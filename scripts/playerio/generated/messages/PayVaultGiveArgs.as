package playerio.generated.messages {
	import com.protobuf.Message;
	
	public final class PayVaultGiveArgs extends Message {
		public var items:Array = [];
		
		public var itemsDummy:PayVaultBuyItemInfo = null;
		
		public var targetUserId:String;
		
		public function PayVaultGiveArgs(items:Array, targetUserId:String) {
			super();
			registerField("items","playerio.generated.messages.PayVaultBuyItemInfo",11,3,1);
			registerField("targetUserId","",9,1,2);
			this.items = items;
			this.targetUserId = targetUserId;
		}
	}
}

