package playerio.generated.messages {
	import com.protobuf.Message;
	
	public final class PlayerInsightTrackEventsArgs extends Message {
		public var events:Array = [];
		
		public var eventsDummy:PlayerInsightEvent = null;
		
		public function PlayerInsightTrackEventsArgs(events:Array) {
			super();
			registerField("events","playerio.generated.messages.PlayerInsightEvent",11,3,1);
			this.events = events;
		}
	}
}

