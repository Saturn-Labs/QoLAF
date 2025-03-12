package core.states.AIStates
{
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	import generics.Util;
	
	public class AITeleport implements IState
	{
		private var g:Game;
		
		private var s:EnemyShip;
		
		private var sm:StateMachine;
		
		private var target:Unit;
		
		private var targetX:Number;
		
		private var targetY:Number;
		
		private var duration:Number;
		
		private var emitters1:Vector.<Emitter>;
		
		private var emitters2:Vector.<Emitter>;
		
		public function AITeleport(param1:Game, param2:EnemyShip, param3:Unit, param4:int = 1, param5:Number = 0, param6:Number = 0)
		{
			super();
			this.g = param1;
			this.s = param2;
			this.target = param3;
			this.targetX = param5;
			this.targetY = param6;
			this.duration = param4;
		}
		
		public function enter():void
		{
			s.invulnerable = true;
			emitters1 = EmitterFactory.create("UZ3AiNHAEUmBD4ev0Itu0A", g, s.pos.x, s.pos.y, s, true);
			emitters2 = EmitterFactory.create("5BSaDIEYj0mEuVkMVp1JGw", g, targetX, targetY, null, true);
		}
		
		public function execute():void
		{
			if (target == null && s.target == null && g.time > s.orbitStartTime && g.time - 2000 < s.orbitStartTime)
			{
				s.stateMachine.changeState(new AIOrbit(g, s, true));
				s.course.pos.x = targetX;
				s.course.pos.y = targetY;
				s.clearConvergeTarget();
			}
		}
		
		public function exit():void
		{
			var _loc2_:Number = NaN;
			var _loc3_:Number = NaN;
			for each (var _loc1_:* in emitters1)
			{
				_loc1_.killEmitter();
			}
			for each (_loc1_ in emitters2)
			{
				_loc1_.killEmitter();
			}
			if (target != null)
			{
				_loc2_ = target.pos.x - targetX;
				_loc3_ = target.pos.y - targetY;
				if (_loc3_ != 0 || _loc2_ != 0)
				{
					s.rotation = Util.clampRadians(Math.atan2(_loc3_, _loc2_));
				}
			}
			else if (s.target != null)
			{
				_loc2_ = s.target.pos.x - targetX;
				_loc3_ = s.target.pos.y - targetY;
				if (_loc3_ != 0 || _loc2_ != 0)
				{
					s.rotation = Util.clampRadians(Math.atan2(_loc3_, _loc2_) - 3.141592653589793);
				}
				s.target = null;
			}
			s.course.pos.x = targetX;
			s.course.pos.y = targetY;
			s.clearConvergeTarget();
			s.invulnerable = false;
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
			return "AITeleport";
		}
	}
}
