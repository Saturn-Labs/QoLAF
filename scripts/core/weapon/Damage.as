package core.weapon {
	import generics.Localize;
	
	public class Damage {
		public static const SINGLETYPES:int = 5;
		
		public static const TOTALTYPES:int = 10;
		
		public static const KINETIC:int = 0;
		
		public static const ENERGY:int = 1;
		
		public static const CORROSIVE:int = 2;
		
		public static const KINNETICENERGY:int = 3;
		
		public static const CORROSIVEKINNETIC:int = 4;
		
		public static const ALL:int = 5;
		
		public static const HEAL:int = 6;
		
		public static const KINNETICENERGYCORROSIVE:int = 7;
		
		public static const DONT_SCALE:int = 8;
		
		public static const ENERGYCORROSIVE:int = 9;
		
		public static const RESISTANCE_CAP:int = 75;
		
		public static const TYPE:Vector.<String> = Vector.<String>(["Kinetic","Energy","Corrosive","50% Kinetic + 50% Energy","50% Corrosive + 50% Kinetic","","Health","33% Energy + 33% Kinetic + 33% Corrosive","None","50% Energy + 50% Corrosive"]);
		
		public static const TYPE_HTML:Vector.<String> = Vector.<String>(["<FONT COLOR=\'#00ffff\'>Kinetic</FONT>","<FONT COLOR=\'#ff030d\'>Energy</FONT>","<FONT COLOR=\'#009900\'>Corrosive</FONT>","<FONT COLOR=\'#00ffff\'>Kinetic</FONT> + <FONT COLOR=\'#ff030d\'>Energy</FONT>","<FONT COLOR=\'#009900\'>Corrosive</FONT> + <FONT COLOR=\'#00ffff\'>Kinetic</FONT>","<FONT COLOR=\'#ffffff\'>All</FONT>","<FONT COLOR=\'#00ff00\'>Health</FONT>","<FONT COLOR=\'#00ffff\'>Kinetic</FONT> + <FONT COLOR=\'#ff030d\'>Energy</FONT> + <FONT COLOR=\'#009900\'>Corrosive</FONT>","<FONT COLOR=\'#ff0000\'>Don\'t scale</FONT>","<FONT COLOR=\'#ff030d\'>Energy</FONT> + <FONT COLOR=\'#009900\'>Corrosive</FONT>"]);
		
		public static const SINGLETYPE_HTML:Vector.<String> = Vector.<String>(["<FONT COLOR=\'#00ffff\'>Kinetic</FONT>","<FONT COLOR=\'#ff030d\'>Energy</FONT>","<FONT COLOR=\'#009900\'>Corrosive</FONT>","<FONT COLOR=\'#00ff00\'>Health</FONT>","<FONT COLOR=\'#ff0000\'>Special</FONT>"]);
		
		public static const stats:Vector.<Vector.<Number>> = Vector.<Vector.<Number>>([Vector.<Number>([1,0,0,0,0]),Vector.<Number>([0,1,0,0,0]),Vector.<Number>([0,0,1,0,0]),Vector.<Number>([0.5,0.5,0,0,0]),Vector.<Number>([0.5,0,0.5,0,0]),Vector.<Number>([1,1,1,0,0]),Vector.<Number>([0,0,0,1,0]),Vector.<Number>([0.33,0.33,0.33,0,0]),Vector.<Number>([0,0,0,0,1]),Vector.<Number>([0,0.5,0.5,0,0])]);
		
		public var type:int;
		
		private var damage:Vector.<Number>;
		
		private var damageBase:Vector.<Number>;
		
		public function Damage(dmg:Number, type:int) {
			var _local3:int = 0;
			super();
			this.type = type;
			damage = new Vector.<Number>();
			damageBase = new Vector.<Number>();
			_local3 = 0;
			while(_local3 < 5) {
				damageBase.push(dmg * stats[type][_local3]);
				damage.push(dmg * stats[type][_local3]);
				_local3++;
			}
		}
		
		public function dmg() : Number {
			var _local1:int = 0;
			var _local2:Number = 0;
			_local1 = 0;
			while(_local1 < 5) {
				_local2 += damage[_local1];
				_local1++;
			}
			return _local2;
		}
		
		public function damageText() : String {
			var _local1:int = 0;
			var _local2:String = "";
			_local1 = 0;
			while(_local1 < 3) {
				if(damage[_local1] > 0) {
					if(_local2 == "") {
						_local2 += "Deals: ";
					} else {
						_local2 += " + ";
					}
					_local2 += "<FONT COLOR=\'#eeeeee\'>" + damage[_local1].toFixed(0) + "</FONT> " + Damage.SINGLETYPE_HTML[_local1] + " Damage";
				}
				_local1++;
			}
			if(damage[_local1] > 0) {
				_local2 += "Repairs: <FONT COLOR=\'#eeeeee\'>" + damage[_local1].toFixed(0) + "</FONT> " + Damage.SINGLETYPE_HTML[_local1];
			}
			if(_local2 != "") {
				_local2 += " per hit. \n";
			}
			return _local2;
		}
		
		public function debuffdamageText(debuffMod:Number, debuffDuration:int, s:String) : String {
			var _local4:int = 0;
			var _local5:String = "";
			_local4 = 0;
			while(_local4 < 3) {
				if(damage[_local4] > 0) {
					_local5 += Localize.t("Deals <FONT COLOR=\'#eeeeee\'>[damage]</FONT> [type] " + s + " <FONT COLOR=\'#eeeeee\'>[duration]</FONT> seconds \n").replace("[damage]",Math.ceil(debuffMod * damage[_local4]).toFixed(0)).replace("[type]",Damage.SINGLETYPE_HTML[_local4]).replace("[duration]",debuffDuration);
				}
				_local4++;
			}
			if(damage[_local4] > 0) {
				_local5 += Localize.t("Repairs <FONT COLOR=\'#eeeeee\'>[damage]</FONT> [type] " + s + " <FONT COLOR=\'#eeeeee\'>[duration]</FONT> seconds \n").replace("[damage]",Math.ceil(debuffMod * damage[_local4]).toFixed(0)).replace("[type]",Damage.SINGLETYPE_HTML[_local4]).replace("[duration]",debuffDuration);
			}
			return _local5;
		}
		
		public function setBaseDmg(dmg:Number) : void {
			var _local2:int = 0;
			if(type == 8) {
				return;
			}
			_local2 = 0;
			while(_local2 < 5) {
				damageBase[_local2] = dmg * stats[type][_local2];
				damage[_local2] = dmg * stats[type][_local2];
				_local2++;
			}
		}
		
		public function addBaseDmg(dmg:Number, type:int = -1) : void {
			var _local3:int = 0;
			if(type == 8) {
				return;
			}
			if(type == -1) {
				type = this.type;
			}
			_local3 = 0;
			while(_local3 < 5) {
				var _local4:* = _local3;
				var _local5:* = damage[_local4] + dmg * stats[type][_local3];
				damage[_local4] = _local5;
				damageBase[_local3] += dmg * stats[type][_local3];
				_local3++;
			}
		}
		
		public function addBasePercent(percent:Number, type:int = -1) : void {
			var _local3:int = 0;
			if(type == 8) {
				return;
			}
			if(type == -1) {
				type = this.type;
			}
			_local3 = 0;
			while(_local3 < 5) {
				var _local4:* = _local3;
				var _local5:* = damage[_local4] + damageBase[_local3] * percent * stats[type][_local3] / 100;
				damage[_local4] = _local5;
				damageBase[_local3] += damageBase[_local3] * percent * stats[type][_local3] / 100;
				_local3++;
			}
		}
		
		public function addDmgInt(dmg:int, type:int = -1) : void {
			var _local3:int = 0;
			if(type == -1) {
				type = this.type;
			}
			_local3 = 0;
			while(_local3 < 5) {
				if(damage[_local3] > 0) {
					var _local4:* = _local3;
					var _local5:* = damage[_local4] + dmg * stats[type][_local3];
					damage[_local4] = _local5;
				}
				_local3++;
			}
		}
		
		public function addDmgPercent(bonus:Number, type:int = -1) : void {
			var _local3:int = 0;
			if(type == -1) {
				type = this.type;
			}
			_local3 = 0;
			while(_local3 < 5) {
				if(stats[type][_local3] > 0) {
					var _local4:* = _local3;
					var _local5:* = damage[_local4] + damageBase[_local3] * bonus / 100;
					damage[_local4] = _local5;
				}
				_local3++;
			}
		}
		
		public function addLevelBonus(level:int, bonus:Number) : void {
			var _local3:int = 0;
			if(type == 8) {
				return;
			}
			_local3 = 0;
			while(_local3 < 5) {
				damage[_local3] = damageBase[_local3] * (100 + bonus * (level - 1)) / 100;
				damageBase[_local3] = damageBase[_local3] * (100 + bonus * (level - 1)) / 100;
				_local3++;
			}
		}
	}
}

