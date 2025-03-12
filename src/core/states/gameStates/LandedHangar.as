package core.states.gameStates
{
	import core.hud.components.Hangar;
	import core.scene.Game;
	import core.solarSystem.Body;
	
	public class LandedHangar extends LandedState
	{
		public function LandedHangar(param1:Game, param2:Body)
		{
			super(param1, param2, param2.name);
		}
		
		override public function enter():void
		{
			super.enter();
			addChild(new Hangar(g, body));
			RymdenRunt.s.nativeStage.frameRate = 60;
			loadCompleted();
		}
	}
}
