package com.adobe.utils {
	public class IntUtil {
		private static var hexChars:String = "0123456789abcdef";
		
		public function IntUtil() {
			super();
		}
		
		public static function rol(x:int, n:int) : int {
			return x << n | x >>> 32 - n;
		}
		
		public static function ror(x:int, n:int) : uint {
			var _local3:int = 32 - n;
			return x << _local3 | x >>> 32 - _local3;
		}
		
		public static function toHex(n:int, bigEndian:Boolean = false) : String {
			var _local5:int = 0;
			var _local4:int = 0;
			var _local3:String = "";
			if(bigEndian) {
				_local5 = 0;
				while(_local5 < 4) {
					_local3 += hexChars.charAt(n >> (3 - _local5) * 8 + 4 & 0x0F) + hexChars.charAt(n >> (3 - _local5) * 8 & 0x0F);
					_local5++;
				}
			} else {
				_local4 = 0;
				while(_local4 < 4) {
					_local3 += hexChars.charAt(n >> _local4 * 8 + 4 & 0x0F) + hexChars.charAt(n >> _local4 * 8 & 0x0F);
					_local4++;
				}
			}
			return _local3;
		}
	}
}

