package joinRoom {
	public class Room {
		public static const SYSTEM_TYPE_FRIENDLY:String = "friendly";
		
		public static const SYSTEM_TYPE_HOSTILE:String = "hostile";
		
		public static const SYSTEM_TYPE_DEATHMATCH:String = "deathmatch";
		
		public static const SYSTEM_TYPE_DOMINATION:String = "domination";
		
		public static const SYSTEM_TYPE_ARENA:String = "arena";
		
		public static const SYSTEM_TYPE_SURVIVAL:String = "survival";
		
		public static const SYSTEM_TYPE_CLAN:String = "clan";
		
		public var id:String;
		
		public var roomType:String;
		
		public var joinData:Object;
		
		public var data:Object;
		
		public function Room() {
			super();
		}
	}
}

