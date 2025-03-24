package com.hurlant.math {
	use namespace bi_internal;
	
	internal class BarrettReduction implements IReduction {
		private var m:BigInteger;
		
		private var r2:BigInteger;
		
		private var q3:BigInteger;
		
		private var mu:BigInteger;
		
		public function BarrettReduction(m:BigInteger) {
			super();
			r2 = new BigInteger();
			q3 = new BigInteger();
			BigInteger.ONE.bi_internal::dlShiftTo(2 * m.t,r2);
			mu = r2.divide(m);
			this.m = m;
		}
		
		public function revert(x:BigInteger) : BigInteger {
			return x;
		}
		
		public function mulTo(x:BigInteger, y:BigInteger, r:BigInteger) : void {
			x.bi_internal::multiplyTo(y,r);
			reduce(r);
		}
		
		public function sqrTo(x:BigInteger, r:BigInteger) : void {
			x.bi_internal::squareTo(r);
			reduce(r);
		}
		
		public function convert(x:BigInteger) : BigInteger {
			var _local2:BigInteger = null;
			if(x.bi_internal::s < 0 || x.t > 2 * m.t) {
				return x.mod(m);
			}
			if(x.compareTo(m) < 0) {
				return x;
			}
			_local2 = new BigInteger();
			x.bi_internal::copyTo(_local2);
			reduce(_local2);
			return _local2;
		}
		
		public function reduce(lx:BigInteger) : void {
			var _local2:BigInteger = lx as BigInteger;
			_local2.bi_internal::drShiftTo(m.t - 1,r2);
			if(_local2.t > m.t + 1) {
				_local2.t = m.t + 1;
				_local2.bi_internal::clamp();
			}
			mu.bi_internal::multiplyUpperTo(r2,m.t + 1,q3);
			m.bi_internal::multiplyLowerTo(q3,m.t + 1,r2);
			while(_local2.compareTo(r2) < 0) {
				_local2.bi_internal::dAddOffset(1,m.t + 1);
			}
			_local2.bi_internal::subTo(r2,_local2);
			while(_local2.compareTo(m) >= 0) {
				_local2.bi_internal::subTo(m,_local2);
			}
		}
	}
}

