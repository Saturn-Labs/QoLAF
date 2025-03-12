package data
{
	
	public class DataLocator
	{
		private static var service:IDataManager;
		
		public function DataLocator()
		{
			super();
		}
		
		public static function register(param1:IDataManager):void
		{
			service = param1;
		}
		
		public static function getService():IDataManager
		{
			return service;
		}
	}
}
