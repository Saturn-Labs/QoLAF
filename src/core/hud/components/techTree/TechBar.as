package core.hud.components.techTree
{
	import core.player.Player;
	import core.player.TechSkill;
	import core.scene.Game;
	import starling.display.Sprite;
	
	public class TechBar extends Sprite
	{
		private var maxLevel:int;
		
		public var tech:String;
		
		public var table:String;
		
		public var eti:EliteTechIcon;
		
		private var _playerLevel:int;
		
		private var techIcons:Vector.<TechLevelIcon>;
		
		private var eliteTechIcon:EliteTechIcon;
		
		private var me:Player;
		
		private var _selectedTechLevelIcon:TechLevelIcon;
		
		public function TechBar(param1:Game, param2:TechSkill, param3:Player, param4:Boolean = true, param5:Boolean = false, param6:int = -1)
		{
			var _loc12_:int = 0;
			var _loc8_:int = 0;
			var _loc10_:TechLevelIcon = null;
			super();
			this.me = param3;
			maxLevel = 6;
			techIcons = new Vector.<TechLevelIcon>();
			_playerLevel = param2.level;
			table = param2.table;
			tech = param2.tech;
			var _loc7_:int = param6 == -1 ? Player.getSkinTechLevel(tech, param3.activeSkin) : param6;
			var _loc9_:String = "";
			_loc9_ = "upgraded";
			var _loc11_:TechLevelIcon = new TechLevelIcon(this, _loc9_, 0, param2, param4);
			_loc11_.x = TechLevelIcon.ICON_WIDTH / 2;
			_loc11_.y = TechLevelIcon.ICON_WIDTH / 2;
			_loc11_.pivotX = TechLevelIcon.ICON_WIDTH / 2;
			_loc11_.pivotY = TechLevelIcon.ICON_WIDTH / 2;
			techIcons.push(_loc11_);
			addChild(_loc11_);
			_loc12_ = 0;
			while (_loc12_ < maxLevel)
			{
				_loc8_ = _loc12_ + 1;
				if (_loc8_ <= _playerLevel)
				{
					_loc9_ = "upgraded";
				}
				else if (!TechTree.hasRequiredLevel(_loc8_, param3.level) && param4)
				{
					_loc9_ = "locked";
				}
				else if (_loc8_ == _playerLevel + 1 && param4)
				{
					_loc9_ = "can be upgraded";
				}
				else if (_loc8_ > _playerLevel)
				{
					_loc9_ = "can't be upgraded";
				}
				if (_loc7_ >= _loc8_)
				{
					_loc9_ = "skin locked";
				}
				_loc10_ = new TechLevelIcon(this, _loc9_, _loc8_, param2, param5);
				_loc10_.x = TechLevelIcon.ICON_WIDTH + TechLevelIcon.ICON_PADDING + TechLevelIcon.ICON_WIDTH / 2 + _loc12_ * (TechLevelIcon.ICON_WIDTH + TechLevelIcon.ICON_PADDING);
				_loc10_.y = TechLevelIcon.ICON_WIDTH / 2;
				_loc10_.pivotX = TechLevelIcon.ICON_WIDTH / 2;
				_loc10_.pivotY = TechLevelIcon.ICON_WIDTH / 2;
				techIcons.push(_loc10_);
				addChild(_loc10_);
				_loc12_++;
			}
			if (param2.level < 6)
			{
				_loc9_ = "locked";
			}
			else if (param2.activeEliteTech == "")
			{
				_loc9_ = "no special selected";
			}
			else if (param2.activeEliteTechLevel < 100)
			{
				_loc9_ = "special selected and can be upgraded";
			}
			else
			{
				_loc9_ = "fully upgraded";
			}
			eti = new EliteTechIcon(param1, this, _loc9_, param2, param5, param4);
			eti.x = TechLevelIcon.ICON_WIDTH + TechLevelIcon.ICON_PADDING + TechLevelIcon.ICON_WIDTH / 2 + 6 * (TechLevelIcon.ICON_WIDTH + TechLevelIcon.ICON_PADDING);
			eti.y = EliteTechIcon.ICON_WIDTH / 2;
			eti.pivotX = EliteTechIcon.ICON_WIDTH / 2;
			eti.pivotY = EliteTechIcon.ICON_WIDTH / 2;
			eliteTechIcon = eti;
			addChild(eliteTechIcon);
		}
		
		public function reset():void
		{
			var _loc3_:int = 0;
			var _loc2_:TechLevelIcon = null;
			var _loc1_:int = Player.getSkinTechLevel(tech, me.activeSkin);
			_playerLevel = _loc1_;
			eliteTechIcon.level = -1;
			eliteTechIcon.updateState("locked");
			_loc3_ = 0;
			while (_loc3_ < techIcons.length)
			{
				_loc2_ = techIcons[_loc3_];
				_loc2_.playerLevel = _loc1_;
				if (_loc3_ != 0)
				{
					if (!TechTree.hasRequiredLevel(_loc3_, me.level))
					{
						_loc2_.updateState("locked");
					}
					else if (_loc3_ == _loc1_ + 1)
					{
						_loc2_.updateState("can be upgraded");
					}
					else
					{
						_loc2_.updateState("can't be upgraded");
					}
					_loc2_.visible = true;
					if (_loc1_ >= _loc2_.level)
					{
						_loc2_.updateState("skin locked");
					}
				}
				_loc3_++;
			}
		}
		
		override public function dispose():void
		{
			for each (var _loc1_:* in techIcons)
			{
				_loc1_.dispose();
			}
			removeEventListeners();
			super.dispose();
		}
		
		override public function set touchable(param1:Boolean):void
		{
			for each (var _loc2_:* in techIcons)
			{
				_loc2_.touchable = param1;
			}
			eliteTechIcon.touchable = param1;
		}
		
		private function getUpgradeByLevel(param1:int):TechLevelIcon
		{
			for each (var _loc2_:* in techIcons)
			{
				if (_loc2_.level == param1)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		public function upgrade(param1:TechLevelIcon):void
		{
			param1.updateState("upgraded");
			var _loc2_:TechLevelIcon = getUpgradeByLevel(param1.level + 1);
			if (param1.level == 6)
			{
				eliteTechIcon.updateState("no special selected");
			}
			if (_loc2_ != null && TechTree.hasRequiredLevel(_loc2_.level, me.level))
			{
				_loc2_.updateState("can be upgraded");
				_loc2_.playerLevel = param1.level;
			}
		}
	}
}
