package core.login {
	import playerio.Client;
	import starling.events.Event;
	
	public class ConnectEvent extends Event {
		public static const FB_CONNECT:String = "fbConnect";
		
		public static const SIMPLE_CONNECT:String = "fbConnect";
		
		public static const STATUS_UPDATE:String = "connectStatus";
		
		public var client:Client;
		
		public var joinData:Object = {};
		
		public var message:String = "";
		
		public var subMessage:String = "";
		
		public function ConnectEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type,bubbles,cancelable);
		}
	}
}

