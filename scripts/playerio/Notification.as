package playerio {
	public class Notification {
		private var _recipientUserId:String;
		
		private var _endpointType:String;
		
		private var _data:Object;
		
		public function Notification(recipientUserId:String, endpointType:String) {
			super();
			this._recipientUserId = recipientUserId;
			this._endpointType = endpointType;
			this._data = {};
		}
		
		public function get recipientUserId() : String {
			return _recipientUserId;
		}
		
		public function get endpointType() : String {
			return _endpointType;
		}
		
		public function get data() : Object {
			return _data;
		}
		
		public function set(key:String, value:String) : Notification {
			this._data[key] = value;
			return this;
		}
	}
}

