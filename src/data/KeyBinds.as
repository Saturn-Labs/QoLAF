package data
{
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import io.IInput;
	import io.InputLocator;
	import playerio.Message;
	
	public class KeyBinds
	{
		public static const CLAN:int = 0;
		public static const SHOP:int = 1;
		public static const SHIP:int = 2;
		public static const ARTIFACTS:int = 3;
		public static const ENCOUNTERS:int = 4;
		public static const MISSIONS:int = 5;
		public static const PVP:int = 6;
		public static const CARGO:int = 7;
		public static const SETTINGS:int = 8;
		public static const MAP:int = 9;
		public static const LAND:int = 10;
		public static const FORWARD:int = 11;
		public static const STOP:int = 12;
		public static const LEFT:int = 13;
		public static const RIGHT:int = 14;
		public static const BOOST:int = 15;
		public static const SHIELD:int = 16;
		public static const CONVERT:int = 17;
		public static const POWER:int = 18;
		public static const FIRE:int = 19;
		public static const WEAPON_ONE:int = 20;
		public static const WEAPON_TWO:int = 21;
		public static const WEAPON_THREE:int = 22;
		public static const WEAPON_FOUR:int = 23;
		public static const WEAPON_FIVE:int = 24;
		public static const PLAYERS:int = 25;
		public static const AUTO_FORWARD:int = 26;
		public static const NUMBEROFBINDS:int = 27;
		public var dirty:Boolean;
		
		private var keyOne:Vector.<int>;
		
		private var keyTwo:Vector.<int>;
		
		private var names:Vector.<String>;
		
		private var input:IInput;
		
		private var keyDictionary:Dictionary;
		
		public function KeyBinds()
		{
			var _loc1_:int = 0;
			super();
			input = InputLocator.getService();
			keyOne = new Vector.<int>();
			keyTwo = new Vector.<int>();
			dirty = false;
			keyDictionary = getKeyDictionary();
			_loc1_ = 0;
			while (_loc1_ < 27)
			{
				keyOne.push(-1);
				keyTwo.push(-1);
				_loc1_++;
			}
		}
		
		public function init(param1:Message = null, param2:int = 0):void
		{
			if (param1 == null)
			{
				setDefault();
			}
			else
			{
				setKeyBinds(param1, param2);
			}
		}
		
		private function initNames():void
		{
			var _loc1_:int = 0;
			names = new Vector.<String>();
			_loc1_ = 0;
			while (_loc1_ < 27)
			{
				names.push("");
				_loc1_++;
			}
			names[0] = "Clan Screen";
			names[1] = "Flux Shop";
			names[2] = "Ship Menu";
			names[3] = "Artifact Screen";
			names[4] = "Encounters";
			names[5] = "Missions";
			names[6] = "PvP Screen";
			names[7] = "Cargo Screen";
			names[8] = "Settings Menu";
			names[9] = "Map";
			names[10] = "Try to Land";
			names[25] = "Player List";
			names[15] = "Use Boost";
			names[16] = "Use Harden Shield";
			names[17] = "Use Shield Convert";
			names[18] = "Use Damage Boost";
			names[11] = "Forward";
			names[26] = "Auto Cruise";
			names[12] = "Stop";
			names[13] = "Turn Left";
			names[14] = "Turn Right";
			names[19] = "Fire";
			names[20] = "Use/Select Weapon One";
			names[21] = "Use/Select Weapon Two";
			names[22] = "Use/Select Weapon Three";
			names[23] = "Use/Select Weapon Four";
			names[24] = "Use/Select Weapon Five";
		}
		
		private function setDefault():void
		{
			keyOne[0] = 66;
			keyOne[1] = 86;
			keyOne[2] = 88;
			keyOne[3] = 90;
			keyOne[4] = 79;
			keyOne[5] = 73;
			keyOne[6] = 71;
			keyOne[7] = 67;
			keyOne[8] = 72;
			keyOne[9] = 77;
			keyOne[10] = 76;
			keyOne[25] = 80;
			keyOne[15] = 69;
			keyOne[16] = 81;
			keyOne[17] = 70;
			keyOne[18] = 82;
			keyOne[11] = 87;
			keyOne[26] = 9;
			keyOne[12] = 83;
			keyOne[13] = 65;
			keyOne[14] = 68;
			keyOne[19] = 32;
			keyOne[20] = 49;
			keyOne[21] = 50;
			keyOne[22] = 51;
			keyOne[23] = 52;
			keyOne[24] = 53;
			keyTwo[11] = 38;
			keyTwo[12] = 40;
			keyTwo[13] = 37;
			keyTwo[14] = 39;
			keyTwo[19] = -2;
		}
		
		public function getKeyChar(param1:int):String
		{
			return String.fromCharCode(keyOne[param1]);
		}
		
		private function setKeyBinds(param1:Message, param2:int):void
		{
			var _loc3_:int = 0;
			if (param2 + 2 * 27 - 1 > param1.length)
			{
				setDefault();
				return;
			}
			_loc3_ = 0;
			while (_loc3_ < 27)
			{
				keyOne[_loc3_] = param1.getInt(param2++);
				keyTwo[_loc3_] = param1.getInt(param2++);
				_loc3_++;
			}
		}
		
		private function getKeyDictionary():Dictionary
		{
			var _loc5_:int = 0;
			var _loc1_:XML = describeType(Keyboard);
			var _loc4_:XMLList = _loc1_..constant.@name;
			var _loc3_:Dictionary = new Dictionary();
			var _loc2_:int = int(_loc4_.length());
			_loc5_ = 0;
			while (_loc5_ < _loc2_)
			{
				_loc3_[Keyboard[_loc4_[_loc5_]]] = _loc4_[_loc5_];
				_loc5_++;
			}
			return _loc3_;
		}
		
		public function getName(param1:int):String
		{
			if (names == null)
			{
				initNames();
			}
			return names[param1];
		}
		
		public function getKeyName(param1:int, param2:int):String
		{
			if (param2 == 1)
			{
				if (keyOne[param1] == -2)
				{
					return "Mouse1";
				}
				if (keyOne[param1] == -3)
				{
					return "Mouse2";
				}
				return keyDictionary[keyOne[param1]];
			}
			if (keyTwo[param1] == -2)
			{
				return "Mouse1";
			}
			if (keyTwo[param1] == -3)
			{
				return "Mouse2";
			}
			return keyDictionary[keyTwo[param1]];
		}
		
		public function setBindKey(param1:int, param2:int, param3:int):void
		{
			clearOldBinds(param1);
			if (param3 == 1)
			{
				keyOne[param2] = param1;
			}
			else
			{
				keyTwo[param2] = param1;
			}
			dirty = true;
		}
		
		private function clearOldBinds(param1:int):void
		{
			var _loc2_:int = 0;
			_loc2_ = 0;
			while (_loc2_ < 27)
			{
				if (keyOne[_loc2_] == param1)
				{
					keyOne[_loc2_] = -1;
				}
				if (keyTwo[_loc2_] == param1)
				{
					keyTwo[_loc2_] = -1;
				}
				_loc2_++;
			}
		}
		
		public function get isEscPressed():Boolean
		{
			return input.isKeyPressed(27);
		}
		
		public function get isEnterPressed():Boolean
		{
			return input.isKeyPressed(13);
		}
		
		public function isInputPressed(param1:int):Boolean
		{
			if (keyOne[param1] > -1 && input.isKeyPressed(keyOne[param1]) || keyTwo[param1] > -1 && input.isKeyPressed(keyTwo[param1]))
			{
				return true;
			}
			if ((keyOne[param1] == -2 || keyTwo[param1] == -2) && input.isMousePressed)
			{
				return true;
			}
			if ((keyOne[param1] == -3 || keyTwo[param1] == -3) && input.isMouseRightPressed)
			{
				return true;
			}
			return false;
		}
		
		public function isInputDown(param1:int):Boolean
		{
			if (keyOne[param1] > -1 && input.isKeyDown(keyOne[param1]) || keyTwo[param1] > -1 && input.isKeyDown(keyTwo[param1]))
			{
				return true;
			}
			if ((keyOne[param1] == -2 || keyTwo[param1] == -2) && input.isMousePressed)
			{
				return true;
			}
			if ((keyOne[param1] == -3 || keyTwo[param1] == -3) && input.isMouseRightPressed)
			{
				return true;
			}
			return false;
		}
		
		public function populateMessage(param1:Message):Message
		{
			var _loc2_:int = 0;
			_loc2_ = 0;
			while (_loc2_ < 27)
			{
				param1.add(keyOne[_loc2_]);
				param1.add(keyTwo[_loc2_]);
				_loc2_++;
			}
			return param1;
		}
		
		public function isInputUp(param1:int):Boolean
		{
			if (!(keyOne[param1] > -1 && input.isKeyDown(keyOne[param1])) && !(keyTwo[param1] > -1 && input.isKeyDown(keyTwo[param1])) && !((keyOne[param1] == -2 || keyTwo[param1] == -2) && input.isMousePressed) && !((keyOne[param1] == -3 || keyTwo[param1] == -3) && input.isMouseRightPressed))
			{
				return true;
			}
			return false;
		}
	}
}
