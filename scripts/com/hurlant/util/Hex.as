package com.hurlant.util {
	import flash.utils.ByteArray;
	
	public class Hex {
		public function Hex() {
			super();
		}
		
		public static function toArray(hex:String) : ByteArray {
			var _local3:* = 0;
			hex = hex.replace(/\s|:/gm,"");
			var _local2:ByteArray = new ByteArray();
			if((hex.length & 1) == 1) {
				hex = "0" + hex;
			}
			_local3 = 0;
			while(_local3 < hex.length) {
				_local2[_local3 / 2] = parseInt(hex.substr(_local3,2),16);
				_local3 += 2;
			}
			return _local2;
		}
		
		public static function fromArray(array:ByteArray, colons:Boolean = false) : String {
			var _local4:* = 0;
			var _local3:String = "";
			_local4 = 0;
			while(_local4 < array.length) {
				_local3 += ("0" + array[_local4].toString(16)).substr(-2,2);
				if(colons) {
					if(_local4 < array.length - 1) {
						_local3 += ":";
					}
				}
				_local4++;
			}
			return _local3;
		}
		
		public static function toString(hex:String) : String {
			var _local2:ByteArray = toArray(hex);
			return _local2.readUTFBytes(_local2.length);
		}
		
		public static function fromString(str:String, colons:Boolean = false) : String {
			var _local3:ByteArray = new ByteArray();
			_local3.writeUTFBytes(str);
			return fromArray(_local3,colons);
		}
	}
}

