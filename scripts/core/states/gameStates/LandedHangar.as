package core.states.gameStates {
	import core.hud.components.Hangar;
	import core.scene.Game;
	import core.solarSystem.Body;
	
	public class LandedHangar extends LandedState {
		public function LandedHangar(g:Game, body:Body) {
			super(g,body,body.name);
		}
		
		override public function enter() : void {
			super.enter();
			addChild(new Hangar(g,body));
			RymdenRunt.s.nativeStage.frameRate = 60;
			loadCompleted();
		}
	}
}

