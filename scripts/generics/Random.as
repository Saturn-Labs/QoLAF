package generics {
	public class Random {
		private var r:uint;
		
		public function Random(seed:Number) {
			super();
			if(seed > 1000000) {
				seed %= 1000000;
			}
			r = seed * 4294967293 + 1;
		}
		
		public function stepTo(n:int) : void {
			var _local2:int = 0;
			_local2 = 0;
			while(_local2 < n) {
				random(20);
				_local2++;
			}
		}
		
		public function random(max:int) : int {
			r ^= r << 21;
			r ^= r >>> 35;
			r ^= r << 4;
			return r / 4294967295 * max;
		}
		
		public function randomNumber() : Number {
			var _local1:Number = random(100000);
			return _local1 / 100000;
		}
	}
}

