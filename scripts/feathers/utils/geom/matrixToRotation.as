package feathers.utils.geom {
	import flash.geom.Matrix;
	
	public function matrixToRotation(matrix:Matrix) : Number {
		var _local2:Number = matrix.c;
		var _local3:Number = matrix.d;
		return -Math.atan(_local2 / _local3);
	}
}

