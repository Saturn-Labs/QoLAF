package core {
	public class version {
		private var _value:Number = 0;
		
		public function version(major:uint = 0, minor:uint = 0, build:uint = 0, revision:uint = 0) {
			super();
			this._value = major << 28 | minor << 24 | build << 16 | revision;
		}
		
		public function get build() : uint {
			return (this._value & 0xFF0000) >>> 16;
		}
		
		public function set build(value:uint) : void {
			this._value = this._value & 4278255615 | value << 16;
		}
		
		public function get major() : uint {
			return this._value >>> 28;
		}
		
		public function set major(value:uint) : void {
			this._value = this._value & 0x0FFFFFFF | value << 28;
		}
		
		public function get minor() : uint {
			return (this._value & 0x0F000000) >>> 24;
		}
		
		public function set minor(value:uint) : void {
			this._value = this._value & 4043309055 | value << 24;
		}
		
		public function get revision() : uint {
			return this._value & 0xFFFF;
		}
		
		public function set revision(value:uint) : void {
			this._value = this._value & 4294901760 | value;
		}
		
		public function toString(fields:int = 0, separator:String = ".") : String {
			var _local4:int = 0;
			var _local5:int = 0;
			var _local3:Array = [this.major,this.minor,this.build,this.revision];
			if(fields > 0 && fields < 5) {
				_local3 = _local3.slice(0,fields);
			} else {
				_local5 = int(_local3.length);
				_local4 = _local5 - 1;
				while(_local4 > 0) {
					if(_local3[_local4] != 0) {
						break;
					}
					_local3.pop();
					_local4--;
				}
			}
			return _local3.join(separator);
		}
		
		public function valueOf() : Number {
			return this._value;
		}
	}
}

