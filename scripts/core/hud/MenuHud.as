package core.hud {
	import core.hud.components.ButtonExpandableHud;
	import core.hud.components.ImageButton;
	import core.scene.Game;
	import core.states.DisplayStateMachine;
	import core.states.menuStates.ArtifactState2;
	import core.states.menuStates.CargoState;
	import core.states.menuStates.CrewStateNew;
	import core.states.menuStates.EncounterState;
	import core.states.menuStates.FleetState;
	import core.states.menuStates.HomeState;
	import generics.Localize;
	import starling.display.Image;
	import starling.display.Sprite;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class MenuHud extends Sprite {
		private var continueGameCallback:Function;
		
		private var g:Game;
		
		private var buttons:Vector.<ImageButton> = new Vector.<ImageButton>();
		
		private var bgr:Image;
		
		private var continueGameButton:ButtonExpandableHud;
		
		public var stateMachine:DisplayStateMachine;
		
		public function MenuHud(g:Game, continueGameCallback:Function) {
			super();
			this.g = g;
			this.continueGameCallback = continueGameCallback;
			stateMachine = new DisplayStateMachine(this);
		}
		
		public function load(menuState:Class, callback:Function) : void {
			var _local3:ITextureManager = TextureLocator.getService();
			bgr = new Image(_local3.getTextureGUIByTextureName("map_bgr.png"));
			addChild(bgr);
			continueGameButton = new ButtonExpandableHud(close,Localize.t("close"));
			continueGameButton.x = bgr.width - 46 - continueGameButton.width;
			continueGameButton.y = 0;
			addChild(continueGameButton);
			changeState(menuState);
			callback();
		}
		
		public function showCloseButton(value:Boolean) : void {
			continueGameButton.visible = value;
		}
		
		public function update() : void {
			stateMachine.update();
		}
		
		private function close() : void {
			continueGameCallback();
			unload();
		}
		
		public function unload() : void {
			stateMachine.changeState(null);
		}
		
		public function inState(menuState:Class) : Boolean {
			return stateMachine.inState(menuState);
		}
		
		public function changeState(menuState:Class) : void {
			if(menuState == CargoState) {
				stateMachine.changeState(new CargoState(g,g.me,true));
			} else if(menuState == ArtifactState2) {
				stateMachine.changeState(new ArtifactState2(g,g.me,true));
			} else if(menuState == EncounterState) {
				stateMachine.changeState(new EncounterState(g,true));
			} else if(menuState == FleetState) {
				stateMachine.changeState(new FleetState(g,true));
			} else if(menuState == CrewStateNew) {
				stateMachine.changeState(new CrewStateNew(g));
			} else {
				stateMachine.changeState(new HomeState(g,g.me));
			}
		}
	}
}

