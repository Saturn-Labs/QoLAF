package core.login
{
	import playerio.Client;
	import starling.events.Event;
	
	public class ConnectEvent extends Event
	{
		public static const FB_CONNECT:String = "fbConnect";
		public static const SIMPLE_CONNECT:String = "fbConnect";
		public static const STATUS_UPDATE:String = "connectStatus";
		public var client:Client;
		
		public var joinData:Object;
		
		public var message:String = "";
		public var subMessage:String = "";
		public function ConnectEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
		{
			joinData = {};
			super(param1, param2, param3);
		}
	}
}
