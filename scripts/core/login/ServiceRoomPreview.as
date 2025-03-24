package core.login {
	import com.greensock.TweenMax;
	import core.friend.Friend;
	import core.hud.components.Text;
	import playerio.Connection;
	import playerio.Message;
	import playerio.PlayerIOError;
	import playerio.RoomInfo;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	
	public class ServiceRoomPreview extends Sprite {
		public static var WIDTH:int = 300;
		
		public static const roomNames:Array = ["alpha","beta","gamma","delta","epsilon","zeta","eta","theta","iota","kappa","lambda","mu","beta","nu","xi","omicron","pi","rho","sigma","tau","upsilon","phi","chi","psi","omega"];
		
		public var info:RoomInfo;
		
		private var name:Text = new Text();
		
		private var online:Text = new Text();
		
		private var friends:Text = new Text();
		
		private var status:Text = new Text();
		
		private var level:Text = new Text();
		
		private var recommended:Text = new Text();
		
		private var recommendedBg:Quad;
		
		private var connection:Connection;
		
		private var selectCallback:Function;
		
		public var enabled:Boolean = false;
		
		public var even:Boolean = true;
		
		private var serviceRoomSelector:ServiceRoomSelector;
		
		private var bg:Quad;
		
		private var isSupporter:Boolean = false;
		
		public var avgLevel:int = -1;
		
		public var playerLevel:int = -1;
		
		private var onlineFriends:Vector.<Friend>;
		
		private var friendsTooltip:Sprite;
		
		public var isClosing:Boolean = false;
		
		public function ServiceRoomPreview(info:RoomInfo, selectCallback:Function, serviceRoomSelector:ServiceRoomSelector) {
			super();
			this.info = info;
			this.selectCallback = selectCallback;
			this.serviceRoomSelector = serviceRoomSelector;
			bg = new Quad(WIDTH,50,0);
			bg.alpha = 0.7;
			addChild(bg);
			name.color = 0xffffff;
			online.color = 0xff00;
			friends.color = 10854300;
			status.color = 10854300;
			level.color = status.color;
			recommended.color = 16441344;
			status.alignRight();
			level.alignRight();
			name.text = getName().toUpperCase();
			name.size = 12;
			status.size = 14;
			online.text = info.onlineUsers + " ONLINE";
			if(info.onlineUsers == 0) {
				online.text = "EMPTY";
				online.color = 10854300;
			}
			online.size = 11;
			friends.size = 11;
			recommended.text = "RECOMMENDED";
			recommendedBg = new Quad(recommended.width - 1,recommended.height - 12,0);
			recommendedBg.alpha = 0.7;
			var _local4:int = 5;
			name.y = online.y = level.y = _local4;
			name.x = friends.x = 5;
			online.x = name.x + name.width + _local4 / 2;
			friends.y = name.y + name.height;
			status.y = friends.y;
			status.x = bg.width - _local4;
			level.x = status.x;
			recommended.y = y - recommended.height / 3;
			recommended.x = width / 2 - recommended.width / 2;
			recommended.visible = false;
			recommendedBg.visible = false;
			recommendedBg.x = recommended.x - 1;
			recommendedBg.y = recommended.y;
			bg.height = status.y + status.height + 22;
			addChild(name);
			addChild(friends);
			addChild(online);
			addChild(status);
			addChild(level);
			addChild(recommendedBg);
			addChild(recommended);
			addEventListener("touch",onTouch);
			useHandCursor = true;
			if(name.text == "") {
				this.enabled = false;
			} else {
				join();
			}
		}
		
		private function onTouch(e:TouchEvent) : void {
			if(e.getTouch(this) == null) {
				hideFriends();
			}
			if(e.getTouch(this,"hover")) {
				showFriendsTooltip();
			}
			if(!enabled) {
				return;
			}
			if(e.getTouch(this,"ended")) {
				enabled = false;
				selectRoom();
			}
		}
		
		public function selectRoom() : void {
			selectCallback(this,info.id);
		}
		
		private function getName() : String {
			var _local1:int = getIndex();
			if(_local1 > roomNames.length - 1) {
				return "n/a";
			}
			if(!roomNames[_local1]) {
				return "";
			}
			return roomNames[_local1];
		}
		
		private function getIndex() : int {
			var _local2:Number = NaN;
			var _local1:Array = info.id.split("_");
			if(_local1.length == 2) {
				_local2 = Number(_local1[1]);
				if(!isNaN(_local2)) {
					return _local2;
				}
			}
			return -1;
		}
		
		public function isOpenForAll() : Boolean {
			return info.onlineUsers < 950;
		}
		
		public function isOpenForSupporters() : Boolean {
			return info.onlineUsers < 1000;
		}
		
		private function validate() : Boolean {
			if(getIndex() < 0) {
				return false;
			}
			if(getIndex() > roomNames.length - 1) {
				return false;
			}
			return true;
		}
		
		private function join() : void {
			if(!validate()) {
				this.visible = false;
				return;
			}
			if(info.onlineUsers == 0) {
				updateStatus();
				return;
			}
			friends.text = "Looking for friends...";
			Login.client.multiplayer.joinRoom(info.id,{
				"client_version":23 * 60,
				"preview":"true"
			},joined,function(param1:PlayerIOError):void {
				var _local2:String = null;
				if(param1.errorID != 2) {
					_local2 = param1.message;
					if(_local2.indexOf("The room cannot") > -1) {
						full(true);
					} else {
						status.text = "An error occured...";
					}
					trace(_local2);
					friends.color = 0xff0000;
				}
			});
		}
		
		private function joined(c:Connection) : void {
			connection = c;
			connection.addMessageHandler("onlineFriends",onOnlineFriends);
			connection.addMessageHandler("preview",onPreview);
			connection.addMessageHandler("error",function(param1:Message):void {
				friends.text = param1.getString(0);
				friends.color = 0xff0000;
			});
		}
		
		private function onPreview(m:Message) : void {
			isSupporter = m.getBoolean(0);
			ServiceRoomSelector.isSupporter = isSupporter;
			playerLevel = m.getInt(1);
			ServiceRoomSelector.playerLevel = playerLevel;
			avgLevel = m.getInt(2);
			level.text = "Avg level " + avgLevel;
			serviceRoomSelector.updateRecommended();
			if(playerLevel == 0) {
				serviceRoomSelector.setNewPlayer();
			}
		}
		
		private function onOnlineFriends(m:Message) : void {
			var _local3:Friend = null;
			onlineFriends = new Vector.<Friend>();
			var _local4:int = 0;
			var _local2:String = "";
			while(_local4 < m.length) {
				_local3 = new Friend();
				_local4 = _local3.fill(m,_local4);
				_local3.isOnline = true;
				onlineFriends.push(_local3);
				_local2 += _local3.name + ", ";
			}
			_local2 = _local2.substr(0,_local2.length - 2);
			if(onlineFriends.length > 0) {
				friends.text = onlineFriends.length + " friends online";
			} else {
				friends.text = " ";
			}
			updateStatus();
			showFriendsTooltip();
		}
		
		private function showFriendsTooltip() : void {
			var _local2:int = 0;
			var _local3:Text = null;
			if(!onlineFriends) {
				return;
			}
			if(friendsTooltip != null) {
				friendsTooltip.visible = true;
				return;
			}
			if(onlineFriends.length == 0) {
				return;
			}
			friendsTooltip = new Sprite();
			_local2 = 0;
			while(_local2 < onlineFriends.length) {
				_local3 = new Text(3,3);
				_local3.text = onlineFriends[_local2].name;
				_local3.color = 0;
				_local3.y += _local2 * (_local3.height - 1);
				_local3.size = 10;
				friendsTooltip.addChild(_local3);
				_local2++;
			}
			var _local1:Quad = new Quad(friendsTooltip.width + 10,friendsTooltip.height + 3,0xff00);
			_local1.alpha = 0.3;
			friendsTooltip.addChildAt(_local1,0);
			if(even) {
				friendsTooltip.x = 0 - friendsTooltip.width;
			} else {
				friendsTooltip.x = width;
			}
			friendsTooltip.y = 0;
			addChild(friendsTooltip);
			hideFriends();
		}
		
		private function hideFriends() : void {
			if(!friendsTooltip) {
				return;
			}
			friendsTooltip.visible = false;
		}
		
		private function updateStatus() : void {
			if(isClosing) {
				return;
			}
			if(isOpenForAll()) {
				status.text = "JOIN >";
				status.color = 0xff00;
				enabled = true;
				return;
			}
			if(isOpenForSupporters()) {
				status.size = 10;
				status.text = "OPEN FOR SUPPORTERS >";
				status.color = 16426240;
				status.y += 3;
				if(isSupporter) {
					enabled = true;
				}
				return;
			}
			full();
		}
		
		public function disable() : void {
			enabled = false;
			this.removeEventListeners();
			TweenMax.to(this,0.3,{"alpha":0});
		}
		
		public function highlight() : void {
			var _local1:Quad = new Quad(bg.width + 4,bg.height + 4,11150770);
			_local1.x = -2;
			_local1.y = -2;
			bg.alpha = 0.9;
			addChildAt(_local1,0);
		}
		
		private function full(fromError:Boolean = false) : void {
			status.text = "FULL";
			status.color = 0xff0000;
			if(fromError) {
				online.text = "1000 online";
				friends.text = "";
			}
		}
		
		public function trySetClosing() : void {
			var _local1:int = ServiceRoomSelector.totalFree - info.onlineUsers;
			if(_local1 < 950) {
				return;
			}
			status.text = "CLOSING DOWN";
			status.color = 13202944;
			status.size = 10;
			status.y += 3;
			enabled = false;
			isClosing = true;
			useHandCursor = false;
			alpha = 0.5;
		}
		
		public function setRecommended(v:Boolean) : void {
			recommended.visible = v;
			recommendedBg.visible = v;
		}
	}
}

