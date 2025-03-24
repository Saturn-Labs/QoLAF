package feathers.utils.math {
	public function roundDownToNearest(number:Number, nearest:Number = 1) : Number {
		if(nearest == 0) {
			return number;
		}
		return Math.floor(roundToPrecision(number / nearest,10)) * nearest;
	}
}

