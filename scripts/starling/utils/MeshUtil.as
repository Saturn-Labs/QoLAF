package starling.utils {
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import starling.display.DisplayObject;
	import starling.display.Stage;
	import starling.errors.AbstractClassError;
	import starling.rendering.IndexData;
	import starling.rendering.VertexData;
	
	public class MeshUtil {
		private static var sPoint3D:Vector3D = new Vector3D();
		
		private static var sMatrix:Matrix = new Matrix();
		
		private static var sMatrix3D:Matrix3D = new Matrix3D();
		
		public function MeshUtil() {
			super();
			throw new AbstractClassError();
		}
		
		public static function containsPoint(vertexData:VertexData, indexData:IndexData, point:Point) : Boolean {
			var _local9:int = 0;
			var _local4:Boolean = false;
			var _local7:int = indexData.numIndices;
			var _local5:Point = Pool.getPoint();
			var _local6:Point = Pool.getPoint();
			var _local8:Point = Pool.getPoint();
			_local9 = 0;
			while(_local9 < _local7) {
				vertexData.getPoint(indexData.getIndex(_local9),"position",_local5);
				vertexData.getPoint(indexData.getIndex(_local9 + 1),"position",_local6);
				vertexData.getPoint(indexData.getIndex(_local9 + 2),"position",_local8);
				if(MathUtil.isPointInTriangle(point,_local5,_local6,_local8)) {
					_local4 = true;
					break;
				}
				_local9 += 3;
			}
			Pool.putPoint(_local5);
			Pool.putPoint(_local6);
			Pool.putPoint(_local8);
			return _local4;
		}
		
		public static function calculateBounds(vertexData:VertexData, sourceSpace:DisplayObject, targetSpace:DisplayObject, out:Rectangle = null) : Rectangle {
			if(out == null) {
				out = new Rectangle();
			}
			var _local5:Stage = sourceSpace.stage;
			if(sourceSpace.is3D && _local5) {
				_local5.getCameraPosition(targetSpace,sPoint3D);
				sourceSpace.getTransformationMatrix3D(targetSpace,sMatrix3D);
				vertexData.getBoundsProjected("position",sMatrix3D,sPoint3D,0,-1,out);
			} else {
				sourceSpace.getTransformationMatrix(targetSpace,sMatrix);
				vertexData.getBounds("position",sMatrix,0,-1,out);
			}
			return out;
		}
	}
}

