package facebook {
	import flash.events.*;
	import flash.external.*;
	import flash.system.*;
	import flash.utils.*;
	
	public class FBWaitable {
		private var subscribers:Object = {};
		
		private var _value:Object = null;
		
		public function FBWaitable() {
			super();
		}
		
		public function set value(value:Object) : void {
			if(JSON2.serialize(value) != JSON2.serialize(_value)) {
				_value = value;
				fire("value",value);
			}
		}
		
		public function get value() : Object {
			return _value;
		}
		
		public function error(ex:Error) : void {
			fire("error",ex);
		}
		
		public function wait(callback:Function, ... rest) : void {
			var t:*;
			var args:Array = rest;
			var errorHandler:Function = args.length == 1 && args[0] is Function ? args[0] : null;
			if(errorHandler != null) {
				this.subscribe("error",errorHandler);
			}
			t = this;
			this.monitor("value",function():Boolean {
				if(t.value != null) {
					callback(t.value);
					return true;
				}
				return false;
			});
		}
		
		public function subscribe(name:String, cb:Function) : void {
			if(!subscribers[name]) {
				subscribers[name] = [cb];
			} else {
				subscribers[name].push(cb);
			}
		}
		
		public function unsubscribe(name:String, cb:Function) : void {
			var _local4:int = 0;
			var _local3:Array = subscribers[name];
			if(_local3) {
				_local4 = 0;
				while(_local4 != _local3.length) {
					if(_local3[_local4] == cb) {
						_local3[_local4] = null;
					}
					_local4++;
				}
			}
		}
		
		public function monitor(name:String, callback:Function) : void {
			var ctx:FBWaitable;
			var fn:Function;
			if(!callback()) {
				ctx = this;
				fn = function(... rest):void {
					if(callback.apply(callback,rest)) {
						ctx.unsubscribe(name,fn);
					}
				};
				subscribe(name,fn);
			}
		}
		
		public function clear(name:String) : void {
			delete subscribers[name];
		}
		
		public function fire(name:String, ... rest) : void {
			var _local4:int = 0;
			var _local3:Array = subscribers[name];
			if(_local3) {
				_local4 = 0;
				while(_local4 != _local3.length) {
					if(_local3[_local4] != null) {
						_local3[_local4].apply(this,rest);
					}
					_local4++;
				}
			}
		}
	}
}

