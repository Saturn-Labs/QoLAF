package core.group
{
	import core.hud.components.chat.MessageLog;
	import core.player.Player;
	import core.scene.Game;
	
	public class Group
	{
		private var _players:Vector.<Player>;
		
		private var _id:String;
		
		private var g:Game;
		
		public function Group(param1:Game, param2:String)
		{
			_players = new Vector.<Player>();
			super();
			this._id = param2;
			this.g = param1;
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function addPlayer(param1:Player):void
		{
			if (_players.indexOf(param1) != -1)
			{
				return;
			}
			param1.group = this;
			if (_players.length > 1 && g.me != null)
			{
				if (param1 != g.me && this != g.me.group)
				{
					MessageLog.write(param1.name + " joined a group.");
				}
				else if (param1 == g.me)
				{
					MessageLog.write("You joined a group.");
				}
				else if (this == g.me.group)
				{
					MessageLog.write(param1.name + " joined your group.");
				}
			}
			_players.push(param1);
			for each (var _loc2_:* in _players)
			{
				if (_loc2_.ship != null)
				{
					_loc2_.ship.updateLabel();
				}
			}
		}
		
		public function removePlayer(param1:Player):void
		{
			if (_players.indexOf(param1) == -1)
			{
				return;
			}
			if (_players.length > 1)
			{
				if (param1 != g.me && this != g.me.group)
				{
					MessageLog.write(param1.name + " left a group.");
				}
				else if (param1 == g.me)
				{
					MessageLog.write("You left your group.");
				}
				else if (this == g.me.group)
				{
					MessageLog.write(param1.name + " left your group.");
				}
			}
			_players.splice(_players.indexOf(param1), 1);
			for each (var _loc2_:* in _players)
			{
				if (_loc2_.ship != null)
				{
					_loc2_.ship.updateLabel();
				}
			}
		}
		
		public function get length():int
		{
			return _players.length;
		}
		
		public function get players():Vector.<Player>
		{
			return _players;
		}
	}
}
