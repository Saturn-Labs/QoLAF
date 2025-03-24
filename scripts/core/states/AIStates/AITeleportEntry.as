package core.states.AIStates {
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.states.IState;
	import core.states.StateMachine;
	import generics.Random;
	import movement.Heading;
	
	public class AITeleportEntry implements IState {
		private var g:Game;
		
		private var s:EnemyShip;
		
		private var sm:StateMachine;
		
		private var targetX:Number;
		
		private var targetY:Number;
		
		private var emitters1:Vector.<Emitter>;
		
		public function AITeleportEntry(g:Game, s:EnemyShip, course:Heading) {
			super();
			targetX = course.pos.x.valueOf();
			targetY = course.pos.y.valueOf();
			var _local4:Random = new Random(s.id);
			s.course.pos.x = 2411242;
			s.course.pos.y = 8942522;
			s.course.rotation = 2 * 3.141592653589793 * _local4.randomNumber();
			s.clearConvergeTarget();
			if(isNaN(s.pos.x)) {
				trace("NaN entry: " + s.name);
				return;
			}
			this.g = g;
			this.s = s;
		}
		
		public function enter() : void {
			s.invulnerable = true;
			s.visible = false;
			emitters1 = EmitterFactory.create("5BSaDIEYj0mEuVkMVp1JGw",g,targetX,targetY,null,true);
		}
		
		public function execute() : void {
		}
		
		public function exit() : void {
			for each(var _local1 in emitters1) {
				_local1.killEmitter();
			}
			s.course.pos.x = targetX;
			s.course.pos.y = targetY;
			s.visible = true;
			s.clearConvergeTarget();
			s.forceupdate = true;
			s.invulnerable = false;
			s.nextDistanceCalculation = -1;
			g.emitterManager.forceUpdate(s);
			if(s.shieldRegenCounter > -3000) {
				s.shieldRegenCounter = -3000;
			}
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
		
		public function get type() : String {
			return "AITeleportEntry";
		}
	}
}

