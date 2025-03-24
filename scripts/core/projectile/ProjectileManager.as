package core.projectile {
	import core.particle.EmitterFactory;
	import core.player.Player;
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.ship.PlayerShip;
	import core.ship.Ship;
	import core.states.AIStates.ProjectileStuck;
	import core.turret.Turret;
	import core.unit.Unit;
	import core.weapon.ProjectileGun;
	import core.weapon.Weapon;
	import debug.Console;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import generics.Util;
	import movement.Heading;
	import playerio.Message;
	import starling.display.MeshBatch;
	
	public class ProjectileManager {
		public var inactiveProjectiles:Vector.<Projectile>;
		
		public var projectiles:Vector.<Projectile>;
		
		public var projectilesById:Dictionary;
		
		private var TARGET_TYPE_SHIP:String = "ship";
		
		private var TARGET_TYPE_SPAWNER:String = "spawner";
		
		private var g:Game;
		
		private var meshBatch:MeshBatch;
		
		public function ProjectileManager(g:Game) {
			var _local3:int = 0;
			var _local2:Projectile = null;
			inactiveProjectiles = new Vector.<Projectile>();
			projectiles = new Vector.<Projectile>();
			projectilesById = new Dictionary();
			meshBatch = new MeshBatch();
			super();
			this.g = g;
			_local3 = 0;
			while(_local3 < 100) {
				_local2 = new Projectile(g);
				inactiveProjectiles.push(_local2);
				_local3++;
			}
		}
		
		public function addMessageHandlers() : void {
			g.addMessageHandler("projectileAddEnemy",addEnemyProjectile);
			g.addMessageHandler("projectileAddPlayer",addPlayerProjectile);
			g.addMessageHandler("projectileCourse",updateCourse);
			g.addMessageHandler("killProjectile",killProjectile);
			g.addMessageHandler("killStuckProjectiles",killStuckProjectiles);
			g.canvasProjectiles.addChild(meshBatch);
		}
		
		public function update() : void {
			var _local2:int = 0;
			var _local1:Projectile = null;
			meshBatch.clear();
			var _local3:int = int(projectiles.length);
			_local2 = _local3 - 1;
			while(_local2 > -1) {
				_local1 = projectiles[_local2];
				if(_local1.alive) {
					_local1.update();
					if(_local1.hasImage && _local1.isVisible) {
						meshBatch.addMesh(_local1.movieClip);
					}
				} else {
					remove(_local1,_local2);
				}
				_local2--;
			}
		}
		
		public function getProjectile() : Projectile {
			var _local1:Projectile = null;
			if(inactiveProjectiles.length > 0) {
				_local1 = inactiveProjectiles.pop();
			} else {
				_local1 = new Projectile(g);
			}
			_local1.reset();
			return _local1;
		}
		
		public function handleBouncing(m:Message, i:int) : void {
			var _local5:int = m.getInt(i);
			var _local4:int = m.getInt(i + 1);
			var _local3:Projectile = projectilesById[_local5];
			if(_local3 == null) {
				return;
			}
			_local3.target = g.unitManager.getTarget(_local4);
		}
		
		public function activateProjectile(p:Projectile) : void {
			p.x = p.course.pos.x;
			p.y = p.course.pos.y;
			if(p.randomAngle) {
				p.rotation = Math.random() * 3.141592653589793 * 2;
			} else {
				p.rotation = p.course.rotation;
			}
			projectiles.push(p);
			p.addToCanvas();
			p.tryAddRibbonTrail();
			if(projectilesById[p.id] != null) {
				Console.write("error: p.id: " + p.id);
			}
			if(p.id != 0) {
				projectilesById[p.id] = p;
			}
		}
		
		public function addEnemyProjectile(m:Message) : void {
			var _local5:int = 0;
			var _local12:int = 0;
			var _local14:int = 0;
			var _local9:int = 0;
			var _local11:Heading = null;
			var _local6:int = 0;
			var _local2:int = 0;
			var _local3:int = 0;
			var _local8:Number = NaN;
			var _local7:EnemyShip = null;
			var _local10:Weapon = null;
			var _local4:Turret = null;
			var _local13:Dictionary = g.shipManager.enemiesById;
			_local5 = 0;
			while(_local5 < m.length - 6) {
				_local12 = m.getInt(_local5);
				_local14 = m.getInt(_local5 + 1);
				_local9 = m.getInt(_local5 + 2);
				_local11 = new Heading();
				_local11.parseMessage(m,_local5 + 3);
				_local6 = m.getInt(_local5 + 3 + 10);
				_local2 = m.getInt(_local5 + 4 + 10);
				_local3 = m.getInt(_local5 + 5 + 10);
				_local8 = m.getNumber(_local5 + 6 + 10);
				_local7 = _local13[_local14];
				if(_local7 != null && _local7.weapons.length > _local9 && _local7.weapons[_local9] != null) {
					_local10 = _local7.weapons[_local9];
					createSetProjectile(ProjectileFactory.create(_local10.projectileFunction,g,_local7,_local10,_local11),_local12,_local7,_local11,_local6,_local2,_local3,_local8);
				} else {
					_local4 = g.turretManager.getTurretById(_local14);
					if(_local4 != null && _local4.weapon != null) {
						_local10 = _local4.weapon;
						createSetProjectile(ProjectileFactory.create(_local10.projectileFunction,g,_local4,_local10),_local12,_local4,_local11,_local6,_local2,_local3,_local8);
					}
				}
				_local5 += 7 + 10;
			}
		}
		
		public function addInitProjectiles(m:Message, startIndex:int, endIndex:int) : void {
			var _local5:* = 0;
			var _local9:int = 0;
			var _local11:int = 0;
			var _local10:int = 0;
			var _local6:Ship = null;
			var _local7:Heading = null;
			var _local8:int = 0;
			var _local4:Weapon = null;
			_local5 = startIndex;
			while(_local5 < endIndex - 4) {
				_local9 = m.getInt(_local5);
				_local11 = m.getInt(_local5 + 1);
				_local10 = m.getInt(_local5 + 2);
				_local6 = g.unitManager.getTarget(_local11) as Ship;
				_local7 = new Heading();
				_local7.pos.x = m.getNumber(_local5 + 3);
				_local7.pos.y = m.getNumber(_local5 + 4);
				_local8 = m.getNumber(_local5 + 5);
				if(_local6 != null && _local10 > 0 && _local10 < _local6.weapons.length) {
					_local4 = _local6.weapons[_local10];
					createSetProjectile(ProjectileFactory.create(_local4.projectileFunction,g,_local6,_local4),_local9,_local6,_local7,_local8);
				}
				_local5 += 6;
			}
		}
		
		public function addPlayerProjectile(m:Message) : void {
			var _local6:int = 0;
			var _local13:int = 0;
			var _local14:String = null;
			var _local9:int = 0;
			var _local2:int = 0;
			var _local4:Heading = null;
			var _local7:int = 0;
			var _local3:int = 0;
			var _local5:int = 0;
			var _local8:Number = NaN;
			var _local15:Player = null;
			var _local11:PlayerShip = null;
			var _local12:ProjectileGun = null;
			var _local10:Unit = null;
			_local6 = 0;
			while(_local6 < m.length - 8 - 10) {
				if(m.length < 6 + 10) {
					return;
				}
				_local13 = m.getInt(_local6);
				_local14 = m.getString(_local6 + 1);
				_local9 = m.getInt(_local6 + 2);
				_local2 = m.getInt(_local6 + 3);
				_local4 = new Heading();
				_local4.parseMessage(m,_local6 + 5);
				if(_local13 == -1) {
					EmitterFactory.create("A086BD35-4F9B-5BD4-518F-4C543B2AB0CF",g,_local4.pos.x,_local4.pos.y,null,true);
					return;
				}
				_local7 = m.getInt(_local6 + 5 + 10);
				_local3 = m.getInt(_local6 + 6 + 10);
				_local5 = m.getInt(_local6 + 7 + 10);
				_local8 = m.getNumber(_local6 + 8 + 10);
				_local15 = g.playerManager.playersById[_local14];
				if(_local15 == null) {
					return;
				}
				_local11 = _local15.ship;
				if(_local11 == null || _local11.weapons == null) {
					return;
				}
				if(!(_local9 > -1 && _local9 < _local15.ship.weapons.length)) {
					return;
				}
				_local15.selectedWeaponIndex = _local9;
				if(_local11.weapon != null && _local11.weapon is ProjectileGun) {
					_local12 = _local11.weapon as ProjectileGun;
					_local10 = null;
					if(_local2 != -1) {
						_local10 = g.unitManager.getTarget(_local2);
					}
					_local12.shootSyncedProjectile(_local13,_local10,_local4,_local7,m.getNumber(_local6 + 4),_local3,_local5,_local8);
				}
				_local6 += 9 + 10;
			}
		}
		
		private function createSetProjectile(p:Projectile, id:int, enemy:Unit, course:Heading, multiPid:int, xRandOffset:int = 0, yRandOffset:int = 0, maxSpeed:Number = 0) : void {
			var _local11:Point = null;
			var _local12:Number = NaN;
			var _local14:Number = NaN;
			var _local13:Number = NaN;
			var _local9:Number = NaN;
			var _local10:Number = NaN;
			if(p == null) {
				return;
			}
			var _local15:Weapon = p.weapon;
			p.id = id;
			if(maxSpeed != 0) {
				p.speedMax = maxSpeed;
			}
			if(p.speedMax != 0) {
				_local11 = new Point();
				if(multiPid > -1) {
					_local12 = _local15.multiNrOfP;
					_local14 = enemy.weaponPos.y + _local15.multiOffset * (multiPid - 0.5 * (_local12 - 1)) / _local12;
				} else {
					_local14 = enemy.weaponPos.y;
				}
				_local13 = enemy.weaponPos.x + _local15.positionOffsetX;
				_local9 = new Point(_local13,_local14).length;
				_local10 = Math.atan2(_local14,_local13);
				_local11.x = enemy.pos.x + Math.cos(enemy.rotation + _local10) * _local9 + xRandOffset;
				_local11.y = enemy.pos.y + Math.sin(enemy.rotation + _local10) * _local9 + yRandOffset;
				p.unit = enemy;
				p.course = course;
				p.rotation = course.rotation;
				p.fastforward();
				p.x = course.pos.x;
				p.y = course.pos.y;
				p.collisionRadius = 0.5 * p.collisionRadius;
				p.error = new Point(-p.course.pos.x + _local11.x,-p.course.pos.y + _local11.y);
				p.convergenceCounter = 0;
				p.course = course;
				p.convergenceTime = 151.51515151515153;
				if(p.error.length > 1000) {
					p.error.x = 0;
					p.error.y = 0;
				}
				if(maxSpeed != 0) {
					if(p.stateMachine.inState("Instant")) {
						p.range = maxSpeed;
						p.speedMax = 10000;
					} else {
						p.speedMax = maxSpeed;
					}
				}
			} else {
				p.course = course;
				p.x = course.pos.x;
				p.y = course.pos.y;
			}
			activateProjectile(p);
			_local15.playFireSound();
		}
		
		private function updateCourse(m:Message) : void {
			var _local5:int = 0;
			var _local6:int = 0;
			var _local7:int = 0;
			var _local2:Projectile = null;
			var _local3:int = 0;
			var _local9:Number = NaN;
			var _local4:Heading = null;
			var _local8:Dictionary = g.shipManager.enemiesById;
			_local5 = 0;
			while(_local5 < m.length) {
				_local6 = m.getInt(_local5);
				_local7 = m.getInt(_local5 + 1);
				_local2 = projectilesById[_local6];
				if(_local2 == null) {
					return;
				}
				_local3 = m.getInt(_local5 + 2);
				if(_local7 == 0) {
					_local2.direction = _local3;
					if(_local2.direction > 0) {
						_local2.boomerangReturning = true;
						_local2.rotationSpeedMax = m.getNumber(_local5 + 3);
					}
					if(_local3 == 3) {
						_local2.course.rotation = Util.clampRadians(_local2.course.rotation + 3.141592653589793);
					}
				} else if(_local7 == 1) {
					_local2.target = g.unitManager.getTarget(_local3);
					_local2.targetProjectile = null;
					_local9 = m.getNumber(_local5 + 3);
					if(_local9 > 0) {
						_local2.aiStuck = true;
						_local2.aiStuckDuration = _local9;
					}
				} else if(_local7 == 2) {
					_local2.aiStuck = false;
					_local2.target = null;
					_local2.targetProjectile = projectilesById[_local3];
				} else if(_local7 == 3) {
					_local2.aiStuck = false;
					_local2.target = null;
					_local2.targetProjectile = null;
					_local4 = new Heading();
					_local4.parseMessage(m,_local5 + 4);
					_local2.error = new Point(_local2.course.pos.x - _local4.pos.x,_local2.course.pos.y - _local4.pos.y);
					_local2.errorRot = Util.clampRadians(_local2.course.rotation - _local4.rotation);
					if(_local2.errorRot > 3.141592653589793) {
						_local2.errorRot -= 2 * 3.141592653589793;
					}
					_local2.convergenceCounter = 0;
					_local2.course = _local4;
					_local2.convergenceTime = 500 / 33;
				} else {
					_local4 = new Heading();
					_local4.parseMessage(m,_local5 + 4);
					while(_local4.time < _local2.course.time) {
						_local2.updateHeading(_local4);
					}
					_local2.course = _local4;
				}
				_local5 += 4 + 10;
			}
		}
		
		private function killProjectile(m:Message) : void {
			var _local3:int = 0;
			var _local4:int = 0;
			var _local2:Projectile = null;
			_local3 = 0;
			while(_local3 < m.length) {
				_local4 = m.getInt(_local3);
				_local2 = projectilesById[_local4];
				if(_local2 != null) {
					_local2.destroy();
				}
				_local3++;
			}
		}
		
		private function killStuckProjectiles(m:Message) : void {
			var _local4:int = m.getInt(0);
			var _local3:Unit = g.unitManager.getTarget(_local4);
			if(_local3 == null) {
				return;
			}
			for each(var _local2 in projectiles) {
				if(_local2.stateMachine.inState(ProjectileStuck) && _local2.target == _local3) {
					_local2.destroy(true);
				}
			}
		}
		
		public function remove(p:Projectile, index:int) : void {
			projectiles.splice(index,1);
			inactiveProjectiles.push(p);
			if(p.id != 0) {
				delete projectilesById[p.id];
			}
			p.removeFromCanvas();
			p.reset();
		}
		
		public function forceUpdate() : void {
			var _local1:Projectile = null;
			var _local2:int = 0;
			_local2 = 0;
			while(_local2 < projectiles.length) {
				_local1 = projectiles[_local2];
				_local1.nextDistanceCalculation = -1;
				_local2++;
			}
		}
		
		public function dispose() : void {
			for each(var _local1 in projectiles) {
				_local1.removeFromCanvas();
				_local1.reset();
			}
			projectiles = null;
			projectilesById = null;
			inactiveProjectiles = null;
		}
	}
}

