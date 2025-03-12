package core.states
{
	
	public interface IGameState
	{
		function enter():void;
		
		function execute():void;
		
		function exit(param1:Function):void;
		
		function tickUpdate():void;
		
		function set stateMachine(param1:GameStateMachine):void;
		
		function get loaded():Boolean;
		
		function get unloaded():Boolean;
		
		function loadCompleted():void;
		
		function unloadCompleted():void;
	}
}
