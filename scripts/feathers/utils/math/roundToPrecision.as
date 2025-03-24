package feathers.utils.math {
	public function roundToPrecision(number:Number, precision:int = 0) : Number {
		var _local3:Number = Math.pow(10,precision);
		return Math.round(_local3 * number) / _local3;
	}
}

