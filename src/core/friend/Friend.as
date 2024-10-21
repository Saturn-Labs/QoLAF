package core.friend
{
	import core.scene.Game;
	import playerio.Message;
	
	public class Friend
	{
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
		
		public function Friend()
		{
			super();
		}
		
		public function fill(param1:Message, param2:int):int
		{
			this.id = param1.getString(param2++);
			this.name = param1.getString(param2++);
			this.currentSolarSystem = param1.getString(param2++);
			this.currentRoom = param1.getString(param2++);
			this.skin = param1.getString(param2++);
			this.level = param1.getInt(param2++);
			this.reputation = param1.getInt(param2++);
			this.clan = param1.getString(param2++);
			return param2;
		}
	}
}
