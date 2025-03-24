package playerio {
	public class RoomInfo {
		private var _id:String;
		
		private var _roomType:String;
		
		private var _onlineUsers:int;
		
		private var _roomData:Object;
		
		public function RoomInfo(id:String, roomType:String, onlineUsers:int, roomData:Object) {
			super();
			_id = id;
			_roomType = roomType;
			_onlineUsers = onlineUsers;
			_roomData = roomData;
		}
		
		public function get id() : String {
			return _id;
		}
		
		public function get serverType() : String {
			trace("serverType is deprecated, please use roomType.");
			return _roomType;
		}
		
		public function get roomType() : String {
			return _roomType;
		}
		
		public function get onlineUsers() : int {
			return _onlineUsers;
		}
		
		public function get initData() : Object {
			trace("initData is deprecated, please use data.");
			return _roomData;
		}
		
		public function get data() : Object {
			return _roomData;
		}
		
		public function toString() : String {
			var _local1:String = "[playerio.RoomInfo]\n";
			_local1 += "id:\t\t\t\t" + id + "\n";
			_local1 += "roomType:\t\t" + roomType + "\n";
			_local1 += "onlineUsers:\t" + onlineUsers + "\n";
			_local1 += "initData:\t\tId\t\t\t\t\t\tValue\n";
			_local1 += "\t\t\t\t-------------------------------------------\n";
			for(var _local2 in initData) {
				_local1 += "\t\t\t\t" + _local2 + "\t\t\t\t\t".substring(_local2.length / 4) + "\t" + initData[_local2] + "\n";
			}
			return _local1;
		}
	}
}

