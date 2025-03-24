package generics {
	import flash.system.Capabilities;
	
	public class GUID {
		private static var counter:Number = 0;
		
		public function GUID() {
			super();
		}
		
		public static function create() : String {
			var _local1:Date = new Date();
			var _local4:Number = Number(_local1.getTime());
			var _local3:Number = Math.random() * 1.7976931348623157e+308;
			var _local6:String = Capabilities.serverString;
			var _local5:String = calculate(_local4 + _local6 + _local3 + counter++).toUpperCase();
			return _local5.substring(0,8) + "-" + _local5.substring(8,12) + "-" + _local5.substring(12,16) + "-" + _local5.substring(16,20) + "-" + _local5.substring(20,32);
		}
		
		private static function calculate(src:String) : String {
			return hex_sha1(src);
		}
		
		private static function hex_sha1(src:String) : String {
			return binb2hex(core_sha1(str2binb(src),src.length * 8));
		}
		
		private static function core_sha1(x:Array, len:Number) : Array {
			var _local9:Number = NaN;
			var _local13:* = NaN;
			var _local8:* = NaN;
			var _local12:Number = NaN;
			var _local15:Number = NaN;
			x[len >> 5] |= 128 << 24 - len % 32;
			x[(len + 64 >> 9 << 4) + 15] = len;
			var _local16:Array = new Array(80);
			var _local3:* = 1732584193;
			var _local4:* = -271733879;
			var _local5:Number = -1732584194;
			var _local6:* = 271733878;
			var _local7:* = -1009589776;
			_local9 = 0;
			while(_local9 < x.length) {
				_local13 = _local3;
				var _local14:* = _local4;
				_local8 = _local5;
				var _local10:* = _local6;
				var _local11:* = _local7;
				_local12 = 0;
				while(_local12 < 80) {
					if(_local12 < 16) {
						_local16[_local12] = x[_local9 + _local12];
					} else {
						_local16[_local12] = rol(_local16[_local12 - 3] ^ _local16[_local12 - 8] ^ _local16[_local12 - 14] ^ _local16[_local12 - 16],1);
					}
					_local15 = safe_add(safe_add(rol(_local3,5),sha1_ft(_local12,_local4,_local5,_local6)),safe_add(safe_add(_local7,_local16[_local12]),sha1_kt(_local12)));
					_local7 = _local6;
					_local6 = _local5;
					_local5 = rol(_local4,30);
					_local4 = _local3;
					_local3 = _local15;
					_local12++;
				}
				_local3 = safe_add(_local3,_local13);
				_local4 = safe_add(_local4,_local14);
				_local5 = safe_add(_local5,_local8);
				_local6 = safe_add(_local6,_local10);
				_local7 = safe_add(_local7,_local11);
				_local9 += 16;
			}
			return new Array(_local3,_local4,_local5,_local6,_local7);
		}
		
		private static function sha1_ft(t:Number, b:Number, c:Number, d:Number) : Number {
			if(t < 20) {
				return b & c | ~b & d;
			}
			if(t < 40) {
				return b ^ c ^ d;
			}
			if(t < 60) {
				return b & c | b & d | c & d;
			}
			return b ^ c ^ d;
		}
		
		private static function sha1_kt(t:Number) : Number {
			return t < 20 ? 1518500249 : (t < 40 ? 1859775393 : (t < 60 ? -1894007588 : -899497514));
		}
		
		private static function safe_add(x:Number, y:Number) : Number {
			var _local4:Number = (x & 0xFFFF) + (y & 0xFFFF);
			var _local3:Number = (x >> 16) + (y >> 16) + (_local4 >> 16);
			return _local3 << 16 | _local4 & 0xFFFF;
		}
		
		private static function rol(num:Number, cnt:Number) : Number {
			return num << cnt | num >>> 32 - cnt;
		}
		
		private static function str2binb(str:String) : Array {
			var _local3:Number = NaN;
			var _local2:Array = [];
			var _local4:Number = 255;
			_local3 = 0;
			while(_local3 < str.length * 8) {
				var _local5:* = _local3 >> 5;
				var _local6:* = _local2[_local5] | (str.charCodeAt(_local3 / 8) & _local4) << 24 - _local3 % 32;
				_local2[_local5] = _local6;
				_local3 += 8;
			}
			return _local2;
		}
		
		private static function binb2hex(binarray:Array) : String {
			var _local4:Number = NaN;
			var _local2:String = new String("");
			var _local3:String = new String("0123456789abcdef");
			_local4 = 0;
			while(_local4 < binarray.length * 4) {
				_local2 += _local3.charAt(binarray[_local4 >> 2] >> (3 - _local4 % 4) * 8 + 4 & 0x0F) + _local3.charAt(binarray[_local4 >> 2] >> (3 - _local4 % 4) * 8 & 0x0F);
				_local4++;
			}
			return _local2;
		}
	}
}

