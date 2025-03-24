package core.solarSystem {
	import core.hud.components.pvp.DominationManager;
	import core.hud.components.pvp.PvpManager;
	import core.hud.components.starMap.SolarSystem;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import data.DataLocator;
	import data.IDataManager;
	import debug.Console;
	
	public class BodyFactory {
		public function BodyFactory() {
			super();
		}
		
		public static function createSolarSystem(g:Game, key:String) : void {
			var _local5:IDataManager = DataLocator.getService();
			var _local3:Object = _local5.loadKey("SolarSystems",key);
			g.solarSystem = new SolarSystem(g,_local3,key);
			g.hud.uberStats.uberLevel = g.hud.uberStats.CalculateUberLevelFromRank(g.hud.uberStats.uberRank);
			g.parallaxManager.load(_local3,null);
			var _local4:Object = _local5.loadRange("Bodies","solarSystem",key);
			createBodies(g,_local4);
			if(g.solarSystem.type == "pvp arena" || g.solarSystem.type == "pvp dm" || g.solarSystem.type == "pvp dom") {
				addUpgradeStation(g);
				if(g.solarSystem.type == "pvp dom") {
					g.pvpManager = new DominationManager(g);
				} else {
					g.pvpManager = new PvpManager(g);
				}
				if(_local3.hasOwnProperty("items")) {
					g.pvpManager.addZones(_local3.items);
				}
			}
		}
		
		private static function addUpgradeStation(g:Game) : void {
			var _local3:Body = g.bodyManager.getRoot();
			_local3.course.pos.x = -1834;
			_local3.course.pos.y = -15391;
			_local3.key = "Research Station";
			_local3.name = "PvP Warm Up Area";
			_local3.boss = "";
			_local3.canTriggerMission = false;
			_local3.mission = "";
			var _local2:Object = {};
			_local2.bitmap = "sf86oalQ9ES4qnb4O9w6Yw";
			_local2.name = "Research Station";
			_local2.type = "research";
			_local2.safeZoneRadius = 200;
			_local2.hostileZoneRadius = 0;
			_local3.switchTexturesByObj(_local2,"texture_body.png");
			_local3.obj = _local2;
			_local3.labelOffset = 0;
			_local3.safeZoneRadius = 200;
			_local3.level = 1;
			_local3.collisionRadius = 80;
			_local3.type = "research";
			_local3.inhabitants = "none";
			_local3.population = 0;
			_local3.size = "average";
			_local3.defence = "none";
			_local3.time = 0;
			_local3.explorable = false;
			_local3.landable = true;
			_local3.elite = false;
			_local3.hostileZoneRadius = 0;
			_local3.preDraw(_local2);
		}
		
		private static function createBodies(g:Game, bodies:Object) : void {
			var _local5:int = 0;
			var _local3:Object = null;
			var _local10:Body = null;
			if(bodies == null) {
				return;
			}
			var _local6:int = 0;
			for(var _local4 in bodies) {
				_local5++;
			}
			for(var _local7 in bodies) {
				_local3 = bodies[_local7];
				if(_local3.parent == "") {
					_local10 = g.bodyManager.getRoot();
					_local10.course.pos.x = _local3.x;
					_local10.course.pos.y = _local3.y;
				} else {
					_local10 = g.bodyManager.getBody();
					_local10.course.orbitAngle = _local3.orbitAngle;
					_local10.course.orbitRadius = _local3.orbitRadius;
					_local10.course.orbitSpeed = _local3.orbitSpeed;
					if(_local10.course.orbitRadius != 0) {
						_local10.course.orbitSpeed /= _local10.course.orbitRadius * (60);
					}
					_local10.course.rotationSpeed = _local3.rotationSpeed / 80;
				}
				_local10.switchTexturesByObj(_local3,"texture_body.png");
				_local10.obj = _local3;
				_local10.key = _local7;
				_local10.name = _local3.name;
				if(_local3.hasOwnProperty("warningRadius")) {
					_local10.warningRadius = _local3.warningRadius;
				}
				if(_local3.hasOwnProperty("labelOffset")) {
					_local10.labelOffset = _local3.labelOffset;
				} else {
					_local10.labelOffset = 0;
				}
				if(_local3.hasOwnProperty("seed")) {
					_local10.seed = _local3.seed;
				} else {
					_local10.seed = Math.random();
				}
				if(_local3.hasOwnProperty("extraAreas")) {
					_local10.extraAreas = _local3.extraAreas;
				} else {
					_local10.extraAreas = 0;
				}
				if(_local3.hasOwnProperty("waypoints")) {
					_local10.wpArray = _local3.waypoints;
				}
				_local10.level = _local3.level;
				_local10.landable = _local3.landable;
				_local10.explorable = _local3.explorable;
				_local10.description = _local3.description;
				_local10.collisionRadius = _local3.collisionRadius;
				_local10.type = _local3.type;
				_local10.inhabitants = _local3.inhabitants;
				_local10.population = _local3.population;
				_local10.size = _local3.size;
				_local10.defence = _local3.defence;
				_local10.time = _local3.time * (60) * 1000;
				_local10.safeZoneRadius = g.isSystemTypeSurvival() ? 0 : _local3.safeZoneRadius;
				if(_local3.controlZoneTimeFactor == null) {
					_local10.controlZoneTimeFactor = 0.2;
					_local10.controlZoneCompleteRewardFactor = 0.2;
					_local10.controlZoneGrabRewardFactor = 0.2;
				} else {
					_local10.controlZoneTimeFactor = _local3.controlZoneTimeFactor;
					_local10.controlZoneCompleteRewardFactor = _local3.controlZoneCompleteRewardFactor;
					_local10.controlZoneGrabRewardFactor = _local3.controlZoneGrabRewardFactor;
				}
				_local10.canTriggerMission = _local3.canTriggerMission;
				_local10.mission = _local3.mission;
				if(_local10.canTriggerMission) {
					if(g.dataManager.loadKey("MissionTypes",_local10.mission).majorType == "time") {
						_local10.missionHint.format.color = 0xff8844;
					} else {
						_local10.missionHint.format.color = 0x88ff88;
					}
					_local10.missionHint.format.font = "DAIDRR";
					_local10.missionHint.text = "?";
					_local10.missionHint.format.size = 100;
					_local10.missionHint.pivotX = _local10.missionHint.width / 2;
					_local10.missionHint.pivotY = _local10.missionHint.height / 2;
				}
				if(_local3.hasOwnProperty("elite")) {
					_local10.elite = _local3.elite;
				}
				if(_local3.effect != null) {
					EmitterFactory.create(_local3.effect,g,_local10.pos.x,_local10.pos.y,_local10,true);
				}
				if(_local10.type == "sun") {
					_local10.gravityDistance = _local3.gravityDistance == null ? 640000 : _local3.gravityDistance * _local3.gravityDistance;
					_local10.gravityForce = _local3.gravityForce == null ? _local10.collisionRadius * 5000 : _local10.collisionRadius * _local3.gravityForce;
					_local10.gravityMin = _local3.gravityMin == null ? 15 * 60 : _local3.gravityMin * _local3.gravityMin;
				}
				_local10.addSpawners(_local3,_local7);
			}
			for each(var _local8 in g.bodyManager.bodies) {
				for each(var _local9 in g.bodyManager.bodies) {
					if(_local9.obj.parent == _local8.key) {
						_local8.addChild(_local9);
					}
				}
			}
			Console.write("complete init solar stuff");
		}
	}
}

