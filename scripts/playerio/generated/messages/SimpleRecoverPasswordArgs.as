package playerio.generated.messages {
	import com.protobuf.Message;
	
	public final class SimpleRecoverPasswordArgs extends Message {
		public var gameId:String;
		
		public var usernameOrEmail:String;
		
		public function SimpleRecoverPasswordArgs(gameId:String, usernameOrEmail:String) {
			super();
			registerField("gameId","",9,1,1);
			registerField("usernameOrEmail","",9,1,2);
			this.gameId = gameId;
			this.usernameOrEmail = usernameOrEmail;
		}
	}
}

