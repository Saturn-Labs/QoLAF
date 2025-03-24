package core.states.AIStates {
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.states.IState;
	import core.states.StateMachine;
	import movement.Heading;
	
	public class AIIdle implements IState {
		private var g:Game;
		
		private var s:EnemyShip;
		
		private var sm:StateMachine;
		
		public function AIIdle(g:Game, s:EnemyShip, course:Heading) {
			super();
			s.initCourse(course);
			s.engine.speed = 0.2 * s.engine.speed;
			if(s.factions.length == 1 && s.factions[0] == "tempFaction") {
				s.factions.splice(0,1);
			}
			this.g = g;
			this.s = s;
		}
		
		public function enter() : void {
			s.target = null;
			s.setAngleTargetPos(null);
			s.stopShooting();
		}
		
		public function execute() : void {
			s.convergerUpdateHeading(s.course);
			s.regenerateShield();
			s.updateHealthBars();
			s.accelerate = true;
			s.engine.update();
			s.updateWeapons();
		}
		
		public function exit() : void {
			s.course.accelerate = false;
			s.engine.speed = 5 * s.engine.speed;
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
		
		public function get type() : String {
			return "AIIdle";
		}
	}
}

