package com.greensock.easing {
	public final class ElasticOut extends Ease {
		private static const _2PI:Number = 6.283185307179586;
		
		public static var ease:ElasticOut = new ElasticOut();
		
		public function ElasticOut(amplitude:Number = 1, period:Number = 0.3) {
			super();
			_p1 = amplitude || 1;
			_p2 = period || 0.3;
			_p3 = _p2 / 6.283185307179586 * (Math.asin(1 / _p1) || 0);
		}
		
		override public function getRatio(p:Number) : Number {
			return _p1 * Math.pow(2,-10 * p) * Math.sin((p - _p3) * 6.283185307179586 / _p2) + 1;
		}
		
		public function config(amplitude:Number = 1, period:Number = 0.3) : ElasticOut {
			return new ElasticOut(amplitude,period);
		}
	}
}

