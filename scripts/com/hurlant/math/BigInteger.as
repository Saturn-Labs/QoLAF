package com.hurlant.math {
	import com.hurlant.crypto.prng.Random;
	import com.hurlant.util.Hex;
	import com.hurlant.util.Memory;
	import flash.utils.ByteArray;
	
	use namespace bi_internal;
	
	public class BigInteger {
		public static const DB:int = 30;
		
		public static const DV:int = 1073741824;
		
		public static const DM:int = 1073741823;
		
		public static const BI_FP:int = 52;
		
		public static const F1:int = 22;
		
		public static const F2:int = 8;
		
		public static const FV:Number = Math.pow(2,52);
		
		public static const ZERO:BigInteger = nbv(0);
		
		public static const ONE:BigInteger = nbv(1);
		
		public static const lowprimes:Array = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,101,103,107,109,113,127,131,137,139,149,151,157,163,167,173,179,181,191,193,197,199,211,223,227,229,233,239,241,251,257,263,269,271,277,281,283,293,307,311,313,317,331,337,347,349,353,359,367,373,379,383,389,397,401,409,419,421,431,433,439,443,449,457,461,463,467,479,487,491,499,503,509];
		
		public static const lplim:int = 0x4000000 / lowprimes[lowprimes.length - 1];
		
		public var t:int;
		
		bi_internal var s:int;
		
		bi_internal var a:Array;
		
		public function BigInteger(value:* = null, radix:int = 0) {
			var _local3:ByteArray = null;
			var _local4:int = 0;
			super();
			bi_internal::a = [];
			if(value is String) {
				value = Hex.toArray(value);
				radix = 0;
			}
			if(value is ByteArray) {
				_local3 = value as ByteArray;
				_local4 = int(radix || _local3.length - _local3.position);
				bi_internal::fromArray(_local3,_local4);
			}
		}
		
		public static function nbv(value:int) : BigInteger {
			var _local2:BigInteger = new BigInteger();
			_local2.bi_internal::fromInt(value);
			return _local2;
		}
		
		public function dispose() : void {
			var _local2:* = 0;
			var _local1:Random = new Random();
			_local2 = 0;
			while(_local2 < bi_internal::a.length) {
				bi_internal::a[_local2] = _local1.nextByte();
				delete bi_internal::a[_local2];
				_local2++;
			}
			bi_internal::a = null;
			t = 0;
			bi_internal::s = 0;
			Memory.gc();
		}
		
		public function toString(radix:Number = 16) : String {
			var _local7:int = 0;
			if(bi_internal::s < 0) {
				return "-" + negate().toString(radix);
			}
			switch(radix) {
				case 2:
					_local7 = 1;
					break;
				case 4:
					_local7 = 2;
					break;
				case 8:
					_local7 = 3;
					break;
				case 16:
					_local7 = 4;
					break;
				case 32:
					_local7 = 5;
			}
			var _local3:int = (1 << _local7) - 1;
			var _local5:* = 0;
			var _local8:Boolean = false;
			var _local4:String = "";
			var _local6:int = t;
			var _local2:int = 30 - _local6 * 30 % _local7;
			if(_local6-- > 0) {
				if(_local2 < 30 && (_local5 = bi_internal::a[_local6] >> _local2) > 0) {
					_local8 = true;
					_local4 = _local5.toString(36);
				}
				while(_local6 >= 0) {
					if(_local2 < _local7) {
						_local6--;
						_local5 = (bi_internal::a[_local6] & (1 << _local2) - 1) << _local7 - _local2;
						_local5 = _local5 | bi_internal::a[_local6] >> (_local2 += 30 - _local7);
					} else {
						_local5 = bi_internal::a[_local6] >> (_local2 -= _local7) & _local3;
						if(_local2 <= 0) {
							_local2 += 30;
							_local6--;
						}
					}
					if(_local5 > 0) {
						_local8 = true;
					}
					if(_local8) {
						_local4 += _local5.toString(36);
					}
				}
			}
			return _local8 ? _local4 : "0";
		}
		
		public function toArray(array:ByteArray) : uint {
			var _local7:int = 0;
			_local7 = 8;
			var _local3:int = 0;
			_local3 = 255;
			var _local5:* = 0;
			var _local6:int = t;
			var _local2:int = 30 - _local6 * 30 % 8;
			var _local8:Boolean = false;
			var _local4:int = 0;
			if(_local6-- > 0) {
				if(_local2 < 30 && (_local5 = bi_internal::a[_local6] >> _local2) > 0) {
					_local8 = true;
					array.writeByte(_local5);
					_local4++;
				}
				while(_local6 >= 0) {
					if(_local2 < 8) {
						_local6--;
						_local5 = (bi_internal::a[_local6] & (1 << _local2) - 1) << 8 - _local2;
						_local5 = _local5 | bi_internal::a[_local6] >> (_local2 += 30 - 8);
					} else {
						_local5 = bi_internal::a[_local6] >> (_local2 -= 8) & 0xFF;
						if(_local2 <= 0) {
							_local2 += 30;
							_local6--;
						}
					}
					if(_local5 > 0) {
						_local8 = true;
					}
					if(_local8) {
						array.writeByte(_local5);
						_local4++;
					}
				}
			}
			return _local4;
		}
		
		public function valueOf() : Number {
			var _local2:* = 0;
			var _local1:Number = 1;
			var _local3:Number = 0;
			_local2 = 0;
			while(_local2 < t) {
				_local3 += bi_internal::a[_local2] * _local1;
				_local1 *= 0x40000000;
				_local2++;
			}
			return _local3;
		}
		
		public function negate() : BigInteger {
			var _local1:BigInteger = nbi();
			ZERO.bi_internal::subTo(this,_local1);
			return _local1;
		}
		
		public function abs() : BigInteger {
			return bi_internal::s < 0 ? negate() : this;
		}
		
		public function compareTo(v:BigInteger) : int {
			var _local2:int = bi_internal::s - v.bi_internal::s;
			if(_local2 != 0) {
				return _local2;
			}
			var _local3:int = t;
			_local2 = _local3 - v.t;
			if(_local2 != 0) {
				return _local2;
			}
			while(true) {
				_local3--;
				if(_local3 < 0) {
					break;
				}
				_local2 = bi_internal::a[_local3] - v.bi_internal::a[_local3];
				if(_local2 != 0) {
					return _local2;
				}
			}
			return 0;
		}
		
		bi_internal function nbits(x:int) : int {
			var _local3:int = 0;
			var _local2:int = 1;
			_local3 = x >>> 16;
			if(_local3 != 0) {
				x = _local3;
				_local2 += 16;
			}
			_local3 = x >> 8;
			if(_local3 != 0) {
				x = _local3;
				_local2 += 8;
			}
			_local3 = x >> 4;
			if(_local3 != 0) {
				x = _local3;
				_local2 += 4;
			}
			_local3 = x >> 2;
			if(_local3 != 0) {
				x = _local3;
				_local2 += 2;
			}
			_local3 = x >> 1;
			if(_local3 != 0) {
				x = _local3;
				_local2 += 1;
			}
			return _local2;
		}
		
		public function bitLength() : int {
			if(t <= 0) {
				return 0;
			}
			return 30 * (t - 1) + bi_internal::nbits(bi_internal::a[t - 1] ^ bi_internal::s & 0x3FFFFFFF);
		}
		
		public function mod(v:BigInteger) : BigInteger {
			var _local2:BigInteger = nbi();
			abs().bi_internal::divRemTo(v,null,_local2);
			if(bi_internal::s < 0 && _local2.compareTo(ZERO) > 0) {
				v.bi_internal::subTo(_local2,_local2);
			}
			return _local2;
		}
		
		public function modPowInt(e:int, m:BigInteger) : BigInteger {
			var _local3:IReduction = null;
			if(e < 256 || m.bi_internal::isEven()) {
				_local3 = new ClassicReduction(m);
			} else {
				_local3 = new MontgomeryReduction(m);
			}
			return bi_internal::exp(e,_local3);
		}
		
		bi_internal function copyTo(r:BigInteger) : void {
			var _local2:int = 0;
			_local2 = t - 1;
			while(_local2 >= 0) {
				r.bi_internal::a[_local2] = bi_internal::a[_local2];
				_local2--;
			}
			r.t = t;
			r.bi_internal::s = bi_internal::s;
		}
		
		bi_internal function fromInt(value:int) : void {
			t = 1;
			bi_internal::s = value < 0 ? -1 : 0;
			if(value > 0) {
				bi_internal::a[0] = value;
			} else if(value < -1) {
				bi_internal::a[0] = value + 0x40000000;
			} else {
				t = 0;
			}
		}
		
		bi_internal function fromArray(value:ByteArray, length:int) : void {
			var _local7:int = 0;
			_local7 = 8;
			var _local5:int = 0;
			var _local3:int = int(value.position);
			var _local6:int = _local3 + length;
			var _local4:int = 0;
			t = 0;
			bi_internal::s = 0;
			while(true) {
				_local6--;
				if(_local6 < _local3) {
					break;
				}
				_local5 = int(_local6 < value.length ? value[_local6] : 0);
				if(_local4 == 0) {
					bi_internal::a[t++] = _local5;
				} else if(_local4 + 8 > 30) {
					var _local8:* = t - 1;
					var _local9:* = bi_internal::a[_local8] | (_local5 & (1 << 30 - _local4) - 1) << _local4;
					bi_internal::a[_local8] = _local9;
					bi_internal::a[t++] = _local5 >> 30 - _local4;
				} else {
					_local9 = t - 1;
					_local8 = bi_internal::a[_local9] | _local5 << _local4;
					bi_internal::a[_local9] = _local8;
				}
				_local4 += 8;
				if(_local4 >= 30) {
					_local4 -= 30;
				}
			}
			bi_internal::clamp();
			value.position = Math.min(_local3 + length,value.length);
		}
		
		bi_internal function clamp() : void {
			var _local1:* = bi_internal::s & 0x3FFFFFFF;
			while(t > 0 && bi_internal::a[t - 1] == _local1) {
				--t;
			}
		}
		
		bi_internal function dlShiftTo(n:int, r:BigInteger) : void {
			var _local3:int = 0;
			_local3 = t - 1;
			while(_local3 >= 0) {
				r.bi_internal::a[_local3 + n] = bi_internal::a[_local3];
				_local3--;
			}
			_local3 = n - 1;
			while(_local3 >= 0) {
				r.bi_internal::a[_local3] = 0;
				_local3--;
			}
			r.t = t + n;
			r.bi_internal::s = bi_internal::s;
		}
		
		bi_internal function drShiftTo(n:int, r:BigInteger) : void {
			var _local3:* = 0;
			_local3 = n;
			while(_local3 < t) {
				r.bi_internal::a[_local3 - n] = bi_internal::a[_local3];
				_local3++;
			}
			r.t = Math.max(t - n,0);
			r.bi_internal::s = bi_internal::s;
		}
		
		bi_internal function lShiftTo(n:int, r:BigInteger) : void {
			var _local6:int = 0;
			var _local3:int = n % 30;
			var _local5:int = 30 - _local3;
			var _local7:int = (1 << _local5) - 1;
			var _local8:int = n / 30;
			var _local4:* = bi_internal::s << _local3 & 0x3FFFFFFF;
			_local6 = t - 1;
			while(_local6 >= 0) {
				r.bi_internal::a[_local6 + _local8 + 1] = bi_internal::a[_local6] >> _local5 | _local4;
				_local4 = (bi_internal::a[_local6] & _local7) << _local3;
				_local6--;
			}
			_local6 = _local8 - 1;
			while(_local6 >= 0) {
				r.bi_internal::a[_local6] = 0;
				_local6--;
			}
			r.bi_internal::a[_local8] = _local4;
			r.t = t + _local8 + 1;
			r.bi_internal::s = bi_internal::s;
			r.bi_internal::clamp();
		}
		
		bi_internal function rShiftTo(n:int, r:BigInteger) : void {
			var _local5:int = 0;
			r.bi_internal::s = bi_internal::s;
			var _local7:int = n / 30;
			if(_local7 >= t) {
				r.t = 0;
				return;
			}
			var _local3:int = n % 30;
			var _local4:int = 30 - _local3;
			var _local6:int = (1 << _local3) - 1;
			r.bi_internal::a[0] = bi_internal::a[_local7] >> _local3;
			_local5 = _local7 + 1;
			while(_local5 < t) {
				var _local8:* = _local5 - _local7 - 1;
				var _local9:* = r.bi_internal::a[_local8] | (bi_internal::a[_local5] & _local6) << _local4;
				r.bi_internal::a[_local8] = _local9;
				r.bi_internal::a[_local5 - _local7] = bi_internal::a[_local5] >> _local3;
				_local5++;
			}
			if(_local3 > 0) {
				_local9 = t - _local7 - 1;
				_local8 = r.bi_internal::a[_local9] | (bi_internal::s & _local6) << _local4;
				r.bi_internal::a[_local9] = _local8;
			}
			r.t = t - _local7;
			r.bi_internal::clamp();
		}
		
		bi_internal function subTo(v:BigInteger, r:BigInteger) : void {
			var _local4:int = 0;
			var _local3:* = 0;
			var _local5:int = Math.min(v.t,t);
			while(_local4 < _local5) {
				_local3 += bi_internal::a[_local4] - v.bi_internal::a[_local4];
				r.bi_internal::a[_local4++] = _local3 & 0x3FFFFFFF;
				_local3 >>= 30;
			}
			if(v.t < t) {
				_local3 -= v.bi_internal::s;
				while(_local4 < t) {
					_local3 += bi_internal::a[_local4];
					r.bi_internal::a[_local4++] = _local3 & 0x3FFFFFFF;
					_local3 >>= 30;
				}
				_local3 += bi_internal::s;
			} else {
				_local3 += bi_internal::s;
				while(_local4 < v.t) {
					_local3 -= v.bi_internal::a[_local4];
					r.bi_internal::a[_local4++] = _local3 & 0x3FFFFFFF;
					_local3 >>= 30;
				}
				_local3 -= v.bi_internal::s;
			}
			r.bi_internal::s = _local3 < 0 ? -1 : 0;
			if(_local3 < -1) {
				r.bi_internal::a[_local4++] = 0x40000000 + _local3;
			} else if(_local3 > 0) {
				r.bi_internal::a[_local4++] = _local3;
			}
			r.t = _local4;
			r.bi_internal::clamp();
		}
		
		bi_internal function am(i:int, x:int, w:BigInteger, j:int, c:int, n:int) : int {
			var _local10:* = 0;
			var _local9:* = 0;
			var _local11:int = 0;
			var _local8:* = x & 0x7FFF;
			var _local7:* = x >> 15;
			while(true) {
				n--;
				if(n < 0) {
					break;
				}
				_local10 = bi_internal::a[i] & 0x7FFF;
				_local9 = bi_internal::a[i++] >> 15;
				_local11 = _local7 * _local10 + _local9 * _local8;
				_local10 = _local8 * _local10 + ((_local11 & 0x7FFF) << 15) + w.bi_internal::a[j] + (c & 0x3FFFFFFF);
				c = (_local10 >>> 30) + (_local11 >>> 15) + _local7 * _local9 + (c >>> 30);
				w.bi_internal::a[j++] = _local10 & 0x3FFFFFFF;
			}
			return c;
		}
		
		bi_internal function multiplyTo(v:BigInteger, r:BigInteger) : void {
			var _local3:BigInteger = abs();
			var _local4:BigInteger = v.abs();
			var _local5:int = _local3.t;
			r.t = _local5 + _local4.t;
			while(true) {
				_local5--;
				if(_local5 < 0) {
					break;
				}
				r.bi_internal::a[_local5] = 0;
			}
			_local5 = 0;
			while(_local5 < _local4.t) {
				r.bi_internal::a[_local5 + _local3.t] = _local3.bi_internal::am(0,_local4.bi_internal::a[_local5],r,_local5,0,_local3.t);
				_local5++;
			}
			r.bi_internal::s = 0;
			r.bi_internal::clamp();
			if(bi_internal::s != v.bi_internal::s) {
				ZERO.bi_internal::subTo(r,r);
			}
		}
		
		bi_internal function squareTo(r:BigInteger) : void {
			var _local2:int = 0;
			var _local3:BigInteger = abs();
			var _local4:* = r.t = 2 * _local3.t;
			while(true) {
				_local4--;
				if(_local4 < 0) {
					break;
				}
				r.bi_internal::a[_local4] = 0;
			}
			_local4 = 0;
			while(_local4 < _local3.t - 1) {
				_local2 = _local3.bi_internal::am(_local4,_local3.bi_internal::a[_local4],r,2 * _local4,0,1);
				r.bi_internal::a[_local4 + _local3.t] += _local3.bi_internal::am(_local4 + 1,2 * _local3.bi_internal::a[_local4],r,2 * _local4 + 1,_local2,_local3.t - _local4 - 1);
				if(_local6 >= 0x40000000) {
					var _local6:* = _local4 + _local3.t;
					var _local5:* = r.bi_internal::a[_local6] - 0x40000000;
					r.bi_internal::a[_local6] = _local5;
					r.bi_internal::a[_local4 + _local3.t + 1] = 1;
				}
				_local4++;
			}
			if(r.t > 0) {
				_local5 = r.t - 1;
				_local6 = r.bi_internal::a[_local5] + _local3.bi_internal::am(_local4,_local3.bi_internal::a[_local4],r,2 * _local4,0,1);
				r.bi_internal::a[_local5] = _local6;
			}
			r.bi_internal::s = 0;
			r.bi_internal::clamp();
		}
		
		bi_internal function divRemTo(m:BigInteger, q:BigInteger = null, r:BigInteger = null) : void {
			var _local12:int = 0;
			var _local18:BigInteger = m.abs();
			if(_local18.t <= 0) {
				return;
			}
			var _local5:BigInteger = abs();
			if(_local5.t < _local18.t) {
				if(q != null) {
					q.bi_internal::fromInt(0);
				}
				if(r != null) {
					bi_internal::copyTo(r);
				}
				return;
			}
			if(r == null) {
				r = nbi();
			}
			var _local15:BigInteger = nbi();
			var _local19:int = bi_internal::s;
			var _local7:int = m.bi_internal::s;
			var _local4:int = 30 - bi_internal::nbits(_local18.bi_internal::a[_local18.t - 1]);
			if(_local4 > 0) {
				_local18.bi_internal::lShiftTo(_local4,_local15);
				_local5.bi_internal::lShiftTo(_local4,r);
			} else {
				_local18.bi_internal::copyTo(_local15);
				_local5.bi_internal::copyTo(r);
			}
			var _local16:int = _local15.t;
			var _local14:int = int(_local15.bi_internal::a[_local16 - 1]);
			if(_local14 == 0) {
				return;
			}
			var _local17:Number = _local14 * (1 << 22) + (_local16 > 1 ? _local15.bi_internal::a[_local16 - 2] >> 8 : 0);
			var _local10:Number = FV / _local17;
			var _local11:Number = (1 << 22) / _local17;
			var _local6:Number = 256;
			var _local8:int = r.t;
			var _local9:int = _local8 - _local16;
			var _local13:BigInteger = q == null ? nbi() : q;
			_local15.bi_internal::dlShiftTo(_local9,_local13);
			if(r.compareTo(_local13) >= 0) {
				r.bi_internal::a[r.t++] = 1;
				r.bi_internal::subTo(_local13,r);
			}
			ONE.bi_internal::dlShiftTo(_local16,_local13);
			_local13.bi_internal::subTo(_local15,_local15);
			while(_local15.t < _local16) {
				_local15.(_local15.t++, false);
			}
			while(true) {
				_local9--;
				if(_local9 < 0) {
					break;
				}
				_local8--;
				_local12 = int(r.bi_internal::a[_local8] == _local14 ? 0x3fffffff : Number(r.bi_internal::a[_local8]) * _local10 + (Number(r.bi_internal::a[_local8 - 1]) + _local6) * _local11);
				r.bi_internal::a[_local8] += _local15.bi_internal::am(0,_local12,r,_local9,0,_local16);
				if(_local21 < _local12) {
					_local15.bi_internal::dlShiftTo(_local9,_local13);
					r.bi_internal::subTo(_local13,r);
					while(true) {
						_local12--;
						if(r.bi_internal::a[_local8] >= _local12) {
							break;
						}
						r.bi_internal::subTo(_local13,r);
					}
				}
			}
			if(q != null) {
				r.bi_internal::drShiftTo(_local16,q);
				if(_local19 != _local7) {
					ZERO.bi_internal::subTo(q,q);
				}
			}
			r.t = _local16;
			r.bi_internal::clamp();
			if(_local4 > 0) {
				r.bi_internal::rShiftTo(_local4,r);
			}
			if(_local19 < 0) {
				ZERO.bi_internal::subTo(r,r);
			}
		}
		
		bi_internal function invDigit() : int {
			if(t < 1) {
				return 0;
			}
			var _local1:int = int(bi_internal::a[0]);
			if((_local1 & 1) == 0) {
				return 0;
			}
			var _local2:* = _local1 & 3;
			_local2 = _local2 * (2 - (_local1 & 0x0F) * _local2) & 0x0F;
			_local2 = _local2 * (2 - (_local1 & 0xFF) * _local2) & 0xFF;
			_local2 = _local2 * (2 - ((_local1 & 0xFFFF) * _local2 & 0xFFFF)) & 0xFFFF;
			_local2 = _local2 * (2 - _local1 * _local2 % 0x40000000) % 0x40000000;
			return _local2 > 0 ? 0x40000000 - _local2 : -_local2;
		}
		
		bi_internal function isEven() : Boolean {
			return (t > 0 ? bi_internal::a[0] & 1 : bi_internal::s) == 0;
		}
		
		bi_internal function exp(e:int, z:IReduction) : BigInteger {
			var _local5:* = null;
			if(e > 4294967295 || e < 1) {
				return ONE;
			}
			var _local4:* = nbi();
			var _local3:* = nbi();
			var _local6:BigInteger = z.convert(this);
			var _local7:int = bi_internal::nbits(e) - 1;
			_local6.bi_internal::copyTo(_local4);
			while(true) {
				_local7--;
				if(_local7 < 0) {
					break;
				}
				z.sqrTo(_local4,_local3);
				if((e & 1 << _local7) > 0) {
					z.mulTo(_local3,_local6,_local4);
				} else {
					_local5 = _local4;
					_local4 = _local3;
					_local3 = _local5;
				}
			}
			return z.revert(_local4);
		}
		
		bi_internal function intAt(str:String, index:int) : int {
			return parseInt(str.charAt(index),36);
		}
		
		protected function nbi() : * {
			return new BigInteger();
		}
		
		public function clone() : BigInteger {
			var _local1:BigInteger = new BigInteger();
			this.bi_internal::copyTo(_local1);
			return _local1;
		}
		
		public function intValue() : int {
			if(bi_internal::s < 0) {
				if(t == 1) {
					return bi_internal::a[0] - 0x40000000;
				}
				if(t == 0) {
					return -1;
				}
			} else {
				if(t == 1) {
					return bi_internal::a[0];
				}
				if(t == 0) {
					return 0;
				}
			}
			return (bi_internal::a[1] & 3) << 30 | bi_internal::a[0];
		}
		
		public function byteValue() : int {
			return t == 0 ? bi_internal::s : bi_internal::a[0] << 24 >> 24;
		}
		
		public function shortValue() : int {
			return t == 0 ? bi_internal::s : bi_internal::a[0] << 16 >> 16;
		}
		
		protected function chunkSize(r:Number) : int {
			return Math.floor(0.6931471805599453 * 30 / Math.log(r));
		}
		
		public function sigNum() : int {
			if(bi_internal::s < 0) {
				return -1;
			}
			if(t <= 0 || t == 1 && bi_internal::a[0] <= 0) {
				return 0;
			}
			return 1;
		}
		
		protected function toRadix(b:uint = 10) : String {
			if(sigNum() == 0 || b < 2 || b > 32) {
				return "0";
			}
			var _local2:int = chunkSize(b);
			var _local3:Number = Math.pow(b,_local2);
			var _local5:BigInteger = nbv(_local3);
			var _local6:BigInteger = nbi();
			var _local7:BigInteger = nbi();
			var _local4:String = "";
			bi_internal::divRemTo(_local5,_local6,_local7);
			while(_local6.sigNum() > 0) {
				_local4 = (_local3 + _local7.intValue()).toString(b).substr(1) + _local4;
				_local6.bi_internal::divRemTo(_local5,_local6,_local7);
			}
			return _local7.intValue().toString(b) + _local4;
		}
		
		protected function fromRadix(s:String, b:int = 10) : void {
			var _local7:int = 0;
			var _local6:int = 0;
			bi_internal::fromInt(0);
			var _local3:int = chunkSize(b);
			var _local4:Number = Math.pow(b,_local3);
			var _local9:Boolean = false;
			var _local8:int = 0;
			var _local5:int = 0;
			_local7 = 0;
			while(_local7 < s.length) {
				_local6 = bi_internal::intAt(s,_local7);
				if(_local6 < 0) {
					if(s.charAt(_local7) == "-" && sigNum() == 0) {
						_local9 = true;
					}
				} else {
					_local5 = b * _local5 + _local6;
					_local8++;
					if(_local8 >= _local3) {
						bi_internal::dMultiply(_local4);
						bi_internal::dAddOffset(_local5,0);
						_local8 = 0;
						_local5 = 0;
					}
				}
				_local7++;
			}
			if(_local8 > 0) {
				bi_internal::dMultiply(Math.pow(b,_local8));
				bi_internal::dAddOffset(_local5,0);
			}
			if(_local9) {
				BigInteger.ZERO.bi_internal::subTo(this,this);
			}
		}
		
		public function toByteArray() : ByteArray {
			var _local3:* = 0;
			var _local4:int = t;
			var _local2:ByteArray = new ByteArray();
			_local2[0] = bi_internal::s;
			var _local1:int = 30 - _local4 * 30 % 8;
			var _local5:int = 0;
			if(_local4-- > 0) {
				if(_local1 < 30 && (_local3 = bi_internal::a[_local4] >> _local1) != (bi_internal::s & 0x3FFFFFFF) >> _local1) {
					_local2[_local5++] = _local3 | bi_internal::s << 30 - _local1;
				}
				while(_local4 >= 0) {
					if(_local1 < 8) {
						_local3 = (bi_internal::a[_local4] & (1 << _local1) - 1) << 8 - _local1;
						_local4--;
						_local3 |= bi_internal::a[_local4] >> (_local1 += 30 - 8);
					} else {
						_local3 = bi_internal::a[_local4] >> (_local1 -= 8) & 0xFF;
						if(_local1 <= 0) {
							_local1 += 30;
							_local4--;
						}
					}
					if((_local3 & 0x80) != 0) {
						_local3 |= -256;
					}
					if(_local5 == 0 && (bi_internal::s & 0x80) != (_local3 & 0x80)) {
						_local5++;
					}
					if(_local5 > 0 || _local3 != bi_internal::s) {
						_local2[_local5++] = _local3;
					}
				}
			}
			return _local2;
		}
		
		public function equals(a:BigInteger) : Boolean {
			return compareTo(a) == 0;
		}
		
		public function min(a:BigInteger) : BigInteger {
			return compareTo(a) < 0 ? this : a;
		}
		
		public function max(a:BigInteger) : BigInteger {
			return compareTo(a) > 0 ? this : a;
		}
		
		protected function bitwiseTo(a:BigInteger, op:Function, r:BigInteger) : void {
			var _local5:* = 0;
			var _local4:* = 0;
			var _local6:int = Math.min(a.t,t);
			_local5 = 0;
			while(_local5 < _local6) {
				r.bi_internal::a[_local5] = op(this.bi_internal::a[_local5],a.bi_internal::a[_local5]);
				_local5++;
			}
			if(a.t < t) {
				_local4 = a.bi_internal::s & 0x3FFFFFFF;
				_local5 = _local6;
				while(_local5 < t) {
					r.bi_internal::a[_local5] = op(this.bi_internal::a[_local5],_local4);
					_local5++;
				}
				r.t = t;
			} else {
				_local4 = bi_internal::s & 0x3FFFFFFF;
				_local5 = _local6;
				while(_local5 < a.t) {
					r.bi_internal::a[_local5] = op(_local4,a.bi_internal::a[_local5]);
					_local5++;
				}
				r.t = a.t;
			}
			r.bi_internal::s = op(bi_internal::s,a.bi_internal::s);
			r.bi_internal::clamp();
		}
		
		private function op_and(x:int, y:int) : int {
			return x & y;
		}
		
		public function and(a:BigInteger) : BigInteger {
			var _local2:BigInteger = new BigInteger();
			bitwiseTo(a,op_and,_local2);
			return _local2;
		}
		
		private function op_or(x:int, y:int) : int {
			return x | y;
		}
		
		public function or(a:BigInteger) : BigInteger {
			var _local2:BigInteger = new BigInteger();
			bitwiseTo(a,op_or,_local2);
			return _local2;
		}
		
		private function op_xor(x:int, y:int) : int {
			return x ^ y;
		}
		
		public function xor(a:BigInteger) : BigInteger {
			var _local2:BigInteger = new BigInteger();
			bitwiseTo(a,op_xor,_local2);
			return _local2;
		}
		
		private function op_andnot(x:int, y:int) : int {
			return x & ~y;
		}
		
		public function andNot(a:BigInteger) : BigInteger {
			var _local2:BigInteger = new BigInteger();
			bitwiseTo(a,op_andnot,_local2);
			return _local2;
		}
		
		public function not() : BigInteger {
			var _local2:int = 0;
			var _local1:BigInteger = new BigInteger();
			_local2 = 0;
			while(_local2 < t) {
				_local1[_local2] = 0x3FFFFFFF & ~bi_internal::a[_local2];
				_local2++;
			}
			_local1.t = t;
			_local1.bi_internal::s = ~bi_internal::s;
			return _local1;
		}
		
		public function shiftLeft(n:int) : BigInteger {
			var _local2:BigInteger = new BigInteger();
			if(n < 0) {
				bi_internal::rShiftTo(-n,_local2);
			} else {
				bi_internal::lShiftTo(n,_local2);
			}
			return _local2;
		}
		
		public function shiftRight(n:int) : BigInteger {
			var _local2:BigInteger = new BigInteger();
			if(n < 0) {
				bi_internal::lShiftTo(-n,_local2);
			} else {
				bi_internal::rShiftTo(n,_local2);
			}
			return _local2;
		}
		
		private function lbit(x:int) : int {
			if(x == 0) {
				return -1;
			}
			var _local2:int = 0;
			if((x & 0xFFFF) == 0) {
				x >>= 16;
				_local2 += 16;
			}
			if((x & 0xFF) == 0) {
				x >>= 8;
				_local2 += 8;
			}
			if((x & 0x0F) == 0) {
				x >>= 4;
				_local2 += 4;
			}
			if((x & 3) == 0) {
				x >>= 2;
				_local2 += 2;
			}
			if((x & 1) == 0) {
				_local2++;
			}
			return _local2;
		}
		
		public function getLowestSetBit() : int {
			var _local1:int = 0;
			_local1 = 0;
			while(_local1 < t) {
				if(bi_internal::a[_local1] != 0) {
					return _local1 * 30 + lbit(bi_internal::a[_local1]);
				}
				_local1++;
			}
			if(bi_internal::s < 0) {
				return t * 30;
			}
			return -1;
		}
		
		private function cbit(x:int) : int {
			var _local2:uint = 0;
			while(x != 0) {
				x &= x - 1;
				_local2++;
			}
			return _local2;
		}
		
		public function bitCount() : int {
			var _local3:int = 0;
			var _local1:int = 0;
			var _local2:* = bi_internal::s & 0x3FFFFFFF;
			_local3 = 0;
			while(_local3 < t) {
				_local1 += cbit(bi_internal::a[_local3] ^ _local2);
				_local3++;
			}
			return _local1;
		}
		
		public function testBit(n:int) : Boolean {
			var _local2:int = Math.floor(n / 30);
			if(_local2 >= t) {
				return bi_internal::s != 0;
			}
			return (bi_internal::a[_local2] & 1 << n % 30) != 0;
		}
		
		protected function changeBit(n:int, op:Function) : BigInteger {
			var _local3:BigInteger = BigInteger.ONE.shiftLeft(n);
			bitwiseTo(_local3,op,_local3);
			return _local3;
		}
		
		public function setBit(n:int) : BigInteger {
			return changeBit(n,op_or);
		}
		
		public function clearBit(n:int) : BigInteger {
			return changeBit(n,op_andnot);
		}
		
		public function flipBit(n:int) : BigInteger {
			return changeBit(n,op_xor);
		}
		
		protected function addTo(a:BigInteger, r:BigInteger) : void {
			var _local4:int = 0;
			var _local3:* = 0;
			var _local5:int = Math.min(a.t,t);
			while(_local4 < _local5) {
				_local3 += this.bi_internal::a[_local4] + a.bi_internal::a[_local4];
				r.bi_internal::a[_local4++] = _local3 & 0x3FFFFFFF;
				_local3 >>= 30;
			}
			if(a.t < t) {
				_local3 += a.bi_internal::s;
				while(_local4 < t) {
					_local3 += this.bi_internal::a[_local4];
					r.bi_internal::a[_local4++] = _local3 & 0x3FFFFFFF;
					_local3 >>= 30;
				}
				_local3 += bi_internal::s;
			} else {
				_local3 += bi_internal::s;
				while(_local4 < a.t) {
					_local3 += a.bi_internal::a[_local4];
					r.bi_internal::a[_local4++] = _local3 & 0x3FFFFFFF;
					_local3 >>= 30;
				}
				_local3 += a.bi_internal::s;
			}
			r.bi_internal::s = _local3 < 0 ? -1 : 0;
			if(_local3 > 0) {
				r.bi_internal::a[_local4++] = _local3;
			} else if(_local3 < -1) {
				r.bi_internal::a[_local4++] = 0x40000000 + _local3;
			}
			r.t = _local4;
			r.bi_internal::clamp();
		}
		
		public function add(a:BigInteger) : BigInteger {
			var _local2:BigInteger = new BigInteger();
			addTo(a,_local2);
			return _local2;
		}
		
		public function subtract(a:BigInteger) : BigInteger {
			var _local2:BigInteger = new BigInteger();
			bi_internal::subTo(a,_local2);
			return _local2;
		}
		
		public function multiply(a:BigInteger) : BigInteger {
			var _local2:BigInteger = new BigInteger();
			bi_internal::multiplyTo(a,_local2);
			return _local2;
		}
		
		public function divide(a:BigInteger) : BigInteger {
			var _local2:BigInteger = new BigInteger();
			bi_internal::divRemTo(a,_local2,null);
			return _local2;
		}
		
		public function remainder(a:BigInteger) : BigInteger {
			var _local2:BigInteger = new BigInteger();
			bi_internal::divRemTo(a,null,_local2);
			return _local2;
		}
		
		public function divideAndRemainder(a:BigInteger) : Array {
			var _local2:BigInteger = new BigInteger();
			var _local3:BigInteger = new BigInteger();
			bi_internal::divRemTo(a,_local2,_local3);
			return [_local2,_local3];
		}
		
		bi_internal function dMultiply(n:int) : void {
			bi_internal::a[t] = bi_internal::am(0,n - 1,this,0,0,t);
			++t;
			bi_internal::clamp();
		}
		
		bi_internal function dAddOffset(n:int, w:int) : void {
			while(t <= w) {
				bi_internal::a[t++] = 0;
			}
			var _local3:* = w;
			var _local4:* = bi_internal::a[_local3] + n;
			bi_internal::a[_local3] = _local4;
			while(bi_internal::a[w] >= 0x40000000) {
				_local4 = w;
				_local3 = bi_internal::a[_local4] - 0x40000000;
				bi_internal::a[_local4] = _local3;
				w++;
				if(w >= t) {
					bi_internal::a[t++] = 0;
				}
				++bi_internal::a[w];
			}
		}
		
		public function pow(e:int) : BigInteger {
			return bi_internal::exp(e,new NullReduction());
		}
		
		bi_internal function multiplyLowerTo(a:BigInteger, n:int, r:BigInteger) : void {
			var _local5:int = 0;
			var _local4:int = Math.min(t + a.t,n);
			r.bi_internal::s = 0;
			r.t = _local4;
			while(_local4 > 0) {
				_local4--;
				r.bi_internal::a[_local4] = 0;
			}
			_local5 = r.t - t;
			while(_local4 < _local5) {
				r.bi_internal::a[_local4 + t] = bi_internal::am(0,a.bi_internal::a[_local4],r,_local4,0,t);
				_local4++;
			}
			_local5 = Math.min(a.t,n);
			while(_local4 < _local5) {
				bi_internal::am(0,a.bi_internal::a[_local4],r,_local4,0,n - _local4);
				_local4++;
			}
			r.bi_internal::clamp();
		}
		
		bi_internal function multiplyUpperTo(a:BigInteger, n:int, r:BigInteger) : void {
			n--;
			var _local4:* = r.t = t + a.t - n;
			r.bi_internal::s = 0;
			while(true) {
				_local4--;
				if(_local4 < 0) {
					break;
				}
				r.bi_internal::a[_local4] = 0;
			}
			_local4 = Math.max(n - t,0);
			while(_local4 < a.t) {
				r.bi_internal::a[t + _local4 - n] = bi_internal::am(n - _local4,a.bi_internal::a[_local4],r,0,0,t + _local4 - n);
				_local4++;
			}
			r.bi_internal::clamp();
			r.bi_internal::drShiftTo(1,r);
		}
		
		public function modPow(e:BigInteger, m:BigInteger) : BigInteger {
			var _local10:int = 0;
			var _local16:IReduction = null;
			var _local11:BigInteger = null;
			var _local15:* = 0;
			var _local14:* = null;
			var _local8:int = e.bitLength();
			var _local13:* = nbv(1);
			if(_local8 <= 0) {
				return _local13;
			}
			if(_local8 < 18) {
				_local10 = 1;
			} else if(_local8 < 48) {
				_local10 = 3;
			} else if(_local8 < 144) {
				_local10 = 4;
			} else if(_local8 < 768) {
				_local10 = 5;
			} else {
				_local10 = 6;
			}
			if(_local8 < 8) {
				_local16 = new ClassicReduction(m);
			} else if(m.bi_internal::isEven()) {
				_local16 = new BarrettReduction(m);
			} else {
				_local16 = new MontgomeryReduction(m);
			}
			var _local7:Array = [];
			var _local12:* = 3;
			var _local5:int = _local10 - 1;
			var _local4:int = (1 << _local10) - 1;
			_local7[1] = _local16.convert(this);
			if(_local10 > 1) {
				_local11 = new BigInteger();
				_local16.sqrTo(_local7[1],_local11);
				while(_local12 <= _local4) {
					_local7[_local12] = new BigInteger();
					_local16.mulTo(_local11,_local7[_local12 - 2],_local7[_local12]);
					_local12 += 2;
				}
			}
			var _local9:int = e.t - 1;
			var _local6:Boolean = true;
			var _local3:* = new BigInteger();
			_local8 = bi_internal::nbits(e.bi_internal::a[_local9]) - 1;
			while(_local9 >= 0) {
				if(_local8 >= _local5) {
					_local15 = e.bi_internal::a[_local9] >> _local8 - _local5 & _local4;
				} else {
					_local15 = (e.bi_internal::a[_local9] & (1 << _local8 + 1) - 1) << _local5 - _local8;
					if(_local9 > 0) {
						_local15 |= e.bi_internal::a[_local9 - 1] >> 30 + _local8 - _local5;
					}
				}
				_local12 = _local10;
				while((_local15 & 1) == 0) {
					_local15 >>= 1;
					_local12--;
				}
				_local8 -= _local12;
				if(_local8 < 0) {
					_local8 += 30;
					_local9--;
				}
				if(_local6) {
					_local7[_local15].copyTo(_local13);
					_local6 = false;
				} else {
					while(_local12 > 1) {
						_local16.sqrTo(_local13,_local3);
						_local16.sqrTo(_local3,_local13);
						_local12 -= 2;
					}
					if(_local12 > 0) {
						_local16.sqrTo(_local13,_local3);
					} else {
						_local14 = _local13;
						_local13 = _local3;
						_local3 = _local14;
					}
					_local16.mulTo(_local3,_local7[_local15],_local13);
				}
				while(_local9 >= 0 && (e.bi_internal::a[_local9] & 1 << _local8) == 0) {
					_local16.sqrTo(_local13,_local3);
					_local14 = _local13;
					_local13 = _local3;
					_local3 = _local14;
					_local8--;
					if(_local8 < 0) {
						_local8 = 30 - 1;
						_local9--;
					}
				}
			}
			return _local16.revert(_local13);
		}
		
		public function gcd(a:BigInteger) : BigInteger {
			var _local2:* = null;
			var _local4:* = bi_internal::s < 0 ? negate() : clone();
			var _local5:* = a.bi_internal::s < 0 ? a.negate() : a.clone();
			if(_local4.compareTo(_local5) < 0) {
				_local2 = _local4;
				_local4 = _local5;
				_local5 = _local2;
			}
			var _local6:int = _local4.getLowestSetBit();
			var _local3:* = _local5.getLowestSetBit();
			if(_local3 < 0) {
				return _local4;
			}
			if(_local6 < _local3) {
				_local3 = _local6;
			}
			if(_local3 > 0) {
				_local4.bi_internal::rShiftTo(_local3,_local4);
				_local5.bi_internal::rShiftTo(_local3,_local5);
			}
			while(_local4.sigNum() > 0) {
				_local6 = _local4.getLowestSetBit();
				if(_local6 > 0) {
					_local4.bi_internal::rShiftTo(_local6,_local4);
				}
				_local6 = _local5.getLowestSetBit();
				if(_local6 > 0) {
					_local5.bi_internal::rShiftTo(_local6,_local5);
				}
				if(_local4.compareTo(_local5) >= 0) {
					_local4.bi_internal::subTo(_local5,_local4);
					_local4.bi_internal::rShiftTo(1,_local4);
				} else {
					_local5.bi_internal::subTo(_local4,_local5);
					_local5.bi_internal::rShiftTo(1,_local5);
				}
			}
			if(_local3 > 0) {
				_local5.bi_internal::lShiftTo(_local3,_local5);
			}
			return _local5;
		}
		
		protected function modInt(n:int) : int {
			var _local4:int = 0;
			if(n <= 0) {
				return 0;
			}
			var _local3:int = 0x40000000 % n;
			var _local2:int = bi_internal::s < 0 ? n - 1 : 0;
			if(t > 0) {
				if(_local3 == 0) {
					_local2 = bi_internal::a[0] % n;
				} else {
					_local4 = t - 1;
					while(_local4 >= 0) {
						_local2 = (_local3 * _local2 + bi_internal::a[_local4]) % n;
						_local4--;
					}
				}
			}
			return _local2;
		}
		
		public function modInverse(m:BigInteger) : BigInteger {
			var _local3:Boolean = m.bi_internal::isEven();
			if(bi_internal::isEven() && _local3 || m.sigNum() == 0) {
				return BigInteger.ZERO;
			}
			var _local7:BigInteger = m.clone();
			var _local8:BigInteger = clone();
			var _local2:BigInteger = nbv(1);
			var _local4:BigInteger = nbv(0);
			var _local5:BigInteger = nbv(0);
			var _local6:BigInteger = nbv(1);
			while(_local7.sigNum() != 0) {
				while(_local7.bi_internal::isEven()) {
					_local7.bi_internal::rShiftTo(1,_local7);
					if(_local3) {
						if(!_local2.bi_internal::isEven() || !_local4.bi_internal::isEven()) {
							_local2.addTo(this,_local2);
							_local4.bi_internal::subTo(m,_local4);
						}
						_local2.bi_internal::rShiftTo(1,_local2);
					} else if(!_local4.bi_internal::isEven()) {
						_local4.bi_internal::subTo(m,_local4);
					}
					_local4.bi_internal::rShiftTo(1,_local4);
				}
				while(_local8.bi_internal::isEven()) {
					_local8.bi_internal::rShiftTo(1,_local8);
					if(_local3) {
						if(!_local5.bi_internal::isEven() || !_local6.bi_internal::isEven()) {
							_local5.addTo(this,_local5);
							_local6.bi_internal::subTo(m,_local6);
						}
						_local5.bi_internal::rShiftTo(1,_local5);
					} else if(!_local6.bi_internal::isEven()) {
						_local6.bi_internal::subTo(m,_local6);
					}
					_local6.bi_internal::rShiftTo(1,_local6);
				}
				if(_local7.compareTo(_local8) >= 0) {
					_local7.bi_internal::subTo(_local8,_local7);
					if(_local3) {
						_local2.bi_internal::subTo(_local5,_local2);
					}
					_local4.bi_internal::subTo(_local6,_local4);
				} else {
					_local8.bi_internal::subTo(_local7,_local8);
					if(_local3) {
						_local5.bi_internal::subTo(_local2,_local5);
					}
					_local6.bi_internal::subTo(_local4,_local6);
				}
			}
			if(_local8.compareTo(BigInteger.ONE) != 0) {
				return BigInteger.ZERO;
			}
			if(_local6.compareTo(m) >= 0) {
				return _local6.subtract(m);
			}
			if(_local6.sigNum() < 0) {
				_local6.addTo(m,_local6);
				if(_local6.sigNum() < 0) {
					return _local6.add(m);
				}
				return _local6;
			}
			return _local6;
		}
		
		public function isProbablePrime(t:int) : Boolean {
			var _local3:int = 0;
			var _local5:int = 0;
			var _local4:int = 0;
			var _local2:BigInteger = abs();
			if(_local2.t == 1 && _local2.bi_internal::a[0] <= lowprimes[lowprimes.length - 1]) {
				_local3 = 0;
				while(_local3 < lowprimes.length) {
					if(_local2[0] == lowprimes[_local3]) {
						return true;
					}
					_local3++;
				}
				return false;
			}
			if(_local2.bi_internal::isEven()) {
				return false;
			}
			_local3 = 1;
			while(_local3 < lowprimes.length) {
				_local5 = int(lowprimes[_local3]);
				_local4 = _local3 + 1;
				while(_local4 < lowprimes.length && _local5 < lplim) {
					_local5 *= lowprimes[_local4++];
				}
				_local5 = _local2.modInt(_local5);
				while(_local3 < _local4) {
					if(_local5 % lowprimes[_local3++] == 0) {
						return false;
					}
				}
			}
			return _local2.millerRabin(t);
		}
		
		protected function millerRabin(t:int) : Boolean {
			var _local5:int = 0;
			var _local6:BigInteger = null;
			var _local7:int = 0;
			var _local4:BigInteger = subtract(BigInteger.ONE);
			var _local8:int = _local4.getLowestSetBit();
			if(_local8 <= 0) {
				return false;
			}
			var _local3:BigInteger = _local4.shiftRight(_local8);
			t = t + 1 >> 1;
			if(t > lowprimes.length) {
				t = int(lowprimes.length);
			}
			var _local2:BigInteger = new BigInteger();
			_local5 = 0;
			while(_local5 < t) {
				_local2.bi_internal::fromInt(lowprimes[_local5]);
				_local6 = _local2.modPow(_local3,this);
				if(_local6.compareTo(BigInteger.ONE) != 0 && _local6.compareTo(_local4) != 0) {
					_local7 = 1;
					while(_local7++ < _local8 && _local6.compareTo(_local4) != 0) {
						_local6 = _local6.modPowInt(2,this);
						if(_local6.compareTo(BigInteger.ONE) == 0) {
							return false;
						}
					}
					if(_local6.compareTo(_local4) != 0) {
						return false;
					}
				}
				_local5++;
			}
			return true;
		}
		
		public function primify(bits:int, t:int) : void {
			if(!testBit(bits - 1)) {
				bitwiseTo(BigInteger.ONE.shiftLeft(bits - 1),op_or,this);
			}
			if(bi_internal::isEven()) {
				bi_internal::dAddOffset(1,0);
			}
			while(!isProbablePrime(t)) {
				bi_internal::dAddOffset(2,0);
				while(bitLength() > bits) {
					bi_internal::subTo(BigInteger.ONE.shiftLeft(bits - 1),this);
				}
			}
		}
	}
}

