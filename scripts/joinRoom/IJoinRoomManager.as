package joinRoom {
	import core.player.Player;
	
	public interface IJoinRoomManager {
		function init() : void;
		
		function joinServiceRoom(id:String) : void;
		
		function joinGame(solarSystemKey:String, joinData:Object) : void;
		
		function tryWarpJumpToFriend(player:Player, destination:String, successCallback:Function, failCallback:Function) : void;
		
		function set desiredRoomId(value:String) : void;
		
		function get desiredRoomId() : String;
		
		function set desiredSystemType(value:String) : void;
		
		function get desiredSystemType() : String;
	}
}

