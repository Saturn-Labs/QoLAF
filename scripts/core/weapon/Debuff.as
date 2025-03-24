package core.weapon {
	import generics.Localize;
	
	public class Debuff {
		public static const TOTALTYPES:int = 12;
		
		public static const DOT:int = 0;
		
		public static const DOT_STACKING:int = 1;
		
		public static const BOMB:int = 2;
		
		public static const REDUCE_ARMOR:int = 3;
		
		public static const BURN:int = 4;
		
		public static const DISABLE_REGEN:int = 5;
		
		public static const DISABLE_HEAL:int = 6;
		
		public static const REDUCED_DAMAGE:int = 7;
		
		public static const REDUCED_KINETIC_RESIST:int = 8;
		
		public static const REDUCED_ENERGY_RESIST:int = 9;
		
		public static const REDUCED_CORROSIVE_RESIST:int = 10;
		
		public static const SLOW_DOWN:int = 11;
		
		public function Debuff() {
			super();
		}
		
		public static function debuffText(debuffType:int, debuffDuration:int, debuffValue:Damage) : String {
			var _local5:String = "";
			var _local4:String = "";
			if(debuffType == 0 || debuffType == 1) {
				_local4 = " over";
				_local5 += debuffValue.debuffdamageText(debuffDuration,debuffDuration,_local4);
				if(debuffType == 1) {
					_local5 += Localize.t("\nThe debuff stacks.\n");
				}
			} else if(debuffType == 2) {
				_local4 = " after";
				_local5 += debuffValue.debuffdamageText(3,debuffDuration,_local4);
			} else if(debuffType == 3) {
				_local5 += Localize.t("<FONT COLOR=\'#eeeeee\'>[value]</FONT> reduced armor per stack for <FONT COLOR=\'#eeeeee\'>[duration]</FONT> seconds").replace("[value]",debuffValue.dmg().toFixed(0)).replace("[duration]",debuffDuration);
				_local5 = _local5 + Localize.t("\nCan reduce armor below zero for a maximum bonus of +50%.\n");
				_local5 = _local5 + Localize.t("\nThe debuff stacks up to 100x.\n");
			} else if(debuffType == 4) {
				_local4 = " over";
				_local5 += debuffValue.debuffdamageText(0.5 * debuffDuration,debuffDuration,_local4);
				_local5 = _local5 + Localize.t("\nThe debuff decays over time\n");
			} else if(debuffType == 5) {
				_local5 += Localize.t("Disables shield regeneration for <FONT COLOR=\'#eeeeee\'>[duration]</FONT> seconds \n").replace("[duration]",debuffDuration);
			} else if(debuffType == 6) {
				_local5 += Localize.t("Disables healing for <FONT COLOR=\'#eeeeee\'>[duration]</FONT> seconds \n").replace("[duration]",debuffDuration);
			} else if(debuffType == 7) {
				_local5 += Localize.t("Reduces target\'s damage by <FONT COLOR=\'#eeeeee\'>[value]%</FONT> for <FONT COLOR=\'#eeeeee\'>[duration]</FONT> seconds \n").replace("[value]",debuffValue.dmg().toFixed(0)).replace("[duration]",debuffDuration);
			} else if(debuffType == 8) {
				_local5 += Localize.t("Reduces target\'s <FONT COLOR=\'#00ffff\'>Kinetic</FONT> resistance by <FONT COLOR=\'#eeeeee\'>[value]%</FONT> for <FONT COLOR=\'#eeeeee\'>[duration]</FONT> seconds \n").replace("[value]",debuffValue.dmg().toFixed(0)).replace("[duration]",debuffDuration);
			} else if(debuffType == 9) {
				_local5 += Localize.t("Reduces target\'s <FONT COLOR=\'#ff030d\'>Energy</FONT> resistance by <FONT COLOR=\'#eeeeee\'>[value]%</FONT> for <FONT COLOR=\'#eeeeee\'>[duration]</FONT> seconds \n").replace("[value]",debuffValue.dmg().toFixed(0)).replace("[duration]",debuffDuration);
			} else if(debuffType == 10) {
				_local5 += Localize.t("Reduces target\'s <FONT COLOR=\'#009900\'>Corrosive</FONT> resistance by <FONT COLOR=\'#eeeeee\'>[value]%</FONT> for <FONT COLOR=\'#eeeeee\'>[duration]</FONT> seconds \n").replace("[value]",debuffValue.dmg().toFixed(0)).replace("[duration]",debuffDuration);
			} else if(debuffType == 11) {
				_local5 += Localize.t("Reduces target\'s speed by <FONT COLOR=\'#eeeeee\'>[value]%</FONT> for <FONT COLOR=\'#eeeeee\'>[duration]</FONT> seconds \n").replace("[value]",debuffValue.dmg().toFixed(0)).replace("[duration]",debuffDuration);
			}
			return _local5;
		}
	}
}

