package joinRoom {
	public class JoinRoomLocator {
		private static var service:IJoinRoomManager;
		
		public function JoinRoomLocator() {
			super();
		}
		
		public static function register(s:IJoinRoomManager) : void {
			service = s;
		}
		
		public static function getService() : IJoinRoomManager {
			return service;
		}
	}
}

