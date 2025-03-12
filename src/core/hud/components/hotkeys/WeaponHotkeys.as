package core.hud.components.hotkeys
{
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
	
	public class WeaponHotkeys extends DisplayObjectContainer
	{
		private var g:Game;
		
		public var selectedHotkey:WeaponHotkey;
		
		private var hotkeys:Vector.<WeaponHotkey>;
		
		private var ship:PlayerShip;
		
		private var player:Player;
		
		private var textureManager:ITextureManager;
		
		public function WeaponHotkeys(param1:Game)
		{
			super();
			this.g = param1;
			textureManager = TextureLocator.getService();
			hotkeys = new Vector.<WeaponHotkey>();
		}
		
		public function load():void
		{
			var _loc2_:Object = null;
			var _loc3_:WeaponHotkey = null;
			ship = g.me.ship;
			player = g.me;
			if (ship == null)
			{
				Console.write("No ship for weapon hotkeys.");
				return;
			}
			if (ship.weapons.length == 0)
			{
				Console.write("No weapons for hotkeys");
				return;
			}
			for each (var _loc1_:* in ship.weapons)
			{
				if (_loc1_.active)
				{
					_loc2_ = DataLocator.getService().loadKey("Images", _loc1_.techIconFileName);
					_loc3_ = new WeaponHotkey(clickedHotkey, textureManager.getTextureGUIByTextureName(_loc2_.textureName), textureManager.getTextureGUIByTextureName(_loc2_.textureName + "_inactive"), _loc1_.hotkey);
					hotkeys.push(_loc3_);
					addChild(_loc3_);
					_loc1_.fireCallback = _loc3_.initiateCooldown;
					new ToolTip(g, _loc3_, createWeaponToolTip(_loc1_), null, "WeaponHotkeys", 300);
					_loc3_.cooldownTime = _loc1_.reloadTime;
					_loc3_.x = 17 + (_loc1_.hotkey - 1) * 50;
					_loc3_.y = 22;
				}
			}
			highlightWeapon(ship.weapons[player.selectedWeaponIndex].hotkey);
		}
		
		private function createWeaponToolTip(param1:Weapon):String
		{
			return param1.getDescription(param1 is Beam);
		}
		
		private function clickedHotkey(param1:WeaponHotkey):void
		{
			player.sendChangeWeapon(param1.key);
			selectedHotkey = param1;
		}
		
		public function reloadWeapon():void
		{
		}
		
		public function highlightWeapon(param1:int):void
		{
			for each (var _loc2_:* in hotkeys)
			{
				if (_loc2_.key == param1)
				{
					selectedHotkey = _loc2_;
					_loc2_.active = true;
				}
				else
				{
					_loc2_.active = false;
				}
			}
		}
		
		public function update():void
		{
			for each (var _loc1_:* in hotkeys)
			{
				_loc1_.update();
			}
		}
		
		public function refresh():void
		{
			ToolTip.disposeType("WeaponHotkeys");
			for each (var _loc1_:* in hotkeys)
			{
				removeChild(_loc1_, true);
			}
			hotkeys.length = 0;
			load();
		}
	}
}
