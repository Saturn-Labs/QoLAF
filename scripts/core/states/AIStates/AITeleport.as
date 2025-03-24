package core.states.AIStates {
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	import generics.Util;
	
	public class AITeleport implements IState {
		private var g:Game;
		
		private var s:EnemyShip;
		
		private var sm:StateMachine;
		
		private var target:Unit;
		
		private var targetX:Number;
		
		private var targetY:Number;
		
		private var duration:Number;
		
		private var emitters1:Vector.<Emitter>;
		
		private var emitters2:Vector.<Emitter>;
		
		public function AITeleport(g:Game, s:EnemyShip, target:Unit, duration:int = 1, targetX:Number = 0, targetY:Number = 0) {
			super();
			this.g = g;
			this.s = s;
			this.target = target;
			this.targetX = targetX;
			this.targetY = targetY;
			this.duration = duration;
		}
		
		public function enter() : void {
			s.invulnerable = true;
			emitters1 = EmitterFactory.create("UZ3AiNHAEUmBD4ev0Itu0A",g,s.pos.x,s.pos.y,s,true);
			emitters2 = EmitterFactory.create("5BSaDIEYj0mEuVkMVp1JGw",g,targetX,targetY,null,true);
		}
		
		public function execute() : void {
			if(target == null && s.target == null && g.time > s.orbitStartTime && g.time - 2000 < s.orbitStartTime) {
				s.stateMachine.changeState(new AIOrbit(g,s,true));
				s.course.pos.x = targetX;
				s.course.pos.y = targetY;
				s.clearConvergeTarget();
			}
		}
		
		public function exit() : void {
			var _local1:Number = NaN;
			var _local3:Number = NaN;
			for each(var _local2 in emitters1) {
				_local2.killEmitter();
			}
			for each(_local2 in emitters2) {
				_local2.killEmitter();
			}
			if(target != null) {
				_local1 = target.pos.x - targetX;
				_local3 = target.pos.y - targetY;
				if(_local3 != 0 || _local1 != 0) {
					s.rotation = Util.clampRadians(Math.atan2(_local3,_local1));
				}
			} else if(s.target != null) {
				_local1 = s.target.pos.x - targetX;
				_local3 = s.target.pos.y - targetY;
				if(_local3 != 0 || _local1 != 0) {
					s.rotation = Util.clampRadians(Math.atan2(_local3,_local1) - 3.141592653589793);
				}
				s.target = null;
			}
			s.course.pos.x = targetX;
			s.course.pos.y = targetY;
			s.clearConvergeTarget();
			s.invulnerable = false;
			if(s.shieldRegenCounter > -3000) {
				s.shieldRegenCounter = -3000;
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

