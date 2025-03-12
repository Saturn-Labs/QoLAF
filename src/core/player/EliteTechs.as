package core.player
{
	import core.hud.components.techTree.EliteTechBar;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.weapon.Beam;
	import core.weapon.Damage;
	import core.weapon.ProjectileGun;
	import core.weapon.Weapon;
	import generics.Localize;
	
	public class EliteTechs
	{
		public static const MAX_LEVEL:Number = 100;
		public static const COST_INCREASE:Number = 1.025;
		public static const COST_SUM:Number = 432.548654;
		public static const PRIMARY_COST_SUM:Number = 3200000;
		public static const SECONDARY_COST_SUM:Number = 540000;
		public static const FLUX_COST_SUM:Number = 12000;
		public static const HYDROGEN_CRYSTALS:String = "d6H3w_34pk2ghaQcXYBDag";
		public static const PLASMA_FLUIDS:String = "H5qybQDy9UindMh9yYIeqg";
		public static const IRIDIUM:String = "gO_f-y0QEU68vVwJ_XVmOg";
		public static const WEAPON_ELITE_TECHS:Vector.<String> = Vector.<String>(["AddKineticDamage", "AddEnergyDamage", "AddCorrosiveDamage", "AddKineticBaseDamage", "AddEnergyBaseDamage", "AddCorrosiveBaseDamage", "AddKineticDot5", "AddEnergyDot5", "AddCorrosiveDot5", "AddKineticDot10", "AddEnergyDot10", "AddCorrosiveDot10", "AddKineticDot20", "AddEnergyDot20", "AddCorrosiveDot20", "AddEnergyBurn", "AddCorrosiveBurn", "AddHealthVamp", "AddShieldVamp", "AddDualVamp", "KineticPenetration", "EnergyPenetration", "CorrosivePenetration", "AddExtraProjectiles", "IncreaseDirectDamage", "IncreaseDebuffDamage", "IncreaseRange", "IncreaseRefire", "IncreaseGuidance", "ReducePowerCost", "DisableHealing", "DisableShieldRegen", "ReduceTargetDamage", "ReduceTargetArmor", "IncreaseAOE", "AddAOE", "IncreaseNrHits", "IncreaseSpeed", "IncreasePetHp"]);
		
		public static const WEAPON_ELITE_TECHS_NAME:Vector.<String> = Vector.<String>(["Kinetic Damage", "Energy Damage", "Corrosive Damage", "Kinetic Damage", "Energy Damage", "Corrosive Damage", "Kinetic DoT 5 Seconds", "Energy DoT 5 Seconds", "Corrosive DoT 5 Seconds", "Kinetic DoT 10 Seconds", "Energy DoT 10 Seconds", "Corrosive DoT 10 Seconds", "Kinetic DoT 20 Seconds", "Energy DoT 20 Seconds", "Corrosive DoT 20 Seconds", "Energy Burn 10 Seconds", "Corrosive Burn 10 Seconds", "Health Leech", "Shield Leech", "Health and Shield Leech", "Reduce Kinetic Resitance", "Reduce Energy Resitance", "Reduce Corrosive Resitance", "Extra Projectiles", "Improved Direct Damage", "Improved DoT", "Improved Range", "Improved Attack Speed", "Improved Velocity and Guidance", "Reduced the Power Cost", "Disables target Healing", "Disables target Shield Regen", "Reduce Target Damage done", "Reduce Target Armor", "Improved Area Of Effect", "Improved Area Of Effect", "Improved Number of Hits", "Increase Speed", "Increase Pet HP and Shield"]);
		
		public static const ELITE_TECHS:Vector.<String> = Vector.<String>(["IncreaseShield", "IncreaseShieldRegen", "ConvertShield", "IncreaseHealth", "IncreaseArmor", "ConvertHealth", "IncreaseSheildDuration", "ReduceSheildCooldown", "IncreaseSpeedBoostAmount", "IncreaseSpeedBoostDuration", "ReduceSpeedBoostCooldown", "IncreaseArmorConvBonus", "ReduceArmorConvCooldown", "IncreaseDamage", "IncreaseRefire", "ReducePowerCost", "IncreaseDmgBoostDuration", "IncreaseDmgBoostBonus", "ReduceDmgBoostPowerCost", "IncreaseEngineSpeed", "UnbreakableArmor"]);
		
		public static const ELITE_TECHS_NAME:Vector.<String> = Vector.<String>(["Maximum Shield", "Shield Regen", "Convert Shield", "Maximum Health", "Improved Armor", "Convert Health", "Lasting Harden Shields", "Rapid Recharge Harden Sheilds", "Overcharged Speed Boost", "Lasting Speed Boost", "Rapid Recharge Speed Boost", "Optimized Repair", "Rapid Recharge Repair", "Over-Charged Weapons", "Hyper-Charged Weapons", "Optimized Weapons", "Lasting Power Boost", "Super Charged Power Boost", "Optimized Power Boost", "Improved Engines", "Unbreakable Armor"]);
		
		public function EliteTechs()
		{
			super();
		}
		
		public static function getStatTextByLevel(param1:String, param2:Object, param3:Number):String
		{
			var _loc4_:Number = NaN;
			var _loc8_:Number = NaN;
			var _loc9_:Object = null;
			var _loc11_:int = 0;
			var _loc6_:* = NaN;
			var _loc5_:String = "";
			if (!param2.hasOwnProperty("eliteTechs"))
			{
				return _loc5_;
			}
			var _loc10_:Object = param2.eliteTechs;
			if (!_loc10_.hasOwnProperty(param1))
			{
				return _loc5_;
			}
			var _loc12_:Number = Number(_loc10_[param1]);
			var _loc7_:Number = _loc12_ * param3 / 100;
			switch (param1)
			{
			case "AddKineticDamage": 
				_loc5_ += Localize.t("Adds extra [value]% Kinetic Damage").replace("[value]", _loc7_.toFixed(2));
				break;
			case "AddEnergyDamage": 
				_loc5_ += Localize.t("Adds extra [value]% Energy Damage").replace("[value]", _loc7_.toFixed(2));
				break;
			case "AddCorrosiveDamage": 
				_loc5_ += Localize.t("Adds extra [value]% Corrosive Damage").replace("[value]", _loc7_.toFixed(2));
				break;
			case "AddKineticBaseDamage": 
				_loc5_ += Localize.t("Adds extra [value] Kinetic Damage").replace("[value]", _loc7_.toFixed(2));
				break;
			case "AddEnergyBaseDamage": 
				_loc5_ += Localize.t("Adds extra [value] Energy Damage").replace("[value]", _loc7_.toFixed(2));
				break;
			case "AddCorrosiveBaseDamage": 
				_loc5_ += Localize.t("Adds extra [value] Corrosive Damage").replace("[value]", _loc7_.toFixed(2));
				break;
			case "AddKineticDot5": 
				_loc5_ += Localize.t("Adds extra [value]% Kinetic Damage over 5 Seconds").replace("[value]", _loc7_.toFixed(2));
				break;
			case "AddEnergyDot5": 
				_loc5_ += Localize.t("Adds extra [value]% Energy Damage over 5 Seconds").replace("[value]", _loc7_.toFixed(2));
				break;
			case "AddCorrosiveDot5": 
				_loc5_ += Localize.t("Adds extra [value]% Corrosive Damage over 5 Seconds").replace("[value]", _loc7_.toFixed(2));
				break;
			case "AddKineticDot10": 
				_loc5_ += Localize.t("Adds extra [value]% Kinetic Damage over 10 Seconds").replace("[value]", _loc7_.toFixed(2));
				break;
			case "AddEnergyDot10": 
				_loc5_ += Localize.t("Adds extra [value]% Energy Damage over 10 Seconds").replace("[value]", _loc7_.toFixed(2));
				break;
			case "AddCorrosiveDot10": 
				_loc5_ += Localize.t("Adds extra [value]% Corrosive Damage over 10 Seconds").replace("[value]", _loc7_.toFixed(2));
				break;
			case "AddKineticDot20": 
				_loc5_ += Localize.t("Adds extra [value]% Kinetic Damage over 20 Seconds").replace("[value]", _loc7_.toFixed(2));
				break;
			case "AddEnergyDot20": 
				_loc5_ += Localize.t("Adds extra [value]% Energy Damage over 20 Seconds").replace("[value]", _loc7_.toFixed(2));
				break;
			case "AddCorrosiveDot20": 
				_loc5_ += Localize.t("Adds extra [value]% Corrosive Damage over 20 Seconds").replace("[value]", _loc7_.toFixed(2));
				break;
			case "AddEnergyBurn": 
				_loc5_ += Localize.t("Adds extra [value]% Energy Burn Damage over 10 Seconds").replace("[value]", _loc7_.toFixed(2));
				break;
			case "AddCorrosiveBurn": 
				_loc5_ += Localize.t("Adds extra [value]% Corrosive Burn Damage over 10 Seconds").replace("[value]", _loc7_.toFixed(2));
				break;
			case "AddHealthVamp": 
				_loc5_ += Localize.t("Steals [value]% of Health Damage done to targets").replace("[value]", _loc7_.toFixed(2));
				break;
			case "AddShieldVamp": 
				_loc5_ += Localize.t("Steals [value]% of Shield Damage done to targets").replace("[value]", _loc7_.toFixed(2));
				break;
			case "AddDualVamp": 
				_loc5_ += Localize.t("Steals [value]% of Health Damage done to targets\n").replace("[value]", _loc7_.toFixed(2));
				_loc5_ = _loc5_ + Localize.t("Steals [value]% of Shield Damage done to targets").replace("[value]", _loc7_.toFixed(2));
				break;
			case "KineticPenetration": 
				_loc5_ += Localize.t("Reduces targets Kinetic Resistance by [value]% for [value2] Seconds").replace("[value]", _loc7_.toFixed(2)).replace("[value2]", (5 + 5 * param3 / 100).toFixed(1));
				break;
			case "EnergyPenetration": 
				_loc5_ += Localize.t("Reduces targets Energy Resistance by [value]% for [value2] Seconds").replace("[value]", _loc7_.toFixed(2)).replace("[value2]", (5 + 5 * param3 / 100).toFixed(1));
				break;
			case "CorrosivePenetration": 
				_loc5_ += Localize.t("Reduces targets Corrosive Resistance by [value]% for [value2] Seconds").replace("[value]", _loc7_.toFixed(2)).replace("[value2]", (5 + 5 * param3 / 100).toFixed(1));
				break;
			case "AddExtraProjectiles": 
				_loc4_ = param3 / 100;
				_loc8_ = Number(param2.multiNrOfP);
				_loc11_ = 0;
				while (_loc11_ < 6)
				{
					_loc9_ = param2.techLevels[_loc11_];
					_loc8_ += _loc9_.incMultiNrOfP;
					_loc11_++;
				}
				_loc6_ = _loc8_;
				if (_loc8_ == 1)
				{
					if (_loc4_ < 0.5)
					{
						_loc8_ = 2;
					}
					else if (_loc4_ >= 0.5)
					{
						_loc8_ = 3;
					}
				}
				else
				{
					_loc8_ += int(Math.floor(_loc4_ * _loc8_));
				}
				_loc4_ = _loc6_ / _loc8_;
				_loc7_ = Math.abs(_loc4_ * (100 + _loc7_) - 100);
				_loc5_ += Localize.t("Adds [value2] extra projectiles, each projectile deals [value]% less damage").replace("[value]", _loc7_.toFixed(2)).replace("[value2]", _loc8_ - _loc6_);
				break;
			case "IncreaseDirectDamage": 
				_loc5_ += Localize.t("Increases Direct Damage by [value]%").replace("[value]", _loc7_.toFixed(2));
				break;
			case "IncreaseDebuffDamage": 
				_loc5_ += Localize.t("Increases Debuff Damage by [value]%").replace("[value]", _loc7_.toFixed(2));
				break;
			case "IncreaseRange": 
				_loc5_ += Localize.t("Increases Range by [value]%").replace("[value]", _loc7_.toFixed(2));
				break;
			case "IncreaseRefire": 
				if (param2.name == "Teleport Device" || param2.name == "Bionic Teleport" || param2.name == "Cloaking Device")
				{
					_loc5_ += Localize.t("Reduce cooldown by [value]%").replace("[value]", _loc7_.toFixed(2));
				}
				else
				{
					_loc5_ += Localize.t("Increases Attack Speed by [value]%").replace("[value]", _loc7_.toFixed(2));
				}
				break;
			case "IncreaseGuidance": 
				_loc5_ += Localize.t("Improves Guidance by [value]%\n").replace("[value]", _loc7_.toFixed(2));
				_loc5_ = _loc5_ + Localize.t("Improves Velocity by [value]%").replace("[value]", (0.1 * _loc7_).toFixed(2));
				break;
			case "ReducePowerCost": 
				_loc5_ += Localize.t("Reduce Power Cost by [value]%").replace("[value]", _loc7_.toFixed(2));
				break;
			case "DisableHealing": 
				_loc5_ += Localize.t("Disables targets from Healing for [value] seconds").replace("[value]", (1 + _loc7_).toFixed(2));
				break;
			case "DisableShieldRegen": 
				_loc5_ += Localize.t("Disables targets Shield Regen for [value] seconds").replace("[value]", (1 + _loc7_).toFixed(2));
				break;
			case "ReduceTargetDamage": 
				_loc5_ += Localize.t("Reduces targets Damage by [value]% for  Seconds").replace("[value]", _loc7_.toFixed(2)).replace("[value2]", (5 + 5 * param3 / 100).toFixed(2));
				break;
			case "ReduceTargetArmor": 
				_loc5_ += Localize.t("Reduces targets Armor by [value]% of weapon damage for [value2] Seconds").replace("[value]", _loc7_.toFixed(2)).replace("[value2]", (5 + 5 * param3 / 100).toFixed(2));
				break;
			case "IncreaseShield": 
				_loc5_ += Localize.t("Increases Shield by [value]%").replace("[value]", _loc7_.toFixed(2));
				break;
			case "IncreaseShieldRegen": 
				_loc5_ += Localize.t("Increases Shield Regeneration by [value]%").replace("[value]", _loc7_.toFixed(2));
				break;
			case "ConvertShield": 
				_loc5_ += Localize.t("Sacrifice [value]% Maximum Shield to regen [value2]% of Maximum Health Regen every second").replace("[value]", _loc7_.toFixed(2)).replace("[value2]", (0.06 * _loc7_).toFixed(2));
				break;
			case "IncreaseHealth": 
				_loc5_ += Localize.t("Increases Health by [value]%").replace("[value]", _loc7_.toFixed(2));
				break;
			case "IncreaseArmor": 
				_loc5_ += Localize.t("Increases Armor by [value]%").replace("[value]", _loc7_.toFixed(2));
				break;
			case "ConvertHealth": 
				_loc5_ += Localize.t("Sacrifice [value]% Maximum Health to increase Shield Regen by [value2]%").replace("[value]", _loc7_.toFixed(2)).replace("[value2]", (3 * _loc7_).toFixed(2));
				break;
			case "IncreaseSheildDuration": 
				_loc5_ += Localize.t("Increases the Duration of Harden Shield by [value]%").replace("[value]", _loc7_.toFixed(2));
				break;
			case "ReduceSheildCooldown": 
				_loc5_ += Localize.t("Decreases the Cooldown of Harden Shield by [value]%").replace("[value]", _loc7_.toFixed(2));
				break;
			case "IncreaseSpeedBoostAmount": 
				_loc5_ += Localize.t("Increases the Bonus Speed gained by Speed Boost by [value]%").replace("[value]", _loc7_.toFixed(2));
				break;
			case "IncreaseSpeedBoostDuration": 
				_loc5_ += Localize.t("Increases the Duration of Speed Boost by [value]%").replace("[value]", _loc7_.toFixed(2));
				break;
			case "ReduceSpeedBoostCooldown": 
				_loc5_ += Localize.t("Decreases the Cooldown of Speed Boost by [value]%").replace("[value]", _loc7_.toFixed(2));
				break;
			case "IncreaseArmorConvBonus": 
				_loc5_ += Localize.t("Increases the Amount of Health gained by Convert by [value]%").replace("[value]", _loc7_.toFixed(2));
				break;
			case "ReduceArmorConvCooldown": 
				_loc5_ += Localize.t("Decreases the Cooldown of Convert by [value]%").replace("[value]", _loc7_.toFixed(2));
				break;
			case "IncreaseDamage": 
				_loc5_ += Localize.t("Increases Damage done by all Weapons by [value]%").replace("[value]", _loc7_.toFixed(2));
				break;
			case "IncreaseRefire": 
				_loc5_ += Localize.t("Increases Attack Speed for all Weapons by [value]%").replace("[value]", _loc7_.toFixed(2));
				break;
			case "ReducePowerCost": 
				_loc5_ += Localize.t("Reduces Power Cost of all Weapons by [value]%").replace("[value]", _loc7_.toFixed(2));
				break;
			case "IncreaseDmgBoostDuration": 
				_loc5_ += Localize.t("Increases the Duration of Damage Boost by [value]%").replace("[value]", _loc7_.toFixed(2));
				break;
			case "IncreaseDmgBoostBonus": 
				_loc5_ += Localize.t("Increases the Damage Bonus gained from Damage Boost by [value]%").replace("[value]", _loc7_.toFixed(2));
				break;
			case "ReduceDmgBoostPowerCost": 
				_loc5_ += Localize.t("Reduces the Power Penalty of Damage Boost by [value]%").replace("[value]", _loc7_.toFixed(2));
				break;
			case "IncreaseAOE": 
				_loc5_ += Localize.t("Increases area of effect radius by [value]%").replace("[value]", _loc7_.toFixed(2));
				break;
			case "AddAOE": 
				_loc5_ += Localize.t("Increases area of effect radius by [value] units").replace("[value]", (5 + _loc7_).toFixed(2));
				break;
			case "IncreaseNrHits": 
				_loc5_ += Localize.t("Increases Number of Hits by [value]").replace("[value]", int(1 + _loc7_));
				break;
			case "IncreaseSpeed": 
				if (param2.name == "Teleport Device" || param2.name == "Bionic Teleport")
				{
					_loc5_ += Localize.t("Increases Cast Speed by [value]%").replace("[value]", _loc7_.toFixed(2));
				}
				else
				{
					_loc5_ += Localize.t("Increases Speed by [value]%").replace("[value]", _loc7_.toFixed(2));
				}
				break;
			case "IncreasePetHp": 
				_loc5_ += Localize.t("Increases Pet HP and Shield by [value]%").replace("[value]", _loc7_.toFixed(2));
			case "IncreaseEngineSpeed": 
				_loc5_ += Localize.t("Increases Engine Speed by [value]%").replace("[value]", _loc7_.toFixed(2));
				break;
			case "UnbreakableArmor": 
				_loc5_ += Localize.t("Armor can not be reduced below [value]% of maximum").replace("[value]", _loc7_.toFixed(2));
			}
			return _loc5_ + "\n";
		}
		
		public static function addWeaponEliteTechs(param1:Weapon, param2:Object, param3:int, param4:String):void
		{
			var _loc5_:Number = NaN;
			var _loc7_:Number = NaN;
			var _loc6_:Beam = null;
			if (!param2.hasOwnProperty("eliteTechs"))
			{
				return;
			}
			var _loc9_:Object = param2.eliteTechs;
			if (!_loc9_.hasOwnProperty(param4))
			{
				return;
			}
			var _loc10_:Number = Number(_loc9_[param4]);
			var _loc8_:Number = _loc10_ * param3 / 100;
			if (_loc10_ == 0)
			{
				return;
			}
			switch (param4)
			{
			case "AddKineticDamage": 
				param1.dmg.addBaseDmg(0.01 * _loc8_ * param1.dmg.dmg(), 0);
				break;
			case "AddEnergyDamage": 
				param1.dmg.addBaseDmg(0.01 * _loc8_ * param1.dmg.dmg(), 1);
				break;
			case "AddCorrosiveDamage": 
				param1.dmg.addBaseDmg(0.01 * _loc8_ * param1.dmg.dmg(), 2);
				break;
			case "AddKineticBaseDamage": 
				param1.dmg.addBaseDmg(_loc8_, 0);
				break;
			case "AddEnergyBaseDamage": 
				param1.dmg.addBaseDmg(_loc8_, 1);
				break;
			case "AddCorrosiveBaseDamage": 
				param1.dmg.addBaseDmg(_loc8_, 2);
				break;
			case "AddKineticDot5": 
				param1.addDebuff(0, 5, new Damage(0.01 * _loc8_ * param1.dmg.dmg() / 5, 0), "Tk7JFixDAkuw6mB-BLXQwg");
				break;
			case "AddEnergyDot5": 
				param1.addDebuff(0, 5, new Damage(0.01 * _loc8_ * param1.dmg.dmg() / 5, 1), "9kIM0A-0d0uPHMjJ1qg5pg");
				break;
			case "AddCorrosiveDot5": 
				param1.addDebuff(0, 5, new Damage(0.01 * _loc8_ * param1.dmg.dmg() / 5, 2), "U4WOoDzOV0iXNmVwM3SELA");
				break;
			case "AddKineticDot10": 
				param1.addDebuff(0, 10, new Damage(0.01 * _loc8_ * param1.dmg.dmg() / 10, 0), "Tk7JFixDAkuw6mB-BLXQwg");
				break;
			case "AddEnergyDot10": 
				param1.addDebuff(0, 10, new Damage(0.01 * _loc8_ * param1.dmg.dmg() / 10, 1), "9kIM0A-0d0uPHMjJ1qg5pg");
				break;
			case "AddCorrosiveDot10": 
				param1.addDebuff(0, 10, new Damage(0.01 * _loc8_ * param1.dmg.dmg() / 10, 2), "U4WOoDzOV0iXNmVwM3SELA");
				break;
			case "AddKineticDot20": 
				param1.addDebuff(0, 20, new Damage(0.01 * _loc8_ * param1.dmg.dmg() / 20, 0), "Tk7JFixDAkuw6mB-BLXQwg");
				break;
			case "AddEnergyDot20": 
				param1.addDebuff(0, 20, new Damage(0.01 * _loc8_ * param1.dmg.dmg() / 20, 1), "9kIM0A-0d0uPHMjJ1qg5pg");
				break;
			case "AddCorrosiveDot20": 
				param1.addDebuff(0, 20, new Damage(0.01 * _loc8_ * param1.dmg.dmg() / 20, 2), "U4WOoDzOV0iXNmVwM3SELA");
				break;
			case "AddEnergyBurn": 
				param1.addDebuff(4, 10, new Damage(0.002 * _loc8_ * param1.dmg.dmg(), 1), "7XV2cuSPJ0erabUgynivBA");
				break;
			case "AddCorrosiveBurn": 
				param1.addDebuff(4, 10, new Damage(0.002 * _loc8_ * param1.dmg.dmg(), 2), "U4WOoDzOV0iXNmVwM3SELA");
				break;
			case "AddHealthVamp": 
				param1.healthVamp += _loc8_;
				break;
			case "AddShieldVamp": 
				param1.shieldVamp += _loc8_;
				break;
			case "AddDualVamp": 
				param1.healthVamp += _loc8_;
				param1.shieldVamp += _loc8_;
				break;
			case "KineticPenetration": 
				param1.addDebuff(8, 5 + 5 * param3 / 100, new Damage(_loc8_, 8), "Tk7JFixDAkuw6mB-BLXQwg");
				break;
			case "EnergyPenetration": 
				param1.addDebuff(9, 5 + 5 * param3 / 100, new Damage(_loc8_, 8), "9kIM0A-0d0uPHMjJ1qg5pg");
				break;
			case "CorrosivePenetration": 
				param1.addDebuff(10, 5 + 5 * param3 / 100, new Damage(_loc8_, 8), "U4WOoDzOV0iXNmVwM3SELA");
				break;
			case "AddExtraProjectiles": 
				_loc5_ = param3 / 100;
				if (_loc5_ == 0)
				{
					return;
				}
				_loc7_ = param1.multiNrOfP;
				if (param1.multiNrOfP == 1)
				{
					if (_loc5_ < 0.5)
					{
						param1.multiNrOfP = 2;
						param1.multiOffset += 10;
					}
					else if (_loc5_ >= 0.5)
					{
						param1.multiNrOfP = 3;
						param1.multiOffset += 15;
					}
				}
				else
				{
					param1.multiNrOfP += int(Math.floor(_loc5_ * param1.multiNrOfP));
				}
				_loc5_ = _loc7_ / param1.multiNrOfP;
				param1.maxProjectiles = param1.multiNrOfP / _loc7_ * param1.maxProjectiles;
				param1.dmg.addBasePercent(_loc5_ * (100 + _loc8_) - 100);
				param1.debuffValue.addBasePercent(_loc5_ * (100 + _loc8_) - 100);
				param1.debuffValue2.addBasePercent(_loc5_ * (100 + _loc8_) - 100);
				_loc5_ = 1 / _loc5_;
				param1.multiAngleOffset += param1.multiAngleOffset * 0.5 * _loc5_;
				param1.multiOffset += param1.multiOffset * 0.5 * _loc5_;
				if (param1 is ProjectileGun)
				{
					param1.heatCost = param1.heatCost / param1.multiNrOfP * _loc7_;
				}
				break;
			case "IncreaseDirectDamage": 
				param1.dmg.addBasePercent(_loc8_, 0);
				param1.dmg.addBasePercent(_loc8_, 1);
				param1.dmg.addBasePercent(_loc8_, 2);
				param1.dmg.addBasePercent(_loc8_, 6);
				break;
			case "IncreaseDebuffDamage": 
				if (param1.debuffValue.dmg() > 0)
				{
					param1.debuffValue.addBasePercent(_loc8_, 0);
					param1.debuffValue.addBasePercent(_loc8_, 1);
					param1.debuffValue.addBasePercent(_loc8_, 2);
					param1.debuffValue.addBasePercent(_loc8_, 6);
				}
				if (param1.debuffValue2.dmg() > 0)
				{
					param1.debuffValue2.addBasePercent(_loc8_, 0);
					param1.debuffValue2.addBasePercent(_loc8_, 1);
					param1.debuffValue2.addBasePercent(_loc8_, 2);
					param1.debuffValue2.addBasePercent(_loc8_, 6);
				}
				break;
			case "IncreaseRange": 
				param1.range += int(param1.range * 0.01 * _loc8_);
				param1.ttl += int(param1.ttl * 0.01 * _loc8_);
				break;
			case "IncreaseRefire": 
				param1.reloadTime -= param1.reloadTime * 0.01 * _loc8_;
				param1.heatCost -= param1.heatCost * 0.01 * _loc8_;
				break;
			case "IncreaseGuidance": 
				param1.rotationSpeed += param1.rotationSpeed * 0.01 * _loc8_;
				param1.acceleration += param1.acceleration * 0.01 * _loc8_;
				param1.speed += param1.speed * 0.002 * _loc8_;
				break;
			case "ReducePowerCost": 
				param1.heatCost -= param1.heatCost * 0.01 * _loc8_;
				break;
			case "DisableHealing": 
				param1.addDebuff(6, 1 + _loc8_, new Damage(0, 8), "jvcmRezjZUKQUuhAlhhCqw");
				break;
			case "DisableShieldRegen": 
				param1.addDebuff(5, 1 + _loc8_, new Damage(0, 8), "jvcmRezjZUKQUuhAlhhCqw");
				break;
			case "ReduceTargetDamage": 
				param1.addDebuff(7, 5 + 5 * param3 / 100, new Damage(_loc8_, 8), "xYk7ubyao0uh8j9SDJYeWw");
				break;
			case "ReduceTargetArmor": 
				param1.addDebuff(3, 5 + 5 * param3 / 100, new Damage(0.01 * _loc8_ * param1.dmg.dmg(), param1.dmg.type), "Tk7JFixDAkuw6mB-BLXQwg");
				break;
			case "IncreaseAOE": 
				param1.dmgRadius += int(0.01 * _loc8_ * param1.dmgRadius);
				break;
			case "AddAOE": 
				param1.dmgRadius += int(5 + _loc8_);
				break;
			case "IncreaseNrHits": 
				if (param1 is Beam)
				{
					_loc6_ = param1 as Beam;
					_loc6_.nrTargets = _loc6_.nrTargets + (int(1 + _loc8_));
				}
				else
				{
					param1.numberOfHits += int(1 + _loc8_);
				}
			case "IncreaseSpeed": 
				param1.speed += 0.01 * _loc8_ * param1.speed;
				break;
			case "IncreasePetHp": 
			}
		}
		
		public static function addEliteTechs(param1:PlayerShip, param2:Object, param3:int, param4:String):void
		{
			if (!param2.hasOwnProperty("eliteTechs"))
			{
				return;
			}
			var _loc7_:Object = param2.eliteTechs;
			if (!_loc7_.hasOwnProperty(param4))
			{
				return;
			}
			var _loc8_:Number = Number(_loc7_[param4]);
			var _loc6_:Number = _loc8_ * param3 / 100;
			if (_loc8_ == 0)
			{
				return;
			}
			switch (param4)
			{
			case "IncreaseShield": 
				param1.shieldHpBase += 0.01 * _loc6_ * param1.shieldHpBase;
				param1.shieldHpMax = param1.shieldHpBase;
				param1.shieldHp = param1.shieldHpBase;
				break;
			case "IncreaseShieldRegen": 
				param1.shieldRegenBase += 0.01 * _loc6_ * param1.shieldRegenBase;
				param1.shieldRegen = param1.shieldRegenBase;
				break;
			case "ConvertShield": 
				param1.hpRegen = 0.0006 * _loc6_;
				param1.shieldHpBase -= 0.01 * _loc6_ * param1.shieldHpBase;
				if (param1.shieldHpBase < 1)
				{
					param1.shieldHpBase = 1;
				}
				param1.shieldHpMax = param1.shieldHpBase;
				param1.shieldHp = param1.shieldHpBase;
				break;
			case "IncreaseHealth": 
				param1.hpBase += 0.01 * _loc6_ * param1.hpBase;
				param1.hpMax = param1.hpBase;
				param1.hp = param1.hpBase;
				break;
			case "IncreaseArmor": 
				param1.armorThresholdBase += 0.01 * _loc6_ * param1.armorThresholdBase;
				param1.armorThreshold = param1.armorThresholdBase;
				break;
			case "ConvertHealth": 
				param1.shieldRegenBase += 0.03 * _loc6_ * param1.shieldRegenBase;
				param1.shieldRegen = param1.shieldRegenBase;
				param1.hpBase -= 0.01 * _loc6_ * param1.hpBase;
				if (param1.hpBase < 1)
				{
					param1.hpBase = 1;
				}
				param1.hpMax = param1.hpBase;
				param1.hp = param1.hpBase;
				break;
			case "IncreaseSheildDuration": 
				param1.hardenDuration += 0.01 * _loc6_ * param1.hardenDuration;
				break;
			case "ReduceSheildCooldown": 
				param1.hardenCD -= Math.round(0.01 * _loc6_ * param1.hardenCD);
				break;
			case "IncreaseSpeedBoostAmount": 
				param1.boostBonus += 0.01 * _loc6_ * param1.boostBonus;
				break;
			case "IncreaseSpeedBoostDuration": 
				param1.boostDuration += 0.01 * _loc6_ * param1.boostDuration;
				break;
			case "ReduceSpeedBoostCooldown": 
				param1.boostCD -= Math.round(0.01 * _loc6_ * param1.boostCD);
				break;
			case "IncreaseArmorConvBonus": 
				param1.convGain += 0.01 * _loc6_ * param1.convGain;
				break;
			case "ReduceArmorConvCooldown": 
				param1.convCD -= Math.round(0.01 * _loc6_ * param1.convCD);
				break;
			case "IncreaseDamage": 
				for each (var _loc5_:* in param1.weapons)
				{
					_loc5_.dmg.addBasePercent(_loc6_);
					_loc5_.debuffValue.addBasePercent(_loc6_);
					_loc5_.debuffValue2.addBasePercent(_loc6_);
				}
				break;
			case "IncreaseRefire": 
				for each (_loc5_ in param1.weapons)
				{
					_loc5_.reloadTime -= _loc5_.reloadTime * 0.01 * _loc6_;
					_loc5_.heatCost -= _loc5_.heatCost * 0.01 * _loc6_;
				}
				break;
			case "ReducePowerCost": 
				for each (_loc5_ in param1.weapons)
				{
					_loc5_.heatCost -= _loc5_.heatCost * 0.01 * _loc6_;
				}
				break;
			case "IncreaseDmgBoostDuration": 
				param1.dmgBoostDuration += 0.01 * _loc6_ * param1.dmgBoostDuration;
				break;
			case "IncreaseDmgBoostBonus": 
				param1.dmgBoostBonus += 0.01 * _loc6_ * param1.dmgBoostBonus;
				break;
			case "ReduceDmgBoostPowerCost": 
				param1.dmgBoostCost -= 0.01 * _loc6_ * param1.dmgBoostCost;
				break;
			case "IncreaseEngineSpeed": 
				param1.engine.speed += param1.engine.speed * 0.01 * _loc6_;
				break;
			case "UnbreakableArmor": 
			}
		}
		
		private static function getDescription(param1:String, param2:int, param3:Object):String
		{
			var _loc4_:String = "";
			if (param2 < 1)
			{
				param2 = 1;
			}
			if (param2 < 100)
			{
				_loc4_ += "<FONT COLOR='#88ff88'>" + Localize.t("Level") + ": " + param2 + " " + Localize.t("Bonus") + ":</FONT>\n";
				_loc4_ = _loc4_ + getStatTextByLevel(param1, param3, param2);
				_loc4_ = _loc4_ + ("<FONT COLOR='#88ff88'>" + Localize.t("Bonus at level") + " " + (param2 + 1).toString() + ":</FONT>\n");
				_loc4_ = _loc4_ + (getStatTextByLevel(param1, param3, param2 + 1) + "\n");
			}
			else
			{
				_loc4_ += "<FONT COLOR='#88ff88'>" + Localize.t("Level") + ": " + param2 + " " + Localize.t("Bonus") + ":</FONT>\n";
				_loc4_ = _loc4_ + (getStatTextByLevel(param1, param3, param2) + "\n");
			}
			return _loc4_;
		}
		
		public static function getIconName(param1:String):String
		{
			var _loc2_:String = null;
			switch (param1)
			{
			case "AddKineticDamage": 
				_loc2_ = "ti2_kinetic_dmg";
				break;
			case "AddEnergyDamage": 
				_loc2_ = "ti2_energy_dmg";
				break;
			case "AddCorrosiveDamage": 
				_loc2_ = "ti2_corrosive_dmg";
				break;
			case "AddKineticBaseDamage": 
				_loc2_ = "ti2_kinetic_base_dmg";
				break;
			case "AddEnergyBaseDamage": 
				_loc2_ = "ti2_energy_base_dmg";
				break;
			case "AddCorrosiveBaseDamage": 
				_loc2_ = "ti2_corrosive_base_dmg";
				break;
			case "AddKineticDot5": 
				_loc2_ = "ti2_kinetic_dot5";
				break;
			case "AddEnergyDot5": 
				_loc2_ = "ti2_energy_dot5";
				break;
			case "AddCorrosiveDot5": 
				_loc2_ = "ti2_corrosive_dot5";
				break;
			case "AddKineticDot10": 
				_loc2_ = "ti2_kinetic_dot10";
				break;
			case "AddEnergyDot10": 
				_loc2_ = "ti2_energy_dot10";
				break;
			case "AddCorrosiveDot10": 
				_loc2_ = "ti2_corrosive_dot10";
				break;
			case "AddKineticDot20": 
				_loc2_ = "ti2_kinetic_dot20";
				break;
			case "AddEnergyDot20": 
				_loc2_ = "ti2_energy_dot20";
				break;
			case "AddCorrosiveDot20": 
				_loc2_ = "ti2_corrosive_dot20";
				break;
			case "AddEnergyBurn": 
				_loc2_ = "ti2_energy_burn";
				break;
			case "AddCorrosiveBurn": 
				_loc2_ = "ti2_corrosive_burn";
				break;
			case "AddHealthVamp": 
				_loc2_ = "ti2_vamp_health";
				break;
			case "AddShieldVamp": 
				_loc2_ = "ti2_vamp_shield";
				break;
			case "AddDualVamp": 
				_loc2_ = "ti2_vamp_all";
				break;
			case "KineticPenetration": 
				_loc2_ = "ti2_pen_kinetic";
				break;
			case "EnergyPenetration": 
				_loc2_ = "ti2_pen_energy";
				break;
			case "CorrosivePenetration": 
				_loc2_ = "ti2_pen_corrosive";
				break;
			case "AddExtraProjectiles": 
				_loc2_ = "ti2_add_projectile";
				break;
			case "IncreaseDirectDamage": 
				_loc2_ = "ti2_increase_dmg";
				break;
			case "IncreaseDebuffDamage": 
				_loc2_ = "ti2_increase_dot";
				break;
			case "IncreaseRange": 
				_loc2_ = "ti2_increase_range";
				break;
			case "IncreaseRefire": 
				_loc2_ = "ti2_increase_fire_rate";
				break;
			case "IncreaseGuidance": 
				_loc2_ = "ti2_increase_guidance";
				break;
			case "ReducePowerCost": 
				_loc2_ = "ti2_power_reduce_cost";
				break;
			case "DisableHealing": 
				_loc2_ = "ti2_disable_healing";
				break;
			case "DisableShieldRegen": 
				_loc2_ = "ti2_disable_shield_regen";
				break;
			case "ReduceTargetDamage": 
				_loc2_ = "ti2_decrease_dmg";
				break;
			case "ReduceTargetArmor": 
				_loc2_ = "ti2_pen_armor";
				break;
			case "IncreaseAOE": 
				_loc2_ = "ti2_increase_area_dmg_radius";
				break;
			case "AddAOE": 
				_loc2_ = "ti2_increase_area_dmg_radius";
				break;
			case "IncreaseNrHits": 
				_loc2_ = "ti2_increase_nr_of_hits";
			case "IncreaseShield": 
				_loc2_ = "ti2_shield_increase";
				break;
			case "IncreaseShieldRegen": 
				_loc2_ = "ti2_shield_increase_regen";
				break;
			case "ConvertShield": 
				_loc2_ = "ti2_shield_convert";
				break;
			case "IncreaseHealth": 
				_loc2_ = "ti2_armor_increase_health";
				break;
			case "IncreaseArmor": 
				_loc2_ = "ti2_armor_increase";
				break;
			case "ConvertHealth": 
				_loc2_ = "ti2_armor_convert_health";
				break;
			case "IncreaseSheildDuration": 
				_loc2_ = "ti2_shield_duration";
				break;
			case "ReduceSheildCooldown": 
				_loc2_ = "ti2_shield_cooldown";
				break;
			case "IncreaseSpeedBoostAmount": 
				_loc2_ = "ti2_speed_increase";
				break;
			case "IncreaseSpeedBoostDuration": 
				_loc2_ = "ti2_speed_increase";
				break;
			case "ReduceSpeedBoostCooldown": 
				_loc2_ = "ti2_speed_cooldown";
				break;
			case "IncreaseArmorConvBonus": 
				_loc2_ = "ti2_armor_increase_convert_bonus";
				break;
			case "ReduceArmorConvCooldown": 
				_loc2_ = "ti2_armor_cooldown";
				break;
			case "IncreaseDamage": 
				_loc2_ = "ti2_increase_dmg";
				break;
			case "IncreaseRefire": 
				_loc2_ = "ti2_increase_fire_rate";
				break;
			case "ReducePowerCost": 
				_loc2_ = "ti2_power_reduce_cost";
				break;
			case "IncreaseDmgBoostDuration": 
				_loc2_ = "ti2_power_boost_duration";
				break;
			case "IncreaseDmgBoostBonus": 
				_loc2_ = "ti2_power_boost_dmg";
				break;
			case "ReduceDmgBoostPowerCost": 
				_loc2_ = "ti2_power_reduce_cost";
				break;
			case "IncreaseSpeed": 
				_loc2_ = "ti2_speed_increase";
				break;
			case "IncreasePetHp": 
				_loc2_ = "ti2_armor_increase_health";
			case "IncreaseEngineSpeed": 
				_loc2_ = "ti2_speed_increase";
				break;
			case "UnbreakableArmor": 
				_loc2_ = "ti2_pen_armor";
			}
			return _loc2_;
		}
		
		public static function getName(param1:String):String
		{
			var _loc2_:int = 0;
			_loc2_ = 0;
			while (_loc2_ < WEAPON_ELITE_TECHS.length)
			{
				if (WEAPON_ELITE_TECHS[_loc2_] == param1)
				{
					return Localize.t(WEAPON_ELITE_TECHS_NAME[_loc2_]);
				}
				_loc2_++;
			}
			_loc2_ = 0;
			while (_loc2_ < ELITE_TECHS.length)
			{
				if (ELITE_TECHS[_loc2_] == param1)
				{
					return Localize.t(ELITE_TECHS_NAME[_loc2_]);
				}
				_loc2_++;
			}
			return "";
		}
		
		private static function createEliteTechBar(param1:Game, param2:String, param3:String, param4:TechSkill, param5:Object):EliteTechBar
		{
			var _loc8_:int = 1;
			for each (var _loc9_:* in param4.eliteTechs)
			{
				if (_loc9_.eliteTech == param2)
				{
					_loc8_ = _loc9_.eliteTechLevel;
					break;
				}
			}
			var _loc7_:String = getDescription(param2, _loc8_, param5);
			var _loc6_:String = getIconName(param2);
			return new EliteTechBar(param1, param3, _loc7_, _loc6_, _loc8_, param2, param4);
		}
		
		public static function getEliteTechBarList(param1:Game, param2:TechSkill, param3:Object):Vector.<EliteTechBar>
		{
			var _loc4_:* = undefined;
			var _loc6_:* = undefined;
			var _loc9_:String = null;
			var _loc8_:int = 0;
			var _loc5_:Vector.<EliteTechBar> = new Vector.<EliteTechBar>();
			var _loc7_:Object = param3.eliteTechs;
			if (param2.table == "Weapons")
			{
				_loc4_ = WEAPON_ELITE_TECHS;
				_loc6_ = WEAPON_ELITE_TECHS_NAME;
			}
			else
			{
				_loc4_ = ELITE_TECHS;
				_loc6_ = ELITE_TECHS_NAME;
			}
			_loc8_ = 0;
			while (_loc8_ < _loc4_.length)
			{
				_loc9_ = _loc4_[_loc8_];
				if (_loc7_.hasOwnProperty(_loc9_) && _loc7_[_loc9_] > 0)
				{
					_loc5_.push(createEliteTechBar(param1, _loc9_, _loc6_[_loc8_], param2, param3));
				}
				_loc8_++;
			}
			return _loc5_;
		}
		
		public static function getResource1Cost(param1:int):int
		{
			return int(Math.round(Math.pow(1.025, param1 - 1) / 432.548654 * 3200000));
		}
		
		public static function getResource2Cost(param1:int):int
		{
			return int(Math.round(Math.pow(1.025, param1 - 1) / 432.548654 * 540000));
		}
		
		public static function getResource1CostRange(param1:int, param2:int):int
		{
			var _loc3_:* = 0;
			var _loc4_:int = 0;
			_loc3_ = param1;
			while (_loc3_ <= param2)
			{
				_loc4_ += getResource1Cost(_loc3_);
				_loc3_++;
			}
			return _loc4_;
		}
		
		public static function getFluxCost(param1:int):int
		{
			return int(Math.round(Math.pow(1.025, param1 - 1) / 432.548654 * 12000));
		}
		
		public static function getFluxCostRange(param1:int, param2:int):int
		{
			var _loc3_:* = 0;
			var _loc4_:int = 0;
			_loc3_ = param1;
			while (_loc3_ <= param2)
			{
				_loc4_ += getFluxCost(_loc3_);
				_loc3_++;
			}
			return _loc4_;
		}
	}
}
