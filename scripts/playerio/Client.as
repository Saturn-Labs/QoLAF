package playerio {
	import flash.display.Stage;
	import playerio.generated.messages.PlayerInsightState;
	import playerio.utils.HTTPChannel;
	
	public class Client {
		private var _connectUserId:String;
		
		private var _gameId:String;
		
		private var _showBranding:Boolean;
		
		private var _multiplayer:Multiplayer;
		
		private var _bigDB:BigDB;
		
		private var _errorLog:ErrorLog;
		
		private var _notifications:Notifications;
		
		private var _gameFS:GameFS;
		
		private var _payVault:PayVault;
		
		private var _playerInsight:PlayerInsight;
		
		private var _gameRequests:GameRequests;
		
		private var _achievements:Achievements;
		
		private var _social:Social;
		
		private var _publishingnetwork:PublishingNetwork;
		
		private var _oneScore:OneScore;
		
		private var _stage:Stage;
		
		private var _channel:HTTPChannel;
		
		private var _isSocialNetworkuser:Boolean;
		
		public function Client(stage:Stage, channel:HTTPChannel, gameId:String, map:String, token:String, connectUserId:String, showBranding:Boolean, playerInsightstate:PlayerInsightState) {
			super();
			_multiplayer = new Multiplayer(channel,this);
			_errorLog = new ErrorLog(channel,this);
			_bigDB = new BigDB(channel,this);
			_payVault = new PayVault(channel,this);
			_achievements = new Achievements(channel,this);
			_gameFS = new GameFS(gameId,map);
			_playerInsight = new PlayerInsight(channel,this,playerInsightstate);
			_gameRequests = new GameRequests(channel,this);
			_notifications = new Notifications(channel,this);
			_publishingnetwork = new PublishingNetwork(this);
			_social = new Social(channel,this);
			_oneScore = new OneScore(channel,this);
			_connectUserId = connectUserId;
			_stage = stage;
			_channel = channel;
		}
		
		public function get connectUserId() : String {
			return _connectUserId;
		}
		
		public function get gameId() : String {
			return _gameId;
		}
		
		public function get showBranding() : Boolean {
			return _showBranding;
		}
		
		public function get multiplayer() : Multiplayer {
			return _multiplayer;
		}
		
		public function get bigDB() : BigDB {
			return _bigDB;
		}
		
		public function get errorLog() : ErrorLog {
			return _errorLog;
		}
		
		public function get notifications() : Notifications {
			return _notifications;
		}
		
		public function get gameFS() : GameFS {
			return _gameFS;
		}
		
		public function get payVault() : PayVault {
			return _payVault;
		}
		
		public function get playerInsight() : PlayerInsight {
			return _playerInsight;
		}
		
		public function get gameRequests() : GameRequests {
			return _gameRequests;
		}
		
		public function get achievements() : Achievements {
			return _achievements;
		}
		
		internal function get _internal_social() : Social {
			return _social;
		}
		
		public function get publishingnetwork() : PublishingNetwork {
			return _publishingnetwork;
		}
		
		public function get oneScore() : OneScore {
			return _oneScore;
		}
		
		public function get channel() : HTTPChannel {
			return _channel;
		}
		
		public function handleCallbackError(what:String, e:Error) : void {
			if(multiplayer.developmentServer == null) {
				errorLog.writeError(e.name,e.message,(e.getStackTrace() == null ? "I" : e.getStackTrace() + "\n i") + "n callback handler for " + what,{});
			}
		}
		
		public function handleCallbackErrorVerbose(message:String, e:Error) : void {
			if(multiplayer.developmentServer == null) {
				errorLog.writeError(e.message,message,e.getStackTrace() == null ? "" : e.getStackTrace(),{});
			}
		}
		
		public function handleSystemError(message:String, e:Error, extra:Object) : void {
			errorLog.writeError(e.message,message,e.getStackTrace() == null ? "" : e.getStackTrace(),extra);
		}
		
		public function get stage() : Stage {
			return _stage;
		}
		
		public function toString() : String {
			return "[Player.IO Client]";
		}
	}
}

