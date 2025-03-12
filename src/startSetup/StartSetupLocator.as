package startSetup
{
	
	public class StartSetupLocator
	{
		private static var service:IStartSetup;
		
		public function StartSetupLocator()
		{
			super();
		}
		
		public static function initialize():void
		{
		}
		
		public static function register(param1:IStartSetup):void
		{
			service = param1;
		}
		
		public static function getService():IStartSetup
		{
			return service;
		}
	}
}
