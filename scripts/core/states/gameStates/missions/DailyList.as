package core.states.gameStates.missions {
	import core.scene.Game;
	import feathers.controls.ScrollContainer;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class DailyList extends Sprite {
		private var g:Game;
		
		private var views:Array;
		
		private var container:ScrollContainer;
		
		public function DailyList(g:Game) {
			var _local6:int = 0;
			var _local5:Daily = null;
			var _local2:DailyView = null;
			views = [];
			super();
			this.g = g;
			container = new ScrollContainer();
			container.width = 680;
			container.height = 500;
			container.x = 40;
			container.y = 40;
			addChild(container);
			var _local7:Array = g.me.dailyMissions;
			_local7.sortOn(["complete","level"],[2,16]);
			container.addEventListener("dailyMissionsUpdateList",updateList);
			var _local3:int = 24;
			var _local4:int = 20;
			_local6 = 0;
			while(_local6 < _local7.length) {
				_local5 = _local7[_local6];
				_local2 = new DailyView(g,_local5,container);
				_local2.x = _local4;
				_local2.y = _local3;
				container.addChild(_local2);
				if(_local6 % 2 != 0) {
					_local4 = 20;
					_local3 += _local2.height;
				} else {
					_local4 = _local2.width + 40;
				}
				views.push(_local2);
				_local6++;
			}
		}
		
		private function updateList(e:Event) : void {
			var _local2:DailyView = null;
			var _local3:int = 0;
			_local3 = 0;
			while(_local3 < views.length) {
				_local2 = views[_local3];
				if(_local2.isTypeMission()) {
					_local2.onReset(null);
				}
				_local3++;
			}
		}
		
		override public function dispose() : void {
			super.dispose();
			container.removeEventListener("dailyMissionsUpdateList",updateList);
			for each(var _local1 in views) {
				_local1.dispose();
			}
		}
	}
}

