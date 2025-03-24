package core.player {
	import data.DataLocator;
	import data.IDataManager;
	import playerio.Message;
	
	public class FleetObj {
		public var skin:String = "";
		
		public var shipHue:Number = 0;
		
		public var shipBrightness:Number = 0;
		
		public var shipSaturation:Number = 0;
		
		public var shipContrast:Number = 0;
		
		public var engineHue:Number = 0;
		
		public var activeWeapon:String = "";
		
		public var activeArtifactSetup:int;
		
		public var lastUsed:Number = 0;
		
		public var weapons:Array = [];
		
		public var weaponsState:Array = [];
		
		public var weaponsHotkeys:Array = [];
		
		public var techSkills:Vector.<TechSkill> = new Vector.<TechSkill>();
		
		public var nrOfUpgrades:Vector.<int> = Vector.<int>([0,0,0,0,0,0,0]);
		
		public function FleetObj() {
			super();
		}
		
		public function initFromSkin(skinKey:String) : void {
			var _local2:TechSkill = null;
			var _local6:IDataManager = DataLocator.getService();
			var _local3:Object = _local6.loadKey("Skins",skinKey);
			skin = skinKey;
			var _local4:Array = _local3.upgrades;
			for each(var _local5 in _local4) {
				_local2 = new TechSkill();
				_local2.table = _local5.table;
				_local2.tech = _local5.tech;
				_local2.name = _local5.name;
				_local2.level = _local5.level;
				techSkills.push(_local2);
				if(_local5.table == "Weapons") {
					weapons.push({"weapon":_local5.tech});
					weaponsState.push(false);
					weaponsHotkeys.push(0);
				}
			}
		}
		
		public function initFromMessage(m:Message, startIndex:int) : int {
			skin = m.getString(startIndex++);
			activeArtifactSetup = m.getInt(startIndex++);
			activeWeapon = m.getString(startIndex++);
			shipHue = m.getNumber(startIndex++);
			shipBrightness = m.getNumber(startIndex++);
			shipSaturation = m.getNumber(startIndex++);
			shipContrast = m.getNumber(startIndex++);
			engineHue = m.getNumber(startIndex++);
			lastUsed = m.getNumber(startIndex++);
			startIndex = initWeaponsFromMessage(m,startIndex);
			return initTechSkillsFromMessage(m,startIndex,skin);
		}
		
		private function initWeaponsFromMessage(m:Message, startIndex:int) : int {
			var _local3:int = 0;
			weapons = [];
			weaponsState = [];
			weaponsHotkeys = [];
			var _local4:int = m.getInt(startIndex);
			_local3 = startIndex + 1;
			while(_local3 < startIndex + _local4 * 3 + 1) {
				weapons.push({"weapon":m.getString(_local3)});
				weaponsState.push(m.getBoolean(_local3 + 1));
				weaponsHotkeys.push(m.getInt(_local3 + 2));
				_local3 += 3;
			}
			return _local3;
		}
		
		private function initTechSkillsFromMessage(m:Message, startIndex:int, skinKey:String) : int {
			var _local9:int = 0;
			var _local5:int = 0;
			var _local6:TechSkill = null;
			var _local8:int = 0;
			var _local11:int = 0;
			var _local10:int = 0;
			var _local12:int = 0;
			techSkills = new Vector.<TechSkill>();
			var _local4:int = m.getInt(startIndex);
			nrOfUpgrades = Vector.<int>([0,0,0,0,0,0,0]);
			var _local7:int = startIndex + 1;
			_local9 = 0;
			while(_local9 < _local4) {
				_local5 = m.getInt(_local7 + 3);
				_local6 = new TechSkill(m.getString(_local7),m.getString(_local7 + 1),m.getString(_local7 + 2),_local5,m.getString(_local7 + 4),m.getInt(_local7 + 5));
				_local8 = m.getInt(_local7 + 6);
				_local7 += 7;
				_local11 = 0;
				while(_local11 < _local8) {
					if(m.getString(_local7) != "") {
						_local6.addEliteTechData(m.getString(_local7),m.getInt(_local7 + 1));
					}
					_local7 += 2;
					_local11++;
				}
				techSkills.push(_local6);
				_local10 = Player.getSkinTechLevel(_local6.tech,skinKey);
				if(_local5 > _local10) {
					var _local13:* = 0;
					var _local14:* = nrOfUpgrades[_local13] + _local5;
					nrOfUpgrades[_local13] = _local14;
					if(_local5 > 0) {
						_local12 = 1;
						while(_local12 <= _local5) {
							_local14 = _local12;
							_local13 = nrOfUpgrades[_local14] + 1;
							nrOfUpgrades[_local14] = _local13;
							_local12++;
						}
					}
				}
				_local9++;
			}
			return _local7;
		}
	}
}

