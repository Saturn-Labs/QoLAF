package playerio.generated.messages {
	import com.protobuf.Message;
	
	public final class AuthenticateArgs extends Message {
		public var gameId:String;
		
		public var connectionId:String;
		
		public var authenticationArguments:Array = [];
		
		public var authenticationArgumentsDummy:KeyValuePair = null;
		
		public var playerInsightSegments:Array = [];
		
		public var clientAPI:String;
		
		public var clientInfo:Array = [];
		
		public var clientInfoDummy:KeyValuePair = null;
		
		public var playCodes:Array = [];
		
		public function AuthenticateArgs(gameId:String, connectionId:String, authenticationArguments:Array, playerInsightSegments:Array, clientAPI:String, clientInfo:Array, playCodes:Array) {
			super();
			registerField("gameId","",9,1,1);
			registerField("connectionId","",9,1,2);
			registerField("authenticationArguments","playerio.generated.messages.KeyValuePair",11,3,3);
			registerField("playerInsightSegments","",9,3,4);
			registerField("clientAPI","",9,1,5);
			registerField("clientInfo","playerio.generated.messages.KeyValuePair",11,3,6);
			registerField("playCodes","",9,3,7);
			this.gameId = gameId;
			this.connectionId = connectionId;
			this.authenticationArguments = authenticationArguments;
			this.playerInsightSegments = playerInsightSegments;
			this.clientAPI = clientAPI;
			this.clientInfo = clientInfo;
			this.playCodes = playCodes;
		}
	}
}

