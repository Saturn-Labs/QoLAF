package
{
	
	public class TimeDelta
	{
		public var latency:Number;
		
		public var timeSyncDelta:Number;
		
		public function TimeDelta(param1:Number, param2:Number)
		{
			super();
			this.latency = param1;
			this.timeSyncDelta = param2;
		}
	}
}
