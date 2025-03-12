package core.states.ship
{
	import core.ship.PlayerShip;
	import core.solarSystem.Body;
	import core.states.IState;
	import core.states.StateMachine;
	
	public class LandedShip implements IState
	{
		private var sm:StateMachine;
		
		private var ship:PlayerShip;
		
		private var body:Body;
		
		public function LandedShip(param1:PlayerShip, param2:Body)
		{
			super();
			this.ship = param1;
			this.body = param2;
		}
		
		public function enter():void
		{
			ship.land();
		}
		
		public function execute():void
		{
		}
		
		public function exit():void
		{
		}
		
		public function get type():String
		{
			return "Landed";
		}
		
		public function set stateMachine(param1:StateMachine):void
		{
			this.sm = param1;
		}
	}
}
