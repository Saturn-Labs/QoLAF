package core.friend {
	import core.hud.components.chat.MessageLog;
	import core.player.Player;
	import core.scene.Game;
	import playerio.Message;
	
	public class FriendManager {
		private var g:Game;
		
		private var me:Player;
		
		private var requests:Array = [];
		
		private var onlineFriendsCallback:Function;
		
		public function FriendManager(g:Game) {
			super();
			this.g = g;
		}
		
		public function addMessageHandlers() : void {
			g.addMessageHandler("friendRequest",friendRequest);
			g.addMessageHandler("addFriend",addFriend);
			g.addMessageHandler("removeFriend",removeFriendRecieved);
			g.addServiceMessageHandler("onlineFriends",onOnlineFriends);
		}
		
		public function init(me:Player, forceFetch:Boolean = false) : void {
			this.me = me;
			if(Player.friends != null && !forceFetch) {
				return;
			}
			Player.friends = new Vector.<Friend>();
			g.rpc("getFriends",function(param1:Message):void {
				var _local3:int = 0;
				var _local2:Friend = null;
				_local3 = 0;
				while(_local3 < param1.length) {
					_local2 = new Friend();
					_local2.id = param1.getString(_local3);
					Player.friends.push(_local2);
					_local3++;
				}
			});
		}
		
		public function updateOnlineFriends(callback:Function) : void {
			onlineFriendsCallback = callback;
			g.sendToServiceRoom("getOnlineFriends");
		}
		
		private function onOnlineFriends(m:Message) : void {
			var _local2:Friend = null;
			if(onlineFriendsCallback == null) {
				return;
			}
			Player.onlineFriends = new Vector.<Friend>();
			var _local3:int = 0;
			while(_local3 < m.length) {
				_local2 = new Friend();
				_local3 = _local2.fill(m,_local3);
				_local2.isOnline = true;
				Player.onlineFriends.push(_local2);
			}
			onlineFriendsCallback();
		}
		
		public function sendFriendRequest(p:Player) : void {
			g.send("sendFriendRequest",p.id);
		}
		
		public function friendRequest(m:Message) : void {
			var _local3:String = m.getString(0);
			var _local2:Player = g.playerManager.playersById[_local3];
			if(_local2 == null) {
				return;
			}
			if(me.isFriendWith(_local2)) {
				return;
			}
			if(requests.indexOf(_local3) != -1) {
				return;
			}
			requests.push(_local3);
			MessageLog.write("<FONT COLOR=\'#88ff88\'>" + _local2.name + " wants to add you as a friend.</FONT>");
			g.hud.playerListButton.hintNew();
		}
		
		public function sendFriendConfirm(p:Player) : void {
			var _local2:int = 0;
			_local2 = 0;
			while(_local2 < requests.length) {
				if(requests[_local2] == p.id) {
					requests.splice(_local2,1);
					break;
				}
				_local2++;
			}
			g.send("friendConfirm",p.id);
		}
		
		public function addFriend(m:Message) : void {
			var _local2:Friend = new Friend();
			_local2.fill(m,0);
			Player.friends.push(_local2);
			MessageLog.write("<FONT COLOR=\'#88ff88\'>You are now friends with " + _local2.name + "</FONT>");
			g.sendToServiceRoom("addFriend",_local2.id);
		}
		
		public function removeFriend(playerId:String) : void {
			var _local2:int = 0;
			_local2 = 0;
			while(_local2 < Player.friends.length) {
				if(Player.friends[_local2].id == playerId) {
					g.sendToServiceRoom("removeFriend",Player.friends[_local2].id);
					Player.friends.splice(_local2,1);
				}
				_local2++;
			}
		}
		
		public function sendRemoveFriend(p:Player) : void {
			removeFriend(p.id);
			g.send("removeFriend",p.id);
		}
		
		public function sendRemoveFriendById(id:String) : void {
			removeFriend(id);
			g.send("removeFriend",id);
		}
		
		public function removeFriendRecieved(m:Message) : void {
			removeFriend(m.getString(0));
		}
		
		public function pendingRequest(p:Player) : Boolean {
			return requests.indexOf(p.id) != -1;
		}
	}
}

