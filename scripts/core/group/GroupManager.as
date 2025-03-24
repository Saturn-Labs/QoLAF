package core.group {
	import core.hud.components.chat.MessageLog;
	import core.player.Invite;
	import core.player.Player;
	import core.scene.Game;
	import debug.Console;
	import playerio.Message;
	import starling.events.EventDispatcher;
	
	public class GroupManager extends EventDispatcher {
		private var g:Game;
		
		private var _groups:Vector.<Group>;
		
		private var _invites:Vector.<Invite>;
		
		public function GroupManager(g:Game) {
			super();
			this.g = g;
			_groups = new Vector.<Group>();
			_invites = new Vector.<Invite>();
		}
		
		public function addMessageHandlers() : void {
			g.addMessageHandler("addToGroup",addToGroup);
			g.addMessageHandler("removeFromGroup",removeFromGroup);
			g.addMessageHandler("addGroupInvite",addGroupInvite);
			g.addMessageHandler("cancelGroupInvite",cancelGroupInvite);
		}
		
		public function get groups() : Vector.<Group> {
			return _groups;
		}
		
		private function addToGroup(m:Message) : void {
			var _local3:String = m.getString(0);
			var _local2:String = m.getString(1);
			var _local4:Player = g.playerManager.playersById[_local2];
			if(_local4 == null) {
				Console.write("Add to group failed, player is null! Key: " + _local2);
				return;
			}
			var _local5:Group = getGroupById(_local3);
			if(_local5 == null) {
				Console.write("Created new group, id: " + _local3);
				_local5 = new Group(g,_local3);
				_groups.push(_local5);
			}
			if(_local4 == g.me || _local5 == g.me.group) {
				removeInvites();
			}
			_local5.addPlayer(_local4);
			dispatchEventWith("update");
		}
		
		public function autoJoinOrCreateGroup(player:Player, id:String) : void {
			var _local3:Group = getGroupById(id);
			if(_local3 == null) {
				_local3 = new Group(g,id);
				_groups.push(_local3);
			}
			_local3.addPlayer(player);
			dispatchEventWith("update");
		}
		
		private function removeFromGroup(m:Message) : void {
			var _local3:String = m.getString(0);
			var _local2:String = m.getString(1);
			var _local4:Group = getGroupById(_local3);
			if(_local4 == null) {
				Console.write("Group doesn\'t exist on remove.");
				return;
			}
			var _local5:Player = g.playerManager.playersById[_local2];
			if(_local5 == null) {
				Console.write("Remove from group failed, player is null! Key: " + _local2);
				return;
			}
			_local5.group = new Group(g,_local5.id);
			_local4.removePlayer(_local5);
			if(_local4.length == 0) {
				_groups.splice(_groups.indexOf(_local4),1);
			}
			dispatchEventWith("update");
		}
		
		private function addGroupInvite(m:Message) : void {
			var _local4:String = m.getString(0);
			var _local3:String = m.getString(1);
			var _local2:String = m.getString(2);
			var _local5:Player = g.playerManager.playersById[_local3];
			var _local8:Group = getGroupById(_local4);
			if(_local5 == null) {
				Console.write("Invite failed, invited player is null! Key: " + _local3);
				return;
			}
			var _local6:Player = g.playerManager.playersById[_local2];
			if(_local6 == null) {
				Console.write("Invite failed, inviter is null! Key: " + _local2);
				return;
			}
			if(findInvite(_local4,_local5) != null) {
				Console.write("player is already invited. Name: " + _local5.name);
				return;
			}
			var _local7:Invite = new Invite(g,_local4,_local5,_local6);
			_local7.x = 100;
			_local7.y = 100;
			_invites.push(_local7);
			g.hud.playerListButton.hintNew();
			MessageLog.write(_local6.name + " has invited you to a group. Type <FONT COLOR=\'#44ff44\'>/y</FONT> to accept");
			dispatchEventWith("update");
		}
		
		public function findInvite(groupId:String, invited:Player) : Invite {
			for each(var _local3 in _invites) {
				if(_local3.id == groupId && invited == _local3.invited) {
					return _local3;
				}
			}
			return null;
		}
		
		private function removeInvites() : void {
			_invites.splice(0,_invites.length);
		}
		
		public function acceptGroupInvite(id:String = null) : void {
			if(id == null && _invites.length > 0) {
				id = _invites[_invites.length - 1].id;
			}
			if(id != null) {
				g.send("acceptGroupInvite",id);
			}
		}
		
		public function cancelGroupInvite(id:String) : void {
			var _local3:int = 0;
			var _local2:Invite = null;
			_local3 = _invites.length - 1;
			while(_local3 > -1) {
				_local2 = _invites[_local3];
				if(_local2.id == id) {
					_invites.splice(_invites.indexOf(_local2),1);
				}
				_local3--;
			}
			g.send("cancelGroupInvite",id);
		}
		
		public function getGroupById(id:String) : Group {
			for each(var _local2 in _groups) {
				if(_local2.id == id) {
					return _local2;
				}
			}
			return null;
		}
		
		public function invitePlayer(player:Player) : void {
			g.send("inviteToGroup",player.id);
		}
		
		public function leaveGroup() : void {
			g.send("leaveGroup");
		}
	}
}

