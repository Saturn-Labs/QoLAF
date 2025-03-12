package core.states.AIStates
{
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	import movement.Heading;
	
	public class AIObserve implements IState
	{
		private var g:Game;
		
		private var s:EnemyShip;
		
		private var sm:StateMachine;
		
		public function AIObserve(param1:Game, param2:EnemyShip, param3:Unit, param4:Heading, param5:int)
		{
			super();
			param2.target = param3;
			if (!param2.aiCloak)
			{
				param2.setConvergeTarget(param4);
			}
			param2.setNextTurnDirection(param5);
			this.g = param1;
			this.s = param2;
		}
		
		public function enter():void
		{
		}
		
		public function execute():void
		{
			if (s.target != null && SqrRange(s.target) < s.visionRange * s.visionRange)
			{
				s.setAngleTargetPos(s.target.pos);
			}
			else
			{
				s.setAngleTargetPos(null);
			}
			if (!s.aiCloak)
			{
				s.runConverger();
			}
			s.regenerateShield();
			s.updateHealthBars();
			s.engine.update();
			s.updateWeapons();
		}
		
		private function SqrRange(param1:Unit):Number
		{
			var _loc2_:Number = s.pos.x - param1.pos.x;
			var _loc3_:Number = s.pos.y - param1.pos.y;
			return _loc2_ * _loc2_ + _loc3_ * _loc3_;
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
			return "AIObserve";
		}
	}
}
