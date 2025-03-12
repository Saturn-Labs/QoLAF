package core.states.gameStates
{
	import core.hud.components.ToolTip;
	import core.hud.components.map.Map;
	import core.scene.Game;
	import starling.events.Event;
	
	public class MapState extends PlayState
	{
		private var map:Map;
		
		public function MapState(param1:Game)
		{
			super(param1);
			map = new Map(param1);
		}
		
		override public function enter():void
		{
			super.enter();
			map.load();
			map.visible = false;
			addChild(map);
			g.hud.show = false;
			g.tutorial.showMapTargetHint();
			map.addEventListener("close", function(param1:Event):void
			{
				sm.revertState();
			});
			loadCompleted();
		}
		
		override public function tickUpdate():void
		{
			if (!map.visible)
			{
				map.visible = true;
			}
			super.tickUpdate();
			map.update();
		}
		
		override public function execute():void
		{
			if (loaded)
			{
				if (keybinds.isEscPressed || keybinds.isInputPressed(9))
				{
					sm.revertState();
				}
				else if (keybinds.isInputPressed(1) && (g.me.isDeveloper || g.me.isModerator))
				{
					sm.changeState(new GoWarpState(g));
				}
				else if (keybinds.isInputPressed(7) && (g.me.isDeveloper || g.me.isModerator))
				{
					sm.changeState(new PodState(g));
				}
				updateCommands();
			}
			super.execute();
		}
		
		override public function exit(param1:Function):void
		{
			ToolTip.disposeType("Map");
			map.removeEventListeners();
			map.dispose();
			container.removeChildren(0, -1, true);
			super.exit(param1);
		}
	}
}
