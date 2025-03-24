package core.player {
	import core.hud.components.techTree.EliteTechBar;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.weapon.Beam;
	import core.weapon.Damage;
	import core.weapon.ProjectileGun;
	import core.weapon.Weapon;
	import generics.Localize;
	
	public class EliteTechs {
		public static const MAX_LEVEL:Number = 100;
		
		public static const COST_INCREASE:Number = 1.025;
		
		public static const COST_SUM:Number = 432.548654;
		
		public static const PRIMARY_COST_SUM:Number = 3200000;
		
		public static const SECONDARY_COST_SUM:Number = 540000;
		
		public static const FLUX_COST_SUM:Number = 12000;
		
		public static const HYDROGEN_CRYSTALS:String = "d6H3w_34pk2ghaQcXYBDag";
		
		public static const PLASMA_FLUIDS:String = "H5qybQDy9UindMh9yYIeqg";
		
		public static const IRIDIUM:String = "gO_f-y0QEU68vVwJ_XVmOg";
		
		public static const WEAPON_ELITE_TECHS:Vector.<String> = Vector.<String>(["AddKineticDamage","AddEnergyDamage","AddCorrosiveDamage","AddKineticBaseDamage","AddEnergyBaseDamage","AddCorrosiveBaseDamage","AddKineticDot5","AddEnergyDot5","AddCorrosiveDot5","AddKineticDot10","AddEnergyDot10","AddCorrosiveDot10","AddKineticDot20","AddEnergyDot20","AddCorrosiveDot20","AddEnergyBurn","AddCorrosiveBurn","AddHealthVamp","AddShieldVamp","AddDualVamp","KineticPenetration","EnergyPenetration","CorrosivePenetration","AddExtraProjectiles","IncreaseDirectDamage","IncreaseDebuffDamage","IncreaseRange","IncreaseRefire","IncreaseGuidance","ReducePowerCost","DisableHealing","DisableShieldRegen","ReduceTargetDamage","ReduceTargetArmor","IncreaseAOE","AddAOE","IncreaseNrHits","IncreaseSpeed","IncreasePetHp"]);
		
		public static const WEAPON_ELITE_TECHS_NAME:Vector.<String> = Vector.<String>(["Kinetic Damage","Energy Damage","Corrosive Damage","Kinetic Damage","Energy Damage","Corrosive Damage","Kinetic DoT 5 Seconds","Energy DoT 5 Seconds","Corrosive DoT 5 Seconds","Kinetic DoT 10 Seconds","Energy DoT 10 Seconds","Corrosive DoT 10 Seconds","Kinetic DoT 20 Seconds","Energy DoT 20 Seconds","Corrosive DoT 20 Seconds","Energy Burn 10 Seconds","Corrosive Burn 10 Seconds","Health Leech","Shield Leech","Health and Shield Leech","Reduce Kinetic Resitance","Reduce Energy Resitance","Reduce Corrosive Resitance","Extra Projectiles","Improved Direct Damage","Improved DoT","Improved Range","Improved Attack Speed","Improved Velocity and Guidance","Reduced the Power Cost","Disables target Healing","Disables target Shield Regen","Reduce Target Damage done","Reduce Target Armor","Improved Area Of Effect","Improved Area Of Effect","Improved Number of Hits","Increase Speed","Increase Pet HP and Shield"]);
		
		public static const ELITE_TECHS:Vector.<String> = Vector.<String>(["IncreaseShield","IncreaseShieldRegen","ConvertShield","IncreaseHealth","IncreaseArmor","ConvertHealth","IncreaseSheildDuration","ReduceSheildCooldown","IncreaseSpeedBoostAmount","IncreaseSpeedBoostDuration","ReduceSpeedBoostCooldown","IncreaseArmorConvBonus","ReduceArmorConvCooldown","IncreaseDamage","IncreaseRefire","ReducePowerCost","IncreaseDmgBoostDuration","IncreaseDmgBoostBonus","ReduceDmgBoostPowerCost","IncreaseEngineSpeed","UnbreakableArmor"]);
		
		public static const ELITE_TECHS_NAME:Vector.<String> = Vector.<String>(["Maximum Shield","Shield Regen","Convert Shield","Maximum Health","Improved Armor","Convert Health","Lasting Harden Shields","Rapid Recharge Harden Sheilds","Overcharged Speed Boost","Lasting Speed Boost","Rapid Recharge Speed Boost","Optimized Repair","Rapid Recharge Repair","Over-Charged Weapons","Hyper-Charged Weapons","Optimized Weapons","Lasting Power Boost","Super Charged Power Boost","Optimized Power Boost","Improved Engines","Unbreakable Armor"]);
		
		public function EliteTechs() {
			super();
		}
		
		public static function getStatTextByLevel(eliteTech:String, obj:Object, level:Number) : String {
			var _local11:Number = NaN;
			var _local6:Number = NaN;
			var _local12:Object = null;
			var _local7:int = 0;
			var _local8:* = NaN;
			var _local10:String = "";
			if(!obj.hasOwnProperty("eliteTechs")) {
				return _local10;
			}
			var _local4:Object = obj.eliteTechs;
			if(!_local4.hasOwnProperty(eliteTech)) {
				return _local10;
			}
			var _local5:Number = Number(_local4[eliteTech]);
			var _local9:Number = _local5 * level / 100;
			switch(eliteTech) {
				case "AddKineticDamage":
					_local10 += Localize.t("Adds extra [value]% Kinetic Damage").replace("[value]",_local9.toFixed(2));
					break;
				case "AddEnergyDamage":
					_local10 += Localize.t("Adds extra [value]% Energy Damage").replace("[value]",_local9.toFixed(2));
					break;
				case "AddCorrosiveDamage":
					_local10 += Localize.t("Adds extra [value]% Corrosive Damage").replace("[value]",_local9.toFixed(2));
					break;
				case "AddKineticBaseDamage":
					_local10 += Localize.t("Adds extra [value] Kinetic Damage").replace("[value]",_local9.toFixed(2));
					break;
				case "AddEnergyBaseDamage":
					_local10 += Localize.t("Adds extra [value] Energy Damage").replace("[value]",_local9.toFixed(2));
					break;
				case "AddCorrosiveBaseDamage":
					_local10 += Localize.t("Adds extra [value] Corrosive Damage").replace("[value]",_local9.toFixed(2));
					break;
				case "AddKineticDot5":
					_local10 += Localize.t("Adds extra [value]% Kinetic Damage over 5 Seconds").replace("[value]",_local9.toFixed(2));
					break;
				case "AddEnergyDot5":
					_local10 += Localize.t("Adds extra [value]% Energy Damage over 5 Seconds").replace("[value]",_local9.toFixed(2));
					break;
				case "AddCorrosiveDot5":
					_local10 += Localize.t("Adds extra [value]% Corrosive Damage over 5 Seconds").replace("[value]",_local9.toFixed(2));
					break;
				case "AddKineticDot10":
					_local10 += Localize.t("Adds extra [value]% Kinetic Damage over 10 Seconds").replace("[value]",_local9.toFixed(2));
					break;
				case "AddEnergyDot10":
					_local10 += Localize.t("Adds extra [value]% Energy Damage over 10 Seconds").replace("[value]",_local9.toFixed(2));
					break;
				case "AddCorrosiveDot10":
					_local10 += Localize.t("Adds extra [value]% Corrosive Damage over 10 Seconds").replace("[value]",_local9.toFixed(2));
					break;
				case "AddKineticDot20":
					_local10 += Localize.t("Adds extra [value]% Kinetic Damage over 20 Seconds").replace("[value]",_local9.toFixed(2));
					break;
				case "AddEnergyDot20":
					_local10 += Localize.t("Adds extra [value]% Energy Damage over 20 Seconds").replace("[value]",_local9.toFixed(2));
					break;
				case "AddCorrosiveDot20":
					_local10 += Localize.t("Adds extra [value]% Corrosive Damage over 20 Seconds").replace("[value]",_local9.toFixed(2));
					break;
				case "AddEnergyBurn":
					_local10 += Localize.t("Adds extra [value]% Energy Burn Damage over 10 Seconds").replace("[value]",_local9.toFixed(2));
					break;
				case "AddCorrosiveBurn":
					_local10 += Localize.t("Adds extra [value]% Corrosive Burn Damage over 10 Seconds").replace("[value]",_local9.toFixed(2));
					break;
				case "AddHealthVamp":
					_local10 += Localize.t("Steals [value]% of Health Damage done to targets").replace("[value]",_local9.toFixed(2));
					break;
				case "AddShieldVamp":
					_local10 += Localize.t("Steals [value]% of Shield Damage done to targets").replace("[value]",_local9.toFixed(2));
					break;
				case "AddDualVamp":
					_local10 += Localize.t("Steals [value]% of Health Damage done to targets\n").replace("[value]",_local9.toFixed(2));
					_local10 = _local10 + Localize.t("Steals [value]% of Shield Damage done to targets").replace("[value]",_local9.toFixed(2));
					break;
				case "KineticPenetration":
					_local10 += Localize.t("Reduces targets Kinetic Resistance by [value]% for [value2] Seconds").replace("[value]",_local9.toFixed(2)).replace("[value2]",(5 + 5 * level / 100).toFixed(1));
					break;
				case "EnergyPenetration":
					_local10 += Localize.t("Reduces targets Energy Resistance by [value]% for [value2] Seconds").replace("[value]",_local9.toFixed(2)).replace("[value2]",(5 + 5 * level / 100).toFixed(1));
					break;
				case "CorrosivePenetration":
					_local10 += Localize.t("Reduces targets Corrosive Resistance by [value]% for [value2] Seconds").replace("[value]",_local9.toFixed(2)).replace("[value2]",(5 + 5 * level / 100).toFixed(1));
					break;
				case "AddExtraProjectiles":
					_local11 = level / 100;
					_local6 = Number(obj.multiNrOfP);
					_local7 = 0;
					while(_local7 < 6) {
						_local12 = obj.techLevels[_local7];
						_local6 += _local12.incMultiNrOfP;
						_local7++;
					}
					_local8 = _local6;
					if(_local6 == 1) {
						if(_local11 < 0.5) {
							_local6 = 2;
						} else if(_local11 >= 0.5) {
							_local6 = 3;
						}
					} else {
						_local6 += int(Math.floor(_local11 * _local6));
					}
					_local11 = _local8 / _local6;
					_local9 = Math.abs(_local11 * (100 + _local9) - 100);
					_local10 += Localize.t("Adds [value2] extra projectiles, each projectile deals [value]% less damage").replace("[value]",_local9.toFixed(2)).replace("[value2]",_local6 - _local8);
					break;
				case "IncreaseDirectDamage":
					_local10 += Localize.t("Increases Direct Damage by [value]%").replace("[value]",_local9.toFixed(2));
					break;
				case "IncreaseDebuffDamage":
					_local10 += Localize.t("Increases Debuff Damage by [value]%").replace("[value]",_local9.toFixed(2));
					break;
				case "IncreaseRange":
					_local10 += Localize.t("Increases Range by [value]%").replace("[value]",_local9.toFixed(2));
					break;
				case "IncreaseRefire":
					if(obj.name == "Teleport Device" || obj.name == "Bionic Teleport" || obj.name == "Cloaking Device") {
						_local10 += Localize.t("Reduce cooldown by [value]%").replace("[value]",_local9.toFixed(2));
					} else {
						_local10 += Localize.t("Increases Attack Speed by [value]%").replace("[value]",_local9.toFixed(2));
					}
					break;
				case "IncreaseGuidance":
					_local10 += Localize.t("Improves Guidance by [value]%\n").replace("[value]",_local9.toFixed(2));
					_local10 = _local10 + Localize.t("Improves Velocity by [value]%").replace("[value]",(0.1 * _local9).toFixed(2));
					break;
				case "ReducePowerCost":
					_local10 += Localize.t("Reduce Power Cost by [value]%").replace("[value]",_local9.toFixed(2));
					break;
				case "DisableHealing":
					_local10 += Localize.t("Disables targets from Healing for [value] seconds").replace("[value]",(1 + _local9).toFixed(2));
					break;
				case "DisableShieldRegen":
					_local10 += Localize.t("Disables targets Shield Regen for [value] seconds").replace("[value]",(1 + _local9).toFixed(2));
					break;
				case "ReduceTargetDamage":
					_local10 += Localize.t("Reduces targets Damage by [value]% for [value2] Seconds").replace("[value]",_local9.toFixed(2)).replace("[value2]",(5 + 5 * level / 100).toFixed(2));
					break;
				case "ReduceTargetArmor":
					_local10 += Localize.t("Reduces targets Armor by [value]% of weapon damage for [value2] Seconds").replace("[value]",_local9.toFixed(2)).replace("[value2]",(5 + 5 * level / 100).toFixed(2));
					break;
				case "IncreaseShield":
					_local10 += Localize.t("Increases Shield by [value]%").replace("[value]",_local9.toFixed(2));
					break;
				case "IncreaseShieldRegen":
					_local10 += Localize.t("Increases Shield Regeneration by [value]%").replace("[value]",_local9.toFixed(2));
					break;
				case "ConvertShield":
					_local10 += Localize.t("Sacrifice [value]% Maximum Shield to regen [value2]% of Maximum Health Regen every second").replace("[value]",_local9.toFixed(2)).replace("[value2]",(0.06 * _local9).toFixed(2));
					break;
				case "IncreaseHealth":
					_local10 += Localize.t("Increases Health by [value]%").replace("[value]",_local9.toFixed(2));
					break;
				case "IncreaseArmor":
					_local10 += Localize.t("Increases Armor by [value]%").replace("[value]",_local9.toFixed(2));
					break;
				case "ConvertHealth":
					_local10 += Localize.t("Sacrifice [value]% Maximum Health to increase Shield Regen by [value2]%").replace("[value]",_local9.toFixed(2)).replace("[value2]",(3 * _local9).toFixed(2));
					break;
				case "IncreaseSheildDuration":
					_local10 += Localize.t("Increases the Duration of Harden Shield by [value]%").replace("[value]",_local9.toFixed(2));
					break;
				case "ReduceSheildCooldown":
					_local10 += Localize.t("Decreases the Cooldown of Harden Shield by [value]%").replace("[value]",_local9.toFixed(2));
					break;
				case "IncreaseSpeedBoostAmount":
					_local10 += Localize.t("Increases the Bonus Speed gained by Speed Boost by [value]%").replace("[value]",_local9.toFixed(2));
					break;
				case "IncreaseSpeedBoostDuration":
					_local10 += Localize.t("Increases the Duration of Speed Boost by [value]%").replace("[value]",_local9.toFixed(2));
					break;
				case "ReduceSpeedBoostCooldown":
					_local10 += Localize.t("Decreases the Cooldown of Speed Boost by [value]%").replace("[value]",_local9.toFixed(2));
					break;
				case "IncreaseArmorConvBonus":
					_local10 += Localize.t("Increases the Amount of Health gained by Convert by [value]%").replace("[value]",_local9.toFixed(2));
					break;
				case "ReduceArmorConvCooldown":
					_local10 += Localize.t("Decreases the Cooldown of Convert by [value]%").replace("[value]",_local9.toFixed(2));
					break;
				case "IncreaseDamage":
					_local10 += Localize.t("Increases Damage done by all Weapons by [value]%").replace("[value]",_local9.toFixed(2));
					break;
				case "IncreaseRefire":
					_local10 += Localize.t("Increases Attack Speed for all Weapons by [value]%").replace("[value]",_local9.toFixed(2));
					break;
				case "ReducePowerCost":
					_local10 += Localize.t("Reduces Power Cost of all Weapons by [value]%").replace("[value]",_local9.toFixed(2));
					break;
				case "IncreaseDmgBoostDuration":
					_local10 += Localize.t("Increases the Duration of Damage Boost by [value]%").replace("[value]",_local9.toFixed(2));
					break;
				case "IncreaseDmgBoostBonus":
					_local10 += Localize.t("Increases the Damage Bonus gained from Damage Boost by [value]%").replace("[value]",_local9.toFixed(2));
					break;
				case "ReduceDmgBoostPowerCost":
					_local10 += Localize.t("Reduces the Power Penalty of Damage Boost by [value]%").replace("[value]",_local9.toFixed(2));
					break;
				case "IncreaseAOE":
					_local10 += Localize.t("Increases area of effect radius by [value]%").replace("[value]",_local9.toFixed(2));
					break;
				case "AddAOE":
					_local10 += Localize.t("Increases area of effect radius by [value] units").replace("[value]",(5 + _local9).toFixed(2));
					break;
				case "IncreaseNrHits":
					_local10 += Localize.t("Increases Number of Hits by [value]").replace("[value]",int(1 + _local9));
					break;
				case "IncreaseSpeed":
					if(obj.name == "Teleport Device" || obj.name == "Bionic Teleport") {
						_local10 += Localize.t("Increases Cast Speed by [value]%").replace("[value]",_local9.toFixed(2));
					} else {
						_local10 += Localize.t("Increases Speed by [value]%").replace("[value]",_local9.toFixed(2));
					}
					break;
				case "IncreasePetHp":
					_local10 += Localize.t("Increases Pet HP and Shield by [value]%").replace("[value]",_local9.toFixed(2));
				case "IncreaseEngineSpeed":
					_local10 += Localize.t("Increases Engine Speed by [value]%").replace("[value]",_local9.toFixed(2));
					break;
				case "UnbreakableArmor":
					_local10 += Localize.t("Armor can not be reduced below [value]% of maximum").replace("[value]",_local9.toFixed(2));
			}
			return _local10 + "\n";
		}
		
		public static function addWeaponEliteTechs(w:Weapon, obj:Object, eliteTechLevel:int, eliteTech:String) : void {
			var _local10:Number = NaN;
			var _local8:Number = NaN;
			var _local5:Beam = null;
			if(!obj.hasOwnProperty("eliteTechs")) {
				return;
			}
			var _local6:Object = obj.eliteTechs;
			if(!_local6.hasOwnProperty(eliteTech)) {
				return;
			}
			var _local7:Number = Number(_local6[eliteTech]);
			var _local9:Number = _local7 * eliteTechLevel / 100;
			if(_local7 == 0) {
				return;
			}
			switch(eliteTech) {
				case "AddKineticDamage":
					w.dmg.addBaseDmg(0.01 * _local9 * w.dmg.dmg(),0);
					break;
				case "AddEnergyDamage":
					w.dmg.addBaseDmg(0.01 * _local9 * w.dmg.dmg(),1);
					break;
				case "AddCorrosiveDamage":
					w.dmg.addBaseDmg(0.01 * _local9 * w.dmg.dmg(),2);
					break;
				case "AddKineticBaseDamage":
					w.dmg.addBaseDmg(_local9,0);
					break;
				case "AddEnergyBaseDamage":
					w.dmg.addBaseDmg(_local9,1);
					break;
				case "AddCorrosiveBaseDamage":
					w.dmg.addBaseDmg(_local9,2);
					break;
				case "AddKineticDot5":
					w.addDebuff(0,5,new Damage(0.01 * _local9 * w.dmg.dmg() / 5,0),"Tk7JFixDAkuw6mB-BLXQwg");
					break;
				case "AddEnergyDot5":
					w.addDebuff(0,5,new Damage(0.01 * _local9 * w.dmg.dmg() / 5,1),"9kIM0A-0d0uPHMjJ1qg5pg");
					break;
				case "AddCorrosiveDot5":
					w.addDebuff(0,5,new Damage(0.01 * _local9 * w.dmg.dmg() / 5,2),"U4WOoDzOV0iXNmVwM3SELA");
					break;
				case "AddKineticDot10":
					w.addDebuff(0,10,new Damage(0.01 * _local9 * w.dmg.dmg() / 10,0),"Tk7JFixDAkuw6mB-BLXQwg");
					break;
				case "AddEnergyDot10":
					w.addDebuff(0,10,new Damage(0.01 * _local9 * w.dmg.dmg() / 10,1),"9kIM0A-0d0uPHMjJ1qg5pg");
					break;
				case "AddCorrosiveDot10":
					w.addDebuff(0,10,new Damage(0.01 * _local9 * w.dmg.dmg() / 10,2),"U4WOoDzOV0iXNmVwM3SELA");
					break;
				case "AddKineticDot20":
					w.addDebuff(0,20,new Damage(0.01 * _local9 * w.dmg.dmg() / 20,0),"Tk7JFixDAkuw6mB-BLXQwg");
					break;
				case "AddEnergyDot20":
					w.addDebuff(0,20,new Damage(0.01 * _local9 * w.dmg.dmg() / 20,1),"9kIM0A-0d0uPHMjJ1qg5pg");
					break;
				case "AddCorrosiveDot20":
					w.addDebuff(0,20,new Damage(0.01 * _local9 * w.dmg.dmg() / 20,2),"U4WOoDzOV0iXNmVwM3SELA");
					break;
				case "AddEnergyBurn":
					w.addDebuff(4,10,new Damage(0.002 * _local9 * w.dmg.dmg(),1),"7XV2cuSPJ0erabUgynivBA");
					break;
				case "AddCorrosiveBurn":
					w.addDebuff(4,10,new Damage(0.002 * _local9 * w.dmg.dmg(),2),"U4WOoDzOV0iXNmVwM3SELA");
					break;
				case "AddHealthVamp":
					w.healthVamp += _local9;
					break;
				case "AddShieldVamp":
					w.shieldVamp += _local9;
					break;
				case "AddDualVamp":
					w.healthVamp += _local9;
					w.shieldVamp += _local9;
					break;
				case "KineticPenetration":
					w.addDebuff(8,5 + 5 * eliteTechLevel / 100,new Damage(_local9,8),"Tk7JFixDAkuw6mB-BLXQwg");
					break;
				case "EnergyPenetration":
					w.addDebuff(9,5 + 5 * eliteTechLevel / 100,new Damage(_local9,8),"9kIM0A-0d0uPHMjJ1qg5pg");
					break;
				case "CorrosivePenetration":
					w.addDebuff(10,5 + 5 * eliteTechLevel / 100,new Damage(_local9,8),"U4WOoDzOV0iXNmVwM3SELA");
					break;
				case "AddExtraProjectiles":
					_local10 = eliteTechLevel / 100;
					if(_local10 == 0) {
						return;
					}
					_local8 = w.multiNrOfP;
					if(w.multiNrOfP == 1) {
						if(_local10 < 0.5) {
							w.multiNrOfP = 2;
							w.multiOffset += 10;
						} else if(_local10 >= 0.5) {
							w.multiNrOfP = 3;
							w.multiOffset += 15;
						}
					} else {
						w.multiNrOfP += int(Math.floor(_local10 * w.multiNrOfP));
					}
					_local10 = _local8 / w.multiNrOfP;
					w.maxProjectiles = w.multiNrOfP / _local8 * w.maxProjectiles;
					w.dmg.addBasePercent(_local10 * (100 + _local9) - 100);
					w.debuffValue.addBasePercent(_local10 * (100 + _local9) - 100);
					w.debuffValue2.addBasePercent(_local10 * (100 + _local9) - 100);
					_local10 = 1 / _local10;
					w.multiAngleOffset += w.multiAngleOffset * 0.5 * _local10;
					w.multiOffset += w.multiOffset * 0.5 * _local10;
					if(w is ProjectileGun) {
						w.heatCost = w.heatCost / w.multiNrOfP * _local8;
					}
					break;
				case "IncreaseDirectDamage":
					w.dmg.addBasePercent(_local9,0);
					w.dmg.addBasePercent(_local9,1);
					w.dmg.addBasePercent(_local9,2);
					w.dmg.addBasePercent(_local9,6);
					break;
				case "IncreaseDebuffDamage":
					if(w.debuffValue.dmg() > 0) {
						w.debuffValue.addBasePercent(_local9,0);
						w.debuffValue.addBasePercent(_local9,1);
						w.debuffValue.addBasePercent(_local9,2);
						w.debuffValue.addBasePercent(_local9,6);
					}
					if(w.debuffValue2.dmg() > 0) {
						w.debuffValue2.addBasePercent(_local9,0);
						w.debuffValue2.addBasePercent(_local9,1);
						w.debuffValue2.addBasePercent(_local9,2);
						w.debuffValue2.addBasePercent(_local9,6);
					}
					break;
				case "IncreaseRange":
					w.range += int(w.range * 0.01 * _local9);
					w.ttl += int(w.ttl * 0.01 * _local9);
					break;
				case "IncreaseRefire":
					w.reloadTime -= w.reloadTime * 0.01 * _local9;
					w.heatCost -= w.heatCost * 0.01 * _local9;
					break;
				case "IncreaseGuidance":
					w.rotationSpeed += w.rotationSpeed * 0.01 * _local9;
					w.acceleration += w.acceleration * 0.01 * _local9;
					w.speed += w.speed * 0.002 * _local9;
					break;
				case "ReducePowerCost":
					w.heatCost -= w.heatCost * 0.01 * _local9;
					break;
				case "DisableHealing":
					w.addDebuff(6,1 + _local9,new Damage(0,8),"jvcmRezjZUKQUuhAlhhCqw");
					break;
				case "DisableShieldRegen":
					w.addDebuff(5,1 + _local9,new Damage(0,8),"jvcmRezjZUKQUuhAlhhCqw");
					break;
				case "ReduceTargetDamage":
					w.addDebuff(7,5 + 5 * eliteTechLevel / 100,new Damage(_local9,8),"xYk7ubyao0uh8j9SDJYeWw");
					break;
				case "ReduceTargetArmor":
					w.addDebuff(3,5 + 5 * eliteTechLevel / 100,new Damage(0.01 * _local9 * w.dmg.dmg(),w.dmg.type),"Tk7JFixDAkuw6mB-BLXQwg");
					break;
				case "IncreaseAOE":
					w.dmgRadius += int(0.01 * _local9 * w.dmgRadius);
					break;
				case "AddAOE":
					w.dmgRadius += int(5 + _local9);
					break;
				case "IncreaseNrHits":
					if(w is Beam) {
						_local5 = w as Beam;
						_local5.nrTargets = _local5.nrTargets + (int(1 + _local9));
					} else {
						w.numberOfHits += int(1 + _local9);
					}
				case "IncreaseSpeed":
					w.speed += 0.01 * _local9 * w.speed;
					break;
				case "IncreasePetHp":
			}
		}
		
		public static function addEliteTechs(s:PlayerShip, obj:Object, eliteTechLevel:int, eliteTech:String) : void {
			if(!obj.hasOwnProperty("eliteTechs")) {
				return;
			}
			var _local5:Object = obj.eliteTechs;
			if(!_local5.hasOwnProperty(eliteTech)) {
				return;
			}
			var _local6:Number = Number(_local5[eliteTech]);
			var _local8:Number = _local6 * eliteTechLevel / 100;
			if(_local6 == 0) {
				return;
			}
			switch(eliteTech) {
				case "IncreaseShield":
					s.shieldHpBase += 0.01 * _local8 * s.shieldHpBase;
					s.shieldHpMax = s.shieldHpBase;
					s.shieldHp = s.shieldHpBase;
					break;
				case "IncreaseShieldRegen":
					s.shieldRegenBase += 0.01 * _local8 * s.shieldRegenBase;
					s.shieldRegen = s.shieldRegenBase;
					break;
				case "ConvertShield":
					s.hpRegen = 0.0006 * _local8;
					s.shieldHpBase -= 0.01 * _local8 * s.shieldHpBase;
					if(s.shieldHpBase < 1) {
						s.shieldHpBase = 1;
					}
					s.shieldHpMax = s.shieldHpBase;
					s.shieldHp = s.shieldHpBase;
					break;
				case "IncreaseHealth":
					s.hpBase += 0.01 * _local8 * s.hpBase;
					s.hpMax = s.hpBase;
					s.hp = s.hpBase;
					break;
				case "IncreaseArmor":
					s.armorThresholdBase += 0.01 * _local8 * s.armorThresholdBase;
					s.armorThreshold = s.armorThresholdBase;
					break;
				case "ConvertHealth":
					s.shieldRegenBase += 0.03 * _local8 * s.shieldRegenBase;
					s.shieldRegen = s.shieldRegenBase;
					s.hpBase -= 0.01 * _local8 * s.hpBase;
					if(s.hpBase < 1) {
						s.hpBase = 1;
					}
					s.hpMax = s.hpBase;
					s.hp = s.hpBase;
					break;
				case "IncreaseSheildDuration":
					s.hardenDuration += 0.01 * _local8 * s.hardenDuration;
					break;
				case "ReduceSheildCooldown":
					s.hardenCD -= Math.round(0.01 * _local8 * s.hardenCD);
					break;
				case "IncreaseSpeedBoostAmount":
					s.boostBonus += 0.01 * _local8 * s.boostBonus;
					break;
				case "IncreaseSpeedBoostDuration":
					s.boostDuration += 0.01 * _local8 * s.boostDuration;
					break;
				case "ReduceSpeedBoostCooldown":
					s.boostCD -= Math.round(0.01 * _local8 * s.boostCD);
					break;
				case "IncreaseArmorConvBonus":
					s.convGain += 0.01 * _local8 * s.convGain;
					break;
				case "ReduceArmorConvCooldown":
					s.convCD -= Math.round(0.01 * _local8 * s.convCD);
					break;
				case "IncreaseDamage":
					for each(var _local7 in s.weapons) {
						_local7.dmg.addBasePercent(_local8);
						_local7.debuffValue.addBasePercent(_local8);
						_local7.debuffValue2.addBasePercent(_local8);
					}
					break;
				case "IncreaseRefire":
					for each(_local7 in s.weapons) {
						_local7.reloadTime -= _local7.reloadTime * 0.01 * _local8;
						_local7.heatCost -= _local7.heatCost * 0.01 * _local8;
					}
					break;
				case "ReducePowerCost":
					for each(_local7 in s.weapons) {
						_local7.heatCost -= _local7.heatCost * 0.01 * _local8;
					}
					break;
				case "IncreaseDmgBoostDuration":
					s.dmgBoostDuration += 0.01 * _local8 * s.dmgBoostDuration;
					break;
				case "IncreaseDmgBoostBonus":
					s.dmgBoostBonus += 0.01 * _local8 * s.dmgBoostBonus;
					break;
				case "ReduceDmgBoostPowerCost":
					s.dmgBoostCost -= 0.01 * _local8 * s.dmgBoostCost;
					break;
				case "IncreaseEngineSpeed":
					s.engine.speed += s.engine.speed * 0.01 * _local8;
					break;
				case "UnbreakableArmor":
			}
		}
		
		private static function getDescription(eliteTech:String, level:int, obj:Object) : String {
			var _local4:String = "";
			if(level < 1) {
				level = 1;
			}
			if(level < 100) {
				_local4 += "<FONT COLOR=\'#88ff88\'>" + Localize.t("Level") + ": " + level + " " + Localize.t("Bonus") + ":</FONT>\n";
				_local4 = _local4 + getStatTextByLevel(eliteTech,obj,level);
				_local4 = _local4 + ("<FONT COLOR=\'#88ff88\'>" + Localize.t("Bonus at level") + " " + (level + 1).toString() + ":</FONT>\n");
				_local4 = _local4 + (getStatTextByLevel(eliteTech,obj,level + 1) + "\n");
			} else {
				_local4 += "<FONT COLOR=\'#88ff88\'>" + Localize.t("Level") + ": " + level + " " + Localize.t("Bonus") + ":</FONT>\n";
				_local4 = _local4 + (getStatTextByLevel(eliteTech,obj,level) + "\n");
			}
			return _local4;
		}
		
		public static function getIconName(eliteTech:String) : String {
			var _local2:String = null;
			switch(eliteTech) {
				case "AddKineticDamage":
					_local2 = "ti2_kinetic_dmg";
					break;
				case "AddEnergyDamage":
					_local2 = "ti2_energy_dmg";
					break;
				case "AddCorrosiveDamage":
					_local2 = "ti2_corrosive_dmg";
					break;
				case "AddKineticBaseDamage":
					_local2 = "ti2_kinetic_base_dmg";
					break;
				case "AddEnergyBaseDamage":
					_local2 = "ti2_energy_base_dmg";
					break;
				case "AddCorrosiveBaseDamage":
					_local2 = "ti2_corrosive_base_dmg";
					break;
				case "AddKineticDot5":
					_local2 = "ti2_kinetic_dot5";
					break;
				case "AddEnergyDot5":
					_local2 = "ti2_energy_dot5";
					break;
				case "AddCorrosiveDot5":
					_local2 = "ti2_corrosive_dot5";
					break;
				case "AddKineticDot10":
					_local2 = "ti2_kinetic_dot10";
					break;
				case "AddEnergyDot10":
					_local2 = "ti2_energy_dot10";
					break;
				case "AddCorrosiveDot10":
					_local2 = "ti2_corrosive_dot10";
					break;
				case "AddKineticDot20":
					_local2 = "ti2_kinetic_dot20";
					break;
				case "AddEnergyDot20":
					_local2 = "ti2_energy_dot20";
					break;
				case "AddCorrosiveDot20":
					_local2 = "ti2_corrosive_dot20";
					break;
				case "AddEnergyBurn":
					_local2 = "ti2_energy_burn";
					break;
				case "AddCorrosiveBurn":
					_local2 = "ti2_corrosive_burn";
					break;
				case "AddHealthVamp":
					_local2 = "ti2_vamp_health";
					break;
				case "AddShieldVamp":
					_local2 = "ti2_vamp_shield";
					break;
				case "AddDualVamp":
					_local2 = "ti2_vamp_all";
					break;
				case "KineticPenetration":
					_local2 = "ti2_pen_kinetic";
					break;
				case "EnergyPenetration":
					_local2 = "ti2_pen_energy";
					break;
				case "CorrosivePenetration":
					_local2 = "ti2_pen_corrosive";
					break;
				case "AddExtraProjectiles":
					_local2 = "ti2_add_projectile";
					break;
				case "IncreaseDirectDamage":
					_local2 = "ti2_increase_dmg";
					break;
				case "IncreaseDebuffDamage":
					_local2 = "ti2_increase_dot";
					break;
				case "IncreaseRange":
					_local2 = "ti2_increase_range";
					break;
				case "IncreaseRefire":
					_local2 = "ti2_increase_fire_rate";
					break;
				case "IncreaseGuidance":
					_local2 = "ti2_increase_guidance";
					break;
				case "ReducePowerCost":
					_local2 = "ti2_power_reduce_cost";
					break;
				case "DisableHealing":
					_local2 = "ti2_disable_healing";
					break;
				case "DisableShieldRegen":
					_local2 = "ti2_disable_shield_regen";
					break;
				case "ReduceTargetDamage":
					_local2 = "ti2_decrease_dmg";
					break;
				case "ReduceTargetArmor":
					_local2 = "ti2_pen_armor";
					break;
				case "IncreaseAOE":
					_local2 = "ti2_increase_area_dmg_radius";
					break;
				case "AddAOE":
					_local2 = "ti2_increase_area_dmg_radius";
					break;
				case "IncreaseNrHits":
					_local2 = "ti2_increase_nr_of_hits";
				case "IncreaseShield":
					_local2 = "ti2_shield_increase";
					break;
				case "IncreaseShieldRegen":
					_local2 = "ti2_shield_increase_regen";
					break;
				case "ConvertShield":
					_local2 = "ti2_shield_convert";
					break;
				case "IncreaseHealth":
					_local2 = "ti2_armor_increase_health";
					break;
				case "IncreaseArmor":
					_local2 = "ti2_armor_increase";
					break;
				case "ConvertHealth":
					_local2 = "ti2_armor_convert_health";
					break;
				case "IncreaseSheildDuration":
					_local2 = "ti2_shield_duration";
					break;
				case "ReduceSheildCooldown":
					_local2 = "ti2_shield_cooldown";
					break;
				case "IncreaseSpeedBoostAmount":
					_local2 = "ti2_speed_increase";
					break;
				case "IncreaseSpeedBoostDuration":
					_local2 = "ti2_speed_increase";
					break;
				case "ReduceSpeedBoostCooldown":
					_local2 = "ti2_speed_cooldown";
					break;
				case "IncreaseArmorConvBonus":
					_local2 = "ti2_armor_increase_convert_bonus";
					break;
				case "ReduceArmorConvCooldown":
					_local2 = "ti2_armor_cooldown";
					break;
				case "IncreaseDamage":
					_local2 = "ti2_increase_dmg";
					break;
				case "IncreaseRefire":
					_local2 = "ti2_increase_fire_rate";
					break;
				case "ReducePowerCost":
					_local2 = "ti2_power_reduce_cost";
					break;
				case "IncreaseDmgBoostDuration":
					_local2 = "ti2_power_boost_duration";
					break;
				case "IncreaseDmgBoostBonus":
					_local2 = "ti2_power_boost_dmg";
					break;
				case "ReduceDmgBoostPowerCost":
					_local2 = "ti2_power_reduce_cost";
					break;
				case "IncreaseSpeed":
					_local2 = "ti2_speed_increase";
					break;
				case "IncreasePetHp":
					_local2 = "ti2_armor_increase_health";
				case "IncreaseEngineSpeed":
					_local2 = "ti2_speed_increase";
					break;
				case "UnbreakableArmor":
					_local2 = "ti2_pen_armor";
			}
			return _local2;
		}
		
		public static function getName(eliteTech:String) : String {
			var _local2:int = 0;
			_local2 = 0;
			while(_local2 < WEAPON_ELITE_TECHS.length) {
				if(WEAPON_ELITE_TECHS[_local2] == eliteTech) {
					return Localize.t(WEAPON_ELITE_TECHS_NAME[_local2]);
				}
				_local2++;
			}
			_local2 = 0;
			while(_local2 < ELITE_TECHS.length) {
				if(ELITE_TECHS[_local2] == eliteTech) {
					return Localize.t(ELITE_TECHS_NAME[_local2]);
				}
				_local2++;
			}
			return "";
		}
		
		private static function createEliteTechBar(g:Game, eliteTech:String, name:String, techSkill:TechSkill, obj:Object) : EliteTechBar {
			var _local6:int = 1;
			for each(var _local8 in techSkill.eliteTechs) {
				if(_local8.eliteTech == eliteTech) {
					_local6 = _local8.eliteTechLevel;
					break;
				}
			}
			var _local9:String = getDescription(eliteTech,_local6,obj);
			var _local7:String = getIconName(eliteTech);
			return new EliteTechBar(g,name,_local9,_local7,_local6,eliteTech,techSkill);
		}
		
		public static function getEliteTechBarList(g:Game, techSkill:TechSkill, obj:Object) : Vector.<EliteTechBar> {
			var _local8:* = undefined;
			var _local5:* = undefined;
			var _local9:String = null;
			var _local6:int = 0;
			var _local7:Vector.<EliteTechBar> = new Vector.<EliteTechBar>();
			var _local4:Object = obj.eliteTechs;
			if(techSkill.table == "Weapons") {
				_local8 = WEAPON_ELITE_TECHS;
				_local5 = WEAPON_ELITE_TECHS_NAME;
			} else {
				_local8 = ELITE_TECHS;
				_local5 = ELITE_TECHS_NAME;
			}
			_local6 = 0;
			while(_local6 < _local8.length) {
				_local9 = _local8[_local6];
				if(_local4.hasOwnProperty(_local9) && _local4[_local9] > 0) {
					_local7.push(createEliteTechBar(g,_local9,_local5[_local6],techSkill,obj));
				}
				_local6++;
			}
			return _local7;
		}
		
		public static function getResource1Cost(level:int) : int {
			return int(Math.round(Math.pow(1.025,level - 1) / 432.548654 * 3200000));
		}
		
		public static function getResource2Cost(level:int) : int {
			return int(Math.round(Math.pow(1.025,level - 1) / 432.548654 * (150 * 60 * 60)));
		}
		
		public static function getResource1CostRange(fromLevel:int, toLevel:int) : int {
			var _local4:* = 0;
			var _local3:int = 0;
			_local4 = fromLevel;
			while(_local4 <= toLevel) {
				_local3 += getResource1Cost(_local4);
				_local4++;
			}
			return _local3;
		}
		
		public static function getFluxCost(level:int) : int {
			return int(Math.round(Math.pow(1.025,level - 1) / 432.548654 * (200 * 60)));
		}
		
		public static function getFluxCostRange(fromLevel:int, toLevel:int) : int {
			var _local4:* = 0;
			var _local3:int = 0;
			_local4 = fromLevel;
			while(_local4 <= toLevel) {
				_local3 += getFluxCost(_local4);
				_local4++;
			}
			return _local3;
		}
	}
}

