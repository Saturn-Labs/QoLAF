package starling.filters {
	import flash.errors.IllegalOperationError;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import starling.core.Starling;
	import starling.core.starling_internal;
	import starling.display.DisplayObject;
	import starling.display.Stage;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.rendering.FilterEffect;
	import starling.rendering.IndexData;
	import starling.rendering.Painter;
	import starling.rendering.VertexData;
	import starling.textures.Texture;
	import starling.utils.MatrixUtil;
	import starling.utils.Padding;
	import starling.utils.Pool;
	import starling.utils.RectangleUtil;
	
	use namespace starling_internal;
	
	public class FragmentFilter extends EventDispatcher {
		private static var sMatrix3D:Matrix3D;
		
		private var _quad:FilterQuad;
		
		private var _target:DisplayObject;
		
		private var _effect:FilterEffect;
		
		private var _vertexData:VertexData;
		
		private var _indexData:IndexData;
		
		private var _padding:Padding;
		
		private var _helper:FilterHelper;
		
		private var _resolution:Number;
		
		private var _antiAliasing:int;
		
		private var _textureFormat:String;
		
		private var _textureSmoothing:String;
		
		private var _alwaysDrawToBackBuffer:Boolean;
		
		private var _cacheRequested:Boolean;
		
		private var _cached:Boolean;
		
		public function FragmentFilter() {
			super();
			_resolution = 1;
			_textureFormat = "bgra";
			_textureSmoothing = "bilinear";
			Starling.current.stage3D.addEventListener("context3DCreate",onContextCreated,false,0,true);
		}
		
		public function dispose() : void {
			Starling.current.stage3D.removeEventListener("context3DCreate",onContextCreated);
			if(_helper) {
				_helper.dispose();
			}
			if(_effect) {
				_effect.dispose();
			}
			if(_quad) {
				_quad.dispose();
			}
			_effect = null;
			_quad = null;
		}
		
		private function onContextCreated(event:Object) : void {
			setRequiresRedraw();
		}
		
		public function render(painter:Painter) : void {
			if(_target == null) {
				throw new IllegalOperationError("Cannot render filter without target");
			}
			if(_target.is3D) {
				_cached = _cacheRequested = false;
			}
			if(!_cached || _cacheRequested) {
				renderPasses(painter,_cacheRequested);
				_cacheRequested = false;
			} else if(_quad.visible) {
				_quad.render(painter);
			}
		}
		
		private function renderPasses(painter:Painter, forCache:Boolean) : void {
			var _local4:Rectangle = null;
			var _local3:Texture = null;
			if(_helper == null) {
				_helper = new FilterHelper(_textureFormat);
			}
			if(_quad == null) {
				_quad = new FilterQuad(_textureSmoothing);
			} else {
				_helper.putTexture(_quad.texture);
				_quad.texture = null;
			}
			var _local11:Rectangle = Pool.getRectangle();
			var _local10:* = false;
			var _local12:Number = _resolution;
			var _local6:DisplayObject = _target.stage || _target.parent;
			var _local7:* = _local6 is Stage;
			var _local8:Stage = Starling.current.stage;
			if(!forCache && (_alwaysDrawToBackBuffer || _target.requiresRedraw)) {
				_local10 = painter.state.alpha == 1;
				painter.excludeFromCache(_target);
			}
			if(_target == Starling.current.root) {
				_local8.getStageBounds(_target,_local11);
			} else {
				_target.getBounds(_local6,_local11);
				if(!forCache && _local7) {
					_local4 = _local8.getStageBounds(null,Pool.getRectangle());
					RectangleUtil.intersect(_local11,_local4,_local11);
					Pool.putRectangle(_local4);
				}
			}
			_quad.visible = !_local11.isEmpty();
			if(!_quad.visible) {
				Pool.putRectangle(_local11);
				return;
			}
			if(_padding) {
				RectangleUtil.extend(_local11,_padding.left,_padding.right,_padding.top,_padding.bottom);
			}
			_local11.setTo(Math.floor(_local11.x),Math.floor(_local11.y),Math.ceil(_local11.width),Math.ceil(_local11.height));
			_helper.textureScale = Starling.contentScaleFactor * _resolution;
			_helper.projectionMatrix3D = painter.state.projectionMatrix3D;
			_helper.renderTarget = painter.state.renderTarget;
			_helper.clipRect = painter.state.clipRect;
			_helper.targetBounds = _local11;
			_helper.target = _target;
			_helper.start(numPasses,_local10);
			_quad.setBounds(_local11);
			_resolution = 1;
			var _local9:Boolean = painter.cacheEnabled;
			var _local5:Texture = _helper.getTexture();
			painter.cacheEnabled = false;
			painter.pushState();
			painter.state.alpha = 1;
			painter.state.clipRect = null;
			painter.state.setRenderTarget(_local5,true,_antiAliasing);
			painter.state.setProjectionMatrix(_local11.x,_local11.y,_local5.root.width,_local5.root.height,_local8.stageWidth,_local8.stageHeight,_local8.cameraPosition);
			_target.render(painter);
			painter.finishMeshBatch();
			painter.state.setModelviewMatricesToIdentity();
			_local3 = process(painter,_helper,_local5);
			painter.popState();
			painter.cacheEnabled = _local9;
			if(_local3) {
				painter.pushState();
				if(_target.is3D) {
					painter.state.setModelviewMatricesToIdentity();
				} else {
					_quad.moveVertices(_local6,_target);
				}
				_quad.texture = _local3;
				_quad.render(painter);
				painter.finishMeshBatch();
				painter.popState();
			}
			_helper.target = null;
			_helper.putTexture(_local5);
			_resolution = _local12;
			Pool.putRectangle(_local11);
		}
		
		public function process(painter:Painter, helper:IFilterHelper, input0:Texture = null, input1:Texture = null, input2:Texture = null, input3:Texture = null) : Texture {
			var _local8:Matrix3D = null;
			var _local10:* = null;
			var _local9:FilterEffect = this.effect;
			var _local7:Texture = helper.getTexture(_resolution);
			var _local11:Rectangle = null;
			if(_local7) {
				_local10 = _local7;
				_local8 = MatrixUtil.createPerspectiveProjectionMatrix(0,0,_local7.root.width / _resolution,_local7.root.height / _resolution,0,0,null,sMatrix3D);
			} else {
				_local11 = helper.targetBounds;
				_local10 = (helper as FilterHelper).renderTarget;
				_local8 = (helper as FilterHelper).projectionMatrix3D;
				_local9.textureSmoothing = _textureSmoothing;
				painter.state.clipRect = (helper as FilterHelper).clipRect;
				painter.state.projectionMatrix3D.copyFrom(_local8);
			}
			painter.state.renderTarget = _local10;
			painter.prepareToDraw();
			painter.drawCount += 1;
			input0.setupVertexPositions(vertexData,0,"position",_local11);
			input0.setupTextureCoordinates(vertexData);
			_local9.texture = input0;
			_local9.mvpMatrix3D = _local8;
			_local9.uploadVertexData(vertexData);
			_local9.uploadIndexData(indexData);
			_local9.render(0,indexData.numTriangles);
			return _local7;
		}
		
		protected function createEffect() : FilterEffect {
			return new FilterEffect();
		}
		
		public function cache() : void {
			_cached = _cacheRequested = true;
			setRequiresRedraw();
		}
		
		public function clearCache() : void {
			_cached = _cacheRequested = false;
			setRequiresRedraw();
		}
		
		override public function addEventListener(type:String, listener:Function) : void {
			if(type == "enterFrame" && _target) {
				_target.addEventListener("enterFrame",onEnterFrame);
			}
			super.addEventListener(type,listener);
		}
		
		override public function removeEventListener(type:String, listener:Function) : void {
			if(type == "enterFrame" && _target) {
				_target.removeEventListener(type,onEnterFrame);
			}
			super.removeEventListener(type,listener);
		}
		
		private function onEnterFrame(event:Event) : void {
			dispatchEvent(event);
		}
		
		protected function get effect() : FilterEffect {
			if(_effect == null) {
				_effect = createEffect();
			}
			return _effect;
		}
		
		protected function get vertexData() : VertexData {
			if(_vertexData == null) {
				_vertexData = new VertexData(effect.vertexFormat,4);
			}
			return _vertexData;
		}
		
		protected function get indexData() : IndexData {
			if(_indexData == null) {
				_indexData = new IndexData(6);
				_indexData.addQuad(0,1,2,3);
			}
			return _indexData;
		}
		
		protected function setRequiresRedraw() : void {
			dispatchEventWith("change");
			if(_target) {
				_target.setRequiresRedraw();
			}
			if(_cached) {
				_cacheRequested = true;
			}
		}
		
		public function get numPasses() : int {
			return 1;
		}
		
		protected function onTargetAssigned(target:DisplayObject) : void {
		}
		
		public function get padding() : Padding {
			if(_padding == null) {
				_padding = new Padding();
				_padding.addEventListener("change",setRequiresRedraw);
			}
			return _padding;
		}
		
		public function set padding(value:Padding) : void {
			padding.copyFrom(value);
		}
		
		public function get isCached() : Boolean {
			return _cached;
		}
		
		public function get resolution() : Number {
			return _resolution;
		}
		
		public function set resolution(value:Number) : void {
			if(value != _resolution) {
				if(value <= 0) {
					throw new ArgumentError("resolution must be > 0");
				}
				_resolution = value;
				setRequiresRedraw();
			}
		}
		
		public function get antiAliasing() : int {
			return _antiAliasing;
		}
		
		public function set antiAliasing(value:int) : void {
			if(value != _antiAliasing) {
				_antiAliasing = value;
				setRequiresRedraw();
			}
		}
		
		public function get textureSmoothing() : String {
			return _textureSmoothing;
		}
		
		public function set textureSmoothing(value:String) : void {
			if(value != _textureSmoothing) {
				_textureSmoothing = value;
				if(_quad) {
					_quad.textureSmoothing = value;
				}
				setRequiresRedraw();
			}
		}
		
		public function get textureFormat() : String {
			return _textureFormat;
		}
		
		public function set textureFormat(value:String) : void {
			if(value != _textureFormat) {
				_textureFormat = value;
				if(_helper) {
					_helper.textureFormat = value;
				}
				setRequiresRedraw();
			}
		}
		
		public function get alwaysDrawToBackBuffer() : Boolean {
			return _alwaysDrawToBackBuffer;
		}
		
		public function set alwaysDrawToBackBuffer(value:Boolean) : void {
			_alwaysDrawToBackBuffer = value;
		}
		
		starling_internal function setTarget(target:DisplayObject) : void {
			var _local2:DisplayObject = null;
			if(target != _target) {
				_local2 = _target;
				_target = target;
				if(target == null) {
					if(_helper) {
						_helper.purge();
					}
					if(_effect) {
						_effect.purgeBuffers();
					}
					if(_quad) {
						_quad.disposeTexture();
					}
				}
				if(_local2) {
					_local2.filter = null;
					_local2.removeEventListener("enterFrame",onEnterFrame);
				}
				if(target) {
					if(hasEventListener("enterFrame")) {
						target.addEventListener("enterFrame",onEnterFrame);
					}
					onTargetAssigned(target);
				}
			}
		}
	}
}

