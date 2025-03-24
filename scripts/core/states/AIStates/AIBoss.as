package core.states.AIStates {
	import core.boss.Boss;
	import core.scene.Game;
	import core.states.IState;
	import core.states.StateMachine;
	import core.turret.Turret;
	import core.unit.Unit;
	import core.weapon.Beam;
	import core.weapon.Weapon;
	import flash.geom.Point;
	
	public class AIBoss implements IState {
		private var b:Boss;
		
		private var g:Game;
		
		private var courseSendTime:Number;
		
		private var courseSendInterval:Number = 3000;
		
		private var rotationSpeedCurrent:Number = 0;
		
		private var nextRegen:Number;
		
		private var sm:StateMachine;
		
		public function AIBoss(g:Game, b:Boss) {
			super();
			this.g = g;
			this.b = b;
		}
		
		public function enter() : void {
			b.course.accelerate = true;
			nextRegen = g.time + 1000;
			courseSendTime = g.time + courseSendInterval;
		}
		
		public function execute() : void {
			var _local4:Weapon = null;
			var _local1:Beam = null;
			if(!b.alive) {
				return;
			}
			if(nextRegen < g.time) {
				for each(var _local2 in b.allComponents) {
					if(_local2.alive && _local2.active && _local2.hp < _local2.hpMax && _local2.disableHealEndtime < g.time) {
						_local2.hp += b.hpRegen;
						if(_local2.hp > _local2.hpMax) {
							_local2.hp = _local2.hpMax;
						}
					}
				}
				g.hud.bossHealth.update();
				nextRegen = g.time + 1000;
			}
			if(b.teleportExitTime != 0) {
				if(b.teleportExitTime < g.time) {
					b.overrideConvergeTarget(b.teleportExitPoint.x,b.teleportExitPoint.y);
					b.teleportExitTime = 0;
					b.endTeleportEffect();
					return;
				}
				b.course.accelerate = false;
				return;
			}
			if(b.bodyTarget != null && b.bodyDestroyStart != 0) {
				if(b.bodyDestroyEnd != 0 && b.bodyDestroyEnd < g.time) {
					b.bodyTarget.explode();
					b.bodyTarget = null;
					b.bodyDestroyStart = 0;
					b.bodyDestroyEnd = 0;
				}
				for each(var _local3 in b.turrets) {
					_local4 = _local3.weapon;
					if(_local4 is Beam) {
						_local1 = _local4 as Beam;
						_local1.fireAtBody(b.bodyTarget);
					}
				}
			}
			if(b.target == null) {
				if(b.currentWaypoint != null) {
					b.course.accelerate = true;
					b.angleTargetPos = b.currentWaypoint.pos;
				} else {
					b.course.accelerate = false;
					b.angleTargetPos = null;
				}
			} else {
				b.course.accelerate = true;
				b.angleTargetPos = new Point(b.target.pos.x,b.target.pos.y);
			}
			b.updateHeading(b.course);
			if(b.holonomic || b.rotationForced) {
				if(b.rotationSpeed > 0 && rotationSpeedCurrent < b.rotationSpeed || b.rotationSpeed < 0 && rotationSpeedCurrent > b.rotationSpeed) {
					rotationSpeedCurrent += 0.05 * b.rotationSpeed;
				}
				b.course.rotation += rotationSpeedCurrent * 33 / 1000;
			}
			b.x = b.course.pos.x;
			b.y = b.course.pos.y;
			b.rotation = b.course.rotation;
		}
		
		public function exit() : void {
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
		
		public function get type() : String {
			return "AIChase";
		}
	}
}

