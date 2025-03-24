package core.states.menuStates {
	import core.artifact.ArtifactOverview;
	import core.hud.components.ToolTip;
	import core.player.Player;
	import core.scene.Game;
	import core.states.DisplayState;
	
	public class ArtifactState2 extends DisplayState {
		public function ArtifactState2(g:Game, p:Player, isRoot:Boolean = false) {
			super(g,HomeState,isRoot);
		}
		
		override public function enter() : void {
			super.enter();
			var _local1:ArtifactOverview = new ArtifactOverview(g);
			addChild(_local1);
			_local1.x = 55;
			_local1.y = 50;
			_local1.load();
		}
		
		override public function exit() : void {
			ToolTip.disposeType("artifactBox");
			super.exit();
		}
	}
}

