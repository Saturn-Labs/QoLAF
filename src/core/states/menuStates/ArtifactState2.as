package core.states.menuStates
{
	import core.artifact.ArtifactOverview;
	import core.hud.components.ToolTip;
	import core.player.Player;
	import core.scene.Game;
	import core.states.DisplayState;
	
	public class ArtifactState2 extends DisplayState
	{
		public function ArtifactState2(param1:Game, param2:Player, param3:Boolean = false)
		{
			super(param1, HomeState, param3);
		}
		
		override public function enter():void
		{
			super.enter();
			var _loc1_:ArtifactOverview = new ArtifactOverview(g);
			addChild(_loc1_);
			_loc1_.x = 55;
			_loc1_.y = 50;
			_loc1_.load();
		}
		
		override public function exit():void
		{
			ToolTip.disposeType("artifactBox");
			super.exit();
		}
	}
}
