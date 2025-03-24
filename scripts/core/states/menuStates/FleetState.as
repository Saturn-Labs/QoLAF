package core.states.menuStates {
	import core.hud.components.Hangar;
	import core.scene.Game;
	import core.states.DisplayState;
	
	public class FleetState extends DisplayState {
		public function FleetState(g:Game, isRoot:Boolean = false) {
			super(g,HomeState,isRoot);
		}
		
		override public function enter() : void {
			super.enter();
			var _local1:Hangar = new Hangar(g,null);
			addChild(_local1);
		}
		
		override public function exit() : void {
			super.exit();
		}
	}
}

