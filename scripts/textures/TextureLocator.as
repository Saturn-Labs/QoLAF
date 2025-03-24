package textures {
	public class TextureLocator {
		private static var service:ITextureManager;
		
		public function TextureLocator() {
			super();
		}
		
		public static function initialize() : void {
		}
		
		public static function register(s:ITextureManager) : void {
			service = s;
		}
		
		public static function getService() : ITextureManager {
			return service;
		}
	}
}

