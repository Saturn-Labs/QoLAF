package core.artifact
{
	import core.scene.Game;
	
	public class Artifact
	{
		public static const TYPE_CORROSIVE_ADD:String = "corrosiveAdd";
		
		public static const TYPE_CORROSIVE_ADD_SUPERIOR:String = "corrosiveAdd2";
		
		public static const TYPE_CORROSIVE_ADD_EXCEPTIONAL:String = "corrosiveAdd3";
		
		public static const TYPE_CORROSIVE_MULTI:String = "corrosiveMulti";
		
		public static const TYPE_KINETIC_ADD:String = "kineticAdd";
		
		public static const TYPE_KINETIC_ADD_SUPERIOR:String = "kineticAdd2";
		
		public static const TYPE_KINETIC_ADD_EXCEPTIONAL:String = "kineticAdd3";
		
		public static const TYPE_KINETIC_MULTI:String = "kineticMulti";
		
		public static const TYPE_ENERGY_ADD:String = "energyAdd";
		
		public static const TYPE_ENERGY_ADD_SUPERIOR:String = "energyAdd2";
		
		public static const TYPE_ENERGY_ADD_EXCEPTIONAL:String = "energyAdd3";
		
		public static const TYPE_ENERGY_MULTI:String = "energyMulti";
		
		public static const TYPE_CORROSIVE_RESIST:String = "corrosiveResist";
		
		public static const TYPE_KINETIC_RESIST:String = "kineticResist";
		
		public static const TYPE_ENERGY_RESIST:String = "energyResist";
		
		public static const TYPE_SHIELD_ADD:String = "shieldAdd";
		
		public static const TYPE_SHIELD_ADD_SUPERIOR:String = "shieldAdd2";
		
		public static const TYPE_SHIELD_ADD_EXCEPTIONAL:String = "shieldAdd3";
		
		public static const TYPE_SHIELD_MULTI:String = "shieldMulti";
		
		public static const TYPE_SHIELD_REGEN:String = "shieldRegen";
		
		public static const TYPE_HEALTH_ADD:String = "healthAdd";
		
		public static const TYPE_HEALTH_ADD_SUPERIOR:String = "healthAdd2";
		
		public static const TYPE_HEALTH_ADD_EXCEPTIONAL:String = "healthAdd3";
		
		public static const TYPE_HEALTH_MULTI:String = "healthMulti";
		
		public static const TYPE_ARMOR_ADD:String = "armorAdd";
		
		public static const TYPE_ARMOR_ADD_SUPERIOR:String = "armorAdd2";
		
		public static const TYPE_ARMOR_ADD_EXCEPTIONAL:String = "armorAdd3";
		
		public static const TYPE_ARMOR_MULTI:String = "armorMulti";
		
		public static const TYPE_ALL_ADD:String = "allAdd";
		
		public static const TYPE_ALL_ADD_SUPERIOR:String = "allAdd2";
		
		public static const TYPE_ALL_ADD_EXCEPTIONAL:String = "allAdd3";
		
		public static const TYPE_ALL_MULTI:String = "allMulti";
		
		public static const TYPE_ALL_RESIST:String = "allResist";
		
		public static const TYPE_SPEED:String = "speed";
		
		public static const TYPE_SPEED_SUPERIOR:String = "speed2";
		
		public static const TYPE_SPEED_EXCEPTIONAL:String = "speed3";
		
		public static const TYPE_REFIRE:String = "refire";
		
		public static const TYPE_REFIRE_SUPERIOR:String = "refire2";
		
		public static const TYPE_REFIRE_EXCEPTIONAL:String = "refire3";
		
		public static const TYPE_CONV_HP:String = "convHp";
		
		public static const TYPE_CONV_SHIELD:String = "convShield";
		
		public static const TYPE_POWER_REG:String = "powerReg";
		
		public static const TYPE_POWER_REG_SUPERIOR:String = "powerReg2";
		
		public static const TYPE_POWER_REG_EXCEPTIONAL:String = "powerReg3";
		
		public static const TYPE_POWER_MAX:String = "powerMax";
		
		public static const TYPE_COOLDOWN:String = "cooldown";
		
		public static const TYPE_COOLDOWN_SUPERIOR:String = "cooldown2";
		
		public static const TYPE_COOLDOWN_EXCEPTIONAL:String = "cooldown3";
		
		public static const MAX_UPGRADES:int = 10;
		
		public static var currentTypeOrder:String = "healthAdd";
		
		private var colors:Array;
		
		public var name:String;
		
		public var id:String;
		
		public var bitmap:String;
		
		public var level:int;
		
		public var levelPotential:int;
		
		public var revealed:Boolean;
		
		public var upgraded:int;
		
		public var upgrading:Boolean = false;
		
		public var upgradeTime:Number;
		
		public var stats:Vector.<ArtifactStat>;
		
		public function Artifact(param1:Object)
		{
			colors = [11184810, 4491519, 4517444, 16729343, 16761634];
			stats = new Vector.<ArtifactStat>();
			super();
			this.id = param1.key;
			this.name = param1.name;
			this.bitmap = param1.bitmap;
			this.level = param1.level;
			this.levelPotential = param1.levelPotential == null ? param1.level : param1.levelPotential;
			this.revealed = param1.revealed;
			this.upgraded = param1.upgraded;
			for each (var _loc2_:* in param1.stats)
			{
				stats.push(new ArtifactStat(_loc2_.type, _loc2_.value));
			}
		}
		
		public static function orderStat(param1:Artifact, param2:Artifact):int
		{
			if (!param1.revealed || !param2.revealed)
			{
				return orderRevealed(param1, param2);
			}
			var _loc3_:Number = param1.getStat(Artifact.currentTypeOrder);
			var _loc4_:Number = param2.getStat(Artifact.currentTypeOrder);
			if (_loc3_ < _loc4_)
			{
				return 1;
			}
			if (_loc3_ > _loc4_)
			{
				return -1;
			}
			return 0;
		}
		
		public static function orderHighestLevel(param1:Artifact, param2:Artifact):int
		{
			if (!param1.revealed || !param2.revealed)
			{
				return orderRevealed(param1, param2);
			}
			var _loc4_:int = param1.level;
			var _loc3_:int = param2.level;
			if (_loc4_ > _loc3_)
			{
				return -1;
			}
			if (_loc4_ < _loc3_)
			{
				return 1;
			}
			return 0;
		}
		
		public static function orderStatCountAsc(param1:Artifact, param2:Artifact):int
		{
			if (!param1.revealed || !param2.revealed)
			{
				return orderRevealed(param1, param2);
			}
			var _loc3_:Number = param1.stats.length;
			var _loc4_:Number = param2.stats.length;
			if (_loc3_ > _loc4_)
			{
				return 1;
			}
			if (_loc3_ < _loc4_)
			{
				return -1;
			}
			return 0;
		}
		
		public static function orderStatCountDesc(param1:Artifact, param2:Artifact):int
		{
			if (!param1.revealed || !param2.revealed)
			{
				return orderRevealed(param1, param2);
			}
			var _loc3_:Number = param1.stats.length;
			var _loc4_:Number = param2.stats.length;
			if (_loc3_ < _loc4_)
			{
				return 1;
			}
			if (_loc3_ > _loc4_)
			{
				return -1;
			}
			return 0;
		}
		
		public static function orderLevelHigh(param1:Artifact, param2:Artifact):int
		{
			if (!param1.revealed || !param2.revealed)
			{
				return orderRevealed(param1, param2);
			}
			var _loc3_:Number = param1.level;
			var _loc4_:Number = param2.level;
			if (_loc3_ < _loc4_)
			{
				return 1;
			}
			if (_loc3_ > _loc4_)
			{
				return -1;
			}
			return 0;
		}
		
		public static function orderLevelLow(param1:Artifact, param2:Artifact):int
		{
			if (!param1.revealed || !param2.revealed)
			{
				return orderRevealed(param1, param2);
			}
			var _loc3_:Number = param1.level;
			var _loc4_:Number = param2.level;
			if (_loc3_ > _loc4_)
			{
				return 1;
			}
			if (_loc3_ < _loc4_)
			{
				return -1;
			}
			return 0;
		}
		
		public static function orderRevealed(param1:Artifact, param2:Artifact):int
		{
			if (!param1.revealed && param2.revealed)
			{
				return 1;
			}
			if (param1.revealed && !param2.revealed)
			{
				return -1;
			}
			return 0;
		}
		
		public function getStat(param1:String):Number
		{
			var _loc4_:int = 0;
			var _loc3_:ArtifactStat = null;
			var _loc2_:Number = 0;
			_loc4_ = 0;
			while (_loc4_ < stats.length)
			{
				_loc3_ = stats[_loc4_];
				if (_loc3_.type.indexOf(param1) != -1)
				{
					_loc2_ += _loc3_.value;
				}
				_loc4_++;
			}
			return _loc2_;
		}
		
		public function getColor():uint
		{
			return colors[stats.length - 1];
		}
		
		public function get isRestricted():Boolean
		{
			var _loc1_:int = Game.instance.me.level;
			var _loc2_:int = Math.ceil(1.2 * _loc1_ + 10);
			if (_loc2_ > 150)
			{
				_loc2_ = 150;
			}
			return levelPotential > _loc2_;
		}
		
		public function get requiredPlayerLevel():int
		{
			return Math.ceil((levelPotential - 10) / 1.2);
		}
	}
}
