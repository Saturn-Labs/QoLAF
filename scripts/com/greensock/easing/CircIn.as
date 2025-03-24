package com.greensock.easing {
	public final class CircIn extends Ease {
		public static var ease:CircIn = new CircIn();
		
		public function CircIn() {
			super();
		}
		
		override public function getRatio(p:Number) : Number {
			return -(Math.sqrt(1 - p * p) - 1);
		}
	}
}

