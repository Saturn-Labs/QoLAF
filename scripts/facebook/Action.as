package facebook {
	public class Action {
		private static var ogBaseUrl:String = "http://astroboken.appspot.com/";
		
		public function Action() {
			super();
		}
		
		public static function discover(key:String) : void {
			send("discover","planet",key);
		}
		
		public static function encounter(key:String) : void {
			send("encounter","enemy",key);
		}
		
		public static function hire(image:String, name:String) : void {
			send("hire","crew_member",image,name);
		}
		
		public static function levelUp(level:int) : void {
			send("reach","level",level.toString());
		}
		
		public static function unlockSystem(key:String) : void {
			send("unlock","star_system",key);
		}
		
		public static function unlockWeapon(key:String) : void {
			send("unlock","weapon",key);
		}
		
		public static function unlockShip(key:String) : void {
			send("unlock","ship",key);
		}
		
		public static function join(name:String) : void {
			send("join","clan",name);
		}
		
		private static function send(action:String, object:String, param1:String = "", param2:String = "") : void {
			var objectUrl:String;
			var apiCall:String;
			if(Login.currentState != "facebook") {
				return;
			}
			objectUrl = ogBaseUrl + object;
			if(param1 != "") {
				objectUrl += "/" + param1;
			}
			if(param2 != "") {
				objectUrl += "/" + param2;
			}
			objectUrl = encodeURIComponent(objectUrl);
			apiCall = "/me/astroflux:" + action + "?" + object + "=" + objectUrl;
			try {
				FB.api(apiCall,"post",function(param1:Object):void {
				});
			}
			catch(e:*) {
			}
		}
	}
}

