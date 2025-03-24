package playerio.generated.messages {
	import com.protobuf.Message;
	
	public final class FacebookOAuthConnectArgs extends Message {
		public var gameId:String;
		
		public var accessToken:String;
		
		public var partnerId:String;
		
		public var playerInsightSegments:Array = [];
		
		public var clientAPI:String;
		
		public var clientInfo:Array = [];
		
		public var clientInfoDummy:KeyValuePair = null;
		
		public function FacebookOAuthConnectArgs(gameId:String, accessToken:String, partnerId:String, playerInsightSegments:Array, clientAPI:String, clientInfo:Array) {
			super();
			registerField("gameId","",9,1,1);
			registerField("accessToken","",9,1,2);
			registerField("partnerId","",9,1,3);
			registerField("playerInsightSegments","",9,3,4);
			registerField("clientAPI","",9,1,5);
			registerField("clientInfo","playerio.generated.messages.KeyValuePair",11,3,6);
			this.gameId = gameId;
			this.accessToken = accessToken;
			this.partnerId = partnerId;
			this.playerInsightSegments = playerInsightSegments;
			this.clientAPI = clientAPI;
			this.clientInfo = clientInfo;
		}
	}
}

