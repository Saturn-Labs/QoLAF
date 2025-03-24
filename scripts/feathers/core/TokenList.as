package feathers.core {
	import starling.events.EventDispatcher;
	
	public class TokenList extends EventDispatcher {
		protected var _joinedNames:String = null;
		
		protected var names:Vector.<String> = new Vector.<String>(0);
		
		public function TokenList() {
			super();
		}
		
		public function get value() : String {
			if(this._joinedNames === null) {
				this._joinedNames = names.join(" ");
			}
			return this._joinedNames;
		}
		
		public function set value(value:String) : void {
			if(this.value == value) {
				return;
			}
			this._joinedNames = value;
			this.names.length = 0;
			this.names = Vector.<String>(value.split(" "));
			this.dispatchEventWith("change");
		}
		
		public function get length() : int {
			return this.names.length;
		}
		
		public function item(index:int) : String {
			if(index < 0 || index >= this.names.length) {
				return null;
			}
			return this.names[index];
		}
		
		public function add(name:String) : void {
			var _local2:int = int(this.names.indexOf(name));
			if(_local2 >= 0) {
				return;
			}
			if(this._joinedNames !== null) {
				this._joinedNames += " " + name;
			}
			this.names[this.names.length] = name;
			this.dispatchEventWith("change");
		}
		
		public function remove(name:String) : void {
			var _local2:int = int(this.names.indexOf(name));
			this.removeAt(_local2);
		}
		
		public function toggle(name:String) : void {
			var _local2:int = int(this.names.indexOf(name));
			if(_local2 < 0) {
				if(this._joinedNames !== null) {
					this._joinedNames += " " + name;
				}
				this.names[this.names.length] = name;
				this.dispatchEventWith("change");
			} else {
				this.removeAt(_local2);
			}
		}
		
		public function contains(name:String) : Boolean {
			return this.names.indexOf(name) >= 0;
		}
		
		protected function removeAt(index:int) : void {
			if(index < 0) {
				return;
			}
			this._joinedNames = null;
			this.names.removeAt(index);
			this.dispatchEventWith("change");
		}
	}
}

