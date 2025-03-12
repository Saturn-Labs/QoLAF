package textures
{
	
	public class TextureLocator
	{
		private static var service:ITextureManager;
		
		public function TextureLocator()
		{
			super();
		}
		
		public static function initialize():void
		{
		}
		
		public static function register(param1:ITextureManager):void
		{
			service = param1;
		}
		
		public static function getService():ITextureManager
		{
			return service;
		}
	}
}
