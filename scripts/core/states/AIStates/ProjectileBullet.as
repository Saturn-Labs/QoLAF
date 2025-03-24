package core.states.AIStates {
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	import flash.geom.Point;
	
	public class ProjectileBullet implements IState {
		protected var m:Game;
		
		protected var p:Projectile;
		
		protected var sm:StateMachine;
		
		protected var isEnemy:Boolean;
		
		private var globalInterval:Number = 1000;
		
		private var localTargetList:Vector.<Unit>;
		
		private var nextGlobalUpdate:Number;
		
		private var nextLocalUpdate:Number;
		
		private var localRangeSQ:Number;
		
		private var firstUpdate:Boolean;
		
		public function ProjectileBullet(m:Game, p:Projectile) {
			super();
			this.m = m;
			this.p = p;
			if(p.isHeal || p.unit.factions.length > 0) {
				this.isEnemy = false;
			} else {
				this.isEnemy = p.unit.type == "enemyShip" || p.unit.type == "turret";
			}
		}
		
		public function enter() : void {
			if(p.ttl < globalInterval) {
				globalInterval = p.ttl;
			}
			localTargetList = new Vector.<Unit>();
			firstUpdate = true;
			nextGlobalUpdate = 0;
			nextLocalUpdate = 0;
			localRangeSQ = globalInterval * 0.001 * (p.speedMax + 500);
			localRangeSQ *= localRangeSQ;
			if(p.unit.lastBulletTargetList != null) {
				if(p.unit.lastBulletGlobal > m.time) {
					nextGlobalUpdate = p.unit.lastBulletGlobal;
					localTargetList = p.unit.lastBulletTargetList;
					firstUpdate = false;
				} else {
					p.unit.lastBulletTargetList = null;
					firstUpdate = true;
				}
				if(p.unit.lastBulletLocal > m.time + 50) {
					nextLocalUpdate = p.unit.lastBulletLocal - 50;
					firstUpdate = false;
				}
			}
		}
		
		public function execute() : void {
			var _local22:Unit = null;
			var _local19:Number = NaN;
			var _local13:Number = NaN;
			var _local27:Number = NaN;
			var _local26:Number = NaN;
			var _local20:int = 0;
			var _local15:* = undefined;
			var _local17:int = 0;
			var _local16:Number = NaN;
			var _local21:* = undefined;
			var _local9:Boolean = false;
			var _local2:Number = 33;
			var _local1:int = (p.convergenceTime - p.convergenceCounter) / p.convergenceTime;
			if(_local1 <= 0) {
				p.error = null;
			}
			if(p.error != null) {
				p.course.pos.x += p.error.x * _local1;
				p.course.pos.y += p.error.y * _local1;
			}
			p.oldPos.x = p.course.pos.x;
			p.oldPos.y = p.course.pos.y;
			p.updateHeading(p.course);
			if(p.error != null) {
				p.convergenceCounter++;
				_local1 = (p.convergenceTime - p.convergenceCounter) / p.convergenceTime;
				p.course.pos.x -= p.error.x * _local1;
				p.course.pos.y -= p.error.y * _local1;
			}
			if(nextLocalUpdate > m.time) {
				return;
			}
			var _local25:* = 100000000;
			var _local3:Point = p.course.pos;
			if(_local3.y == p.oldPos.y && _local3.x == p.oldPos.x) {
				return;
			}
			var _local5:Number = -Math.atan2(_local3.y - p.oldPos.y,_local3.x - p.oldPos.x);
			var _local23:Number = Math.cos(_local5);
			var _local10:Number = Math.sin(_local5);
			var _local4:Number = p.oldPos.x * _local23 - p.oldPos.y * _local10;
			var _local7:Number = p.oldPos.x * _local10 + p.oldPos.y * _local23;
			var _local8:Number = _local3.x * _local23 - _local3.y * _local10;
			var _local6:Number = _local3.x * _local10 + _local3.y * _local23;
			var _local11:Number = p.collisionRadius;
			var _local12:Number = Math.min(_local4,_local8) - _local11;
			var _local14:Number = Math.max(_local4,_local8) + _local11;
			var _local24:Number = Math.min(_local7,_local6) - _local11;
			var _local18:Number = Math.max(_local7,_local6) + _local11;
			if(isEnemy) {
				_local20 = int(m.shipManager.players.length);
				_local15 = m.shipManager.players;
				_local17 = 0;
				while(_local17 < _local20) {
					_local22 = _local15[_local17];
					if(!(!_local22.alive || _local22 == p.unit || _local22.invulnerable)) {
						_local19 = _local22.pos.x;
						_local13 = _local22.pos.y;
						_local27 = _local3.x - _local19;
						_local26 = _local3.y - _local13;
						_local16 = _local27 * _local27 + _local26 * _local26;
						if(_local25 > _local16) {
							_local25 = _local16;
						}
						if(_local16 <= 2500) {
							_local4 = _local19 * _local23 - _local13 * _local10;
							_local7 = _local19 * _local10 + _local13 * _local23;
							_local11 = _local22.collisionRadius;
							if(_local4 <= _local14 + _local11 && _local4 > _local12 - _local11 && _local7 <= _local18 + _local11 && _local7 > _local24 - _local11) {
								if(p.debuffType == 2) {
									_local3.y = (_local24 * _local23 / _local10 - _local4 + (_local11 - p.collisionRadius)) / (1 * _local10 + _local23 * _local23 / _local10);
									_local3.x = (_local24 - _local3.y * _local23) / _local10;
									p.ttl = p.weapon.debuffDuration * 1000;
									sm.changeState(new ProjectileStuck(m,p,_local22));
									return;
								}
								if(p.numberOfHits <= 1) {
									_local3.y = (_local24 * _local23 / _local10 - _local4 + (_local11 - p.collisionRadius)) / (1 * _local10 + _local23 * _local23 / _local10);
									_local3.x = (_local24 - _local3.y * _local23) / _local10;
									p.destroy();
									return;
								}
								p.explode();
								if(p.numberOfHits >= 10) {
									p.numberOfHits--;
								}
							}
						}
					}
					_local17++;
				}
				nextLocalUpdate = m.time + Math.sqrt(_local25) * 1000 / (p.speedMax + 5 * 60) - 35;
				if(firstUpdate) {
					firstUpdate = false;
					p.unit.lastBulletLocal = nextLocalUpdate;
				}
			} else {
				if(nextGlobalUpdate < m.time) {
					if(p.unit.lastBulletGlobal > m.time - 35 && p.unit.lastBulletTargetList != null) {
						localTargetList = p.unit.lastBulletTargetList;
						_local21 = localTargetList;
						_local9 = false;
						nextGlobalUpdate = m.time + 1000;
					} else {
						_local9 = true;
						_local21 = m.unitManager.units;
						localTargetList.splice(0,localTargetList.length);
						nextGlobalUpdate = m.time + 1000;
					}
				} else {
					_local9 = false;
					_local21 = localTargetList;
				}
				_local20 = int(_local21.length);
				_local17 = 0;
				while(_local17 < _local20) {
					_local22 = _local21[_local17];
					if(_local22.canBeDamage(p.unit,p)) {
						_local19 = _local22.pos.x;
						_local13 = _local22.pos.y;
						_local27 = _local3.x - _local19;
						_local26 = _local3.y - _local13;
						_local16 = _local27 * _local27 + _local26 * _local26;
						if(_local9 && _local16 < localRangeSQ) {
							localTargetList.push(_local22);
						}
						if(_local25 > _local16) {
							_local25 = _local16;
						}
						if(_local16 <= 2500) {
							_local4 = _local19 * _local23 - _local13 * _local10;
							_local7 = _local19 * _local10 + _local13 * _local23;
							_local11 = _local22.collisionRadius;
							if(_local4 <= _local14 + _local11 && _local4 > _local12 - _local11 && _local7 <= _local18 + _local11 && _local7 > _local24 - _local11) {
								if(p.debuffType == 2) {
									_local3.y = (_local24 * _local23 / _local10 - _local4 + (_local11 - p.collisionRadius)) / (1 * _local10 + _local23 * _local23 / _local10);
									_local3.x = (_local24 - _local3.y * _local23) / _local10;
									p.ttl = p.weapon.debuffDuration * 1000;
									sm.changeState(new ProjectileStuck(m,p,_local22));
									return;
								}
								if(p.numberOfHits <= 1) {
									_local3.y = (_local24 * _local23 / _local10 - _local4 + (_local11 - p.collisionRadius)) / (1 * _local10 + _local23 * _local23 / _local10);
									_local3.x = (_local24 - _local3.y * _local23) / _local10;
									p.destroy();
									return;
								}
								p.explode();
								if(p.numberOfHits >= 10) {
									p.numberOfHits--;
								}
							}
						}
					}
					_local17++;
				}
				nextLocalUpdate = m.time + Math.sqrt(_local25) * 1000 / (p.speedMax + 400) - 35;
				if(nextGlobalUpdate < nextLocalUpdate) {
					nextGlobalUpdate = nextLocalUpdate;
				}
				if(_local9) {
					_local9 = false;
					firstUpdate = false;
					p.unit.lastBulletGlobal = nextGlobalUpdate;
					p.unit.lastBulletLocal = nextLocalUpdate;
					p.unit.lastBulletTargetList = localTargetList;
				}
			}
		}
		
		public function exit() : void {
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
		
		public function get type() : String {
			return "ProjectileBullet";
		}
	}
}

