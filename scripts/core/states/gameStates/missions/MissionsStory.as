package core.states.gameStates.missions {
	import core.hud.components.ToolTip;
	import core.scene.Game;
	import starling.display.Sprite;
	
	public class MissionsStory extends Sprite {
		private var g:Game;
		
		public function MissionsStory(g:Game) {
			super();
			this.g = g;
			var _local2:MissionsList = new MissionsList(g);
			_local2.loadStoryMissions();
			_local2.drawMissions();
			addChild(_local2);
		}
		
		override public function dispose() : void {
			super.dispose();
			ToolTip.disposeType("missionView");
		}
	}
}

