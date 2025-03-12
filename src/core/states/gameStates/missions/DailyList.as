package core.states.gameStates.missions
{
	import core.scene.Game;
	import feathers.controls.ScrollContainer;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class DailyList extends Sprite
	{
		private var g:Game;
		
		private var views:Array;
		
		private var container:ScrollContainer;
		
		public function DailyList(param1:Game)
		{
			var _loc7_:int = 0;
			var _loc6_:Daily = null;
			var _loc5_:DailyView = null;
			views = [];
			super();
			this.g = param1;
			container = new ScrollContainer();
			container.width = 680;
			container.height = 500;
			container.x = 40;
			container.y = 40;
			addChild(container);
			var _loc2_:Array = param1.me.dailyMissions;
			_loc2_.sortOn(["complete", "level"], [2, 16]);
			container.addEventListener("dailyMissionsUpdateList", updateList);
			var _loc4_:int = 24;
			var _loc3_:int = 20;
			_loc7_ = 0;
			while (_loc7_ < _loc2_.length)
			{
				_loc6_ = _loc2_[_loc7_];
				_loc5_ = new DailyView(param1, _loc6_, container);
				_loc5_.x = _loc3_;
				_loc5_.y = _loc4_;
				container.addChild(_loc5_);
				if (_loc7_ % 2 != 0)
				{
					_loc3_ = 20;
					_loc4_ += _loc5_.height;
				}
				else
				{
					_loc3_ = _loc5_.width + 40;
				}
				views.push(_loc5_);
				_loc7_++;
			}
		}
		
		private function updateList(param1:Event):void
		{
			var _loc2_:DailyView = null;
			var _loc3_:int = 0;
			_loc3_ = 0;
			while (_loc3_ < views.length)
			{
				_loc2_ = views[_loc3_];
				if (_loc2_.isTypeMission())
				{
					_loc2_.onReset(null);
				}
				_loc3_++;
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
			container.removeEventListener("dailyMissionsUpdateList", updateList);
			for each (var _loc1_:* in views)
			{
				_loc1_.dispose();
			}
		}
	}
}
