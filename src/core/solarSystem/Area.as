package core.solarSystem
{
	import core.hud.components.TextBitmap;
	import core.player.CrewMember;
	
	public class Area
	{
		public static const TOTALSKILLTYPES:int = 3;
		public static const MINEVENTS:int = 4;
		public static const TOTALSPECIALTYPES:int = 9;
		public static const SKILLTYPE:Vector.<String> = Vector.<String>(["Survival", "Diplomacy", "Combat"]);
		
		public static const SKILLTYPEHTML:Vector.<String> = Vector.<String>(["Survival", "Diplomacy", "Combat"]);
		
		public static const REWARD_ACTIONS:Vector.<Array> = Vector.<Array>([["Salvaged", "Discovered", "Excavated"], ["Bribe", "Smuggled", "Traded"], ["Stole", "Pillaged", "Robbed"]]);
		
		public static const SPECIALTYPE:Vector.<String> = Vector.<String>(["Cold", "Heat", "Radiation", "First Contact", "Trade", "Collaboration", "Kinetic Weapons", "Energy Weapons", "Bio Weapons"]);
		
		public static const SPECIALTYPEHTML:Vector.<String> = Vector.<String>(["<FONT COLOR='#4682B4'>" + SPECIALTYPE[0] + "</FONT>", "<FONT COLOR='#FF2400'>" + SPECIALTYPE[1] + "</FONT>", "<FONT COLOR='#9CCB19'>" + SPECIALTYPE[2] + "</FONT>", "<FONT COLOR='#8B0000'>" + SPECIALTYPE[3] + "</FONT>", "<FONT COLOR='#7B0000'>" + SPECIALTYPE[4] + "</FONT>", "<FONT COLOR='#9151ff'>" + SPECIALTYPE[5] + "</FONT>", "<FONT COLOR='#ffffff'>" + SPECIALTYPE[6] + "</FONT>", "<FONT COLOR='#ffdfdf'>" + SPECIALTYPE[7] + "</FONT>", "<FONT COLOR='#23ff23'>" + SPECIALTYPE[8] + "</FONT>"]);
		
		public static const SPECIALCOLORTYPE:Vector.<uint> = Vector.<uint>([4620980, 16720896, 10275609, 9109504, 8060928, 9523711, 16777215, 16768991, 2359075]);
		
		public static const COLORTYPE:Vector.<uint> = Vector.<uint>([5635925, 5592575, 16724787]);
		
		public static const COLORTYPESTR:Vector.<String> = Vector.<String>(["#55ff55", "#5555ff", "#ff3333"]);
		
		public static const COLORTYPEFILL:Vector.<uint> = Vector.<uint>([2276130, 2237115, 12259601]);
		
		public static const SIZE:Vector.<String> = Vector.<String>(["Tiny", "Small", "Small", "Medium", "Medium", "Large", "Large", "Very Large", "Very Large", "Gigantic"]);
		
		public function Area()
		{
			super();
		}
		
		public static function getSkillType(param1:int):String
		{
			return SKILLTYPE[param1];
		}
		
		public static function getSkillTypeHtml(param1:int):String
		{
			return SKILLTYPEHTML[param1];
		}
		
		public static function getRewardAction(param1:int):String
		{
			return REWARD_ACTIONS[param1][Math.floor(Math.random() * 3)];
		}
		
		public static function getSpecialIndex(param1:String):int
		{
			var _loc2_:int = 0;
			_loc2_ = 0;
			while (_loc2_ < SPECIALTYPE.length)
			{
				if (SPECIALTYPE[_loc2_] == param1)
				{
					return _loc2_;
				}
				_loc2_++;
			}
			return -1;
		}
		
		public static function getSizeString(param1:int):String
		{
			return SIZE[param1 - 1];
		}
		
		public static function getSpecialType(param1:int):String
		{
			return SPECIALTYPE[param1];
		}
		
		public static function getSpecialTypeHtml(param1:int):String
		{
			return SPECIALTYPEHTML[param1];
		}
		
		public static function getTime(param1:int, param2:int, param3:int, param4:Array, param5:int = 0):int
		{
			var _loc6_:Number = param2 - param5;
			if (_loc6_ < -12)
			{
				_loc6_ = -12;
			}
			return (0.2 * param4.length + 1) * (1 + 0.05 * _loc6_ + 0.2 * param3) * (30 * Math.pow(2, param1 - 1));
		}
		
		public static function getSuccessChance(param1:Number, param2:int, param3:CrewMember, param4:Array):Number
		{
			var _loc7_:Number = NaN;
			var _loc6_:Number = NaN;
			var _loc5_:Number = Number(param3.skills[param2]);
			if (_loc5_ >= param1)
			{
				_loc7_ = 0.9 + 0.02 * (_loc5_ - param1);
			}
			else if (_loc5_ > param1 - 10)
			{
				_loc6_ = 0.1 * (_loc5_ - param1 + 10);
				_loc7_ = Math.acos(1 - 2 * _loc6_) / 3.141592653589793;
			}
			else
			{
				_loc7_ = 0;
			}
			for each (var _loc8_:* in param4)
			{
				_loc7_ *= param3.specials[_loc8_] || 0;
			}
			if (_loc7_ > 1)
			{
				_loc7_ = 1;
			}
			return _loc7_;
		}
		
		public static function injuryRiskText(param1:Number, param2:int, param3:int, param4:CrewMember, param5:Array):TextBitmap
		{
			var _loc6_:Number = Number(param4.skills[param2]);
			var _loc8_:Number = 0;
			if (_loc6_ > param1)
			{
				_loc8_ = 0.01;
			}
			else if (_loc6_ > param1 - 46)
			{
				_loc8_ = 0.01 + 0.02 * (param1 - _loc6_);
			}
			else
			{
				_loc8_ = 1;
			}
			var _loc9_:Number = 0;
			for each (var _loc10_:* in param5)
			{
				if (Number(param4.specials[_loc10_]) < 0.5)
				{
					_loc9_ += 0.5;
				}
			}
			_loc9_ += (param3 - 1) * 0.05;
			_loc8_ *= 1 + _loc9_;
			var _loc7_:TextBitmap = new TextBitmap();
			if (_loc8_ > 0.75)
			{
				_loc7_.text = "Extreme";
				_loc7_.format.color = 16711680;
			}
			else if (_loc8_ >= 0.25)
			{
				_loc7_.text = "High";
				_loc7_.format.color = 16711680;
			}
			else if (_loc8_ > 0.18)
			{
				_loc7_.text = "Moderate";
				_loc7_.format.color = 16724736;
			}
			else if (_loc8_ > 0.1)
			{
				_loc7_.text = "Some";
				_loc7_.format.color = 16737792;
			}
			else if (_loc8_ > 0.05)
			{
				_loc7_.text = "Low";
				_loc7_.format.color = 15658496;
			}
			else if (_loc8_ > 0.01)
			{
				_loc7_.text = "Small";
				_loc7_.format.color = 11403055;
			}
			else if (_loc8_ > 0)
			{
				_loc7_.text = "Minimal";
				_loc7_.format.color = 11403055;
			}
			else
			{
				_loc7_.text = "None";
				_loc7_.format.color = 6159370;
			}
			_loc7_.text = _loc7_.text.toLocaleUpperCase();
			return _loc7_;
		}
	}
}
