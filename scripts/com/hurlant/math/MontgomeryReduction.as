package com.hurlant.math {
	use namespace bi_internal;
	
	internal class MontgomeryReduction implements IReduction {
		private var m:BigInteger;
		
		private var mp:int;
		
		private var mpl:int;
		
		private var mph:int;
		
		private var um:int;
		
		private var mt2:int;
		
		public function MontgomeryReduction(m:BigInteger) {
			super();
			this.m = m;
			mp = m.bi_internal::invDigit();
			mpl = mp & 0x7FFF;
			mph = mp >> 15;
			um = 0x7fff;
			mt2 = 2 * m.t;
		}
		
		public function convert(x:BigInteger) : BigInteger {
			var _local2:BigInteger = new BigInteger();
			x.abs().bi_internal::dlShiftTo(m.t,_local2);
			_local2.bi_internal::divRemTo(m,null,_local2);
			if(x.bi_internal::s < 0 && _local2.compareTo(BigInteger.ZERO) > 0) {
				m.bi_internal::subTo(_local2,_local2);
			}
			return _local2;
		}
		
		public function revert(x:BigInteger) : BigInteger {
			var _local2:BigInteger = new BigInteger();
			x.bi_internal::copyTo(_local2);
			reduce(_local2);
			return _local2;
		}
		
		public function reduce(x:BigInteger) : void {
			var _local2:int = 0;
			var _local3:* = 0;
			var _local4:* = 0;
			while(x.t <= mt2) {
				x.bi_internal::a[x.t++] = 0;
			}
			_local2 = 0;
			while(_local2 < m.t) {
				_local3 = x.bi_internal::a[_local2] & 0x7FFF;
				_local4 = _local3 * mpl + ((_local3 * mph + (x.bi_internal::a[_local2] >> 15) * mpl & um) << 15) & 0x3FFFFFFF;
				_local3 = _local2 + m.t;
				x.bi_internal::a[_local3] += m.bi_internal::am(0,_local4,x,_local2,0,m.t);
				while(x.bi_internal::a[_local3] >= 0x40000000) {
					var _local6:* = _local3;
					var _local5:* = x.bi_internal::a[_local6] - 0x40000000;
					x.bi_internal::a[_local6] = _local5;
					_local3++;
					x.bi_internal::a[_local3]++;
				}
				_local2++;
			}
			x.bi_internal::clamp();
			x.bi_internal::drShiftTo(m.t,x);
			if(x.compareTo(m) >= 0) {
				x.bi_internal::subTo(m,x);
			}
		}
		
		public function sqrTo(x:BigInteger, r:BigInteger) : void {
			x.bi_internal::squareTo(r);
			reduce(r);
		}
		
		public function mulTo(x:BigInteger, y:BigInteger, r:BigInteger) : void {
			x.bi_internal::multiplyTo(y,r);
			reduce(r);
		}
	}
}

