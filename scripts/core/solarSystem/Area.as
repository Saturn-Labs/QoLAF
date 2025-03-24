package core.solarSystem {
	import core.hud.components.TextBitmap;
	import core.player.CrewMember;
	
	public class Area {
		public static const TOTALSKILLTYPES:int = 3;
		
		public static const MINEVENTS:int = 4;
		
		public static const TOTALSPECIALTYPES:int = 9;
		
		public static const SKILLTYPE:Vector.<String> = Vector.<String>(["Survival","Diplomacy","Combat"]);
		
		public static const SKILLTYPEHTML:Vector.<String> = Vector.<String>(["Survival","Diplomacy","Combat"]);
		
		public static const REWARD_ACTIONS:Vector.<Array> = Vector.<Array>([["Salvaged","Discovered","Excavated"],["Bribe","Smuggled","Traded"],["Stole","Pillaged","Robbed"]]);
		
		public static const SPECIALTYPE:Vector.<String> = Vector.<String>(["Cold","Heat","Radiation","First Contact","Trade","Collaboration","Kinetic Weapons","Energy Weapons","Bio Weapons"]);
		
		public static const SPECIALTYPEHTML:Vector.<String> = Vector.<String>(["<FONT COLOR=\'#4682B4\'>" + SPECIALTYPE[0] + "</FONT>","<FONT COLOR=\'#FF2400\'>" + SPECIALTYPE[1] + "</FONT>","<FONT COLOR=\'#9CCB19\'>" + SPECIALTYPE[2] + "</FONT>","<FONT COLOR=\'#8B0000\'>" + SPECIALTYPE[3] + "</FONT>","<FONT COLOR=\'#7B0000\'>" + SPECIALTYPE[4] + "</FONT>","<FONT COLOR=\'#9151ff\'>" + SPECIALTYPE[5] + "</FONT>","<FONT COLOR=\'#ffffff\'>" + SPECIALTYPE[6] + "</FONT>","<FONT COLOR=\'#ffdfdf\'>" + SPECIALTYPE[7] + "</FONT>","<FONT COLOR=\'#23ff23\'>" + SPECIALTYPE[8] + "</FONT>"]);
		
		public static const SPECIALCOLORTYPE:Vector.<uint> = Vector.<uint>([4620980,16720896,10275609,9109504,8060928,9523711,0xffffff,0xffdfdf,2359075]);
		
		public static const COLORTYPE:Vector.<uint> = Vector.<uint>([0x55ff55,0x5555ff,0xff3333]);
		
		public static const COLORTYPESTR:Vector.<String> = Vector.<String>(["#55ff55","#5555ff","#ff3333"]);
		
		public static const COLORTYPEFILL:Vector.<uint> = Vector.<uint>([0x22bb22,0x2222bb,0xbb1111]);
		
		public static const SIZE:Vector.<String> = Vector.<String>(["Tiny","Small","Small","Medium","Medium","Large","Large","Very Large","Very Large","Gigantic"]);
		
		public function Area() {
			super();
		}
		
		public static function getSkillType(i:int) : String {
			return SKILLTYPE[i];
		}
		
		public static function getSkillTypeHtml(i:int) : String {
			return SKILLTYPEHTML[i];
		}
		
		public static function getRewardAction(type:int) : String {
			return REWARD_ACTIONS[type][Math.floor(Math.random() * 3)];
		}
		
		public static function getSpecialIndex(name:String) : int {
			var _local2:int = 0;
			_local2 = 0;
			while(_local2 < SPECIALTYPE.length) {
				if(SPECIALTYPE[_local2] == name) {
					return _local2;
				}
				_local2++;
			}
			return -1;
		}
		
		public static function getSizeString(i:int) : String {
			return SIZE[i - 1];
		}
		
		public static function getSpecialType(i:int) : String {
			return SPECIALTYPE[i];
		}
		
		public static function getSpecialTypeHtml(i:int) : String {
			return SPECIALTYPEHTML[i];
		}
		
		public static function getTime(size:int, skillLevel:int, rewardLevel:int, types:Array, crewLevel:int = 0) : int {
			var _local6:Number = skillLevel - crewLevel;
			if(_local6 < -12) {
				_local6 = -12;
			}
			return (0.2 * types.length + 1) * (1 + 0.05 * _local6 + 0.2 * rewardLevel) * (30 * Math.pow(2,size - 1));
		}
		
		public static function getSuccessChance(skillLevel:Number, type:int, crew:CrewMember, types:Array) : Number {
			var _local5:Number = NaN;
			var _local8:Number = NaN;
			var _local6:Number = Number(crew.skills[type]);
			if(_local6 >= skillLevel) {
				_local5 = 0.9 + 0.02 * (_local6 - skillLevel);
			} else if(_local6 > skillLevel - 10) {
				_local8 = 0.1 * (_local6 - skillLevel + 10);
				_local5 = Math.acos(1 - 2 * _local8) / 3.141592653589793;
			} else {
				_local5 = 0;
			}
			for each(var _local7 in types) {
				_local5 *= crew.specials[_local7] || 0;
			}
			if(_local5 > 1) {
				_local5 = 1;
			}
			return _local5;
		}
		
		public static function injuryRiskText(areaLevel:Number, type:int, size:int, crew:CrewMember, types:Array) : TextBitmap {
			var _local6:Number = Number(crew.skills[type]);
			var _local7:Number = 0;
			if(_local6 > areaLevel) {
				_local7 = 0.01;
			} else if(_local6 > areaLevel - 46) {
				_local7 = 0.01 + 0.02 * (areaLevel - _local6);
			} else {
				_local7 = 1;
			}
			var _local8:Number = 0;
			for each(var _local9 in types) {
				if(Number(crew.specials[_local9]) < 0.5) {
					_local8 += 0.5;
				}
			}
			_local8 += (size - 1) * 0.05;
			_local7 *= 1 + _local8;
			var _local10:TextBitmap = new TextBitmap();
			if(_local7 > 0.75) {
				_local10.text = "Extreme";
				_local10.format.color = 0xff0000;
			} else if(_local7 >= 0.25) {
				_local10.text = "High";
				_local10.format.color = 0xff0000;
			} else if(_local7 > 0.18) {
				_local10.text = "Moderate";
				_local10.format.color = 0xff3300;
			} else if(_local7 > 0.1) {
				_local10.text = "Some";
				_local10.format.color = 0xff6600;
			} else if(_local7 > 0.05) {
				_local10.text = "Low";
				_local10.format.color = 0xeeee00;
			} else if(_local7 > 0.01) {
				_local10.text = "Small";
				_local10.format.color = 11403055;
			} else if(_local7 > 0) {
				_local10.text = "Minimal";
				_local10.format.color = 11403055;
			} else {
				_local10.text = "None";
				_local10.format.color = 6159370;
			}
			_local10.text = _local10.text.toLocaleUpperCase();
			return _local10;
		}
	}
}

