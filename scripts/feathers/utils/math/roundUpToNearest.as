package feathers.utils.math {
	public function roundUpToNearest(number:Number, nearest:Number = 1) : Number {
		if(nearest == 0) {
			return number;
		}
		return Math.ceil(roundToPrecision(number / nearest,10)) * nearest;
	}
}

