package playerio.generated.messages {
	import com.protobuf.Message;
	
	public final class LoadIndexRangeArgs extends Message {
		public var table:String;
		
		public var index:String;
		
		public var startIndexValue:Array = [];
		
		public var startIndexValueDummy:ValueObject = null;
		
		public var stopIndexValue:Array = [];
		
		public var stopIndexValueDummy:ValueObject = null;
		
		public var limit:int;
		
		public function LoadIndexRangeArgs(table:String, index:String, startIndexValue:Array, stopIndexValue:Array, limit:int) {
			super();
			registerField("table","",9,1,1);
			registerField("index","",9,1,2);
			registerField("startIndexValue","playerio.generated.messages.ValueObject",11,3,3);
			registerField("stopIndexValue","playerio.generated.messages.ValueObject",11,3,4);
			registerField("limit","",5,1,5);
			this.table = table;
			this.index = index;
			this.startIndexValue = startIndexValue;
			this.stopIndexValue = stopIndexValue;
			this.limit = limit;
		}
	}
}

