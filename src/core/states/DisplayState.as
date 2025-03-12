package core.states
{
	import core.hud.components.Button;
	import core.scene.Game;
	import core.states.menuStates.ArtifactState2;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class DisplayState implements IDisplayState
	{
		protected var sm:DisplayStateMachine;
		
		protected var g:Game;
		
		protected var textureManager:ITextureManager;
		
		protected var container:Sprite;
		
		private var rootState:Class;
		
		private var isRoot:Boolean;
		
		private var parent:Sprite;
		
		public var backButton:Button;
		
		public function DisplayState(param1:Game, param2:Class, param3:Boolean = false)
		{
			super();
			this.g = param1;
			this.isRoot = param3;
			this.rootState = param2;
			textureManager = TextureLocator.getService();
		}
		
		public function enter():void
		{
			g.messageLog.visible = false;
			parent = sm.parent;
			container = new Sprite();
			backButton = new Button(back, "Back");
			backButton.x = 45;
			backButton.y = 50;
			if (sm.inState(rootState) || isRoot || this is ArtifactState2)
			{
				backButton.visible = false;
			}
			else
			{
				backButton.visible = true;
			}
			parent.addChild(container);
			parent.addChild(backButton);
		}
		
		public function execute():void
		{
		}
		
		public function exit():void
		{
			container.removeChildren(0, container.numChildren, true);
			if (parent.contains(container))
			{
				parent.removeChild(container, true);
			}
			if (parent.contains(backButton))
			{
				parent.removeChild(backButton, true);
			}
			container = null;
			parent = null;
		}
		
		public function set stateMachine(param1:DisplayStateMachine):void
		{
			this.sm = param1;
		}
		
		protected function addChild(param1:DisplayObject):void
		{
			if (container != null)
			{
				container.addChild(param1);
			}
		}
		
		protected function removeChild(param1:DisplayObject, param2:Boolean = false):void
		{
			if (container != null && container.contains(param1))
			{
				container.removeChild(param1, param2);
			}
		}
		
		public function get type():String
		{
			return "DisplayState";
		}
		
		private function back(param1:TouchEvent):void
		{
			sm.revertState();
		}
	}
}
