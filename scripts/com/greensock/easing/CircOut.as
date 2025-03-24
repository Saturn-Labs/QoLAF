package com.greensock.easing {
	public final class CircOut extends Ease {
		public static var ease:CircOut = new CircOut();
		
		public function CircOut() {
			super();
		}
		
		override public function getRatio(p:Number) : Number {
			return Math.sqrt(1 - (p -= 1) * p);
		}
	}
}

