package core.weapon
{
	import generics.Localize;
	
	public class Damage
	{
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
		public static const TYPE:Vector.<String> = Vector.<String>(["Kinetic", "Energy", "Corrosive", "50% Kinetic + 50% Energy", "50% Corrosive + 50% Kinetic", "", "Health", "33% Energy + 33% Kinetic + 33% Corrosive", "None", "50% Energy + 50% Corrosive"]);
		
		public static const TYPE_HTML:Vector.<String> = Vector.<String>(["<FONT COLOR='#00ffff'>Kinetic</FONT>", "<FONT COLOR='#ff030d'>Energy</FONT>", "<FONT COLOR='#009900'>Corrosive</FONT>", "<FONT COLOR='#00ffff'>Kinetic</FONT> + <FONT COLOR='#ff030d'>Energy</FONT>", "<FONT COLOR='#009900'>Corrosive</FONT> + <FONT COLOR='#00ffff'>Kinetic</FONT>", "<FONT COLOR='#ffffff'>All</FONT>", "<FONT COLOR='#00ff00'>Health</FONT>", "<FONT COLOR='#00ffff'>Kinetic</FONT> + <FONT COLOR='#ff030d'>Energy</FONT> + <FONT COLOR='#009900'>Corrosive</FONT>", "<FONT COLOR='#ff0000'>Don't scale</FONT>", "<FONT COLOR='#ff030d'>Energy</FONT> + <FONT COLOR='#009900'>Corrosive</FONT>"]);
		
		public static const SINGLETYPE_HTML:Vector.<String> = Vector.<String>(["<FONT COLOR='#00ffff'>Kinetic</FONT>", "<FONT COLOR='#ff030d'>Energy</FONT>", "<FONT COLOR='#009900'>Corrosive</FONT>", "<FONT COLOR='#00ff00'>Health</FONT>", "<FONT COLOR='#ff0000'>Special</FONT>"]);
		
		public static const stats:Vector.<Vector.<Number>> = Vector.<Vector.<Number>>([Vector.<Number>([1, 0, 0, 0, 0]), Vector.<Number>([0, 1, 0, 0, 0]), Vector.<Number>([0, 0, 1, 0, 0]), Vector.<Number>([0.5, 0.5, 0, 0, 0]), Vector.<Number>([0.5, 0, 0.5, 0, 0]), Vector.<Number>([1, 1, 1, 0, 0]), Vector.<Number>([0, 0, 0, 1, 0]), Vector.<Number>([0.33, 0.33, 0.33, 0, 0]), Vector.<Number>([0, 0, 0, 0, 1]), Vector.<Number>([0, 0.5, 0.5, 0, 0])]);
		
		public var type:int;
		
		private var damage:Vector.<Number>;
		
		private var damageBase:Vector.<Number>;
		
		public function Damage(param1:Number, param2:int)
		{
			var _loc3_:int = 0;
			super();
			this.type = param2;
			damage = new Vector.<Number>();
			damageBase = new Vector.<Number>();
			_loc3_ = 0;
			while (_loc3_ < 5)
			{
				damageBase.push(param1 * stats[param2][_loc3_]);
				damage.push(param1 * stats[param2][_loc3_]);
				_loc3_++;
			}
		}
		
		public function dmg():Number
		{
			var _loc2_:int = 0;
			var _loc1_:Number = 0;
			_loc2_ = 0;
			while (_loc2_ < 5)
			{
				_loc1_ += damage[_loc2_];
				_loc2_++;
			}
			return _loc1_;
		}
		
		public function damageText():String
		{
			var _loc2_:int = 0;
			var _loc1_:String = "";
			_loc2_ = 0;
			while (_loc2_ < 3)
			{
				if (damage[_loc2_] > 0)
				{
					if (_loc1_ == "")
					{
						_loc1_ += "Deals: ";
					}
					else
					{
						_loc1_ += " + ";
					}
					_loc1_ += "<FONT COLOR='#eeeeee'>" + damage[_loc2_].toFixed(0) + "</FONT> " + Damage.SINGLETYPE_HTML[_loc2_] + " Damage";
				}
				_loc2_++;
			}
			if (damage[_loc2_] > 0)
			{
				_loc1_ += "Repairs: <FONT COLOR='#eeeeee'>" + damage[_loc2_].toFixed(0) + "</FONT> " + Damage.SINGLETYPE_HTML[_loc2_];
			}
			if (_loc1_ != "")
			{
				_loc1_ += " per hit. \n";
			}
			return _loc1_;
		}
		
		public function debuffdamageText(param1:Number, param2:int, param3:String):String
		{
			var _loc5_:int = 0;
			var _loc4_:String = "";
			_loc5_ = 0;
			while (_loc5_ < 3)
			{
				if (damage[_loc5_] > 0)
				{
					_loc4_ += Localize.t("Deals <FONT COLOR='#eeeeee'>[damage]</FONT> [type] " + param3 + " <FONT COLOR='#eeeeee'>[duration]</FONT> seconds \n").replace("[damage]", Math.ceil(param1 * damage[_loc5_]).toFixed(0)).replace("[type]", Damage.SINGLETYPE_HTML[_loc5_]).replace("[duration]", param2);
				}
				_loc5_++;
			}
			if (damage[_loc5_] > 0)
			{
				_loc4_ += Localize.t("Repairs <FONT COLOR='#eeeeee'>[damage]</FONT> [type] " + param3 + " <FONT COLOR='#eeeeee'>[duration]</FONT> seconds \n").replace("[damage]", Math.ceil(param1 * damage[_loc5_]).toFixed(0)).replace("[type]", Damage.SINGLETYPE_HTML[_loc5_]).replace("[duration]", param2);
			}
			return _loc4_;
		}
		
		public function setBaseDmg(param1:Number):void
		{
			var _loc2_:int = 0;
			if (type == 8)
			{
				return;
			}
			_loc2_ = 0;
			while (_loc2_ < 5)
			{
				damageBase[_loc2_] = param1 * stats[type][_loc2_];
				damage[_loc2_] = param1 * stats[type][_loc2_];
				_loc2_++;
			}
		}
		
		public function addBaseDmg(param1:Number, param2:int = -1):void
		{
			var _loc3_:int = 0;
			if (param2 == 8)
			{
				return;
			}
			if (param2 == -1)
			{
				param2 = this.type;
			}
			_loc3_ = 0;
			while (_loc3_ < 5)
			{
				var _loc4_:* = _loc3_;
				var _loc5_:* = damage[_loc4_] + param1 * stats[param2][_loc3_];
				damage[_loc4_] = _loc5_;
				damageBase[_loc3_] += param1 * stats[param2][_loc3_];
				_loc3_++;
			}
		}
		
		public function addBasePercent(param1:Number, param2:int = -1):void
		{
			var _loc3_:int = 0;
			if (param2 == 8)
			{
				return;
			}
			if (param2 == -1)
			{
				param2 = this.type;
			}
			_loc3_ = 0;
			while (_loc3_ < 5)
			{
				var _loc4_:* = _loc3_;
				var _loc5_:* = damage[_loc4_] + damageBase[_loc3_] * param1 * stats[param2][_loc3_] / 100;
				damage[_loc4_] = _loc5_;
				damageBase[_loc3_] += damageBase[_loc3_] * param1 * stats[param2][_loc3_] / 100;
				_loc3_++;
			}
		}
		
		public function addDmgInt(param1:int, param2:int = -1):void
		{
			var _loc3_:int = 0;
			if (param2 == -1)
			{
				param2 = this.type;
			}
			_loc3_ = 0;
			while (_loc3_ < 5)
			{
				if (damage[_loc3_] > 0)
				{
					var _loc4_:* = _loc3_;
					var _loc5_:* = damage[_loc4_] + param1 * stats[param2][_loc3_];
					damage[_loc4_] = _loc5_;
				}
				_loc3_++;
			}
		}
		
		public function addDmgPercent(param1:Number, param2:int = -1):void
		{
			var _loc3_:int = 0;
			if (param2 == -1)
			{
				param2 = this.type;
			}
			_loc3_ = 0;
			while (_loc3_ < 5)
			{
				if (stats[param2][_loc3_] > 0)
				{
					var _loc4_:* = _loc3_;
					var _loc5_:* = damage[_loc4_] + damageBase[_loc3_] * param1 / 100;
					damage[_loc4_] = _loc5_;
				}
				_loc3_++;
			}
		}
		
		public function addLevelBonus(param1:int, param2:Number):void
		{
			var _loc3_:int = 0;
			if (type == 8)
			{
				return;
			}
			_loc3_ = 0;
			while (_loc3_ < 5)
			{
				damage[_loc3_] = damageBase[_loc3_] * (100 + param2 * (param1 - 1)) / 100;
				damageBase[_loc3_] = damageBase[_loc3_] * (100 + param2 * (param1 - 1)) / 100;
				_loc3_++;
			}
		}
	}
}
