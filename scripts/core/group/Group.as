package core.group {
	import core.hud.components.chat.MessageLog;
	import core.player.Player;
	import core.scene.Game;
	
	public class Group {
		private var _players:Vector.<Player> = new Vector.<Player>();
		
		private var _id:String;
		
		private var g:Game;
		
		public function Group(g:Game, id:String) {
			super();
			this._id = id;
			this.g = g;
		}
		
		public function get id() : String {
			return _id;
		}
		
		public function addPlayer(p:Player) : void {
			if(_players.indexOf(p) != -1) {
				return;
			}
			p.group = this;
			if(_players.length > 1 && g.me != null) {
				if(p != g.me && this != g.me.group) {
					MessageLog.write(p.name + " joined a group.");
				} else if(p == g.me) {
					MessageLog.write("You joined a group.");
				} else if(this == g.me.group) {
					MessageLog.write(p.name + " joined your group.");
				}
			}
			_players.push(p);
			for each(var _local2 in _players) {
				if(_local2.ship != null) {
					_local2.ship.updateLabel();
				}
			}
		}
		
		public function removePlayer(p:Player) : void {
			if(_players.indexOf(p) == -1) {
				return;
			}
			if(_players.length > 1) {
				if(p != g.me && this != g.me.group) {
					MessageLog.write(p.name + " left a group.");
				} else if(p == g.me) {
					MessageLog.write("You left your group.");
				} else if(this == g.me.group) {
					MessageLog.write(p.name + " left your group.");
				}
			}
			_players.splice(_players.indexOf(p),1);
			for each(var _local2 in _players) {
				if(_local2.ship != null) {
					_local2.ship.updateLabel();
				}
			}
		}
		
		public function get length() : int {
			return _players.length;
		}
		
		public function get players() : Vector.<Player> {
			return _players;
		}
	}
}

