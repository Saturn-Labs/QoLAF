package starling.utils {
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import starling.errors.AbstractClassError;
	
	public class RectangleUtil {
		private static const sPoint:Point = new Point();
		
		private static const sPoint3D:Vector3D = new Vector3D();
		
		private static const sPositions:Vector.<Point> = new <Point>[new Point(),new Point(),new Point(),new Point()];
		
		public function RectangleUtil() {
			super();
			throw new AbstractClassError();
		}
		
		public static function intersect(rect1:Rectangle, rect2:Rectangle, out:Rectangle = null) : Rectangle {
			if(out == null) {
				out = new Rectangle();
			}
			var _local5:Number = rect1.x > rect2.x ? rect1.x : rect2.x;
			var _local7:Number = rect1.right < rect2.right ? rect1.right : rect2.right;
			var _local4:Number = rect1.y > rect2.y ? rect1.y : rect2.y;
			var _local6:Number = rect1.bottom < rect2.bottom ? rect1.bottom : rect2.bottom;
			if(_local5 > _local7 || _local4 > _local6) {
				out.setEmpty();
			} else {
				out.setTo(_local5,_local4,_local7 - _local5,_local6 - _local4);
			}
			return out;
		}
		
		public static function fit(rectangle:Rectangle, into:Rectangle, scaleMode:String = "showAll", pixelPerfect:Boolean = false, out:Rectangle = null) : Rectangle {
			if(!ScaleMode.isValid(scaleMode)) {
				throw new ArgumentError("Invalid scaleMode: " + scaleMode);
			}
			if(out == null) {
				out = new Rectangle();
			}
			var _local8:Number = rectangle.width;
			var _local10:Number = rectangle.height;
			var _local7:Number = into.width / _local8;
			var _local6:Number = into.height / _local10;
			var _local9:Number = 1;
			if(scaleMode == "showAll") {
				_local9 = _local7 < _local6 ? _local7 : _local6;
				if(pixelPerfect) {
					_local9 = nextSuitableScaleFactor(_local9,false);
				}
			} else if(scaleMode == "noBorder") {
				_local9 = _local7 > _local6 ? _local7 : _local6;
				if(pixelPerfect) {
					_local9 = nextSuitableScaleFactor(_local9,true);
				}
			}
			_local8 *= _local9;
			_local10 *= _local9;
			out.setTo(into.x + (into.width - _local8) / 2,into.y + (into.height - _local10) / 2,_local8,_local10);
			return out;
		}
		
		private static function nextSuitableScaleFactor(factor:Number, up:Boolean) : Number {
			var _local3:Number = 1;
			if(up) {
				if(factor >= 0.5) {
					return Math.ceil(factor);
				}
				while(1 / (_local3 + 1) > factor) {
					_local3++;
				}
			} else {
				if(factor >= 1) {
					return Math.floor(factor);
				}
				while(1 / _local3 > factor) {
					_local3++;
				}
			}
			return 1 / _local3;
		}
		
		public static function normalize(rect:Rectangle) : void {
			if(rect.width < 0) {
				rect.width = -rect.width;
				rect.x -= rect.width;
			}
			if(rect.height < 0) {
				rect.height = -rect.height;
				rect.y -= rect.height;
			}
		}
		
		public static function extend(rect:Rectangle, left:Number = 0, right:Number = 0, top:Number = 0, bottom:Number = 0) : void {
			rect.x -= left;
			rect.y -= top;
			rect.width += left + right;
			rect.height += top + bottom;
		}
		
		public static function getBounds(rectangle:Rectangle, matrix:Matrix, out:Rectangle = null) : Rectangle {
			var _local8:int = 0;
			if(out == null) {
				out = new Rectangle();
			}
			var _local5:Number = 1.7976931348623157e+308;
			var _local7:Number = -1.7976931348623157e+308;
			var _local4:Number = 1.7976931348623157e+308;
			var _local6:Number = -1.7976931348623157e+308;
			var _local9:Vector.<Point> = getPositions(rectangle,sPositions);
			_local8 = 0;
			while(_local8 < 4) {
				MatrixUtil.transformCoords(matrix,_local9[_local8].x,_local9[_local8].y,sPoint);
				if(_local5 > sPoint.x) {
					_local5 = sPoint.x;
				}
				if(_local7 < sPoint.x) {
					_local7 = sPoint.x;
				}
				if(_local4 > sPoint.y) {
					_local4 = sPoint.y;
				}
				if(_local6 < sPoint.y) {
					_local6 = sPoint.y;
				}
				_local8++;
			}
			out.setTo(_local5,_local4,_local7 - _local5,_local6 - _local4);
			return out;
		}
		
		public static function getBoundsProjected(rectangle:Rectangle, matrix:Matrix3D, camPos:Vector3D, out:Rectangle = null) : Rectangle {
			var _local9:int = 0;
			var _local11:Point = null;
			if(out == null) {
				out = new Rectangle();
			}
			if(camPos == null) {
				throw new ArgumentError("camPos must not be null");
			}
			var _local6:Number = 1.7976931348623157e+308;
			var _local8:Number = -1.7976931348623157e+308;
			var _local5:Number = 1.7976931348623157e+308;
			var _local7:Number = -1.7976931348623157e+308;
			var _local10:Vector.<Point> = getPositions(rectangle,sPositions);
			_local9 = 0;
			while(_local9 < 4) {
				_local11 = _local10[_local9];
				if(matrix) {
					MatrixUtil.transformCoords3D(matrix,_local11.x,_local11.y,0,sPoint3D);
				} else {
					sPoint3D.setTo(_local11.x,_local11.y,0);
				}
				MathUtil.intersectLineWithXYPlane(camPos,sPoint3D,sPoint);
				if(_local6 > sPoint.x) {
					_local6 = sPoint.x;
				}
				if(_local8 < sPoint.x) {
					_local8 = sPoint.x;
				}
				if(_local5 > sPoint.y) {
					_local5 = sPoint.y;
				}
				if(_local7 < sPoint.y) {
					_local7 = sPoint.y;
				}
				_local9++;
			}
			out.setTo(_local6,_local5,_local8 - _local6,_local7 - _local5);
			return out;
		}
		
		public static function getPositions(rectangle:Rectangle, out:Vector.<Point> = null) : Vector.<Point> {
			var _local3:int = 0;
			if(out == null) {
				out = new Vector.<Point>(4,true);
			}
			_local3 = 0;
			while(_local3 < 4) {
				if(out[_local3] == null) {
					out[_local3] = new Point();
				}
				_local3++;
			}
			out[0].x = rectangle.left;
			out[0].y = rectangle.top;
			out[1].x = rectangle.right;
			out[1].y = rectangle.top;
			out[2].x = rectangle.left;
			out[2].y = rectangle.bottom;
			out[3].x = rectangle.right;
			out[3].y = rectangle.bottom;
			return out;
		}
		
		public static function compare(r1:Rectangle, r2:Rectangle, e:Number = 0.0001) : Boolean {
			if(r1 == null) {
				return r2 == null;
			}
			if(r2 == null) {
				return false;
			}
			return r1.x > r2.x - e && r1.x < r2.x + e && r1.y > r2.y - e && r1.y < r2.y + e && r1.width > r2.width - e && r1.width < r2.width + e && r1.height > r2.height - e && r1.height < r2.height + e;
		}
	}
}

