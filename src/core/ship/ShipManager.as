package core.ship
{
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
	
	public class ShipManager
	{
		private var g:Game;
		
		public var shipSync:ShipSync;
		
		public var ships:Vector.<Ship>;
		
		public var players:Vector.<PlayerShip>;
		
		private var inactivePlayers:Vector.<PlayerShip>;
		
		public var enemies:Vector.<EnemyShip>;
		
		private var inactiveEnemies:Vector.<EnemyShip>;
		
		public var enemiesById:Dictionary;
		
		public function ShipManager(param1:Game)
		{
			var _loc4_:int = 0;
			var _loc3_:PlayerShip = null;
			var _loc2_:EnemyShip = null;
			ships = new Vector.<Ship>();
			players = new Vector.<PlayerShip>();
			inactivePlayers = new Vector.<PlayerShip>();
			enemies = new Vector.<EnemyShip>();
			inactiveEnemies = new Vector.<EnemyShip>();
			enemiesById = new Dictionary();
			super();
			this.g = param1;
			shipSync = new ShipSync(param1);
			_loc4_ = 0;
			while (_loc4_ < 4)
			{
				_loc3_ = new PlayerShip(param1);
				inactivePlayers.push(_loc3_);
				_loc4_++;
			}
			_loc4_ = 0;
			while (_loc4_ < 20)
			{
				_loc2_ = new EnemyShip(param1);
				inactiveEnemies.push(_loc2_);
				_loc4_++;
			}
		}
		
		public function addMessageHandlers():void
		{
			shipSync.addMessageHandlers();
			g.addMessageHandler("enemyUpdate", onEnemyUpdate);
		}
		
		public function addEarlyMessageHandlers():void
		{
			g.addMessageHandler("spawnEnemy", onSpawnEnemy);
		}
		
		public function update():void
		{
			var _loc2_:int = 0;
			var _loc1_:Ship = null;
			_loc2_ = ships.length - 1;
			while (_loc2_ > -1)
			{
				_loc1_ = ships[_loc2_];
				if (_loc1_.alive)
				{
					_loc1_.update();
				}
				else
				{
					removeShip(_loc1_, _loc2_);
				}
				_loc2_--;
			}
		}
		
		public function getPlayerShip():PlayerShip
		{
			var _loc1_:PlayerShip = null;
			if (inactivePlayers.length > 0)
			{
				_loc1_ = inactivePlayers.pop();
			}
			else
			{
				_loc1_ = new PlayerShip(g);
			}
			_loc1_.reset();
			return _loc1_;
		}
		
		public function activatePlayerShip(param1:PlayerShip):void
		{
			g.unitManager.add(param1, g.canvasPlayerShips);
			ships.push(param1);
			players.push(param1);
			param1.alive = true;
		}
		
		public function getEnemyShip():EnemyShip
		{
			var _loc1_:EnemyShip = null;
			if (inactiveEnemies.length > 0)
			{
				_loc1_ = inactiveEnemies.pop();
			}
			else
			{
				_loc1_ = new EnemyShip(g);
			}
			_loc1_.reset();
			return _loc1_;
		}
		
		public function activateEnemyShip(param1:EnemyShip):void
		{
			g.unitManager.add(param1, g.canvasEnemyShips);
			ships.push(param1);
			enemies.push(param1);
			param1.alive = true;
		}
		
		public function removeShip(param1:Ship, param2:int):void
		{
			ships.splice(param2, 1);
			var _loc3_:int = 0;
			if (param1 is PlayerShip)
			{
				_loc3_ = int(players.indexOf(PlayerShip(param1)));
				players.splice(_loc3_, 1);
				inactivePlayers.push(param1);
			}
			else if (param1 is EnemyShip)
			{
				_loc3_ = int(enemies.indexOf(EnemyShip(param1)));
				enemies.splice(_loc3_, 1);
				inactiveEnemies.push(param1);
				if (param1.id.toString() in enemiesById)
				{
					delete enemiesById[param1.id];
				}
			}
			g.unitManager.remove(param1);
		}
		
		private function onSpawnEnemy(param1:Message):void
		{
			spawnEnemy(param1);
		}
		
		public function spawnEnemy(param1:Message, param2:int = 0, param3:int = 0):void
		{
			var _loc4_:int = 0;
			var _loc25_:int = 0;
			var _loc26_:* = 0;
			var _loc17_:String = null;
			var _loc9_:int = 0;
			var _loc16_:int = 0;
			var _loc12_:String = null;
			var _loc8_:Number = NaN;
			var _loc19_:Number = NaN;
			var _loc14_:Number = NaN;
			var _loc7_:Number = NaN;
			var _loc23_:Number = NaN;
			var _loc11_:Number = NaN;
			var _loc21_:Boolean = false;
			var _loc28_:Boolean = false;
			var _loc29_:Spawner = null;
			var _loc10_:Heading = null;
			var _loc18_:EnemyShip = null;
			var _loc20_:Number = NaN;
			var _loc24_:int = 0;
			var _loc22_:int = 0;
			var _loc6_:Number = NaN;
			var _loc30_:int = 0;
			var _loc5_:int = 0;
			var _loc13_:Unit = null;
			var _loc15_:int = 21;
			if (param3 != 0)
			{
				_loc4_ = param3 - param2;
				_loc25_ = _loc4_ / _loc15_;
			}
			else
			{
				_loc25_ = param1.length / _loc15_;
				param3 = param1.length;
			}
			if (_loc25_ == 0)
			{
				return;
			}
			_loc26_ = param2;
			while (_loc26_ < param3)
			{
				_loc17_ = param1.getString(_loc26_++);
				_loc9_ = param1.getInt(_loc26_++);
				_loc16_ = param1.getInt(_loc26_++);
				_loc12_ = param1.getString(_loc26_++);
				_loc8_ = param1.getNumber(_loc26_++);
				_loc19_ = param1.getNumber(_loc26_++);
				_loc14_ = param1.getNumber(_loc26_++);
				_loc7_ = param1.getNumber(_loc26_++);
				_loc23_ = param1.getNumber(_loc26_++);
				_loc11_ = param1.getNumber(_loc26_++);
				_loc21_ = param1.getBoolean(_loc26_++);
				_loc28_ = param1.getBoolean(_loc26_++);
				_loc29_ = g.spawnManager.getSpawnerByKey(_loc12_);
				_loc10_ = new Heading();
				_loc26_ = _loc10_.parseMessage(param1, _loc26_);
				if (_loc29_ != null)
				{
					_loc29_.initialHardenedShield = false;
				}
				_loc18_ = ShipFactory.createEnemy(g, _loc17_, _loc16_);
				createSetEnemy(_loc18_, _loc9_, _loc10_, _loc25_, _loc8_, _loc29_, _loc19_, _loc14_, _loc7_, _loc23_, _loc11_, _loc21_);
				if (_loc16_ == 6)
				{
					_loc18_.hp = param1.getInt(_loc26_++);
					_loc18_.hpMax = _loc18_.hp;
					_loc18_.shieldHp = param1.getInt(_loc26_++);
					_loc18_.shieldHpMax = _loc18_.shieldHp;
					_loc18_.shieldRegen = param1.getInt(_loc26_++);
					_loc18_.engine.speed = param1.getNumber(_loc26_++);
					_loc18_.engine.acceleration = param1.getNumber(_loc26_++);
					_loc20_ = param1.getNumber(_loc26_++);
					_loc24_ = param1.getInt(_loc26_++);
					_loc22_ = param1.getInt(_loc26_++);
					_loc6_ = param1.getNumber(_loc26_++);
					_loc30_ = param1.getInt(_loc26_++);
					for each (var _loc27_:* in _loc18_.weapons)
					{
						_loc27_.speed = _loc20_;
						_loc27_.ttl = _loc24_;
						_loc27_.numberOfHits = _loc22_;
						_loc27_.reloadTime = _loc6_;
						_loc27_.multiNrOfP = _loc30_;
					}
					_loc18_.name = param1.getString(_loc26_++);
					_loc5_ = param1.getInt(_loc26_++);
					_loc13_ = g.unitManager.getTarget(_loc5_);
					_loc18_.owner = _loc13_ as PlayerShip;
				}
				if (_loc28_ == true)
				{
					_loc18_.cloakStart();
				}
				_loc26_;
			}
		}
		
		private function createSetEnemy(param1:EnemyShip, param2:int, param3:Heading, param4:int, param5:Number, param6:Spawner, param7:Number, param8:Number, param9:Number, param10:Number, param11:Number, param12:Boolean = false):void
		{
			param1.id = param2;
			randomizeSpeed(param1);
			param1.initCourse(param3);
			param1.engine.pos.x = param1.pos.x;
			param1.engine.pos.y = param1.pos.y;
			if (enemiesById[param1.id] != null)
			{
				Console.write("ERROR: enemy alrdy in use with id: " + param1.id);
			}
			enemiesById[param1.id] = param1;
			if (param1.orbitSpawner && param6 != null)
			{
				param1.spawner = param6;
				param1.orbitAngle = param7;
				param1.orbitRadius = param8;
				param1.ellipseFactor = param10;
				param1.ellipseAlpha = param9;
				param1.angleVelocity = param11;
				param1.orbitStartTime = param5;
				if (param12)
				{
					param1.stateMachine.changeState(new AIOrbit(g, param1));
				}
				else
				{
					param1.stateMachine.changeState(new AIReturnOrbit(g, param1, param9, param5, param3, 0));
				}
			}
			else if (param1.teleport)
			{
				param1.stateMachine.changeState(new AITeleportEntry(g, param1, param3));
			}
			else
			{
				param1.stateMachine.changeState(new AIIdle(g, param1, param3));
			}
		}
		
		private function randomizeSpeed(param1:EnemyShip):void
		{
			var _loc2_:Random = new Random(1 / param1.id);
			_loc2_.stepTo(1);
			param1.engine.speed *= 0.8 + 0.001 * _loc2_.random(201);
			param1.engine.rotationSpeed *= 0.6 + 0.002 * _loc2_.random(201);
		}
		
		public function getShipFromId(param1:int):Ship
		{
			for each (var _loc2_:* in ships)
			{
				if (_loc2_.id == param1)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		public function enemyFire(param1:Message, param2:int = 0):void
		{
			var _loc8_:int = 0;
			var _loc5_:Weapon = null;
			var _loc3_:int = param1.getInt(param2);
			var _loc7_:int = param1.getInt(param2 + 1);
			var _loc9_:Boolean = param1.getBoolean(param2 + 2);
			var _loc4_:Ship = getShipFromId(_loc3_);
			var _loc6_:Unit = null;
			if (param1.length > 3)
			{
				_loc8_ = param1.getInt(param2 + 3);
				_loc6_ = g.unitManager.getTarget(_loc8_);
			}
			if (_loc4_ != null)
			{
				_loc5_ = _loc4_.weapons[_loc7_];
				_loc5_.fire = _loc9_;
				_loc5_.target = _loc6_;
			}
		}
		
		public function damaged(param1:Message, param2:int):void
		{
			var _loc5_:int = 0;
			var _loc4_:int = param1.getInt(param2 + 1);
			var _loc3_:EnemyShip = enemiesById[_loc4_];
			if (_loc3_ != null)
			{
				_loc5_ = param1.getInt(param2 + 2);
				_loc3_.takeDamage(_loc5_);
				_loc3_.shieldHp = param1.getInt(param2 + 3);
				if (_loc3_.shieldHp == 0)
				{
					if (_loc3_.shieldRegenCounter > -1000)
					{
						_loc3_.shieldRegenCounter = -1000;
					}
				}
				_loc3_.hp = param1.getInt(param2 + 4);
				if (param1.getBoolean(param2 + 5))
				{
					_loc3_.doDOTEffect(param1.getInt(param2 + 6), param1.getString(param2 + 7), param1.getInt(param2 + 8));
				}
			}
		}
		
		public function killed(param1:Message, param2:int):void
		{
			var _loc5_:int = param1.getInt(param2);
			var _loc4_:Boolean = param1.getBoolean(param2 + 1);
			var _loc3_:EnemyShip = enemiesById[_loc5_];
			if (_loc3_ != null)
			{
				_loc3_.destroy(_loc4_);
			}
		}
		
		private function syncEnemyTarget(param1:Message, param2:int):void
		{
			var _loc7_:* = 0;
			var _loc3_:EnemyShip = null;
			var _loc5_:String = null;
			var _loc4_:Unit = null;
			var _loc6_:int = 0;
			_loc7_ = param2;
			while (_loc7_ < param1.length - 1)
			{
				_loc3_ = g.shipManager.enemiesById[param1.getInt(_loc7_)];
				_loc5_ = param1.getString(_loc7_ + 1);
				_loc4_ = g.unitManager.getTarget(param1.getInt(_loc7_ + 2));
				if (_loc3_ != null)
				{
					if (!_loc3_.stateMachine.inState(_loc5_))
					{
						switch (_loc5_)
						{
						case "AIObserve": 
							_loc3_.stateMachine.changeState(new AIObserve(g, _loc3_, _loc4_, _loc3_.course, 0));
							break;
						case "AIChase": 
							_loc3_.stateMachine.changeState(new AIChase(g, _loc3_, _loc4_, _loc3_.course, 0));
							break;
						case "AIResurect": 
							_loc3_.stateMachine.changeState(new AIResurect(g, _loc3_));
							break;
						case "AIFollow": 
							_loc3_.stateMachine.changeState(new AIFollow(g, _loc3_, _loc4_, _loc3_.course, 0));
							break;
						case "AIMelee": 
							_loc3_.stateMachine.changeState(new AIMelee(g, _loc3_, _loc4_, _loc3_.course, 0));
							break;
						case "AIOrbit": 
							_loc3_.stateMachine.changeState(new AIOrbit(g, _loc3_));
							break;
						case "AIIdle": 
							_loc3_.stateMachine.changeState(new AIIdle(g, _loc3_, _loc3_.course));
							break;
						case "AIKamikaze": 
							_loc3_.stateMachine.changeState(new AIKamikaze(g, _loc3_, _loc4_, _loc3_.course, 0));
							break;
						case "AITeleport": 
							_loc3_.stateMachine.changeState(new AITeleport(g, _loc3_, _loc4_));
							break;
						case "AITeleportExit": 
							_loc3_.stateMachine.changeState(new AITeleportExit(g, _loc3_));
							break;
						case "AIExit": 
							_loc3_.stateMachine.changeState(new AIExit(g, _loc3_));
						}
					}
					_loc6_ = 0;
					while (_loc6_ < _loc3_.weapons.length)
					{
						_loc7_++;
						_loc3_.weapons[_loc6_].target = _loc4_;
						_loc3_.weapons[_loc6_].fire = param1.getBoolean(_loc7_ + 3);
						_loc6_++;
					}
				}
				_loc7_ += 4;
			}
		}
		
		public function initSyncEnemies(param1:Message):void
		{
			var _loc2_:* = 1;
			var _loc3_:int = _loc2_ + param1.getInt(0);
			g.turretManager.syncTurretTarget(param1, _loc2_, _loc3_);
			_loc2_ = _loc3_ + 1;
			_loc3_ = _loc2_ + param1.getInt(_loc3_);
			g.projectileManager.addInitProjectiles(param1, _loc2_, _loc3_);
			_loc2_ = _loc3_;
			syncEnemyTarget(param1, _loc2_);
		}
		
		public function initEnemies(param1:Message):void
		{
			Console.write("running spawnEnemy");
			spawnEnemy(param1, 0, 0);
		}
		
		private function onEnemyUpdate(param1:Message):void
		{
			var _loc4_:int = 0;
			var _loc5_:Boolean = false;
			var _loc6_:int = 0;
			var _loc2_:EnemyShip = g.shipManager.enemiesById[param1.getInt(_loc6_++)];
			if (_loc2_ == null)
			{
				return;
			}
			_loc2_.hp = param1.getInt(_loc6_++);
			_loc2_.shieldHp = param1.getInt(_loc6_++);
			if (_loc2_.hp < _loc2_.hpMax || _loc2_.shieldHp < _loc2_.shieldHpMax)
			{
				_loc2_.isInjured = true;
			}
			var _loc3_:Ship = g.shipManager.getShipFromId(param1.getInt(_loc6_++));
			_loc4_ = 0;
			while (_loc4_ < _loc2_.weapons.length)
			{
				_loc5_ = param1.getBoolean(_loc6_++);
				_loc2_.weapons[_loc4_].fire = _loc5_;
				_loc2_.weapons[_loc4_].target = _loc5_ ? _loc3_ : null;
				_loc4_++;
			}
		}
		
		public function dispose():void
		{
			var _loc1_:* = null;
			for each (_loc1_ in enemies)
			{
				_loc1_.removeFromCanvas();
				_loc1_.reset();
			}
			g.removeMessageHandler("spawnEnemy", onSpawnEnemy);
			enemies = null;
			inactiveEnemies = null;
			for each (_loc1_ in players)
			{
				_loc1_.removeFromCanvas();
				_loc1_.reset();
			}
			players = null;
			inactivePlayers = null;
		}
	}
}
