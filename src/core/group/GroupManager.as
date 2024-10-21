package core.group
{
	import core.hud.components.chat.MessageLog;
	import core.player.Invite;
	import core.player.Player;
	import core.scene.Game;
	import debug.Console;
	import playerio.Message;
	import starling.events.EventDispatcher;
	
	public class GroupManager extends EventDispatcher
	{
		private var g:Game;
		
		private var _groups:Vector.<Group>;
		
		private var _invites:Vector.<Invite>;
		
		public function GroupManager(param1:Game)
		{
			super();
			this.g = param1;
			_groups = new Vector.<Group>();
			_invites = new Vector.<Invite>();
		}
		
		public function addMessageHandlers():void
		{
			g.addMessageHandler("addToGroup", addToGroup);
			g.addMessageHandler("removeFromGroup", removeFromGroup);
			g.addMessageHandler("addGroupInvite", addGroupInvite);
			g.addMessageHandler("cancelGroupInvite", cancelGroupInvite);
		}
		
		public function get groups():Vector.<Group>
		{
			return _groups;
		}
		
		private function addToGroup(param1:Message):void
		{
			var _loc2_:String = param1.getString(0);
			var _loc4_:String = param1.getString(1);
			var _loc3_:Player = g.playerManager.playersById[_loc4_];
			if (_loc3_ == null)
			{
				Console.write("Add to group failed, player is null! Key: " + _loc4_);
				return;
			}
			var _loc5_:Group = getGroupById(_loc2_);
			if (_loc5_ == null)
			{
				Console.write("Created new group, id: " + _loc2_);
				_loc5_ = new Group(g, _loc2_);
				_groups.push(_loc5_);
			}
			if (_loc3_ == g.me || _loc5_ == g.me.group)
			{
				removeInvites();
			}
			_loc5_.addPlayer(_loc3_);
			dispatchEventWith("update");
		}
		
		public function autoJoinOrCreateGroup(param1:Player, param2:String):void
		{
			var _loc3_:Group = getGroupById(param2);
			if (_loc3_ == null)
			{
				_loc3_ = new Group(g, param2);
				_groups.push(_loc3_);
			}
			_loc3_.addPlayer(param1);
			dispatchEventWith("update");
		}
		
		private function removeFromGroup(param1:Message):void
		{
			var _loc2_:String = param1.getString(0);
			var _loc4_:String = param1.getString(1);
			var _loc5_:Group = getGroupById(_loc2_);
			if (_loc5_ == null)
			{
				Console.write("Group doesn't exist on remove.");
				return;
			}
			var _loc3_:Player = g.playerManager.playersById[_loc4_];
			if (_loc3_ == null)
			{
				Console.write("Remove from group failed, player is null! Key: " + _loc4_);
				return;
			}
			_loc3_.group = new Group(g, _loc3_.id);
			_loc5_.removePlayer(_loc3_);
			if (_loc5_.length == 0)
			{
				_groups.splice(_groups.indexOf(_loc5_), 1);
			}
			dispatchEventWith("update");
		}
		
		private function addGroupInvite(param1:Message):void
		{
			var _loc4_:String = param1.getString(0);
			var _loc6_:String = param1.getString(1);
			var _loc5_:String = param1.getString(2);
			var _loc8_:Player = g.playerManager.playersById[_loc6_];
			var _loc7_:Group = getGroupById(_loc4_);
			if (_loc8_ == null)
			{
				Console.write("Invite failed, invited player is null! Key: " + _loc6_);
				return;
			}
			var _loc3_:Player = g.playerManager.playersById[_loc5_];
			if (_loc3_ == null)
			{
				Console.write("Invite failed, inviter is null! Key: " + _loc5_);
				return;
			}
			if (findInvite(_loc4_, _loc8_) != null)
			{
				Console.write("player is already invited. Name: " + _loc8_.name);
				return;
			}
			var _loc2_:Invite = new Invite(g, _loc4_, _loc8_, _loc3_);
			_loc2_.x = 100;
			_loc2_.y = 100;
			_invites.push(_loc2_);
			g.hud.playerListButton.hintNew();
			MessageLog.write(_loc3_.name + " has invited you to a group. Type <FONT COLOR='#44ff44'>/y</FONT> to accept");
			dispatchEventWith("update");
		}
		
		public function findInvite(param1:String, param2:Player):Invite
		{
			for each (var _loc3_:* in _invites)
			{
				if (_loc3_.id == param1 && param2 == _loc3_.invited)
				{
					return _loc3_;
				}
			}
			return null;
		}
		
		private function removeInvites():void
		{
			_invites.splice(0, _invites.length);
		}
		
		public function acceptGroupInvite(param1:String = null):void
		{
			if (param1 == null && _invites.length > 0)
			{
				param1 = _invites[_invites.length - 1].id;
			}
			if (param1 != null)
			{
				g.send("acceptGroupInvite", param1);
			}
		}
		
		public function cancelGroupInvite(param1:String):void
		{
			var _loc3_:int = 0;
			var _loc2_:Invite = null;
			_loc3_ = _invites.length - 1;
			while (_loc3_ > -1)
			{
				_loc2_ = _invites[_loc3_];
				if (_loc2_.id == param1)
				{
					_invites.splice(_invites.indexOf(_loc2_), 1);
				}
				_loc3_--;
			}
			g.send("cancelGroupInvite", param1);
		}
		
		public function getGroupById(param1:String):Group
		{
			for each (var _loc2_:* in _groups)
			{
				if (_loc2_.id == param1)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		public function invitePlayer(param1:Player):void
		{
			g.send("inviteToGroup", param1.id);
		}
		
		public function leaveGroup():void
		{
			g.send("leaveGroup");
		}
	}
}
