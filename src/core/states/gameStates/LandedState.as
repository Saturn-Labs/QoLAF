package core.states.gameStates
{
	import core.hud.MenuHud;
	import core.hud.components.ButtonExpandableHud;
	import core.scene.Game;
	import core.solarSystem.Body;
	import core.states.menuStates.ArtifactState2;
	import core.states.menuStates.CargoState;
	import core.states.menuStates.CrewStateNew;
	import core.states.menuStates.FleetState;
	import core.states.menuStates.HomeState;
	import core.tutorial.Tutorial;
	import data.DataLocator;
	import data.IDataManager;
	import io.InputLocator;
	import sound.SoundLocator;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import textures.TextureLocator;
	
	public class LandedState extends GameState
	{
		protected var body:Body;
		
		protected var dataManager:IDataManager;
		
		protected var bg:Image;
		
		private var container:Sprite;
		
		private var menuHud:MenuHud;
		
		public var leaveButton:ButtonExpandableHud;
		
		private var shipButton:ButtonExpandableHud;
		
		private var fleetButton:ButtonExpandableHud;
		
		private var defaultButton:ButtonExpandableHud;
		
		private var cargoButton:ButtonExpandableHud;
		
		private var artifactButton:ButtonExpandableHud;
		
		private var crewButton:ButtonExpandableHud;
		
		private var bgrOverlay:Quad;
		
		private var bgrMenuOverlay:Quad;
		
		public function LandedState(param1:Game, param2:Body, param3:String)
		{
			var g:Game = param1;
			var body:Body = param2;
			var stationName:String = param3;
			container = new Sprite();
			bgrOverlay = new Quad(100, 100, 0);
			bgrMenuOverlay = new Quad(100, 100, 0);
			super(g);
			this.body = body;
			g.messageLog.visible = false;
			input = InputLocator.getService();
			soundManager = SoundLocator.getService();
			textureManager = TextureLocator.getService();
			dataManager = DataLocator.getService();
			leaveButton = new ButtonExpandableHud(leave, "take off");
			container.addChild(bgrOverlay);
			bg = new Image(textureManager.getTextureGUIByTextureName("map_bgr.png"));
			if (stationName.length > 16)
			{
				stationName = stationName.slice(0, 16);
			}
			defaultButton = new ButtonExpandableHud(function():void
			{
				hideMenu();
				defaultButton.enabled = true;
			}, stationName);
			fleetButton = new ButtonExpandableHud(function():void
			{
				showMenu(FleetState, fleetButton);
				fleetButton.enabled = true;
			}, "Fleet");
			shipButton = new ButtonExpandableHud(function():void
			{
				showMenu(HomeState, shipButton);
				shipButton.enabled = true;
			}, "Ship");
			cargoButton = new ButtonExpandableHud(function():void
			{
				showMenu(CargoState, cargoButton);
				cargoButton.enabled = true;
			}, "Cargo");
			artifactButton = new ButtonExpandableHud(function():void
			{
				showMenu(ArtifactState2, artifactButton);
				artifactButton.enabled = true;
			}, "Artifacts");
			crewButton = new ButtonExpandableHud(function():void
			{
				showMenu(CrewStateNew, crewButton);
				crewButton.enabled = true;
			}, "Crew");
			container.addChild(bg);
			resize();
			selectButton(defaultButton);
		}
		
		private function selectButton(param1:ButtonExpandableHud):void
		{
			defaultButton.select = param1 == defaultButton ? true : false;
			fleetButton.select = param1 == fleetButton ? true : false;
			shipButton.select = param1 == shipButton ? true : false;
			cargoButton.select = param1 == cargoButton ? true : false;
			artifactButton.select = param1 == artifactButton ? true : false;
		}
		
		override public function enter():void
		{
			g.hud.show = false;
			g.toggleRoamingCanvases(false);
			RymdenRunt.s.nativeStage.frameRate = 30;
			g.addChildToMenu(container);
			g.addChildToMenu(defaultButton);
			g.addChildToMenu(fleetButton);
			g.addChildToMenu(shipButton);
			g.addChildToMenu(cargoButton);
			g.addChildToMenu(artifactButton);
			g.addChildToMenu(leaveButton);
			g.addChildToMenu(crewButton);
			g.hud.healthAndShield.stopLowHPWarningEffect();
			g.addResizeListener(resize);
		}
		
		public function resize(param1:Event = null):void
		{
			container.x = g.stage.stageWidth / 2 - bg.width / 2;
			container.y = g.stage.stageHeight / 2 - bg.height / 2;
			defaultButton.x = container.x + 40;
			defaultButton.y = container.y;
			fleetButton.x = defaultButton.x + defaultButton.width + 5;
			fleetButton.y = defaultButton.y;
			shipButton.x = fleetButton.x + fleetButton.width + 5;
			shipButton.y = fleetButton.y;
			cargoButton.x = shipButton.x + shipButton.width + 5;
			cargoButton.y = shipButton.y;
			artifactButton.x = cargoButton.x + cargoButton.width + 5;
			artifactButton.y = shipButton.y;
			crewButton.x = artifactButton.x + artifactButton.width + 5;
			crewButton.y = shipButton.y;
			leaveButton.y = container.y;
			leaveButton.x = container.x + 760 - 46 - leaveButton.width;
			drawBlackBackground();
		}
		
		override public function execute():void
		{
			if (g.isLeaving)
			{
				return;
			}
			g.draw();
			if (menuHud != null)
			{
				menuHud.update();
			}
			if (!_loaded || g.blockHotkeys)
			{
				return;
			}
			if (keybinds.isEscPressed || !g.chatInput.isActive() && keybinds.isInputPressed(10))
			{
				if (g.chatInput.isActive())
				{
					g.chatInput.closeChat();
				}
				else if (menuHud != null)
				{
					hideMenu();
				}
				else
				{
					leave();
				}
			}
			else if (keybinds.isEnterPressed)
			{
				g.chatInput.toggleChatMode();
			}
			else if (g.chatInput.isActive())
			{
				if (input.isKeyPressed(40))
				{
					g.chatInput.next();
				}
				if (input.isKeyPressed(38))
				{
					g.chatInput.previous();
				}
				return;
			}
		}
		
		override public function loadCompleted():void
		{
			Login.fadeScreen.fadeOut();
			_loaded = true;
		}
		
		override public function exit(param1:Function):void
		{
			g.removeChildFromMenu(container);
			g.removeChildFromMenu(defaultButton);
			g.removeChildFromMenu(fleetButton);
			g.removeChildFromMenu(shipButton);
			g.removeChildFromMenu(cargoButton);
			g.removeChildFromMenu(artifactButton);
			g.removeChildFromMenu(leaveButton);
			g.removeChildFromMenu(crewButton);
			g.removeResizeListener(resize);
			container.removeChildren(0, -1, true);
			unloadCompleted();
			Tutorial.clear();
			g.camera.zoomFocus(1, 1);
			g.toggleRoamingCanvases(true);
			RymdenRunt.s.nativeStage.frameRate = 60;
			param1();
		}
		
		override public function tickUpdate():void
		{
			super.tickUpdate();
		}
		
		private function showMenu(param1:Class, param2:ButtonExpandableHud):void
		{
			var menuState:Class = param1;
			var button:ButtonExpandableHud = param2;
			if (menuHud != null)
			{
				if (menuHud.inState(menuState))
				{
					hideMenu();
					return;
				}
				hideMenu();
			}
			menuHud = new MenuHud(g, function():void
			{
				hideMenu();
			});
			menuHud.load(menuState, function():void
			{
			});
			selectButton(button);
			menuHud.showCloseButton(false);
			addChild(bgrMenuOverlay);
			addChild(menuHud);
			resize();
		}
		
		private function hideMenu(param1:TouchEvent = null):void
		{
			if (menuHud == null)
			{
				return;
			}
			menuHud.unload();
			removeChild(menuHud);
			menuHud = null;
			selectButton(defaultButton);
			removeChild(bgrMenuOverlay);
		}
		
		public function leave(param1:TouchEvent = null):void
		{
			g.me.leaveBody();
		}
		
		protected function addChild(param1:DisplayObject):void
		{
			container.addChild(param1);
		}
		
		protected function removeChild(param1:DisplayObject):void
		{
			if (container.contains(param1))
			{
				container.removeChild(param1);
			}
		}
		
		protected function drawBlackBackground():void
		{
			bgrOverlay.x = -g.stage.stageWidth / 2 + bg.width / 2;
			bgrOverlay.y = -g.stage.stageHeight / 2 + bg.height / 2;
			bgrOverlay.width = g.stage.stageWidth;
			bgrOverlay.height = g.stage.stageHeight;
			if (bgrMenuOverlay == null)
			{
				return;
			}
			bgrMenuOverlay.x = -g.stage.stageWidth / 2 + bg.width / 2;
			bgrMenuOverlay.y = -g.stage.stageHeight / 2 + bg.height / 2;
			bgrMenuOverlay.width = g.stage.stageWidth;
			bgrMenuOverlay.height = g.stage.stageHeight;
		}
	}
}
