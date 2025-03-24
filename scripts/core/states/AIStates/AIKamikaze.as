package core.states.AIStates {
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.ship.PlayerShip;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	import movement.Heading;
	
	public class AIKamikaze implements IState {
		private var g:Game;
		
		private var s:EnemyShip;
		
		private var sm:StateMachine;
		
		private var startTime:Number;
		
		private var startDelay:Number = 1000;
		
		public function AIKamikaze(g:Game, s:EnemyShip, target:Unit, targetPos:Heading, nextTurnDirection:int) {
			super();
			s.target = target;
			s.setConvergeTarget(targetPos);
			s.nextTurnDir = nextTurnDirection;
			this.g = g;
			this.s = s;
			if(!(s.target is PlayerShip) && s.factions.length == 0) {
				s.factions.push("tempFaction");
			}
		}
		
		public function enter() : void {
			s.startKamikaze();
			startTime = g.time;
			s.setAngleTargetPos(null);
			s.accelerate = false;
			s.stopShooting();
		}
		
		public function execute() : void {
			if(s.kamikazeHoming && s.target != null && s.target.alive) {
				s.setAngleTargetPos(s.target.pos);
				s.accelerate = true;
			}
			s.runConverger();
			s.regenerateShield();
			s.updateHealthBars();
			s.engine.update();
			s.updateWeapons();
		}
		
		public function exit() : void {
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
		
		public function get type() : String {
			return "AIKamikaze";
		}
	}
}

