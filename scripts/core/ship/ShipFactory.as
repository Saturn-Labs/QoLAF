package core.ship {
	import core.engine.EngineFactory;
	import core.player.EliteTechs;
	import core.player.FleetObj;
	import core.player.Player;
	import core.player.TechSkill;
	import core.scene.Game;
	import core.turret.Turret;
	import core.unit.Unit;
	import core.weapon.Weapon;
	import core.weapon.WeaponFactory;
	import data.DataLocator;
	import data.IDataManager;
	import generics.Random;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.filters.ColorMatrixFilter;
	
	public class ShipFactory {
		public function ShipFactory() {
			super();
		}
		
		public static function createPlayer(g:Game, player:Player, ship:PlayerShip, weapons:Array) : PlayerShip {
			var _local10:ColorMatrixFilter = null;
			var _local8:IDataManager = DataLocator.getService();
			var _local6:Object = _local8.loadKey("Skins",player.activeSkin);
			var _local11:FleetObj = player.getActiveFleetObj();
			ship.hideShadow = _local6.hideShadow;
			createBody(_local6.ship,g,ship);
			ship = PlayerShip(ship);
			ship.name = player.name;
			ship.setIsHostile(player.isHostile);
			ship.group = player.group;
			ship.factions = player.factions;
			ship.hpBase = ship.hpMax;
			ship.shieldHpBase = ship.shieldHpMax;
			ship.activeWeapons = 0;
			ship.unlockedWeaponSlots = player.unlockedWeaponSlots;
			ship.player = player;
			ship.artifact_convAmount = 0;
			ship.artifact_cooldownReduction = 0;
			ship.artifact_speed = 0;
			ship.artifact_powerRegen = 0;
			ship.artifact_powerMax = 0;
			ship.artifact_refire = 0;
			var _local9:Number = !!_local11.shipHue ? _local11.shipHue : 0;
			var _local5:Number = !!_local11.shipBrightness ? _local11.shipBrightness : 0;
			if(_local9 != 0 || _local5 != 0) {
				_local10 = createPlayerShipColorMatrixFilter(_local11);
				ship.movieClip.filter = _local10;
				ship.originalFilter = _local10;
			}
			ship.engine = EngineFactory.create(_local6.engine,g,ship);
			var _local7:Number = !!_local11.engineHue ? _local11.engineHue : 0;
			addEngineTechToShip(player,ship);
			ship.engine.colorHue = _local7;
			CreatePlayerShipWeapon(g,player,0,weapons,ship);
			addArmorTechToShip(player,ship);
			addShieldTechToShip(player,ship);
			addPowerTechToShip(player,ship);
			addLevelBonusToShip(g,player.level,ship);
			ship.hp = ship.hpMax;
			ship.shieldHp = ship.shieldHpMax;
			return ship;
		}
		
		public static function createPlayerShipColorMatrixFilter(fleetObj:FleetObj) : ColorMatrixFilter {
			if(RymdenRunt.isBuggedFlashVersion) {
				return null;
			}
			var _local6:ColorMatrixFilter = new ColorMatrixFilter();
			var _local5:Number = !!fleetObj.shipHue ? fleetObj.shipHue : 0;
			var _local3:Number = !!fleetObj.shipBrightness ? fleetObj.shipBrightness : 0;
			var _local2:Number = !!fleetObj.shipSaturation ? fleetObj.shipSaturation : 0;
			var _local4:Number = !!fleetObj.shipContrast ? fleetObj.shipContrast : 0;
			_local6.resolution = 2;
			_local6.adjustHue(_local5);
			_local6.adjustBrightness(_local3);
			_local6.adjustSaturation(_local2);
			_local6.adjustContrast(_local4);
			return _local6;
		}
		
		public static function CreatePlayerShipWeapon(g:Game, player:Player, i:int, weapons:Array, ship:PlayerShip) : void {
			var _local7:int = 0;
			var _local6:TechSkill = null;
			var _local9:Weapon = null;
			var _local8:Object = weapons[i];
			var _local11:int = 0;
			var _local10:int = -1;
			var _local13:String = "";
			if(player != null && player.techSkills != null && _local8 != null) {
				_local7 = 0;
				while(_local7 < player.techSkills.length) {
					_local6 = player.techSkills[_local7];
					if(_local6.tech == _local8.weapon) {
						_local11 = _local6.level;
						_local10 = _local6.activeEliteTechLevel;
						_local13 = _local6.activeEliteTech;
					}
					_local7++;
				}
			}
			var _local12:Weapon = WeaponFactory.create(_local8.weapon,g,ship,_local11,_local10,_local13);
			_local12.setActive(ship,player.weaponsState[i]);
			_local12.hotkey = player.weaponsHotkeys[i];
			addLevelBonusToWeapon(g,player.level,_local12,player);
			if(i < ship.weapons.length) {
				_local9 = ship.weapons[i];
				ship.weapons[i] = _local12;
				_local9.destroy();
			} else {
				ship.weapons.push(_local12);
			}
			if(i == weapons.length - 1) {
				player.saveWeaponData(ship.weapons);
			} else {
				i += 1;
				CreatePlayerShipWeapon(g,player,i,weapons,ship);
			}
		}
		
		private static function addArmorTechToShip(player:Player, s:PlayerShip) : void {
			var _local8:int = 0;
			var _local3:TechSkill = null;
			var _local10:Object = null;
			var _local7:int = 0;
			_local8 = 0;
			while(_local8 < player.techSkills.length) {
				_local3 = player.techSkills[_local8];
				if(_local3.tech == "m4yG1IRPIUeyRQHrC3h5kQ") {
					break;
				}
				_local8++;
			}
			var _local9:IDataManager = DataLocator.getService();
			var _local5:Object = _local9.loadKey("BasicTechs",_local3.tech);
			var _local6:int = _local3.level;
			_local7 = 0;
			while(_local7 < _local6) {
				_local10 = _local5.techLevels[_local7];
				s.armorThreshold += _local10.dmgThreshold;
				s.armorThresholdBase += _local10.dmgThreshold;
				s.hpBase += _local10.hpBonus;
				if(_local7 == _local6 - 1) {
					if(_local10.armorConvGain > 0) {
						s.hasArmorConverter = true;
						s.convCD = _local10.cooldown * 1000;
						s.convCost = _local10.armorConvCost;
						s.convGain = _local10.armorConvGain;
					}
				}
				_local7++;
			}
			s.hpMax = s.hpBase;
			var _local4:int = -1;
			var _local11:String = "";
			_local4 = _local3.activeEliteTechLevel;
			_local11 = _local3.activeEliteTech;
			EliteTechs.addEliteTechs(s,_local5,_local4,_local11);
		}
		
		private static function addShieldTechToShip(player:Player, s:PlayerShip) : void {
			var _local8:int = 0;
			var _local3:TechSkill = null;
			var _local10:Object = null;
			var _local7:int = 0;
			_local8 = 0;
			while(_local8 < player.techSkills.length) {
				_local3 = player.techSkills[_local8];
				if(_local3.tech == "QgKEEj8a-0yzYAJ06eSLqA") {
					break;
				}
				_local8++;
			}
			var _local9:IDataManager = DataLocator.getService();
			var _local5:Object = _local9.loadKey("BasicTechs",_local3.tech);
			var _local6:int = _local3.level;
			_local7 = 0;
			while(_local7 < _local6) {
				_local10 = _local5.techLevels[_local7];
				s.shieldHpBase += _local10.hpBonus;
				s.shieldRegenBase += _local10.regen;
				if(_local7 == _local6 - 1) {
					if(_local10.hardenMaxDmg > 0) {
						s.hasHardenedShield = true;
						s.hardenMaxDmg = _local10.hardenMaxDmg;
						s.hardenCD = _local10.cooldown * 1000;
						s.hardenDuration = _local10.duration * 1000;
					}
				}
				_local7++;
			}
			s.shieldRegen = s.shieldRegenBase;
			s.shieldHpMax = s.shieldHpBase;
			var _local4:int = -1;
			var _local11:String = "";
			_local4 = _local3.activeEliteTechLevel;
			_local11 = _local3.activeEliteTech;
			EliteTechs.addEliteTechs(s,_local5,_local4,_local11);
		}
		
		private static function addEngineTechToShip(player:Player, s:PlayerShip) : void {
			var _local5:int = 0;
			var _local3:TechSkill = null;
			var _local7:Object = null;
			var _local4:int = 0;
			_local5 = 0;
			while(_local5 < player.techSkills.length) {
				_local3 = player.techSkills[_local5];
				if(_local3.tech == "rSr1sn-_oUOY6E0hpAhh0Q") {
					break;
				}
				_local5++;
			}
			var _local12:IDataManager = DataLocator.getService();
			var _local9:Object = _local12.loadKey("BasicTechs",_local3.tech);
			var _local10:int = _local3.level;
			var _local6:int = 100;
			var _local11:int = 100;
			_local4 = 0;
			while(_local4 < _local10) {
				_local7 = _local9.techLevels[_local4];
				_local6 += _local7.acceleration;
				_local11 += _local7.maxSpeed;
				if(_local4 == _local10 - 1) {
					if(_local7.boost > 0) {
						s.hasBoost = true;
						s.boostBonus = _local7.boost;
						s.boostCD = _local7.cooldown * 1000;
						s.boostDuration = _local7.duration * 1000;
						s.totalTicksOfBoost = s.boostDuration / 33;
						s.ticksOfBoost = 0;
					}
				}
				_local4++;
			}
			s.engine.acceleration = s.engine.acceleration * _local6 / 100;
			s.engine.speed = s.engine.speed * _local11 / 100;
			var _local8:int = -1;
			var _local13:String = "";
			_local8 = _local3.activeEliteTechLevel;
			_local13 = _local3.activeEliteTech;
			EliteTechs.addEliteTechs(s,_local9,_local8,_local13);
		}
		
		private static function addPowerTechToShip(player:Player, s:PlayerShip) : void {
			var _local8:int = 0;
			var _local3:TechSkill = null;
			var _local10:Object = null;
			var _local7:int = 0;
			_local8 = 0;
			while(_local8 < player.techSkills.length) {
				_local3 = player.techSkills[_local8];
				if(_local3.tech == "kwlCdExeJk-oEJZopIz5kg") {
					break;
				}
				_local8++;
			}
			var _local9:IDataManager = DataLocator.getService();
			var _local5:Object = _local9.loadKey("BasicTechs",_local3.tech);
			var _local6:int = _local3.level;
			s.maxPower = 1;
			s.powerRegBonus = 1;
			_local7 = 0;
			while(_local7 < _local6) {
				_local10 = _local5.techLevels[_local7];
				s.maxPower += 0.01 * Number(_local10.maxPower);
				s.powerRegBonus += 0.01 * Number(_local10.powerReg);
				if(_local7 == _local6 - 1) {
					if(_local10.boost > 0) {
						s.hasDmgBoost = true;
						s.dmgBoostCD = _local10.cooldown * 1000;
						s.dmgBoostDuration = _local10.duration * 1000;
						s.dmgBoostCost = 0.01 * Number(_local10.boostCost);
						s.dmgBoostBonus = 0.01 * Number(_local10.boost);
						s.totalTicksOfBoost = s.boostDuration / 33;
						s.ticksOfBoost = 0;
					}
				}
				_local7++;
			}
			s.weaponHeat.setBonuses(s.maxPower,s.powerRegBonus);
			var _local4:int = -1;
			var _local11:String = "";
			_local4 = _local3.activeEliteTechLevel;
			_local11 = _local3.activeEliteTech;
			EliteTechs.addEliteTechs(s,_local5,_local4,_local11);
		}
		
		private static function addLevelBonusToShip(g:Game, level:Number, s:PlayerShip) : void {
			if(g.solarSystem.isPvpSystemInEditor) {
				level = 100;
			}
			var _local5:Number = s.player.troons;
			var _local4:Number = _local5 / 200000;
			level += _local4;
			s.hpBase = s.hpBase * (100 + 8 * (level - 1)) / 100;
			s.hpMax = s.hpBase;
			s.hp = s.hpMax;
			s.armorThresholdBase = s.armorThresholdBase * (100 + 2.5 * 8 * (level - 1)) / 100;
			s.shieldHpBase = s.shieldHpBase * (100 + 8 * (level - 1)) / 100;
			s.armorThreshold = s.armorThresholdBase;
			s.shieldHpMax = s.shieldHpBase;
			s.shieldHp = s.shieldHpMax;
			s.shieldRegenBase = s.shieldRegenBase * (100 + 1 * (level - 1)) / 100;
			s.shieldRegen = s.shieldRegenBase;
		}
		
		private static function addLevelBonusToWeapon(g:Game, level:Number, w:Weapon, p:Player) : void {
			if(g.solarSystem.isPvpSystemInEditor) {
				level = 100;
			}
			var _local6:Number = p.troons;
			var _local5:Number = _local6 / 200000;
			level += _local5;
			w.dmg.addLevelBonus(level,8);
			if(w.debuffValue != null) {
				w.debuffValue.addLevelBonus(level,8);
				w.debuffValue2.addLevelBonus(level,8);
			}
		}
		
		public static function createEnemy(g:Game, key:String, rareType:int = 0) : EnemyShip {
			var _local5:Number = NaN;
			var _local4:Random = null;
			var _local8:IDataManager = DataLocator.getService();
			var _local6:Object = _local8.loadKey("Enemies",key);
			if(g.isLeaving) {
				return null;
			}
			if(_local6 == null) {
				trace("Key: ",key);
				return null;
			}
			var _local7:EnemyShip = g.shipManager.getEnemyShip();
			_local7.name = _local6.name;
			_local7.xp = _local6.xp;
			_local7.level = _local6.level;
			_local7.rareType = rareType;
			_local7.aggroRange = _local6.aggroRange;
			_local7.chaseRange = _local6.chaseRange;
			_local7.observer = _local6.observer;
			if(_local7.observer) {
				_local7.visionRange = _local6.visionRange;
			} else {
				_local7.visionRange = _local7.aggroRange;
			}
			if(g.isSystemTypeSurvival() && _local7.level < g.hud.uberStats.uberLevel) {
				_local5 = g.hud.uberStats.CalculateUberRankFromLevel(_local7.level);
				_local7.uberDifficulty = g.hud.uberStats.CalculateUberDifficultyFromRank(g.hud.uberStats.uberRank - _local5,_local7.level);
				_local7.uberLevelFactor = 1 + (g.hud.uberStats.uberLevel - _local7.level) / 100;
				_local7.aggroRange *= _local7.uberLevelFactor;
				_local7.chaseRange *= _local7.uberLevelFactor;
				_local7.visionRange *= _local7.uberLevelFactor;
				_local4 = new Random(_local7.id);
				if(_local7.aggroRange > 2000) {
					_local7.aggroRange = 10000;
				} else if(g.hud.uberStats.uberRank >= 9) {
					_local7.aggroRange = 50 * 60 + _local4.random(10000);
				} else if(g.hud.uberStats.uberRank >= 6) {
					_local7.aggroRange = 2000 + _local4.random(10000);
				} else if(g.hud.uberStats.uberRank >= 3) {
					_local7.aggroRange = 25 * 60 + _local4.random(10000);
				} else if(_local7.aggroRange < 50 * 60) {
					_local7.aggroRange = 1000 + _local4.random(10000);
				}
				_local7.chaseRange = _local7.aggroRange;
				_local7.visionRange = _local7.aggroRange;
				_local7.xp *= _local7.uberLevelFactor;
				_local7.level = g.hud.uberStats.uberLevel;
			}
			_local7.orbitSpawner = _local6.orbitSpawner;
			if(_local7.orbitSpawner) {
				_local7.hpRegen = _local6.hpRegen;
			}
			_local7.aimSkill = _local6.aimSkill;
			if(_local6.hasOwnProperty("stopWhenClose")) {
				_local7.stopWhenClose = _local6.stopWhenClose;
			}
			if(_local6.hasOwnProperty("AIFaction1") && _local6.AIFaction1 != "") {
				_local7.factions.push(_local6.AIFaction1);
			}
			if(_local6.hasOwnProperty("AIFaction2") && _local6.AIFaction2 != "") {
				_local7.factions.push(_local6.AIFaction2);
			}
			if(_local6.hasOwnProperty("teleport")) {
				_local7.teleport = _local6.teleport;
			}
			_local7.kamikaze = _local6.kamikaze;
			if(_local7.kamikaze) {
				_local7.kamikazeLifeTreshhold = _local6.kamikazeLifeTreshhold;
				_local7.kamikazeHoming = _local6.kamikazeHoming;
				_local7.kamikazeTtl = _local6.kamikazeTtl;
				_local7.kamikazeDmg = _local6.kamikazeDmg;
				_local7.kamikazeRadius = _local6.kamikazeRadius;
				_local7.kamikazeWhenClose = _local6.kamikazeWhenClose;
			}
			if(_local6.hasOwnProperty("alwaysFire")) {
				_local7.alwaysFire = _local6.alwaysFire;
			} else {
				_local7.alwaysFire = false;
			}
			_local7.forcedRotation = _local6.forcedRotation;
			if(_local7.forcedRotation) {
				_local7.forcedRotationSpeed = _local6.forcedRotationSpeed;
				_local7.forcedRotationAim = _local6.forcedRotationAim;
			}
			_local7.melee = _local6.melee;
			if(_local7.melee) {
				_local7.meleeCharge = _local6.charge;
				_local7.meleeChargeSpeedBonus = Number(_local6.chargeSpeedBonus) / 100;
				_local7.meleeChargeDuration = _local6.chargeDuration;
				_local7.meleeCanGrab = _local6.grab;
			}
			_local7.flee = _local6.flee;
			if(_local7.flee) {
				_local7.fleeLifeTreshhold = _local6.fleeLifeTreshhold;
				_local7.fleeDuration = _local6.fleeDuration;
				if(_local6.hasOwnProperty("fleeClose")) {
					_local7.fleeClose = _local6.fleeClose;
				} else {
					_local7.fleeClose = 0;
				}
			}
			_local7.aiCloak = false;
			if(_local6.hasOwnProperty("hardenShield")) {
				_local7.aiHardenShield = false;
				_local7.aiHardenShieldDuration = _local6.hardenShieldDuration;
			} else {
				_local7.aiHardenShield = false;
				_local7.aiHardenShieldDuration = 0;
			}
			if(_local6.hasOwnProperty("sniper")) {
				_local7.sniper = _local6.sniper;
				if(_local7.sniper) {
					_local7.sniperMinRange = _local6.sniperMinRange;
				}
			}
			_local7.isHostile = true;
			_local7.group = null;
			createBody(_local6.ship,g,_local7);
			_local7.engine = EngineFactory.create(_local6.engine,g,_local7);
			if(_local7.uberDifficulty > 0) {
				_local7.hp = _local7.hpMax *= _local7.uberDifficulty;
				_local7.shieldHp = _local7.shieldHpMax *= _local7.uberDifficulty;
				_local7.engine.speed *= _local7.uberLevelFactor;
				if(_local7.engine.speed > 380) {
					_local7.engine.speed = 380;
				}
			}
			if(rareType == 1) {
				_local7.hp = _local7.hpMax *= 3;
				_local7.shieldHp = _local7.shieldHpMax *= 3;
			}
			if(rareType == 4) {
				_local7.hp = _local7.hpMax *= 3;
				_local7.shieldHp = _local7.shieldHpMax *= 3;
				_local7.engine.speed *= 1.1;
			}
			if(rareType == 5) {
				_local7.color = 0xff8811;
				_local7.hp = _local7.hpMax *= 10;
				_local7.shieldHp = _local7.shieldHpMax *= 10;
				_local7.engine.speed *= 1.3;
			}
			if(rareType == 3) {
				_local7.engine.speed *= 1.4;
			}
			if(_local6.hasOwnProperty("startHp")) {
				_local7.hp = 0.01 * _local6.startHp * _local7.hp;
			}
			CreateEnemyShipWeapon(g,0,_local6.weapons,_local7);
			CreateEnemyShipExtraWeapon(g,_local7.weapons.length,_local6.fleeWeaponItem,_local7,0);
			CreateEnemyShipExtraWeapon(g,_local7.weapons.length,_local6.antiProjectileWeaponItem,_local7,1);
			if(!g.isLeaving) {
				g.shipManager.activateEnemyShip(_local7);
			}
			return _local7;
		}
		
		private static function CreateEnemyShipWeapon(g:Game, i:int, weapons:Array, ship:EnemyShip) : void {
			var _local7:Weapon = null;
			if(weapons.length == 0) {
				return;
			}
			var _local6:Object = weapons[i];
			var _local5:Weapon = WeaponFactory.create(_local6.weapon,g,ship,0);
			ship.weaponRanges.push(new WeaponRange(_local6.minRange,_local6.maxRange));
			if(i < ship.weapons.length) {
				_local7 = ship.weapons[i];
				ship.weapons[i] = _local5;
				_local7.destroy();
			} else {
				ship.weapons.push(_local5);
			}
			if(i != weapons.length - 1) {
				i += 1;
				CreateEnemyShipWeapon(g,i,weapons,ship);
			}
		}
		
		private static function CreateEnemyShipExtraWeapon(g:Game, i:int, weaponObj:Object, ship:EnemyShip, type:int) : void {
			var _local7:Weapon = null;
			if(weaponObj == null) {
				return;
			}
			var _local6:Weapon = WeaponFactory.create(weaponObj.weapon,g,ship,0);
			ship.weaponRanges.push(new WeaponRange(0,0));
			if(type == 0) {
				ship.escapeWeapon = _local6;
			} else {
				ship.antiProjectileWeapon = _local6;
			}
			if(i < ship.weapons.length) {
				_local7 = ship.weapons[i];
				ship.weapons[i] = _local6;
				_local7.destroy();
			} else {
				ship.weapons.push(_local6);
			}
		}
		
		public static function createBody(key:String, g:Game, s:Unit) : void {
			var _local6:IDataManager = DataLocator.getService();
			var _local4:Object = _local6.loadKey("Ships",key);
			s.switchTexturesByObj(_local4);
			if(_local4.blendModeAdd) {
				s.movieClip.blendMode = "add";
			}
			s.obj = _local4;
			s.bodyName = _local4.name;
			s.collisionRadius = _local4.collisionRadius;
			s.hp = _local4.hp;
			s.hpMax = _local4.hp;
			s.shieldHp = _local4.shieldHp;
			s.shieldHpMax = _local4.shieldHp;
			s.armorThreshold = _local4.armor;
			s.armorThresholdBase = _local4.armor;
			s.shieldRegenBase = 1.5 * _local4.shieldRegen;
			s.shieldRegen = s.shieldRegenBase;
			if(s is Ship) {
				s.enginePos.x = _local4.enginePosX;
				s.enginePos.y = _local4.enginePosY;
				s.weaponPos.x = _local4.weaponPosX;
				s.weaponPos.y = _local4.weaponPosY;
			} else {
				s is Turret;
			}
			s.weaponPos.x = _local4.weaponPosX;
			s.weaponPos.y = _local4.weaponPosY;
			s.explosionEffect = _local4.explosionEffect;
			s.explosionSound = _local4.explosionSound;
			var _local5:ISound = SoundLocator.getService();
			if(s.explosionSound != null) {
				_local5.preCacheSound(s.explosionSound);
			}
		}
	}
}

