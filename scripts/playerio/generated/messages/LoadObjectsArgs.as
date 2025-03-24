package playerio.generated.messages {
	import com.protobuf.Message;
	
	public final class LoadObjectsArgs extends Message {
		public var objectIds:Array = [];
		
		public var objectIdsDummy:BigDBObjectId = null;
		
		public function LoadObjectsArgs(objectIds:Array) {
			super();
			registerField("objectIds","playerio.generated.messages.BigDBObjectId",11,3,1);
			this.objectIds = objectIds;
		}
	}
}

