package core.states.AIStates {
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	import flash.geom.Point;
	import movement.Heading;
	
	public class AIFollow implements IState {
		private var g:Game;
		
		private var s:EnemyShip;
		
		private var sm:StateMachine;
		
		private var closeRangeSQ:Number;
		
		private var speedRotFactor:Number;
		
		private var rollPeriod:Number;
		
		private var rollPeriodFactor:Number;
		
		private var target:Unit;
		
		public function AIFollow(g:Game, s:EnemyShip, t:Unit, targetPosition:Heading, nextTurnDirection:int) {
			super();
			target = t;
			s.setConvergeTarget(targetPosition);
			s.nextTurnDir = nextTurnDirection;
			this.s = s;
			this.g = g;
		}
		
		public function enter() : void {
			closeRangeSQ = 40000;
			s.course.roll = false;
			s.roll = false;
			s.accelerate = false;
		}
		
		public function execute() : void {
			if(target == null) {
				return;
			}
			var _local3:Point = s.course.pos;
			var _local1:Point = target.pos;
			s.setAngleTargetPos(_local1);
			var _local2:Number = _local3.x - _local1.x;
			var _local4:Number = _local3.y - _local1.y;
			var _local5:Number = _local2 * _local2 + _local4 * _local4;
			if(_local5 > closeRangeSQ) {
				s.accelerate = true;
				s.engine.accelerating = true;
			} else {
				s.engine.accelerating = false;
				s.accelerate = false;
			}
			s.runConverger();
			s.regenerateShield();
			s.updateHealthBars();
			s.engine.update();
		}
		
		public function exit() : void {
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
		
		public function get type() : String {
			return "AIFollow";
		}
	}
}

