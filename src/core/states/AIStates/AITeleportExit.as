package core.states.AIStates
{
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.states.IState;
	import core.states.StateMachine;
	
	public class AITeleportExit implements IState
	{
		private var g:Game;
		
		private var s:EnemyShip;
		
		private var sm:StateMachine;
		
		private var endTime:Number;
		
		private var emitters1:Vector.<Emitter>;
		
		public function AITeleportExit(param1:Game, param2:EnemyShip)
		{
			super();
			this.g = param1;
			this.s = param2;
		}
		
		public function enter():void
		{
			s.invulnerable = true;
			endTime = g.time + 3500;
			emitters1 = EmitterFactory.create("UZ3AiNHAEUmBD4ev0Itu0A", g, s.pos.x, s.pos.y, s, true);
		}
		
		public function execute():void
		{
			if (endTime < g.time)
			{
				for each (var _loc1_:* in emitters1)
				{
					_loc1_.killEmitter();
				}
				s.clearConvergeTarget();
				s.invulnerable = false;
				s.alive = false;
				s.explosionEffect = "";
				s.destroy(false);
				s.clearConvergeTarget();
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
			return "AITeleportExit";
		}
	}
}
