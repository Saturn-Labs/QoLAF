package playerio.generated.messages {
	import com.protobuf.Message;
	
	public final class GameRequestsSendArgs extends Message {
		public var requestType:String;
		
		public var requestData:Array = [];
		
		public var requestDataDummy:KeyValuePair = null;
		
		public var requestRecipients:Array = [];
		
		public function GameRequestsSendArgs(requestType:String, requestData:Array, requestRecipients:Array) {
			super();
			registerField("requestType","",9,1,1);
			registerField("requestData","playerio.generated.messages.KeyValuePair",11,3,2);
			registerField("requestRecipients","",9,3,3);
			this.requestType = requestType;
			this.requestData = requestData;
			this.requestRecipients = requestRecipients;
		}
	}
}

