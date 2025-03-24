package com.greensock.easing {
	public final class CircInOut extends Ease {
		public static var ease:CircInOut = new CircInOut();
		
		public function CircInOut() {
			super();
		}
		
		override public function getRatio(p:Number) : Number {
			p *= 2;
			return p < 1 ? -0.5 * (Math.sqrt(1 - p * p) - 1) : 0.5 * (Math.sqrt(1 - (p -= 2) * p) + 1);
		}
	}
}

