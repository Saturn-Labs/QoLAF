package Clock {
	public class TimeDelta {
		public var latency:Number;
		
		public var timeSyncDelta:Number;
		
		public function TimeDelta(latency:Number, timeSyncDelta:Number) {
			super();
			this.latency = latency;
			this.timeSyncDelta = timeSyncDelta;
		}
	}
}

