package core.player
{
	import data.DataLocator;
	import data.IDataManager;
	import playerio.Message;

	public class FleetObj
	{
		public var skin:String = "";
		public var shipHue:Number = 0;
		public var shipBrightness:Number = 0;
		public var shipSaturation:Number = 0;
		public var shipContrast:Number = 0;
		public var engineHue:Number = 0;
		public var activeWeapon:String = "";
		public var activeArtifactSetup:int;
		public var lastUsed:Number = 0;
		public var weapons:Array;
		public var weaponsState:Array;
		public var weaponsHotkeys:Array;
		public var techSkills:Vector.<TechSkill>;

		public var nrOfUpgrades:Vector.<int>;

		public function FleetObj()
		{
			weapons = [];
			weaponsState = [];
			weaponsHotkeys = [];
			techSkills = new Vector.<TechSkill>();
			nrOfUpgrades = Vector.<int>([0, 0, 0, 0, 0, 0, 0]);
			super();
		}

		public function initFromSkin(param1:String):void
		{
			var _loc4_:TechSkill = null;
			var _loc6_:IDataManager = DataLocator.getService();
			var _loc2_:Object = _loc6_.loadKey("Skins", param1);
			skin = param1;
			var _loc3_:Array = _loc2_.upgrades;
			for each (var _loc5_:* in _loc3_)
			{
				_loc4_ = new TechSkill();
				_loc4_.table = _loc5_.table;
				_loc4_.tech = _loc5_.tech;
				_loc4_.name = _loc5_.name;
				_loc4_.level = _loc5_.level;
				techSkills.push(_loc4_);
				if (_loc5_.table == "Weapons")
				{
					weapons.push( {"weapon": _loc5_.tech});
					weaponsState.push(false);
					weaponsHotkeys.push(0);
				}
			}
		}

		public function initFromMessage(param1:Message, param2:int):int
		{
			skin = param1.getString(param2++ );
			activeArtifactSetup = param1.getInt(param2++ );
			activeWeapon = param1.getString(param2++ );
			shipHue = param1.getNumber(param2++ );
			shipBrightness = param1.getNumber(param2++ );
			shipSaturation = param1.getNumber(param2++ );
			shipContrast = param1.getNumber(param2++ );
			engineHue = param1.getNumber(param2++ );
			lastUsed = param1.getNumber(param2++ );
			param2 = initWeaponsFromMessage(param1, param2);
			return initTechSkillsFromMessage(param1, param2, skin);
		}

		private function initWeaponsFromMessage(param1:Message, param2:int):int
		{
			var _loc4_:int = 0;
			weapons = [];
			weaponsState = [];
			weaponsHotkeys = [];
			var _loc3_:int = param1.getInt(param2);
			_loc4_ = param2 + 1;
			while (_loc4_ < param2 + _loc3_ * 3 + 1)
			{
				weapons.push( {"weapon": param1.getString(_loc4_)});
				weaponsState.push(param1.getBoolean(_loc4_ + 1));
				weaponsHotkeys.push(param1.getInt(_loc4_ + 2));
				_loc4_ += 3;
			}
			return _loc4_;
		}

		private function initTechSkillsFromMessage(param1:Message, param2:int, param3:String):int
		{
			var _loc9_:int = 0;
			var _loc5_:int = 0;
			var _loc8_:TechSkill = null;
			var _loc6_:int = 0;
			var _loc10_:int = 0;
			var _loc4_:int = 0;
			var _loc7_:int = 0;
			techSkills = new Vector.<TechSkill>();
			var _loc11_:int = param1.getInt(param2);
			nrOfUpgrades = Vector.<int>([0, 0, 0, 0, 0, 0, 0]);
			var _loc12_:int = param2 + 1;
			_loc9_ = 0;
			while (_loc9_ < _loc11_)
			{
				_loc5_ = param1.getInt(_loc12_ + 3);
				_loc8_ = new TechSkill(param1.getString(_loc12_), param1.getString(_loc12_ + 1), param1.getString(_loc12_ + 2), _loc5_, param1.getString(_loc12_ + 4), param1.getInt(_loc12_ + 5));
				_loc6_ = param1.getInt(_loc12_ + 6);
				_loc12_ += 7;
				_loc10_ = 0;
				while (_loc10_ < _loc6_)
				{
					if (param1.getString(_loc12_) != "")
					{
						_loc8_.addEliteTechData(param1.getString(_loc12_), param1.getInt(_loc12_ + 1));
					}
					_loc12_ += 2;
					_loc10_++;
				}
				techSkills.push(_loc8_);
				_loc4_ = Player.getSkinTechLevel(_loc8_.tech, param3);
				if (_loc5_ > _loc4_)
				{
					var _loc13_:* = 0;
					var _loc14_:* = nrOfUpgrades[_loc13_] + _loc5_;
					nrOfUpgrades[_loc13_] = _loc14_;
					if (_loc5_ > 0)
					{
						_loc7_ = 1;
						while (_loc7_ <= _loc5_)
						{
							_loc14_ = _loc7_;
							_loc13_ = nrOfUpgrades[_loc14_] + 1;
							nrOfUpgrades[_loc14_] = _loc13_;
							_loc7_++;
						}
					}
				}
				_loc9_++;
			}
			return _loc12_;
		}
	}
}
