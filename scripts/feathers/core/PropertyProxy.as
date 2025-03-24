package feathers.core {
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	use namespace flash_proxy;
	
	public final dynamic class PropertyProxy extends Proxy {
		private var _subProxyName:String;
		
		private var _onChangeCallbacks:Vector.<Function> = new Vector.<Function>(0);
		
		private var _names:Array = [];
		
		private var _storage:Object = {};
		
		public function PropertyProxy(onChangeCallback:Function = null) {
			super();
			if(onChangeCallback != null) {
				this._onChangeCallbacks[this._onChangeCallbacks.length] = onChangeCallback;
			}
		}
		
		public static function fromObject(source:Object, onChangeCallback:Function = null) : PropertyProxy {
			var _local3:PropertyProxy = new PropertyProxy(onChangeCallback);
			for(var _local4 in source) {
				_local3[_local4] = source[_local4];
			}
			return _local3;
		}
		
		override flash_proxy function hasProperty(name:*) : Boolean {
			return this._storage.hasOwnProperty(name);
		}
		
		override flash_proxy function getProperty(name:*) : * {
			var _local3:String = null;
			var _local2:PropertyProxy = null;
			if(this.flash_proxy::isAttribute(name)) {
				_local3 = name is QName ? QName(name).localName : name.toString();
				if(!this._storage.hasOwnProperty(_local3)) {
					_local2 = new PropertyProxy(subProxy_onChange);
					_local2._subProxyName = _local3;
					this._storage[_local3] = _local2;
					this._names[this._names.length] = _local3;
					this.fireOnChangeCallback(_local3);
				}
				return this._storage[_local3];
			}
			return this._storage[name];
		}
		
		override flash_proxy function setProperty(name:*, value:*) : void {
			var _local3:String = name is QName ? QName(name).localName : name.toString();
			this._storage[_local3] = value;
			if(this._names.indexOf(_local3) < 0) {
				this._names[this._names.length] = _local3;
			}
			this.fireOnChangeCallback(_local3);
		}
		
		override flash_proxy function deleteProperty(name:*) : Boolean {
			var _local4:String = name is QName ? QName(name).localName : name.toString();
			var _local3:int = int(this._names.indexOf(_local4));
			if(_local3 >= 0) {
				this._names.removeAt(_local3);
			}
			var _local2:* = delete this._storage[_local4];
			if(_local2) {
				this.fireOnChangeCallback(_local4);
			}
			return _local2;
		}
		
		override flash_proxy function nextNameIndex(index:int) : int {
			if(index < this._names.length) {
				return index + 1;
			}
			return 0;
		}
		
		override flash_proxy function nextName(index:int) : String {
			return this._names[index - 1];
		}
		
		override flash_proxy function nextValue(index:int) : * {
			var _local2:* = this._names[index - 1];
			return this._storage[_local2];
		}
		
		public function addOnChangeCallback(callback:Function) : void {
			this._onChangeCallbacks[this._onChangeCallbacks.length] = callback;
		}
		
		public function removeOnChangeCallback(callback:Function) : void {
			var _local2:int = int(this._onChangeCallbacks.indexOf(callback));
			if(_local2 < 0) {
				return;
			}
			if(_local2 == 0) {
				this._onChangeCallbacks.shift();
				return;
			}
			var _local3:int = this._onChangeCallbacks.length - 1;
			if(_local2 == _local3) {
				this._onChangeCallbacks.pop();
				return;
			}
			this._onChangeCallbacks.removeAt(_local2);
		}
		
		public function toString() : String {
			var _local1:String = "[object PropertyProxy";
			for(var _local2 in this) {
				_local1 += " " + _local2;
			}
			return _local1 + "]";
		}
		
		private function fireOnChangeCallback(forName:String) : void {
			var _local3:int = 0;
			var _local4:Function = null;
			var _local2:int = int(this._onChangeCallbacks.length);
			_local3 = 0;
			while(_local3 < _local2) {
				_local4 = this._onChangeCallbacks[_local3] as Function;
				_local4(this,forName);
				_local3++;
			}
		}
		
		private function subProxy_onChange(proxy:PropertyProxy, name:String) : void {
			this.fireOnChangeCallback(proxy._subProxyName);
		}
	}
}

