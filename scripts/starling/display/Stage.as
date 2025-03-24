package starling.display {
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.errors.IllegalOperationError;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import starling.core.Starling;
	import starling.core.starling_internal;
	import starling.events.EnterFrameEvent;
	import starling.filters.FragmentFilter;
	import starling.rendering.Painter;
	import starling.rendering.RenderState;
	import starling.utils.MatrixUtil;
	import starling.utils.RectangleUtil;
	
	use namespace starling_internal;
	
	public class Stage extends DisplayObjectContainer {
		private static var sMatrix:Matrix = new Matrix();
		
		private static var sMatrix3D:Matrix3D = new Matrix3D();
		
		private var _width:int;
		
		private var _height:int;
		
		private var _color:uint;
		
		private var _fieldOfView:Number;
		
		private var _projectionOffset:Point;
		
		private var _cameraPosition:Vector3D;
		
		private var _enterFrameEvent:EnterFrameEvent;
		
		private var _enterFrameListeners:Vector.<DisplayObject>;
		
		public function Stage(width:int, height:int, color:uint = 0) {
			super();
			_width = width;
			_height = height;
			_color = color;
			_fieldOfView = 1;
			_projectionOffset = new Point();
			_cameraPosition = new Vector3D();
			_enterFrameEvent = new EnterFrameEvent("enterFrame",0);
			_enterFrameListeners = new Vector.<DisplayObject>(0);
		}
		
		public function advanceTime(passedTime:Number) : void {
			_enterFrameEvent.starling_internal::reset("enterFrame",false,passedTime);
			broadcastEvent(_enterFrameEvent);
		}
		
		override public function hitTest(localPoint:Point) : DisplayObject {
			if(!visible || !touchable) {
				return null;
			}
			if(localPoint.x < 0 || localPoint.x > _width || localPoint.y < 0 || localPoint.y > _height) {
				return null;
			}
			var _local2:DisplayObject = super.hitTest(localPoint);
			return !!_local2 ? _local2 : this;
		}
		
		public function drawToBitmapData(destination:BitmapData = null, transparent:Boolean = true) : BitmapData {
			var _local5:int = 0;
			var _local7:int = 0;
			var _local3:Painter = Starling.painter;
			var _local6:RenderState = _local3.state;
			var _local4:Context3D = _local3.context;
			if(destination == null) {
				_local5 = _local4.backBufferWidth;
				_local7 = _local4.backBufferHeight;
				destination = new BitmapData(_local5,_local7,transparent);
			}
			_local3.pushState();
			_local6.renderTarget = null;
			_local6.setProjectionMatrix(0,0,_width,_height,_width,_height,cameraPosition);
			if(transparent) {
				_local3.clear();
			} else {
				_local3.clear(_color,1);
			}
			render(_local3);
			_local3.finishMeshBatch();
			_local4.drawToBitmapData(destination);
			_local4.present();
			_local3.popState();
			return destination;
		}
		
		public function getStageBounds(targetSpace:DisplayObject, out:Rectangle = null) : Rectangle {
			if(out == null) {
				out = new Rectangle();
			}
			out.setTo(0,0,_width,_height);
			getTransformationMatrix(targetSpace,sMatrix);
			return RectangleUtil.getBounds(out,sMatrix,out);
		}
		
		public function getCameraPosition(space:DisplayObject = null, out:Vector3D = null) : Vector3D {
			getTransformationMatrix3D(space,sMatrix3D);
			return MatrixUtil.transformCoords3D(sMatrix3D,_width / 2 + _projectionOffset.x,_height / 2 + _projectionOffset.y,-focalLength,out);
		}
		
		internal function addEnterFrameListener(listener:DisplayObject) : void {
			var _local2:int = int(_enterFrameListeners.indexOf(listener));
			if(_local2 < 0) {
				_enterFrameListeners[_enterFrameListeners.length] = listener;
			}
		}
		
		internal function removeEnterFrameListener(listener:DisplayObject) : void {
			var _local2:int = int(_enterFrameListeners.indexOf(listener));
			if(_local2 >= 0) {
				_enterFrameListeners.removeAt(_local2);
			}
		}
		
		override internal function getChildEventListeners(object:DisplayObject, eventType:String, listeners:Vector.<DisplayObject>) : void {
			var _local5:int = 0;
			var _local4:int = 0;
			if(eventType == "enterFrame" && object == this) {
				_local5 = 0;
				_local4 = int(_enterFrameListeners.length);
				while(_local5 < _local4) {
					listeners[listeners.length] = _enterFrameListeners[_local5];
					_local5++;
				}
			} else {
				super.getChildEventListeners(object,eventType,listeners);
			}
		}
		
		override public function set width(value:Number) : void {
			throw new IllegalOperationError("Cannot set width of stage");
		}
		
		override public function set height(value:Number) : void {
			throw new IllegalOperationError("Cannot set height of stage");
		}
		
		override public function set x(value:Number) : void {
			throw new IllegalOperationError("Cannot set x-coordinate of stage");
		}
		
		override public function set y(value:Number) : void {
			throw new IllegalOperationError("Cannot set y-coordinate of stage");
		}
		
		override public function set scaleX(value:Number) : void {
			throw new IllegalOperationError("Cannot scale stage");
		}
		
		override public function set scaleY(value:Number) : void {
			throw new IllegalOperationError("Cannot scale stage");
		}
		
		override public function set rotation(value:Number) : void {
			throw new IllegalOperationError("Cannot rotate stage");
		}
		
		override public function set skewX(value:Number) : void {
			throw new IllegalOperationError("Cannot skew stage");
		}
		
		override public function set skewY(value:Number) : void {
			throw new IllegalOperationError("Cannot skew stage");
		}
		
		override public function set filter(value:FragmentFilter) : void {
			throw new IllegalOperationError("Cannot add filter to stage. Add it to \'root\' instead!");
		}
		
		public function get color() : uint {
			return _color;
		}
		
		public function set color(value:uint) : void {
			_color = value;
		}
		
		public function get stageWidth() : int {
			return _width;
		}
		
		public function set stageWidth(value:int) : void {
			_width = value;
		}
		
		public function get stageHeight() : int {
			return _height;
		}
		
		public function set stageHeight(value:int) : void {
			_height = value;
		}
		
		public function get starling() : Starling {
			var _local3:int = 0;
			var _local1:Vector.<Starling> = Starling.all;
			var _local2:int = int(_local1.length);
			_local3 = 0;
			while(_local3 < _local2) {
				if(_local1[_local3].stage == this) {
					return _local1[_local3];
				}
				_local3++;
			}
			return null;
		}
		
		public function get focalLength() : Number {
			return _width / (2 * Math.tan(_fieldOfView / 2));
		}
		
		public function set focalLength(value:Number) : void {
			_fieldOfView = 2 * Math.atan(stageWidth / (2 * value));
		}
		
		public function get fieldOfView() : Number {
			return _fieldOfView;
		}
		
		public function set fieldOfView(value:Number) : void {
			_fieldOfView = value;
		}
		
		public function get projectionOffset() : Point {
			return _projectionOffset;
		}
		
		public function set projectionOffset(value:Point) : void {
			_projectionOffset.setTo(value.x,value.y);
		}
		
		public function get cameraPosition() : Vector3D {
			return getCameraPosition(null,_cameraPosition);
		}
	}
}

