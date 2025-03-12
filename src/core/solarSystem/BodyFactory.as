package core.solarSystem
{
	import core.hud.components.pvp.DominationManager;
	import core.hud.components.pvp.PvpManager;
	import core.hud.components.starMap.SolarSystem;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import data.DataLocator;
	import data.IDataManager;
	import debug.Console;
	
	public class BodyFactory
	{
		public function BodyFactory()
		{
			super();
		}
		
		public static function createSolarSystem(param1:Game, param2:String):void
		{
			var _loc5_:IDataManager = DataLocator.getService();
			var _loc3_:Object = _loc5_.loadKey("SolarSystems", param2);
			param1.solarSystem = new SolarSystem(param1, _loc3_, param2);
			param1.hud.uberStats.uberLevel = param1.hud.uberStats.CalculateUberLevelFromRank(param1.hud.uberStats.uberRank);
			param1.parallaxManager.load(_loc3_, null);
			var _loc4_:Object = _loc5_.loadRange("Bodies", "solarSystem", param2);
			createBodies(param1, _loc4_);
			if (param1.solarSystem.type == "pvp arena" || param1.solarSystem.type == "pvp dm" || param1.solarSystem.type == "pvp dom")
			{
				addUpgradeStation(param1);
				if (param1.solarSystem.type == "pvp dom")
				{
					param1.pvpManager = new DominationManager(param1);
				}
				else
				{
					param1.pvpManager = new PvpManager(param1);
				}
				if (_loc3_.hasOwnProperty("items"))
				{
					param1.pvpManager.addZones(_loc3_.items);
				}
			}
		}
		
		private static function addUpgradeStation(param1:Game):void
		{
			var _loc3_:Body = param1.bodyManager.getRoot();
			_loc3_.course.pos.x = -1834;
			_loc3_.course.pos.y = -15391;
			_loc3_.key = "Research Station";
			_loc3_.name = "PvP Warm Up Area";
			_loc3_.boss = "";
			_loc3_.canTriggerMission = false;
			_loc3_.mission = "";
			var _loc2_:Object = {};
			_loc2_.bitmap = "sf86oalQ9ES4qnb4O9w6Yw";
			_loc2_.name = "Research Station";
			_loc2_.type = "research";
			_loc2_.safeZoneRadius = 200;
			_loc2_.hostileZoneRadius = 0;
			_loc3_.switchTexturesByObj(_loc2_, "texture_body.png");
			_loc3_.obj = _loc2_;
			_loc3_.labelOffset = 0;
			_loc3_.safeZoneRadius = 200;
			_loc3_.level = 1;
			_loc3_.collisionRadius = 80;
			_loc3_.type = "research";
			_loc3_.inhabitants = "none";
			_loc3_.population = 0;
			_loc3_.size = "average";
			_loc3_.defence = "none";
			_loc3_.time = 0;
			_loc3_.explorable = false;
			_loc3_.landable = true;
			_loc3_.elite = false;
			_loc3_.hostileZoneRadius = 0;
			_loc3_.preDraw(_loc2_);
		}
		
		private static function createBodies(param1:Game, param2:Object):void
		{
			var _loc8_:int = 0;
			var _loc4_:Object = null;
			var _loc6_:Body = null;
			if (param2 == null)
			{
				return;
			}
			var _loc7_:int = 0;
			for (var _loc9_:* in param2)
			{
				_loc8_++;
			}
			for (var _loc10_:* in param2)
			{
				_loc4_ = param2[_loc10_];
				if (_loc4_.parent == "")
				{
					_loc6_ = param1.bodyManager.getRoot();
					_loc6_.course.pos.x = _loc4_.x;
					_loc6_.course.pos.y = _loc4_.y;
				}
				else
				{
					_loc6_ = param1.bodyManager.getBody();
					_loc6_.course.orbitAngle = _loc4_.orbitAngle;
					_loc6_.course.orbitRadius = _loc4_.orbitRadius;
					_loc6_.course.orbitSpeed = _loc4_.orbitSpeed;
					if (_loc6_.course.orbitRadius != 0)
					{
						_loc6_.course.orbitSpeed /= _loc6_.course.orbitRadius * 60;
					}
					_loc6_.course.rotationSpeed = _loc4_.rotationSpeed / 80;
				}
				_loc6_.switchTexturesByObj(_loc4_, "texture_body.png");
				_loc6_.obj = _loc4_;
				_loc6_.key = _loc10_;
				_loc6_.name = _loc4_.name;
				if (_loc4_.hasOwnProperty("warningRadius"))
				{
					_loc6_.warningRadius = _loc4_.warningRadius;
				}
				if (_loc4_.hasOwnProperty("labelOffset"))
				{
					_loc6_.labelOffset = _loc4_.labelOffset;
				}
				else
				{
					_loc6_.labelOffset = 0;
				}
				if (_loc4_.hasOwnProperty("seed"))
				{
					_loc6_.seed = _loc4_.seed;
				}
				else
				{
					_loc6_.seed = Math.random();
				}
				if (_loc4_.hasOwnProperty("extraAreas"))
				{
					_loc6_.extraAreas = _loc4_.extraAreas;
				}
				else
				{
					_loc6_.extraAreas = 0;
				}
				if (_loc4_.hasOwnProperty("waypoints"))
				{
					_loc6_.wpArray = _loc4_.waypoints;
				}
				_loc6_.level = _loc4_.level;
				_loc6_.landable = _loc4_.landable;
				_loc6_.explorable = _loc4_.explorable;
				_loc6_.description = _loc4_.description;
				_loc6_.collisionRadius = _loc4_.collisionRadius;
				_loc6_.type = _loc4_.type;
				_loc6_.inhabitants = _loc4_.inhabitants;
				_loc6_.population = _loc4_.population;
				_loc6_.size = _loc4_.size;
				_loc6_.defence = _loc4_.defence;
				_loc6_.time = _loc4_.time * 60 * 1000;
				_loc6_.safeZoneRadius = param1.isSystemTypeSurvival() ? 0 : _loc4_.safeZoneRadius;
				if (_loc4_.controlZoneTimeFactor == null)
				{
					_loc6_.controlZoneTimeFactor = 0.2;
					_loc6_.controlZoneCompleteRewardFactor = 0.2;
					_loc6_.controlZoneGrabRewardFactor = 0.2;
				}
				else
				{
					_loc6_.controlZoneTimeFactor = _loc4_.controlZoneTimeFactor;
					_loc6_.controlZoneCompleteRewardFactor = _loc4_.controlZoneCompleteRewardFactor;
					_loc6_.controlZoneGrabRewardFactor = _loc4_.controlZoneGrabRewardFactor;
				}
				_loc6_.canTriggerMission = _loc4_.canTriggerMission;
				_loc6_.mission = _loc4_.mission;
				if (_loc6_.canTriggerMission)
				{
					if (param1.dataManager.loadKey("MissionTypes", _loc6_.mission).majorType == "time")
					{
						_loc6_.missionHint.format.color = 16746564;
					}
					else
					{
						_loc6_.missionHint.format.color = 8978312;
					}
					_loc6_.missionHint.format.font = "DAIDRR";
					_loc6_.missionHint.text = "?";
					_loc6_.missionHint.format.size = 100;
					_loc6_.missionHint.pivotX = _loc6_.missionHint.width / 2;
					_loc6_.missionHint.pivotY = _loc6_.missionHint.height / 2;
				}
				if (_loc4_.hasOwnProperty("elite"))
				{
					_loc6_.elite = _loc4_.elite;
				}
				if (_loc4_.effect != null)
				{
					EmitterFactory.create(_loc4_.effect, param1, _loc6_.pos.x, _loc6_.pos.y, _loc6_, true);
				}
				if (_loc6_.type == "sun")
				{
					_loc6_.gravityDistance = _loc4_.gravityDistance == null ? 640000 : _loc4_.gravityDistance * _loc4_.gravityDistance;
					_loc6_.gravityForce = _loc4_.gravityForce == null ? _loc6_.collisionRadius * 5000 : _loc6_.collisionRadius * _loc4_.gravityForce;
					_loc6_.gravityMin = _loc4_.gravityMin == null ? 900 : _loc4_.gravityMin * _loc4_.gravityMin;
				}
				_loc6_.addSpawners(_loc4_, _loc10_);
			}
			for each (var _loc3_:* in param1.bodyManager.bodies)
			{
				for each (var _loc5_:* in param1.bodyManager.bodies)
				{
					if (_loc5_.obj.parent == _loc3_.key)
					{
						_loc3_.addChild(_loc5_);
					}
				}
			}
			Console.write("complete init solar stuff");
		}
	}
}
