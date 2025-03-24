package core.states.player {
	import core.player.Player;
	import core.scene.Game;
	import core.states.IState;
	import core.states.StateMachine;
	
	public class Roaming implements IState {
		private var player:Player;
		
		private var sm:StateMachine;
		
		private var g:Game;
		
		public function Roaming(player:Player, g:Game) {
			super();
			this.g = g;
			this.player = player;
		}
		
		public function enter() : void {
			if(player.isMe) {
				g.focusGameObject(player.ship,true);
			}
			player.ship.engine.show();
		}
		
		public function execute() : void {
		}
		
		public function exit() : void {
		}
		
		public function get type() : String {
			return "Roaming";
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
	}
}

