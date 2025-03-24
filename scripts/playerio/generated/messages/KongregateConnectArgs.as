package playerio.generated.messages {
	import com.protobuf.Message;
	
	public final class KongregateConnectArgs extends Message {
		public var gameId:String;
		
		public var userId:String;
		
		public var gameAuthToken:String;
		
		public var playerInsightSegments:Array = [];
		
		public var clientAPI:String;
		
		public var clientInfo:Array = [];
		
		public var clientInfoDummy:KeyValuePair = null;
		
		public function KongregateConnectArgs(gameId:String, userId:String, gameAuthToken:String, playerInsightSegments:Array, clientAPI:String, clientInfo:Array) {
			super();
			registerField("gameId","",9,1,1);
			registerField("userId","",9,1,2);
			registerField("gameAuthToken","",9,1,3);
			registerField("playerInsightSegments","",9,3,4);
			registerField("clientAPI","",9,1,5);
			registerField("clientInfo","playerio.generated.messages.KeyValuePair",11,3,6);
			this.gameId = gameId;
			this.userId = userId;
			this.gameAuthToken = gameAuthToken;
			this.playerInsightSegments = playerInsightSegments;
			this.clientAPI = clientAPI;
			this.clientInfo = clientInfo;
		}
	}
}

