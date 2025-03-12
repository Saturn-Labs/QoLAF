package core.states.gameStates
{
	import core.player.LandedBody;
	import core.scene.Game;
	import core.solarSystem.Body;
	import core.states.DisplayStateMachine;
	import core.states.exploreStates.ExploreState;
	import core.states.exploreStates.ReportState;
	import core.states.exploreStates.SelectTeamState;
	import facebook.Action;
	import starling.display.Sprite;
	
	public class LandedExplore extends LandedState
	{
		private var sceneSM:DisplayStateMachine;
		
		private var container:Sprite;
		
		public function LandedExplore(param1:Game, param2:Body)
		{
			var _loc3_:Boolean = false;
			for each (var _loc4_:* in param1.me.landedBodies)
			{
				if (_loc4_.key == param2.key)
				{
					_loc3_ = true;
					break;
				}
			}
			if (!_loc3_)
			{
				param1.me.landedBodies.push(new LandedBody(param2.key, false));
				Action.discover(param2.key);
			}
			super(param1, param2, param2.name);
		}
		
		override public function enter():void
		{
			super.enter();
			container = new Sprite();
			sceneSM = new DisplayStateMachine(container);
			sceneSM.changeState(new ExploreState(g, body));
			loadCompleted();
			addChild(container);
		}
		
		override public function execute():void
		{
			if (sceneSM.inState(SelectTeamState))
			{
				leaveButton.visible = false;
				if (keybinds.isEscPressed)
				{
					sceneSM.revertState();
				}
			}
			else if (sceneSM.inState(ReportState))
			{
				leaveButton.visible = false;
			}
			else
			{
				super.execute();
				leaveButton.visible = true;
				if (_loaded && !g.blockHotkeys && keybinds.isEscPressed || !g.chatInput.isActive() && keybinds.isInputPressed(10))
				{
					super.leave();
				}
			}
		}
		
		override public function tickUpdate():void
		{
			sceneSM.update();
			super.tickUpdate();
		}
		
		override public function exit(param1:Function):void
		{
			sceneSM.changeState(null);
			super.exit(param1);
		}
	}
}
