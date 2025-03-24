package playerio.generated.messages {
	import com.protobuf.Message;
	
	public final class PayVaultDebitArgs extends Message {
		public var amount:uint;
		
		public var reason:String;
		
		public var targetUserId:String;
		
		public function PayVaultDebitArgs(amount:uint, reason:String, targetUserId:String) {
			super();
			registerField("amount","",13,1,1);
			registerField("reason","",9,1,2);
			registerField("targetUserId","",9,1,3);
			this.amount = amount;
			this.reason = reason;
			this.targetUserId = targetUserId;
		}
	}
}