import flash.geom.Matrix;
import flash.geom.Rectangle;
import starling.display.DisplayObject;
import starling.display.Mesh;
import starling.rendering.IndexData;
import starling.rendering.VertexData;
import starling.textures.Texture;

class FilterQuad extends Mesh {
	private static var sMatrix:Matrix = new Matrix();
	
	public function FilterQuad(smoothing:String) {
		var _local2:VertexData = new VertexData(null,4);
		_local2.numVertices = 4;
		var _local3:IndexData = new IndexData(6);
		_local3.addQuad(0,1,2,3);
		super(_local2,_local3);
		textureSmoothing = smoothing;
		pixelSnapping = false;
	}
	
	override public function dispose() : void {
		disposeTexture();
		super.dispose();
	}
	
	public function disposeTexture() : void {
		if(texture) {
			texture.dispose();
			texture = null;
		}
	}
	
	public function moveVertices(sourceSpace:DisplayObject, targetSpace:DisplayObject) : void {
		if(targetSpace.is3D) {
			throw new Error("cannot move vertices into 3D space");
		}
		if(sourceSpace != targetSpace) {
			targetSpace.getTransformationMatrix(sourceSpace,sMatrix).invert();
			vertexData.transformPoints("position",sMatrix);
		}
	}
	
	public function setBounds(bounds:Rectangle) : void {
		var _local2:VertexData = this.vertexData;
		var _local3:String = "position";
		_local2.setPoint(0,_local3,bounds.x,bounds.y);
		_local2.setPoint(1,_local3,bounds.right,bounds.y);
		_local2.setPoint(2,_local3,bounds.x,bounds.bottom);
		_local2.setPoint(3,_local3,bounds.right,bounds.bottom);
	}
	
	override public function set texture(value:Texture) : void {
		super.texture = value;
		if(value) {
			value.setupTextureCoordinates(vertexData);
		}
	}
}
