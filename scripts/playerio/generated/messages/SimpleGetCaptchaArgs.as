package playerio.generated.messages {
	import com.protobuf.Message;
	
	public final class SimpleGetCaptchaArgs extends Message {
		public var gameId:String;
		
		public var width:int;
		
		public var height:int;
		
		public function SimpleGetCaptchaArgs(gameId:String, width:int, height:int) {
			super();
			registerField("gameId","",9,1,1);
			registerField("width","",5,1,2);
			registerField("height","",5,1,3);
			this.gameId = gameId;
			this.width = width;
			this.height = height;
		}
	}
}

