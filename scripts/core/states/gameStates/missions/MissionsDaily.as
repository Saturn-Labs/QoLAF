package core.states.gameStates.missions {
	import core.scene.Game;
	import starling.display.Sprite;
	
	public class MissionsDaily extends Sprite {
		private var g:Game;
		
		private var list:DailyList;
		
		public function MissionsDaily(g:Game) {
			super();
			this.g = g;
			list = new DailyList(g);
			addChild(list);
		}
		
		override public function dispose() : void {
			super.dispose();
			list.dispose();
		}
	}
}

