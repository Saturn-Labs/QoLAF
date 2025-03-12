package joinRoom
{
	
	public class JoinRoomLocator
	{
		private static var service:IJoinRoomManager;
		
		public function JoinRoomLocator()
		{
			super();
		}
		
		public static function register(param1:IJoinRoomManager):void
		{
			service = param1;
		}
		
		public static function getService():IJoinRoomManager
		{
			return service;
		}
	}
}
