package playerio.generated.messages {
	import com.protobuf.Message;
	
	public final class PayVaultPaymentInfoArgs extends Message {
		public var provider:String;
		
		public var purchaseArguments:Array = [];
		
		public var purchaseArgumentsDummy:KeyValuePair = null;
		
		public var items:Array = [];
		
		public var itemsDummy:PayVaultBuyItemInfo = null;
		
		public function PayVaultPaymentInfoArgs(provider:String, purchaseArguments:Array, items:Array) {
			super();
			registerField("provider","",9,1,1);
			registerField("purchaseArguments","playerio.generated.messages.KeyValuePair",11,3,2);
			registerField("items","playerio.generated.messages.PayVaultBuyItemInfo",11,3,3);
			this.provider = provider;
			this.purchaseArguments = purchaseArguments;
			this.items = items;
		}
	}
}

