package core.login {
	public class Username {
		public static const RESTRICT:String = "a-zA-Z0-9\\-_";
		
		public static const MIN:int = 15;
		
		public static const MAX:int = 15;
		
		public static const BANNED:Array = ["astroflux","astro flux","benjaminsen","fulafisken","fula fisken","playerio","admin","moderator","game master","gamemaster","[mod]","[gm]","[dev]","[pio]","[ff]"];
		
		public function Username() {
			super();
		}
		
		public static function isBanned(name:String) : Boolean {
			var _local3:String = name.toLocaleLowerCase();
			for each(var _local2 in BANNED) {
				if(_local3.indexOf(_local2) > -1) {
					return true;
				}
			}
			return false;
		}
	}
}

