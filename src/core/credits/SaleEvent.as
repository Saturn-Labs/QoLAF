package core.credits
{
	
	public class SaleEvent
	{
		public var start:Date;
		
		public var end:Date;
		
		public function SaleEvent(param1:int, param2:int, param3:int, param4:int, param5:int)
		{
			super();
			start = new Date(param1, param2 - 1, param3, param4, 0, 0, 0);
			end = new Date(start.valueOf() + param5 * 60 * 60 * 1000);
		}
		
		public function isNow():Boolean
		{
			var _loc1_:Date = new Date();
			_loc1_ = new Date(_loc1_.fullYearUTC, _loc1_.monthUTC, _loc1_.dateUTC, _loc1_.hoursUTC, _loc1_.minutesUTC, _loc1_.secondsUTC, _loc1_.millisecondsUTC);
			if (start.valueOf() < _loc1_.valueOf() && end.valueOf() > _loc1_.valueOf())
			{
				return true;
			}
			return false;
		}
	}
}
