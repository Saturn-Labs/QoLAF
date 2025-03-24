package starling.events {
	import starling.core.starling_internal;
	import starling.display.DisplayObject;
	
	use namespace starling_internal;
	
	public class TouchEvent extends Event {
		public static const TOUCH:String = "touch";
		
		private static var sTouches:Vector.<Touch> = new Vector.<Touch>(0);
		
		private var _shiftKey:Boolean;
		
		private var _ctrlKey:Boolean;
		
		private var _timestamp:Number;
		
		private var _visitedObjects:Vector.<EventDispatcher>;
		
		public function TouchEvent(type:String, touches:Vector.<Touch> = null, shiftKey:Boolean = false, ctrlKey:Boolean = false, bubbles:Boolean = true) {
			super(type,bubbles,touches);
			_shiftKey = shiftKey;
			_ctrlKey = ctrlKey;
			_visitedObjects = new Vector.<EventDispatcher>(0);
			updateTimestamp(touches);
		}
		
		internal function resetTo(type:String, touches:Vector.<Touch> = null, shiftKey:Boolean = false, ctrlKey:Boolean = false, bubbles:Boolean = true) : TouchEvent {
			super.starling_internal::reset(type,bubbles,touches);
			_shiftKey = shiftKey;
			_ctrlKey = ctrlKey;
			_visitedObjects.length = 0;
			updateTimestamp(touches);
			return this;
		}
		
		private function updateTimestamp(touches:Vector.<Touch>) : void {
			var _local2:int = 0;
			_timestamp = -1;
			var _local3:int = int(!!touches ? touches.length : 0);
			_local2 = 0;
			while(_local2 < _local3) {
				if(touches[_local2].timestamp > _timestamp) {
					_timestamp = touches[_local2].timestamp;
				}
				_local2++;
			}
		}
		
		public function getTouches(target:DisplayObject, phase:String = null, out:Vector.<Touch> = null) : Vector.<Touch> {
			var _local6:int = 0;
			var _local7:Touch = null;
			var _local4:Boolean = false;
			var _local5:Boolean = false;
			if(out == null) {
				out = new Vector.<Touch>(0);
			}
			var _local8:Vector.<Touch> = data as Vector.<Touch>;
			var _local9:int = int(_local8.length);
			_local6 = 0;
			while(_local6 < _local9) {
				_local7 = _local8[_local6];
				_local4 = _local7.isTouching(target);
				_local5 = phase == null || phase == _local7.phase;
				if(_local4 && _local5) {
					out[out.length] = _local7;
				}
				_local6++;
			}
			return out;
		}
		
		public function getTouch(target:DisplayObject, phase:String = null, id:int = -1) : Touch {
			var _local4:Touch = null;
			var _local5:int = 0;
			getTouches(target,phase,sTouches);
			var _local6:int = int(sTouches.length);
			if(_local6 > 0) {
				_local4 = null;
				if(id < 0) {
					_local4 = sTouches[0];
				} else {
					_local5 = 0;
					while(_local5 < _local6) {
						if(sTouches[_local5].id == id) {
							_local4 = sTouches[_local5];
							break;
						}
						_local5++;
					}
				}
				sTouches.length = 0;
				return _local4;
			}
			return null;
		}
		
		public function interactsWith(target:DisplayObject) : Boolean {
			var _local3:int = 0;
			var _local2:Boolean = false;
			getTouches(target,null,sTouches);
			_local3 = sTouches.length - 1;
			while(_local3 >= 0) {
				if(sTouches[_local3].phase != "ended") {
					_local2 = true;
					break;
				}
				_local3--;
			}
			sTouches.length = 0;
			return _local2;
		}
		
		internal function dispatch(chain:Vector.<EventDispatcher>) : void {
			var _local2:int = 0;
			var _local6:EventDispatcher = null;
			var _local4:int = 0;
			var _local3:EventDispatcher = null;
			var _local5:Boolean = false;
			if(chain && chain.length) {
				_local2 = int(bubbles ? chain.length : 1);
				_local6 = target;
				setTarget(chain[0] as EventDispatcher);
				_local4 = 0;
				while(_local4 < _local2) {
					_local3 = chain[_local4] as EventDispatcher;
					if(_visitedObjects.indexOf(_local3) == -1) {
						_local5 = _local3.invokeEvent(this);
						_visitedObjects[_visitedObjects.length] = _local3;
						if(_local5) {
							break;
						}
					}
					_local4++;
				}
				setTarget(_local6);
			}
		}
		
		public function get timestamp() : Number {
			return _timestamp;
		}
		
		public function get touches() : Vector.<Touch> {
			return (data as Vector.<Touch>).concat();
		}
		
		public function get shiftKey() : Boolean {
			return _shiftKey;
		}
		
		public function get ctrlKey() : Boolean {
			return _ctrlKey;
		}
	}
}

