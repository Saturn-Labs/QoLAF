package core.states.gameStates {
	import core.hud.components.SettingsKeybind;
	import core.hud.components.Text;
	import core.scene.Game;
	import core.scene.SceneBase;
	import data.KeyBinds;
	import feathers.controls.ScrollContainer;
	import generics.Localize;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class SettingsBindings extends Sprite {
		private var g:Game;
		
		private var keybinds:KeyBinds;
		
		private var currentHeight:Number = 0;
		
		private var currentWidth:Number = 50;
		
		private var scrollArea:ScrollContainer;
		
		private var keybindList:Vector.<SettingsKeybind> = new Vector.<SettingsKeybind>();
		
		public function SettingsBindings(g:Game) {
			super();
			this.g = g;
			this.keybinds = SceneBase.settings.keybinds;
			scrollArea = new ScrollContainer();
			scrollArea.y = 50;
			scrollArea.x = 10;
			scrollArea.width = 700;
			scrollArea.height = 500;
			initComponents();
			addChild(scrollArea);
			g.stage.addEventListener("updateButtons",updateButtons);
		}
		
		private function initComponents() : void {
			var _local1:Text = new Text();
			_local1.htmlText = Localize.t("Movements:");
			_local1.size = 16;
			_local1.y = currentHeight;
			_local1.x = currentWidth;
			scrollArea.addChild(_local1);
			currentHeight += 40;
			addKeybind(11);
			addKeybind(26);
			addKeybind(12);
			addKeybind(13);
			addKeybind(14);
			_local1 = new Text();
			_local1.htmlText = Localize.t("Abilities:");
			_local1.size = 16;
			_local1.y = currentHeight;
			_local1.x = currentWidth;
			scrollArea.addChild(_local1);
			currentHeight += 40;
			addKeybind(16);
			addKeybind(15);
			addKeybind(18);
			addKeybind(17);
			_local1 = new Text();
			_local1.htmlText = Localize.t("Weapons");
			_local1.size = 16;
			_local1.y = currentHeight;
			_local1.x = currentWidth;
			scrollArea.addChild(_local1);
			currentHeight += 40;
			addKeybind(19);
			addKeybind(20);
			addKeybind(21);
			addKeybind(22);
			addKeybind(23);
			addKeybind(24);
			_local1 = new Text();
			_local1.htmlText = Localize.t("Misc:");
			_local1.size = 16;
			_local1.y = currentHeight;
			_local1.x = currentWidth;
			scrollArea.addChild(_local1);
			currentHeight += 40;
			addKeybind(10);
			addKeybind(9);
			addKeybind(2);
			addKeybind(1);
			addKeybind(3);
			addKeybind(7);
			addKeybind(25);
			addKeybind(6);
			addKeybind(4);
			addKeybind(5);
			addKeybind(8);
			addKeybind(0);
		}
		
		private function addKeybind(type:int) : void {
			var _local2:SettingsKeybind = new SettingsKeybind(keybinds,type,currentWidth,currentHeight);
			keybindList.push(_local2);
			scrollArea.addChild(_local2);
			currentHeight += 62;
		}
		
		public function updateButtons(e:Event) : void {
			for each(var _local2 in keybindList) {
				_local2.update();
			}
		}
	}
}

