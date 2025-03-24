package core.states.gameStates {
	import core.player.LandedBody;
	import core.scene.Game;
	import core.solarSystem.Body;
	import core.states.DisplayStateMachine;
	import core.states.exploreStates.ExploreState;
	import core.states.exploreStates.ReportState;
	import core.states.exploreStates.SelectTeamState;
	import facebook.Action;
	import starling.display.Sprite;
	
	public class LandedExplore extends LandedState {
		private var sceneSM:DisplayStateMachine;
		
		private var container:Sprite;
		
		public function LandedExplore(g:Game, body:Body) {
			var _local4:Boolean = false;
			for each(var _local3 in g.me.landedBodies) {
				if(_local3.key == body.key) {
					_local4 = true;
					break;
				}
			}
			if(!_local4) {
				g.me.landedBodies.push(new LandedBody(body.key,false));
				Action.discover(body.key);
			}
			super(g,body,body.name);
		}
		
		override public function enter() : void {
			super.enter();
			container = new Sprite();
			sceneSM = new DisplayStateMachine(container);
			sceneSM.changeState(new ExploreState(g,body));
			loadCompleted();
			addChild(container);
		}
		
		override public function execute() : void {
			if(sceneSM.inState(SelectTeamState)) {
				leaveButton.visible = false;
				if(keybinds.isEscPressed) {
					sceneSM.revertState();
				}
			} else if(sceneSM.inState(ReportState)) {
				leaveButton.visible = false;
			} else {
				super.execute();
				leaveButton.visible = true;
				if(_loaded && !g.blockHotkeys && keybinds.isEscPressed || !g.chatInput.isActive() && keybinds.isInputPressed(10)) {
					super.leave();
				}
			}
		}
		
		override public function tickUpdate() : void {
			sceneSM.update();
			super.tickUpdate();
		}
		
		override public function exit(callback:Function) : void {
			sceneSM.changeState(null);
			super.exit(callback);
		}
	}
}

