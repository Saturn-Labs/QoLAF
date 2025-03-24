package com.hurlant.crypto.prng {
	import com.hurlant.util.Memory;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.Font;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	public class Random {
		private var state:IPRNG;
		
		private var ready:Boolean = false;
		
		private var pool:ByteArray;
		
		private var psize:int;
		
		private var pptr:int;
		
		private var seeded:Boolean = false;
		
		public function Random(prng:Class = null) {
			var _local2:* = 0;
			super();
			if(prng == null) {
				prng = ARC4;
			}
			state = new prng() as IPRNG;
			psize = state.getPoolSize();
			pool = new ByteArray();
			pptr = 0;
			while(pptr < psize) {
				_local2 = 65536 * Math.random();
				pool[pptr++] = _local2 >>> 8;
				pool[pptr++] = _local2 & 0xFF;
			}
			pptr = 0;
			seed();
		}
		
		public function seed(x:int = 0) : void {
			if(x == 0) {
				x = int(new Date().getTime());
			}
			var _local2:* = pptr++;
			var _local3:* = pool[_local2] ^ x & 0xFF;
			pool[_local2] = _local3;
			pool[pptr++] ^= x >> 8 & 0xFF;
			pool[pptr++] ^= x >> 16 & 0xFF;
			pool[pptr++] ^= x >> 24 & 0xFF;
			pptr %= psize;
			seeded = true;
		}
		
		public function autoSeed() : void {
			var _local2:ByteArray = new ByteArray();
			_local2.writeUnsignedInt(System.totalMemory);
			_local2.writeUTF(Capabilities.serverString);
			_local2.writeUnsignedInt(getTimer());
			_local2.writeUnsignedInt(new Date().getTime());
			var _local1:Array = Font.enumerateFonts(true);
			for each(var _local3 in _local1) {
				_local2.writeUTF(_local3.fontName);
				_local2.writeUTF(_local3.fontStyle);
				_local2.writeUTF(_local3.fontType);
			}
			_local2.position = 0;
			while(_local2.bytesAvailable >= 4) {
				seed(_local2.readUnsignedInt());
			}
		}
		
		public function nextBytes(buffer:ByteArray, length:int) : void {
			while(length--) {
				buffer.writeByte(nextByte());
			}
		}
		
		public function nextByte() : int {
			if(!ready) {
				if(!seeded) {
					autoSeed();
				}
				state.init(pool);
				pool.length = 0;
				pptr = 0;
				ready = true;
			}
			return state.next();
		}
		
		public function dispose() : void {
			var _local1:* = 0;
			_local1 = 0;
			while(_local1 < pool.length) {
				pool[_local1] = Math.random() * 256;
				_local1++;
			}
			pool.length = 0;
			pool = null;
			state.dispose();
			state = null;
			psize = 0;
			pptr = 0;
			Memory.gc();
		}
		
		public function toString() : String {
			return "random-" + state.toString();
		}
	}
}

