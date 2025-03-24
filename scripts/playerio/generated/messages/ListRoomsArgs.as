package playerio.generated.messages {
	import com.protobuf.Message;
	
	public final class ListRoomsArgs extends Message {
		public var roomType:String;
		
		public var searchCriteria:Array = [];
		
		public var searchCriteriaDummy:KeyValuePair = null;
		
		public var resultLimit:int;
		
		public var resultOffset:int;
		
		public var onlyDevRooms:Boolean;
		
		public function ListRoomsArgs(roomType:String, searchCriteria:Array, resultLimit:int, resultOffset:int, onlyDevRooms:Boolean) {
			super();
			registerField("roomType","",9,1,1);
			registerField("searchCriteria","playerio.generated.messages.KeyValuePair",11,3,2);
			registerField("resultLimit","",5,1,3);
			registerField("resultOffset","",5,1,4);
			registerField("onlyDevRooms","",8,1,5);
			this.roomType = roomType;
			this.searchCriteria = searchCriteria;
			this.resultLimit = resultLimit;
			this.resultOffset = resultOffset;
			this.onlyDevRooms = onlyDevRooms;
		}
	}
}

