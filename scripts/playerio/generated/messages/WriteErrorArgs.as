package playerio.generated.messages {
	import com.protobuf.Message;
	
	public final class WriteErrorArgs extends Message {
		public var source:String;
		
		public var error:String;
		
		public var details:String;
		
		public var stacktrace:String;
		
		public var extraData:Array = [];
		
		public var extraDataDummy:KeyValuePair = null;
		
		public function WriteErrorArgs(source:String, error:String, details:String, stacktrace:String, extraData:Array) {
			super();
			registerField("source","",9,1,1);
			registerField("error","",9,1,2);
			registerField("details","",9,1,3);
			registerField("stacktrace","",9,1,4);
			registerField("extraData","playerio.generated.messages.KeyValuePair",11,3,5);
			this.source = source;
			this.error = error;
			this.details = details;
			this.stacktrace = stacktrace;
			this.extraData = extraData;
		}
	}
}

