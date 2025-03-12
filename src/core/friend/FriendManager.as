package core.friend
{
	import core.hud.components.chat.MessageLog;
	import core.player.Player;
	import core.scene.Game;
	import playerio.Message;
	
	public class FriendManager
	{
		private var g:Game;
		
		private var me:Player;
		
		private var requests:Array;
		
		private var onlineFriendsCallback:Function;
		
		public function FriendManager(param1:Game)
		{
			requests = [];
			super();
			this.g = param1;
		}
		
		public function addMessageHandlers():void
		{
			g.addMessageHandler("friendRequest", friendRequest);
			g.addMessageHandler("addFriend", addFriend);
			g.addMessageHandler("removeFriend", removeFriendRecieved);
			g.addServiceMessageHandler("onlineFriends", onOnlineFriends);
		}
		
		public function init(param1:Player, param2:Boolean = false):void
		{
			var me:Player = param1;
			var forceFetch:Boolean = param2;
			this.me = me;
			if (Player.friends != null && !forceFetch)
			{
				return;
			}
			Player.friends = new Vector.<Friend>();
			g.rpc("getFriends", function(param1:Message):void
			{
				var _loc3_:int = 0;
				var _loc2_:Friend = null;
				_loc3_ = 0;
				while (_loc3_ < param1.length)
				{
					_loc2_ = new Friend();
					_loc2_.id = param1.getString(_loc3_);
					Player.friends.push(_loc2_);
					_loc3_++;
				}
			});
		}
		
		public function updateOnlineFriends(param1:Function):void
		{
			onlineFriendsCallback = param1;
			g.sendToServiceRoom("getOnlineFriends");
		}
		
		private function onOnlineFriends(param1:Message):void
		{
			var _loc2_:Friend = null;
			if (onlineFriendsCallback == null)
			{
				return;
			}
			Player.onlineFriends = new Vector.<Friend>();
			var _loc3_:int = 0;
			while (_loc3_ < param1.length)
			{
				_loc2_ = new Friend();
				_loc3_ = _loc2_.fill(param1, _loc3_);
				_loc2_.isOnline = true;
				Player.onlineFriends.push(_loc2_);
			}
			onlineFriendsCallback();
		}
		
		public function sendFriendRequest(param1:Player):void
		{
			g.send("sendFriendRequest", param1.id);
		}
		
		public function friendRequest(param1:Message):void
		{
			var _loc3_:String = param1.getString(0);
			var _loc2_:Player = g.playerManager.playersById[_loc3_];
			if (_loc2_ == null)
			{
				return;
			}
			if (me.isFriendWith(_loc2_))
			{
				return;
			}
			if (requests.indexOf(_loc3_) != -1)
			{
				return;
			}
			requests.push(_loc3_);
			MessageLog.write("<FONT COLOR='#88ff88'>" + _loc2_.name + " wants to add you as a friend.</FONT>");
			g.hud.playerListButton.hintNew();
		}
		
		public function sendFriendConfirm(param1:Player):void
		{
			var _loc2_:int = 0;
			_loc2_ = 0;
			while (_loc2_ < requests.length)
			{
				if (requests[_loc2_] == param1.id)
				{
					requests.splice(_loc2_, 1);
					break;
				}
				_loc2_++;
			}
			g.send("friendConfirm", param1.id);
		}
		
		public function addFriend(param1:Message):void
		{
			var _loc2_:Friend = new Friend();
			_loc2_.fill(param1, 0);
			Player.friends.push(_loc2_);
			MessageLog.write("<FONT COLOR='#88ff88'>You are now friends with " + _loc2_.name + "</FONT>");
			g.sendToServiceRoom("addFriend", _loc2_.id);
		}
		
		public function removeFriend(param1:String):void
		{
			var _loc2_:int = 0;
			_loc2_ = 0;
			while (_loc2_ < Player.friends.length)
			{
				if (Player.friends[_loc2_].id == param1)
				{
					g.sendToServiceRoom("removeFriend", Player.friends[_loc2_].id);
					Player.friends.splice(_loc2_, 1);
				}
				_loc2_++;
			}
		}
		
		public function sendRemoveFriend(param1:Player):void
		{
			removeFriend(param1.id);
			g.send("removeFriend", param1.id);
		}
		
		public function sendRemoveFriendById(param1:String):void
		{
			removeFriend(param1);
			g.send("removeFriend", param1);
		}
		
		public function removeFriendRecieved(param1:Message):void
		{
			removeFriend(param1.getString(0));
		}
		
		public function pendingRequest(param1:Player):Boolean
		{
			return requests.indexOf(param1.id) != -1;
		}
	}
}
