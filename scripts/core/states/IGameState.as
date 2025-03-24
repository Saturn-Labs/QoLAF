package core.states {
	public interface IGameState {
		function enter() : void;
		
		function execute() : void;
		
		function exit(callback:Function) : void;
		
		function tickUpdate() : void;
		
		function set stateMachine(sm:GameStateMachine) : void;
		
		function get loaded() : Boolean;
		
		function get unloaded() : Boolean;
		
		function loadCompleted() : void;
		
		function unloadCompleted() : void;
	}
}

