package starling.animation {
	import flash.utils.Dictionary;
	import starling.core.starling_internal;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	use namespace starling_internal;
	
	public class Juggler implements IAnimatable {
		private static var sCurrentObjectID:uint;
		
		private var _objects:Vector.<IAnimatable>;
		
		private var _objectIDs:Dictionary;
		
		private var _elapsedTime:Number;
		
		private var _timeScale:Number;
		
		public function Juggler() {
			super();
			_elapsedTime = 0;
			_timeScale = 1;
			_objects = new Vector.<IAnimatable>(0);
			_objectIDs = new Dictionary(true);
		}
		
		private static function getNextID() : uint {
			return ++sCurrentObjectID;
		}
		
		public function add(object:IAnimatable) : uint {
			return addWithID(object,getNextID());
		}
		
		private function addWithID(object:IAnimatable, objectID:uint) : uint {
			var _local3:EventDispatcher = null;
			if(object && !(object in _objectIDs)) {
				_local3 = object as EventDispatcher;
				if(_local3) {
					_local3.addEventListener("removeFromJuggler",onRemove);
				}
				_objects[_objects.length] = object;
				_objectIDs[object] = objectID;
				return objectID;
			}
			return 0;
		}
		
		public function contains(object:IAnimatable) : Boolean {
			return object in _objectIDs;
		}
		
		public function remove(object:IAnimatable) : uint {
			var _local3:EventDispatcher = null;
			var _local2:int = 0;
			var _local4:uint = 0;
			if(object && object in _objectIDs) {
				_local3 = object as EventDispatcher;
				if(_local3) {
					_local3.removeEventListener("removeFromJuggler",onRemove);
				}
				_local2 = int(_objects.indexOf(object));
				_objects[_local2] = null;
				_local4 = uint(_objectIDs[object]);
				delete _objectIDs[object];
			}
			return _local4;
		}
		
		public function removeByID(objectID:uint) : uint {
			var _local2:int = 0;
			var _local3:IAnimatable = null;
			_local2 = _objects.length - 1;
			while(_local2 >= 0) {
				_local3 = _objects[_local2];
				if(_objectIDs[_local3] == objectID) {
					remove(_local3);
					return objectID;
				}
				_local2--;
			}
			return 0;
		}
		
		public function removeTweens(target:Object) : void {
			var _local3:int = 0;
			var _local2:Tween = null;
			if(target == null) {
				return;
			}
			_local3 = _objects.length - 1;
			while(_local3 >= 0) {
				_local2 = _objects[_local3] as Tween;
				if(_local2 && _local2.target == target) {
					_local2.removeEventListener("removeFromJuggler",onRemove);
					_objects[_local3] = null;
					delete _objectIDs[_local2];
				}
				_local3--;
			}
		}
		
		public function removeDelayedCalls(callback:Function) : void {
			var _local2:int = 0;
			var _local3:DelayedCall = null;
			if(callback == null) {
				return;
			}
			_local2 = _objects.length - 1;
			while(_local2 >= 0) {
				_local3 = _objects[_local2] as DelayedCall;
				if(_local3 && _local3.callback == callback) {
					_local3.removeEventListener("removeFromJuggler",onRemove);
					_objects[_local2] = null;
					delete _objectIDs[tween];
				}
				_local2--;
			}
		}
		
		public function containsTweens(target:Object) : Boolean {
			var _local3:int = 0;
			var _local2:Tween = null;
			if(target) {
				_local3 = _objects.length - 1;
				while(_local3 >= 0) {
					_local2 = _objects[_local3] as Tween;
					if(_local2 && _local2.target == target) {
						return true;
					}
					_local3--;
				}
			}
			return false;
		}
		
		public function containsDelayedCalls(callback:Function) : Boolean {
			var _local2:int = 0;
			var _local3:DelayedCall = null;
			if(callback != null) {
				_local2 = _objects.length - 1;
				while(_local2 >= 0) {
					_local3 = _objects[_local2] as DelayedCall;
					if(_local3 && _local3.callback == callback) {
						return true;
					}
					_local2--;
				}
			}
			return false;
		}
		
		public function purge() : void {
			var _local1:int = 0;
			var _local3:IAnimatable = null;
			var _local2:EventDispatcher = null;
			_local1 = _objects.length - 1;
			while(_local1 >= 0) {
				_local3 = _objects[_local1];
				_local2 = _local3 as EventDispatcher;
				if(_local2) {
					_local2.removeEventListener("removeFromJuggler",onRemove);
				}
				_objects[_local1] = null;
				delete _objectIDs[_local3];
				_local1--;
			}
		}
		
		public function delayCall(call:Function, delay:Number, ... rest) : uint {
			if(call == null) {
				throw new ArgumentError("call must not be null");
			}
			var _local4:DelayedCall = DelayedCall.starling_internal::fromPool(call,delay,rest);
			_local4.addEventListener("removeFromJuggler",onPooledDelayedCallComplete);
			return add(_local4);
		}
		
		public function repeatCall(call:Function, interval:Number, repeatCount:int = 0, ... rest) : uint {
			if(call == null) {
				throw new ArgumentError("call must not be null");
			}
			var _local5:DelayedCall = DelayedCall.starling_internal::fromPool(call,interval,rest);
			_local5.repeatCount = repeatCount;
			_local5.addEventListener("removeFromJuggler",onPooledDelayedCallComplete);
			return add(_local5);
		}
		
		private function onPooledDelayedCallComplete(event:Event) : void {
			DelayedCall.starling_internal::toPool(event.target as DelayedCall);
		}
		
		public function tween(target:Object, time:Number, properties:Object) : uint {
			var _local6:Object = null;
			if(target == null) {
				throw new ArgumentError("target must not be null");
			}
			var _local4:Tween = Tween.starling_internal::fromPool(target,time);
			for(var _local5 in properties) {
				_local6 = properties[_local5];
				if(_local4.hasOwnProperty(_local5)) {
					_local4[_local5] = _local6;
				} else {
					if(!target.hasOwnProperty(Tween.getPropertyName(_local5))) {
						throw new ArgumentError("Invalid property: " + _local5);
					}
					_local4.animate(_local5,_local6 as Number);
				}
			}
			_local4.addEventListener("removeFromJuggler",onPooledTweenComplete);
			return add(_local4);
		}
		
		private function onPooledTweenComplete(event:Event) : void {
			Tween.starling_internal::toPool(event.target as Tween);
		}
		
		public function advanceTime(time:Number) : void {
			var _local2:int = 0;
			var _local5:IAnimatable = null;
			var _local4:int = int(_objects.length);
			var _local3:int = 0;
			time *= _timeScale;
			if(_local4 == 0 || time == 0) {
				return;
			}
			_elapsedTime += time;
			_local2 = 0;
			while(_local2 < _local4) {
				_local5 = _objects[_local2];
				if(_local5) {
					if(_local3 != _local2) {
						_objects[_local3] = _local5;
						_objects[_local2] = null;
					}
					_local5.advanceTime(time);
					_local3++;
				}
				_local2++;
			}
			if(_local3 != _local2) {
				_local4 = int(_objects.length);
				while(_local2 < _local4) {
					_objects[_local3++] = _objects[_local2++];
				}
				_objects.length = _local3;
			}
		}
		
		private function onRemove(event:Event) : void {
			var _local2:Tween = null;
			var _local3:uint = remove(event.target as IAnimatable);
			if(_local3) {
				_local2 = event.target as Tween;
				if(_local2 && _local2.isComplete) {
					addWithID(_local2.nextTween,_local3);
				}
			}
		}
		
		public function get elapsedTime() : Number {
			return _elapsedTime;
		}
		
		public function get timeScale() : Number {
			return _timeScale;
		}
		
		public function set timeScale(value:Number) : void {
			_timeScale = value;
		}
		
		protected function get objects() : Vector.<IAnimatable> {
			return _objects;
		}
	}
}

