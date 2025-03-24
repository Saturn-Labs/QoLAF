package playerio {
	import flash.utils.ByteArray;
	
	public class Message {
		private var content:Array;
		
		private var _type:String;
		
		public function Message(type:String, ... rest) {
			var _local3:int = 0;
			content = [];
			super();
			this._type = type;
			_local3 = 0;
			while(_local3 < rest.length) {
				_add(rest[_local3]);
				_local3++;
			}
		}
		
		public function add(... rest) : void {
			var _local2:int = 0;
			_local2 = 0;
			while(_local2 < rest.length) {
				_add(rest[_local2]);
				_local2++;
			}
		}
		
		public function getNumber(index:int) : Number {
			return content[index] as Number;
		}
		
		public function getInt(index:int) : int {
			return content[index] as int;
		}
		
		public function getUInt(index:int) : uint {
			return content[index] as uint;
		}
		
		public function getString(index:int) : String {
			return content[index].toString();
		}
		
		public function getBoolean(index:int) : Boolean {
			return content[index] as Boolean;
		}
		
		public function getByteArray(index:int) : ByteArray {
			return content[index] as ByteArray;
		}
		
		public function getObject(index:int) : * {
			return content[index];
		}
		
		public function clone(to:Object) : void {
			var _local2:int = 0;
			_local2 = 0;
			while(_local2 < content.length) {
				to.Add(content[_local2]);
				_local2++;
			}
		}
		
		public function get length() : int {
			return content.length;
		}
		
		public function get type() : String {
			return _type;
		}
		
		public function set type(type:String) : void {
			_type = type;
		}
		
		public function toString() : String {
			var _local3:int = 0;
			var _local4:* = undefined;
			var _local2:ByteArray = null;
			var _local1:String = "[playerio.Message]\n";
			_local1 += "type:\t\t" + type + "\n";
			_local1 += "length:\t\t" + length + "\n";
			_local1 += "content:\tId\tType\t\tValue\n";
			_local1 += "\t\t\t---------------------\n";
			_local3 = 0;
			while(_local3 < content.length) {
				_local4 = content[_local3];
				if(_local4 === undefined) {
					_local1 += "\t\t\t" + _local3 + "\tundefined\t\t" + _local4 + "\n";
				} else if(_local4 is String) {
					_local1 += "\t\t\t" + _local3 + "\tString\t\t" + _local4 + "\n";
				} else if(_local4 is Boolean) {
					_local1 += "\t\t\t" + _local3 + "\tBoolean\t\t" + _local4 + "\n";
				} else if(_local4 is ByteArray) {
					_local1 += "\t\t\t" + _local3 + "\tByteArray\tLength:" + _local4.length + "\n";
				} else {
					_local2 = new ByteArray();
					_local2.writeInt(_local4);
					_local2.position = 0;
					if(_local2.readInt() === _local4) {
						_local1 += "\t\t\t" + _local3 + "\tint\t\t\t" + _local4 + "\n";
					} else {
						_local2 = new ByteArray();
						_local2.writeUnsignedInt(_local4);
						_local2.position = 0;
						if(_local2.readUnsignedInt() === _local4) {
							_local1 += "\t\t\t" + _local3 + "\tuint\t\t" + _local4 + "\n";
						} else {
							_local2 = new ByteArray();
							_local2.writeFloat(_local4);
							_local2.position = 0;
							if(_local2.readFloat() === _local4) {
								_local1 += "\t\t\t" + _local3 + "\tFloat\t\t" + _local4 + "\n";
							} else {
								_local1 += "\t\t\t" + _local3 + "\tDouble\t\t" + _local4 + "\n";
							}
						}
					}
				}
				_local3++;
			}
			return _local1;
		}
		
		private function _add(o:*) : void {
			if(o is Number || o is Boolean || o is String || o is ByteArray) {
				content.push(o);
				return;
			}
			throw new Error(typeof o + " is not yet supported");
		}
	}
}

