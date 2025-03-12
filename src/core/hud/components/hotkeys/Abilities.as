package core.hud.components.hotkeys
{
	import core.hud.components.ToolTip;
	import core.player.TechSkill;
	import core.scene.Game;
	import core.scene.SceneBase;
	import core.ship.PlayerShip;
	import data.DataLocator;
	import data.IDataManager;
	import data.KeyBinds;
	import debug.Console;
	import generics.Localize;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class Abilities extends Sprite
	{
		private var hotkeys:Vector.<AbilityHotkey>;
		
		private var g:Game;
		
		private var dataManager:IDataManager;
		
		private var textureManager:ITextureManager;
		
		private var keyBinds:KeyBinds;
		
		public function Abilities(param1:Game)
		{
			hotkeys = new Vector.<AbilityHotkey>();
			super();
			this.g = param1;
			dataManager = DataLocator.getService();
			textureManager = TextureLocator.getService();
		}
		
		public function load():void
		{
			var _loc8_:Object = null;
			var _loc7_:String = null;
			var _loc2_:Boolean = false;
			var _loc6_:Function = null;
			var _loc3_:String = null;
			var _loc5_:int = 0;
			var _loc1_:Object = null;
			var _loc10_:AbilityHotkey = null;
			keyBinds = SceneBase.settings.keybinds;
			var _loc4_:PlayerShip = g.me.ship;
			if (_loc4_ == null)
			{
				Console.write("No ship for weapon hotkeys.");
				return;
			}
			var _loc11_:int = 0;
			for each (var _loc9_:* in g.me.techSkills)
			{
				if (_loc9_.tech == "m4yG1IRPIUeyRQHrC3h5kQ" || _loc9_.tech == "QgKEEj8a-0yzYAJ06eSLqA" || _loc9_.tech == "rSr1sn-_oUOY6E0hpAhh0Q" || _loc9_.tech == "kwlCdExeJk-oEJZopIz5kg")
				{
					_loc8_ = dataManager.loadKey(_loc9_.table, _loc9_.tech);
					_loc7_ = "";
					_loc2_ = false;
					_loc6_ = null;
					_loc3_ = "";
					_loc5_ = 0;
					if (_loc8_.name == "Engine")
					{
						_loc6_ = g.commandManager.addBoostCommand;
						_loc7_ = "E";
						_loc2_ = _loc4_.hasBoost;
						if (_loc4_.aritfact_cooldownReduction > 0.4)
						{
							_loc5_ = _loc4_.boostCD * 0.6;
						}
						else
						{
							_loc5_ = _loc4_.boostCD * (1 - _loc4_.aritfact_cooldownReduction);
						}
						_loc3_ = Localize.t("Boost your engine with <FONT COLOR='#ffffff'>[boostBonus]%</FONT> over <FONT COLOR='#ffffff'>[duration]</FONT> seconds.").replace("[boostBonus]", _loc4_.boostBonus).replace("[duration]", _loc4_.boostDuration / 1000);
					}
					else if (_loc8_.name == "Shield")
					{
						_loc6_ = g.commandManager.addHardenedShieldCommand;
						_loc7_ = "Q";
						_loc2_ = _loc4_.hasHardenedShield;
						if (_loc4_.aritfact_cooldownReduction > 0.4)
						{
							_loc5_ = _loc4_.hardenCD * 0.6;
						}
						else
						{
							_loc5_ = _loc4_.hardenCD * (1 - _loc4_.aritfact_cooldownReduction);
						}
						_loc3_ = Localize.t("Creates a hardened shield that protects you from all damage over <FONT COLOR='#ffffff'>[duration]</FONT> seconds.").replace("[duration]", _loc4_.hardenDuration / 1000);
					}
					else if (_loc8_.name == "Armor")
					{
						_loc6_ = g.commandManager.addShieldConvertCommand;
						_loc7_ = "F";
						_loc2_ = _loc4_.hasArmorConverter;
						if (_loc4_.aritfact_cooldownReduction > 0.4)
						{
							_loc5_ = _loc4_.convCD * 0.6;
						}
						else
						{
							_loc5_ = _loc4_.convCD * (1 - _loc4_.aritfact_cooldownReduction);
						}
						_loc3_ = Localize.t("Use <FONT COLOR='#ffffff'>[convCost]%</FONT> of your shield energy to repair ship with <FONT COLOR='#ffffff'>[convGain]%</FONT> of the energy consumed.").replace("[convCost]", _loc4_.convCost).replace("[convGain]", _loc4_.convGain);
					}
					else if (_loc8_.name == "Power")
					{
						_loc6_ = g.commandManager.addDmgBoostCommand;
						_loc7_ = "R";
						_loc2_ = _loc4_.hasDmgBoost;
						if (_loc4_.aritfact_cooldownReduction > 0.4)
						{
							_loc5_ = _loc4_.dmgBoostCD * 0.6;
						}
						else
						{
							_loc5_ = _loc4_.dmgBoostCD * (1 - _loc4_.aritfact_cooldownReduction);
						}
						_loc3_ = Localize.t("Damage is increased by <FONT COLOR='#ffffff'>[damage]%</FONT> but power consumtion is increased by <FONT COLOR='#ffffff'>[cost]%</FONT> over <FONT COLOR='#ffffff'>[duration]</FONT> seconds.").replace("[damage]", _loc4_.dmgBoostBonus * 100).replace("[cost]", _loc4_.dmgBoostCost * 100).replace("[duration]", _loc4_.dmgBoostDuration / 1000);
					}
					_loc1_ = dataManager.loadKey("Images", _loc8_.techIcon);
					_loc10_ = new AbilityHotkey(_loc6_, textureManager.getTextureGUIByTextureName(_loc1_.textureName), textureManager.getTextureGUIByTextureName(_loc1_.textureName + "_inactive"), textureManager.getTextureGUIByTextureName(_loc1_.textureName + "_cooldown"), _loc7_);
					_loc10_.cooldownTime = _loc5_;
					_loc10_.obj = _loc8_;
					_loc10_.y = 50 * _loc11_;
					_loc10_.visible = _loc2_;
					hotkeys.push(_loc10_);
					new ToolTip(g, _loc10_, _loc3_, null, "abilities");
					addChild(_loc10_);
					_loc11_++;
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
		
		private function createHotkey(param1:Object, param2:Boolean, param3:Function, param4:int, param5:String, param6:String, param7:int):Function
		{
			var obj:Object = param1;
			var visible:Boolean = param2;
			var command:Function = param3;
			var level:int = param4;
			var caption:String = param5;
			var toolTip:String = param6;
			var i:int = param7;
			return function(param1:Texture):void
			{
			};
		}
		
		public function initiateCooldown(param1:String):void
		{
			for each (var _loc2_:* in hotkeys)
			{
				if (_loc2_.obj.name == param1)
				{
					_loc2_.initiateCooldown();
				}
			}
		}
		
		public function refresh():void
		{
			for each (var _loc1_:* in hotkeys)
			{
				removeChild(_loc1_);
				ToolTip.disposeType("abiltites");
			}
			hotkeys.splice(0, hotkeys.length);
			load();
		}
	}
}
