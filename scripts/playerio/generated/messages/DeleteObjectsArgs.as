package playerio.generated.messages {
	import com.protobuf.Message;
	
	public final class DeleteObjectsArgs extends Message {
		public var objectIds:Array = [];
		
		public var objectIdsDummy:BigDBObjectId = null;
		
		public function DeleteObjectsArgs(objectIds:Array) {
			super();
			registerField("objectIds","playerio.generated.messages.BigDBObjectId",11,3,1);
			this.objectIds = objectIds;
		}
	}
}

