package playerio {
	import playerio.generated.messages.WaitingGameRequest;
	import playerio.utils.Converter;
	
	public class GameRequest {
		private var _id:String;
		
		private var _type:String;
		
		private var _sendUserId:String;
		
		private var _created:Date;
		
		private var _data:Object;
		
		public function GameRequest() {
			super();
		}
		
		internal function _internal_initialize(request:WaitingGameRequest) : void {
			this._id = request.id;
			this._type = request.type;
			this._sendUserId = request.senderUserId;
			this._created = new Date(request.created);
			this._data = Converter.toKeyValueObject(request.data);
		}
		
		internal function get _internal_id() : String {
			return _id;
		}
		
		public function get type() : String {
			return _type;
		}
		
		public function get senderUserId() : String {
			return _sendUserId;
		}
		
		public function get created() : Date {
			return _created;
		}
		
		public function get data() : Object {
			return _data;
		}
	}
}

