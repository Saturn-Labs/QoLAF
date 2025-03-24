package feathers.utils.math {
	public function clamp(value:Number, minimum:Number, maximum:Number) : Number {
		if(minimum > maximum) {
			throw new ArgumentError("minimum should be smaller than maximum.");
		}
		if(value < minimum) {
			value = minimum;
		} else if(value > maximum) {
			value = maximum;
		}
		return value;
	}
}

