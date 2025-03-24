package com.adobe.crypto {
	import com.adobe.utils.IntUtil;
	import flash.utils.ByteArray;
	
	public class MD5 {
		public static var digest:ByteArray;
		
		public function MD5() {
			super();
		}
		
		public static function hash(s:String) : String {
			var _local2:ByteArray = new ByteArray();
			_local2.writeUTFBytes(s);
			return hashBinary(_local2);
		}
		
		public static function hashBytes(s:ByteArray) : String {
			return hashBinary(s);
		}
		
		public static function hashBinary(s:ByteArray) : String {
			var _local2:* = 0;
			var _local3:* = 0;
			var _local4:* = 0;
			var _local5:* = 0;
			var _local12:int = 0;
			var _local6:int = 1732584193;
			var _local7:int = -271733879;
			var _local8:int = -1732584194;
			var _local9:int = 271733878;
			var _local11:Array = createBlocks(s);
			var _local10:int = int(_local11.length);
			_local12 = 0;
			while(_local12 < _local10) {
				_local2 = _local6;
				_local3 = _local7;
				_local4 = _local8;
				_local5 = _local9;
				_local6 = ff(_local6,_local7,_local8,_local9,_local11[_local12 + 0],7,-680876936);
				_local9 = ff(_local9,_local6,_local7,_local8,_local11[_local12 + 1],12,-389564586);
				_local8 = ff(_local8,_local9,_local6,_local7,_local11[_local12 + 2],17,606105819);
				_local7 = ff(_local7,_local8,_local9,_local6,_local11[_local12 + 3],22,-1044525330);
				_local6 = ff(_local6,_local7,_local8,_local9,_local11[_local12 + 4],7,-176418897);
				_local9 = ff(_local9,_local6,_local7,_local8,_local11[_local12 + 5],12,1200080426);
				_local8 = ff(_local8,_local9,_local6,_local7,_local11[_local12 + 6],17,-1473231341);
				_local7 = ff(_local7,_local8,_local9,_local6,_local11[_local12 + 7],22,-45705983);
				_local6 = ff(_local6,_local7,_local8,_local9,_local11[_local12 + 8],7,1770035416);
				_local9 = ff(_local9,_local6,_local7,_local8,_local11[_local12 + 9],12,-1958414417);
				_local8 = ff(_local8,_local9,_local6,_local7,_local11[_local12 + 10],17,-42063);
				_local7 = ff(_local7,_local8,_local9,_local6,_local11[_local12 + 11],22,-1990404162);
				_local6 = ff(_local6,_local7,_local8,_local9,_local11[_local12 + 12],7,1804603682);
				_local9 = ff(_local9,_local6,_local7,_local8,_local11[_local12 + 13],12,-40341101);
				_local8 = ff(_local8,_local9,_local6,_local7,_local11[_local12 + 14],17,-1502002290);
				_local7 = ff(_local7,_local8,_local9,_local6,_local11[_local12 + 15],22,1236535329);
				_local6 = gg(_local6,_local7,_local8,_local9,_local11[_local12 + 1],5,-165796510);
				_local9 = gg(_local9,_local6,_local7,_local8,_local11[_local12 + 6],9,-1069501632);
				_local8 = gg(_local8,_local9,_local6,_local7,_local11[_local12 + 11],14,643717713);
				_local7 = gg(_local7,_local8,_local9,_local6,_local11[_local12 + 0],20,-373897302);
				_local6 = gg(_local6,_local7,_local8,_local9,_local11[_local12 + 5],5,-701558691);
				_local9 = gg(_local9,_local6,_local7,_local8,_local11[_local12 + 10],9,38016083);
				_local8 = gg(_local8,_local9,_local6,_local7,_local11[_local12 + 15],14,-660478335);
				_local7 = gg(_local7,_local8,_local9,_local6,_local11[_local12 + 4],20,-405537848);
				_local6 = gg(_local6,_local7,_local8,_local9,_local11[_local12 + 9],5,568446438);
				_local9 = gg(_local9,_local6,_local7,_local8,_local11[_local12 + 14],9,-1019803690);
				_local8 = gg(_local8,_local9,_local6,_local7,_local11[_local12 + 3],14,-187363961);
				_local7 = gg(_local7,_local8,_local9,_local6,_local11[_local12 + 8],20,1163531501);
				_local6 = gg(_local6,_local7,_local8,_local9,_local11[_local12 + 13],5,-1444681467);
				_local9 = gg(_local9,_local6,_local7,_local8,_local11[_local12 + 2],9,-51403784);
				_local8 = gg(_local8,_local9,_local6,_local7,_local11[_local12 + 7],14,1735328473);
				_local7 = gg(_local7,_local8,_local9,_local6,_local11[_local12 + 12],20,-1926607734);
				_local6 = hh(_local6,_local7,_local8,_local9,_local11[_local12 + 5],4,-378558);
				_local9 = hh(_local9,_local6,_local7,_local8,_local11[_local12 + 8],11,-2022574463);
				_local8 = hh(_local8,_local9,_local6,_local7,_local11[_local12 + 11],16,1839030562);
				_local7 = hh(_local7,_local8,_local9,_local6,_local11[_local12 + 14],23,-35309556);
				_local6 = hh(_local6,_local7,_local8,_local9,_local11[_local12 + 1],4,-1530992060);
				_local9 = hh(_local9,_local6,_local7,_local8,_local11[_local12 + 4],11,1272893353);
				_local8 = hh(_local8,_local9,_local6,_local7,_local11[_local12 + 7],16,-155497632);
				_local7 = hh(_local7,_local8,_local9,_local6,_local11[_local12 + 10],23,-1094730640);
				_local6 = hh(_local6,_local7,_local8,_local9,_local11[_local12 + 13],4,681279174);
				_local9 = hh(_local9,_local6,_local7,_local8,_local11[_local12 + 0],11,-358537222);
				_local8 = hh(_local8,_local9,_local6,_local7,_local11[_local12 + 3],16,-722521979);
				_local7 = hh(_local7,_local8,_local9,_local6,_local11[_local12 + 6],23,76029189);
				_local6 = hh(_local6,_local7,_local8,_local9,_local11[_local12 + 9],4,-640364487);
				_local9 = hh(_local9,_local6,_local7,_local8,_local11[_local12 + 12],11,-421815835);
				_local8 = hh(_local8,_local9,_local6,_local7,_local11[_local12 + 15],16,530742520);
				_local7 = hh(_local7,_local8,_local9,_local6,_local11[_local12 + 2],23,-995338651);
				_local6 = ii(_local6,_local7,_local8,_local9,_local11[_local12 + 0],6,-198630844);
				_local9 = ii(_local9,_local6,_local7,_local8,_local11[_local12 + 7],10,1126891415);
				_local8 = ii(_local8,_local9,_local6,_local7,_local11[_local12 + 14],15,-1416354905);
				_local7 = ii(_local7,_local8,_local9,_local6,_local11[_local12 + 5],21,-57434055);
				_local6 = ii(_local6,_local7,_local8,_local9,_local11[_local12 + 12],6,1700485571);
				_local9 = ii(_local9,_local6,_local7,_local8,_local11[_local12 + 3],10,-1894986606);
				_local8 = ii(_local8,_local9,_local6,_local7,_local11[_local12 + 10],15,-1051523);
				_local7 = ii(_local7,_local8,_local9,_local6,_local11[_local12 + 1],21,-2054922799);
				_local6 = ii(_local6,_local7,_local8,_local9,_local11[_local12 + 8],6,1873313359);
				_local9 = ii(_local9,_local6,_local7,_local8,_local11[_local12 + 15],10,-30611744);
				_local8 = ii(_local8,_local9,_local6,_local7,_local11[_local12 + 6],15,-1560198380);
				_local7 = ii(_local7,_local8,_local9,_local6,_local11[_local12 + 13],21,1309151649);
				_local6 = ii(_local6,_local7,_local8,_local9,_local11[_local12 + 4],6,-145523070);
				_local9 = ii(_local9,_local6,_local7,_local8,_local11[_local12 + 11],10,-1120210379);
				_local8 = ii(_local8,_local9,_local6,_local7,_local11[_local12 + 2],15,718787259);
				_local7 = ii(_local7,_local8,_local9,_local6,_local11[_local12 + 9],21,-343485551);
				_local6 += _local2;
				_local7 += _local3;
				_local8 += _local4;
				_local9 += _local5;
				_local12 += 16;
			}
			digest = new ByteArray();
			digest.writeInt(_local6);
			digest.writeInt(_local7);
			digest.writeInt(_local8);
			digest.writeInt(_local9);
			digest.position = 0;
			return IntUtil.toHex(_local6) + IntUtil.toHex(_local7) + IntUtil.toHex(_local8) + IntUtil.toHex(_local9);
		}
		
		private static function f(x:int, y:int, z:int) : int {
			return x & y | ~x & z;
		}
		
		private static function g(x:int, y:int, z:int) : int {
			return x & z | y & ~z;
		}
		
		private static function h(x:int, y:int, z:int) : int {
			return x ^ y ^ z;
		}
		
		private static function i(x:int, y:int, z:int) : int {
			return y ^ (x | ~z);
		}
		
		private static function transform(func:Function, a:int, b:int, c:int, d:int, x:int, s:int, t:int) : int {
			var _local9:int = a + func(b,c,d) + x + t;
			return IntUtil.rol(_local9,s) + b;
		}
		
		private static function ff(a:int, b:int, c:int, d:int, x:int, s:int, t:int) : int {
			return transform(f,a,b,c,d,x,s,t);
		}
		
		private static function gg(a:int, b:int, c:int, d:int, x:int, s:int, t:int) : int {
			return transform(g,a,b,c,d,x,s,t);
		}
		
		private static function hh(a:int, b:int, c:int, d:int, x:int, s:int, t:int) : int {
			return transform(h,a,b,c,d,x,s,t);
		}
		
		private static function ii(a:int, b:int, c:int, d:int, x:int, s:int, t:int) : int {
			return transform(i,a,b,c,d,x,s,t);
		}
		
		private static function createBlocks(s:ByteArray) : Array {
			var _local4:int = 0;
			var _local3:Array = [];
			var _local2:int = s.length * 8;
			var _local5:int = 255;
			_local4 = 0;
			while(_local4 < _local2) {
				var _local6:* = _local4 >> 5;
				var _local7:* = _local3[_local6] | (s[_local4 / 8] & _local5) << _local4 % 32;
				_local3[_local6] = _local7;
				_local4 += 8;
			}
			_local7 = _local2 >> 5;
			_local6 = _local3[_local7] | 128 << _local2 % 32;
			_local3[_local7] = _local6;
			_local3[(_local2 + 64 >>> 9 << 4) + 14] = _local2;
			return _local3;
		}
	}
}

