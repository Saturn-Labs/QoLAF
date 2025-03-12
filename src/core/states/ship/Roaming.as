package core.states.ship
{
	import core.ship.PlayerShip;
	import core.states.IState;
	import core.states.StateMachine;
	
	public class Roaming implements IState
	{
		private var ship:PlayerShip;
		
		private var sm:StateMachine;
		
		public function Roaming(param1:PlayerShip)
		{
			super();
			this.ship = param1;
		}
		
		public function enter():void
		{
		}
		
		public function execute():void
		{
			ship.updateHeading();
			ship.updateHealthBars();
			ship.engine.update();
			ship.updateWeapons();
			ship.regenerateShield();
			ship.regenerateHP();
		}
		
		public function exit():void
		{
		}
		
		public function get type():String
		{
			return "Roaming";
		}
		
		public function set stateMachine(param1:StateMachine):void
		{
			this.sm = param1;
		}
	}
}
