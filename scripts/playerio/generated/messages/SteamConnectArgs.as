package playerio.generated.messages {
	import com.protobuf.Message;
	
	public final class SteamConnectArgs extends Message {
		public var gameId:String;
		
		public var steamAppId:String;
		
		public var steamSessionTicket:String;
		
		public var playerInsightSegments:Array = [];
		
		public var clientAPI:String;
		
		public var clientInfo:Array = [];
		
		public var clientInfoDummy:KeyValuePair = null;
		
		public function SteamConnectArgs(gameId:String, steamAppId:String, steamSessionTicket:String, playerInsightSegments:Array, clientAPI:String, clientInfo:Array) {
			super();
			registerField("gameId","",9,1,1);
			registerField("steamAppId","",9,1,2);
			registerField("steamSessionTicket","",9,1,3);
			registerField("playerInsightSegments","",9,3,4);
			registerField("clientAPI","",9,1,5);
			registerField("clientInfo","playerio.generated.messages.KeyValuePair",11,3,6);
			this.gameId = gameId;
			this.steamAppId = steamAppId;
			this.steamSessionTicket = steamSessionTicket;
			this.playerInsightSegments = playerInsightSegments;
			this.clientAPI = clientAPI;
			this.clientInfo = clientInfo;
		}
	}
}

