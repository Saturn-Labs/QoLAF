package playerio {
	import playerio.generated.messages.NotificationsEndpoint;
	import playerio.utils.Converter;
	
	public class NotificationEndpoint {
		private var _type:String;
		
		private var _identifier:String;
		
		private var _data:Object;
		
		private var _enabled:Boolean;
		
		public function NotificationEndpoint() {
			super();
		}
		
		internal function _internal_initialize(endpoint:NotificationsEndpoint) : void {
			this._type = endpoint.type;
			this._identifier = endpoint.identifier;
			this._enabled = endpoint.enabled;
			this._data = Converter.toKeyValueObject(endpoint.configuration);
		}
		
		public function get type() : String {
			return _type;
		}
		
		public function get identifier() : String {
			return _identifier;
		}
		
		public function get configuration() : Object {
			return _data;
		}
		
		public function get endabled() : Boolean {
			return _enabled;
		}
	}
}

