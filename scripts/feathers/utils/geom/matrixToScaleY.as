package feathers.utils.geom {
	import flash.geom.Matrix;
	
	public function matrixToScaleY(matrix:Matrix) : Number {
		var _local2:Number = matrix.c;
		var _local3:Number = matrix.d;
		return Math.sqrt(_local2 * _local2 + _local3 * _local3);
	}
}

