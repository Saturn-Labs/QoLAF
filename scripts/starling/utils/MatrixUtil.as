package starling.utils {
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import starling.errors.AbstractClassError;
	
	public class MatrixUtil {
		private static var sRawData:Vector.<Number> = new <Number>[1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1];
		
		private static var sRawData2:Vector.<Number> = new Vector.<Number>(16,true);
		
		private static var sPoint3D:Vector3D = new Vector3D();
		
		private static var sMatrixData:Vector.<Number> = new <Number>[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
		
		public function MatrixUtil() {
			super();
			throw new AbstractClassError();
		}
		
		public static function convertTo3D(matrix:Matrix, out:Matrix3D = null) : Matrix3D {
			if(out == null) {
				out = new Matrix3D();
			}
			sRawData[0] = matrix.a;
			sRawData[1] = matrix.b;
			sRawData[4] = matrix.c;
			sRawData[5] = matrix.d;
			sRawData[12] = matrix.tx;
			sRawData[13] = matrix.ty;
			out.copyRawDataFrom(sRawData);
			return out;
		}
		
		public static function convertTo2D(matrix3D:Matrix3D, out:Matrix = null) : Matrix {
			if(out == null) {
				out = new Matrix();
			}
			matrix3D.copyRawDataTo(sRawData2);
			out.a = sRawData2[0];
			out.b = sRawData2[1];
			out.c = sRawData2[4];
			out.d = sRawData2[5];
			out.tx = sRawData2[12];
			out.ty = sRawData2[13];
			return out;
		}
		
		public static function isIdentity(matrix:Matrix) : Boolean {
			return matrix.a == 1 && matrix.b == 0 && matrix.c == 0 && matrix.d == 1 && matrix.tx == 0 && matrix.ty == 0;
		}
		
		public static function isIdentity3D(matrix:Matrix3D) : Boolean {
			var _local2:Vector.<Number> = sRawData2;
			matrix.copyRawDataTo(_local2);
			return _local2[0] == 1 && _local2[1] == 0 && _local2[2] == 0 && _local2[3] == 0 && _local2[4] == 0 && _local2[5] == 1 && _local2[6] == 0 && _local2[7] == 0 && _local2[8] == 0 && _local2[9] == 0 && _local2[10] == 1 && _local2[11] == 0 && _local2[12] == 0 && _local2[13] == 0 && _local2[14] == 0 && _local2[15] == 1;
		}
		
		public static function transformPoint(matrix:Matrix, point:Point, out:Point = null) : Point {
			return transformCoords(matrix,point.x,point.y,out);
		}
		
		public static function transformPoint3D(matrix:Matrix3D, point:Vector3D, out:Vector3D = null) : Vector3D {
			return transformCoords3D(matrix,point.x,point.y,point.z,out);
		}
		
		public static function transformCoords(matrix:Matrix, x:Number, y:Number, out:Point = null) : Point {
			if(out == null) {
				out = new Point();
			}
			out.x = matrix.a * x + matrix.c * y + matrix.tx;
			out.y = matrix.d * y + matrix.b * x + matrix.ty;
			return out;
		}
		
		public static function transformCoords3D(matrix:Matrix3D, x:Number, y:Number, z:Number, out:Vector3D = null) : Vector3D {
			if(out == null) {
				out = new Vector3D();
			}
			matrix.copyRawDataTo(sRawData2);
			out.x = x * sRawData2[0] + y * sRawData2[4] + z * sRawData2[8] + sRawData2[12];
			out.y = x * sRawData2[1] + y * sRawData2[5] + z * sRawData2[9] + sRawData2[13];
			out.z = x * sRawData2[2] + y * sRawData2[6] + z * sRawData2[10] + sRawData2[14];
			out.w = x * sRawData2[3] + y * sRawData2[7] + z * sRawData2[11] + sRawData2[15];
			return out;
		}
		
		public static function skew(matrix:Matrix, skewX:Number, skewY:Number) : void {
			var _local5:Number = Math.sin(skewX);
			var _local7:Number = Math.cos(skewX);
			var _local4:Number = Math.sin(skewY);
			var _local6:Number = Math.cos(skewY);
			matrix.setTo(matrix.a * _local6 - matrix.b * _local5,matrix.a * _local4 + matrix.b * _local7,matrix.c * _local6 - matrix.d * _local5,matrix.c * _local4 + matrix.d * _local7,matrix.tx * _local6 - matrix.ty * _local5,matrix.tx * _local4 + matrix.ty * _local7);
		}
		
		public static function prependMatrix(base:Matrix, prep:Matrix) : void {
			base.setTo(base.a * prep.a + base.c * prep.b,base.b * prep.a + base.d * prep.b,base.a * prep.c + base.c * prep.d,base.b * prep.c + base.d * prep.d,base.tx + base.a * prep.tx + base.c * prep.ty,base.ty + base.b * prep.tx + base.d * prep.ty);
		}
		
		public static function prependTranslation(matrix:Matrix, tx:Number, ty:Number) : void {
			matrix.tx += matrix.a * tx + matrix.c * ty;
			matrix.ty += matrix.b * tx + matrix.d * ty;
		}
		
		public static function prependScale(matrix:Matrix, sx:Number, sy:Number) : void {
			matrix.setTo(matrix.a * sx,matrix.b * sx,matrix.c * sy,matrix.d * sy,matrix.tx,matrix.ty);
		}
		
		public static function prependRotation(matrix:Matrix, angle:Number) : void {
			var _local4:Number = Math.sin(angle);
			var _local3:Number = Math.cos(angle);
			matrix.setTo(matrix.a * _local3 + matrix.c * _local4,matrix.b * _local3 + matrix.d * _local4,matrix.c * _local3 - matrix.a * _local4,matrix.d * _local3 - matrix.b * _local4,matrix.tx,matrix.ty);
		}
		
		public static function prependSkew(matrix:Matrix, skewX:Number, skewY:Number) : void {
			var _local5:Number = Math.sin(skewX);
			var _local7:Number = Math.cos(skewX);
			var _local4:Number = Math.sin(skewY);
			var _local6:Number = Math.cos(skewY);
			matrix.setTo(matrix.a * _local6 + matrix.c * _local4,matrix.b * _local6 + matrix.d * _local4,matrix.c * _local7 - matrix.a * _local5,matrix.d * _local7 - matrix.b * _local5,matrix.tx,matrix.ty);
		}
		
		public static function toString3D(matrix:Matrix3D, transpose:Boolean = true, precision:int = 3) : String {
			if(transpose) {
				matrix.transpose();
			}
			matrix.copyRawDataTo(sRawData2);
			if(transpose) {
				matrix.transpose();
			}
			return "[Matrix3D rawData=\n" + formatRawData(sRawData2,4,4,precision) + "\n]";
		}
		
		public static function toString(matrix:Matrix, precision:int = 3) : String {
			sRawData2[0] = matrix.a;
			sRawData2[1] = matrix.c;
			sRawData2[2] = matrix.tx;
			sRawData2[3] = matrix.b;
			sRawData2[4] = matrix.d;
			sRawData2[5] = matrix.ty;
			return "[Matrix rawData=\n" + formatRawData(sRawData2,3,2,precision) + "\n]";
		}
		
		private static function formatRawData(data:Vector.<Number>, numCols:int, numRows:int, precision:int, indent:String = "  ") : String {
			var _local10:String = null;
			var _local14:Number = NaN;
			var _local6:int = 0;
			var _local12:int = 0;
			var _local11:int = 0;
			var _local9:* = indent;
			var _local7:int = numCols * numRows;
			var _local13:* = 0;
			_local6 = 0;
			while(_local6 < _local7) {
				_local14 = Math.abs(data[_local6]);
				if(_local14 > _local13) {
					_local13 = _local14;
				}
				_local6++;
			}
			var _local8:int = _local13.toFixed(precision).length + 1;
			_local12 = 0;
			while(_local12 < numRows) {
				_local11 = 0;
				while(_local11 < numCols) {
					_local14 = data[numCols * _local12 + _local11];
					_local10 = _local14.toFixed(precision);
					while(_local10.length < _local8) {
						_local10 = " " + _local10;
					}
					_local9 += _local10;
					if(_local11 != numCols - 1) {
						_local9 += ", ";
					}
					_local11++;
				}
				if(_local12 != numRows - 1) {
					_local9 += "\n" + indent;
				}
				_local12++;
			}
			return _local9;
		}
		
		public static function snapToPixels(matrix:Matrix, pixelSize:Number) : void {
			var _local6:Number = NaN;
			_local6 = 0.0001;
			var _local4:Number = NaN;
			var _local3:Number = NaN;
			var _local5:Number = NaN;
			var _local8:Number = NaN;
			var _local7:Boolean = false;
			if(matrix.b + 0.0001 > 0 && matrix.b - 0.0001 < 0 && matrix.c + 0.0001 > 0 && matrix.c - 0.0001 < 0) {
				_local8 = matrix.a * matrix.a;
				_local5 = matrix.d * matrix.d;
				_local7 = _local8 + 0.0001 > 1 && _local8 - 0.0001 < 1 && _local5 + 0.0001 > 1 && _local5 - 0.0001 < 1;
			} else if(matrix.a + 0.0001 > 0 && matrix.a - 0.0001 < 0 && matrix.d + 0.0001 > 0 && matrix.d - 0.0001 < 0) {
				_local4 = matrix.b * matrix.b;
				_local3 = matrix.c * matrix.c;
				_local7 = _local4 + 0.0001 > 1 && _local4 - 0.0001 < 1 && _local3 + 0.0001 > 1 && _local3 - 0.0001 < 1;
			}
			if(_local7) {
				matrix.tx = Math.round(matrix.tx / pixelSize) * pixelSize;
				matrix.ty = Math.round(matrix.ty / pixelSize) * pixelSize;
			}
		}
		
		public static function createPerspectiveProjectionMatrix(x:Number, y:Number, width:Number, height:Number, stageWidth:Number = 0, stageHeight:Number = 0, cameraPos:Vector3D = null, out:Matrix3D = null) : Matrix3D {
			var _local14:Number = NaN;
			_local14 = 1;
			if(out == null) {
				out = new Matrix3D();
			}
			if(stageWidth <= 0) {
				stageWidth = width;
			}
			if(stageHeight <= 0) {
				stageHeight = height;
			}
			if(cameraPos == null) {
				cameraPos = sPoint3D;
				cameraPos.setTo(stageWidth / 2,stageHeight / 2,stageWidth / Math.tan(0.5) * 0.5);
			}
			var _local15:Number = Math.abs(cameraPos.z);
			var _local9:Number = cameraPos.x - stageWidth / 2;
			var _local12:Number = cameraPos.y - stageHeight / 2;
			var _local13:Number = _local15 * 20;
			var _local10:Number = stageWidth / width;
			var _local11:Number = stageHeight / height;
			sMatrixData[0] = 2 * _local15 / stageWidth;
			sMatrixData[5] = -2 * _local15 / stageHeight;
			sMatrixData[10] = _local13 / (_local13 - 1);
			sMatrixData[14] = -_local13 * 1 / (_local13 - 1);
			sMatrixData[11] = 1;
			sMatrixData[0] *= _local10;
			sMatrixData[5] *= _local11;
			sMatrixData[8] = _local10 - 1 - 2 * _local10 * (x - _local9) / stageWidth;
			sMatrixData[9] = -_local11 + 1 + 2 * _local11 * (y - _local12) / stageHeight;
			out.copyRawDataFrom(sMatrixData);
			out.prependTranslation(-stageWidth / 2 - _local9,-stageHeight / 2 - _local12,_local15);
			return out;
		}
		
		public static function createOrthographicProjectionMatrix(x:Number, y:Number, width:Number, height:Number, out:Matrix = null) : Matrix {
			if(out == null) {
				out = new Matrix();
			}
			out.setTo(2 / width,0,0,-2 / height,-(2 * x + width) / width,(2 * y + height) / height);
			return out;
		}
	}
}

