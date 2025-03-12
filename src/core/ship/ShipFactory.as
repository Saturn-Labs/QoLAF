package core.ship
{
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
	
	public class ShipFactory
	{
		public function ShipFactory()
		{
			super();
		}
		
		public static function createPlayer(param1:Game, param2:Player, param3:PlayerShip, param4:Array):PlayerShip
		{
			var _loc5_:ColorMatrixFilter = null;
			var _loc11_:IDataManager = DataLocator.getService();
			var _loc10_:Object = _loc11_.loadKey("Skins", param2.activeSkin);
			var _loc7_:FleetObj = param2.getActiveFleetObj();
			param3.hideShadow = _loc10_.hideShadow;
			createBody(_loc10_.ship, param1, param3);
			param3 = PlayerShip(param3);
			param3.name = param2.name;
			param3.setIsHostile(param2.isHostile);
			param3.group = param2.group;
			param3.factions = param2.factions;
			param3.hpBase = param3.hpMax;
			param3.shieldHpBase = param3.shieldHpMax;
			param3.activeWeapons = 0;
			param3.unlockedWeaponSlots = param2.unlockedWeaponSlots;
			param3.player = param2;
			param3.aritfact_convAmount = 0;
			param3.aritfact_cooldownReduction = 0;
			param3.aritfact_speed = 0;
			param3.aritfact_poweReg = 0;
			param3.aritfact_powerMax = 0;
			param3.aritfact_refire = 0;
			var _loc8_:Number = !!_loc7_.shipHue ? _loc7_.shipHue : 0;
			var _loc9_:Number = !!_loc7_.shipBrightness ? _loc7_.shipBrightness : 0;
			if (_loc8_ != 0 || _loc9_ != 0)
			{
				_loc5_ = createPlayerShipColorMatrixFilter(_loc7_);
				param3.movieClip.filter = _loc5_;
				param3.originalFilter = _loc5_;
			}
			param3.engine = EngineFactory.create(_loc10_.engine, param1, param3);
			var _loc6_:Number = !!_loc7_.engineHue ? _loc7_.engineHue : 0;
			addEngineTechToShip(param2, param3);
			param3.engine.colorHue = _loc6_;
			CreatePlayerShipWeapon(param1, param2, 0, param4, param3);
			addArmorTechToShip(param2, param3);
			addShieldTechToShip(param2, param3);
			addPowerTechToShip(param2, param3);
			addLevelBonusToShip(param1, param2.level, param3);
			param3.hp = param3.hpMax;
			param3.shieldHp = param3.shieldHpMax;
			return param3;
		}
		
		public static function createPlayerShipColorMatrixFilter(param1:FleetObj):ColorMatrixFilter
		{
			if (RymdenRunt.isBuggedFlashVersion)
			{
				return null;
			}
			var _loc2_:ColorMatrixFilter = new ColorMatrixFilter();
			var _loc5_:Number = !!param1.shipHue ? param1.shipHue : 0;
			var _loc6_:Number = !!param1.shipBrightness ? param1.shipBrightness : 0;
			var _loc4_:Number = !!param1.shipSaturation ? param1.shipSaturation : 0;
			var _loc3_:Number = !!param1.shipContrast ? param1.shipContrast : 0;
			_loc2_.resolution = 2;
			_loc2_.adjustHue(_loc5_);
			_loc2_.adjustBrightness(_loc6_);
			_loc2_.adjustSaturation(_loc4_);
			_loc2_.adjustContrast(_loc3_);
			return _loc2_;
		}
		
		public static function CreatePlayerShipWeapon(param1:Game, param2:Player, param3:int, param4:Array, param5:PlayerShip):void
		{
			var _loc8_:int = 0;
			var _loc10_:TechSkill = null;
			var _loc9_:Weapon = null;
			var _loc7_:Object = param4[param3];
			var _loc6_:int = 0;
			var _loc12_:int = -1;
			var _loc13_:String = "";
			if (param2 != null && param2.techSkills != null && _loc7_ != null)
			{
				_loc8_ = 0;
				while (_loc8_ < param2.techSkills.length)
				{
					_loc10_ = param2.techSkills[_loc8_];
					if (_loc10_.tech == _loc7_.weapon)
					{
						_loc6_ = _loc10_.level;
						_loc12_ = _loc10_.activeEliteTechLevel;
						_loc13_ = _loc10_.activeEliteTech;
					}
					_loc8_++;
				}
			}
			var _loc11_:Weapon = WeaponFactory.create(_loc7_.weapon, param1, param5, _loc6_, _loc12_, _loc13_);
			_loc11_.setActive(param5, param2.weaponsState[param3]);
			_loc11_.hotkey = param2.weaponsHotkeys[param3];
			addLevelBonusToWeapon(param1, param2.level, _loc11_, param2);
			if (param3 < param5.weapons.length)
			{
				_loc9_ = param5.weapons[param3];
				param5.weapons[param3] = _loc11_;
				_loc9_.destroy();
			}
			else
			{
				param5.weapons.push(_loc11_);
			}
			if (param3 == param4.length - 1)
			{
				param2.saveWeaponData(param5.weapons);
			}
			else
			{
				param3 += 1;
				CreatePlayerShipWeapon(param1, param2, param3, param4, param5);
			}
		}
		
		private static function addArmorTechToShip(param1:Player, param2:PlayerShip):void
		{
			var _loc5_:int = 0;
			var _loc7_:TechSkill = null;
			var _loc6_:Object = null;
			var _loc10_:int = 0;
			_loc5_ = 0;
			while (_loc5_ < param1.techSkills.length)
			{
				_loc7_ = param1.techSkills[_loc5_];
				if (_loc7_.tech == "m4yG1IRPIUeyRQHrC3h5kQ")
				{
					break;
				}
				_loc5_++;
			}
			var _loc11_:IDataManager = DataLocator.getService();
			var _loc4_:Object = _loc11_.loadKey("BasicTechs", _loc7_.tech);
			var _loc3_:int = _loc7_.level;
			_loc10_ = 0;
			while (_loc10_ < _loc3_)
			{
				_loc6_ = _loc4_.techLevels[_loc10_];
				param2.armorThreshold += _loc6_.dmgThreshold;
				param2.armorThresholdBase += _loc6_.dmgThreshold;
				param2.hpBase += _loc6_.hpBonus;
				if (_loc10_ == _loc3_ - 1)
				{
					if (_loc6_.armorConvGain > 0)
					{
						param2.hasArmorConverter = true;
						param2.convCD = _loc6_.cooldown * 1000;
						param2.convCost = _loc6_.armorConvCost;
						param2.convGain = _loc6_.armorConvGain;
					}
				}
				_loc10_++;
			}
			param2.hpMax = param2.hpBase;
			var _loc9_:int = -1;
			var _loc8_:String = "";
			_loc9_ = _loc7_.activeEliteTechLevel;
			_loc8_ = _loc7_.activeEliteTech;
			EliteTechs.addEliteTechs(param2, _loc4_, _loc9_, _loc8_);
		}
		
		private static function addShieldTechToShip(param1:Player, param2:PlayerShip):void
		{
			var _loc5_:int = 0;
			var _loc7_:TechSkill = null;
			var _loc6_:Object = null;
			var _loc10_:int = 0;
			_loc5_ = 0;
			while (_loc5_ < param1.techSkills.length)
			{
				_loc7_ = param1.techSkills[_loc5_];
				if (_loc7_.tech == "QgKEEj8a-0yzYAJ06eSLqA")
				{
					break;
				}
				_loc5_++;
			}
			var _loc11_:IDataManager = DataLocator.getService();
			var _loc4_:Object = _loc11_.loadKey("BasicTechs", _loc7_.tech);
			var _loc3_:int = _loc7_.level;
			_loc10_ = 0;
			while (_loc10_ < _loc3_)
			{
				_loc6_ = _loc4_.techLevels[_loc10_];
				param2.shieldHpBase += _loc6_.hpBonus;
				param2.shieldRegenBase += _loc6_.regen;
				if (_loc10_ == _loc3_ - 1)
				{
					if (_loc6_.hardenMaxDmg > 0)
					{
						param2.hasHardenedShield = true;
						param2.hardenMaxDmg = _loc6_.hardenMaxDmg;
						param2.hardenCD = _loc6_.cooldown * 1000;
						param2.hardenDuration = _loc6_.duration * 1000;
					}
				}
				_loc10_++;
			}
			param2.shieldRegen = param2.shieldRegenBase;
			param2.shieldHpMax = param2.shieldHpBase;
			var _loc9_:int = -1;
			var _loc8_:String = "";
			_loc9_ = _loc7_.activeEliteTechLevel;
			_loc8_ = _loc7_.activeEliteTech;
			EliteTechs.addEliteTechs(param2, _loc4_, _loc9_, _loc8_);
		}
		
		private static function addEngineTechToShip(param1:Player, param2:PlayerShip):void
		{
			var _loc6_:int = 0;
			var _loc7_:TechSkill = null;
			var _loc10_:Object = null;
			var _loc8_:int = 0;
			_loc6_ = 0;
			while (_loc6_ < param1.techSkills.length)
			{
				_loc7_ = param1.techSkills[_loc6_];
				if (_loc7_.tech == "rSr1sn-_oUOY6E0hpAhh0Q")
				{
					break;
				}
				_loc6_++;
			}
			var _loc11_:IDataManager = DataLocator.getService();
			var _loc9_:Object = _loc11_.loadKey("BasicTechs", _loc7_.tech);
			var _loc4_:int = _loc7_.level;
			var _loc3_:int = 100;
			var _loc5_:int = 100;
			_loc8_ = 0;
			while (_loc8_ < _loc4_)
			{
				_loc10_ = _loc9_.techLevels[_loc8_];
				_loc3_ += _loc10_.acceleration;
				_loc5_ += _loc10_.maxSpeed;
				if (_loc8_ == _loc4_ - 1)
				{
					if (_loc10_.boost > 0)
					{
						param2.hasBoost = true;
						param2.boostBonus = _loc10_.boost;
						param2.boostCD = _loc10_.cooldown * 1000;
						param2.boostDuration = _loc10_.duration * 1000;
						param2.totalTicksOfBoost = param2.boostDuration / 33;
						param2.ticksOfBoost = 0;
					}
				}
				_loc8_++;
			}
			param2.engine.acceleration = param2.engine.acceleration * _loc3_ / 100;
			param2.engine.speed = param2.engine.speed * _loc5_ / 100;
			var _loc12_:int = -1;
			var _loc13_:String = "";
			_loc12_ = _loc7_.activeEliteTechLevel;
			_loc13_ = _loc7_.activeEliteTech;
			EliteTechs.addEliteTechs(param2, _loc9_, _loc12_, _loc13_);
		}
		
		private static function addPowerTechToShip(param1:Player, param2:PlayerShip):void
		{
			var _loc5_:int = 0;
			var _loc7_:TechSkill = null;
			var _loc6_:Object = null;
			var _loc10_:int = 0;
			_loc5_ = 0;
			while (_loc5_ < param1.techSkills.length)
			{
				_loc7_ = param1.techSkills[_loc5_];
				if (_loc7_.tech == "kwlCdExeJk-oEJZopIz5kg")
				{
					break;
				}
				_loc5_++;
			}
			var _loc11_:IDataManager = DataLocator.getService();
			var _loc4_:Object = _loc11_.loadKey("BasicTechs", _loc7_.tech);
			var _loc3_:int = _loc7_.level;
			param2.maxPower = 1;
			param2.powerRegBonus = 1;
			_loc10_ = 0;
			while (_loc10_ < _loc3_)
			{
				_loc6_ = _loc4_.techLevels[_loc10_];
				param2.maxPower += 0.01 * Number(_loc6_.maxPower);
				param2.powerRegBonus += 0.01 * Number(_loc6_.powerReg);
				if (_loc10_ == _loc3_ - 1)
				{
					if (_loc6_.boost > 0)
					{
						param2.hasDmgBoost = true;
						param2.dmgBoostCD = _loc6_.cooldown * 1000;
						param2.dmgBoostDuration = _loc6_.duration * 1000;
						param2.dmgBoostCost = 0.01 * Number(_loc6_.boostCost);
						param2.dmgBoostBonus = 0.01 * Number(_loc6_.boost);
						param2.totalTicksOfBoost = param2.boostDuration / 33;
						param2.ticksOfBoost = 0;
					}
				}
				_loc10_++;
			}
			param2.weaponHeat.setBonuses(param2.maxPower, param2.powerRegBonus);
			var _loc9_:int = -1;
			var _loc8_:String = "";
			_loc9_ = _loc7_.activeEliteTechLevel;
			_loc8_ = _loc7_.activeEliteTech;
			EliteTechs.addEliteTechs(param2, _loc4_, _loc9_, _loc8_);
		}
		
		private static function addLevelBonusToShip(param1:Game, param2:Number, param3:PlayerShip):void
		{
			if (param1.solarSystem.isPvpSystemInEditor)
			{
				param2 = 100;
			}
			var _loc4_:Number = param3.player.troons;
			var _loc5_:Number = _loc4_ / 200000;
			param2 += _loc5_;
			param3.hpBase = param3.hpBase * (100 + 8 * (param2 - 1)) / 100;
			param3.hpMax = param3.hpBase;
			param3.hp = param3.hpMax;
			param3.armorThresholdBase = param3.armorThresholdBase * (100 + 2.5 * 8 * (param2 - 1)) / 100;
			param3.shieldHpBase = param3.shieldHpBase * (100 + 8 * (param2 - 1)) / 100;
			param3.armorThreshold = param3.armorThresholdBase;
			param3.shieldHpMax = param3.shieldHpBase;
			param3.shieldHp = param3.shieldHpMax;
			param3.shieldRegenBase = param3.shieldRegenBase * (100 + 1 * (param2 - 1)) / 100;
			param3.shieldRegen = param3.shieldRegenBase;
		}
		
		private static function addLevelBonusToWeapon(param1:Game, param2:Number, param3:Weapon, param4:Player):void
		{
			if (param1.solarSystem.isPvpSystemInEditor)
			{
				param2 = 100;
			}
			var _loc5_:Number = param4.troons;
			var _loc6_:Number = _loc5_ / 200000;
			param2 += _loc6_;
			param3.dmg.addLevelBonus(param2, 8);
			if (param3.debuffValue != null)
			{
				param3.debuffValue.addLevelBonus(param2, 8);
				param3.debuffValue2.addLevelBonus(param2, 8);
			}
		}
		
		public static function createEnemy(param1:Game, param2:String, param3:int = 0):EnemyShip
		{
			var _loc7_:Number = NaN;
			var _loc6_:Random = null;
			var _loc8_:IDataManager = DataLocator.getService();
			var _loc5_:Object = _loc8_.loadKey("Enemies", param2);
			if (param1.isLeaving)
			{
				return null;
			}
			var _loc4_:EnemyShip = param1.shipManager.getEnemyShip();
			_loc4_.name = _loc5_.name;
			_loc4_.xp = _loc5_.xp;
			_loc4_.level = _loc5_.level;
			_loc4_.rareType = param3;
			_loc4_.aggroRange = _loc5_.aggroRange;
			_loc4_.chaseRange = _loc5_.chaseRange;
			_loc4_.observer = _loc5_.observer;
			if (_loc4_.observer)
			{
				_loc4_.visionRange = _loc5_.visionRange;
			}
			else
			{
				_loc4_.visionRange = _loc4_.aggroRange;
			}
			if (param1.isSystemTypeSurvival() && _loc4_.level < param1.hud.uberStats.uberLevel)
			{
				_loc7_ = param1.hud.uberStats.CalculateUberRankFromLevel(_loc4_.level);
				_loc4_.uberDifficulty = param1.hud.uberStats.CalculateUberDifficultyFromRank(param1.hud.uberStats.uberRank - _loc7_, _loc4_.level);
				_loc4_.uberLevelFactor = 1 + (param1.hud.uberStats.uberLevel - _loc4_.level) / 100;
				_loc4_.aggroRange *= _loc4_.uberLevelFactor;
				_loc4_.chaseRange *= _loc4_.uberLevelFactor;
				_loc4_.visionRange *= _loc4_.uberLevelFactor;
				_loc6_ = new Random(_loc4_.id);
				if (_loc4_.aggroRange > 2000)
				{
					_loc4_.aggroRange = 10000;
				}
				else if (param1.hud.uberStats.uberRank >= 9)
				{
					_loc4_.aggroRange = 3000 + _loc6_.random(10000);
				}
				else if (param1.hud.uberStats.uberRank >= 6)
				{
					_loc4_.aggroRange = 2000 + _loc6_.random(10000);
				}
				else if (param1.hud.uberStats.uberRank >= 3)
				{
					_loc4_.aggroRange = 1500 + _loc6_.random(10000);
				}
				else if (_loc4_.aggroRange < 3000)
				{
					_loc4_.aggroRange = 1000 + _loc6_.random(10000);
				}
				_loc4_.chaseRange = _loc4_.aggroRange;
				_loc4_.visionRange = _loc4_.aggroRange;
				_loc4_.xp *= _loc4_.uberLevelFactor;
				_loc4_.level = param1.hud.uberStats.uberLevel;
			}
			_loc4_.orbitSpawner = _loc5_.orbitSpawner;
			if (_loc4_.orbitSpawner)
			{
				_loc4_.hpRegen = _loc5_.hpRegen;
			}
			_loc4_.aimSkill = _loc5_.aimSkill;
			if (_loc5_.hasOwnProperty("stopWhenClose"))
			{
				_loc4_.stopWhenClose = _loc5_.stopWhenClose;
			}
			if (_loc5_.hasOwnProperty("AIFaction1") && _loc5_.AIFaction1 != "")
			{
				_loc4_.factions.push(_loc5_.AIFaction1);
			}
			if (_loc5_.hasOwnProperty("AIFaction2") && _loc5_.AIFaction2 != "")
			{
				_loc4_.factions.push(_loc5_.AIFaction2);
			}
			if (_loc5_.hasOwnProperty("teleport"))
			{
				_loc4_.teleport = _loc5_.teleport;
			}
			_loc4_.kamikaze = _loc5_.kamikaze;
			if (_loc4_.kamikaze)
			{
				_loc4_.kamikazeLifeTreshhold = _loc5_.kamikazeLifeTreshhold;
				_loc4_.kamikazeHoming = _loc5_.kamikazeHoming;
				_loc4_.kamikazeTtl = _loc5_.kamikazeTtl;
				_loc4_.kamikazeDmg = _loc5_.kamikazeDmg;
				_loc4_.kamikazeRadius = _loc5_.kamikazeRadius;
				_loc4_.kamikazeWhenClose = _loc5_.kamikazeWhenClose;
			}
			if (_loc5_.hasOwnProperty("alwaysFire"))
			{
				_loc4_.alwaysFire = _loc5_.alwaysFire;
			}
			else
			{
				_loc4_.alwaysFire = false;
			}
			_loc4_.forcedRotation = _loc5_.forcedRotation;
			if (_loc4_.forcedRotation)
			{
				_loc4_.forcedRotationSpeed = _loc5_.forcedRotationSpeed;
				_loc4_.forcedRotationAim = _loc5_.forcedRotationAim;
			}
			_loc4_.melee = _loc5_.melee;
			if (_loc4_.melee)
			{
				_loc4_.meleeCharge = _loc5_.charge;
				_loc4_.meleeChargeSpeedBonus = Number(_loc5_.chargeSpeedBonus) / 100;
				_loc4_.meleeChargeDuration = _loc5_.chargeDuration;
				_loc4_.meleeCanGrab = _loc5_.grab;
			}
			_loc4_.flee = _loc5_.flee;
			if (_loc4_.flee)
			{
				_loc4_.fleeLifeTreshhold = _loc5_.fleeLifeTreshhold;
				_loc4_.fleeDuration = _loc5_.fleeDuration;
				if (_loc5_.hasOwnProperty("fleeClose"))
				{
					_loc4_.fleeClose = _loc5_.fleeClose;
				}
				else
				{
					_loc4_.fleeClose = 0;
				}
			}
			_loc4_.aiCloak = false;
			if (_loc5_.hasOwnProperty("hardenShield"))
			{
				_loc4_.aiHardenShield = false;
				_loc4_.aiHardenShieldDuration = _loc5_.hardenShieldDuration;
			}
			else
			{
				_loc4_.aiHardenShield = false;
				_loc4_.aiHardenShieldDuration = 0;
			}
			if (_loc5_.hasOwnProperty("sniper"))
			{
				_loc4_.sniper = _loc5_.sniper;
				if (_loc4_.sniper)
				{
					_loc4_.sniperMinRange = _loc5_.sniperMinRange;
				}
			}
			_loc4_.isHostile = true;
			_loc4_.group = null;
			createBody(_loc5_.ship, param1, _loc4_);
			_loc4_.engine = EngineFactory.create(_loc5_.engine, param1, _loc4_);
			if (_loc4_.uberDifficulty > 0)
			{
				_loc4_.hp = _loc4_.hpMax *= _loc4_.uberDifficulty;
				_loc4_.shieldHp = _loc4_.shieldHpMax *= _loc4_.uberDifficulty;
				_loc4_.engine.speed *= _loc4_.uberLevelFactor;
				if (_loc4_.engine.speed > 380)
				{
					_loc4_.engine.speed = 380;
				}
			}
			if (param3 == 1)
			{
				_loc4_.hp = _loc4_.hpMax *= 3;
				_loc4_.shieldHp = _loc4_.shieldHpMax *= 3;
			}
			if (param3 == 4)
			{
				_loc4_.hp = _loc4_.hpMax *= 3;
				_loc4_.shieldHp = _loc4_.shieldHpMax *= 3;
				_loc4_.engine.speed *= 1.1;
			}
			if (param3 == 5)
			{
				_loc4_.color = 16746513;
				_loc4_.hp = _loc4_.hpMax *= 10;
				_loc4_.shieldHp = _loc4_.shieldHpMax *= 10;
				_loc4_.engine.speed *= 1.3;
			}
			if (param3 == 3)
			{
				_loc4_.engine.speed *= 1.4;
			}
			if (_loc5_.hasOwnProperty("startHp"))
			{
				_loc4_.hp = 0.01 * _loc5_.startHp * _loc4_.hp;
			}
			CreateEnemyShipWeapon(param1, 0, _loc5_.weapons, _loc4_);
			CreateEnemyShipExtraWeapon(param1, _loc4_.weapons.length, _loc5_.fleeWeaponItem, _loc4_, 0);
			CreateEnemyShipExtraWeapon(param1, _loc4_.weapons.length, _loc5_.antiProjectileWeaponItem, _loc4_, 1);
			if (!param1.isLeaving)
			{
				param1.shipManager.activateEnemyShip(_loc4_);
			}
			return _loc4_;
		}
		
		private static function CreateEnemyShipWeapon(param1:Game, param2:int, param3:Array, param4:EnemyShip):void
		{
			var _loc6_:Weapon = null;
			if (param3.length == 0)
			{
				return;
			}
			var _loc7_:Object = param3[param2];
			var _loc5_:Weapon = WeaponFactory.create(_loc7_.weapon, param1, param4, 0);
			param4.weaponRanges.push(new WeaponRange(_loc7_.minRange, _loc7_.maxRange));
			if (param2 < param4.weapons.length)
			{
				_loc6_ = param4.weapons[param2];
				param4.weapons[param2] = _loc5_;
				_loc6_.destroy();
			}
			else
			{
				param4.weapons.push(_loc5_);
			}
			if (param2 != param3.length - 1)
			{
				param2 += 1;
				CreateEnemyShipWeapon(param1, param2, param3, param4);
			}
		}
		
		private static function CreateEnemyShipExtraWeapon(param1:Game, param2:int, param3:Object, param4:EnemyShip, param5:int):void
		{
			var _loc7_:Weapon = null;
			if (param3 == null)
			{
				return;
			}
			var _loc6_:Weapon = WeaponFactory.create(param3.weapon, param1, param4, 0);
			param4.weaponRanges.push(new WeaponRange(0, 0));
			if (param5 == 0)
			{
				param4.escapeWeapon = _loc6_;
			}
			else
			{
				param4.antiProjectileWeapon = _loc6_;
			}
			if (param2 < param4.weapons.length)
			{
				_loc7_ = param4.weapons[param2];
				param4.weapons[param2] = _loc6_;
				_loc7_.destroy();
			}
			else
			{
				param4.weapons.push(_loc6_);
			}
		}
		
		public static function createBody(param1:String, param2:Game, param3:Unit):void
		{
			var _loc6_:IDataManager = DataLocator.getService();
			var _loc4_:Object = _loc6_.loadKey("Ships", param1);
			param3.switchTexturesByObj(_loc4_);
			if (_loc4_.blendModeAdd)
			{
				param3.movieClip.blendMode = "add";
			}
			param3.obj = _loc4_;
			param3.bodyName = _loc4_.name;
			param3.collisionRadius = _loc4_.collisionRadius;
			param3.hp = _loc4_.hp;
			param3.hpMax = _loc4_.hp;
			param3.shieldHp = _loc4_.shieldHp;
			param3.shieldHpMax = _loc4_.shieldHp;
			param3.armorThreshold = _loc4_.armor;
			param3.armorThresholdBase = _loc4_.armor;
			param3.shieldRegenBase = 1.5 * _loc4_.shieldRegen;
			param3.shieldRegen = param3.shieldRegenBase;
			if (param3 is Ship)
			{
				param3.enginePos.x = _loc4_.enginePosX;
				param3.enginePos.y = _loc4_.enginePosY;
				param3.weaponPos.x = _loc4_.weaponPosX;
				param3.weaponPos.y = _loc4_.weaponPosY;
			}
			else
			{
				param3 is Turret;
			}
			param3.weaponPos.x = _loc4_.weaponPosX;
			param3.weaponPos.y = _loc4_.weaponPosY;
			param3.explosionEffect = _loc4_.explosionEffect;
			param3.explosionSound = _loc4_.explosionSound;
			var _loc5_:ISound = SoundLocator.getService();
			if (param3.explosionSound != null)
			{
				_loc5_.preCacheSound(param3.explosionSound);
			}
		}
	}
}
