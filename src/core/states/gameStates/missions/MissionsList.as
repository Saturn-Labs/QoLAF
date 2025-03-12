package core.states.gameStates.missions
{
	import core.hud.components.ToolTip;
	import core.player.Mission;
	import core.scene.Game;
	import feathers.controls.ScrollContainer;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class MissionsList extends Sprite
	{
		public static var instance:MissionsList;
		
		private var g:Game;
		
		private var missions:Vector.<Mission>;
		
		private var missionViews:Vector.<MissionView>;
		
		private var missionsContainer:ScrollContainer;
		
		private var majorType:String;
		
		public function MissionsList(param1:Game)
		{
			missionViews = new Vector.<MissionView>();
			super();
			this.g = param1;
			instance = this;
			missionsContainer = new ScrollContainer();
			missionsContainer.width = 720;
			missionsContainer.height = 500;
			missionsContainer.x = 0;
			missionsContainer.y = 40;
			addChild(missionsContainer);
		}
		
		public static function reload():void
		{
			if (instance != null)
			{
				instance.reload();
			}
		}
		
		public function loadStoryMissions():void
		{
			this.majorType = "static";
			load();
		}
		
		public function loadTimedMissions():void
		{
			this.majorType = "time";
			load();
		}
		
		public function load():void
		{
			var majorType:String = this.majorType;
			missions = g.me.missions.filter(function(param1:Mission, param2:int, param3:Vector.<Mission>):Boolean
			{
				return param1.majorType == majorType;
			});
			sortByDate();
		}
		
		private function sortByDate():void
		{
			missions = missions.sort((function():*
			{
				var f:Function;
				return f = function(param1:Mission, param2:Mission):int
				{
					if (param1.created < param2.created)
					{
						return 1;
					}
					if (param1.created > param2.created)
					{
						return -1;
					}
					return 0;
				};
			})());
		}
		
		private function reload(param1:Event = null):void
		{
			missionViews.length = 0;
			missionsContainer.removeChildren(0, -1, true);
			load();
			drawMissions();
		}
		
		public function drawMissions():void
		{
			var _loc4_:int = 0;
			var _loc2_:Mission = null;
			var _loc3_:MissionView = null;
			var _loc1_:int = 635;
			if (missions.length > 2)
			{
				_loc1_ = 620;
			}
			_loc4_ = 0;
			while (_loc4_ < missions.length)
			{
				_loc2_ = missions[_loc4_];
				_loc3_ = new MissionView(g, _loc2_, _loc1_);
				missionViews.push(_loc3_);
				missionsContainer.addChild(_loc3_);
				_loc3_.init();
				_loc3_.addEventListener("reload", reload);
				_loc4_++;
			}
			positionMissions();
			trySetMissionsViewed();
		}
		
		private function positionMissions():void
		{
			var _loc4_:int = 0;
			var _loc1_:MissionView = null;
			var _loc3_:Number = 62;
			var _loc2_:Number = 23;
			_loc4_ = 0;
			while (_loc4_ < missionViews.length)
			{
				_loc1_ = missionViews[_loc4_];
				_loc1_.x = _loc3_;
				_loc1_.y = _loc2_;
				_loc2_ += _loc1_.height;
				_loc4_++;
			}
		}
		
		private function trySetMissionsViewed():void
		{
			var _loc1_:Boolean = false;
			for each (var _loc2_:* in missions)
			{
				if (!_loc2_.viewed)
				{
					_loc2_.viewed = true;
					_loc1_ = true;
				}
			}
			if (_loc1_)
			{
				g.rpc("setMissionsViewed", null);
			}
			g.hud.missionsButton.hideHintNew();
		}
		
		public function update():void
		{
			var _loc2_:int = 0;
			var _loc1_:MissionView = null;
			_loc2_ = 0;
			while (_loc2_ < missionViews.length)
			{
				_loc1_ = missionViews[_loc2_];
				_loc1_.update();
				_loc2_++;
			}
		}
		
		override public function dispose():void
		{
			missionsContainer.removeChildren(0, -1, true);
			ToolTip.disposeType("missionView");
			instance = null;
			super.dispose();
		}
	}
}
