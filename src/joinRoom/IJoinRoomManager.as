package joinRoom
{
	import core.player.Player;
	
	public interface IJoinRoomManager
	{
		function init():void;
		
		function joinServiceRoom(param1:String):void;
		
		function joinGame(param1:String, param2:Object):void;
		
		function tryWarpJumpToFriend(param1:Player, param2:String, param3:Function, param4:Function):void;
		
		function set desiredRoomId(param1:String):void;
		
		function get desiredRoomId():String;
		
		function set desiredSystemType(param1:String):void;
		
		function get desiredSystemType():String;
	}
}
