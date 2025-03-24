package core.states {
	public interface ISceneState {
		function enter() : void;
		
		function execute() : void;
		
		function exit() : void;
		
		function set stateMachine(sm:SceneStateMachine) : void;
	}
}

