package playerio.generated.messages {
	import com.protobuf.Message;
	
	public final class PayVaultRefreshArgs extends Message {
		public var lastVersion:String;
		
		public var targetUserId:String;
		
		public function PayVaultRefreshArgs(lastVersion:String, targetUserId:String) {
			super();
			registerField("lastVersion","",9,1,1);
			registerField("targetUserId","",9,1,2);
			this.lastVersion = lastVersion;
			this.targetUserId = targetUserId;
		}
	}
}

