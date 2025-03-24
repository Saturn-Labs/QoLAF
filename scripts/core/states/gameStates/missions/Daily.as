package core.states.gameStates.missions {
	public class Daily {
		public static const STATUS_ONGOING:int = 0;
		
		public static const STATUS_COMPLETED:int = 1;
		
		public static const STATUS_CLAIMED:int = 2;
		
		public static const TYPE_KILL:String = "kill";
		
		public static const TYPE_KILL_DISTINCT:String = "kill_distinct";
		
		public static const TYPE_LAND:String = "land_on_planet";
		
		public static const TYPE_UPGRADE_TECH:String = "upgrade_tect";
		
		public static const TYPE_PVP:String = "win_pvp";
		
		public static const TYPE_CAPTURE:String = "capture_planet";
		
		public static const TYPE_PICKUP:String = "pickup";
		
		public static const TYPE_HEAL:String = "heal_player";
		
		public static const TYPE_SURVIVAL:String = "play_survival";
		
		public var key:String;
		
		public var status:int = 0;
		
		public var progress:int;
		
		public var json:Object;
		
		public var level:int;
		
		public var name:String;
		
		public var description:String;
		
		public var reward:Object;
		
		public function Daily(key:String, json:Object) {
			super();
			this.key = key;
			this.json = json;
			this.level = json.level;
			this.name = json.name;
			this.description = json.description;
			this.reward = json.reward;
		}
		
		public function get missionGoal() : int {
			return json.targets.count;
		}
		
		public function get complete() : Boolean {
			return this.status == 1;
		}
		
		public function get isClaimed() : Boolean {
			return this.status == 2;
		}
	}
}

