package playerio {
	import flash.display.Stage;
	import playerio.generated.PlayerIO;
	import playerio.generated.PlayerIOError;
	import playerio.generated.messages.AuthenticateStartDialog;
	import playerio.generated.messages.KeyValuePair;
	import playerio.generated.messages.PlayerInsightState;
	import playerio.utils.HTTPChannel;
	import playerio.utils.Utilities;
	
	public final class PlayerIO extends playerio.generated.PlayerIO {
		public namespace inside = "http://playerio.com/inside/";
		
		public static var useSecureApiRequests:Boolean = false;
		
		public function PlayerIO() {
			super();
		}
		
		internal static function _internal_getChannel() : HTTPChannel {
			return new HTTPChannel(useSecureApiRequests);
		}
		
		public static function connect(stage:Stage, gameId:String, connectionId:String, userId:String, auth:String, partnerId:* = null, playerInsightSegments:* = null, callback:* = null, errorHandler:* = null) : void {
			new playerio.PlayerIO().connect(stage,gameId,connectionId,userId,auth,partnerId,playerInsightSegments,callback,errorHandler);
		}
		
		public static function authenticate(stage:Stage, gameId:String, connectionId:String, authenticationArguments:Object, playerInsightSegments:* = null, callback:* = null, errorHandler:* = null) : void {
			new playerio.PlayerIO().authenticate(stage,gameId,connectionId,authenticationArguments,playerInsightSegments,callback,errorHandler);
		}
		
		private static function authSuccess(client:Client, channel:HTTPChannel, dialogs:Array, successCallback:Function) : void {
			var dialog:AuthenticateStartDialog;
			var dialogArgs:Object;
			var a:int;
			var kvp:KeyValuePair;
			if(dialogs == null || dialogs.length == 0) {
				if(successCallback != null) {
					successCallback(client);
				}
			} else {
				dialog = dialogs[0];
				dialogArgs = {};
				if(dialog.arguments != null) {
					a = 0;
					while(a < dialog.arguments.length) {
						kvp = dialog.arguments[a] as KeyValuePair;
						dialogArgs[kvp.key] = kvp.value;
						a++;
					}
				}
				PublishingNetworkDialog.showDialog(dialog.name,dialogArgs,channel,function(param1:Object):void {
					dialogs.shift();
					authSuccess(client,channel,dialogs,successCallback);
				});
			}
		}
		
		public static function get quickConnect() : QuickConnect {
			return new QuickConnect(_internal_getChannel());
		}
		
		public static function gameFS(gameId:String) : GameFS {
			return new GameFS(gameId,null);
		}
		
		private function connect(stage:Stage, gameId:String, connectionId:String, userId:String, auth:String, partnerId:* = null, playerInsightSegments:* = null, callback:* = null, errorHandler:* = null) : void {
			if(partnerId is Function) {
				connect(stage,gameId,connectionId,userId,auth,null,null,partnerId,playerInsightSegments);
				return;
			}
			if(playerInsightSegments is Function) {
				connect(stage,gameId,connectionId,userId,auth,partnerId,null,playerInsightSegments,callback);
				return;
			}
			_connect(_internal_getChannel(),gameId,connectionId,userId,auth,partnerId,playerInsightSegments,Utilities.clientAPI,Utilities.getSystemInfo(),function(param1:String, param2:String, param3:Boolean, param4:String, param5:String, param6:PlayerInsightState):void {
				if(stage && param3 && Minilogo.showLogo) {
					stage.addChild(new Minilogo());
				}
				var _local7:HTTPChannel = _internal_getChannel();
				_local7.token = param1;
				callback(new Client(stage,_local7,gameId,param4,param1,userId,param3,param6));
			},errorHandler);
		}
		
		private function authenticate(stage:Stage, gameId:String, connectionId:String, authenticationArguments:Object, playerInsightSegments:Array, callback:Function, errorHandler:Function) : void {
			if(authenticationArguments["publishingnetworklogin"] != undefined && authenticationArguments["publishingnetworklogin"] == "auto") {
				PublishingNetworkDialog.showDialog("login",{
					"gameId":gameId,
					"connectionId":connectionId,
					"__use_usertoken__":"true"
				},null,function(param1:Object):void {
					if(param1["error"] != undefined) {
						errorHandler(new playerio.generated.PlayerIOError(param1["error"],playerio.PlayerIOError.GeneralError.errorID));
					} else if(param1["userToken"] == undefined) {
						errorHandler(new playerio.generated.PlayerIOError("Missing userToken value in result, but no error message given.",playerio.PlayerIOError.GeneralError.errorID));
					} else {
						authenticate(stage,gameId,connectionId,{"userToken":param1["userToken"]},playerInsightSegments,callback,errorHandler);
					}
				});
				return;
			}
			_authenticate(_internal_getChannel(),gameId,connectionId,authenticationArguments,playerInsightSegments,Utilities.clientAPI,Utilities.getSystemInfo(),null,function(param1:String, param2:String, param3:Boolean, param4:String, param5:PlayerInsightState, param6:Array, param7:Boolean, param8:Array, param9:String, param10:Boolean, param11:Array, param12:int, param13:Array):void {
				var _local14:HTTPChannel = new HTTPChannel(useSecureApiRequests);
				_local14.token = param1;
				authSuccess(new Client(stage,_local14,gameId,param4,param1,param2,param3,param5),_local14,param6,callback);
			},errorHandler);
		}
	}
}

