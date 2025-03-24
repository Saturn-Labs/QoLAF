package com.hurlant.crypto.rsa {
	import com.hurlant.crypto.prng.Random;
	import com.hurlant.math.BigInteger;
	import com.hurlant.util.Memory;
	import flash.utils.ByteArray;
	
	public class RSAKey {
		public var e:int;
		
		public var n:BigInteger;
		
		public var d:BigInteger;
		
		public var p:BigInteger;
		
		public var q:BigInteger;
		
		public var dmp1:BigInteger;
		
		public var dmq1:BigInteger;
		
		public var coeff:BigInteger;
		
		protected var canDecrypt:Boolean;
		
		protected var canEncrypt:Boolean;
		
		public function RSAKey(N:BigInteger, E:int, D:BigInteger = null, P:BigInteger = null, Q:BigInteger = null, DP:BigInteger = null, DQ:BigInteger = null, C:BigInteger = null) {
			super();
			this.n = N;
			this.e = E;
			this.d = D;
			this.p = P;
			this.q = Q;
			this.dmp1 = DP;
			this.dmq1 = DQ;
			this.coeff = C;
			canEncrypt = n != null && e != 0;
			canDecrypt = canEncrypt && d != null;
		}
		
		public static function parsePublicKey(N:String, E:String) : RSAKey {
			return new RSAKey(new BigInteger(N,16),parseInt(E,16));
		}
		
		public static function parsePrivateKey(N:String, E:String, D:String, P:String = null, Q:String = null, DMP1:String = null, DMQ1:String = null, IQMP:String = null) : RSAKey {
			if(P == null) {
				return new RSAKey(new BigInteger(N,16),parseInt(E,16),new BigInteger(D,16));
			}
			return new RSAKey(new BigInteger(N,16),parseInt(E,16),new BigInteger(D,16),new BigInteger(P,16),new BigInteger(Q,16),new BigInteger(DMP1,16),new BigInteger(DMQ1),new BigInteger(IQMP));
		}
		
		public static function generate(B:uint, E:String) : RSAKey {
			var _local8:BigInteger = null;
			var _local6:BigInteger = null;
			var _local4:BigInteger = null;
			var _local5:BigInteger = null;
			var _local9:Random = new Random();
			var _local7:uint = uint(B >> 1);
			var _local10:RSAKey = new RSAKey(null,0,null);
			_local10.e = parseInt(E,16);
			var _local3:BigInteger = new BigInteger(E,16);
			do {
				do {
					_local10.p = bigRandom(B - _local7,_local9);
				}
				while(!(_local10.p.subtract(BigInteger.ONE).gcd(_local3).compareTo(BigInteger.ONE) == 0 && _local10.p.isProbablePrime(10)));
				
				do {
					_local10.q = bigRandom(_local7,_local9);
				}
				while(!(_local10.q.subtract(BigInteger.ONE).gcd(_local3).compareTo(BigInteger.ONE) == 0 && _local10.q.isProbablePrime(10)));
				
				if(_local10.p.compareTo(_local10.q) <= 0) {
					_local8 = _local10.p;
					_local10.p = _local10.q;
					_local10.q = _local8;
				}
				_local6 = _local10.p.subtract(BigInteger.ONE);
				_local4 = _local10.q.subtract(BigInteger.ONE);
			}
			while(_local5 = _local6.multiply(_local4), _local5.gcd(_local3).compareTo(BigInteger.ONE) != 0);
			
			_local10.n = _local10.p.multiply(_local10.q);
			_local10.d = _local3.modInverse(_local5);
			_local10.dmp1 = _local10.d.mod(_local6);
			_local10.dmq1 = _local10.d.mod(_local4);
			_local10.coeff = _local10.q.modInverse(_local10.p);
			return _local10;
		}
		
		protected static function bigRandom(bits:int, rnd:Random) : BigInteger {
			if(bits < 2) {
				return BigInteger.nbv(1);
			}
			var _local4:ByteArray = new ByteArray();
			rnd.nextBytes(_local4,bits >> 3);
			_local4.position = 0;
			var _local3:BigInteger = new BigInteger(_local4);
			_local3.primify(bits,1);
			return _local3;
		}
		
		public function getBlockSize() : uint {
			return (n.bitLength() + 7) / 8;
		}
		
		public function dispose() : void {
			e = 0;
			n.dispose();
			n = null;
			Memory.gc();
		}
		
		public function encrypt(src:ByteArray, dst:ByteArray, length:uint, pad:Function = null) : void {
			_encrypt(doPublic,src,dst,length,pad,2);
		}
		
		public function decrypt(src:ByteArray, dst:ByteArray, length:uint, pad:Function = null) : void {
			_decrypt(doPrivate2,src,dst,length,pad,2);
		}
		
		public function sign(src:ByteArray, dst:ByteArray, length:uint, pad:Function = null) : void {
			_encrypt(doPrivate2,src,dst,length,pad,1);
		}
		
		public function verify(src:ByteArray, dst:ByteArray, length:uint, pad:Function = null) : void {
			_decrypt(doPublic,src,dst,length,pad,1);
		}
		
		private function _encrypt(op:Function, src:ByteArray, dst:ByteArray, length:uint, pad:Function, padType:int) : void {
			var _local10:BigInteger = null;
			var _local7:BigInteger = null;
			if(pad == null) {
				pad = pkcs1pad;
			}
			if(src.position >= src.length) {
				src.position = 0;
			}
			var _local8:uint = getBlockSize();
			var _local9:int = int(src.position + length);
			while(src.position < _local9) {
				_local10 = new BigInteger(pad(src,_local9,_local8,padType),_local8);
				_local7 = op(_local10);
				_local7.toArray(dst);
			}
		}
		
		private function _decrypt(op:Function, src:ByteArray, dst:ByteArray, length:uint, pad:Function, padType:int) : void {
			var _local11:BigInteger = null;
			var _local8:BigInteger = null;
			var _local7:ByteArray = null;
			if(pad == null) {
				pad = pkcs1unpad;
			}
			if(src.position >= src.length) {
				src.position = 0;
			}
			var _local9:uint = getBlockSize();
			var _local10:int = int(src.position + length);
			while(src.position < _local10) {
				_local11 = new BigInteger(src,length);
				_local8 = op(_local11);
				_local7 = pad(_local8,_local9);
				dst.writeBytes(_local7);
			}
		}
		
		private function pkcs1pad(src:ByteArray, end:int, n:uint, type:uint = 2) : ByteArray {
			var _local6:int = 0;
			var _local9:ByteArray = new ByteArray();
			var _local5:uint = src.position;
			end = Math.min(end,src.length,_local5 + n - 11);
			src.position = end;
			var _local7:int = end - 1;
			while(_local7 >= _local5 && n > 11) {
				_local9[--n] = src[_local7--];
			}
			_local9[--n] = 0;
			var _local8:Random = new Random();
			while(n > 2) {
				_local6 = 0;
				while(_local6 == 0) {
					_local6 = int(type == 2 ? _local8.nextByte() : 255);
				}
				_local9[--n] = _local6;
			}
			_local9[--n] = type;
			_local9[--n] = 0;
			return _local9;
		}
		
		private function pkcs1unpad(src:BigInteger, n:uint, type:uint = 2) : ByteArray {
			var _local4:ByteArray = src.toByteArray();
			var _local6:ByteArray = new ByteArray();
			var _local5:int = 0;
			while(_local5 < _local4.length && _local4[_local5] == 0) {
				_local5++;
			}
			if(_local4.length - _local5 != n - 1 || _local4[_local5] > 2) {
				trace("PKCS#1 unpad: i=" + _local5 + ", expected b[i]==[0,1,2], got b[i]=" + _local4[_local5].toString(16));
				return null;
			}
			_local5++;
			while(_local4[_local5] != 0) {
				_local5++;
				if(_local5 >= _local4.length) {
					trace("PKCS#1 unpad: i=" + _local5 + ", b[i-1]!=0 (=" + _local4[_local5 - 1].toString(16) + ")");
					return null;
				}
			}
			while(true) {
				_local5++;
				if(_local5 >= _local4.length) {
					break;
				}
				_local6.writeByte(_local4[_local5]);
			}
			_local6.position = 0;
			return _local6;
		}
		
		private function rawpad(src:ByteArray, end:int, n:uint) : ByteArray {
			return src;
		}
		
		public function toString() : String {
			return "rsa";
		}
		
		public function dump() : String {
			var _local1:String = "N=" + n.toString(16) + "\n" + "E=" + e.toString(16) + "\n";
			if(canDecrypt) {
				_local1 += "D=" + d.toString(16) + "\n";
				if(p != null && q != null) {
					_local1 += "P=" + p.toString(16) + "\n";
					_local1 += "Q=" + q.toString(16) + "\n";
					_local1 += "DMP1=" + dmp1.toString(16) + "\n";
					_local1 += "DMQ1=" + dmq1.toString(16) + "\n";
					_local1 += "IQMP=" + coeff.toString(16) + "\n";
				}
			}
			return _local1;
		}
		
		protected function doPublic(x:BigInteger) : BigInteger {
			return x.modPowInt(e,n);
		}
		
		protected function doPrivate2(x:BigInteger) : BigInteger {
			if(p == null && q == null) {
				return x.modPow(d,n);
			}
			var _local3:BigInteger = x.mod(p).modPow(dmp1,p);
			var _local4:BigInteger = x.mod(q).modPow(dmq1,q);
			while(_local3.compareTo(_local4) < 0) {
				_local3 = _local3.add(p);
			}
			return _local3.subtract(_local4).multiply(coeff).mod(p).multiply(q).add(_local4);
		}
		
		protected function doPrivate(x:BigInteger) : BigInteger {
			if(p == null || q == null) {
				return x.modPow(d,n);
			}
			var _local2:BigInteger = x.mod(p).modPow(dmp1,p);
			var _local3:BigInteger = x.mod(q).modPow(dmq1,q);
			while(_local2.compareTo(_local3) < 0) {
				_local2 = _local2.add(p);
			}
			return _local2.subtract(_local3).multiply(coeff).mod(p).multiply(q).add(_local3);
		}
	}
}

