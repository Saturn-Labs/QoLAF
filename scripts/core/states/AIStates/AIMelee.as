package core.states.AIStates {
	import core.particle.Emitter;
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.ship.PlayerShip;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	import core.weapon.Blaster;
	import core.weapon.Weapon;
	import flash.geom.Point;
	import generics.Random;
	import generics.Util;
	import movement.Heading;
	
	public class AIMelee implements IState {
		private var g:Game;
		
		private var s:EnemyShip;
		
		private var sm:StateMachine;
		
		private var targetAngleDiff:Number;
		
		private var targetStartAngle:Number;
		
		private var error:Point;
		
		private var errorAngle:Number;
		
		private var convergeTime:Number = 400;
		
		private var convergeStartTime:Number;
		
		private var speedRotFactor:Number;
		
		private var closeRangeSQ:Number;
		
		public function AIMelee(g:Game, s:EnemyShip, t:Unit, targetPosition:Heading, nextTurnDirection:int) {
			super();
			s.target = t;
			if(!s.aiCloak) {
				s.setConvergeTarget(targetPosition);
			}
			s.nextTurnDir = nextTurnDirection;
			this.s = s;
			this.g = g;
			if(!(s.target is PlayerShip) && s.factions.length == 0) {
				s.factions.push("tempFaction");
			}
		}
		
		public function enter() : void {
			s.accelerate = true;
			s.meleeStuck = false;
			error = null;
			errorAngle = 0;
			var _local1:Random = new Random(1 / s.id);
			_local1.stepTo(5);
			closeRangeSQ = 66 + 0.8 * _local1.random(80) + s.collisionRadius;
			closeRangeSQ *= closeRangeSQ;
			speedRotFactor = s.engine.speed / (0.5 * s.engine.rotationSpeed);
		}
		
		public function execute() : void {
			var _local7:Point = null;
			var _local8:Number = NaN;
			var _local6:Point = null;
			var _local3:Number = NaN;
			var _local1:Number = NaN;
			var _local4:Number = NaN;
			var _local2:Number = NaN;
			if(s.target != null && s.target.alive) {
				s.setAngleTargetPos(s.target.pos);
				_local7 = new Point(s.pos.x - s.target.pos.x,s.pos.y - s.target.pos.y);
				_local8 = _local7.x * _local7.x + _local7.y * _local7.y;
				if(s.meleeCanGrab && _local8 < s.chaseRange && s.meleeChargeEndTime != 0 && s.meleeCanGrab) {
					s.meleeChargeEndTime = 1;
				}
				if(s.meleeChargeEndTime < g.time && s.meleeChargeEndTime != 0) {
					s.engine.speed = s.oldSpeed;
					s.engine.rotationSpeed = s.oldTurningSpeed;
					s.meleeChargeEndTime = 0;
					for each(var _local5 in s.chargeEffect) {
						_local5.killEmitter();
					}
				}
				if(s.meleeStuck) {
					if(error == null) {
						_local6 = s.pos.clone();
						errorAngle = s.target.rotation + s.meleeTargetAngleDiff - s.rotation;
					}
					s.speed.x = 0;
					s.speed.y = 0;
					s.rotation = s.target.rotation + s.meleeTargetAngleDiff;
					_local3 = Util.clampRadians(s.target.rotation - s.meleeTargetStartAngle);
					s.pos.x = s.target.pos.x + Math.cos(_local3) * s.meleeOffset.x - Math.sin(_local3) * s.meleeOffset.y;
					s.pos.y = s.target.pos.y + Math.sin(_local3) * s.meleeOffset.x + Math.cos(_local3) * s.meleeOffset.y;
					s.accelerate = false;
					if(error == null) {
						convergeStartTime = g.time;
						error = new Point(_local6.x - s.pos.x,_local6.y - s.pos.y);
						convergeTime = error.length / s.engine.speed * 1000;
					}
					if(error != null) {
						_local1 = (convergeTime - (g.time - convergeStartTime)) / convergeTime;
						if(_local1 > 0) {
							s.pos.x += _local1 * error.x;
							s.pos.y += _local1 * error.y;
							s.rotation += _local1 * errorAngle;
						}
					}
				} else {
					if(s.stopWhenClose && _local8 < closeRangeSQ) {
						s.accelerate = false;
					} else if(s.meleeChargeEndTime < g.time && _local8 < speedRotFactor * speedRotFactor) {
						_local4 = Math.atan2(s.course.pos.y - s.target.pos.y,s.course.pos.x - s.target.pos.x);
						_local3 = Util.angleDifference(s.course.rotation,_local4 + 3.141592653589793);
						if(_local3 > 0.4 * 3.141592653589793 && _local3 < 0.65 * 3.141592653589793 || _local3 < -0.4 * 3.141592653589793 && _local3 > -0.65 * 3.141592653589793) {
							s.accelerate = false;
						} else {
							s.accelerate = true;
						}
					} else {
						s.accelerate = true;
					}
					error = null;
					if(!s.aiCloak) {
						s.runConverger();
					}
				}
			}
			if(isNaN(s.pos.x)) {
				trace("NaN Melee");
			}
			s.regenerateShield();
			s.updateHealthBars();
			s.engine.update();
			if(s.target != null) {
				_local2 = s.rotation;
				s.updateBeamWeapons();
				s.rotation = aim();
				s.updateNonBeamWeapons();
				s.rotation = _local2;
			}
		}
		
		public function aim() : Number {
			var _local4:int = 0;
			var _local6:Number = NaN;
			var _local5:Number = NaN;
			var _local2:Number = NaN;
			var _local7:Number = NaN;
			var _local1:Point = null;
			var _local3:Weapon = null;
			_local4 = 0;
			while(_local4 < s.weapons.length) {
				_local3 = s.weapons[_local4];
				if(_local3.fire && _local3 is Blaster) {
					if(s.aimSkill == 0) {
						return s.course.rotation;
					}
					_local6 = s.target.pos.x - s.course.pos.x;
					_local5 = s.target.pos.y - s.course.pos.y;
					_local2 = Math.sqrt(_local6 * _local6 + _local5 * _local5);
					_local6 /= _local2;
					_local5 /= _local2;
					_local7 = _local2 / (_local3.speed - Util.dotProduct(s.target.speed.x,s.target.speed.y,_local6,_local5));
					_local1 = new Point(s.target.pos.x + s.target.speed.x * _local7 * s.aimSkill,s.target.pos.y + s.target.speed.y * _local7 * s.aimSkill);
					return Math.atan2(_local1.y - s.course.pos.y,_local1.x - s.course.pos.x);
				}
				_local4++;
			}
			return s.course.rotation;
		}
		
		public function exit() : void {
			if(s.meleeChargeEndTime != 0) {
				s.engine.speed = s.oldSpeed;
				s.engine.rotationSpeed = s.oldTurningSpeed;
				s.meleeChargeEndTime = 0;
				for each(var _local1 in s.chargeEffect) {
					_local1.killEmitter();
				}
			}
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
		
		public function get type() : String {
			return "AIMelee";
		}
	}
}

