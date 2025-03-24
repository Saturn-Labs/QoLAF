package core.artifact {
	import generics.Localize;
	
	public class ArtifactStat {
		public var type:String;
		
		public var value:Number;
		
		public function ArtifactStat(type:String, value:Number) {
			super();
			this.type = type;
			this.value = value;
		}
		
		public static function parseTextFromStatType(type:String, value:Number, isUnique:Boolean = false) : String {
			var _local5:String = isUnique ? "<FONT COLOR=\'#FFaa44\'>" : "<FONT COLOR=\'#D3D3D3\'>";
			var _local6:String = "</FONT>";
			var _local4:* = value > 0 ? "+" : "";
			switch(type) {
				case "healthAdd":
				case "healthAdd2":
				case "healthAdd3":
					_local5 += _local4 + (2 * value).toFixed(1) + " " + Localize.t("health") + _local6;
					break;
				case "healthMulti":
					_local5 += _local4 + (1.35 * value).toFixed(1) + "%" + " " + Localize.t("health") + _local6;
					break;
				case "armorAdd":
				case "armorAdd2":
				case "armorAdd3":
					_local5 += _local4 + (7.5 * value).toFixed(1) + " " + Localize.t("armor") + _local6;
					break;
				case "armorMulti":
					_local5 += _local4 + (1 * value).toFixed(1) + "%" + " " + Localize.t("armor") + _local6;
					break;
				case "corrosiveAdd":
				case "corrosiveAdd2":
				case "corrosiveAdd3":
					_local5 += _local4 + (4 * value).toFixed(1) + " " + Localize.t("corrosive dmg") + _local6;
					break;
				case "corrosiveMulti":
					_local5 += _local4 + (1 * value).toFixed(1) + "%" + " " + Localize.t("corrosive dmg") + _local6;
					break;
				case "energyAdd":
				case "energyAdd2":
				case "energyAdd3":
					_local5 += _local4 + (4 * value).toFixed(1) + " " + Localize.t("energy dmg") + _local6;
					break;
				case "energyMulti":
					_local5 += _local4 + (1 * value).toFixed(1) + "%" + " " + Localize.t("energy dmg") + _local6;
					break;
				case "kineticAdd":
				case "kineticAdd2":
				case "kineticAdd3":
					_local5 += _local4 + (4 * value).toFixed(1) + " " + Localize.t("kinetic dmg") + _local6;
					break;
				case "kineticMulti":
					_local5 += _local4 + (1 * value).toFixed(1) + "%" + " " + Localize.t("kinetic dmg") + _local6;
					break;
				case "shieldAdd":
				case "shieldAdd2":
				case "shieldAdd3":
					_local5 += _local4 + (1.75 * value).toFixed(1) + " " + Localize.t("shield") + _local6;
					break;
				case "shieldMulti":
					_local5 += _local4 + (1.35 * value).toFixed(1) + "%" + " " + Localize.t("shield") + _local6;
					break;
				case "shieldRegen":
					_local5 += _local4 + value.toFixed(1) + "%" + " " + Localize.t("shield regen") + _local6;
					break;
				case "corrosiveResist":
					_local5 += _local4 + value.toFixed(1) + "%" + " " + Localize.t("corrosive resist") + _local6;
					break;
				case "energyResist":
					_local5 += _local4 + value.toFixed(1) + "%" + " " + Localize.t("energy resist") + _local6;
					break;
				case "kineticResist":
					_local5 += _local4 + value.toFixed(1) + "%" + " " + Localize.t("kinetic resist") + _local6;
					break;
				case "allResist":
					_local5 += _local4 + value.toFixed(1) + "%" + " " + Localize.t("all resist") + _local6;
					break;
				case "allAdd":
				case "allAdd2":
				case "allAdd3":
					_local5 += _local4 + (1.5 * value).toFixed(1) + " " + Localize.t("to all dmg") + _local6;
					break;
				case "allMulti":
					_local5 += _local4 + (1.5 * value).toFixed(1) + "%" + " " + Localize.t("to all dmg") + _local6;
					break;
				case "dotDamage":
					_local5 += _local4 + value.toFixed(1) + "%" + Localize.t(" damage on all debuffs.") + _local6;
					break;
				case "dotDuration":
					_local5 += _local4 + value.toFixed(1) + "%" + Localize.t(" duration on all debuffs.") + _local6;
					break;
				case "directDamage":
					_local5 += _local4 + value.toFixed(1) + "%" + Localize.t(" direct damage.") + _local6;
					break;
				case "speed":
				case "speed2":
				case "speed3":
					_local5 += _local4 + (0.1 * 2 * value).toFixed(2) + "%" + " " + Localize.t("inc speed") + _local6;
					break;
				case "refire":
				case "refire2":
				case "refire3":
					_local5 += _local4 + (3 * 0.1 * value).toFixed(1) + "%" + " " + Localize.t("inc attack speed") + _local6;
					break;
				case "convHp":
					if(0.1 * value > 100) {
						_local5 += "-100% " + Localize.t("hp to 150% shield") + _local6;
					} else {
						_local5 += "-" + (0.1 * value).toFixed(1) + "%" + " " + Localize.t("hp to 150% shield") + _local6;
					}
					break;
				case "convShield":
					if(0.1 * value > 100) {
						_local5 += "-100% " + Localize.t("shield to 150% hp") + _local6;
					} else {
						_local5 += "-" + (0.1 * value).toFixed(1) + "%" + " " + Localize.t("shield to 150% hp") + _local6;
					}
					break;
				case "powerReg":
				case "powerReg2":
				case "powerReg3":
					_local5 += _local4 + (0.1 * 1.5 * value).toFixed(1) + "%" + " " + Localize.t("inc power regen") + _local6;
					break;
				case "powerMax":
					_local5 += _local4 + (1.5 * value).toFixed(1) + "%" + " " + Localize.t("inc maximum power") + _local6;
					break;
				case "cooldown":
				case "cooldown2":
				case "cooldown3":
					_local5 += _local4 + (0.1 * 1 * value).toFixed(1) + "% " + Localize.t("reduced cooldown") + _local6;
					break;
				case "increaseRecyleRate":
					_local5 += _local4 + value.toFixed(1) + "%" + Localize.t(" increased yield from recycling junk") + _local6;
					break;
				case "damageReduction":
					_local5 += _local4 + value.toFixed(1) + "%" + Localize.t(" damage reduction") + _local6;
					break;
				case "damageReductionWithLowHealth":
					_local5 += _local4 + value.toFixed(1) + "%" + Localize.t(" damage reduction with low health") + _local6;
					break;
				case "damageReductionWithLowShield":
					_local5 += _local4 + value.toFixed(1) + "%" + Localize.t(" damage reduction with low shield") + _local6;
					break;
				case "healthRegenAdd":
					_local5 += _local4 + value.toFixed(1) + Localize.t("% of maximum health regenerated every second") + _local6;
					break;
				case "shieldVamp":
					_local5 += Localize.t("Steals [value]% of damage done to enemy shields.").replace("[value]",value.toFixed(1)) + _local6;
					break;
				case "healthVamp":
					_local5 += Localize.t("Steals [value]% of damage done to enemy health.").replace("[value]",value.toFixed(1)) + _local6;
					break;
				case "kineticChanceToPenetrateShield":
					_local5 += Localize.t("• On Hit: <FONT COLOR=\'#ffccaa\'>[chance]%</FONT> chance to penetrate shield and deal <FONT COLOR=\'#ffccaa\'>25%</FONT> of total kinetic dmg to hull.").replace("[chance]",(0.1 * value).toFixed(1)) + _local6;
					break;
				case "energyChanceToShieldOverload":
					_local5 += Localize.t("• On Hit: <FONT COLOR=\'#ffccaa\'>[chance]%</FONT> chance to overload shield and deal <FONT COLOR=\'#ffccaa\'>400%</FONT> more energy damage.").replace("[chance]",(0.1 * value).toFixed(1)) + _local6;
					break;
				case "corrosiveChanceToIgnite":
					_local5 += Localize.t("• On Hit: <FONT COLOR=\'#ffccaa\'>[chance]%</FONT> chance to splice the hull and deal <FONT COLOR=\'#ffccaa\'>400%</FONT> more corrosive damage.").replace("[chance]",(0.1 * value).toFixed(1)) + _local6;
					break;
				case "beamAndMissileDoesBonusDamage":
					_local5 += Localize.t("• All Beam and Missile weapons do <FONT COLOR=\'#ffccaa\'>+[dmg]%</FONT> bonus damage.").replace("[dmg]",value.toFixed(1)) + _local6;
					break;
				case "recycleCatalyst":
					_local5 += Localize.t("• Increased the chance of finding rare material when recycling junk by <FONT COLOR=\'#ffccaa\'>50%</FONT> and increase yield with <FONT COLOR=\'#ffccaa\'>[rate]%</FONT>.").replace("[rate]",value.toFixed(1)) + _local6;
					break;
				case "velocityCore":
					_local5 += Localize.t("• Hyper-increases engine speed by <FONT COLOR=\'#ffccaa\'>[speed]%</FONT>.").replace("[speed]",(value * 2 * 0.1).toFixed(1)) + _local6;
					break;
				case "slowDown":
					_local5 += Localize.t("• Debuff: Temporarily slows down the enemy\'s speed by <FONT COLOR=\'#ffccaa\'>[value]%</FONT> for <FONT COLOR=\'#ffccaa\'>4</FONT> seconds.").replace("[value]",value.toFixed(0)) + _local6;
					break;
				case "damageReductionUnique":
					_local5 += "• <FONT COLOR=\'#ffccaa\'>" + value.toFixed(1) + "%" + Localize.t("</FONT> damage reduction.") + _local6;
					break;
				case "damageReductionWithLowHealthUnique":
					_local5 += "• <FONT COLOR=\'#ffccaa\'>" + value.toFixed(1) + "%" + Localize.t("</FONT> damage reduction with low health.") + _local6;
					break;
				case "damageReductionWithLowShieldUnique":
					_local5 += "• <FONT COLOR=\'#ffccaa\'>" + value.toFixed(1) + "%" + Localize.t("</FONT> damage reduction with low shield.") + _local6;
					break;
				case "damageReductionWhileStationaryUnique":
					_local5 += "• Fortress Lock: <FONT COLOR=\'#ffccaa\'>" + value.toFixed(1) + "%" + Localize.t("</FONT> damage reduction while stationary.") + _local6;
					break;
				case "overmind":
					_local5 += Localize.t("• Doubles number of pets and increase hp with <FONT COLOR=\'#ffccaa\'>50%</FONT>.") + _local6;
					break;
				case "upgrade":
					_local5 += Localize.t("• Greatly improves all ships with legacy hull, shield and armor.") + _local6;
					break;
				case "lucaniteCore":
					_local5 += Localize.t("• Debuff: Reduces targets damage by <FONT COLOR=\'#ffccaa\'>[value]%</FONT> over <FONT COLOR=\'#ffccaa\'>4</FONT> seconds.").replace("[value]",value.toFixed(1)) + _local6;
					break;
				case "mantisCore":
					_local5 += Localize.t("• <FONT COLOR=\'#ffccaa\'>[value]%</FONT> increased damage if target is close.").replace("[value]",value.toFixed(1)) + _local6;
					break;
				case "thermofangCore":
					_local5 += Localize.t("• Increased kinetic damage on burning targets with <FONT COLOR=\'#ffccaa\'>[value]%</FONT>.").replace("[value]",value.toFixed(1)) + _local6;
					break;
				case "reduceKineticResistance":
					_local5 += Localize.t("• Debuff: Reduces targets kinetic resistance by <FONT COLOR=\'#ffccaa\'>[value]%</FONT> over <FONT COLOR=\'#ffccaa\'>4</FONT> seconds.").replace("[value]",value.toFixed(1)) + _local6;
					break;
				case "reduceCorrosiveResistance":
					_local5 += Localize.t("• Debuff: Reduces targets corrosive resistance by <FONT COLOR=\'#ffccaa\'>[value]%</FONT> over <FONT COLOR=\'#ffccaa\'>4</FONT> seconds.").replace("[value]",value.toFixed(1)) + _local6;
					break;
				case "reduceEnergyResistance":
					_local5 += Localize.t("• Debuff: Reduces targets energy resistance by <FONT COLOR=\'#ffccaa\'>[value]%</FONT> over <FONT COLOR=\'#ffccaa\'>4</FONT> seconds.").replace("[value]",value.toFixed(1)) + _local6;
					break;
				case "crownOfXhersix":
					_local5 += Localize.t("• Emperor\'s Will: Automatically cleanse a debuff every <FONT COLOR=\'#ffccaa\'>[value]</FONT> seconds.").replace("[value]",value.toFixed(1)) + _local6;
					break;
				case "veilOfYhgvis":
					_local5 += Localize.t("• <FONT COLOR=\'#ffccaa\'>50%</FONT> damage reduction while cloaked and <FONT COLOR=\'#ffccaa\'>[value]%</FONT> damage bonus on ambush.").replace("[value]",value) + _local6;
					break;
				case "fistOfZharix":
					_local5 += Localize.t("• On Kill: Activates a shockwave on kill, damaging nearby enemies with <FONT COLOR=\'#ffccaa\'>[value]%</FONT> of total shield and health.").replace("[value]",value.toFixed(1)) + _local6;
					break;
				case "bloodlineSurge":
					_local5 += Localize.t("• On Kill: Gain <FONT COLOR=\'#ffccaa\'>+[value]%</FONT> total damage, and <FONT COLOR=\'#ffccaa\'>+[value2]%</FONT> reduced damage for <FONT COLOR=\'#ffccaa\'>6</FONT> seconds, stack up to <FONT COLOR=\'#ffccaa\'>3</FONT> times.").replace("[value]",value.toFixed(1)).replace("[value2]",(value * 0.5).toFixed(1)) + _local6;
					break;
				case "dotDamageUnique":
					_local5 += "• <FONT COLOR=\'#ffccaa\'>" + value.toFixed(1) + "%" + Localize.t("</FONT> damage on all debuffs.") + _local6;
					break;
				case "directDamageUnique":
					_local5 += "• <FONT COLOR=\'#ffccaa\'>" + value.toFixed(1) + "%" + Localize.t("</FONT> direct damage.") + _local6;
					break;
				case "reflectDamageUnique":
					_local5 += "• If Hit: Reflects <FONT COLOR=\'#ffccaa\'>" + value.toFixed(1) + Localize.t("</FONT> damage to attacker.") + _local6;
					break;
				default:
					_local5 += "ERROR, did not found artifact stat: " + type;
			}
			return _local5 + _local6;
		}
		
		public static function parseTextFromStatTypeShort(type:String, value:Number) : String {
			var _local3:String = "+";
			if(value < 0) {
				_local3 = "";
			}
			switch(type) {
				case "healthAdd":
				case "healthAdd2":
				case "healthAdd3":
					break;
				case "healthMulti":
					return _local3 + (1.35 * value).toFixed(1) + "% " + Localize.t("health");
				case "armorAdd":
				case "armorAdd2":
				case "armorAdd3":
					return _local3 + (7.5 * value).toFixed(0) + " " + Localize.t("armor");
				case "armorMulti":
					return _local3 + value.toFixed(1) + "% " + Localize.t("armor");
				case "corrosiveAdd":
				case "corrosiveAdd2":
				case "corrosiveAdd3":
					return _local3 + (4 * value).toFixed(0) + " " + Localize.t("corrosive dmg");
				case "corrosiveMulti":
					return _local3 + value.toFixed(1) + "% " + Localize.t("corrosive dmg");
				case "energyAdd":
				case "energyAdd2":
				case "energyAdd3":
					return _local3 + (4 * value).toFixed(0) + " " + Localize.t("energy dmg");
				case "energyMulti":
					return _local3 + value.toFixed(1) + "% " + Localize.t("energy dmg");
				case "kineticAdd":
				case "kineticAdd2":
				case "kineticAdd3":
					return _local3 + (4 * value).toFixed(0) + " " + Localize.t("kinetic dmg");
				case "kineticMulti":
					return _local3 + value.toFixed(1) + "% " + Localize.t("kinetic dmg");
				case "shieldAdd":
				case "shieldAdd2":
				case "shieldAdd3":
					return _local3 + (1.75 * value).toFixed(0) + " " + Localize.t("shield");
				case "shieldMulti":
					return _local3 + (1.35 * value).toFixed(1) + "% " + Localize.t("shield");
				case "shieldRegen":
					return _local3 + value.toFixed(0) + "% " + Localize.t("shield regen");
				case "corrosiveResist":
					return _local3 + value.toFixed(1) + "% " + Localize.t("corrosive resist");
				case "energyResist":
					return _local3 + value.toFixed(1) + "% " + Localize.t("energy resist");
				case "kineticResist":
					return value.toFixed(1) + "% " + Localize.t("kinetic resist");
				case "allResist":
					return _local3 + value.toFixed(1) + "% " + Localize.t("all resist");
				case "allAdd":
				case "allAdd2":
				case "allAdd3":
					return _local3 + (1.5 * value).toFixed(1) + " " + Localize.t("to all dmg");
				case "allMulti":
					return _local3 + (1.5 * value).toFixed(1) + "% " + Localize.t("to all dmg");
				case "speed":
				case "speed2":
				case "speed3":
					return _local3 + (0.1 * value).toFixed(2) + "% " + Localize.t("speed");
				case "refire":
				case "refire2":
				case "refire3":
					return _local3 + (3 * 0.1 * value).toFixed(1) + "% " + Localize.t("attack speed");
				case "convHp":
					if(0.1 * value > 100) {
						return "-100% " + Localize.t("hp to 150% shield");
					}
					return _local3 + (0.1 * value).toFixed(1) + "% " + Localize.t("hp to 150% shield");
					break;
				case "convShield":
					if(0.1 * value > 100) {
						return "-100% " + Localize.t("shield to 150% hp");
					}
					return _local3 + (0.1 * value).toFixed(1) + "% " + Localize.t("shield to 150% hp");
					break;
				case "powerReg":
				case "powerReg2":
				case "powerReg3":
					return _local3 + (0.1 * (1.5 * value)).toFixed(1) + "% " + Localize.t("power regen");
				case "powerMax":
					return _local3 + (1.5 * value).toFixed(1) + "% " + Localize.t("max power");
				case "cooldown":
				case "cooldown2":
				case "cooldown3":
					return "-" + (0.1 * value * 1).toFixed(1) + "% " + Localize.t("cooldown");
				case "increaseRecyleRate":
					return "+" + value.toFixed(1) + "%" + Localize.t(" increased yield from recycling junk.");
				default:
					return "ERROR - artifact stat not found: " + type;
			}
			return _local3 + (2 * value).toFixed(0) + " " + Localize.t("health");
		}
		
		public static function isUnique(type:String) : Boolean {
			switch(type) {
				case "slowDown":
				case "kineticChanceToPenetrateShield":
				case "energyChanceToShieldOverload":
				case "corrosiveChanceToIgnite":
				case "recycleCatalyst":
				case "beamAndMissileDoesBonusDamage":
				case "velocityCore":
				case "damageReductionUnique":
				case "damageReductionWithLowShieldUnique":
				case "damageReductionWithLowHealthUnique":
				case "damageReductionWhileStationaryUnique":
				case "overmind":
				case "upgrade":
				case "lucaniteCore":
				case "mantisCore":
				case "thermofangCore":
				case "reduceKineticResistance":
				case "reduceCorrosiveResistance":
				case "reduceEnergyResistance":
				case "crownOfXhersix":
				case "veilOfYhgvis":
				case "fistOfZharix":
				case "bloodlineSurge":
				case "dotDamageUnique":
				case "directDamageUnique":
				case "reflectDamageUnique":
					break;
				default:
					return false;
			}
			return true;
		}
		
		public function get isUnique() : Boolean {
			return ArtifactStat.isUnique(type);
		}
	}
}

