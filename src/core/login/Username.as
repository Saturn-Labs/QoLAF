package core.login
{
	public class Username
	{
		public static const RESTRICT:String = "a-zA-Z0-9\\-_";

		public static const MIN:int = 15;

		public static const MAX:int = 15;

		public static const BANNED:Array = ["astroflux", "astro flux", "benjaminsen", "fulafisken", "fula fisken", "playerio", "admin", "moderator", "game master", "gamemaster", "[mod]", "[gm]", "[dev]", "[pio]", "[ff]"];

		public function Username()
		{
			super();
		}

		public static function isBanned(param1:String):Boolean
		{
			var _loc3_:String = param1.toLocaleLowerCase();
			for each (var _loc2_:* in BANNED)
			{
				if (_loc3_.indexOf(_loc2_) > -1)
				{
					return true;
				}
			}
			return false;
		}
	}
}
