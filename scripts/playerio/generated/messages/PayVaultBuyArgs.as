package playerio.generated.messages {
	import com.protobuf.Message;
	
	public final class PayVaultBuyArgs extends Message {
		public var items:Array = [];
		
		public var itemsDummy:PayVaultBuyItemInfo = null;
		
		public var storeItems:Boolean;
		
		public var targetUserId:String;
		
		public function PayVaultBuyArgs(items:Array, storeItems:Boolean, targetUserId:String) {
			super();
			registerField("items","playerio.generated.messages.PayVaultBuyItemInfo",11,3,1);
			registerField("storeItems","",8,1,2);
			registerField("targetUserId","",9,1,3);
			this.items = items;
			this.storeItems = storeItems;
			this.targetUserId = targetUserId;
		}
	}
}

