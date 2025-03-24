package playerio {
	import playerio.generated.Multiplayer;
	import playerio.utils.HTTPChannel;
	
	public class Multiplayer extends playerio.generated.Multiplayer {
		private var _developmentServer:String = null;
		
		private var _client:Client;
		
		public function Multiplayer(channel:HTTPChannel, client:Client) {
			super(channel,client);
		}
		
		public function createRoom(roomId:String, roomType:String, visible:Boolean, roomData:Object, callback:Function = null, errorHandler:Function = null) : void {
			_createRoom(roomId,roomType,visible,roomData,_developmentServer != null,callback,errorHandler);
		}
		
		public function joinRoom(roomId:String, joinData:Object, callback:Function = null, errorHandler:Function = null) : void {
			_joinRoom(roomId,joinData,_developmentServer != null,function(param1:String, param2:Array):void {
				doConnect(roomId,param1,param2,joinData,callback,errorHandler);
			},errorHandler);
		}
		
		public function createJoinRoom(roomId:String, roomType:String, visible:Boolean, roomData:Object, joinData:Object, callback:Function = null, errorHandler:Function = null) : void {
			_createJoinRoom(roomId,roomType,visible,roomData,joinData,_developmentServer != null,function(param1:String, param2:String, param3:Array):void {
				doConnect(param1,param2,param3,joinData,callback,errorHandler);
			},errorHandler);
		}
		
		public function listRooms(roomType:String, searchCriteria:Object, resultLimit:int, resultOffset:int, callback:Function = null, errorHandler:Function = null) : void {
			_listRooms(roomType,searchCriteria,resultLimit,resultOffset,_developmentServer != null,callback,errorHandler);
		}
		
		public function set developmentServer(server:String) : void {
			this._developmentServer = server;
		}
		
		public function get developmentServer() : String {
			return this._developmentServer;
		}
		
		private function doConnect(roomid:String, key:String, endpoints:Array, joinData:Object, callback:Function, errorHandler:Function) : void {
			new Connection(client,roomid,key,endpoints,joinData,callback,errorHandler,_developmentServer);
		}
	}
}

