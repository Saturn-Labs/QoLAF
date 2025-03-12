package core.projectile
{
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
	
	public class ProjectileManager
	{
		public var inactiveProjectiles:Vector.<Projectile>;
		
		public var projectiles:Vector.<Projectile>;
		
		public var projectilesById:Dictionary;
		
		private var TARGET_TYPE_SHIP:String = "ship";
		private var TARGET_TYPE_SPAWNER:String = "spawner";
		private var g:Game;
		
		private var meshBatch:MeshBatch;
		
		public function ProjectileManager(param1:Game)
		{
			var _loc3_:int = 0;
			var _loc2_:Projectile = null;
			inactiveProjectiles = new Vector.<Projectile>();
			projectiles = new Vector.<Projectile>();
			projectilesById = new Dictionary();
			meshBatch = new MeshBatch();
			super();
			this.g = param1;
			_loc3_ = 0;
			while (_loc3_ < 100)
			{
				_loc2_ = new Projectile(param1);
				inactiveProjectiles.push(_loc2_);
				_loc3_++;
			}
		}
		
		public function addMessageHandlers():void
		{
			g.addMessageHandler("projectileAddEnemy", addEnemyProjectile);
			g.addMessageHandler("projectileAddPlayer", addPlayerProjectile);
			g.addMessageHandler("projectileCourse", updateCourse);
			g.addMessageHandler("killProjectile", killProjectile);
			g.addMessageHandler("killStuckProjectiles", killStuckProjectiles);
			g.canvasProjectiles.addChild(meshBatch);
		}
		
		public function update():void
		{
			var _loc3_:int = 0;
			var _loc1_:Projectile = null;
			meshBatch.clear();
			var _loc2_:int = int(projectiles.length);
			_loc3_ = _loc2_ - 1;
			while (_loc3_ > -1)
			{
				_loc1_ = projectiles[_loc3_];
				if (_loc1_.alive)
				{
					_loc1_.update();
					if (_loc1_.hasImage && _loc1_.isVisible)
					{
						meshBatch.addMesh(_loc1_.movieClip);
					}
				}
				else
				{
					remove(_loc1_, _loc3_);
				}
				_loc3_--;
			}
		}
		
		public function getProjectile():Projectile
		{
			var _loc1_:Projectile = null;
			if (inactiveProjectiles.length > 0)
			{
				_loc1_ = inactiveProjectiles.pop();
			}
			else
			{
				_loc1_ = new Projectile(g);
			}
			_loc1_.reset();
			return _loc1_;
		}
		
		public function handleBouncing(param1:Message, param2:int):void
		{
			var _loc3_:int = param1.getInt(param2);
			var _loc5_:int = param1.getInt(param2 + 1);
			var _loc4_:Projectile = projectilesById[_loc3_];
			if (_loc4_ == null)
			{
				return;
			}
			_loc4_.target = g.unitManager.getTarget(_loc5_);
		}
		
		public function activateProjectile(param1:Projectile):void
		{
			param1.x = param1.course.pos.x;
			param1.y = param1.course.pos.y;
			if (param1.randomAngle)
			{
				param1.rotation = Math.random() * 3.141592653589793 * 2;
			}
			else
			{
				param1.rotation = param1.course.rotation;
			}
			projectiles.push(param1);
			param1.addToCanvas();
			param1.tryAddRibbonTrail();
			if (projectilesById[param1.id] != null)
			{
				Console.write("error: p.id: " + param1.id);
			}
			if (param1.id != 0)
			{
				projectilesById[param1.id] = param1;
			}
		}
		
		public function addEnemyProjectile(param1:Message):void
		{
			var _loc7_:int = 0;
			var _loc8_:int = 0;
			var _loc2_:int = 0;
			var _loc5_:int = 0;
			var _loc9_:Heading = null;
			var _loc13_:int = 0;
			var _loc4_:int = 0;
			var _loc14_:int = 0;
			var _loc12_:Number = NaN;
			var _loc3_:EnemyShip = null;
			var _loc10_:Weapon = null;
			var _loc6_:Turret = null;
			var _loc11_:Dictionary = g.shipManager.enemiesById;
			_loc7_ = 0;
			while (_loc7_ < param1.length - 6)
			{
				_loc8_ = param1.getInt(_loc7_);
				_loc2_ = param1.getInt(_loc7_ + 1);
				_loc5_ = param1.getInt(_loc7_ + 2);
				_loc9_ = new Heading();
				_loc9_.parseMessage(param1, _loc7_ + 3);
				_loc13_ = param1.getInt(_loc7_ + 3 + 10);
				_loc4_ = param1.getInt(_loc7_ + 4 + 10);
				_loc14_ = param1.getInt(_loc7_ + 5 + 10);
				_loc12_ = param1.getNumber(_loc7_ + 6 + 10);
				_loc3_ = _loc11_[_loc2_];
				if (_loc3_ != null && _loc3_.weapons.length > _loc5_ && _loc3_.weapons[_loc5_] != null)
				{
					_loc10_ = _loc3_.weapons[_loc5_];
					createSetProjectile(ProjectileFactory.create(_loc10_.projectileFunction, g, _loc3_, _loc10_, _loc9_), _loc8_, _loc3_, _loc9_, _loc13_, _loc4_, _loc14_, _loc12_);
				}
				else
				{
					_loc6_ = g.turretManager.getTurretById(_loc2_);
					if (_loc6_ != null && _loc6_.weapon != null)
					{
						_loc10_ = _loc6_.weapon;
						createSetProjectile(ProjectileFactory.create(_loc10_.projectileFunction, g, _loc6_, _loc10_), _loc8_, _loc6_, _loc9_, _loc13_, _loc4_, _loc14_, _loc12_);
					}
				}
				_loc7_ += 7 + 10;
			}
		}
		
		public function addInitProjectiles(param1:Message, param2:int, param3:int):void
		{
			var _loc11_:* = 0;
			var _loc7_:int = 0;
			var _loc6_:int = 0;
			var _loc10_:int = 0;
			var _loc8_:Ship = null;
			var _loc5_:Heading = null;
			var _loc9_:int = 0;
			var _loc4_:Weapon = null;
			_loc11_ = param2;
			while (_loc11_ < param3 - 4)
			{
				_loc7_ = param1.getInt(_loc11_);
				_loc6_ = param1.getInt(_loc11_ + 1);
				_loc10_ = param1.getInt(_loc11_ + 2);
				_loc8_ = g.unitManager.getTarget(_loc6_) as Ship;
				_loc5_ = new Heading();
				_loc5_.pos.x = param1.getNumber(_loc11_ + 3);
				_loc5_.pos.y = param1.getNumber(_loc11_ + 4);
				_loc9_ = param1.getNumber(_loc11_ + 5);
				if (_loc8_ != null && _loc10_ > 0 && _loc10_ < _loc8_.weapons.length)
				{
					_loc4_ = _loc8_.weapons[_loc10_];
					createSetProjectile(ProjectileFactory.create(_loc4_.projectileFunction, g, _loc8_, _loc4_), _loc7_, _loc8_, _loc5_, _loc9_);
				}
				_loc11_ += 6;
			}
		}
		
		public function addPlayerProjectile(param1:Message):void
		{
			var _loc6_:int = 0;
			var _loc8_:int = 0;
			var _loc10_:String = null;
			var _loc4_:int = 0;
			var _loc5_:int = 0;
			var _loc14_:Heading = null;
			var _loc13_:int = 0;
			var _loc3_:int = 0;
			var _loc15_:int = 0;
			var _loc11_:Number = NaN;
			var _loc2_:Player = null;
			var _loc9_:PlayerShip = null;
			var _loc7_:ProjectileGun = null;
			var _loc12_:Unit = null;
			_loc6_ = 0;
			while (_loc6_ < param1.length - 8 - 10)
			{
				if (param1.length < 6 + 10)
				{
					return;
				}
				_loc8_ = param1.getInt(_loc6_);
				_loc10_ = param1.getString(_loc6_ + 1);
				_loc4_ = param1.getInt(_loc6_ + 2);
				_loc5_ = param1.getInt(_loc6_ + 3);
				_loc14_ = new Heading();
				_loc14_.parseMessage(param1, _loc6_ + 5);
				_loc13_ = param1.getInt(_loc6_ + 5 + 10);
				_loc3_ = param1.getInt(_loc6_ + 6 + 10);
				_loc15_ = param1.getInt(_loc6_ + 7 + 10);
				_loc11_ = param1.getNumber(_loc6_ + 8 + 10);
				_loc2_ = g.playerManager.playersById[_loc10_];
				if (_loc2_ == null)
				{
					return;
				}
				_loc9_ = _loc2_.ship;
				if (_loc9_ == null || _loc9_.weapons == null)
				{
					return;
				}
				if (!(_loc4_ > -1 && _loc4_ < _loc2_.ship.weapons.length))
				{
					return;
				}
				_loc2_.selectedWeaponIndex = _loc4_;
				if (_loc9_.weapon != null && _loc9_.weapon is ProjectileGun)
				{
					_loc7_ = _loc9_.weapon as ProjectileGun;
					_loc12_ = null;
					if (_loc5_ != -1)
					{
						_loc12_ = g.unitManager.getTarget(_loc5_);
					}
					_loc7_.shootSyncedProjectile(_loc8_, _loc12_, _loc14_, _loc13_, param1.getNumber(_loc6_ + 4), _loc3_, _loc15_, _loc11_);
				}
				_loc6_ += 9 + 10;
			}
		}
		
		private function createSetProjectile(param1:Projectile, param2:int, param3:Unit, param4:Heading, param5:int, param6:int = 0, param7:int = 0, param8:Number = 0):void
		{
			var _loc10_:Point = null;
			var _loc13_:Number = NaN;
			var _loc11_:Number = NaN;
			var _loc9_:Number = NaN;
			var _loc15_:Number = NaN;
			var _loc12_:Number = NaN;
			if (param1 == null)
			{
				return;
			}
			var _loc14_:Weapon = param1.weapon;
			param1.id = param2;
			if (param8 != 0)
			{
				param1.speedMax = param8;
			}
			if (param1.speedMax != 0)
			{
				_loc10_ = new Point();
				if (param5 > -1)
				{
					_loc13_ = _loc14_.multiNrOfP;
					_loc11_ = param3.weaponPos.y + _loc14_.multiOffset * (param5 - 0.5 * (_loc13_ - 1)) / _loc13_;
				}
				else
				{
					_loc11_ = param3.weaponPos.y;
				}
				_loc9_ = param3.weaponPos.x + _loc14_.positionOffsetX;
				_loc15_ = new Point(_loc9_, _loc11_).length;
				_loc12_ = Math.atan2(_loc11_, _loc9_);
				_loc10_.x = param3.pos.x + Math.cos(param3.rotation + _loc12_) * _loc15_ + param6;
				_loc10_.y = param3.pos.y + Math.sin(param3.rotation + _loc12_) * _loc15_ + param7;
				param1.unit = param3;
				param1.course = param4;
				param1.rotation = param4.rotation;
				param1.fastforward();
				param1.x = param4.pos.x;
				param1.y = param4.pos.y;
				param1.collisionRadius = 0.5 * param1.collisionRadius;
				param1.error = new Point(-param1.course.pos.x + _loc10_.x, -param1.course.pos.y + _loc10_.y);
				param1.convergenceCounter = 0;
				param1.course = param4;
				param1.convergenceTime = 151.51515151515153;
				if (param1.error.length > 1000)
				{
					param1.error.x = 0;
					param1.error.y = 0;
				}
				if (param8 != 0)
				{
					if (param1.stateMachine.inState("Instant"))
					{
						param1.range = param8;
						param1.speedMax = 10000;
					}
					else
					{
						param1.speedMax = param8;
					}
				}
			}
			else
			{
				param1.course = param4;
				param1.x = param4.pos.x;
				param1.y = param4.pos.y;
			}
			activateProjectile(param1);
			_loc14_.playFireSound();
		}
		
		private function updateCourse(param1:Message):void
		{
			var _loc9_:int = 0;
			var _loc2_:int = 0;
			var _loc7_:int = 0;
			var _loc5_:Projectile = null;
			var _loc6_:int = 0;
			var _loc3_:Number = NaN;
			var _loc8_:Heading = null;
			var _loc4_:Dictionary = g.shipManager.enemiesById;
			_loc9_ = 0;
			while (_loc9_ < param1.length)
			{
				_loc2_ = param1.getInt(_loc9_);
				_loc7_ = param1.getInt(_loc9_ + 1);
				_loc5_ = projectilesById[_loc2_];
				if (_loc5_ == null)
				{
					return;
				}
				_loc6_ = param1.getInt(_loc9_ + 2);
				if (_loc7_ == 0)
				{
					_loc5_.direction = _loc6_;
					if (_loc5_.direction > 0)
					{
						_loc5_.boomerangReturning = true;
						_loc5_.rotationSpeedMax = param1.getNumber(_loc9_ + 3);
					}
					if (_loc6_ == 3)
					{
						_loc5_.course.rotation = Util.clampRadians(_loc5_.course.rotation + 3.141592653589793);
					}
				}
				else if (_loc7_ == 1)
				{
					_loc5_.target = g.unitManager.getTarget(_loc6_);
					_loc5_.targetProjectile = null;
					_loc3_ = param1.getNumber(_loc9_ + 3);
					if (_loc3_ > 0)
					{
						_loc5_.aiStuck = true;
						_loc5_.aiStuckDuration = _loc3_;
					}
				}
				else if (_loc7_ == 2)
				{
					_loc5_.aiStuck = false;
					_loc5_.target = null;
					_loc5_.targetProjectile = projectilesById[_loc6_];
				}
				else if (_loc7_ == 3)
				{
					_loc5_.aiStuck = false;
					_loc5_.target = null;
					_loc5_.targetProjectile = null;
					_loc8_ = new Heading();
					_loc8_.parseMessage(param1, _loc9_ + 4);
					_loc5_.error = new Point(_loc5_.course.pos.x - _loc8_.pos.x, _loc5_.course.pos.y - _loc8_.pos.y);
					_loc5_.errorRot = Util.clampRadians(_loc5_.course.rotation - _loc8_.rotation);
					if (_loc5_.errorRot > 3.141592653589793)
					{
						_loc5_.errorRot -= 2 * 3.141592653589793;
					}
					_loc5_.convergenceCounter = 0;
					_loc5_.course = _loc8_;
					_loc5_.convergenceTime = 500 / 33;
				}
				else
				{
					_loc8_ = new Heading();
					_loc8_.parseMessage(param1, _loc9_ + 4);
					while (_loc8_.time < _loc5_.course.time)
					{
						_loc5_.updateHeading(_loc8_);
					}
					_loc5_.course = _loc8_;
				}
				_loc9_ += 4 + 10;
			}
		}
		
		private function killProjectile(param1:Message):void
		{
			var _loc4_:int = 0;
			var _loc2_:int = 0;
			var _loc3_:Projectile = null;
			_loc4_ = 0;
			while (_loc4_ < param1.length)
			{
				_loc2_ = param1.getInt(_loc4_);
				_loc3_ = projectilesById[_loc2_];
				if (_loc3_ != null)
				{
					_loc3_.destroy();
				}
				_loc4_++;
			}
		}
		
		private function killStuckProjectiles(param1:Message):void
		{
			var _loc2_:int = param1.getInt(0);
			var _loc3_:Unit = g.unitManager.getTarget(_loc2_);
			if (_loc3_ == null)
			{
				return;
			}
			for each (var _loc4_:* in projectiles)
			{
				if (_loc4_.stateMachine.inState(ProjectileStuck) && _loc4_.target == _loc3_)
				{
					_loc4_.destroy(true);
				}
			}
		}
		
		public function remove(param1:Projectile, param2:int):void
		{
			projectiles.splice(param2, 1);
			inactiveProjectiles.push(param1);
			if (param1.id != 0)
			{
				delete projectilesById[param1.id];
			}
			param1.removeFromCanvas();
			param1.reset();
		}
		
		public function forceUpdate():void
		{
			var _loc1_:Projectile = null;
			var _loc2_:int = 0;
			_loc2_ = 0;
			while (_loc2_ < projectiles.length)
			{
				_loc1_ = projectiles[_loc2_];
				_loc1_.nextDistanceCalculation = -1;
				_loc2_++;
			}
		}
		
		public function dispose():void
		{
			for each (var _loc1_:* in projectiles)
			{
				_loc1_.removeFromCanvas();
				_loc1_.reset();
			}
			projectiles = null;
			projectilesById = null;
			inactiveProjectiles = null;
		}
	}
}
