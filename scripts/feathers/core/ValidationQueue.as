package feathers.core {
	import flash.utils.Dictionary;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	
	public final class ValidationQueue implements IAnimatable {
		private static const STARLING_TO_VALIDATION_QUEUE:Dictionary = new Dictionary(true);
		
		private var _starling:Starling;
		
		private var _isValidating:Boolean = false;
		
		private var _delayedQueue:Vector.<IValidating> = new Vector.<IValidating>(0);
		
		private var _queue:Vector.<IValidating> = new Vector.<IValidating>(0);
		
		public function ValidationQueue(starling:Starling) {
			super();
			this._starling = starling;
		}
		
		public static function forStarling(starling:Starling) : ValidationQueue {
			if(!starling) {
				return null;
			}
			var _local2:ValidationQueue = STARLING_TO_VALIDATION_QUEUE[starling];
			if(!_local2) {
				STARLING_TO_VALIDATION_QUEUE[starling] = _local2 = new ValidationQueue(starling);
			}
			return _local2;
		}
		
		public function get isValidating() : Boolean {
			return this._isValidating;
		}
		
		public function dispose() : void {
			if(this._starling) {
				this._starling.juggler.remove(this);
				this._starling = null;
			}
		}
		
		public function addControl(control:IValidating, delayIfValidating:Boolean) : void {
			var _local5:int = 0;
			var _local7:int = 0;
			var _local8:IValidating = null;
			var _local6:int = 0;
			if(!this._starling.juggler.contains(this)) {
				this._starling.juggler.add(this);
			}
			var _local3:Vector.<IValidating> = this._isValidating && delayIfValidating ? this._delayedQueue : this._queue;
			if(_local3.indexOf(control) >= 0) {
				return;
			}
			var _local4:int = int(_local3.length);
			if(this._isValidating && _local3 == this._queue) {
				_local5 = control.depth;
				_local7 = _local4 - 1;
				while(_local7 >= 0) {
					_local8 = IValidating(_local3[_local7]);
					_local6 = _local8.depth;
					if(_local5 >= _local6) {
						break;
					}
					_local7--;
				}
				_local7++;
				_local3.insertAt(_local7,control);
			} else {
				_local3[_local4] = control;
			}
		}
		
		public function advanceTime(time:Number) : void {
			var _local3:IValidating = null;
			if(this._isValidating || !this._starling.contextValid) {
				return;
			}
			var _local2:int = int(this._queue.length);
			if(_local2 === 0) {
				return;
			}
			this._isValidating = true;
			if(_local2 > 1) {
				this._queue = this._queue.sort(queueSortFunction);
			}
			while(this._queue.length > 0) {
				_local3 = this._queue.shift();
				if(_local3.depth >= 0) {
					_local3.validate();
				}
			}
			var _local4:Vector.<IValidating> = this._queue;
			this._queue = this._delayedQueue;
			this._delayedQueue = _local4;
			this._isValidating = false;
		}
		
		protected function queueSortFunction(first:IValidating, second:IValidating) : int {
			var _local3:int = second.depth - first.depth;
			if(_local3 > 0) {
				return -1;
			}
			if(_local3 < 0) {
				return 1;
			}
			return 0;
		}
	}
}

