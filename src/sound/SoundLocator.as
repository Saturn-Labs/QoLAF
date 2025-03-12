package sound
{
	
	public class SoundLocator
	{
		private static var service:ISound;
		
		public function SoundLocator()
		{
			super();
		}
		
		public static function register(param1:ISound):void
		{
			service = param1;
		}
		
		public static function getService():ISound
		{
			return service;
		}
	}
}
