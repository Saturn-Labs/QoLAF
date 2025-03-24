package core.states.AIStates {
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	import movement.Heading;
	
	public class AIObserve implements IState {
		private var g:Game;
		
		private var s:EnemyShip;
		
		private var sm:StateMachine;
		
		public function AIObserve(g:Game, s:EnemyShip, t:Unit, target:Heading, nextTurnDirection:int) {
			super();
			s.target = t;
			if(!s.aiCloak) {
				s.setConvergeTarget(target);
			}
			s.setNextTurnDirection(nextTurnDirection);
			this.g = g;
			this.s = s;
		}
		
		public function enter() : void {
		}
		
		public function execute() : void {
			if(s.target != null && SqrRange(s.target) < s.visionRange * s.visionRange) {
				s.setAngleTargetPos(s.target.pos);
			} else {
				s.setAngleTargetPos(null);
			}
			if(!s.aiCloak) {
				s.runConverger();
			}
			s.regenerateShield();
			s.updateHealthBars();
			s.engine.update();
			s.updateWeapons();
		}
		
		private function SqrRange(target:Unit) : Number {
			var _local3:Number = s.pos.x - target.pos.x;
			var _local2:Number = s.pos.y - target.pos.y;
			return _local3 * _local3 + _local2 * _local2;
		}
		
		public function exit() : void {
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
		
		public function get type() : String {
			return "AIObserve";
		}
	}
}

