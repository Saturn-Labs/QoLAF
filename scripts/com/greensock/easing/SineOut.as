package com.greensock.easing {
	public final class SineOut extends Ease {
		private static const _HALF_PI:Number = 1.5707963267948966;
		
		public static var ease:SineOut = new SineOut();
		
		public function SineOut() {
			super();
		}
		
		override public function getRatio(p:Number) : Number {
			return Math.sin(p * 1.5707963267948966);
		}
	}
}

