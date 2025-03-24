package starling.utils {
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import starling.errors.AbstractClassError;
	
	public class Pool {
		private static var sPoints:Vector.<Point> = new Vector.<Point>(0);
		
		private static var sPoints3D:Vector.<Vector3D> = new Vector.<Vector3D>(0);
		
		private static var sMatrices:Vector.<Matrix> = new Vector.<Matrix>(0);
		
		private static var sMatrices3D:Vector.<Matrix3D> = new Vector.<Matrix3D>(0);
		
		private static var sRectangles:Vector.<Rectangle> = new Vector.<Rectangle>(0);
		
		public function Pool() {
			super();
			throw new AbstractClassError();
		}
		
		public static function getPoint(x:Number = 0, y:Number = 0) : Point {
			var _local3:Point = null;
			if(sPoints.length == 0) {
				return new Point(x,y);
			}
			_local3 = sPoints.pop();
			_local3.x = x;
			_local3.y = y;
			return _local3;
		}
		
		public static function putPoint(point:Point) : void {
			if(point) {
				sPoints[sPoints.length] = point;
			}
		}
		
		public static function getPoint3D(x:Number = 0, y:Number = 0, z:Number = 0) : Vector3D {
			var _local4:Vector3D = null;
			if(sPoints3D.length == 0) {
				return new Vector3D(x,y,z);
			}
			_local4 = sPoints3D.pop();
			_local4.x = x;
			_local4.y = y;
			_local4.z = z;
			return _local4;
		}
		
		public static function putPoint3D(point:Vector3D) : void {
			if(point) {
				sPoints3D[sPoints3D.length] = point;
			}
		}
		
		public static function getMatrix(a:Number = 1, b:Number = 0, c:Number = 0, d:Number = 1, tx:Number = 0, ty:Number = 0) : Matrix {
			var _local7:Matrix = null;
			if(sMatrices.length == 0) {
				return new Matrix(a,b,c,d,tx,ty);
			}
			_local7 = sMatrices.pop();
			_local7.setTo(a,b,c,d,tx,ty);
			return _local7;
		}
		
		public static function putMatrix(matrix:Matrix) : void {
			if(matrix) {
				sMatrices[sMatrices.length] = matrix;
			}
		}
		
		public static function getMatrix3D(identity:Boolean = true) : Matrix3D {
			var _local2:Matrix3D = null;
			if(sMatrices3D.length == 0) {
				return new Matrix3D();
			}
			_local2 = sMatrices3D.pop();
			if(identity) {
				_local2.identity();
			}
			return _local2;
		}
		
		public static function putMatrix3D(matrix:Matrix3D) : void {
			if(matrix) {
				sMatrices3D[sMatrices3D.length] = matrix;
			}
		}
		
		public static function getRectangle(x:Number = 0, y:Number = 0, width:Number = 0, height:Number = 0) : Rectangle {
			var _local5:Rectangle = null;
			if(sRectangles.length == 0) {
				return new Rectangle(x,y,width,height);
			}
			_local5 = sRectangles.pop();
			_local5.setTo(x,y,width,height);
			return _local5;
		}
		
		public static function putRectangle(rectangle:Rectangle) : void {
			if(rectangle) {
				sRectangles[sRectangles.length] = rectangle;
			}
		}
	}
}

