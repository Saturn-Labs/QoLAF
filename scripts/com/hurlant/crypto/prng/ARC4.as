package com.hurlant.crypto.prng {
	import com.hurlant.crypto.symmetric.IStreamCipher;
	import com.hurlant.util.Memory;
	import flash.utils.ByteArray;
	
	public class ARC4 implements IPRNG, IStreamCipher {
		private var i:int = 0;
		
		private var j:int = 0;
		
		private var S:ByteArray;
		
		private const psize:uint = 256;
		
		public function ARC4(key:ByteArray = null) {
			super();
			S = new ByteArray();
			if(key) {
				init(key);
			}
		}
		
		public function getPoolSize() : uint {
			return 256;
		}
		
		public function init(key:ByteArray) : void {
			var _local3:int = 0;
			var _local4:* = 0;
			var _local2:int = 0;
			_local3 = 0;
			while(_local3 < 256) {
				S[_local3] = _local3;
				_local3++;
			}
			_local4 = 0;
			_local3 = 0;
			while(_local3 < 256) {
				_local4 = _local4 + S[_local3] + key[_local3 % key.length] & 0xFF;
				_local2 = int(S[_local3]);
				S[_local3] = S[_local4];
				S[_local4] = _local2;
				_local3++;
			}
			this.i = 0;
			this.j = 0;
		}
		
		public function next() : uint {
			var _local1:int = 0;
			i = i + 1 & 0xFF;
			j = j + S[i] & 0xFF;
			_local1 = int(S[i]);
			S[i] = S[j];
			S[j] = _local1;
			return S[_local1 + S[i] & 0xFF];
		}
		
		public function getBlockSize() : uint {
			return 1;
		}
		
		public function encrypt(block:ByteArray) : void {
			var _local2:uint = 0;
			while(_local2 < block.length) {
				var _local3:* = _local2++;
				var _local4:* = block[_local3] ^ next();
				block[_local3] = _local4;
			}
		}
		
		public function decrypt(block:ByteArray) : void {
			encrypt(block);
		}
		
		public function dispose() : void {
			var _local1:uint = 0;
			if(S != null) {
				_local1 = 0;
				while(_local1 < S.length) {
					S[_local1] = Math.random() * 256;
					_local1++;
				}
				S.length = 0;
				S = null;
			}
			this.i = 0;
			this.j = 0;
			Memory.gc();
		}
		
		public function toString() : String {
			return "rc4";
		}
	}
}

