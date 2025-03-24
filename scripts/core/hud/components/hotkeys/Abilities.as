package core.hud.components.hotkeys {
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
	
	public class Abilities extends Sprite {
		private var hotkeys:Vector.<AbilityHotkey> = new Vector.<AbilityHotkey>();
		
		private var g:Game;
		
		private var dataManager:IDataManager;
		
		private var textureManager:ITextureManager;
		
		private var keyBinds:KeyBinds;
		
		public function Abilities(g:Game) {
			super();
			this.g = g;
			dataManager = DataLocator.getService();
			textureManager = TextureLocator.getService();
		}
		
		public function load() : void {
			var _local3:Object = null;
			var _local9:String = null;
			var _local1:Boolean = false;
			var _local11:Function = null;
			var _local4:String = null;
			var _local10:int = 0;
			var _local5:Object = null;
			var _local6:AbilityHotkey = null;
			keyBinds = SceneBase.settings.keybinds;
			var _local7:PlayerShip = g.me.ship;
			if(_local7 == null) {
				Console.write("No ship for weapon hotkeys.");
				return;
			}
			var _local8:int = 0;
			for each(var _local2 in g.me.techSkills) {
				if(_local2.tech == "m4yG1IRPIUeyRQHrC3h5kQ" || _local2.tech == "QgKEEj8a-0yzYAJ06eSLqA" || _local2.tech == "rSr1sn-_oUOY6E0hpAhh0Q" || _local2.tech == "kwlCdExeJk-oEJZopIz5kg") {
					_local3 = dataManager.loadKey(_local2.table,_local2.tech);
					_local9 = "";
					_local1 = false;
					_local11 = null;
					_local4 = "";
					_local10 = 0;
					if(_local3.name == "Engine") {
						_local11 = g.commandManager.addBoostCommand;
						_local9 = "E";
						_local1 = _local7.hasBoost;
						if(_local7.artifact_cooldownReduction > 0.4) {
							_local10 = _local7.boostCD * 0.6;
						} else {
							_local10 = _local7.boostCD * (1 - _local7.artifact_cooldownReduction);
						}
						_local4 = Localize.t("Boost your engine with <FONT COLOR=\'#ffffff\'>[boostBonus]%</FONT> over <FONT COLOR=\'#ffffff\'>[duration]</FONT> seconds.").replace("[boostBonus]",_local7.boostBonus).replace("[duration]",_local7.boostDuration / 1000);
					} else if(_local3.name == "Shield") {
						_local11 = g.commandManager.addHardenedShieldCommand;
						_local9 = "Q";
						_local1 = _local7.hasHardenedShield;
						if(_local7.artifact_cooldownReduction > 0.4) {
							_local10 = _local7.hardenCD * 0.6;
						} else {
							_local10 = _local7.hardenCD * (1 - _local7.artifact_cooldownReduction);
						}
						_local4 = Localize.t("Creates a hardened shield that protects you from all damage over <FONT COLOR=\'#ffffff\'>[duration]</FONT> seconds.").replace("[duration]",_local7.hardenDuration / 1000);
					} else if(_local3.name == "Armor") {
						_local11 = g.commandManager.addShieldConvertCommand;
						_local9 = "F";
						_local1 = _local7.hasArmorConverter;
						if(_local7.artifact_cooldownReduction > 0.4) {
							_local10 = _local7.convCD * 0.6;
						} else {
							_local10 = _local7.convCD * (1 - _local7.artifact_cooldownReduction);
						}
						_local4 = Localize.t("Use <FONT COLOR=\'#ffffff\'>[convCost]%</FONT> of your shield energy to repair ship with <FONT COLOR=\'#ffffff\'>[convGain]%</FONT> of the energy consumed.").replace("[convCost]",_local7.convCost).replace("[convGain]",_local7.convGain);
					} else if(_local3.name == "Power") {
						_local11 = g.commandManager.addDmgBoostCommand;
						_local9 = "R";
						_local1 = _local7.hasDmgBoost;
						if(_local7.artifact_cooldownReduction > 0.4) {
							_local10 = _local7.dmgBoostCD * 0.6;
						} else {
							_local10 = _local7.dmgBoostCD * (1 - _local7.artifact_cooldownReduction);
						}
						_local4 = Localize.t("Damage is increased by <FONT COLOR=\'#ffffff\'>[damage]%</FONT> but power consumtion is increased by <FONT COLOR=\'#ffffff\'>[cost]%</FONT> over <FONT COLOR=\'#ffffff\'>[duration]</FONT> seconds.").replace("[damage]",_local7.dmgBoostBonus * 100).replace("[cost]",_local7.dmgBoostCost * 100).replace("[duration]",_local7.dmgBoostDuration / 1000);
					}
					_local5 = dataManager.loadKey("Images",_local3.techIcon);
					_local6 = new AbilityHotkey(_local11,textureManager.getTextureGUIByTextureName(_local5.textureName),textureManager.getTextureGUIByTextureName(_local5.textureName + "_inactive"),textureManager.getTextureGUIByTextureName(_local5.textureName + "_cooldown"),_local9);
					_local6.cooldownTime = _local10;
					_local6.obj = _local3;
					_local6.y = 50 * _local8;
					_local6.visible = _local1;
					hotkeys.push(_local6);
					new ToolTip(g,_local6,_local4,null,"abilities");
					addChild(_local6);
					_local8++;
				}
			}
		}
		
		public function update() : void {
			for each(var _local1 in hotkeys) {
				_local1.update();
			}
		}
		
		private function createHotkey(obj:Object, visible:Boolean, command:Function, level:int, caption:String, toolTip:String, i:int) : Function {
			return function(param1:Texture):void {
			};
		}
		
		public function initiateCooldown(name:String) : void {
			for each(var _local2 in hotkeys) {
				if(_local2.obj.name == name) {
					_local2.initiateCooldown();
				}
			}
		}
		
		public function refresh() : void {
			for each(var _local1 in hotkeys) {
				removeChild(_local1);
				ToolTip.disposeType("abiltites");
			}
			hotkeys.splice(0,hotkeys.length);
			load();
		}
	}
}

