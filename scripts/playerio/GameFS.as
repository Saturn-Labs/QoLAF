package playerio {
	public class GameFS {
		private static var maps:Object = {};
		
		private var gameId:String;
		
		public function GameFS(gameId:String, gameFSRedirectMap:String) {
			super();
			this.gameId = gameId;
			if(gameFSRedirectMap != null) {
				maps[gameId] = new UrlMap(gameFSRedirectMap);
			}
		}
		
		private static function getUrl(gameId:String, path:String, secure:Boolean = false) : String {
			var _local4:UrlMap = null;
			if(path.indexOf("/") != 0) {
				throw new Error("GameFS paths must be absolute and start with a slash (/). IE client.gameFS.getURL(\"/folder/file.extention\")",0);
			}
			if(maps != null && maps[gameId] != undefined) {
				_local4 = UrlMap(maps[gameId]);
				return _local4.getUrl(path,secure);
			}
			return (secure ? "https" : "http") + "://r.playerio.com/r/" + gameId + path;
		}
		
		public function getUrl(path:String, secure:Boolean = false) : String {
			return GameFS.getUrl(gameId,path,secure);
		}
	}
}

class UrlMap {
	private var baseUrl:String;
	
	private var secureBaseUrl:String;
	
	private var map:Object = null;
	
	public function UrlMap(gameFSRedirectMap:String) {
		var _local2:Array = null;
		var _local4:int = 0;
		var _local3:String = null;
		super();
		if(gameFSRedirectMap != null && gameFSRedirectMap != "") {
			_local2 = gameFSRedirectMap.split("|");
			map = {};
			_local4 = 0;
			while(_local4 != _local2.length) {
				_local3 = _local2[_local4];
				if(_local3 == "alltoredirect" || _local3 == "cdnmap") {
					baseUrl = _local2[_local4 + 1];
				} else if(_local3 == "alltoredirectsecure" || _local3 == "cdnmapsecure") {
					secureBaseUrl = _local2[_local4 + 1];
				} else {
					map[_local3] = _local2[_local4 + 1];
				}
				_local4 += 2;
			}
		}
	}
	
	public function getUrl(path:String, secure:Boolean) : String {
		if(map == null) {
			return (secure ? secureBaseUrl : baseUrl) + path;
		}
		if(map[path] != undefined) {
			return (secure ? secureBaseUrl : baseUrl) + map[path];
		}
		return (secure ? secureBaseUrl : baseUrl) + path;
	}
}
