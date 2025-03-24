package core.login {
	import com.greensock.TweenMax;
	import core.hud.components.Text;
	import joinRoom.JoinRoomManager;
	import playerio.RoomInfo;
	import starling.display.Sprite;
	
	public class ServiceRoomSelector extends Sprite {
		public static const FULL:int = 1000;
		
		public static const OPEN_SUPPORTERS:int = 950;
		
		public static const NEW_ROOM_THRESHOLD:int = 950;
		
		public static var playerLevel:int = 0;
		
		public static var isSupporter:Boolean = false;
		
		public static var totalFree:int = 0;
		
		private var rooms:Array;
		
		private var roomPreviews:Array = [];
		
		private var callback:Function;
		
		private var isAutoSelectingRoom:Boolean = false;
		
		public function ServiceRoomSelector(rooms:Array, callback:Function) {
			super();
			this.callback = callback;
			this.rooms = rooms;
			updateTotalFree();
			addRooms();
			var _local3:Text = new Text();
			_local3.text = "Select sector:";
			_local3.y = -50;
			_local3.size = 20;
			_local3.color = 4222876;
			addChild(_local3);
			_local3.x = width / 2 - _local3.width / 2;
			_local3.blendMode = "add";
		}
		
		public function updateRecommended() : void {
			var _local3:* = null;
			var _local4:int = 0;
			var _local1:int = 0;
			for each(var _local2 in roomPreviews) {
				_local2.setRecommended(false);
				if(_local2.playerLevel >= 0) {
					if(!_local3) {
						_local3 = _local2;
					} else if(_local2.isOpenForAll()) {
						_local4 = Math.abs(_local2.avgLevel - playerLevel);
						_local1 = Math.abs(_local3.avgLevel - playerLevel);
						if(_local4 < _local1) {
							_local3 = _local2;
						}
					}
				}
			}
			if(_local3) {
				_local3.setRecommended(true);
			}
		}
		
		private function onSelect(component:ServiceRoomPreview, id:String) : void {
			var r:ServiceRoomPreview;
			for each(r in roomPreviews) {
				if(r == component) {
					r.highlight();
				} else {
					r.disable();
				}
			}
			TweenMax.delayedCall(0.4,function():void {
				callback(id);
			});
		}
		
		private function addRooms() : void {
			var ri:RoomInfo;
			var r:ServiceRoomPreview;
			var nextId:int;
			var name:String;
			var info:RoomInfo;
			var newRoom:ServiceRoomPreview;
			var i:int = 0;
			var padding:int = 30;
			var nextY:int = 0;
			var usedIds:Array = [];
			rooms.sort(function(param1:Object, param2:Object):int {
				if(param1.onlineUsers < param2.onlineUsers || param1.onlineUsers >= 1000) {
					return 1;
				}
				return -1;
			});
			for each(ri in rooms) {
				r = new ServiceRoomPreview(ri,onSelect,this);
				roomPreviews.push(r);
				addChild(r);
				r.y = nextY;
				if(rooms.length < 5) {
					nextY += r.height + 20;
				} else {
					if(i % 2 == 0) {
						r.x = 0;
					} else if(i % 2 == 1) {
						r.x = r.width + padding;
						nextY += r.height + 20;
						r.even = false;
					}
					i++;
				}
			}
			if(totalFree > 950) {
				handleRoomClosing();
				return;
			}
			nextId = getNextRoomIndex();
			name = JoinRoomManager.getServiceRoomID(nextId);
			info = new RoomInfo(name,"service",0,{});
			newRoom = new ServiceRoomPreview(info,onSelect,this);
			newRoom.y = nextY;
			addChild(newRoom);
			roomPreviews.unshift(newRoom);
		}
		
		private function handleRoomClosing() : void {
			var _local2:* = null;
			for each(var _local1 in roomPreviews) {
				if(_local2 == null) {
					_local2 = _local1;
				} else if(_local1.info.onlineUsers < _local2.info.onlineUsers) {
					_local2 = _local1;
				}
			}
			_local2.trySetClosing();
		}
		
		public function getFree(room:RoomInfo) : int {
			var _local2:int = 950 - room.onlineUsers;
			if(_local2 < 0) {
				_local2 = 0;
			}
			return _local2;
		}
		
		public function updateTotalFree() : void {
			totalFree = 0;
			for each(var _local1 in rooms) {
				totalFree += getFree(_local1);
			}
		}
		
		private function getNextRoomIndex() : int {
			var _local4:int = 0;
			var _local1:Boolean = false;
			var _local2:Array = null;
			var _local6:Number = NaN;
			var _local5:Array = [];
			_local4 = 0;
			while(_local4 < 1000) {
				_local1 = false;
				for each(var _local3 in rooms) {
					_local2 = _local3.id.split("_");
					if(_local2.length == 2) {
						_local6 = Number(_local2[1]);
						if(_local6 == _local4) {
							_local1 = true;
						}
					}
				}
				if(!_local1) {
					return _local4;
				}
				_local4++;
			}
			return 10000;
		}
		
		public function setNewPlayer() : void {
			if(isAutoSelectingRoom) {
				return;
			}
			isAutoSelectingRoom = true;
			this.visible = false;
			TweenMax.delayedCall(2,connectToBestNoobRoom);
		}
		
		private function connectToBestNoobRoom() : void {
			var _local2:* = null;
			for each(var _local1 in roomPreviews) {
				if(_local1.isOpenForAll()) {
					if(_local1.enabled) {
						if(!_local1.isClosing) {
							if(!_local2) {
								_local2 = _local1;
							} else if(!_local1.avgLevel < _local2.avgLevel) {
								_local2 = _local1;
							}
						}
					}
				}
			}
			if(_local2) {
				_local2.selectRoom();
				return;
			}
			visible = true;
		}
	}
}

