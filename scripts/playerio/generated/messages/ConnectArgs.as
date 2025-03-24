package playerio.generated.messages {
	import com.protobuf.Message;
	
	public final class ConnectArgs extends Message {
		public var gameId:String;
		
		public var connectionId:String;
		
		public var userId:String;
		
		public var auth:String;
		
		public var partnerId:String;
		
		public var playerInsightSegments:Array = [];
		
		public var clientAPI:String;
		
		public var clientInfo:Array = [];
		
		public var clientInfoDummy:KeyValuePair = null;
		
		public function ConnectArgs(gameId:String, connectionId:String, userId:String, auth:String, partnerId:String, playerInsightSegments:Array, clientAPI:String, clientInfo:Array) {
			super();
			registerField("gameId","",9,1,1);
			registerField("connectionId","",9,1,2);
			registerField("userId","",9,1,3);
			registerField("auth","",9,1,4);
			registerField("partnerId","",9,1,5);
			registerField("playerInsightSegments","",9,3,6);
			registerField("clientAPI","",9,1,7);
			registerField("clientInfo","playerio.generated.messages.KeyValuePair",11,3,8);
			this.gameId = gameId;
			this.connectionId = connectionId;
			this.userId = userId;
			this.auth = auth;
			this.partnerId = partnerId;
			this.playerInsightSegments = playerInsightSegments;
			this.clientAPI = clientAPI;
			this.clientInfo = clientInfo;
		}
	}
}

