package core.states.AIStates
{
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.states.IState;
	import core.states.StateMachine;
	import generics.Random;
	import movement.Heading;
	
	public class AITeleportEntry implements IState
	{
		private var g:Game;
		
		private var s:EnemyShip;
		
		private var sm:StateMachine;
		
		private var targetX:Number;
		
		private var targetY:Number;
		
		private var emitters1:Vector.<Emitter>;
		
		public function AITeleportEntry(param1:Game, param2:EnemyShip, param3:Heading)
		{
			super();
			targetX = param3.pos.x.valueOf();
			targetY = param3.pos.y.valueOf();
			var _loc4_:Random = new Random(param2.id);
			param2.course.pos.x = 2411242;
			param2.course.pos.y = 8942522;
			param2.course.rotation = 2 * 3.141592653589793 * _loc4_.randomNumber();
			param2.clearConvergeTarget();
			if (isNaN(param2.pos.x))
			{
				trace("NaN entry: " + param2.name);
				return;
			}
			this.g = param1;
			this.s = param2;
		}
		
		public function enter():void
		{
			s.invulnerable = true;
			s.visible = false;
			emitters1 = EmitterFactory.create("5BSaDIEYj0mEuVkMVp1JGw", g, targetX, targetY, null, true);
		}
		
		public function execute():void
		{
		}
		
		public function exit():void
		{
			for each (var _loc1_:* in emitters1)
			{
				_loc1_.killEmitter();
			}
			s.course.pos.x = targetX;
			s.course.pos.y = targetY;
			s.visible = true;
			s.clearConvergeTarget();
			s.forceupdate = true;
			s.invulnerable = false;
			s.nextDistanceCalculation = -1;
			g.emitterManager.forceUpdate(s);
			if (s.shieldRegenCounter > -3000)
			{
				s.shieldRegenCounter = -3000;
			}
		}
		
		public function set stateMachine(param1:StateMachine):void
		{
			this.sm = param1;
		}
		
		public function get type():String
		{
			return "AITeleportEntry";
		}
	}
}
