package generics
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Util
	{
		public static var Math2PI:Number = 6.283185307179586;
		
		public function Util()
		{
			super();
		}
		
		public static function lerp(start:Number, end:Number, t:Number): Number {
			var v:Number = start + (end - start) * t;
			return isNaN(v) ? end : v;
		}
		
		public static function distance(lhs:Point, rhs:Point): Number {
			return Math.sqrt(Math.pow(rhs.x - lhs.x, 2) + Math.pow(rhs.y - lhs.y, 2));
		}
		
		public static function degreesToRadians(param1:Number):Number
		{
			return param1 * 3.141592653589793 / 180;
		}
		
		public static function getRotationEaseAmount(param1:Number, param2:Number):Number
		{
			if (param1 > 3.141592653589793)
			{
				param1 -= Math2PI;
			}
			else if (param1 < -3.141592653589793)
			{
				param1 = Math2PI + param1;
			}
			return param1 * param2;
		}
		
		public static function angleDifference(param1:Number, param2:Number):Number
		{
			var _loc3_:Number = param1 - param2;
			if (_loc3_ > 3.141592653589793)
			{
				return _loc3_ - Math2PI;
			}
			if (_loc3_ < -3.141592653589793)
			{
				return _loc3_ + Math2PI;
			}
			return _loc3_;
		}
		
		public static function radiansToDegrees(param1:Number):Number
		{
			return param1 * 180 / 3.141592653589793;
		}
		
		public static function isAngleBetween(param1:Number, param2:Number, param3:Number):Boolean
		{
			var _loc4_:Boolean = false;
			param1 = clampDegrees(param1);
			param2 = clampDegrees(param2);
			param3 = clampDegrees(param3);
			_loc4_ = param1 >= param2 && param1 <= param3;
			if (param2 > 180 && param3 < 180)
			{
				if (param1 <= 360 && param1 >= param2)
				{
					_loc4_ = true;
				}
				if (param1 >= 0 && param1 <= param3)
				{
					_loc4_ = true;
				}
			}
			return _loc4_;
		}
		
		public static function clampDegrees(param1:Number):Number
		{
			return param1 % 360;
		}
		
		public static function clampRadians(param1:Number):Number
		{
			param1 /= Math2PI;
			return (param1 - Math.floor(param1)) * Math2PI;
		}
		
		public static function formatDecimal(param1:Number, param2:int = 1):Number
		{
			return Math.floor(param1 * 10 * param2) / 10 * param2;
		}
		
		public static function sign(param1:Number):Number
		{
			if (param1 >= 0)
			{
				return 1;
			}
			return -1;
		}
		
		public static function formatAmount(param1:Number):String
		{
			var _loc2_:String = "";
			if (param1 > 5000)
			{
				param1 /= 1000;
				_loc2_ = "k";
			}
			return _loc2_ == "" ? param1.toString() : param1.toFixed(1) + _loc2_;
		}
		
		public static function dotProduct(param1:Number, param2:Number, param3:Number, param4:Number):Number
		{
			return param1 * param3 + param2 * param4;
		}
		
		public static function intersectLineAndRect(param1:Number, param2:Number, param3:Number, param4:Number, param5:Rectangle):Point
		{
			var _loc6_:Point = Util.intersectLines(param1, param2, param3, param4, param5.right, param5.y, param5.right, param5.bottom);
			if (_loc6_ == null)
			{
				_loc6_ = Util.intersectLines(param1, param2, param3, param4, param5.x, param5.y, param5.x, param5.bottom);
			}
			if (_loc6_ == null)
			{
				_loc6_ = Util.intersectLines(param1, param2, param3, param4, param5.x, param5.y, param5.right, param5.y);
			}
			if (_loc6_ == null)
			{
				_loc6_ = Util.intersectLines(param1, param2, param3, param4, param5.x, param5.bottom, param5.right, param5.bottom);
			}
			return _loc6_;
		}
		
		public static function intersectLines(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number):Point
		{
			var _loc12_:* = NaN;
			var _loc11_:* = NaN;
			var _loc15_:* = NaN;
			var _loc14_:* = NaN;
			var _loc18_:* = NaN;
			var _loc17_:* = NaN;
			var _loc16_:* = NaN;
			var _loc13_:* = NaN;
			var _loc10_:Number = ((param7 - param5) * (param2 - param6) - (param8 - param6) * (param1 - param5)) / ((param8 - param6) * (param3 - param1) - (param7 - param5) * (param4 - param2));
			var _loc9_:Number = param1 + _loc10_ * (param3 - param1);
			var _loc19_:Number = param2 + _loc10_ * (param4 - param2);
			if (_loc9_.toString() == (NaN).toString() || _loc19_.toString() == (NaN).toString())
			{
				return null;
			}
			if (param1 > param3)
			{
				_loc12_ = param3;
				_loc11_ = param1;
			}
			else
			{
				_loc12_ = param1;
				_loc11_ = param3;
			}
			if (param2 > param4)
			{
				_loc15_ = param4;
				_loc14_ = param2;
			}
			else
			{
				_loc15_ = param2;
				_loc14_ = param4;
			}
			if (param5 > param7)
			{
				_loc18_ = param7;
				_loc17_ = param5;
			}
			else
			{
				_loc18_ = param5;
				_loc17_ = param7;
			}
			if (param6 > param8)
			{
				_loc16_ = param8;
				_loc13_ = param6;
			}
			else
			{
				_loc16_ = param6;
				_loc13_ = param8;
			}
			if (_loc9_ >= _loc12_ && _loc9_ <= _loc11_ && _loc19_ >= _loc15_ && _loc19_ <= _loc14_ && _loc9_ >= _loc18_ && _loc9_ <= _loc17_ && _loc19_ >= _loc16_ && _loc19_ <= _loc13_)
			{
				return new Point(_loc9_, _loc19_);
			}
			return null;
		}
		
		public static function getFormattedTime(param1:Number):String
		{
			var _loc5_:int = Math.floor(param1 / 1000);
			var _loc2_:int = Math.floor(_loc5_ / 60);
			var _loc4_:int = Math.floor(_loc2_ / 60);
			_loc5_ -= _loc2_ * 60;
			_loc2_ -= _loc4_ * 60;
			var _loc3_:String = "";
			if (_loc4_ > 0)
			{
				_loc3_ = _loc4_ + "h ";
			}
			if (_loc2_ > 0 || _loc4_ > 0)
			{
				_loc3_ = _loc3_ + _loc2_ + "m ";
			}
			if (_loc5_ > 0 || _loc2_ > 0 || _loc4_ > 0)
			{
				_loc3_ = _loc3_ + _loc5_ + "s ";
			}
			return _loc3_;
		}
		
		public static function trimUsername(param1:String):String
		{
			return param1.replace(/^([\s|\t|\n]+)?(.*)([\s|\t|\n]+)?$/gm, "$2");
		}
		
		public static function clamp(value:Number, min:Number, max:Number): Number {
			return Math.max(min, Math.min(value, max));
		}
		
		public static function normalize(value:Number, min:Number, max:Number): Number {
			if (max - min == 0) {
				return 0;
			}
			return (value - min) / (max - min);
		}
		
		public static function rescale(value:Number, sourceMin:Number, sourceMax:Number, targetMin:Number, targetMax:Number): Number {
			if (sourceMax - sourceMin == 0) {
				return targetMin;
			}
			return targetMin + ((value - sourceMin) / (sourceMax - sourceMin)) * (targetMax - targetMin);
		}
	}
}
