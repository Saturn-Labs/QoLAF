package core.states.gameStates
{
	import core.hud.components.ButtonExpandableHud;
	import core.hud.components.playerList.PlayerList;
	import core.scene.Game;
	import core.states.IGameState;
	import starling.events.Event;
	
	public class PlayerListState extends PlayState implements IGameState
	{
		private var playerList:PlayerList;
		
		private var friendsButton:ButtonExpandableHud;
		
		private var systemPlayersButton:ButtonExpandableHud;
		
		public function PlayerListState(param1:Game)
		{
			super(param1);
			playerList = new PlayerList(param1);
		}
		
		override public function enter():void
		{
			var that:PlayState;
			super.enter();
			addChild(playerList);
			drawBlackBackground();
			that = this;
			systemPlayersButton = new ButtonExpandableHud(function():void
			{
				playerList.drawSystemPlayerList();
				systemPlayersButton.enabled = true;
				systemPlayersButton.select = true;
				friendsButton.select = false;
			}, "Players in system");
			systemPlayersButton.select = true;
			friendsButton = new ButtonExpandableHud(function():void
			{
				playerList.drawOnlineFriends();
				systemPlayersButton.select = false;
				friendsButton.enabled = true;
				friendsButton.select = true;
			}, "Online friends");
			systemPlayersButton.x = 30;
			friendsButton.x = 10 + systemPlayersButton.x + systemPlayersButton.width;
			addChild(systemPlayersButton);
			addChild(friendsButton);
			playerList.load();
			loadCompleted();
			g.hud.show = false;
			playerList.addEventListener("close", function(param1:Event):void
			{
				sm.revertState();
			});
		}
		
		override public function execute():void
		{
			if (!loaded)
			{
				return;
			}
			if (keybinds.isEscPressed || keybinds.isInputPressed(25))
			{
				sm.revertState();
				return;
			}
			updateCommands();
			super.execute();
		}
		
		override public function exit(param1:Function):void
		{
			playerList.dispose();
			super.exit(param1);
		}
	}
}
