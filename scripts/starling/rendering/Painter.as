package starling.rendering {
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.textures.TextureBase;
	import flash.errors.IllegalOperationError;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import starling.core.starling_internal;
	import starling.display.BlendMode;
	import starling.display.DisplayObject;
	import starling.display.Mesh;
	import starling.display.MeshBatch;
	import starling.display.Quad;
	import starling.textures.Texture;
	import starling.utils.MathUtil;
	import starling.utils.MatrixUtil;
	import starling.utils.MeshSubset;
	import starling.utils.Pool;
	import starling.utils.RectangleUtil;
	import starling.utils.RenderUtil;
	import starling.utils.SystemUtil;
	
	use namespace starling_internal;
	
	public class Painter {
		private static const PROGRAM_DATA_NAME:String = "starling.rendering.Painter.Programs";
		
		private static var sSharedData:Dictionary = new Dictionary();
		
		private static var sMatrix:Matrix = new Matrix();
		
		private static var sPoint3D:Vector3D = new Vector3D();
		
		private static var sMatrix3D:Matrix3D = new Matrix3D();
		
		private static var sClipRect:Rectangle = new Rectangle();
		
		private static var sBufferRect:Rectangle = new Rectangle();
		
		private static var sScissorRect:Rectangle = new Rectangle();
		
		private static var sMeshSubset:MeshSubset = new MeshSubset();
		
		private var _stage3D:Stage3D;
		
		private var _context:Context3D;
		
		private var _shareContext:Boolean;
		
		private var _drawCount:int;
		
		private var _frameID:uint;
		
		private var _pixelSize:Number;
		
		private var _enableErrorChecking:Boolean;
		
		private var _stencilReferenceValues:Dictionary;
		
		private var _clipRectStack:Vector.<Rectangle>;
		
		private var _batchCacheExclusions:Vector.<DisplayObject>;
		
		private var _batchProcessor:BatchProcessor;
		
		private var _batchProcessorCurr:BatchProcessor;
		
		private var _batchProcessorPrev:BatchProcessor;
		
		private var _batchProcessorSpec:BatchProcessor;
		
		private var _actualRenderTarget:TextureBase;
		
		private var _actualRenderTargetOptions:uint;
		
		private var _actualCulling:String;
		
		private var _actualBlendMode:String;
		
		private var _backBufferWidth:Number;
		
		private var _backBufferHeight:Number;
		
		private var _backBufferScaleFactor:Number;
		
		private var _state:RenderState;
		
		private var _stateStack:Vector.<RenderState>;
		
		private var _stateStackPos:int;
		
		private var _stateStackLength:int;
		
		public function Painter(stage3D:Stage3D) {
			super();
			_stage3D = stage3D;
			_stage3D.addEventListener("context3DCreate",onContextCreated,false,40,true);
			_context = _stage3D.context3D;
			_shareContext = _context && _context.driverInfo != "Disposed";
			_backBufferWidth = !!_context ? _context.backBufferWidth : 0;
			_backBufferHeight = !!_context ? _context.backBufferHeight : 0;
			_backBufferScaleFactor = _pixelSize = 1;
			_stencilReferenceValues = new Dictionary(true);
			_clipRectStack = new Vector.<Rectangle>(0);
			_batchProcessorCurr = new BatchProcessor();
			_batchProcessorCurr.onBatchComplete = drawBatch;
			_batchProcessorPrev = new BatchProcessor();
			_batchProcessorPrev.onBatchComplete = drawBatch;
			_batchProcessorSpec = new BatchProcessor();
			_batchProcessorSpec.onBatchComplete = drawBatch;
			_batchProcessor = _batchProcessorCurr;
			_batchCacheExclusions = new Vector.<DisplayObject>();
			_state = new RenderState();
			_state.onDrawRequired = finishMeshBatch;
			_stateStack = new Vector.<RenderState>(0);
			_stateStackPos = -1;
			_stateStackLength = 0;
		}
		
		public function dispose() : void {
			_batchProcessorCurr.dispose();
			_batchProcessorPrev.dispose();
			_batchProcessorSpec.dispose();
			if(!_shareContext) {
				_context.dispose(false);
				sSharedData = new Dictionary();
			}
		}
		
		public function requestContext3D(renderMode:String, profile:*) : void {
			RenderUtil.requestContext3D(_stage3D,renderMode,profile);
		}
		
		private function onContextCreated(event:Object) : void {
			_context = _stage3D.context3D;
			_context.enableErrorChecking = _enableErrorChecking;
			_context.setDepthTest(false,"always");
			_actualBlendMode = null;
			_actualCulling = null;
		}
		
		public function configureBackBuffer(viewPort:Rectangle, contentScaleFactor:Number, antiAlias:int, enableDepthAndStencil:Boolean) : void {
			if(!_shareContext) {
				if(enableDepthAndStencil) {
					enableDepthAndStencil = SystemUtil.supportsDepthAndStencil;
				}
				if(_context.profile == "baselineConstrained") {
					_context.configureBackBuffer(32,32,antiAlias,enableDepthAndStencil);
				}
				if(viewPort.width * contentScaleFactor > _context.maxBackBufferWidth || viewPort.height * contentScaleFactor > _context.maxBackBufferHeight) {
					contentScaleFactor = 1;
				}
				_stage3D.x = viewPort.x;
				_stage3D.y = viewPort.y;
				_context.configureBackBuffer(viewPort.width,viewPort.height,antiAlias,enableDepthAndStencil,contentScaleFactor != 1);
			}
			_backBufferWidth = viewPort.width;
			_backBufferHeight = viewPort.height;
			_backBufferScaleFactor = contentScaleFactor;
		}
		
		public function registerProgram(name:String, program:Program) : void {
			deleteProgram(name);
			programs[name] = program;
		}
		
		public function deleteProgram(name:String) : void {
			var _local2:Program = getProgram(name);
			if(_local2) {
				_local2.dispose();
				delete programs[name];
			}
		}
		
		public function getProgram(name:String) : Program {
			return programs[name] as Program;
		}
		
		public function hasProgram(name:String) : Boolean {
			return name in programs;
		}
		
		public function pushState(token:BatchToken = null) : void {
			_stateStackPos++;
			if(_stateStackLength < _stateStackPos + 1) {
				_stateStack[_stateStackLength++] = new RenderState();
			}
			if(token) {
				_batchProcessor.fillToken(token);
			}
			_stateStack[_stateStackPos].copyFrom(_state);
		}
		
		public function setStateTo(transformationMatrix:Matrix, alphaFactor:Number = 1, blendMode:String = "auto") : void {
			if(transformationMatrix) {
				MatrixUtil.prependMatrix(_state._modelviewMatrix,transformationMatrix);
			}
			if(alphaFactor != 1) {
				_state._alpha *= alphaFactor;
			}
			if(blendMode != "auto") {
				_state.blendMode = blendMode;
			}
		}
		
		public function popState(token:BatchToken = null) : void {
			if(_stateStackPos < 0) {
				throw new IllegalOperationError("Cannot pop empty state stack");
			}
			_state.copyFrom(_stateStack[_stateStackPos]);
			_stateStackPos--;
			if(token) {
				_batchProcessor.fillToken(token);
			}
		}
		
		public function drawMask(mask:DisplayObject, maskee:DisplayObject = null) : void {
			if(_context == null) {
				return;
			}
			finishMeshBatch();
			if(isRectangularMask(mask,maskee,sMatrix)) {
				mask.getBounds(mask,sClipRect);
				RectangleUtil.getBounds(sClipRect,sMatrix,sClipRect);
				pushClipRect(sClipRect);
			} else {
				_context.setStencilActions("frontAndBack","equal","incrementSaturate");
				renderMask(mask);
				stencilReferenceValue++;
				_context.setStencilActions("frontAndBack","equal","keep");
			}
			excludeFromCache(maskee);
		}
		
		public function eraseMask(mask:DisplayObject, maskee:DisplayObject = null) : void {
			if(_context == null) {
				return;
			}
			finishMeshBatch();
			if(isRectangularMask(mask,maskee,sMatrix)) {
				popClipRect();
			} else {
				_context.setStencilActions("frontAndBack","equal","decrementSaturate");
				renderMask(mask);
				stencilReferenceValue--;
				_context.setStencilActions("frontAndBack","equal","keep");
			}
		}
		
		private function renderMask(mask:DisplayObject) : void {
			var _local2:Boolean = cacheEnabled;
			pushState();
			cacheEnabled = false;
			_state.alpha = 0;
			var _local4:Matrix = null;
			var _local3:Matrix3D = null;
			if(mask.stage) {
				_state.setModelviewMatricesToIdentity();
				if(mask.is3D) {
					_local3 = mask.getTransformationMatrix3D(null,sMatrix3D);
				} else {
					_local4 = mask.getTransformationMatrix(null,sMatrix);
				}
			} else if(mask.is3D) {
				_local3 = mask.transformationMatrix3D;
			} else {
				_local4 = mask.transformationMatrix;
			}
			if(_local3) {
				_state.transformModelviewMatrix3D(_local3);
			} else {
				_state.transformModelviewMatrix(_local4);
			}
			mask.render(this);
			finishMeshBatch();
			cacheEnabled = _local2;
			popState();
		}
		
		private function pushClipRect(clipRect:Rectangle) : void {
			var _local2:Vector.<Rectangle> = _clipRectStack;
			var _local4:uint = _local2.length;
			var _local3:Rectangle = Pool.getRectangle();
			if(_local4) {
				RectangleUtil.intersect(_local2[_local4 - 1],clipRect,_local3);
			} else {
				_local3.copyFrom(clipRect);
			}
			_local2[_local4] = _local3;
			_state.clipRect = _local3;
		}
		
		private function popClipRect() : void {
			var _local1:Vector.<Rectangle> = _clipRectStack;
			var _local2:uint = _local1.length;
			if(_local2 == 0) {
				throw new Error("Trying to pop from empty clip rectangle stack");
			}
			_local2--;
			Pool.putRectangle(_local1.pop());
			_state.clipRect = !!_local2 ? _local1[_local2 - 1] : null;
		}
		
		private function isRectangularMask(mask:DisplayObject, maskee:DisplayObject, out:Matrix) : Boolean {
			var _local4:Quad = mask as Quad;
			var _local5:Boolean = mask.is3D || maskee && maskee.is3D && mask.stage == null;
			if(_local4 && !_local5 && _local4.texture == null) {
				if(mask.stage) {
					mask.getTransformationMatrix(null,out);
				} else {
					out.copyFrom(mask.transformationMatrix);
					out.concat(_state.modelviewMatrix);
				}
				return MathUtil.isEquivalent(out.a,0) && MathUtil.isEquivalent(out.d,0) || MathUtil.isEquivalent(out.b,0) && MathUtil.isEquivalent(out.c,0);
			}
			return false;
		}
		
		public function batchMesh(mesh:Mesh, subset:MeshSubset = null) : void {
			_batchProcessor.addMesh(mesh,_state,subset);
		}
		
		public function finishMeshBatch() : void {
			_batchProcessor.finishBatch();
		}
		
		public function finishFrame() : void {
			if(_frameID % 99 == 0) {
				_batchProcessorCurr.trim();
			}
			if(_frameID % 150 == 0) {
				_batchProcessorSpec.trim();
			}
			_batchProcessor.finishBatch();
			_batchProcessor = _batchProcessorSpec;
			processCacheExclusions();
		}
		
		private function processCacheExclusions() : void {
			var _local2:int = 0;
			var _local1:int = int(_batchCacheExclusions.length);
			_local2 = 0;
			while(_local2 < _local1) {
				_batchCacheExclusions[_local2].starling_internal::excludeFromCache();
				_local2++;
			}
			_batchCacheExclusions.length = 0;
		}
		
		public function nextFrame() : void {
			_batchProcessor = swapBatchProcessors();
			_batchProcessor.clear();
			_batchProcessorSpec.clear();
			_actualBlendMode = null;
			_actualCulling = null;
			_context.setDepthTest(false,"always");
			stencilReferenceValue = 0;
			_clipRectStack.length = 0;
			_drawCount = 0;
			_stateStackPos = -1;
			_state.reset();
		}
		
		private function swapBatchProcessors() : BatchProcessor {
			var _local1:BatchProcessor = _batchProcessorPrev;
			_batchProcessorPrev = _batchProcessorCurr;
			return _batchProcessorCurr = _local1;
		}
		
		public function drawFromCache(startToken:BatchToken, endToken:BatchToken) : void {
			var _local3:MeshBatch = null;
			var _local4:int = 0;
			var _local5:MeshSubset = sMeshSubset;
			if(!startToken.equals(endToken)) {
				pushState();
				_local4 = startToken.batchID;
				while(_local4 <= endToken.batchID) {
					_local3 = _batchProcessorPrev.getBatchAt(_local4);
					_local5.setTo();
					if(_local4 == startToken.batchID) {
						_local5.vertexID = startToken.vertexID;
						_local5.indexID = startToken.indexID;
						_local5.numVertices = _local3.numVertices - _local5.vertexID;
						_local5.numIndices = _local3.numIndices - _local5.indexID;
					}
					if(_local4 == endToken.batchID) {
						_local5.numVertices = endToken.vertexID - _local5.vertexID;
						_local5.numIndices = endToken.indexID - _local5.indexID;
					}
					if(_local5.numVertices) {
						_state.alpha = 1;
						_state.blendMode = _local3.blendMode;
						_batchProcessor.addMesh(_local3,_state,_local5,true);
					}
					_local4++;
				}
				popState();
			}
		}
		
		public function excludeFromCache(object:DisplayObject) : void {
			if(object) {
				_batchCacheExclusions[_batchCacheExclusions.length] = object;
			}
		}
		
		private function drawBatch(meshBatch:MeshBatch) : void {
			pushState();
			state.blendMode = meshBatch.blendMode;
			state.modelviewMatrix.identity();
			state.alpha = 1;
			meshBatch.render(this);
			popState();
		}
		
		public function prepareToDraw() : void {
			applyBlendMode();
			applyRenderTarget();
			applyClipRect();
			applyCulling();
		}
		
		public function clear(rgb:uint = 0, alpha:Number = 0) : void {
			applyRenderTarget();
			stencilReferenceValue = 0;
			RenderUtil.clear(rgb,alpha);
		}
		
		public function present() : void {
			_state.renderTarget = null;
			_actualRenderTarget = null;
			_context.present();
		}
		
		private function applyBlendMode() : void {
			var _local1:String = _state.blendMode;
			if(_local1 != _actualBlendMode) {
				BlendMode.get(_state.blendMode).activate();
				_actualBlendMode = _local1;
			}
		}
		
		private function applyCulling() : void {
			var _local1:String = _state.culling;
			if(_local1 != _actualCulling) {
				_context.setCulling(_local1);
				_actualCulling = _local1;
			}
		}
		
		private function applyRenderTarget() : void {
			var _local3:int = 0;
			var _local1:Boolean = false;
			var _local4:TextureBase = _state.renderTargetBase;
			var _local2:uint = _state.renderTargetOptions;
			if(_local4 != _actualRenderTarget || _local2 != _actualRenderTargetOptions) {
				if(_local4) {
					_local3 = _state.renderTargetAntiAlias;
					_local1 = _state.renderTargetSupportsDepthAndStencil;
					_context.setRenderToTexture(_local4,_local1,_local3);
				} else {
					_context.setRenderToBackBuffer();
				}
				_context.setStencilReferenceValue(stencilReferenceValue);
				_actualRenderTargetOptions = _local2;
				_actualRenderTarget = _local4;
			}
		}
		
		private function applyClipRect() : void {
			var _local5:int = 0;
			var _local3:int = 0;
			var _local4:Matrix3D = null;
			var _local2:Texture = null;
			var _local1:Rectangle = _state.clipRect;
			if(_local1) {
				_local4 = _state.projectionMatrix3D;
				_local2 = _state.renderTarget;
				if(_local2) {
					_local3 = _local2.root.nativeWidth;
					_local5 = _local2.root.nativeHeight;
				} else {
					_local3 = _backBufferWidth;
					_local5 = _backBufferHeight;
				}
				MatrixUtil.transformCoords3D(_local4,_local1.x,_local1.y,0,sPoint3D);
				sPoint3D.project();
				sClipRect.x = (sPoint3D.x * 0.5 + 0.5) * _local3;
				sClipRect.y = (0.5 - sPoint3D.y * 0.5) * _local5;
				MatrixUtil.transformCoords3D(_local4,_local1.right,_local1.bottom,0,sPoint3D);
				sPoint3D.project();
				sClipRect.right = (sPoint3D.x * 0.5 + 0.5) * _local3;
				sClipRect.bottom = (0.5 - sPoint3D.y * 0.5) * _local5;
				sBufferRect.setTo(0,0,_local3,_local5);
				RectangleUtil.intersect(sClipRect,sBufferRect,sScissorRect);
				if(sScissorRect.width < 1 || sScissorRect.height < 1) {
					sScissorRect.setTo(0,0,1,1);
				}
				_context.setScissorRectangle(sScissorRect);
			} else {
				_context.setScissorRectangle(null);
			}
		}
		
		public function get drawCount() : int {
			return _drawCount;
		}
		
		public function set drawCount(value:int) : void {
			_drawCount = value;
		}
		
		public function get stencilReferenceValue() : uint {
			var _local1:Object = !!_state.renderTarget ? _state.renderTargetBase : this;
			if(_local1 in _stencilReferenceValues) {
				return _stencilReferenceValues[_local1];
			}
			return 0;
		}
		
		public function set stencilReferenceValue(value:uint) : void {
			var _local2:Object = !!_state.renderTarget ? _state.renderTargetBase : this;
			_stencilReferenceValues[_local2] = value;
			if(contextValid) {
				_context.setStencilReferenceValue(value);
			}
		}
		
		public function get cacheEnabled() : Boolean {
			return _batchProcessor == _batchProcessorCurr;
		}
		
		public function set cacheEnabled(value:Boolean) : void {
			if(value != cacheEnabled) {
				finishMeshBatch();
				if(value) {
					_batchProcessor = _batchProcessorCurr;
				} else {
					_batchProcessor = _batchProcessorSpec;
				}
			}
		}
		
		public function get state() : RenderState {
			return _state;
		}
		
		public function get stage3D() : Stage3D {
			return _stage3D;
		}
		
		public function get context() : Context3D {
			return _context;
		}
		
		public function set frameID(value:uint) : void {
			_frameID = value;
		}
		
		public function get frameID() : uint {
			return _batchProcessor == _batchProcessorCurr ? _frameID : 0;
		}
		
		public function get pixelSize() : Number {
			return _pixelSize;
		}
		
		public function set pixelSize(value:Number) : void {
			_pixelSize = value;
		}
		
		public function get shareContext() : Boolean {
			return _shareContext;
		}
		
		public function set shareContext(value:Boolean) : void {
			_shareContext = value;
		}
		
		public function get enableErrorChecking() : Boolean {
			return _enableErrorChecking;
		}
		
		public function set enableErrorChecking(value:Boolean) : void {
			_enableErrorChecking = value;
			if(_context) {
				_context.enableErrorChecking = value;
			}
		}
		
		public function get backBufferWidth() : int {
			return _backBufferWidth;
		}
		
		public function get backBufferHeight() : int {
			return _backBufferHeight;
		}
		
		public function get backBufferScaleFactor() : Number {
			return _backBufferScaleFactor;
		}
		
		public function get contextValid() : Boolean {
			var _local1:String = null;
			if(_context) {
				_local1 = _context.driverInfo;
				return _local1 != null && _local1 != "" && _local1 != "Disposed";
			}
			return false;
		}
		
		public function get profile() : String {
			if(_context) {
				return _context.profile;
			}
			return null;
		}
		
		public function get sharedData() : Dictionary {
			var _local1:Dictionary = sSharedData[stage3D] as Dictionary;
			if(_local1 == null) {
				_local1 = new Dictionary();
				sSharedData[stage3D] = _local1;
			}
			return _local1;
		}
		
		private function get programs() : Dictionary {
			var _local1:Dictionary = sharedData["starling.rendering.Painter.Programs"] as Dictionary;
			if(_local1 == null) {
				_local1 = new Dictionary();
				sharedData["starling.rendering.Painter.Programs"] = _local1;
			}
			return _local1;
		}
	}
}

