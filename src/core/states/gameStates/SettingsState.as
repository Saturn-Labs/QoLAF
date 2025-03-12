package core.states.gameStates
{
	import core.hud.components.ButtonExpandableHud;
	import core.scene.Game;
	import core.scene.SceneBase;
	import data.Settings;
	import generics.Localize;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class SettingsState extends PlayState
	{
		private var goTo:String;
		
		private var settings:Settings;
		
		private var bg:Image;
		
		private var closeButton:ButtonExpandableHud;
		
		private var generalButton:ButtonExpandableHud;
		
		private var bindingsButton:ButtonExpandableHud;
		
		private var chatButton:ButtonExpandableHud;
		
		private var activeButton:ButtonExpandableHud;
		
		private var activePage:Sprite;
		
		public function SettingsState(param1:Game, param2:String = "")
		{
			var g:Game = param1;
			var goTo:String = param2;
			super(g);
			this.goTo = goTo;
			this.settings = SceneBase.settings;
			bg = new Image(textureManager.getTextureGUIByTextureName("map_bgr.png"));
			generalButton = new ButtonExpandableHud(function():void
			{
				show(SettingsGeneral, generalButton);
			}, "General");
			bindingsButton = new ButtonExpandableHud(function():void
			{
				show(SettingsBindings, bindingsButton);
			}, "Key bindings");
			chatButton = new ButtonExpandableHud(function():void
			{
				show(SettingsChat, chatButton);
			}, "Chat");
			closeButton = new ButtonExpandableHud(close, Localize.t("close"));
		}
		
		override public function enter():void
		{
			super.enter();
			g.hud.show = false;
			drawBlackBackground();
			addChild(bg);
			g.addChildToMenu(generalButton);
			g.addChildToMenu(bindingsButton);
			g.addChildToMenu(chatButton);
			g.addChildToMenu(closeButton);
			resize();
			show(SettingsGeneral, generalButton);
		}
		
		override public function resize(param1:Event = null):void
		{
			super.resize();
			container.x = g.stage.stageWidth / 2 - bg.width / 2;
			container.y = g.stage.stageHeight / 2 - bg.height / 2;
			generalButton.x = container.x + 40;
			generalButton.y = container.y;
			bindingsButton.x = generalButton.x + generalButton.width + 5;
			bindingsButton.y = generalButton.y;
			chatButton.x = bindingsButton.x + bindingsButton.width + 5;
			chatButton.y = bindingsButton.y;
			closeButton.y = container.y;
			closeButton.x = container.x + 760 - 46 - closeButton.width;
		}
		
		override public function execute():void
		{
			updateInput();
			super.execute();
		}
		
		private function updateInput():void
		{
			if (!loaded)
			{
				return;
			}
			checkAccelerate(true);
			if (keybinds.isEscPressed || keybinds.isInputPressed(8))
			{
				close();
			}
		}
		
		private function show(param1:Class, param2:ButtonExpandableHud):void
		{
			if (activeButton == param2)
			{
				activeButton.enabled = true;
				return;
			}
			if (activePage)
			{
				container.removeChild(activePage, true);
			}
			activePage = new param1(g);
			container.addChild(activePage);
			updateButtons(param2);
		}
		
		private function updateButtons(param1:ButtonExpandableHud):void
		{
			generalButton.select = param1 == generalButton;
			bindingsButton.select = param1 == bindingsButton;
			chatButton.select = param1 == chatButton;
			activeButton = param1;
			activeButton.enabled = true;
		}
		
		private function close():void
		{
			g.removeChildFromMenu(generalButton);
			g.removeChildFromMenu(bindingsButton);
			g.removeChildFromMenu(chatButton);
			g.removeChildFromMenu(closeButton);
			if (activePage)
			{
				container.removeChild(activePage, true);
			}
			clearBackground();
			g.me.rotationSpeedMod = settings.rotationSpeed;
			SceneBase.settings.save();
			sm.revertState();
		}
	}
}
