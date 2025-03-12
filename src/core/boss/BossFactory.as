package core.boss
{
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.solarSystem.Body;
	import core.spawner.*;
	import core.states.AIStates.AIBoss;
	import core.states.AIStates.AITurret;
	import core.turret.*;
	import core.unit.Unit;
	import data.*;
	import flash.geom.Point;
	import generics.Util;
	
	public class BossFactory
	{
		public function BossFactory()
		{
			super();
		}
		
		public static function createBoss(param1:String, param2:Body, param3:Array, param4:String, param5:Game):Boss
		{
			var _loc9_:Number = NaN;
			var _loc10_:IDataManager = DataLocator.getService();
			var _loc7_:Object = _loc10_.loadKey("Bosses", param1);
			var _loc6_:Boss = new Boss(param5);
			_loc6_.name = _loc7_.name;
			_loc6_.parentBody = param2;
			_loc6_.key = param1;
			_loc6_.alive = true;
			_loc6_.isHostile = true;
			_loc6_.awaitingActivation = true;
			_loc6_.xp = _loc7_.xp;
			_loc6_.level = _loc7_.level;
			_loc6_.layer = _loc7_.layer;
			_loc6_.hp = 0;
			_loc6_.hpMax = 1;
			_loc6_.resetTime = _loc7_.resetTime;
			_loc6_.respawnTime = _loc7_.respawnTime;
			_loc6_.speed = _loc7_.speed;
			_loc6_.rotationSpeed = _loc7_.rotationSpeed;
			_loc6_.rotationForced = _loc7_.rotationForced;
			_loc6_.acceleration = _loc7_.acceleration;
			_loc6_.holonomic = _loc7_.holonomic;
			if (_loc7_.hasOwnProperty("AIFaction1") && _loc7_.AIFaction1 != "")
			{
				_loc6_.factions.push(_loc7_.AIFaction1);
			}
			if (_loc7_.hasOwnProperty("AIFaction2") && _loc7_.AIFaction2 != "")
			{
				_loc6_.factions.push(_loc7_.AIFaction2);
			}
			if (_loc7_.hasOwnProperty("regen"))
			{
				_loc6_.hpRegen = _loc7_.regen;
			}
			else
			{
				_loc6_.hpRegen = 0;
			}
			_loc6_.targetRange = _loc7_.targetRange;
			_loc6_.orbitOrign = new Point();
			_loc6_.bossRadius = _loc7_.radius;
			for each (var _loc8_:* in param3)
			{
				_loc6_.waypoints.push(new Waypoint(param5, _loc8_.body, _loc8_.xpos, _loc8_.ypos, _loc8_.id));
			}
			_loc6_.waypoints.push(new Waypoint(param5, param4, 0, 0, 1));
			if (_loc7_.hasOwnProperty("explosionSound"))
			{
				_loc6_.explosionSound = _loc7_.explosionSound;
			}
			else
			{
				_loc6_.explosionSound = "";
			}
			if (_loc7_.hasOwnProperty("explosionEffect"))
			{
				_loc6_.explosionEffect = _loc7_.explosionEffect;
			}
			else
			{
				_loc6_.explosionEffect = "";
			}
			_loc6_.switchTexturesByObj(_loc7_);
			if (param5.isSystemTypeSurvival())
			{
				if (_loc6_.name == "Tefat")
				{
					_loc6_.level = 6;
				}
				else
				{
					if (_loc6_.name == "Mandrom")
					{
						_loc6_.level = 12;
					}
					if (_loc6_.name == "Rotator")
					{
						_loc6_.level = 15;
					}
					if (_loc6_.name == "Dominator")
					{
						_loc6_.level = 7;
					}
					if (_loc6_.name == "Chelonidron")
					{
						_loc6_.level = 94;
					}
					if (_loc6_.name == "Motherbrain")
					{
						_loc6_.level = 54;
					}
					if (param5.hud.uberStats.uberRank == 1)
					{
						_loc6_.level = 7;
					}
				}
			}
			addTurrets(_loc7_, param5, _loc6_);
			addSpawners(_loc7_, param5, _loc6_);
			addBossComponents(_loc7_, param5, _loc6_);
			if (param5.isSystemTypeSurvival() && _loc6_.level < param5.hud.uberStats.uberLevel)
			{
				_loc9_ = param5.hud.uberStats.CalculateUberRankFromLevel(_loc6_.level);
				_loc6_.uberDifficulty = param5.hud.uberStats.CalculateUberDifficultyFromRank(param5.hud.uberStats.uberRank - _loc9_, _loc6_.level);
				_loc6_.uberLevelFactor = 1 + (param5.hud.uberStats.uberLevel - _loc6_.level) / 100;
				_loc6_.xp *= _loc6_.uberLevelFactor;
				_loc6_.level = param5.hud.uberStats.uberLevel;
				_loc6_.speed *= _loc6_.uberLevelFactor;
				if (_loc6_.speed > 380)
				{
					_loc6_.speed = 380;
				}
			}
			else if (_loc6_.name == "Chelonidron")
			{
				_loc6_.level = 54;
			}
			_loc6_.addFactions();
			sortComponents(param5, _loc6_);
			_loc6_.calcHpMax();
			_loc6_.stateMachine.changeState(new AIBoss(param5, _loc6_));
			return _loc6_;
		}
		
		private static function addTurrets(param1:Object, param2:Game, param3:Boss):void
		{
			var _loc4_:Array = param1.turrets;
			for each (var _loc5_:* in _loc4_)
			{
				createTurret(_loc5_, param3, param2);
			}
		}
		
		private static function createTurret(param1:Object, param2:Boss, param3:Game):void
		{
			var _loc4_:Turret = TurretFactory.createTurret(param1, param1.turret, param3, param2);
			_loc4_.offset = new Point(param1.xpos, param1.ypos);
			_loc4_.startAngle = Util.degreesToRadians(param1.angle);
			_loc4_.syncId = param1.id;
			_loc4_.parentObj = param2;
			_loc4_.alive = true;
			_loc4_.name = param1.name;
			_loc4_.rotation = _loc4_.startAngle;
			_loc4_.hideIfInactive = param1.hideIfInactive;
			_loc4_.essential = param1.essential;
			_loc4_.active = param1.active;
			_loc4_.invulnerable = param1.invulnerable;
			_loc4_.triggersToActivte = param1.triggersToActivte;
			_loc4_.triggers = getTriggers(param1, param3);
			_loc4_.layer = param1.layer;
			param2.turrets.push(_loc4_);
			param2.allComponents.push(_loc4_);
			_loc4_.stateMachine.changeState(new AITurret(param3, _loc4_));
		}
		
		private static function addSpawners(param1:Object, param2:Game, param3:Boss):void
		{
			var _loc5_:Object = null;
			var _loc7_:IDataManager = DataLocator.getService();
			var _loc4_:Array = param1.spawners;
			if (_loc4_.length == 0)
			{
				return;
			}
			for (var _loc6_:* in _loc4_)
			{
				_loc5_ = _loc4_[_loc6_];
				createSpawner(_loc5_, _loc6_.toString(), param3, param2);
			}
		}
		
		private static function createSpawner(param1:Object, param2:String, param3:Boss, param4:Game):void
		{
			var _loc6_:Object = DataLocator.getService().loadKey("Spawners", param1.spawner);
			var _loc5_:Spawner = SpawnFactory.createSpawner(_loc6_, "bossSpawner_" + param3.key + "_" + param2, param4, param3);
			_loc5_.parentObj = param3;
			_loc5_.offset = new Point(param1.xpos, param1.ypos);
			_loc5_.imageOffset = new Point(param1.imageOffsetX, param1.imageOffsetY);
			_loc5_.syncId = param1.id;
			_loc5_.alive = true;
			_loc5_.rotation = param1.angle / 180 * 3.141592653589793;
			_loc5_.angleOffset = _loc5_.parentObj.rotation - _loc5_.rotation;
			_loc5_.name = param1.name;
			_loc5_.hideIfInactive = param1.hideIfInactive;
			_loc5_.essential = param1.essential;
			_loc5_.active = param1.active;
			_loc5_.invulnerable = param1.invulnerable;
			_loc5_.triggersToActivte = param1.triggersToActivte;
			_loc5_.triggers = getTriggers(param1, param4);
			_loc5_.orbitRadius = 0;
			_loc5_.orbitAngle = 0;
			_loc5_.offset = new Point(param1.xpos, param1.ypos);
			_loc5_.imageOffset = new Point(param1.imageOffsetX, param1.imageOffsetY);
			_loc5_.layer = param1.layer;
			param3.spawners.push(_loc5_);
			param3.allComponents.push(_loc5_);
		}
		
		private static function addBossComponents(param1:Object, param2:Game, param3:Boss):void
		{
			var _loc4_:Array = param1.basicObjs;
			for each (var _loc5_:* in _loc4_)
			{
				createBossComponent(_loc5_, param3, param2);
			}
		}
		
		private static function createBossComponent(param1:Object, param2:Boss, param3:Game):void
		{
			var _loc5_:Number = NaN;
			var _loc4_:BossComponent = new BossComponent(param3);
			_loc4_.switchTexturesByObj(param1);
			_loc4_.parentObj = param2;
			_loc4_.offset = new Point(param1.xpos, param1.ypos);
			_loc4_.imageOffset = new Point(param1.imageOffsetX, param1.imageOffsetY);
			_loc4_.syncId = param1.id;
			_loc4_.parentObj = param2;
			_loc4_.hp = param1.hp;
			_loc4_.hpMax = param1.hp;
			_loc4_.shieldHp = 0;
			_loc4_.shieldHpMax = 0;
			_loc4_.xp = param1.xp;
			_loc4_.level = param1.level;
			_loc4_.essential = param1.essential;
			if (param3.isSystemTypeSurvival() && param2 != null)
			{
				_loc4_.level = param2.level;
			}
			if (param3.isSystemTypeSurvival() && _loc4_.level < param3.hud.uberStats.uberLevel && _loc4_.essential)
			{
				_loc5_ = param3.hud.uberStats.CalculateUberRankFromLevel(_loc4_.level);
				_loc4_.uberDifficulty = param3.hud.uberStats.CalculateUberDifficultyFromRank(param3.hud.uberStats.uberRank - _loc5_, _loc4_.level);
				_loc4_.uberLevelFactor = 1 + (param3.hud.uberStats.uberLevel - _loc4_.level) / 100;
				if (param2 != null)
				{
					_loc4_.uberDifficulty *= param3.hud.uberStats.uberRank / 2 + 1;
				}
				_loc4_.xp *= _loc4_.uberLevelFactor;
				_loc4_.level = param3.hud.uberStats.uberLevel;
				_loc4_.hp = _loc4_.hpMax = _loc4_.hpMax * _loc4_.uberDifficulty;
				_loc4_.shieldHp = _loc4_.shieldHpMax = _loc4_.shieldHpMax * _loc4_.uberDifficulty;
			}
			_loc4_.alive = true;
			_loc4_.imageAngle = Util.degreesToRadians(param1.angle);
			_loc4_.name = param1.name;
			_loc4_.imageScale = param1.scale;
			_loc4_.imageRotationSpeed = param1.rotationSpeed;
			_loc4_.imageRotationMax = param1.maxAngle;
			_loc4_.imageRotationMin = param1.minAngle;
			_loc4_.imagePivotPoint = new Point(param1.pivotPointX, param1.pivotPointY);
			_loc4_.hideIfInactive = param1.hideIfInactive;
			_loc4_.active = param1.active;
			_loc4_.invulnerable = param1.invulnerable;
			_loc4_.triggersToActivte = param1.triggersToActivte;
			_loc4_.triggers = getTriggers(param1, param3);
			_loc4_.isHostile = true;
			_loc4_.collisionRadius = param1.collisionRadius;
			_loc4_.layer = param1.layer;
			param2.allComponents.push(_loc4_);
			param2.bossComponents.push(_loc4_);
			if (param1.hasOwnProperty("explosionEffect"))
			{
				_loc4_.explosionEffect = param1.explosionEffect;
			}
			if (param1.hasOwnProperty("effect"))
			{
				_loc4_.effectX = param1.effectX;
				_loc4_.effectY = param1.effectY;
				_loc4_.effect = EmitterFactory.create(param1.effect, param3, 0, 0, _loc4_.effectTarget, true);
			}
		}
		
		private static function getTriggers(param1:Object, param2:Game):Vector.<Trigger>
		{
			var _loc7_:int = 0;
			var _loc3_:Object = null;
			var _loc4_:Trigger = null;
			var _loc6_:Vector.<Trigger> = new Vector.<Trigger>();
			var _loc5_:Array = param1.triggers;
			if (_loc5_ == null)
			{
				return _loc6_;
			}
			_loc7_ = 0;
			while (_loc7_ < _loc5_.length)
			{
				_loc3_ = _loc5_[_loc7_];
				_loc4_ = new Trigger(param2);
				_loc4_.id = _loc3_.id;
				_loc4_.target = _loc3_.target;
				_loc4_.delay = _loc3_.delay;
				_loc4_.activate = _loc3_.activte;
				_loc4_.inactivate = _loc3_.inactivte;
				_loc4_.vulnerable = _loc3_.vulnerable;
				_loc4_.invulnerable = _loc3_.invulnerable;
				_loc4_.kill = _loc3_.kill;
				_loc4_.threshhold = Number(_loc3_.threshhold) / 100;
				_loc4_.inactivateSelf = _loc3_.inactivateSelf;
				if (_loc3_.hasOwnProperty("sound"))
				{
					_loc4_.soundName = _loc3_.sound;
				}
				else
				{
					_loc4_.soundName = "";
				}
				if (_loc3_.hasOwnProperty("explosionEffect"))
				{
					_loc4_.explosionEffect = _loc3_.explosionEffect;
					_loc4_.xpos = _loc3_.xpos;
					_loc4_.ypos = _loc3_.ypos;
				}
				else
				{
					_loc4_.explosionEffect = "";
					_loc4_.xpos = 0;
					_loc4_.ypos = 0;
				}
				_loc4_.editBase = _loc3_.editBase;
				_loc4_.speed = _loc3_.speed;
				_loc4_.acceleration = _loc3_.acceleration;
				_loc4_.rotationForced = _loc3_.rotationForced;
				_loc4_.rotationSpeed = _loc3_.rotationSpeed;
				_loc4_.targetRange = _loc3_.targetRange;
				_loc6_.push(_loc4_);
				_loc7_++;
			}
			return _loc6_;
		}
		
		private static function sortComponents(param1:Game, param2:Boss):void
		{
			param2.allComponents.sort(compareFunction);
			for each (var _loc3_:* in param2.allComponents)
			{
				_loc3_.isBossUnit = true;
				_loc3_.distanceToCamera = 0;
				param1.unitManager.add(_loc3_, param1.canvasBosses, false);
			}
		}
		
		private static function compareFunction(param1:Unit, param2:Unit):int
		{
			if (param1.layer < param2.layer)
			{
				return -1;
			}
			if (param1.layer > param2.layer)
			{
				return 1;
			}
			return 0;
		}
	}
}