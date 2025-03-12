package core.states.AIStates
{
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.states.IState;
	import core.states.StateMachine;
	
	public class AIExit implements IState
	{
		private var g:Game;
		
		private var s:EnemyShip;
		
		private var sm:StateMachine;
		
		private var endTime:Number;
		
		public function AIExit(param1:Game, param2:EnemyShip)
		{
			super();
			this.g = param1;
			this.s = param2;
		}
		
		public function enter():void
		{
			endTime = g.time + 1000;
		}
		
		public function execute():void
		{
			s.engine.stop();
			s.alpha = (endTime - g.time) / 1000;
			if (endTime < g.time)
			{
				s.clearConvergeTarget();
				s.alive = false;
				s.explosionEffect = "";
				s.destroy(false);
				s.clearConvergeTarget();
				return;
			}
		}
		
		public function exit():void
		{
		}
		
		public function set stateMachine(param1:StateMachine):void
		{
			this.sm = param1;
		}
		
		public function get type():String
		{
			return "AIExit";
		}
	}
}
