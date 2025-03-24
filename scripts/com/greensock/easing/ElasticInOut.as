package com.greensock.easing {
	public final class ElasticInOut extends Ease {
		private static const _2PI:Number = 6.283185307179586;
		
		public static var ease:ElasticInOut = new ElasticInOut();
		
		public function ElasticInOut(amplitude:Number = 1, period:Number = 0.3) {
			super();
			_p1 = amplitude || 1;
			_p2 = period || 0.45;
			_p3 = _p2 / 6.283185307179586 * (Math.asin(1 / _p1) || 0);
		}
		
		override public function getRatio(p:Number) : Number {
			p *= 2;
			return p < 1 ? -0.5 * (_p1 * Math.pow(2,10 * (p -= 1)) * Math.sin((p - _p3) * 6.283185307179586 / _p2)) : _p1 * Math.pow(2,-10 * (p -= 1)) * Math.sin((p - _p3) * 6.283185307179586 / _p2) * 0.5 + 1;
		}
		
		public function config(amplitude:Number = 1, period:Number = 0.3) : ElasticInOut {
			return new ElasticInOut(amplitude,period);
		}
	}
}

