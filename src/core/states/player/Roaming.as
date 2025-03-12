package core.states.player
{
	import core.player.Player;
	import core.scene.Game;
	import core.states.IState;
	import core.states.StateMachine;
	
	public class Roaming implements IState
	{
		private var player:Player;
		
		private var sm:StateMachine;
		
		private var g:Game;
		
		public function Roaming(param1:Player, param2:Game)
		{
			super();
			this.g = param2;
			this.player = param1;
		}
		
		public function enter():void
		{
			if (player.isMe)
			{
				g.focusGameObject(player.ship, true);
			}
			player.ship.engine.show();
		}
		
		public function execute():void
		{
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
