package core.states.gameStates
{
	import core.player.Player;
	import core.scene.Game;
	import core.scene.SceneBase;
	import core.states.GameStateMachine;
	import core.states.IGameState;
	import data.KeyBinds;
	import io.IInput;
	import sound.ISound;
	import textures.ITextureManager;
	
	public class GameState implements IGameState
	{
		protected var sm:GameStateMachine;
		
		protected var g:Game;
		
		protected var me:Player;
		
		protected var input:IInput;
		
		protected var soundManager:ISound;
		
		protected var textureManager:ITextureManager;
		
		protected var _loaded:Boolean = false;
		protected var _unloaded:Boolean = false;
		protected var keybinds:KeyBinds;
		
		protected var _hasExit:Boolean = false;
		public function GameState(param1:Game)
		{
			super();
			this.g = param1;
			this.me = param1.me;
			keybinds = SceneBase.settings.keybinds;
		}
		
		public function enter():void
		{
		}
		
		public function execute():void
		{
		}
		
		public function exit(param1:Function):void
		{
			_hasExit = true;
		}
		
		public function set stateMachine(param1:GameStateMachine):void
		{
			this.sm = param1;
		}
		
		public function tickUpdate():void
		{
			if (!g.isLeaving)
			{
				if (g.me.commandable)
				{
				}
				g.tickUpdate();
			}
		}
		
		public function get loaded():Boolean
		{
			return _loaded;
		}
		
		public function get unloaded():Boolean
		{
			return _unloaded;
		}
		
		public function loadCompleted():void
		{
			_loaded = true;
		}
		
		public function unloadCompleted():void
		{
			_unloaded = true;
		}
	}
}
