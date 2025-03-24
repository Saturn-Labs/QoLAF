package core.hud.components.techTree {
	import core.player.Player;
	import core.player.TechSkill;
	import core.scene.Game;
	import starling.display.Sprite;
	
	public class TechBar extends Sprite {
		private var maxLevel:int;
		
		public var tech:String;
		
		public var table:String;
		
		public var eti:EliteTechIcon;
		
		private var _playerLevel:int;
		
		private var techIcons:Vector.<TechLevelIcon>;
		
		private var eliteTechIcon:EliteTechIcon;
		
		private var me:Player;
		
		private var _selectedTechLevelIcon:TechLevelIcon;
		
		public function TechBar(g:Game, techSkill:TechSkill, me:Player, showCanBeUpgraded:Boolean = true, showTooltip:Boolean = false, overrideSkinLevel:int = -1) {
			var _local9:int = 0;
			var _local7:int = 0;
			var _local8:TechLevelIcon = null;
			super();
			this.me = me;
			maxLevel = 6;
			techIcons = new Vector.<TechLevelIcon>();
			_playerLevel = techSkill.level;
			table = techSkill.table;
			tech = techSkill.tech;
			var _local10:int = overrideSkinLevel == -1 ? Player.getSkinTechLevel(tech,me.activeSkin) : overrideSkinLevel;
			var _local11:String = "";
			_local11 = "upgraded";
			var _local12:TechLevelIcon = new TechLevelIcon(this,_local11,0,techSkill,showCanBeUpgraded);
			_local12.x = TechLevelIcon.ICON_WIDTH / 2;
			_local12.y = TechLevelIcon.ICON_WIDTH / 2;
			_local12.pivotX = TechLevelIcon.ICON_WIDTH / 2;
			_local12.pivotY = TechLevelIcon.ICON_WIDTH / 2;
			techIcons.push(_local12);
			addChild(_local12);
			_local9 = 0;
			while(_local9 < maxLevel) {
				_local7 = _local9 + 1;
				if(_local7 <= _playerLevel) {
					_local11 = "upgraded";
				} else if(!TechTree.hasRequiredLevel(_local7,me.level) && showCanBeUpgraded) {
					_local11 = "locked";
				} else if(_local7 == _playerLevel + 1 && showCanBeUpgraded) {
					_local11 = "can be upgraded";
				} else if(_local7 > _playerLevel) {
					_local11 = "can\'t be upgraded";
				}
				if(_local10 >= _local7) {
					_local11 = "skin locked";
				}
				_local8 = new TechLevelIcon(this,_local11,_local7,techSkill,showTooltip);
				_local8.x = TechLevelIcon.ICON_WIDTH + TechLevelIcon.ICON_PADDING + TechLevelIcon.ICON_WIDTH / 2 + _local9 * (TechLevelIcon.ICON_WIDTH + TechLevelIcon.ICON_PADDING);
				_local8.y = TechLevelIcon.ICON_WIDTH / 2;
				_local8.pivotX = TechLevelIcon.ICON_WIDTH / 2;
				_local8.pivotY = TechLevelIcon.ICON_WIDTH / 2;
				techIcons.push(_local8);
				addChild(_local8);
				_local9++;
			}
			if(techSkill.level < 6) {
				_local11 = "locked";
			} else if(techSkill.activeEliteTech == "") {
				_local11 = "no special selected";
			} else if(techSkill.activeEliteTechLevel < 100) {
				_local11 = "special selected and can be upgraded";
			} else {
				_local11 = "fully upgraded";
			}
			eti = new EliteTechIcon(g,this,_local11,techSkill,showTooltip,showCanBeUpgraded);
			eti.x = TechLevelIcon.ICON_WIDTH + TechLevelIcon.ICON_PADDING + TechLevelIcon.ICON_WIDTH / 2 + 6 * (TechLevelIcon.ICON_WIDTH + TechLevelIcon.ICON_PADDING);
			eti.y = EliteTechIcon.ICON_WIDTH / 2;
			eti.pivotX = EliteTechIcon.ICON_WIDTH / 2;
			eti.pivotY = EliteTechIcon.ICON_WIDTH / 2;
			eliteTechIcon = eti;
			addChild(eliteTechIcon);
		}
		
		public function reset() : void {
			var _local2:int = 0;
			var _local1:TechLevelIcon = null;
			var _local3:int = Player.getSkinTechLevel(tech,me.activeSkin);
			_playerLevel = _local3;
			eliteTechIcon.level = -1;
			eliteTechIcon.updateState("locked");
			_local2 = 0;
			while(_local2 < techIcons.length) {
				_local1 = techIcons[_local2];
				_local1.playerLevel = _local3;
				if(_local2 != 0) {
					if(!TechTree.hasRequiredLevel(_local2,me.level)) {
						_local1.updateState("locked");
					} else if(_local2 == _local3 + 1) {
						_local1.updateState("can be upgraded");
					} else {
						_local1.updateState("can\'t be upgraded");
					}
					_local1.visible = true;
					if(_local3 >= _local1.level) {
						_local1.updateState("skin locked");
					}
				}
				_local2++;
			}
		}
		
		override public function dispose() : void {
			for each(var _local1 in techIcons) {
				_local1.dispose();
			}
			removeEventListeners();
			super.dispose();
		}
		
		override public function set touchable(value:Boolean) : void {
			for each(var _local2 in techIcons) {
				_local2.touchable = value;
			}
			eliteTechIcon.touchable = value;
		}
		
		private function getUpgradeByLevel(level:int) : TechLevelIcon {
			for each(var _local2 in techIcons) {
				if(_local2.level == level) {
					return _local2;
				}
			}
			return null;
		}
		
		public function upgrade(tli:TechLevelIcon) : void {
			tli.updateState("upgraded");
			var _local2:TechLevelIcon = getUpgradeByLevel(tli.level + 1);
			if(tli.level == 6) {
				eliteTechIcon.updateState("no special selected");
			}
			if(_local2 != null && TechTree.hasRequiredLevel(_local2.level,me.level)) {
				_local2.updateState("can be upgraded");
				_local2.playerLevel = tli.level;
			}
		}
	}
}

