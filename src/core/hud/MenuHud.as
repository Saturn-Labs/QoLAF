package core.hud
{
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
	
	public class MenuHud extends Sprite
	{
		private var continueGameCallback:Function;
		
		private var g:Game;
		
		private var buttons:Vector.<ImageButton>;
		
		private var bgr:Image;
		
		private var continueGameButton:ButtonExpandableHud;
		
		public var stateMachine:DisplayStateMachine;
		
		public function MenuHud(param1:Game, param2:Function)
		{
			buttons = new Vector.<ImageButton>();
			super();
			this.g = param1;
			this.continueGameCallback = param2;
			stateMachine = new DisplayStateMachine(this);
		}
		
		public function load(param1:Class, param2:Function):void
		{
			var _loc3_:ITextureManager = TextureLocator.getService();
			bgr = new Image(_loc3_.getTextureGUIByTextureName("map_bgr.png"));
			addChild(bgr);
			continueGameButton = new ButtonExpandableHud(close, Localize.t("close"));
			continueGameButton.x = bgr.width - 46 - continueGameButton.width;
			continueGameButton.y = 0;
			addChild(continueGameButton);
			changeState(param1);
			param2();
		}
		
		public function showCloseButton(param1:Boolean):void
		{
			continueGameButton.visible = param1;
		}
		
		public function update():void
		{
			stateMachine.update();
		}
		
		private function close():void
		{
			continueGameCallback();
			unload();
		}
		
		public function unload():void
		{
			stateMachine.changeState(null);
		}
		
		public function inState(param1:Class):Boolean
		{
			return stateMachine.inState(param1);
		}
		
		public function changeState(param1:Class):void
		{
			if (param1 == CargoState)
			{
				stateMachine.changeState(new CargoState(g, g.me, true));
			}
			else if (param1 == ArtifactState2)
			{
				stateMachine.changeState(new ArtifactState2(g, g.me, true));
			}
			else if (param1 == EncounterState)
			{
				stateMachine.changeState(new EncounterState(g, true));
			}
			else if (param1 == FleetState)
			{
				stateMachine.changeState(new FleetState(g, true));
			}
			else if (param1 == CrewStateNew)
			{
				stateMachine.changeState(new CrewStateNew(g));
			}
			else
			{
				stateMachine.changeState(new HomeState(g, g.me));
			}
		}
	}
}
