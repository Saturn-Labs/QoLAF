package starling.utils {
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import starling.errors.AbstractClassError;
	
	public class MathUtil {
		private static const TWO_PI:Number = 6.283185307179586;
		
		public function MathUtil() {
			super();
			throw new AbstractClassError();
		}
		
		public static function intersectLineWithXYPlane(pointA:Vector3D, pointB:Vector3D, out:Point = null) : Point {
			if(out == null) {
				out = new Point();
			}
			var _local7:Number = pointB.x - pointA.x;
			var _local5:Number = pointB.y - pointA.y;
			var _local6:Number = pointB.z - pointA.z;
			var _local4:Number = -pointA.z / _local6;
			out.x = pointA.x + _local4 * _local7;
			out.y = pointA.y + _local4 * _local5;
			return out;
		}
		
		public static function isPointInTriangle(p:Point, a:Point, b:Point, c:Point) : Boolean {
			var _local15:Number = c.x - a.x;
			var _local13:Number = c.y - a.y;
			var _local8:Number = b.x - a.x;
			var _local16:Number = b.y - a.y;
			var _local12:Number = p.x - a.x;
			var _local9:Number = p.y - a.y;
			var _local10:Number = _local15 * _local15 + _local13 * _local13;
			var _local17:Number = _local15 * _local8 + _local13 * _local16;
			var _local14:Number = _local15 * _local12 + _local13 * _local9;
			var _local11:Number = _local8 * _local8 + _local16 * _local16;
			var _local18:Number = _local8 * _local12 + _local16 * _local9;
			var _local5:Number = 1 / (_local10 * _local11 - _local17 * _local17);
			var _local6:Number = (_local11 * _local14 - _local17 * _local18) * _local5;
			var _local7:Number = (_local10 * _local18 - _local17 * _local14) * _local5;
			return _local6 >= 0 && _local7 >= 0 && _local6 + _local7 < 1;
		}
		
		public static function normalizeAngle(angle:Number) : Number {
			angle %= 6.283185307179586;
			if(angle < -3.141592653589793) {
				angle += 6.283185307179586;
			}
			if(angle > 3.141592653589793) {
				angle -= 6.283185307179586;
			}
			return angle;
		}
		
		public static function getNextPowerOfTwo(number:Number) : int {
			var _local2:* = 0;
			if(number is int && number > 0 && (number & number - 1) == 0) {
				return number;
			}
			_local2 = 1;
			number -= 1e-9;
			while(_local2 < number) {
				_local2 <<= 1;
			}
			return _local2;
		}
		
		public static function isEquivalent(a:Number, b:Number, epsilon:Number = 0.0001) : Boolean {
			return a - epsilon < b && a + epsilon > b;
		}
		
		public static function max(a:Number, b:Number) : Number {
			return a > b ? a : b;
		}
		
		public static function min(a:Number, b:Number) : Number {
			return a < b ? a : b;
		}
		
		public static function clamp(value:Number, min:Number, max:Number) : Number {
			return value < min ? min : (value > max ? max : value);
		}
	}
}

