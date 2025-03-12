package core.states.player
{
	import core.player.Player;
	import core.scene.Game;
	import core.solarSystem.Body;
	import core.states.IState;
	import core.states.StateMachine;
	import core.states.ship.LandedShip;
	import debug.Console;
	
	public class Landed implements IState
	{
		private var player:Player;
		
		private var body:Body;
		
		private var sm:StateMachine;
		
		private var g:Game;
		
		public function Landed(param1:Player, param2:Body, param3:Game)
		{
			super();
			Console.write("Player state: Landed");
			this.g = param3;
			this.player = param1;
			this.body = param2;
		}
		
		public function enter():void
		{
			player.currentBody = body;
			if (player.ship == null || player.ship.stateMachine == null)
			{
				return;
			}
			player.ship.stateMachine.changeState(new LandedShip(player.ship, body));
		}
		
		public function execute():void
		{
		}
		
		private function updateInput():void
		{
		}
		
		public function exit():void
		{
			player.lastBody = player.currentBody;
			player.currentBody = null;
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
