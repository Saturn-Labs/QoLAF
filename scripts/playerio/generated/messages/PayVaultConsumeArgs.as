package playerio.generated.messages {
	import com.protobuf.Message;
	
	public final class PayVaultConsumeArgs extends Message {
		public var ids:Array = [];
		
		public var targetUserId:String;
		
		public function PayVaultConsumeArgs(ids:Array, targetUserId:String) {
			super();
			registerField("ids","",9,3,1);
			registerField("targetUserId","",9,1,2);
			this.ids = ids;
			this.targetUserId = targetUserId;
		}
	}
}

