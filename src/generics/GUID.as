package generics
{
	import flash.system.Capabilities;
	
	public class GUID
	{
		private static var counter:Number = 0;
		public function GUID()
		{
			super();
		}
		
		public static function create():String
		{
			var _loc1_:Date = new Date();
			var _loc3_:Number = Number(_loc1_.getTime());
			var _loc2_:Number = Math.random() * 1.7976931348623157e+308;
			var _loc6_:String = Capabilities.serverString;
			var _loc4_:String = calculate(_loc3_ + _loc6_ + _loc2_ + counter++).toUpperCase();
			return _loc4_.substring(0, 8) + "-" + _loc4_.substring(8, 12) + "-" + _loc4_.substring(12, 16) + "-" + _loc4_.substring(16, 20) + "-" + _loc4_.substring(20, 32);
		}
		
		private static function calculate(param1:String):String
		{
			return hex_sha1(param1);
		}
		
		private static function hex_sha1(param1:String):String
		{
			return binb2hex(core_sha1(str2binb(param1), param1.length * 8));
		}
		
		private static function core_sha1(param1:Array, param2:Number):Array
		{
			var _loc9_:Number = NaN;
			var _loc16_:* = NaN;
			var _loc14_:* = NaN;
			var _loc8_:Number = NaN;
			var _loc13_:Number = NaN;
			param1[param2 >> 5] |= 128 << 24 - param2 % 32;
			param1[(param2 + 64 >> 9 << 4) + 15] = param2;
			var _loc10_:Array = new Array(80);
			var _loc7_:* = 1732584193;
			var _loc5_:* = -271733879;
			var _loc6_:Number = -1732584194;
			var _loc3_:* = 271733878;
			var _loc4_:* = -1009589776;
			_loc9_ = 0;
			while (_loc9_ < param1.length)
			{
				_loc16_ = _loc7_;
				var _loc15_:* = _loc5_;
				_loc14_ = _loc6_;
				var _loc12_:* = _loc3_;
				var _loc11_:* = _loc4_;
				_loc8_ = 0;
				while (_loc8_ < 80)
				{
					if (_loc8_ < 16)
					{
						_loc10_[_loc8_] = param1[_loc9_ + _loc8_];
					}
					else
					{
						_loc10_[_loc8_] = rol(_loc10_[_loc8_ - 3] ^ _loc10_[_loc8_ - 8] ^ _loc10_[_loc8_ - 14] ^ _loc10_[_loc8_ - 16], 1);
					}
					_loc13_ = safe_add(safe_add(rol(_loc7_, 5), sha1_ft(_loc8_, _loc5_, _loc6_, _loc3_)), safe_add(safe_add(_loc4_, _loc10_[_loc8_]), sha1_kt(_loc8_)));
					_loc4_ = _loc3_;
					_loc3_ = _loc6_;
					_loc6_ = rol(_loc5_, 30);
					_loc5_ = _loc7_;
					_loc7_ = _loc13_;
					_loc8_++;
				}
				_loc7_ = safe_add(_loc7_, _loc16_);
				_loc5_ = safe_add(_loc5_, _loc15_);
				_loc6_ = safe_add(_loc6_, _loc14_);
				_loc3_ = safe_add(_loc3_, _loc12_);
				_loc4_ = safe_add(_loc4_, _loc11_);
				_loc9_ += 16;
			}
			return new Array(_loc7_, _loc5_, _loc6_, _loc3_, _loc4_);
		}
		
		private static function sha1_ft(param1:Number, param2:Number, param3:Number, param4:Number):Number
		{
			if (param1 < 20)
			{
				return param2 & param3 | ~param2 & param4;
			}
			if (param1 < 40)
			{
				return param2 ^ param3 ^ param4;
			}
			if (param1 < 60)
			{
				return param2 & param3 | param2 & param4 | param3 & param4;
			}
			return param2 ^ param3 ^ param4;
		}
		
		private static function sha1_kt(param1:Number):Number
		{
			return param1 < 20 ? 1518500249 : (param1 < 40 ? 1859775393 : (param1 < 60 ? -1894007588 : -899497514));
		}
		
		private static function safe_add(param1:Number, param2:Number):Number
		{
			var _loc3_:Number = (param1 & 0xFFFF) + (param2 & 0xFFFF);
			var _loc4_:Number = (param1 >> 16) + (param2 >> 16) + (_loc3_ >> 16);
			return _loc4_ << 16 | _loc3_ & 0xFFFF;
		}
		
		private static function rol(param1:Number, param2:Number):Number
		{
			return param1 << param2 | param1 >>> 32 - param2;
		}
		
		private static function str2binb(param1:String):Array
		{
			var _loc4_:Number = NaN;
			var _loc3_:Array = [];
			var _loc2_:Number = 255;
			_loc4_ = 0;
			while (_loc4_ < param1.length * 8)
			{
				var _loc5_:* = _loc4_ >> 5;
				var _loc6_:* = _loc3_[_loc5_] | (param1.charCodeAt(_loc4_ / 8) & _loc2_) << 24 - _loc4_ % 32;
				_loc3_[_loc5_] = _loc6_;
				_loc4_ += 8;
			}
			return _loc3_;
		}
		
		private static function binb2hex(param1:Array):String
		{
			var _loc4_:Number = NaN;
			var _loc2_:String = new String("");
			var _loc3_:String = new String("0123456789abcdef");
			_loc4_ = 0;
			while (_loc4_ < param1.length * 4)
			{
				_loc2_ += _loc3_.charAt(param1[_loc4_ >> 2] >> (3 - _loc4_ % 4) * 8 + 4 & 0x0F) + _loc3_.charAt(param1[_loc4_ >> 2] >> (3 - _loc4_ % 4) * 8 & 0x0F);
				_loc4_++;
			}
			return _loc2_;
		}
	}
}
