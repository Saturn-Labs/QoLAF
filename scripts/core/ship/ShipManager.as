package core.ship {
	import core.scene.Game;
	import core.spawner.Spawner;
	import core.states.AIStates.AIChase;
	import core.states.AIStates.AIExit;
	import core.states.AIStates.AIFollow;
	import core.states.AIStates.AIIdle;
	import core.states.AIStates.AIKamikaze;
	import core.states.AIStates.AIMelee;
	import core.states.AIStates.AIObserve;
	import core.states.AIStates.AIOrbit;
	import core.states.AIStates.AIResurect;
	import core.states.AIStates.AIReturnOrbit;
	import core.states.AIStates.AITeleport;
	import core.states.AIStates.AITeleportEntry;
	import core.states.AIStates.AITeleportExit;
	import core.unit.Unit;
	import core.weapon.Weapon;
	import debug.Console;
	import flash.utils.Dictionary;
	import generics.Random;
	import movement.Heading;
	import playerio.Message;
	
	public class ShipManager {
		private var g:Game;
		
		public var shipSync:ShipSync;
		
		public var ships:Vector.<Ship>;
		
		public var players:Vector.<PlayerShip>;
		
		private var inactivePlayers:Vector.<PlayerShip>;
		
		public var enemies:Vector.<EnemyShip>;
		
		private var inactiveEnemies:Vector.<EnemyShip>;
		
		public var enemiesById:Dictionary;
		
		public function ShipManager(g:Game) {
			var _local4:int = 0;
			var _local2:PlayerShip = null;
			var _local3:EnemyShip = null;
			ships = new Vector.<Ship>();
			players = new Vector.<PlayerShip>();
			inactivePlayers = new Vector.<PlayerShip>();
			enemies = new Vector.<EnemyShip>();
			inactiveEnemies = new Vector.<EnemyShip>();
			enemiesById = new Dictionary();
			super();
			this.g = g;
			shipSync = new ShipSync(g);
			_local4 = 0;
			while(_local4 < 4) {
				_local2 = new PlayerShip(g);
				inactivePlayers.push(_local2);
				_local4++;
			}
			_local4 = 0;
			while(_local4 < 20) {
				_local3 = new EnemyShip(g);
				inactiveEnemies.push(_local3);
				_local4++;
			}
		}
		
		public function addMessageHandlers() : void {
			shipSync.addMessageHandlers();
			g.addMessageHandler("enemyUpdate",onEnemyUpdate);
		}
		
		public function addEarlyMessageHandlers() : void {
			g.addMessageHandler("spawnEnemy",onSpawnEnemy);
		}
		
		public function update() : void {
			var _local1:int = 0;
			var _local2:Ship = null;
			_local1 = ships.length - 1;
			while(_local1 > -1) {
				_local2 = ships[_local1];
				if(_local2.alive) {
					_local2.update();
				} else {
					removeShip(_local2,_local1);
				}
				_local1--;
			}
		}
		
		public function getPlayerShip() : PlayerShip {
			var _local1:PlayerShip = null;
			if(inactivePlayers.length > 0) {
				_local1 = inactivePlayers.pop();
			} else {
				_local1 = new PlayerShip(g);
			}
			_local1.reset();
			return _local1;
		}
		
		public function activatePlayerShip(s:PlayerShip) : void {
			g.unitManager.add(s,g.canvasPlayerShips);
			ships.push(s);
			players.push(s);
			s.alive = true;
		}
		
		public function getEnemyShip() : EnemyShip {
			var _local1:EnemyShip = null;
			if(inactiveEnemies.length > 0) {
				_local1 = inactiveEnemies.pop();
			} else {
				_local1 = new EnemyShip(g);
			}
			_local1.reset();
			return _local1;
		}
		
		public function activateEnemyShip(s:EnemyShip) : void {
			g.unitManager.add(s,g.canvasEnemyShips);
			ships.push(s);
			enemies.push(s);
			s.alive = true;
		}
		
		public function removeShip(s:Ship, index:int) : void {
			ships.splice(index,1);
			var _local3:int = 0;
			if(s is PlayerShip) {
				_local3 = int(players.indexOf(PlayerShip(s)));
				players.splice(_local3,1);
				inactivePlayers.push(s);
			} else if(s is EnemyShip) {
				_local3 = int(enemies.indexOf(EnemyShip(s)));
				enemies.splice(_local3,1);
				inactiveEnemies.push(s);
				if(s.id.toString() in enemiesById) {
					delete enemiesById[s.id];
				}
			}
			g.unitManager.remove(s);
		}
		
		private function onSpawnEnemy(m:Message) : void {
			spawnEnemy(m);
		}
		
		public function spawnEnemy(m:Message, startIndex:int = 0, endIndex:int = 0) : void {
			var _local20:int = 0;
			var _local28:int = 0;
			var _local22:* = 0;
			var _local18:String = null;
			var _local17:int = 0;
			var _local30:int = 0;
			var _local21:String = null;
			var _local15:Number = NaN;
			var _local5:Number = NaN;
			var _local10:Number = NaN;
			var _local12:Number = NaN;
			var _local23:Number = NaN;
			var _local16:Number = NaN;
			var _local4:Boolean = false;
			var _local8:Boolean = false;
			var _local25:Spawner = null;
			var _local14:Heading = null;
			var _local7:EnemyShip = null;
			var _local11:Number = NaN;
			var _local24:int = 0;
			var _local19:int = 0;
			var _local26:Number = NaN;
			var _local6:int = 0;
			var _local9:int = 0;
			var _local13:Unit = null;
			var _local29:int = 21;
			if(endIndex != 0) {
				_local20 = endIndex - startIndex;
				_local28 = _local20 / _local29;
			} else {
				_local28 = m.length / _local29;
				endIndex = m.length;
			}
			if(_local28 == 0) {
				return;
			}
			_local22 = startIndex;
			while(_local22 < endIndex) {
				_local18 = m.getString(_local22++);
				_local17 = m.getInt(_local22++);
				_local30 = m.getInt(_local22++);
				_local21 = m.getString(_local22++);
				_local15 = m.getNumber(_local22++);
				_local5 = m.getNumber(_local22++);
				_local10 = m.getNumber(_local22++);
				_local12 = m.getNumber(_local22++);
				_local23 = m.getNumber(_local22++);
				_local16 = m.getNumber(_local22++);
				_local4 = m.getBoolean(_local22++);
				_local8 = m.getBoolean(_local22++);
				_local25 = g.spawnManager.getSpawnerByKey(_local21);
				_local14 = new Heading();
				_local22 = _local14.parseMessage(m,_local22);
				if(_local25 != null) {
					_local25.initialHardenedShield = false;
				}
				_local7 = ShipFactory.createEnemy(g,_local18,_local30);
				createSetEnemy(_local7,_local17,_local14,_local28,_local15,_local25,_local5,_local10,_local12,_local23,_local16,_local4);
				if(_local30 == 6) {
					_local7.hp = m.getInt(_local22++);
					_local7.hpMax = _local7.hp;
					_local7.shieldHp = m.getInt(_local22++);
					_local7.shieldHpMax = _local7.shieldHp;
					_local7.shieldRegen = m.getInt(_local22++);
					_local7.engine.speed = m.getNumber(_local22++);
					_local7.engine.acceleration = m.getNumber(_local22++);
					_local11 = m.getNumber(_local22++);
					_local24 = m.getInt(_local22++);
					_local19 = m.getInt(_local22++);
					_local26 = m.getNumber(_local22++);
					_local6 = m.getInt(_local22++);
					for each(var _local27 in _local7.weapons) {
						_local27.speed = _local11;
						_local27.ttl = _local24;
						_local27.numberOfHits = _local19;
						_local27.reloadTime = _local26;
						_local27.multiNrOfP = _local6;
					}
					_local7.name = m.getString(_local22++);
					_local9 = m.getInt(_local22++);
					_local13 = g.unitManager.getTarget(_local9);
					_local7.owner = _local13 as PlayerShip;
				}
				if(_local8 == true) {
					_local7.cloakStart();
				}
				_local22;
			}
		}
		
		private function createSetEnemy(enemy:EnemyShip, id:int, course:Heading, enemyCount:int, startTime:Number, s:Spawner, orbitAngle:Number, orbitRadius:Number, ellipseAlpha:Number, ellipseFactor:Number, angleVelocity:Number, spawnInOrbit:Boolean = false) : void {
			enemy.id = id;
			randomizeSpeed(enemy);
			enemy.initCourse(course);
			enemy.engine.pos.x = enemy.pos.x;
			enemy.engine.pos.y = enemy.pos.y;
			if(enemiesById[enemy.id] != null) {
				Console.write("ERROR: enemy alrdy in use with id: " + enemy.id);
			}
			enemiesById[enemy.id] = enemy;
			if(enemy.orbitSpawner && s != null) {
				enemy.spawner = s;
				enemy.orbitAngle = orbitAngle;
				enemy.orbitRadius = orbitRadius;
				enemy.ellipseFactor = ellipseFactor;
				enemy.ellipseAlpha = ellipseAlpha;
				enemy.angleVelocity = angleVelocity;
				enemy.orbitStartTime = startTime;
				if(spawnInOrbit) {
					enemy.stateMachine.changeState(new AIOrbit(g,enemy));
				} else {
					enemy.stateMachine.changeState(new AIReturnOrbit(g,enemy,ellipseAlpha,startTime,course,0));
				}
			} else if(enemy.teleport) {
				enemy.stateMachine.changeState(new AITeleportEntry(g,enemy,course));
			} else {
				enemy.stateMachine.changeState(new AIIdle(g,enemy,course));
			}
		}
		
		private function randomizeSpeed(enemy:EnemyShip) : void {
			var _local2:Random = new Random(1 / enemy.id);
			_local2.stepTo(1);
			enemy.engine.speed *= 0.8 + 0.001 * _local2.random(201);
			enemy.engine.rotationSpeed *= 0.6 + 0.002 * _local2.random(201);
		}
		
		public function getShipFromId(id:int) : Ship {
			for each(var _local2 in ships) {
				if(_local2.id == id) {
					return _local2;
				}
			}
			return null;
		}
		
		public function enemyFire(m:Message, i:int = 0) : void {
			var _local4:int = 0;
			var _local3:Weapon = null;
			var _local7:int = m.getInt(i);
			var _local8:int = m.getInt(i + 1);
			var _local5:Boolean = m.getBoolean(i + 2);
			var _local6:Ship = getShipFromId(_local7);
			var _local9:Unit = null;
			if(m.length > 3) {
				_local4 = m.getInt(i + 3);
				_local9 = g.unitManager.getTarget(_local4);
			}
			if(_local6 != null) {
				_local3 = _local6.weapons[_local8];
				_local3.fire = _local5;
				_local3.target = _local9;
			}
		}
		
		public function damaged(m:Message, i:int) : void {
			var _local5:int = 0;
			var _local4:int = m.getInt(i + 1);
			var _local3:EnemyShip = enemiesById[_local4];
			if(_local3 != null) {
				_local5 = m.getInt(i + 2);
				_local3.takeDamage(_local5);
				_local3.shieldHp = m.getInt(i + 3);
				if(_local3.shieldHp == 0) {
					if(_local3.shieldRegenCounter > -1000) {
						_local3.shieldRegenCounter = -1000;
					}
				}
				_local3.hp = m.getInt(i + 4);
				if(m.getBoolean(i + 5)) {
					_local3.doDOTEffect(m.getInt(i + 6),m.getString(i + 7),m.getInt(i + 8));
				}
			}
		}
		
		public function killed(m:Message, i:int) : void {
			var _local5:int = m.getInt(i);
			var _local3:Boolean = m.getBoolean(i + 1);
			var _local4:EnemyShip = enemiesById[_local5];
			if(_local4 != null) {
				_local4.destroy(_local3);
			}
		}
		
		private function syncEnemyTarget(m:Message, startIndex:int) : void {
			var _local3:* = 0;
			var _local4:EnemyShip = null;
			var _local6:String = null;
			var _local7:Unit = null;
			var _local5:int = 0;
			_local3 = startIndex;
			while(_local3 < m.length - 1) {
				_local4 = g.shipManager.enemiesById[m.getInt(_local3)];
				_local6 = m.getString(_local3 + 1);
				_local7 = g.unitManager.getTarget(m.getInt(_local3 + 2));
				if(_local4 != null) {
					if(!_local4.stateMachine.inState(_local6)) {
						switch(_local6) {
							case "AIObserve":
								_local4.stateMachine.changeState(new AIObserve(g,_local4,_local7,_local4.course,0));
								break;
							case "AIChase":
								_local4.stateMachine.changeState(new AIChase(g,_local4,_local7,_local4.course,0));
								break;
							case "AIResurect":
								_local4.stateMachine.changeState(new AIResurect(g,_local4));
								break;
							case "AIFollow":
								_local4.stateMachine.changeState(new AIFollow(g,_local4,_local7,_local4.course,0));
								break;
							case "AIMelee":
								_local4.stateMachine.changeState(new AIMelee(g,_local4,_local7,_local4.course,0));
								break;
							case "AIOrbit":
								_local4.stateMachine.changeState(new AIOrbit(g,_local4));
								break;
							case "AIIdle":
								_local4.stateMachine.changeState(new AIIdle(g,_local4,_local4.course));
								break;
							case "AIKamikaze":
								_local4.stateMachine.changeState(new AIKamikaze(g,_local4,_local7,_local4.course,0));
								break;
							case "AITeleport":
								_local4.stateMachine.changeState(new AITeleport(g,_local4,_local7));
								break;
							case "AITeleportExit":
								_local4.stateMachine.changeState(new AITeleportExit(g,_local4));
								break;
							case "AIExit":
								_local4.stateMachine.changeState(new AIExit(g,_local4));
						}
					}
					_local5 = 0;
					while(_local5 < _local4.weapons.length) {
						_local3++;
						_local4.weapons[_local5].target = _local7;
						_local4.weapons[_local5].fire = m.getBoolean(_local3 + 3);
						_local5++;
					}
				}
				_local3 += 4;
			}
		}
		
		public function initSyncEnemies(m:Message) : void {
			var _local2:* = 1;
			var _local3:int = _local2 + m.getInt(0);
			g.turretManager.syncTurretTarget(m,_local2,_local3);
			_local2 = _local3 + 1;
			_local3 = _local2 + m.getInt(_local3);
			g.projectileManager.addInitProjectiles(m,_local2,_local3);
			_local2 = _local3;
			syncEnemyTarget(m,_local2);
		}
		
		public function initEnemies(m:Message) : void {
			Console.write("running spawnEnemy");
			spawnEnemy(m,0,0);
		}
		
		private function onEnemyUpdate(m:Message) : void {
			var _local5:int = 0;
			var _local4:Boolean = false;
			var _local2:int = 0;
			var _local3:EnemyShip = g.shipManager.enemiesById[m.getInt(_local2++)];
			if(_local3 == null) {
				return;
			}
			_local3.hp = m.getInt(_local2++);
			_local3.shieldHp = m.getInt(_local2++);
			if(_local3.hp < _local3.hpMax || _local3.shieldHp < _local3.shieldHpMax) {
				_local3.isInjured = true;
			}
			var _local6:Ship = g.shipManager.getShipFromId(m.getInt(_local2++));
			_local5 = 0;
			while(_local5 < _local3.weapons.length) {
				_local4 = m.getBoolean(_local2++);
				_local3.weapons[_local5].fire = _local4;
				_local3.weapons[_local5].target = _local4 ? _local6 : null;
				_local5++;
			}
		}
		
		public function dispose() : void {
			var _local1:* = null;
			for each(_local1 in enemies) {
				_local1.removeFromCanvas();
				_local1.reset();
			}
			g.removeMessageHandler("spawnEnemy",onSpawnEnemy);
			enemies = null;
			inactiveEnemies = null;
			for each(_local1 in players) {
				_local1.removeFromCanvas();
				_local1.reset();
			}
			players = null;
			inactivePlayers = null;
		}
	}
}

