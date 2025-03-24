package starling.events {
	import flash.geom.Point;
	import starling.display.DisplayObject;
	import starling.utils.StringUtil;
	
	public class Touch {
		private static var sHelperPoint:Point = new Point();
		
		private var _id:int;
		
		private var _globalX:Number;
		
		private var _globalY:Number;
		
		private var _previousGlobalX:Number;
		
		private var _previousGlobalY:Number;
		
		private var _tapCount:int;
		
		private var _phase:String;
		
		private var _target:DisplayObject;
		
		private var _timestamp:Number;
		
		private var _pressure:Number;
		
		private var _width:Number;
		
		private var _height:Number;
		
		private var _cancelled:Boolean;
		
		private var _bubbleChain:Vector.<EventDispatcher>;
		
		public function Touch(id:int) {
			super();
			_id = id;
			_tapCount = 0;
			_phase = "hover";
			_pressure = _width = _height = 1;
			_bubbleChain = new Vector.<EventDispatcher>(0);
		}
		
		public function getLocation(space:DisplayObject, out:Point = null) : Point {
			sHelperPoint.setTo(_globalX,_globalY);
			return space.globalToLocal(sHelperPoint,out);
		}
		
		public function getPreviousLocation(space:DisplayObject, out:Point = null) : Point {
			sHelperPoint.setTo(_previousGlobalX,_previousGlobalY);
			return space.globalToLocal(sHelperPoint,out);
		}
		
		public function getMovement(space:DisplayObject, out:Point = null) : Point {
			if(out == null) {
				out = new Point();
			}
			getLocation(space,out);
			var _local3:Number = out.x;
			var _local4:Number = out.y;
			getPreviousLocation(space,out);
			out.setTo(_local3 - out.x,_local4 - out.y);
			return out;
		}
		
		public function isTouching(target:DisplayObject) : Boolean {
			return _bubbleChain.indexOf(target) != -1;
		}
		
		public function toString() : String {
			return StringUtil.format("[Touch {0}: globalX={1}, globalY={2}, phase={3}]",_id,_globalX,_globalY,_phase);
		}
		
		public function clone() : Touch {
			var _local1:Touch = new Touch(_id);
			_local1._globalX = _globalX;
			_local1._globalY = _globalY;
			_local1._previousGlobalX = _previousGlobalX;
			_local1._previousGlobalY = _previousGlobalY;
			_local1._phase = _phase;
			_local1._tapCount = _tapCount;
			_local1._timestamp = _timestamp;
			_local1._pressure = _pressure;
			_local1._width = _width;
			_local1._height = _height;
			_local1._cancelled = _cancelled;
			_local1.target = _target;
			return _local1;
		}
		
		private function updateBubbleChain() : void {
			var _local1:int = 0;
			var _local2:DisplayObject = null;
			if(_target) {
				_local1 = 1;
				_local2 = _target;
				_bubbleChain.length = 1;
				_bubbleChain[0] = _local2;
				while(true) {
					_local2 = _local2.parent;
					if(_local2 == null) {
						break;
					}
					_bubbleChain[_local1++] = _local2;
				}
			} else {
				_bubbleChain.length = 0;
			}
		}
		
		public function get id() : int {
			return _id;
		}
		
		public function get previousGlobalX() : Number {
			return _previousGlobalX;
		}
		
		public function get previousGlobalY() : Number {
			return _previousGlobalY;
		}
		
		public function get globalX() : Number {
			return _globalX;
		}
		
		public function set globalX(value:Number) : void {
			_previousGlobalX = _globalX != _globalX ? value : _globalX;
			_globalX = value;
		}
		
		public function get globalY() : Number {
			return _globalY;
		}
		
		public function set globalY(value:Number) : void {
			_previousGlobalY = _globalY != _globalY ? value : _globalY;
			_globalY = value;
		}
		
		public function get tapCount() : int {
			return _tapCount;
		}
		
		public function set tapCount(value:int) : void {
			_tapCount = value;
		}
		
		public function get phase() : String {
			return _phase;
		}
		
		public function set phase(value:String) : void {
			_phase = value;
		}
		
		public function get target() : DisplayObject {
			return _target;
		}
		
		public function set target(value:DisplayObject) : void {
			if(_target != value) {
				_target = value;
				updateBubbleChain();
			}
		}
		
		public function get timestamp() : Number {
			return _timestamp;
		}
		
		public function set timestamp(value:Number) : void {
			_timestamp = value;
		}
		
		public function get pressure() : Number {
			return _pressure;
		}
		
		public function set pressure(value:Number) : void {
			_pressure = value;
		}
		
		public function get width() : Number {
			return _width;
		}
		
		public function set width(value:Number) : void {
			_width = value;
		}
		
		public function get height() : Number {
			return _height;
		}
		
		public function set height(value:Number) : void {
			_height = value;
		}
		
		public function get cancelled() : Boolean {
			return _cancelled;
		}
		
		public function set cancelled(value:Boolean) : void {
			_cancelled = value;
		}
		
		internal function dispatchEvent(event:TouchEvent) : void {
			if(_target) {
				event.dispatch(_bubbleChain);
			}
		}
		
		internal function get bubbleChain() : Vector.<EventDispatcher> {
			return _bubbleChain.concat();
		}
	}
}

