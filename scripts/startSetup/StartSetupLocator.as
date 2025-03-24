package startSetup {
	public class StartSetupLocator {
		private static var service:IStartSetup;
		
		public function StartSetupLocator() {
			super();
		}
		
		public static function initialize() : void {
		}
		
		public static function register(s:IStartSetup) : void {
			service = s;
		}
		
		public static function getService() : IStartSetup {
			return service;
		}
	}
}

