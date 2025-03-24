package core.states.AIStates {
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
	
	public class AIChase implements IState {
		private var g:Game;
		
		private var s:EnemyShip;
		
		private var sm:StateMachine;
		
		private var closeRangeSQ:Number;
		
		private var speedRotFactor:Number;
		
		private var rollPeriod:Number;
		
		private var rollPeriodFactor:Number;
		
		public function AIChase(g:Game, s:EnemyShip, t:Unit, targetPosition:Heading, nextTurnDirection:int) {
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
			var _local1:Random = new Random(1 / s.id);
			_local1.stepTo(5);
			closeRangeSQ = 66 + 0.8 * _local1.random(80) + s.collisionRadius;
			closeRangeSQ *= closeRangeSQ;
			if(_local1.random(2) == 0) {
				s.rollDir = -1;
			} else {
				s.rollDir = 1;
			}
			s.rollSpeed = (0.1 + 0.001 * _local1.random(501)) * s.engine.speed;
			s.rollPassive = 0.1 + 0.001 * _local1.random(301);
			rollPeriod = 10000 + _local1.random(10000);
			rollPeriodFactor = 0.25 + 0.001 * _local1.random(501);
			s.rollMod = g.time % rollPeriod > rollPeriodFactor * rollPeriod ? 1 : -1;
			speedRotFactor = s.engine.speed / (0.5 * s.engine.rotationSpeed);
			s.accelerate = true;
			s.roll = false;
			s.engine.accelerate();
		}
		
		public function execute() : void {
			var _local4:Point = null;
			var _local1:Point = null;
			var _local2:Number = NaN;
			var _local5:Number = NaN;
			var _local6:Number = NaN;
			var _local3:Number = NaN;
			if(s.target != null) {
				_local4 = s.course.pos;
				_local1 = s.target.pos;
				s.setAngleTargetPos(_local1);
				_local2 = _local4.x - _local1.x;
				_local5 = _local4.y - _local1.y;
				_local6 = _local2 * _local2 + _local5 * _local5;
				if(s.sniper && _local6 < s.sniperMinRange * s.sniperMinRange) {
					s.accelerate = false;
					s.roll = true;
				} else if(s.stopWhenClose && _local6 < closeRangeSQ) {
					s.accelerate = false;
					s.roll = true;
				} else {
					s.accelerate = true;
					s.roll = false;
				}
			}
			s.rollMod = g.time % rollPeriod > rollPeriodFactor * rollPeriod ? 1 : -1;
			if(!s.aiCloak) {
				s.runConverger();
			}
			s.regenerateShield();
			s.updateHealthBars();
			s.engine.update();
			if(s.target != null) {
				_local3 = s.rotation;
				s.updateBeamWeapons();
				s.rotation = aim();
				s.updateNonBeamWeapons();
				s.rotation = _local3;
			}
		}
		
		public function aim() : Number {
			var _local3:int = 0;
			var _local10:Number = NaN;
			var _local9:Number = NaN;
			var _local14:Number = NaN;
			var _local12:Number = NaN;
			var _local11:Number = NaN;
			var _local13:Weapon = null;
			var _local4:Number = s.target.pos.x;
			var _local2:Number = s.target.pos.y;
			var _local8:Number = s.course.pos.x;
			var _local1:Number = s.course.pos.y;
			var _local6:Number = 0;
			var _local5:Number = 0;
			var _local7:int = int(s.weapons.length);
			_local3 = 0;
			while(_local3 < _local7) {
				_local13 = s.weapons[_local3];
				if(_local13.fire && _local13 is Blaster) {
					if(s.aimSkill == 0) {
						return s.course.rotation;
					}
					_local6 = _local4 - _local8;
					_local5 = _local2 - _local1;
					_local10 = Math.sqrt(_local6 * _local6 + _local5 * _local5);
					_local6 /= _local10;
					_local5 /= _local10;
					_local9 = 0.991;
					_local14 = _local10 / (_local13.speed - Util.dotProduct(s.target.speed.x,s.target.speed.y,_local6,_local5) * _local9);
					_local12 = _local4 + s.target.speed.x * _local14 * _local9 * s.aimSkill;
					_local11 = _local2 + s.target.speed.y * _local14 * _local9 * s.aimSkill;
					return Math.atan2(_local11 - _local1,_local12 - _local8);
				}
				_local3++;
			}
			return s.course.rotation;
		}
		
		public function exit() : void {
			s.rollPassive = 0;
			s.rollSpeed = 0;
			s.rollMod = 0;
			s.rollDir = 0;
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
		
		public function get type() : String {
			return "AIChase";
		}
	}
}

