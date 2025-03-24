package feathers.utils.geom {
	import flash.geom.Matrix;
	
	public function matrixToScaleX(matrix:Matrix) : Number {
		var _local2:Number = matrix.a;
		var _local3:Number = matrix.b;
		return Math.sqrt(_local2 * _local2 + _local3 * _local3);
	}
}

