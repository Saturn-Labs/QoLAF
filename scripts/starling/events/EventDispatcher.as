package starling.events {
	import flash.utils.Dictionary;
	import starling.core.starling_internal;
	import starling.display.DisplayObject;
	
	use namespace starling_internal;
	
	public class EventDispatcher {
		private static var sBubbleChains:Array = [];
		
		private var _eventListeners:Dictionary;
		
		public function EventDispatcher() {
			super();
		}
		
		public function addEventListener(type:String, listener:Function) : void {
			if(_eventListeners == null) {
				_eventListeners = new Dictionary();
			}
			var _local3:Vector.<Function> = _eventListeners[type] as Vector.<Function>;
			if(_local3 == null) {
				_eventListeners[type] = new <Function>[listener];
			} else if(_local3.indexOf(listener) == -1) {
				_local3[_local3.length] = listener;
			}
		}
		
		public function removeEventListener(type:String, listener:Function) : void {
			var _local3:* = undefined;
			var _local4:int = 0;
			var _local5:int = 0;
			var _local7:* = undefined;
			var _local6:int = 0;
			if(_eventListeners) {
				_local3 = _eventListeners[type] as Vector.<Function>;
				_local4 = int(!!_local3 ? _local3.length : 0);
				if(_local4 > 0) {
					_local5 = int(_local3.indexOf(listener));
					if(_local5 != -1) {
						_local7 = _local3.slice(0,_local5);
						_local6 = _local5 + 1;
						while(_local6 < _local4) {
							_local7[_local6 - 1] = _local3[_local6];
							_local6++;
						}
						_eventListeners[type] = _local7;
					}
				}
			}
		}
		
		public function removeEventListeners(type:String = null) : void {
			if(type && _eventListeners) {
				delete _eventListeners[type];
			} else {
				_eventListeners = null;
			}
		}
		
		public function dispatchEvent(event:Event) : void {
			var _local2:Boolean = event.bubbles;
			if(!_local2 && (_eventListeners == null || !(event.type in _eventListeners))) {
				return;
			}
			var _local3:EventDispatcher = event.target;
			event.setTarget(this);
			if(_local2 && this is DisplayObject) {
				bubbleEvent(event);
			} else {
				invokeEvent(event);
			}
			if(_local3) {
				event.setTarget(_local3);
			}
		}
		
		internal function invokeEvent(event:Event) : Boolean {
			var _local6:int = 0;
			var _local5:Function = null;
			var _local2:int = 0;
			var _local3:Vector.<Function> = !!_eventListeners ? _eventListeners[event.type] as Vector.<Function> : null;
			var _local4:int = int(_local3 == null ? 0 : _local3.length);
			if(_local4) {
				event.setCurrentTarget(this);
				_local6 = 0;
				while(_local6 < _local4) {
					_local5 = _local3[_local6] as Function;
					_local2 = _local5.length;
					if(_local2 == 0) {
						_local5();
					} else if(_local2 == 1) {
						_local5(event);
					} else {
						_local5(event,event.data);
					}
					if(event.stopsImmediatePropagation) {
						return true;
					}
					_local6++;
				}
				return event.stopsPropagation;
			}
			return false;
		}
		
		internal function bubbleEvent(event:Event) : void {
			var _local2:* = undefined;
			var _local4:int = 0;
			var _local5:Boolean = false;
			var _local6:DisplayObject = this as DisplayObject;
			var _local3:int = 1;
			if(sBubbleChains.length > 0) {
				_local2 = sBubbleChains.pop();
				_local2[0] = _local6;
			} else {
				_local2 = new <EventDispatcher>[_local6];
			}
			while(true) {
				_local6 = _local6.parent;
				if(_local6 == null) {
					break;
				}
				_local2[_local3++] = _local6;
			}
			_local4 = 0;
			while(_local4 < _local3) {
				_local5 = _local2[_local4].invokeEvent(event);
				if(_local5) {
					break;
				}
				_local4++;
			}
			_local2.length = 0;
			sBubbleChains[sBubbleChains.length] = _local2;
		}
		
		public function dispatchEventWith(type:String, bubbles:Boolean = false, data:Object = null) : void {
			var _local4:Event = null;
			if(bubbles || hasEventListener(type)) {
				_local4 = Event.starling_internal::fromPool(type,bubbles,data);
				dispatchEvent(_local4);
				Event.starling_internal::toPool(_local4);
			}
		}
		
		public function hasEventListener(type:String, listener:Function = null) : Boolean {
			var _local3:Vector.<Function> = !!_eventListeners ? _eventListeners[type] : null;
			if(_local3 == null) {
				return false;
			}
			if(listener != null) {
				return _local3.indexOf(listener) != -1;
			}
			return _local3.length != 0;
		}
	}
}

