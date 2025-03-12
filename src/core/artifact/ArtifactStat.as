package core.artifact
{
	import generics.Localize;
	
	public class ArtifactStat
	{
		public var type:String;
		
		public var value:Number;
		
		public function ArtifactStat(param1:String, param2:Number)
		{
			super();
			this.type = param1;
			this.value = param2;
		}
		
		public static function parseTextFromStatType(param1:String, param2:Number):String
		{
			var _loc5_:String = "";
			var _loc3_:String = "<FONT COLOR='#ffffff'>";
			var _loc4_:String = "</FONT>";
			switch (param1)
			{
			case "healthAdd": 
			case "healthAdd2": 
			case "healthAdd3": 
				_loc5_ = _loc3_ + "+" + (2 * param2).toFixed(1) + _loc4_ + " " + Localize.t("health");
				break;
			case "healthMulti": 
				_loc5_ = _loc3_ + "+" + (1.35 * param2).toFixed(1) + "%" + _loc4_ + " " + Localize.t("health");
				break;
			case "armorAdd": 
			case "armorAdd2": 
			case "armorAdd3": 
				_loc5_ = _loc3_ + "+" + (7.5 * param2).toFixed(1) + _loc4_ + " " + Localize.t("armor");
				break;
			case "armorMulti": 
				_loc5_ = _loc3_ + "+" + param2.toFixed(1) + "%" + _loc4_ + " " + Localize.t("armor");
				break;
			case "corrosiveAdd": 
			case "corrosiveAdd2": 
			case "corrosiveAdd3": 
				_loc5_ = _loc3_ + "+" + (4 * param2).toFixed(1) + _loc4_ + " " + Localize.t("corrosive dmg");
				break;
			case "corrosiveMulti": 
				_loc5_ = _loc3_ + "+" + param2.toFixed(1) + "%" + _loc4_ + " " + Localize.t("corrosive dmg");
				break;
			case "energyAdd": 
			case "energyAdd2": 
			case "energyAdd3": 
				_loc5_ = _loc3_ + "+" + (4 * param2).toFixed(1) + _loc4_ + " " + Localize.t("energy dmg");
				break;
			case "energyMulti": 
				_loc5_ = _loc3_ + "+" + param2.toFixed(1) + "%" + _loc4_ + " " + Localize.t("energy dmg");
				break;
			case "kineticAdd": 
			case "kineticAdd2": 
			case "kineticAdd3": 
				_loc5_ = _loc3_ + "+" + (4 * param2).toFixed(1) + _loc4_ + " " + Localize.t("kinetic dmg");
				break;
			case "kineticMulti": 
				_loc5_ = _loc3_ + "+" + param2.toFixed(1) + "%" + _loc4_ + " " + Localize.t("kinetic dmg");
				break;
			case "shieldAdd": 
			case "shieldAdd2": 
			case "shieldAdd3": 
				_loc5_ = _loc3_ + "+" + (1.75 * param2).toFixed(1) + _loc4_ + " " + Localize.t("shield");
				break;
			case "shieldMulti": 
				_loc5_ = _loc3_ + "+" + (1.35 * param2).toFixed(1) + "%" + _loc4_ + " " + Localize.t("shield");
				break;
			case "shieldRegen": 
				_loc5_ = _loc3_ + "+" + param2.toFixed(1) + "%" + _loc4_ + " " + Localize.t("shield regen");
				break;
			case "corrosiveResist": 
				_loc5_ = _loc3_ + "+" + param2.toFixed(1) + "%" + _loc4_ + " " + Localize.t("corrosive resist");
				break;
			case "energyResist": 
				_loc5_ = _loc3_ + "+" + param2.toFixed(1) + "%" + _loc4_ + " " + Localize.t("energy resist");
				break;
			case "kineticResist": 
				_loc5_ = _loc3_ + "+" + param2.toFixed(1) + "%" + _loc4_ + " " + Localize.t("kinetic resist");
				break;
			case "allResist": 
				_loc5_ = _loc3_ + "+" + param2.toFixed(1) + "%" + _loc4_ + " " + Localize.t("all resist");
				break;
			case "allAdd": 
			case "allAdd2": 
			case "allAdd3": 
				_loc5_ = _loc3_ + "+" + (1.5 * param2).toFixed(1) + _loc4_ + " " + Localize.t("to all dmg");
				break;
			case "allMulti": 
				_loc5_ = _loc3_ + "+" + (1.5 * param2).toFixed(1) + "%" + _loc4_ + " " + Localize.t("to all dmg");
				break;
			case "speed": 
			case "speed2": 
			case "speed3": 
				_loc5_ = _loc3_ + "+" + (0.2 * param2).toFixed(2) + "%" + _loc4_ + " " + Localize.t("inc speed");
				break;
			case "refire": 
			case "refire2": 
			case "refire3": 
				_loc5_ = _loc3_ + "+" + (0.30000000000000004 * param2).toFixed(1) + "%" + _loc4_ + " " + Localize.t("inc attack speed");
				break;
			case "convHp": 
				if (0.1 * param2 > 100)
				{
					_loc5_ = _loc3_ + "-100%" + _loc4_ + " " + Localize.t("hp to 150% shield");
				}
				else
				{
					_loc5_ = _loc3_ + "-" + (0.1 * param2).toFixed(1) + "%" + _loc4_ + " " + Localize.t("hp to 150% shield");
				}
				break;
			case "convShield": 
				if (0.1 * param2 > 100)
				{
					_loc5_ = _loc3_ + "-100%" + _loc4_ + " " + Localize.t("shield to 150% hp");
				}
				else
				{
					_loc5_ = _loc3_ + "-" + (0.1 * param2).toFixed(1) + "%" + _loc4_ + " " + Localize.t("shield to 150% hp");
				}
				break;
			case "powerReg": 
			case "powerReg2": 
			case "powerReg3": 
				_loc5_ = _loc3_ + "+" + (0.15000000000000002 * param2).toFixed(1) + "%" + _loc4_ + " " + Localize.t("inc power regen");
				break;
			case "powerMax": 
				_loc5_ = _loc3_ + "+" + (1.5 * param2).toFixed(1) + "%" + _loc4_ + " " + Localize.t("inc maximum power");
				break;
			case "cooldown": 
			case "cooldown2": 
			case "cooldown3": 
				_loc5_ = _loc3_ + "+" + (0.1 * param2).toFixed(1) + "%" + _loc4_ + " " + Localize.t("reduced cooldown");
			}
			return _loc5_;
		}
		
		public static function parseTextFromStatTypeShort(param1:String, param2:Number):String
		{
			var _loc3_:String = "+";
			if (param2 < 0)
			{
				_loc3_ = "";
			}
			switch (param1)
			{
			case "healthAdd": 
			case "healthAdd2": 
			case "healthAdd3": 
				break;
			case "healthMulti": 
				return _loc3_ + (1.35 * param2).toFixed(1) + "% " + Localize.t("health");
			case "armorAdd": 
			case "armorAdd2": 
			case "armorAdd3": 
				return _loc3_ + (7.5 * param2).toFixed(0) + " " + Localize.t("armor");
			case "armorMulti": 
				return _loc3_ + param2.toFixed(1) + "% " + Localize.t("armor");
			case "corrosiveAdd": 
			case "corrosiveAdd2": 
			case "corrosiveAdd3": 
				return _loc3_ + (4 * param2).toFixed(0) + " " + Localize.t("corrosive dmg");
			case "corrosiveMulti": 
				return _loc3_ + param2.toFixed(1) + "% " + Localize.t("corrosive dmg");
			case "energyAdd": 
			case "energyAdd2": 
			case "energyAdd3": 
				return _loc3_ + (4 * param2).toFixed(0) + " " + Localize.t("energy dmg");
			case "energyMulti": 
				return _loc3_ + param2.toFixed(1) + "% " + Localize.t("energy dmg");
			case "kineticAdd": 
			case "kineticAdd2": 
			case "kineticAdd3": 
				return _loc3_ + (4 * param2).toFixed(0) + " " + Localize.t("kinetic dmg");
			case "kineticMulti": 
				return _loc3_ + param2.toFixed(1) + "% " + Localize.t("kinetic dmg");
			case "shieldAdd": 
			case "shieldAdd2": 
			case "shieldAdd3": 
				return _loc3_ + (2 * param2).toFixed(0) + " " + Localize.t("shield");
			case "shieldMulti": 
				return _loc3_ + (1.35 * param2).toFixed(1) + "% " + Localize.t("shield");
			case "shieldRegen": 
				return _loc3_ + param2.toFixed(0) + "% " + Localize.t("shield regen");
			case "corrosiveResist": 
				return _loc3_ + param2.toFixed(1) + "% " + Localize.t("corrosive resist");
			case "energyResist": 
				return _loc3_ + param2.toFixed(1) + "% " + Localize.t("energy resist");
			case "kineticResist": 
				return param2.toFixed(1) + "% " + Localize.t("kinetic resist");
			case "allResist": 
				return _loc3_ + param2.toFixed(1) + "% " + Localize.t("all resist");
			case "allAdd": 
			case "allAdd2": 
			case "allAdd3": 
				return _loc3_ + (1.5 * param2).toFixed(1) + " " + Localize.t("to all dmg");
			case "allMulti": 
				return _loc3_ + (1.35 * param2).toFixed(1) + "% " + Localize.t("to all dmg");
			case "speed": 
			case "speed2": 
			case "speed3": 
				return _loc3_ + (0.1 * param2).toFixed(2) + "% " + Localize.t("speed");
			case "refire": 
			case "refire2": 
			case "refire3": 
				return _loc3_ + (0.30000000000000004 * param2).toFixed(1) + "% " + Localize.t("attack speed");
			case "convHp": 
				if (0.1 * param2 > 100)
				{
					return "-100% " + Localize.t("hp to 150% shield");
				}
				return _loc3_ + (0.1 * param2).toFixed(1) + "% " + Localize.t("hp to 150% shield");
				break;
			case "convShield": 
				if (0.1 * param2 > 100)
				{
					return "-100% " + Localize.t("shield to 150% hp");
				}
				return _loc3_ + (0.1 * param2).toFixed(1) + "% " + Localize.t("shield to 150% hp");
				break;
			case "powerReg": 
			case "powerReg2": 
			case "powerReg3": 
				return _loc3_ + (0.1 * (1 * param2)).toFixed(1) + "% " + Localize.t("power regen");
			case "powerMax": 
				return _loc3_ + (1 * param2).toFixed(1) + "% " + Localize.t("max power");
			case "cooldown": 
			case "cooldown2": 
			case "cooldown3": 
				return "-" + (0.1 * param2).toFixed(1) + "% " + Localize.t("cooldown");
			default: 
				return "ERROR - artifact not found";
			}
			return _loc3_ + (2 * param2).toFixed(0) + " " + Localize.t("health");
		}
	}
}
