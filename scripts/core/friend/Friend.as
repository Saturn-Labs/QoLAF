package core.friend {
	import core.scene.Game;
	import playerio.Message;
	
	public class Friend {
		public var id:String;
		
		public var name:String;
		
		public var currentSolarSystem:String;
		
		public var currentRoom:String;
		
		public var skin:String;
		
		public var level:int;
		
		public var reputation:int;
		
		public var clan:String;
		
		public var isOnline:Boolean = false;
		
		private var g:Game;
		
		public function Friend() {
			super();
		}
		
		public function fill(m:Message, i:int) : int {
			this.id = m.getString(i++);
			this.name = m.getString(i++);
			this.currentSolarSystem = m.getString(i++);
			this.currentRoom = m.getString(i++);
			this.skin = m.getString(i++);
			this.level = m.getInt(i++);
			this.reputation = m.getInt(i++);
			this.clan = m.getString(i++);
			return i;
		}
	}
}

