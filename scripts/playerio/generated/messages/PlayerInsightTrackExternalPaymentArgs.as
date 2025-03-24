package playerio.generated.messages {
	import com.protobuf.Message;
	
	public final class PlayerInsightTrackExternalPaymentArgs extends Message {
		public var currency:String;
		
		public var amount:int;
		
		public function PlayerInsightTrackExternalPaymentArgs(currency:String, amount:int) {
			super();
			registerField("currency","",9,1,1);
			registerField("amount","",5,1,2);
			this.currency = currency;
			this.amount = amount;
		}
	}
}

