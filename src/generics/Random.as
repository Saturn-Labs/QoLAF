package generics
{
	
	public class Random
	{
		private var r:uint;
		
		public function Random(param1:Number)
		{
			super();
			if (param1 > 1000000)
			{
				param1 %= 1000000;
			}
			r = param1 * 4294967293 + 1;
		}
		
		public function stepTo(param1:int):void
		{
			var _loc2_:int = 0;
			_loc2_ = 0;
			while (_loc2_ < param1)
			{
				random(20);
				_loc2_++;
			}
		}
		
		public function random(param1:int):int
		{
			r ^= r << 21;
			r ^= r >>> 35;
			r ^= r << 4;
			return r / 4294967295 * param1;
		}
		
		public function randomNumber():Number
		{
			var _loc1_:Number = random(100000);
			return _loc1_ / 100000;
		}
	}
}
