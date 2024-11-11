package core.login
{
	import com.greensock.TweenMax;
	import core.hud.components.Text;
	import joinRoom.JoinRoomManager;
	import playerio.RoomInfo;
	import starling.display.Sprite;

	public class ServiceRoomSelector extends Sprite
	{
		public static const FULL:int = 1000;

		public static const OPEN_SUPPORTERS:int = 950;

		public static const NEW_ROOM_THRESHOLD:int = 950;

		public static var playerLevel:int = 0;
		public static var isSupporter:Boolean = false;
		public static var totalFree:int = 0;
		private var rooms:Array;
		private var roomPreviews:Array;
		private var callback:Function;
		private var isAutoSelectingRoom:Boolean = false;
		public function ServiceRoomSelector(param1:Array, param2:Function)
		{
			roomPreviews = [];
			super();
			this.callback = param2;
			this.rooms = param1;
			updateTotalFree();
			addRooms();
			var _loc3_:Text = new Text();
			_loc3_.text = "Select sector:";
			_loc3_.y = -50;
			_loc3_.size = 20;
			_loc3_.color = 4222876;
			addChild(_loc3_);
			_loc3_.x = width / 2 - _loc3_.width / 2;
			_loc3_.blendMode = "add";
		}

		public function updateRecommended():void
		{
			var _loc3_:* = null;
			var _loc1_:int = 0;
			var _loc4_:int = 0;
			for each (var _loc2_:* in roomPreviews)
			{
				_loc2_.setRecommended(false);
				if (_loc2_.playerLevel >= 0)
				{
					if (!_loc3_)
					{
						_loc3_ = _loc2_;
					}
					else if (_loc2_.isOpenForAll())
					{
						_loc1_ = Math.abs(_loc2_.avgLevel - playerLevel);
						_loc4_ = Math.abs(_loc3_.avgLevel - playerLevel);
						if (_loc1_ < _loc4_)
						{
							_loc3_ = _loc2_;
						}
					}
				}
			}
			if (_loc3_)
			{
				_loc3_.setRecommended(true);
			}
		}

		private function onSelect(param1:ServiceRoomPreview, param2:String):void
		{
			var r:ServiceRoomPreview;
			var component:ServiceRoomPreview = param1;
			var id:String = param2;
			for each (r in roomPreviews)
			{
				if (r == component)
				{
					r.highlight();
				}
				else
				{
					r.disable();
				}
			}
			TweenMax.delayedCall(0.4, function():void
				{
					callback(id);
				});
		}

		private function addRooms():void
		{
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
			rooms.sort(function(param1:Object, param2:Object):int
				{
					if (param1.onlineUsers < param2.onlineUsers || param1.onlineUsers >= 1000)
					{
						return 1;
					}
					return -1;
				});
			for each (ri in rooms)
			{
				r = new ServiceRoomPreview(ri, onSelect, this);
				roomPreviews.push(r);
				addChild(r);
				r.y = nextY;
				if (rooms.length < 5)
				{
					nextY += r.height + 20;
				}
				else
				{
					if (i % 2 == 0)
					{
						r.x = 0;
					}
					else if (i % 2 == 1)
					{
						r.x = r.width + padding;
						nextY += r.height + 20;
						r.even = false;
					}
					i++;
				}
			}
			if (totalFree > 950)
			{
				handleRoomClosing();
				return;
			}
			nextId = getNextRoomIndex();
			name = JoinRoomManager.getServiceRoomID(nextId);
			info = new RoomInfo(name, "service", 0, {});
			newRoom = new ServiceRoomPreview(info, onSelect, this);
			newRoom.y = nextY;
			addChild(newRoom);
			roomPreviews.unshift(newRoom);
		}

		private function handleRoomClosing():void
		{
			var _loc2_:* = null;
			for each (var _loc1_:* in roomPreviews)
			{
				if (_loc2_ == null)
				{
					_loc2_ = _loc1_;
				}
				else if (_loc1_.info.onlineUsers < _loc2_.info.onlineUsers)
				{
					_loc2_ = _loc1_;
				}
			}
			_loc2_.trySetClosing();
		}

		public function getFree(param1:RoomInfo):int
		{
			var _loc2_:int = 950 - param1.onlineUsers;
			if (_loc2_ < 0)
			{
				_loc2_ = 0;
			}
			return _loc2_;
		}

		public function updateTotalFree():void
		{
			totalFree = 0;
			for each (var _loc1_:* in rooms)
			{
				totalFree += getFree(_loc1_);
			}
		}

		private function getNextRoomIndex():int
		{
			var _loc6_:int = 0;
			var _loc5_:Boolean = false;
			var _loc3_:Array = null;
			var _loc1_:Number = NaN;
			var _loc4_:Array = [];
			_loc6_ = 0;
			while (_loc6_ < 1000)
			{
				_loc5_ = false;
				for each (var _loc2_:* in rooms)
				{
					_loc3_ = _loc2_.id.split("_");
					if (_loc3_.length == 2)
					{
						_loc1_ = Number(_loc3_[1]);
						if (_loc1_ == _loc6_)
						{
							_loc5_ = true;
						}
					}
				}
				if (!_loc5_)
				{
					return _loc6_;
				}
				_loc6_++;
			}
			return 10000;
		}

		public function setNewPlayer():void
		{
			if (isAutoSelectingRoom)
			{
				return;
			}
			isAutoSelectingRoom = true;
			this.visible = false;
			TweenMax.delayedCall(2, connectToBestNoobRoom);
		}

		private function connectToBestNoobRoom():void
		{
			var _loc2_:* = null;
			for each (var _loc1_:* in roomPreviews)
			{
				if (_loc1_.isOpenForAll())
				{
					if (_loc1_.enabled)
					{
						if (!_loc1_.isClosing)
						{
							if (!_loc2_)
							{
								_loc2_ = _loc1_;
							}
							else if (!_loc1_.avgLevel < _loc2_.avgLevel)
							{
								_loc2_ = _loc1_;
							}
						}
					}
				}
			}
			if (_loc2_)
			{
				_loc2_.selectRoom();
				return;
			}
			visible = true;
		}
	}
}
