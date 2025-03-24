package core.boss {
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
	
	public class BossFactory {
		public function BossFactory() {
			super();
		}
		
		public static function createBoss(key:String, body:Body, wpArray:Array, parentKey:String, g:Game) : Boss {
			var _local7:Number = NaN;
			var _local9:IDataManager = DataLocator.getService();
			var _local8:Object = _local9.loadKey("Bosses",key);
			var _local6:Boss = new Boss(g);
			_local6.name = _local8.name;
			_local6.parentBody = body;
			_local6.key = key;
			_local6.alive = true;
			_local6.isHostile = true;
			_local6.awaitingActivation = true;
			_local6.xp = _local8.xp;
			_local6.level = _local8.level;
			_local6.layer = _local8.layer;
			_local6.hp = 0;
			_local6.hpMax = 1;
			_local6.resetTime = _local8.resetTime;
			_local6.respawnTime = _local8.respawnTime;
			_local6.speed = _local8.speed;
			_local6.rotationSpeed = _local8.rotationSpeed;
			_local6.rotationForced = _local8.rotationForced;
			_local6.acceleration = _local8.acceleration;
			_local6.holonomic = _local8.holonomic;
			if(_local8.hasOwnProperty("AIFaction1") && _local8.AIFaction1 != "") {
				_local6.factions.push(_local8.AIFaction1);
			}
			if(_local8.hasOwnProperty("AIFaction2") && _local8.AIFaction2 != "") {
				_local6.factions.push(_local8.AIFaction2);
			}
			if(_local8.hasOwnProperty("regen")) {
				_local6.hpRegen = _local8.regen;
			} else {
				_local6.hpRegen = 0;
			}
			_local6.targetRange = _local8.targetRange;
			_local6.orbitOrign = new Point();
			_local6.bossRadius = _local8.radius;
			for each(var _local10 in wpArray) {
				_local6.waypoints.push(new Waypoint(g,_local10.body,_local10.xpos,_local10.ypos,_local10.id));
			}
			_local6.waypoints.push(new Waypoint(g,parentKey,0,0,1));
			if(_local8.hasOwnProperty("explosionSound")) {
				_local6.explosionSound = _local8.explosionSound;
			} else {
				_local6.explosionSound = "";
			}
			if(_local8.hasOwnProperty("explosionEffect")) {
				_local6.explosionEffect = _local8.explosionEffect;
			} else {
				_local6.explosionEffect = "";
			}
			_local6.switchTexturesByObj(_local8);
			if(g.isSystemTypeSurvival()) {
				if(_local6.name == "Tefat") {
					_local6.level = 6;
				} else {
					if(_local6.name == "Mandrom") {
						_local6.level = 12;
					}
					if(_local6.name == "Rotator") {
						_local6.level = 15;
					}
					if(_local6.name == "Dominator") {
						_local6.level = 7;
					}
					if(_local6.name == "Chelonidron") {
						_local6.level = 94;
					}
					if(_local6.name == "Motherbrain") {
						_local6.level = 54;
					}
					if(g.hud.uberStats.uberRank == 1) {
						_local6.level = 7;
					}
				}
			}
			addTurrets(_local8,g,_local6);
			addSpawners(_local8,g,_local6);
			addBossComponents(_local8,g,_local6);
			if(g.isSystemTypeSurvival() && _local6.level < g.hud.uberStats.uberLevel) {
				_local7 = g.hud.uberStats.CalculateUberRankFromLevel(_local6.level);
				_local6.uberDifficulty = g.hud.uberStats.CalculateUberDifficultyFromRank(g.hud.uberStats.uberRank - _local7,_local6.level);
				_local6.uberLevelFactor = 1 + (g.hud.uberStats.uberLevel - _local6.level) / 100;
				_local6.xp *= _local6.uberLevelFactor;
				_local6.level = g.hud.uberStats.uberLevel;
				_local6.speed *= _local6.uberLevelFactor;
				if(_local6.speed > 380) {
					_local6.speed = 380;
				}
			} else if(_local6.name == "Chelonidron") {
				_local6.level = 54;
			}
			_local6.addFactions();
			sortComponents(g,_local6);
			_local6.calcHpMax();
			_local6.stateMachine.changeState(new AIBoss(g,_local6));
			return _local6;
		}
		
		private static function addTurrets(obj:Object, g:Game, b:Boss) : void {
			var _local4:Array = obj.turrets;
			for each(var _local5 in _local4) {
				createTurret(_local5,b,g);
			}
		}
		
		private static function createTurret(turretObj:Object, b:Boss, g:Game) : void {
			var _local4:Turret = TurretFactory.createTurret(turretObj,turretObj.turret,g,b);
			_local4.offset = new Point(turretObj.xpos,turretObj.ypos);
			_local4.startAngle = Util.degreesToRadians(turretObj.angle);
			_local4.syncId = turretObj.id;
			_local4.parentObj = b;
			_local4.alive = true;
			_local4.name = turretObj.name;
			_local4.rotation = _local4.startAngle;
			_local4.hideIfInactive = turretObj.hideIfInactive;
			_local4.essential = turretObj.essential;
			_local4.active = turretObj.active;
			_local4.invulnerable = turretObj.invulnerable;
			_local4.triggersToActivte = turretObj.triggersToActivte;
			_local4.triggers = getTriggers(turretObj,g);
			_local4.layer = turretObj.layer;
			b.turrets.push(_local4);
			b.allComponents.push(_local4);
			_local4.stateMachine.changeState(new AITurret(g,_local4));
		}
		
		private static function addSpawners(obj:Object, g:Game, b:Boss) : void {
			var _local7:Object = null;
			var _local4:IDataManager = DataLocator.getService();
			var _local5:Array = obj.spawners;
			if(_local5.length == 0) {
				return;
			}
			for(var _local6 in _local5) {
				_local7 = _local5[_local6];
				createSpawner(_local7,_local6.toString(),b,g);
			}
		}
		
		private static function createSpawner(bossSpawnObj:Object, key:String, b:Boss, g:Game) : void {
			var _local6:Object = DataLocator.getService().loadKey("Spawners",bossSpawnObj.spawner);
			var _local5:Spawner = SpawnFactory.createSpawner(_local6,"bossSpawner_" + b.key + "_" + key,g,b);
			_local5.parentObj = b;
			_local5.offset = new Point(bossSpawnObj.xpos,bossSpawnObj.ypos);
			_local5.imageOffset = new Point(bossSpawnObj.imageOffsetX,bossSpawnObj.imageOffsetY);
			_local5.syncId = bossSpawnObj.id;
			_local5.alive = true;
			_local5.rotation = bossSpawnObj.angle / (3 * 60) * 3.141592653589793;
			_local5.angleOffset = _local5.parentObj.rotation - _local5.rotation;
			_local5.name = bossSpawnObj.name;
			_local5.hideIfInactive = bossSpawnObj.hideIfInactive;
			_local5.essential = bossSpawnObj.essential;
			_local5.active = bossSpawnObj.active;
			_local5.invulnerable = bossSpawnObj.invulnerable;
			_local5.triggersToActivte = bossSpawnObj.triggersToActivte;
			_local5.triggers = getTriggers(bossSpawnObj,g);
			_local5.orbitRadius = 0;
			_local5.orbitAngle = 0;
			_local5.offset = new Point(bossSpawnObj.xpos,bossSpawnObj.ypos);
			_local5.imageOffset = new Point(bossSpawnObj.imageOffsetX,bossSpawnObj.imageOffsetY);
			_local5.layer = bossSpawnObj.layer;
			b.spawners.push(_local5);
			b.allComponents.push(_local5);
		}
		
		private static function addBossComponents(obj:Object, g:Game, b:Boss) : void {
			var _local4:Array = obj.basicObjs;
			for each(var _local5 in _local4) {
				createBossComponent(_local5,b,g);
			}
		}
		
		private static function createBossComponent(compObj:Object, b:Boss, g:Game) : void {
			var _local5:Number = NaN;
			var _local4:BossComponent = new BossComponent(g);
			_local4.switchTexturesByObj(compObj);
			_local4.parentObj = b;
			_local4.offset = new Point(compObj.xpos,compObj.ypos);
			_local4.imageOffset = new Point(compObj.imageOffsetX,compObj.imageOffsetY);
			_local4.syncId = compObj.id;
			_local4.parentObj = b;
			_local4.hp = compObj.hp;
			_local4.hpMax = compObj.hp;
			_local4.shieldHp = 0;
			_local4.shieldHpMax = 0;
			_local4.xp = compObj.xp;
			_local4.level = compObj.level;
			_local4.essential = compObj.essential;
			if(g.isSystemTypeSurvival() && b != null) {
				_local4.level = b.level;
			}
			if(g.isSystemTypeSurvival() && _local4.level < g.hud.uberStats.uberLevel && _local4.essential) {
				_local5 = g.hud.uberStats.CalculateUberRankFromLevel(_local4.level);
				_local4.uberDifficulty = g.hud.uberStats.CalculateUberDifficultyFromRank(g.hud.uberStats.uberRank - _local5,_local4.level);
				_local4.uberLevelFactor = 1 + (g.hud.uberStats.uberLevel - _local4.level) / 100;
				if(b != null) {
					_local4.uberDifficulty *= g.hud.uberStats.uberRank / 2 + 1;
				}
				_local4.xp *= _local4.uberLevelFactor;
				_local4.level = g.hud.uberStats.uberLevel;
				_local4.hp = _local4.hpMax = _local4.hpMax * _local4.uberDifficulty;
				_local4.shieldHp = _local4.shieldHpMax = _local4.shieldHpMax * _local4.uberDifficulty;
			}
			_local4.alive = true;
			_local4.imageAngle = Util.degreesToRadians(compObj.angle);
			_local4.name = compObj.name;
			_local4.imageScale = compObj.scale;
			_local4.imageRotationSpeed = compObj.rotationSpeed;
			_local4.imageRotationMax = compObj.maxAngle;
			_local4.imageRotationMin = compObj.minAngle;
			_local4.imagePivotPoint = new Point(compObj.pivotPointX,compObj.pivotPointY);
			_local4.hideIfInactive = compObj.hideIfInactive;
			_local4.active = compObj.active;
			_local4.invulnerable = compObj.invulnerable;
			_local4.triggersToActivte = compObj.triggersToActivte;
			_local4.triggers = getTriggers(compObj,g);
			_local4.isHostile = true;
			_local4.collisionRadius = compObj.collisionRadius;
			_local4.layer = compObj.layer;
			b.allComponents.push(_local4);
			b.bossComponents.push(_local4);
			if(compObj.hasOwnProperty("explosionEffect")) {
				_local4.explosionEffect = compObj.explosionEffect;
			}
			if(compObj.hasOwnProperty("effect")) {
				_local4.effectX = compObj.effectX;
				_local4.effectY = compObj.effectY;
				_local4.effect = EmitterFactory.create(compObj.effect,g,0,0,_local4.effectTarget,true);
			}
		}
		
		private static function getTriggers(obj:Object, g:Game) : Vector.<Trigger> {
			var _local5:int = 0;
			var _local6:Object = null;
			var _local4:Trigger = null;
			var _local7:Vector.<Trigger> = new Vector.<Trigger>();
			var _local3:Array = obj.triggers;
			if(_local3 == null) {
				return _local7;
			}
			_local5 = 0;
			while(_local5 < _local3.length) {
				_local6 = _local3[_local5];
				_local4 = new Trigger(g);
				_local4.id = _local6.id;
				_local4.target = _local6.target;
				_local4.delay = _local6.delay;
				_local4.activate = _local6.activte;
				_local4.inactivate = _local6.inactivte;
				_local4.vulnerable = _local6.vulnerable;
				_local4.invulnerable = _local6.invulnerable;
				_local4.kill = _local6.kill;
				_local4.threshhold = Number(_local6.threshhold) / 100;
				_local4.inactivateSelf = _local6.inactivateSelf;
				if(_local6.hasOwnProperty("sound")) {
					_local4.soundName = _local6.sound;
				} else {
					_local4.soundName = "";
				}
				if(_local6.hasOwnProperty("explosionEffect")) {
					_local4.explosionEffect = _local6.explosionEffect;
					_local4.xpos = _local6.xpos;
					_local4.ypos = _local6.ypos;
				} else {
					_local4.explosionEffect = "";
					_local4.xpos = 0;
					_local4.ypos = 0;
				}
				_local4.editBase = _local6.editBase;
				_local4.speed = _local6.speed;
				_local4.acceleration = _local6.acceleration;
				_local4.rotationForced = _local6.rotationForced;
				_local4.rotationSpeed = _local6.rotationSpeed;
				_local4.targetRange = _local6.targetRange;
				_local7.push(_local4);
				_local5++;
			}
			return _local7;
		}
		
		private static function sortComponents(g:Game, b:Boss) : void {
			b.allComponents.sort(compareFunction);
			for each(var _local3 in b.allComponents) {
				_local3.isBossUnit = true;
				_local3.distanceToCamera = 0;
				g.unitManager.add(_local3,g.canvasBosses,false);
			}
		}
		
		private static function compareFunction(u1:Unit, u2:Unit) : int {
			if(u1.layer < u2.layer) {
				return -1;
			}
			if(u1.layer > u2.layer) {
				return 1;
			}
			return 0;
		}
	}
}

