package core.states.gameStates.missions {
	import core.hud.components.ToolTip;
	import core.player.Mission;
	import core.scene.Game;
	import feathers.controls.ScrollContainer;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class MissionsList extends Sprite {
		public static var instance:MissionsList;
		
		private var g:Game;
		
		private var missions:Vector.<Mission>;
		
		private var missionViews:Vector.<MissionView> = new Vector.<MissionView>();
		
		private var missionsContainer:ScrollContainer;
		
		private var majorType:String;
		
		public function MissionsList(g:Game) {
			super();
			this.g = g;
			instance = this;
			missionsContainer = new ScrollContainer();
			missionsContainer.width = 12 * 60;
			missionsContainer.height = 500;
			missionsContainer.x = 0;
			missionsContainer.y = 40;
			addChild(missionsContainer);
		}
		
		public static function reload() : void {
			if(instance != null) {
				instance.reload();
			}
		}
		
		public function loadStoryMissions() : void {
			this.majorType = "static";
			load();
		}
		
		public function loadTimedMissions() : void {
			this.majorType = "time";
			load();
		}
		
		public function load() : void {
			var majorType:String = this.majorType;
			missions = g.me.missions.filter(function(param1:Mission, param2:int, param3:Vector.<Mission>):Boolean {
				return param1.majorType == majorType;
			});
			sortByDate();
		}
		
		private function sortByDate() : void {
			missions = missions.sort((function():* {
				var f:Function;
				return f = function(param1:Mission, param2:Mission):int {
					if(param1.created < param2.created) {
						return 1;
					}
					if(param1.created > param2.created) {
						return -1;
					}
					return 0;
				};
			})());
		}
		
		private function reload(e:Event = null) : void {
			missionViews.length = 0;
			missionsContainer.removeChildren(0,-1,true);
			load();
			drawMissions();
		}
		
		public function drawMissions() : void {
			var _local3:int = 0;
			var _local1:Mission = null;
			var _local2:MissionView = null;
			var _local4:int = 635;
			if(missions.length > 2) {
				_local4 = 620;
			}
			_local3 = 0;
			while(_local3 < missions.length) {
				_local1 = missions[_local3];
				_local2 = new MissionView(g,_local1,_local4);
				missionViews.push(_local2);
				missionsContainer.addChild(_local2);
				_local2.init();
				_local2.addEventListener("reload",reload);
				_local3++;
			}
			positionMissions();
			trySetMissionsViewed();
		}
		
		private function positionMissions() : void {
			var _local3:int = 0;
			var _local4:MissionView = null;
			var _local1:Number = 62;
			var _local2:Number = 23;
			_local3 = 0;
			while(_local3 < missionViews.length) {
				_local4 = missionViews[_local3];
				_local4.x = _local1;
				_local4.y = _local2;
				_local2 += _local4.height;
				_local3++;
			}
		}
		
		private function trySetMissionsViewed() : void {
			var _local1:Boolean = false;
			for each(var _local2 in missions) {
				if(!_local2.viewed) {
					_local2.viewed = true;
					_local1 = true;
				}
			}
			if(_local1) {
				g.rpc("setMissionsViewed",null);
			}
			g.hud.missionsButton.hideHintNew();
		}
		
		public function update() : void {
			var _local1:int = 0;
			var _local2:MissionView = null;
			_local1 = 0;
			while(_local1 < missionViews.length) {
				_local2 = missionViews[_local1];
				_local2.update();
				_local1++;
			}
		}
		
		override public function dispose() : void {
			missionsContainer.removeChildren(0,-1,true);
			ToolTip.disposeType("missionView");
			instance = null;
			super.dispose();
		}
	}
}

