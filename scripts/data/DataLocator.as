package data {
	public class DataLocator {
		private static var service:IDataManager;
		
		public function DataLocator() {
			super();
		}
		
		public static function register(s:IDataManager) : void {
			service = s;
		}
		
		public static function getService() : IDataManager {
			return service;
		}
	}
}

