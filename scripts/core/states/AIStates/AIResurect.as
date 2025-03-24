package core.states.AIStates {
	import core.hud.components.chat.MessageLog;
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	
	public class AIResurect implements IState {
		private var g:Game;
		
		private var s:EnemyShip;
		
		private var sm:StateMachine;
		
		private var target:Unit;
		
		private var targetX:Number;
		
		private var targetY:Number;
		
		private var duration:Number;
		
		private var emitters1:Vector.<Emitter>;
		
		private var emitters2:Vector.<Emitter>;
		
		public function AIResurect(g:Game, s:EnemyShip) {
			super();
			this.g = g;
			this.s = s;
		}
		
		public function enter() : void {
			var _local1:String = s.name + " used nanobot reconstruction!";
			MessageLog.write(_local1);
			s.course.speed.x = 0;
			s.course.speed.y = 0;
			s.course.accelerate = false;
			s.course.rotateLeft = false;
			s.course.rotateRight = false;
			s.course.roll = false;
			s.invulnerable = true;
			emitters1 = EmitterFactory.create("UZ3AiNHAEUmBD4ev0Itu0A",g,s.pos.x,s.pos.y,s,true);
			emitters2 = EmitterFactory.create("5BSaDIEYj0mEuVkMVp1JGw",g,targetX,targetY,null,true);
		}
		
		public function execute() : void {
		}
		
		public function exit() : void {
			s.hp = s.hpMax;
			s.shieldHp = s.shieldHpMax;
			for each(var _local1 in emitters1) {
				_local1.killEmitter();
			}
			for each(_local1 in emitters2) {
				_local1.killEmitter();
			}
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
		
		public function get type() : String {
			return "AITeleport";
		}
	}
}

