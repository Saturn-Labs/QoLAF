package core.hud.components.hotkeys {
	import core.hud.components.ToolTip;
	import core.player.Player;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.weapon.Beam;
	import core.weapon.Weapon;
	import data.DataLocator;
	import debug.Console;
	import starling.display.DisplayObjectContainer;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class WeaponHotkeys extends DisplayObjectContainer {
		private var g:Game;
		
		public var selectedHotkey:WeaponHotkey;
		
		private var hotkeys:Vector.<WeaponHotkey>;
		
		private var ship:PlayerShip;
		
		private var player:Player;
		
		private var textureManager:ITextureManager;
		
		public function WeaponHotkeys(g:Game) {
			super();
			this.g = g;
			textureManager = TextureLocator.getService();
			hotkeys = new Vector.<WeaponHotkey>();
		}
		
		public function load() : void {
			var _local3:Object = null;
			var _local2:WeaponHotkey = null;
			ship = g.me.ship;
			player = g.me;
			if(ship == null) {
				Console.write("No ship for weapon hotkeys.");
				return;
			}
			if(ship.weapons.length == 0) {
				Console.write("No weapons for hotkeys");
				return;
			}
			for each(var _local1 in ship.weapons) {
				if(_local1.active) {
					_local3 = DataLocator.getService().loadKey("Images",_local1.techIconFileName);
					_local2 = new WeaponHotkey(clickedHotkey,textureManager.getTextureGUIByTextureName(_local3.textureName),textureManager.getTextureGUIByTextureName(_local3.textureName + "_inactive"),_local1.hotkey);
					hotkeys.push(_local2);
					addChild(_local2);
					_local1.fireCallback = _local2.initiateCooldown;
					new ToolTip(g,_local2,createWeaponToolTip(_local1),null,"WeaponHotkeys",5 * 60);
					_local2.cooldownTime = _local1.reloadTime;
					_local2.x = 17 + (_local1.hotkey - 1) * 50;
					_local2.y = 22;
				}
			}
			highlightWeapon(ship.weapons[player.selectedWeaponIndex].hotkey);
		}
		
		private function createWeaponToolTip(w:Weapon) : String {
			return w.getDescription(w is Beam);
		}
		
		private function clickedHotkey(hotkey:WeaponHotkey) : void {
			player.sendChangeWeapon(hotkey.key);
			selectedHotkey = hotkey;
		}
		
		public function reloadWeapon() : void {
		}
		
		public function highlightWeapon(i:int) : void {
			for each(var _local2 in hotkeys) {
				if(_local2.key == i) {
					selectedHotkey = _local2;
					_local2.active = true;
				} else {
					_local2.active = false;
				}
			}
		}
		
		public function update() : void {
			for each(var _local1 in hotkeys) {
				_local1.update();
			}
		}
		
		public function refresh() : void {
			ToolTip.disposeType("WeaponHotkeys");
			for each(var _local1 in hotkeys) {
				removeChild(_local1,true);
			}
			hotkeys.length = 0;
			load();
		}
	}
}

