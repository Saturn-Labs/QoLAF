package starling.filters {
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import starling.core.Starling;
	import starling.core.starling_internal;
	import starling.display.DisplayObject;
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	import starling.utils.MathUtil;
	import starling.utils.Pool;
	
	use namespace starling_internal;
	
	internal class FilterHelper implements IFilterHelper {
		private var _width:Number;
		
		private var _height:Number;
		
		private var _nativeWidth:int;
		
		private var _nativeHeight:int;
		
		private var _pool:Vector.<Texture>;
		
		private var _usePotTextures:Boolean;
		
		private var _textureFormat:String;
		
		private var _preferredScale:Number;
		
		private var _scale:Number;
		
		private var _sizeStep:int;
		
		private var _numPasses:int;
		
		private var _projectionMatrix:Matrix3D;
		
		private var _renderTarget:Texture;
		
		private var _targetBounds:Rectangle;
		
		private var _target:DisplayObject;
		
		private var _clipRect:Rectangle;
		
		private var sRegion:Rectangle = new Rectangle();
		
		public function FilterHelper(textureFormat:String = "bgra") {
			super();
			_usePotTextures = Starling.current.profile == "baselineConstrained";
			_preferredScale = Starling.contentScaleFactor;
			_textureFormat = textureFormat;
			_sizeStep = 64;
			_pool = new Vector.<Texture>(0);
			_projectionMatrix = new Matrix3D();
			_targetBounds = new Rectangle();
			setSize(_sizeStep,_sizeStep);
		}
		
		public function dispose() : void {
			Pool.putRectangle(_clipRect);
			_clipRect = null;
			purge();
		}
		
		public function start(numPasses:int, drawLastPassToBackBuffer:Boolean) : void {
			_numPasses = drawLastPassToBackBuffer ? numPasses : -1;
		}
		
		public function getTexture(resolution:Number = 1) : Texture {
			var _local3:Texture = null;
			var _local2:SubTexture = null;
			if(_numPasses >= 0) {
				if(_numPasses-- == 0) {
					return null;
				}
			}
			if(_pool.length) {
				_local3 = _pool.pop();
			} else {
				_local3 = Texture.empty(_nativeWidth / _scale,_nativeHeight / _scale,true,false,true,_scale,_textureFormat);
			}
			if(!MathUtil.isEquivalent(_local3.width,_width,0.1) || !MathUtil.isEquivalent(_local3.height,_height,0.1) || !MathUtil.isEquivalent(_local3.scale,_scale * resolution)) {
				sRegion.setTo(0,0,_width * resolution,_height * resolution);
				_local2 = _local3 as SubTexture;
				if(_local2) {
					_local2.starling_internal::setTo(_local3.root,sRegion,true,null,false,resolution);
				} else {
					_local3 = new SubTexture(_local3.root,sRegion,true,null,false,resolution);
				}
			}
			_local3.root.clear();
			return _local3;
		}
		
		public function putTexture(texture:Texture) : void {
			if(texture) {
				if(texture.root.nativeWidth == _nativeWidth && texture.root.nativeHeight == _nativeHeight) {
					_pool.insertAt(_pool.length,texture);
				} else {
					texture.dispose();
				}
			}
		}
		
		public function purge() : void {
			var _local2:int = 0;
			var _local1:int = 0;
			_local2 = 0;
			_local1 = int(_pool.length);
			while(_local2 < _local1) {
				_pool[_local2].dispose();
				_local2++;
			}
			_pool.length = 0;
		}
		
		private function setSize(width:Number, height:Number) : void {
			var _local6:Number = NaN;
			var _local7:Number = _preferredScale;
			var _local4:int = Texture.maxSize;
			var _local5:int = getNativeSize(width,_local7);
			var _local3:int = getNativeSize(height,_local7);
			if(_local5 > _local4 || _local3 > _local4) {
				_local6 = _local4 / Math.max(_local5,_local3);
				_local5 *= _local6;
				_local3 *= _local6;
				_local7 *= _local6;
			}
			if(_nativeWidth != _local5 || _nativeHeight != _local3 || _scale != _local7) {
				purge();
				_scale = _local7;
				_nativeWidth = _local5;
				_nativeHeight = _local3;
			}
			_width = width;
			_height = height;
		}
		
		private function getNativeSize(size:Number, textureScale:Number) : int {
			var _local3:Number = size * textureScale;
			if(_usePotTextures) {
				return _local3 > _sizeStep ? MathUtil.getNextPowerOfTwo(_local3) : _sizeStep;
			}
			return Math.ceil(_local3 / _sizeStep) * _sizeStep;
		}
		
		public function get projectionMatrix3D() : Matrix3D {
			return _projectionMatrix;
		}
		
		public function set projectionMatrix3D(value:Matrix3D) : void {
			_projectionMatrix.copyFrom(value);
		}
		
		public function get renderTarget() : Texture {
			return _renderTarget;
		}
		
		public function set renderTarget(value:Texture) : void {
			_renderTarget = value;
		}
		
		public function get clipRect() : Rectangle {
			return _clipRect;
		}
		
		public function set clipRect(value:Rectangle) : void {
			if(value) {
				if(_clipRect) {
					_clipRect.copyFrom(value);
				} else {
					_clipRect = Pool.getRectangle(value.x,value.y,value.width,value.height);
				}
			} else if(_clipRect) {
				Pool.putRectangle(_clipRect);
				_clipRect = null;
			}
		}
		
		public function get targetBounds() : Rectangle {
			return _targetBounds;
		}
		
		public function set targetBounds(value:Rectangle) : void {
			_targetBounds.copyFrom(value);
			setSize(value.width,value.height);
		}
		
		public function get target() : DisplayObject {
			return _target;
		}
		
		public function set target(value:DisplayObject) : void {
			_target = value;
		}
		
		public function get textureScale() : Number {
			return _preferredScale;
		}
		
		public function set textureScale(value:Number) : void {
			_preferredScale = value > 0 ? value : Starling.contentScaleFactor;
		}
		
		public function get textureFormat() : String {
			return _textureFormat;
		}
		
		public function set textureFormat(value:String) : void {
			_textureFormat = value;
		}
	}
}

