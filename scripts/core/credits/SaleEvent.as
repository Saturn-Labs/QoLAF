package core.credits {
	public class SaleEvent {
		public var start:Date;
		
		public var end:Date;
		
		public function SaleEvent(year:int, month:int, day:int, hour:int, duration:int) {
			super();
			start = new Date(year,month - 1,day,hour,0,0,0);
			end = new Date(start.valueOf() + duration * (60) * (60) * 1000);
		}
		
		public function isNow() : Boolean {
			var _local1:Date = new Date();
			_local1 = new Date(_local1.fullYearUTC,_local1.monthUTC,_local1.dateUTC,_local1.hoursUTC,_local1.minutesUTC,_local1.secondsUTC,_local1.millisecondsUTC);
			if(start.valueOf() < _local1.valueOf() && end.valueOf() > _local1.valueOf()) {
				return true;
			}
			return false;
		}
	}
}

