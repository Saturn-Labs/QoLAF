package starling.display {
	import flash.errors.IllegalOperationError;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.system.Capabilities;
	import flash.ui.Mouse;
	import flash.utils.getQualifiedClassName;
	import starling.core.Starling;
	import starling.core.starling_internal;
	import starling.errors.AbstractClassError;
	import starling.errors.AbstractMethodError;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.events.TouchEvent;
	import starling.filters.FragmentFilter;
	import starling.rendering.BatchToken;
	import starling.rendering.Painter;
	import starling.utils.MathUtil;
	import starling.utils.MatrixUtil;
	import starling.utils.SystemUtil;
	
	use namespace starling_internal;
	
	public class DisplayObject extends EventDispatcher {
		private static var sMaskWarningShown:Boolean = false;
		
		private static var sAncestors:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
		
		private static var sHelperPoint:Point = new Point();
		
		private static var sHelperPoint3D:Vector3D = new Vector3D();
		
		private static var sHelperPointAlt3D:Vector3D = new Vector3D();
		
		private static var sHelperRect:Rectangle = new Rectangle();
		
		private static var sHelperMatrix:Matrix = new Matrix();
		
		private static var sHelperMatrixAlt:Matrix = new Matrix();
		
		private static var sHelperMatrix3D:Matrix3D = new Matrix3D();
		
		private static var sHelperMatrixAlt3D:Matrix3D = new Matrix3D();
		
		private var _x:Number;
		
		private var _y:Number;
		
		private var _pivotX:Number;
		
		private var _pivotY:Number;
		
		private var _scaleX:Number;
		
		private var _scaleY:Number;
		
		private var _skewX:Number;
		
		private var _skewY:Number;
		
		private var _rotation:Number;
		
		private var _alpha:Number;
		
		private var _visible:Boolean;
		
		private var _touchable:Boolean;
		
		private var _blendMode:String;
		
		private var _name:String;
		
		private var _useHandCursor:Boolean;
		
		private var _transformationMatrix:Matrix;
		
		private var _transformationMatrix3D:Matrix3D;
		
		private var _orientationChanged:Boolean;
		
		private var _is3D:Boolean;
		
		private var _maskee:DisplayObject;
		
		internal var _parent:DisplayObjectContainer;
		
		internal var _lastParentOrSelfChangeFrameID:uint;
		
		internal var _lastChildChangeFrameID:uint;
		
		internal var _tokenFrameID:uint;
		
		internal var _pushToken:BatchToken = new BatchToken();
		
		internal var _popToken:BatchToken = new BatchToken();
		
		internal var _hasVisibleArea:Boolean;
		
		internal var _filter:FragmentFilter;
		
		internal var _mask:DisplayObject;
		
		public function DisplayObject() {
			super();
			if(Capabilities.isDebugger && getQualifiedClassName(this) == "starling.display::DisplayObject") {
				throw new AbstractClassError();
			}
			_x = _y = _pivotX = _pivotY = _rotation = _skewX = _skewY = 0;
			_scaleX = _scaleY = _alpha = 1;
			_visible = _touchable = _hasVisibleArea = true;
			_blendMode = "auto";
			_transformationMatrix = new Matrix();
		}
		
		private static function findCommonParent(object1:DisplayObject, object2:DisplayObject) : DisplayObject {
			var _local3:* = object1;
			while(_local3) {
				sAncestors[sAncestors.length] = _local3;
				_local3 = _local3._parent;
			}
			_local3 = object2;
			while(_local3 && sAncestors.indexOf(_local3) == -1) {
				_local3 = _local3._parent;
			}
			sAncestors.length = 0;
			if(_local3) {
				return _local3;
			}
			throw new ArgumentError("Object not connected to target");
		}
		
		public function dispose() : void {
			if(_filter) {
				_filter.dispose();
			}
			if(_mask) {
				_mask.dispose();
			}
			removeEventListeners();
			mask = null;
		}
		
		public function removeFromParent(dispose:Boolean = false) : void {
			if(_parent) {
				_parent.removeChild(this,dispose);
			} else if(dispose) {
				this.dispose();
			}
		}
		
		public function getTransformationMatrix(targetSpace:DisplayObject, out:Matrix = null) : Matrix {
			var _local3:DisplayObject = null;
			var _local4:* = null;
			if(out) {
				out.identity();
			} else {
				out = new Matrix();
			}
			if(targetSpace == this) {
				return out;
			}
			if(targetSpace == _parent || targetSpace == null && _parent == null) {
				out.copyFrom(transformationMatrix);
				return out;
			}
			if(targetSpace == null || targetSpace == base) {
				_local4 = this;
				while(_local4 != targetSpace) {
					out.concat(_local4.transformationMatrix);
					_local4 = _local4._parent;
				}
				return out;
			}
			if(targetSpace._parent == this) {
				targetSpace.getTransformationMatrix(this,out);
				out.invert();
				return out;
			}
			_local3 = findCommonParent(this,targetSpace);
			_local4 = this;
			while(_local4 != _local3) {
				out.concat(_local4.transformationMatrix);
				_local4 = _local4._parent;
			}
			if(_local3 == targetSpace) {
				return out;
			}
			sHelperMatrix.identity();
			_local4 = targetSpace;
			while(_local4 != _local3) {
				sHelperMatrix.concat(_local4.transformationMatrix);
				_local4 = _local4._parent;
			}
			sHelperMatrix.invert();
			out.concat(sHelperMatrix);
			return out;
		}
		
		public function getBounds(targetSpace:DisplayObject, out:Rectangle = null) : Rectangle {
			throw new AbstractMethodError();
		}
		
		public function hitTest(localPoint:Point) : DisplayObject {
			if(!_visible || !_touchable) {
				return null;
			}
			if(_mask && !hitTestMask(localPoint)) {
				return null;
			}
			if(getBounds(this,sHelperRect).containsPoint(localPoint)) {
				return this;
			}
			return null;
		}
		
		public function hitTestMask(localPoint:Point) : Boolean {
			var _local2:Point = null;
			if(_mask) {
				if(_mask.stage) {
					getTransformationMatrix(_mask,sHelperMatrixAlt);
				} else {
					sHelperMatrixAlt.copyFrom(_mask.transformationMatrix);
					sHelperMatrixAlt.invert();
				}
				_local2 = localPoint == sHelperPoint ? new Point() : sHelperPoint;
				MatrixUtil.transformPoint(sHelperMatrixAlt,localPoint,_local2);
				return _mask.hitTest(_local2) != null;
			}
			return true;
		}
		
		public function localToGlobal(localPoint:Point, out:Point = null) : Point {
			if(is3D) {
				sHelperPoint3D.setTo(localPoint.x,localPoint.y,0);
				return local3DToGlobal(sHelperPoint3D,out);
			}
			getTransformationMatrix(base,sHelperMatrixAlt);
			return MatrixUtil.transformPoint(sHelperMatrixAlt,localPoint,out);
		}
		
		public function globalToLocal(globalPoint:Point, out:Point = null) : Point {
			if(is3D) {
				globalToLocal3D(globalPoint,sHelperPoint3D);
				stage.getCameraPosition(this,sHelperPointAlt3D);
				return MathUtil.intersectLineWithXYPlane(sHelperPointAlt3D,sHelperPoint3D,out);
			}
			getTransformationMatrix(base,sHelperMatrixAlt);
			sHelperMatrixAlt.invert();
			return MatrixUtil.transformPoint(sHelperMatrixAlt,globalPoint,out);
		}
		
		public function render(painter:Painter) : void {
			throw new AbstractMethodError();
		}
		
		public function alignPivot(horizontalAlign:String = "center", verticalAlign:String = "center") : void {
			var _local3:Rectangle = getBounds(this,sHelperRect);
			setOrientationChanged();
			if(horizontalAlign == "left") {
				_pivotX = _local3.x;
			} else if(horizontalAlign == "center") {
				_pivotX = _local3.x + _local3.width / 2;
			} else {
				if(horizontalAlign != "right") {
					throw new ArgumentError("Invalid horizontal alignment: " + horizontalAlign);
				}
				_pivotX = _local3.x + _local3.width;
			}
			if(verticalAlign == "top") {
				_pivotY = _local3.y;
			} else if(verticalAlign == "center") {
				_pivotY = _local3.y + _local3.height / 2;
			} else {
				if(verticalAlign != "bottom") {
					throw new ArgumentError("Invalid vertical alignment: " + verticalAlign);
				}
				_pivotY = _local3.y + _local3.height;
			}
		}
		
		public function getTransformationMatrix3D(targetSpace:DisplayObject, out:Matrix3D = null) : Matrix3D {
			var _local3:DisplayObject = null;
			var _local4:* = null;
			if(out) {
				out.identity();
			} else {
				out = new Matrix3D();
			}
			if(targetSpace == this) {
				return out;
			}
			if(targetSpace == _parent || targetSpace == null && _parent == null) {
				out.copyFrom(transformationMatrix3D);
				return out;
			}
			if(targetSpace == null || targetSpace == base) {
				_local4 = this;
				while(_local4 != targetSpace) {
					out.append(_local4.transformationMatrix3D);
					_local4 = _local4._parent;
				}
				return out;
			}
			if(targetSpace._parent == this) {
				targetSpace.getTransformationMatrix3D(this,out);
				out.invert();
				return out;
			}
			_local3 = findCommonParent(this,targetSpace);
			_local4 = this;
			while(_local4 != _local3) {
				out.append(_local4.transformationMatrix3D);
				_local4 = _local4._parent;
			}
			if(_local3 == targetSpace) {
				return out;
			}
			sHelperMatrix3D.identity();
			_local4 = targetSpace;
			while(_local4 != _local3) {
				sHelperMatrix3D.append(_local4.transformationMatrix3D);
				_local4 = _local4._parent;
			}
			sHelperMatrix3D.invert();
			out.append(sHelperMatrix3D);
			return out;
		}
		
		public function local3DToGlobal(localPoint:Vector3D, out:Point = null) : Point {
			var _local3:Stage = this.stage;
			if(_local3 == null) {
				throw new IllegalOperationError("Object not connected to stage");
			}
			getTransformationMatrix3D(_local3,sHelperMatrixAlt3D);
			MatrixUtil.transformPoint3D(sHelperMatrixAlt3D,localPoint,sHelperPoint3D);
			return MathUtil.intersectLineWithXYPlane(_local3.cameraPosition,sHelperPoint3D,out);
		}
		
		public function globalToLocal3D(globalPoint:Point, out:Vector3D = null) : Vector3D {
			var _local3:Stage = this.stage;
			if(_local3 == null) {
				throw new IllegalOperationError("Object not connected to stage");
			}
			getTransformationMatrix3D(_local3,sHelperMatrixAlt3D);
			sHelperMatrixAlt3D.invert();
			return MatrixUtil.transformCoords3D(sHelperMatrixAlt3D,globalPoint.x,globalPoint.y,0,out);
		}
		
		starling_internal function setParent(value:DisplayObjectContainer) : void {
			var _local2:DisplayObject = value;
			while(_local2 != this && _local2 != null) {
				_local2 = _local2._parent;
			}
			if(_local2 == this) {
				throw new ArgumentError("An object cannot be added as a child to itself or one of its children (or children\'s children, etc.)");
			}
			_parent = value;
		}
		
		internal function setIs3D(value:Boolean) : void {
			_is3D = value;
		}
		
		internal function get isMask() : Boolean {
			return _maskee != null;
		}
		
		public function setRequiresRedraw() : void {
			var _local1:DisplayObject = _parent || _maskee;
			var _local2:int = int(Starling.frameID);
			_lastParentOrSelfChangeFrameID = _local2;
			_hasVisibleArea = _alpha != 0 && _visible && _maskee == null && _scaleX != 0 && _scaleY != 0;
			while(_local1 && _local1._lastChildChangeFrameID != _local2) {
				_local1._lastChildChangeFrameID = _local2;
				_local1 = _local1._parent || _local1._maskee;
			}
		}
		
		public function get requiresRedraw() : Boolean {
			var _local1:uint = Starling.frameID;
			return _lastParentOrSelfChangeFrameID == _local1 || _lastChildChangeFrameID == _local1;
		}
		
		starling_internal function excludeFromCache() : void {
			var _local2:* = this;
			var _local1:Number = 4294967295;
			while(_local2 && _local2._tokenFrameID != _local1) {
				_local2._tokenFrameID = _local1;
				_local2 = _local2._parent;
			}
		}
		
		private function setOrientationChanged() : void {
			_orientationChanged = true;
			setRequiresRedraw();
		}
		
		override public function dispatchEvent(event:Event) : void {
			if(event.type == "removedFromStage" && stage == null) {
				return;
			}
			super.dispatchEvent(event);
		}
		
		override public function addEventListener(type:String, listener:Function) : void {
			if(type == "enterFrame" && !hasEventListener(type)) {
				addEventListener("addedToStage",addEnterFrameListenerToStage);
				addEventListener("removedFromStage",removeEnterFrameListenerFromStage);
				if(this.stage) {
					addEnterFrameListenerToStage();
				}
			}
			super.addEventListener(type,listener);
		}
		
		override public function removeEventListener(type:String, listener:Function) : void {
			super.removeEventListener(type,listener);
			if(type == "enterFrame" && !hasEventListener(type)) {
				removeEventListener("addedToStage",addEnterFrameListenerToStage);
				removeEventListener("removedFromStage",removeEnterFrameListenerFromStage);
				removeEnterFrameListenerFromStage();
			}
		}
		
		override public function removeEventListeners(type:String = null) : void {
			if((type == null || type == "enterFrame") && hasEventListener("enterFrame")) {
				removeEventListener("addedToStage",addEnterFrameListenerToStage);
				removeEventListener("removedFromStage",removeEnterFrameListenerFromStage);
				removeEnterFrameListenerFromStage();
			}
			super.removeEventListeners(type);
		}
		
		private function addEnterFrameListenerToStage() : void {
			Starling.current.stage.addEnterFrameListener(this);
		}
		
		private function removeEnterFrameListenerFromStage() : void {
			Starling.current.stage.removeEnterFrameListener(this);
		}
		
		public function get transformationMatrix() : Matrix {
			var _local7:Number = NaN;
			var _local8:Number = NaN;
			var _local1:Number = NaN;
			var _local2:Number = NaN;
			var _local3:Number = NaN;
			var _local4:Number = NaN;
			var _local5:Number = NaN;
			var _local6:Number = NaN;
			if(_orientationChanged) {
				_orientationChanged = false;
				if(_skewX == 0 && _skewY == 0) {
					if(_rotation == 0) {
						_transformationMatrix.setTo(_scaleX,0,0,_scaleY,_x - _pivotX * _scaleX,_y - _pivotY * _scaleY);
					} else {
						_local7 = Math.cos(_rotation);
						_local8 = Math.sin(_rotation);
						_local1 = _scaleX * _local7;
						_local2 = _scaleX * _local8;
						_local3 = _scaleY * -_local8;
						_local4 = _scaleY * _local7;
						_local5 = _x - _pivotX * _local1 - _pivotY * _local3;
						_local6 = _y - _pivotX * _local2 - _pivotY * _local4;
						_transformationMatrix.setTo(_local1,_local2,_local3,_local4,_local5,_local6);
					}
				} else {
					_transformationMatrix.identity();
					_transformationMatrix.scale(_scaleX,_scaleY);
					MatrixUtil.skew(_transformationMatrix,_skewX,_skewY);
					_transformationMatrix.rotate(_rotation);
					_transformationMatrix.translate(_x,_y);
					if(_pivotX != 0 || _pivotY != 0) {
						_transformationMatrix.tx = _x - _transformationMatrix.a * _pivotX - _transformationMatrix.c * _pivotY;
						_transformationMatrix.ty = _y - _transformationMatrix.b * _pivotX - _transformationMatrix.d * _pivotY;
					}
				}
			}
			return _transformationMatrix;
		}
		
		public function set transformationMatrix(matrix:Matrix) : void {
			var _local2:Number = NaN;
			_local2 = 0.7853981633974483;
			setRequiresRedraw();
			_orientationChanged = false;
			_transformationMatrix.copyFrom(matrix);
			_pivotX = _pivotY = 0;
			_x = matrix.tx;
			_y = matrix.ty;
			_skewX = Math.atan(-matrix.c / matrix.d);
			_skewY = Math.atan(matrix.b / matrix.a);
			if(_skewX != _skewX) {
				_skewX = 0;
			}
			if(_skewY != _skewY) {
				_skewY = 0;
			}
			_scaleY = _skewX > -0.7853981633974483 && _skewX < 0.7853981633974483 ? matrix.d / Math.cos(_skewX) : -matrix.c / Math.sin(_skewX);
			_scaleX = _skewY > -0.7853981633974483 && _skewY < 0.7853981633974483 ? matrix.a / Math.cos(_skewY) : matrix.b / Math.sin(_skewY);
			if(MathUtil.isEquivalent(_skewX,_skewY)) {
				_rotation = _skewX;
				_skewX = _skewY = 0;
			} else {
				_rotation = 0;
			}
		}
		
		public function get transformationMatrix3D() : Matrix3D {
			if(_transformationMatrix3D == null) {
				_transformationMatrix3D = new Matrix3D();
			}
			return MatrixUtil.convertTo3D(transformationMatrix,_transformationMatrix3D);
		}
		
		public function get is3D() : Boolean {
			return _is3D;
		}
		
		public function get useHandCursor() : Boolean {
			return _useHandCursor;
		}
		
		public function set useHandCursor(value:Boolean) : void {
			if(value == _useHandCursor) {
				return;
			}
			_useHandCursor = value;
			if(_useHandCursor) {
				addEventListener("touch",onTouch);
			} else {
				removeEventListener("touch",onTouch);
			}
		}
		
		private function onTouch(event:TouchEvent) : void {
			Mouse.cursor = event.interactsWith(this) ? "button" : "auto";
		}
		
		public function get bounds() : Rectangle {
			return getBounds(_parent);
		}
		
		public function get width() : Number {
			return getBounds(_parent,sHelperRect).width;
		}
		
		public function set width(value:Number) : void {
			var _local2:Number = NaN;
			var _local3:* = _scaleX != _scaleX;
			if(_scaleX == 0 || _local3) {
				scaleX = 1;
				_local2 = width;
			} else {
				_local2 = Math.abs(width / _scaleX);
			}
			if(_local2) {
				scaleX = value / _local2;
			}
		}
		
		public function get height() : Number {
			return getBounds(_parent,sHelperRect).height;
		}
		
		public function set height(value:Number) : void {
			var _local2:Number = NaN;
			var _local3:* = _scaleY != _scaleY;
			if(_scaleY == 0 || _local3) {
				scaleY = 1;
				_local2 = height;
			} else {
				_local2 = Math.abs(height / _scaleY);
			}
			if(_local2) {
				scaleY = value / _local2;
			}
		}
		
		public function get x() : Number {
			return _x;
		}
		
		public function set x(value:Number) : void {
			if(_x != value) {
				_x = value;
				setOrientationChanged();
			}
		}
		
		public function get y() : Number {
			return _y;
		}
		
		public function set y(value:Number) : void {
			if(_y != value) {
				_y = value;
				setOrientationChanged();
			}
		}
		
		public function get pivotX() : Number {
			return _pivotX;
		}
		
		public function set pivotX(value:Number) : void {
			if(_pivotX != value) {
				_pivotX = value;
				setOrientationChanged();
			}
		}
		
		public function get pivotY() : Number {
			return _pivotY;
		}
		
		public function set pivotY(value:Number) : void {
			if(_pivotY != value) {
				_pivotY = value;
				setOrientationChanged();
			}
		}
		
		public function get scaleX() : Number {
			return _scaleX;
		}
		
		public function set scaleX(value:Number) : void {
			if(_scaleX != value) {
				_scaleX = value;
				setOrientationChanged();
			}
		}
		
		public function get scaleY() : Number {
			return _scaleY;
		}
		
		public function set scaleY(value:Number) : void {
			if(_scaleY != value) {
				_scaleY = value;
				setOrientationChanged();
			}
		}
		
		public function get scale() : Number {
			return scaleX;
		}
		
		public function set scale(value:Number) : void {
			scaleX = scaleY = value;
		}
		
		public function get skewX() : Number {
			return _skewX;
		}
		
		public function set skewX(value:Number) : void {
			value = MathUtil.normalizeAngle(value);
			if(_skewX != value) {
				_skewX = value;
				setOrientationChanged();
			}
		}
		
		public function get skewY() : Number {
			return _skewY;
		}
		
		public function set skewY(value:Number) : void {
			value = MathUtil.normalizeAngle(value);
			if(_skewY != value) {
				_skewY = value;
				setOrientationChanged();
			}
		}
		
		public function get rotation() : Number {
			return _rotation;
		}
		
		public function set rotation(value:Number) : void {
			value = MathUtil.normalizeAngle(value);
			if(_rotation != value) {
				_rotation = value;
				setOrientationChanged();
			}
		}
		
		internal function get isRotated() : Boolean {
			return _rotation != 0 || _skewX != 0 || _skewY != 0;
		}
		
		public function get alpha() : Number {
			return _alpha;
		}
		
		public function set alpha(value:Number) : void {
			if(value != _alpha) {
				_alpha = value < 0 ? 0 : (value > 1 ? 1 : value);
				setRequiresRedraw();
			}
		}
		
		public function get visible() : Boolean {
			return _visible;
		}
		
		public function set visible(value:Boolean) : void {
			if(value != _visible) {
				_visible = value;
				setRequiresRedraw();
			}
		}
		
		public function get touchable() : Boolean {
			return _touchable;
		}
		
		public function set touchable(value:Boolean) : void {
			_touchable = value;
		}
		
		public function get blendMode() : String {
			return _blendMode;
		}
		
		public function set blendMode(value:String) : void {
			if(value != _blendMode) {
				_blendMode = value;
				setRequiresRedraw();
			}
		}
		
		public function get name() : String {
			return _name;
		}
		
		public function set name(value:String) : void {
			_name = value;
		}
		
		public function get filter() : FragmentFilter {
			return _filter;
		}
		
		public function set filter(value:FragmentFilter) : void {
			if(value != _filter) {
				if(_filter) {
					_filter.starling_internal::setTarget(null);
				}
				if(value) {
					value.starling_internal::setTarget(this);
				}
				_filter = value;
				setRequiresRedraw();
			}
		}
		
		public function get mask() : DisplayObject {
			return _mask;
		}
		
		public function set mask(value:DisplayObject) : void {
			if(_mask != value) {
				if(!sMaskWarningShown) {
					if(!SystemUtil.supportsDepthAndStencil) {
						trace("[Starling] Full mask support requires \'depthAndStencil\' to be enabled in the application descriptor.");
					}
					sMaskWarningShown = true;
				}
				if(_mask) {
					_mask._maskee = null;
				}
				if(value) {
					value._maskee = this;
					value._hasVisibleArea = false;
				}
				_mask = value;
				setRequiresRedraw();
			}
		}
		
		public function get parent() : DisplayObjectContainer {
			return _parent;
		}
		
		public function get base() : DisplayObject {
			var _local1:* = this;
			while(_local1._parent) {
				_local1 = _local1._parent;
			}
			return _local1;
		}
		
		public function get root() : DisplayObject {
			var _local1:* = this;
			while(_local1._parent) {
				if(_local1._parent is Stage) {
					return _local1;
				}
				_local1 = _local1.parent;
			}
			return null;
		}
		
		public function get stage() : Stage {
			return this.base as Stage;
		}
	}
}

