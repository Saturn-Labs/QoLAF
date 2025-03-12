package core.states.menuStates
{
	import core.hud.components.Hangar;
	import core.scene.Game;
	import core.states.DisplayState;
	
	public class FleetState extends DisplayState
	{
		public function FleetState(param1:Game, param2:Boolean = false)
		{
			super(param1, HomeState, param2);
		}
		
		override public function enter():void
		{
			super.enter();
			var _loc1_:Hangar = new Hangar(g, null);
			addChild(_loc1_);
		}
		
		override public function exit():void
		{
			super.exit();
		}
	}
}
