package playerio.generated.messages {
	import com.protobuf.Message;
	
	public final class GameRequestsRefreshArgs extends Message {
		public var playCodes:Array = [];
		
		public function GameRequestsRefreshArgs(playCodes:Array) {
			super();
			registerField("playCodes","",9,3,1);
			this.playCodes = playCodes;
		}
	}
}

