package starling.rendering {
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import starling.textures.Texture;
	import starling.utils.MathUtil;
	import starling.utils.MatrixUtil;
	import starling.utils.Pool;
	import starling.utils.RectangleUtil;
	
	public class RenderState {
		private static var sProjectionMatrix3DRev:uint = 0;
		
		private static const CULLING_VALUES:Vector.<String> = new <String>["none","front","back","frontAndBack"];
		
		private static var sMatrix3D:Matrix3D = new Matrix3D();
		
		internal var _alpha:Number;
		
		internal var _blendMode:String;
		
		internal var _modelviewMatrix:Matrix;
		
		private var _miscOptions:uint;
		
		private var _clipRect:Rectangle;
		
		private var _renderTarget:Texture;
		
		private var _onDrawRequired:Function;
		
		private var _modelviewMatrix3D:Matrix3D;
		
		private var _projectionMatrix3D:Matrix3D;
		
		private var _projectionMatrix3DRev:uint;
		
		private var _mvpMatrix3D:Matrix3D;
		
		public function RenderState() {
			super();
			reset();
		}
		
		public function copyFrom(renderState:RenderState) : void {
			var _local3:TextureBase = null;
			var _local4:TextureBase = null;
			var _local5:* = false;
			var _local2:Boolean = false;
			if(_onDrawRequired != null) {
				_local3 = !!_renderTarget ? _renderTarget.base : null;
				_local4 = !!renderState._renderTarget ? renderState._renderTarget.base : null;
				_local5 = (_miscOptions & 0x0F00) != (renderState._miscOptions & 0x0F00);
				_local2 = _clipRect || renderState._clipRect ? !RectangleUtil.compare(_clipRect,renderState._clipRect) : false;
				if(_blendMode != renderState._blendMode || _local3 != _local4 || _local2 || _local5) {
					_onDrawRequired();
				}
			}
			_alpha = renderState._alpha;
			_blendMode = renderState._blendMode;
			_renderTarget = renderState._renderTarget;
			_miscOptions = renderState._miscOptions;
			_modelviewMatrix.copyFrom(renderState._modelviewMatrix);
			if(_projectionMatrix3DRev != renderState._projectionMatrix3DRev) {
				_projectionMatrix3DRev = renderState._projectionMatrix3DRev;
				_projectionMatrix3D.copyFrom(renderState._projectionMatrix3D);
			}
			if(_modelviewMatrix3D || renderState._modelviewMatrix3D) {
				this.modelviewMatrix3D = renderState._modelviewMatrix3D;
			}
			if(_clipRect || renderState._clipRect) {
				this.clipRect = renderState._clipRect;
			}
		}
		
		public function reset() : void {
			this.alpha = 1;
			this.blendMode = "normal";
			this.culling = "none";
			this.modelviewMatrix3D = null;
			this.renderTarget = null;
			this.clipRect = null;
			_projectionMatrix3DRev = 0;
			if(_modelviewMatrix) {
				_modelviewMatrix.identity();
			} else {
				_modelviewMatrix = new Matrix();
			}
			if(_projectionMatrix3D) {
				_projectionMatrix3D.identity();
			} else {
				_projectionMatrix3D = new Matrix3D();
			}
			if(_mvpMatrix3D == null) {
				_mvpMatrix3D = new Matrix3D();
			}
		}
		
		public function transformModelviewMatrix(matrix:Matrix) : void {
			MatrixUtil.prependMatrix(_modelviewMatrix,matrix);
		}
		
		public function transformModelviewMatrix3D(matrix:Matrix3D) : void {
			if(_modelviewMatrix3D == null) {
				_modelviewMatrix3D = Pool.getMatrix3D();
			}
			_modelviewMatrix3D.prepend(MatrixUtil.convertTo3D(_modelviewMatrix,sMatrix3D));
			_modelviewMatrix3D.prepend(matrix);
			_modelviewMatrix.identity();
		}
		
		public function setProjectionMatrix(x:Number, y:Number, width:Number, height:Number, stageWidth:Number = 0, stageHeight:Number = 0, cameraPos:Vector3D = null) : void {
			_projectionMatrix3DRev = ++sProjectionMatrix3DRev;
			MatrixUtil.createPerspectiveProjectionMatrix(x,y,width,height,stageWidth,stageHeight,cameraPos,_projectionMatrix3D);
		}
		
		public function setProjectionMatrixChanged() : void {
			_projectionMatrix3DRev = ++sProjectionMatrix3DRev;
		}
		
		public function setModelviewMatricesToIdentity() : void {
			_modelviewMatrix.identity();
			if(_modelviewMatrix3D) {
				_modelviewMatrix3D.identity();
			}
		}
		
		public function get modelviewMatrix() : Matrix {
			return _modelviewMatrix;
		}
		
		public function set modelviewMatrix(value:Matrix) : void {
			_modelviewMatrix.copyFrom(value);
		}
		
		public function get modelviewMatrix3D() : Matrix3D {
			return _modelviewMatrix3D;
		}
		
		public function set modelviewMatrix3D(value:Matrix3D) : void {
			if(value) {
				if(_modelviewMatrix3D == null) {
					_modelviewMatrix3D = Pool.getMatrix3D(false);
				}
				_modelviewMatrix3D.copyFrom(value);
			} else if(_modelviewMatrix3D) {
				Pool.putMatrix3D(_modelviewMatrix3D);
				_modelviewMatrix3D = null;
			}
		}
		
		public function get projectionMatrix3D() : Matrix3D {
			return _projectionMatrix3D;
		}
		
		public function set projectionMatrix3D(value:Matrix3D) : void {
			setProjectionMatrixChanged();
			_projectionMatrix3D.copyFrom(value);
		}
		
		public function get mvpMatrix3D() : Matrix3D {
			_mvpMatrix3D.copyFrom(_projectionMatrix3D);
			if(_modelviewMatrix3D) {
				_mvpMatrix3D.prepend(_modelviewMatrix3D);
			}
			_mvpMatrix3D.prepend(MatrixUtil.convertTo3D(_modelviewMatrix,sMatrix3D));
			return _mvpMatrix3D;
		}
		
		public function setRenderTarget(target:Texture, enableDepthAndStencil:Boolean = true, antiAlias:int = 0) : void {
			var _local5:TextureBase = !!_renderTarget ? _renderTarget.base : null;
			var _local6:TextureBase = !!target ? target.base : null;
			var _local7:uint = uint(MathUtil.min(antiAlias,15) | uint(enableDepthAndStencil) << 4);
			var _local4:* = _local7 != (_miscOptions & 0xFF);
			if(_local5 != _local6 || _local4) {
				if(_onDrawRequired != null) {
					_onDrawRequired();
				}
				_renderTarget = target;
				_miscOptions = _miscOptions & 4294967040 | _local7;
			}
		}
		
		public function get alpha() : Number {
			return _alpha;
		}
		
		public function set alpha(value:Number) : void {
			_alpha = value;
		}
		
		public function get blendMode() : String {
			return _blendMode;
		}
		
		public function set blendMode(value:String) : void {
			if(value != "auto" && _blendMode != value) {
				if(_onDrawRequired != null) {
					_onDrawRequired();
				}
				_blendMode = value;
			}
		}
		
		public function get renderTarget() : Texture {
			return _renderTarget;
		}
		
		public function set renderTarget(value:Texture) : void {
			setRenderTarget(value);
		}
		
		internal function get renderTargetBase() : TextureBase {
			return !!_renderTarget ? _renderTarget.base : null;
		}
		
		internal function get renderTargetOptions() : uint {
			return _miscOptions & 0xFF;
		}
		
		public function get culling() : String {
			var _local1:* = (_miscOptions & 0x0F00) >> 8;
			return CULLING_VALUES[_local1];
		}
		
		public function set culling(value:String) : void {
			var _local2:int = 0;
			if(this.culling != value) {
				if(_onDrawRequired != null) {
					_onDrawRequired();
				}
				_local2 = int(CULLING_VALUES.indexOf(value));
				if(_local2 == -1) {
					throw new ArgumentError("Invalid culling mode");
				}
				_miscOptions = _miscOptions & 4294963455 | _local2 << 8;
			}
		}
		
		public function get clipRect() : Rectangle {
			return _clipRect;
		}
		
		public function set clipRect(value:Rectangle) : void {
			if(!RectangleUtil.compare(_clipRect,value)) {
				if(_onDrawRequired != null) {
					_onDrawRequired();
				}
				if(value) {
					if(_clipRect == null) {
						_clipRect = Pool.getRectangle();
					}
					_clipRect.copyFrom(value);
				} else if(_clipRect) {
					Pool.putRectangle(_clipRect);
					_clipRect = null;
				}
			}
		}
		
		public function get renderTargetAntiAlias() : int {
			return _miscOptions & 0x0F;
		}
		
		public function get renderTargetSupportsDepthAndStencil() : Boolean {
			return (_miscOptions & 0xF0) != 0;
		}
		
		public function get is3D() : Boolean {
			return _modelviewMatrix3D != null;
		}
		
		internal function get onDrawRequired() : Function {
			return _onDrawRequired;
		}
		
		internal function set onDrawRequired(value:Function) : void {
			_onDrawRequired = value;
		}
	}
}

