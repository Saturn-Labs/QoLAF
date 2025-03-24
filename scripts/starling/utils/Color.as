package starling.utils {
	import starling.errors.AbstractClassError;
	
	public class Color {
		public static const WHITE:uint = 16777215;
		
		public static const SILVER:uint = 12632256;
		
		public static const GRAY:uint = 8421504;
		
		public static const BLACK:uint = 0;
		
		public static const RED:uint = 16711680;
		
		public static const MAROON:uint = 8388608;
		
		public static const YELLOW:uint = 16776960;
		
		public static const OLIVE:uint = 8421376;
		
		public static const LIME:uint = 65280;
		
		public static const GREEN:uint = 32768;
		
		public static const AQUA:uint = 65535;
		
		public static const TEAL:uint = 32896;
		
		public static const BLUE:uint = 255;
		
		public static const NAVY:uint = 128;
		
		public static const FUCHSIA:uint = 16711935;
		
		public static const PURPLE:uint = 8388736;
		
		public function Color() {
			super();
			throw new AbstractClassError();
		}
		
		public static function getAlpha(color:uint) : int {
			return color >> 24 & 0xFF;
		}
		
		public static function getRed(color:uint) : int {
			return color >> 16 & 0xFF;
		}
		
		public static function getGreen(color:uint) : int {
			return color >> 8 & 0xFF;
		}
		
		public static function getBlue(color:uint) : int {
			return color & 0xFF;
		}
		
		public static function setAlpha(color:uint, alpha:int) : uint {
			return color & 0xFFFFFF | (alpha & 0xFF) << 24;
		}
		
		public static function setRed(color:uint, red:int) : uint {
			return color & 4278255615 | (red & 0xFF) << 16;
		}
		
		public static function setGreen(color:uint, green:int) : uint {
			return color & 4294902015 | (green & 0xFF) << 8;
		}
		
		public static function setBlue(color:uint, blue:int) : uint {
			return color & 4294967040 | blue & 0xFF;
		}
		
		public static function rgb(red:int, green:int, blue:int) : uint {
			return red << 16 | green << 8 | blue;
		}
		
		public static function argb(alpha:int, red:int, green:int, blue:int) : uint {
			return alpha << 24 | red << 16 | green << 8 | blue;
		}
		
		public static function toVector(color:uint, out:Vector.<Number> = null) : Vector.<Number> {
			if(out == null) {
				out = new Vector.<Number>(4,true);
			}
			out[0] = (color >> 16 & 0xFF) / 255;
			out[1] = (color >> 8 & 0xFF) / 255;
			out[2] = (color & 0xFF) / 255;
			out[3] = (color >> 24 & 0xFF) / 255;
			return out;
		}
		
		public static function multiply(color:uint, factor:Number) : uint {
			var _local6:uint = (color >> 24 & 0xFF) * factor;
			var _local3:uint = (color >> 16 & 0xFF) * factor;
			var _local4:uint = (color >> 8 & 0xFF) * factor;
			var _local5:uint = (color & 0xFF) * factor;
			if(_local6 > 255) {
				_local6 = 255;
			}
			if(_local3 > 255) {
				_local3 = 255;
			}
			if(_local4 > 255) {
				_local4 = 255;
			}
			if(_local5 > 255) {
				_local5 = 255;
			}
			return argb(_local6,_local3,_local4,_local5);
		}
		
		public static function interpolate(startColor:uint, endColor:uint, ratio:Number) : uint {
			var _local11:uint = uint(startColor >> 24 & 0xFF);
			var _local15:uint = uint(startColor >> 16 & 0xFF);
			var _local6:uint = uint(startColor >> 8 & 0xFF);
			var _local9:uint = uint(startColor & 0xFF);
			var _local8:uint = uint(endColor >> 24 & 0xFF);
			var _local14:uint = uint(endColor >> 16 & 0xFF);
			var _local5:uint = uint(endColor >> 8 & 0xFF);
			var _local7:uint = uint(endColor & 0xFF);
			var _local12:uint = _local11 + (_local8 - _local11) * ratio;
			var _local4:uint = _local15 + (_local14 - _local15) * ratio;
			var _local13:uint = _local6 + (_local5 - _local6) * ratio;
			var _local10:uint = _local9 + (_local7 - _local9) * ratio;
			return _local12 << 24 | _local4 << 16 | _local13 << 8 | _local10;
		}
	}
}

