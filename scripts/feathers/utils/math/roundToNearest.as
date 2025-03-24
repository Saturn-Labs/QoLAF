package feathers.utils.math {
	public function roundToNearest(number:Number, nearest:Number = 1) : Number {
		if(nearest == 0) {
			return number;
		}
		var _local3:Number = Math.round(roundToPrecision(number / nearest,10)) * nearest;
		return roundToPrecision(_local3,10);
	}
}

