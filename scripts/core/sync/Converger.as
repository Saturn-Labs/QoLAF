package core.sync {
	import core.deathLine.DeathLine;
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.ship.PlayerShip;
	import core.ship.Ship;
	import core.solarSystem.Body;
	import flash.geom.Point;
	import generics.Util;
	import movement.Heading;
	
	public class Converger {
		public static const PI_DIVIDED_BY_8:Number = 0.39269908169872414;
		
		private const BLIP_OFFSET:Number = 30;
		
		public var course:Heading = new Heading();
		
		private var target:Heading;
		
		private var error:Point = new Point();
		
		private var errorAngle:Number;
		
		private var convergeTime:Number = 1000;
		
		private var convergeStartTime:Number;
		
		private var errorOldTime:Number;
		
		private var ship:Ship;
		
		private var g:Game;
		
		private var angleTargetPos:Point;
		
		private var isFacingTarget:Boolean;
		
		private var nextTurnDirection:int;
		
		private const RIGHT:int = 1;
		
		private const LEFT:int = -1;
		
		private const NONE:int = 0;
		
		public function Converger(ship:Ship, g:Game) {
			super();
			this.ship = ship;
			this.g = g;
			angleTargetPos = null;
			nextTurnDirection = 0;
		}
		
		public function run() : void {
			if(course == null || course.time > g.time - 33) {
				return;
			}
			if(ship is EnemyShip) {
				aiRemoveError(course);
				updateHeading(course);
				aiAddError(course);
			} else {
				updateHeading(course);
				if(target != null) {
					calculateOffset();
				}
			}
		}
		
		public function calculateOffset() : void {
			var _local6:Number = NaN;
			var _local8:Number = NaN;
			var _local10:* = undefined;
			var _local11:int = 0;
			var _local7:int = 0;
			var _local4:DeathLine = null;
			while(target.time < course.time) {
				_local6 = target.pos.y;
				_local8 = target.pos.x;
				updateHeading(target);
				_local10 = g.deathLineManager.lines;
				_local11 = int(_local10.length);
				_local7 = 0;
				while(_local7 < _local11) {
					_local4 = _local10[_local7];
					if(_local4.lineIntersection2(course.pos.x,course.pos.y,_local8,_local6,ship.collisionRadius)) {
						target.pos.x = _local8;
						target.pos.y = _local6;
						target.speed.x = 0;
						target.speed.y = 0;
						break;
					}
					_local7++;
				}
			}
			var _local1:Number = target.pos.x - course.pos.x;
			var _local5:Number = target.pos.y - course.pos.y;
			var _local2:Number = Math.sqrt(_local1 * _local1 + _local5 * _local5);
			var _local3:Number = Util.angleDifference(target.rotation,course.rotation);
			if(_local2 > 30) {
				setCourse(target);
				return;
			}
			if(_local3 > 0.39269908169872414 || _local3 < -0.39269908169872414) {
				course.rotation = target.rotation;
				return;
			}
			var _local9:Number = 0.4;
			course.speed.x = target.speed.x + _local9 * _local1;
			course.speed.y = target.speed.y + _local9 * _local5;
			course.rotation += _local3 * 0.05;
			course.rotation = Util.clampRadians(course.rotation);
		}
		
		private function aiAddError(heading:Heading) : void {
			if(error.x == 0 && error.y == 0) {
				return;
			}
			var _local2:Number = g.time;
			var _local4:Number = (convergeTime - (_local2 - convergeStartTime)) / convergeTime;
			var _local3:Number = 3 * _local4 * _local4 - 2 * _local4 * _local4 * _local4;
			if(_local4 > 0) {
				heading.pos.x += _local3 * error.x;
				heading.pos.y += _local3 * error.y;
				heading.rotation += _local3 * errorAngle;
				errorOldTime = _local2;
			} else {
				error.x = 0;
				error.y = 0;
				errorOldTime = 0;
			}
		}
		
		private function aiRemoveError(heading:Heading) : void {
			if(error.x == 0 && error.y == 0 || errorOldTime == 0) {
				return;
			}
			var _local3:Number = (convergeTime - (errorOldTime - convergeStartTime)) / convergeTime;
			var _local2:Number = 3 * _local3 * _local3 - 2 * _local3 * _local3 * _local3;
			heading.pos.x -= _local2 * error.x;
			heading.pos.y -= _local2 * error.y;
			heading.rotation -= _local2 * errorAngle;
		}
		
		public function setNextTurnDirection(value:int) : void {
			nextTurnDirection = value;
		}
		
		public function setConvergeTarget(value:Heading) : void {
			target = value;
			if(ship is EnemyShip) {
				error.x = course.pos.x - target.pos.x;
				error.y = course.pos.y - target.pos.y;
				errorAngle = Util.angleDifference(course.rotation,target.rotation);
				convergeStartTime = g.time;
				course.speed = target.speed;
				course.pos = target.pos;
				course.rotation = target.rotation;
				course.time = target.time;
				aiAddError(course);
			}
		}
		
		public function clearConvergeTarget() : void {
			target = null;
			error.x = 0;
			error.y = 0;
		}
		
		public function setCourse(heading:Heading, allowFastForward:Boolean = true) : void {
			if(allowFastForward) {
				fastforwardToServerTime(heading);
			}
			course = heading;
			target = null;
		}
		
		public function setAngleTargetPos(angleTarget:Point) : void {
			isFacingTarget = false;
			angleTargetPos = angleTarget;
		}
		
		public function isFacingAngleTarget() : Boolean {
			return isFacingTarget;
		}
		
		public function fastforwardToServerTime(heading:Heading) : void {
			if(heading == null) {
				return;
			}
			while(heading.time < g.time - 33) {
				updateHeading(heading);
			}
		}
		
		public function updateHeading(heading:Heading) : void {
			var _local13:Point = null;
			var _local20:Number = NaN;
			var _local12:Number = NaN;
			var _local26:Number = NaN;
			var _local27:Number = NaN;
			var _local11:Boolean = false;
			var _local19:Number = NaN;
			var _local25:EnemyShip = null;
			var _local3:Number = NaN;
			var _local4:Number = NaN;
			var _local23:Number = NaN;
			var _local14:Number = NaN;
			var _local18:Number = NaN;
			var _local24:Number = NaN;
			var _local21:Number = NaN;
			var _local9:Number = NaN;
			var _local8:Number = NaN;
			var _local6:* = undefined;
			var _local15:int = 0;
			var _local22:int = 0;
			var _local17:Body = null;
			var _local2:Number = NaN;
			var _local7:Number = NaN;
			var _local5:Number = NaN;
			var _local16:Number = NaN;
			var _local28:Number = NaN;
			var _local10:Number = 33;
			if(ship is EnemyShip) {
			}
			if(ship is EnemyShip && angleTargetPos != null) {
				_local13 = ship.pos;
				_local20 = ship.rotation;
				_local12 = Math.atan2(angleTargetPos.y - _local13.y,angleTargetPos.x - _local13.x);
				_local26 = Util.angleDifference(_local20,_local12 + 3.141592653589793);
				_local27 = 0.001 * ship.engine.rotationSpeed * _local10;
				_local11 = _local26 > 0.5 * 3.141592653589793 || _local26 < -0.5 * 3.141592653589793;
				_local19 = (angleTargetPos.y - _local13.y) * (angleTargetPos.y - _local13.y) + (angleTargetPos.x - _local13.x) * (angleTargetPos.x - _local13.x);
				_local25 = ship as EnemyShip;
				if(_local19 < 2500 && _local25.meleeCharge) {
					isFacingTarget = false;
				} else if(!_local11) {
					heading.accelerate = true;
					heading.roll = false;
					if(_local26 > 0 && _local26 < 3.141592653589793 - _local27) {
						heading.rotation += _local27;
						heading.rotation = Util.clampRadians(heading.rotation);
						isFacingTarget = false;
					} else if(_local26 <= 0 && _local26 > -3.141592653589793 + _local27) {
						heading.rotation -= _local27;
						heading.rotation = Util.clampRadians(heading.rotation);
						isFacingTarget = false;
					}
				} else if(_local26 > 0 && _local26 < 3.141592653589793 - _local27) {
					heading.rotation += _local27;
					heading.rotation = Util.clampRadians(heading.rotation);
					isFacingTarget = false;
				} else if(_local26 <= 0 && _local26 > -3.141592653589793 + _local27) {
					heading.rotation -= _local27;
					heading.rotation = Util.clampRadians(heading.rotation);
					isFacingTarget = false;
				} else {
					isFacingTarget = true;
					heading.rotation = Util.clampRadians(_local12);
				}
			} else {
				if(heading.rotateLeft) {
					heading.rotation -= 0.001 * ship.engine.rotationSpeed * _local10;
					heading.rotation = Util.clampRadians(heading.rotation);
				}
				if(heading.rotateRight) {
					heading.rotation += 0.001 * ship.engine.rotationSpeed * _local10;
					heading.rotation = Util.clampRadians(heading.rotation);
				}
			}
			if(heading.accelerate) {
				_local3 = heading.speed.x;
				_local4 = heading.speed.y;
				_local23 = _local3 * _local3 + _local4 * _local4;
				_local14 = heading.rotation + ship.rollDir * ship.rollMod * ship.rollPassive;
				_local18 = ship.engine.acceleration * 0.5 * Math.pow(_local10,2);
				if(ship is EnemyShip) {
					_local3 += Math.cos(_local14) * _local18;
					_local4 += Math.sin(_local14) * _local18;
				} else {
					_local3 += Math.cos(heading.rotation) * _local18;
					_local4 += Math.sin(heading.rotation) * _local18;
				}
				_local24 = ship.engine.speed;
				if(ship.usingBoost) {
					_local24 = 0.01 * _local24 * (100 + ship.boostBonus);
				} else if(_local23 > _local24 * _local24) {
					_local24 = Math.sqrt(_local23);
				}
				if(ship.slowDownEndtime > g.time) {
					_local24 = ship.engine.speed * (1 - ship.slowDown);
				}
				_local23 = _local3 * _local3 + _local4 * _local4;
				if(_local23 <= _local24 * _local24) {
					heading.speed.x = _local3;
					heading.speed.y = _local4;
				} else {
					_local21 = Math.sqrt(_local23);
					_local9 = _local3 / _local21 * _local24;
					_local8 = _local4 / _local21 * _local24;
					heading.speed.x = _local9;
					heading.speed.y = _local8;
				}
			} else if(heading.deaccelerate) {
				heading.speed.x = 0.9 * heading.speed.x;
				heading.speed.y = 0.9 * heading.speed.y;
			} else if(ship is EnemyShip && heading.roll) {
				_local3 = heading.speed.x;
				_local4 = heading.speed.y;
				_local23 = _local3 * _local3 + _local4 * _local4;
				if(_local23 <= ship.rollSpeed * ship.rollSpeed) {
					_local14 = heading.rotation + ship.rollDir * ship.rollMod * 3.141592653589793 * 0.5;
					_local18 = ship.engine.acceleration * 0.5 * Math.pow(_local10,2);
					_local3 += Math.cos(_local14) * _local18;
					_local4 += Math.sin(_local14) * _local18;
					_local23 = _local3 * _local3 + _local4 * _local4;
					if(_local23 <= ship.rollSpeed * ship.rollSpeed) {
						heading.speed.x = _local3;
						heading.speed.y = _local4;
					} else {
						_local21 = Math.sqrt(_local23);
						_local9 = _local3 / _local21 * ship.rollSpeed;
						_local8 = _local4 / _local21 * ship.rollSpeed;
						heading.speed.x = _local9;
						heading.speed.y = _local8;
					}
				} else {
					heading.speed.x -= 0.02 * heading.speed.x;
					heading.speed.y -= 0.02 * heading.speed.y;
				}
			}
			if(ship is EnemyShip && !heading.accelerate) {
				heading.speed.x = 0.9 * heading.speed.x;
				heading.speed.y = 0.9 * heading.speed.y;
			} else {
				heading.speed.x -= 0.009 * heading.speed.x;
				heading.speed.y -= 0.009 * heading.speed.y;
			}
			if(ship is PlayerShip) {
				_local6 = g.bodyManager.bodies;
				_local15 = int(_local6.length);
				_local22 = 0;
				while(_local22 < _local15) {
					_local17 = _local6[_local22];
					if(_local17.type == "sun") {
						_local2 = _local17.pos.x - heading.pos.x;
						_local7 = _local17.pos.y - heading.pos.y;
						_local5 = _local2 * _local2 + _local7 * _local7;
						if(_local5 <= _local17.gravityDistance) {
							if(_local5 != 0) {
								if(_local5 < _local17.gravityMin) {
									_local5 = _local17.gravityMin;
								}
								_local16 = Math.atan2(_local7,_local2);
								_local16 = Util.clampRadians(_local16);
								_local28 = _local17.gravityForce / _local5 * _local10 * 0.001;
								heading.speed.x += Math.cos(_local16) * _local28;
								heading.speed.y += Math.sin(_local16) * _local28;
							}
						}
					}
					_local22++;
				}
			}
			heading.pos.x += heading.speed.x * _local10 * 0.001;
			heading.pos.y += heading.speed.y * _local10 * 0.001;
			heading.time += _local10;
		}
	}
}

