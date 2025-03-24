package playerio {
	import flash.display.Stage;
	import flash.net.LocalConnection;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	import playerio.generated.PlayerIOError;
	import playerio.generated.QuickConnect;
	import playerio.generated.messages.KeyValuePair;
	import playerio.generated.messages.PlayerInsightState;
	import playerio.utils.HTTPChannel;
	import playerio.utils.Utilities;
	
	public class QuickConnect extends playerio.generated.QuickConnect {
		private var connections:Array = [];
		
		public function QuickConnect(channel:HTTPChannel) {
			super(channel);
		}
		
		public function simpleConnect(stage:Stage, gameId:String, usernameOrEmail:String, password:String, playerInsightSegments:* = null, callback:* = null, errorHandler:* = null) : void {
			if(stage == null || stage.stage == null) {
				throw new Error("Parsed stage is not attached to document stage",2);
			}
			if(playerInsightSegments is Function) {
				simpleConnect(stage,gameId,usernameOrEmail,password,null,playerInsightSegments,callback);
				return;
			}
			_simpleConnect(gameId,usernameOrEmail,password,playerInsightSegments,Utilities.clientAPI,Utilities.getSystemInfo(),function(param1:String, param2:String, param3:Boolean, param4:String, param5:String, param6:PlayerInsightState):void {
				if(param3 && Minilogo.showLogo) {
					stage.addChild(new Minilogo());
				}
				var _local7:HTTPChannel = PlayerIO._internal_getChannel();
				_local7.token = param1;
				callback(new Client(stage,_local7,gameId,param4,param1,param2,param3,param6));
			},errorHandler);
		}
		
		public function simpleRegister(stage:Stage, gameId:String, usernameOrEmail:String, password:String, email:String, captchaKey:String, captchaValue:String, extraData:Object, partnerId:* = null, playerInsightSegments:* = null, callback:* = null, errorHandler:* = null) : void {
			if(stage == null || stage.stage == null) {
				throw new Error("Parsed stage is not attached to document stage",2);
			}
			if(partnerId is Function) {
				simpleRegister(stage,gameId,usernameOrEmail,password,email,captchaKey,captchaValue,extraData,null,null,partnerId,playerInsightSegments);
				return;
			}
			if(playerInsightSegments is Function) {
				simpleRegister(stage,gameId,usernameOrEmail,password,email,captchaKey,captchaValue,extraData,partnerId,null,playerInsightSegments,callback);
				return;
			}
			_simpleRegister(gameId,usernameOrEmail,password,email,captchaKey,captchaValue,extraData,partnerId,playerInsightSegments,Utilities.clientAPI,Utilities.getSystemInfo(),function(param1:String, param2:String, param3:Boolean, param4:String, param5:String, param6:PlayerInsightState):void {
				if(param3 && Minilogo.showLogo) {
					stage.addChild(new Minilogo());
				}
				var _local7:HTTPChannel = PlayerIO._internal_getChannel();
				_local7.token = param1;
				callback(new Client(stage,_local7,gameId,param4,param1,param2,param3,param6));
			},errorHandler);
		}
		
		override public function simpleGetCaptcha(gameId:String, width:int, height:int, callback:Function = null, errorHandler:Function = null) : void {
			super.simpleGetCaptcha(gameId,width,height,callback,errorHandler);
		}
		
		override public function simpleRecoverPassword(gameId:String, usernameOrEmail:String, callback:Function = null, errorHandler:Function = null) : void {
			super.simpleRecoverPassword(gameId,usernameOrEmail,callback,errorHandler);
		}
		
		public function facebookConnect(stage:Stage, gameId:String, uid:String, sessionKey:String, partnerid:* = null, playerInsightSegments:* = null, callback:* = null, errorHandler:* = null) : void {
			throw new Error("ERROR: facebookConnect is deprecated as Facebook is switching to OAuth. Please use facebookOAuthConnect instead.");
		}
		
		public function facebookOAuthConnect(stage:Stage, gameId:String, accessToken:String, partnerId:* = null, playerInsightSegments:* = null, callback:* = null, errorHandler:* = null) : void {
			if(stage == null || stage.stage == null) {
				throw new Error("Parsed stage is not attached to document stage",2);
			}
			if(partnerId is Function) {
				facebookOAuthConnect(stage,gameId,accessToken,null,null,partnerId,playerInsightSegments);
				return;
			}
			if(playerInsightSegments is Function) {
				facebookOAuthConnect(stage,gameId,accessToken,partnerId,null,playerInsightSegments,callback);
				return;
			}
			_facebookOAuthConnect(gameId,accessToken,partnerId,playerInsightSegments,Utilities.clientAPI,Utilities.getSystemInfo(),function(param1:String, param2:String, param3:Boolean, param4:String, param5:String, param6:String, param7:PlayerInsightState):void {
				if(param3 && Minilogo.showLogo) {
					stage.addChild(new Minilogo());
				}
				var _local8:HTTPChannel = PlayerIO._internal_getChannel();
				_local8.token = param1;
				callback(new Client(stage,_local8,gameId,param4,param1,param2,param3,param7),param5);
			},errorHandler);
		}
		
		public function kongregateConnect(stage:Stage, gameId:String, userId:String, gameAuthToken:String, playerInsightSegments:* = null, callback:* = null, errorHandler:* = null) : void {
			if(stage == null || stage.stage == null) {
				throw new Error("Parsed stage is not attached to document stage",2);
			}
			if(playerInsightSegments is Function) {
				kongregateConnect(stage,gameId,userId,gameAuthToken,null,playerInsightSegments,callback);
				return;
			}
			_kongregateConnect(gameId,userId,gameAuthToken,playerInsightSegments,Utilities.clientAPI,Utilities.getSystemInfo(),function(param1:String, param2:String, param3:Boolean, param4:String, param5:PlayerInsightState):void {
				if(param3 && Minilogo.showLogo) {
					stage.addChild(new Minilogo());
				}
				var _local6:HTTPChannel = PlayerIO._internal_getChannel();
				_local6.token = param1;
				callback(new Client(stage,_local6,gameId,param4,param1,param2,param3,param5));
			},errorHandler);
		}
		
		public function facebookOAuthConnectPopup(stage:Stage, gameId:String, window:String, permissions:Array = null, partnerId:* = null, playerInsightSegments:* = null, callback:* = null, errorHandler:* = null) : void {
			var legacy:Boolean;
			var e:playerio.generated.PlayerIOError;
			var url:String;
			var variables:URLVariables;
			var commid:String;
			var request:URLRequest;
			var receivingLC:LocalConnection;
			if(stage == null || stage.stage == null) {
				throw new Error("Parsed stage is not attached to document stage",2);
			}
			if(partnerId is Function) {
				facebookOAuthConnectPopup(stage,gameId,window,permissions,null,partnerId,playerInsightSegments);
				return;
			}
			if(playerInsightSegments is Function) {
				facebookOAuthConnectPopup(stage,gameId,window,permissions,partnerId,null,playerInsightSegments,callback);
				return;
			}
			legacy = false;
			if(gameId.substring(0,1) == "@") {
				legacy = true;
				gameId = gameId.substring(1);
			}
			if(/\[|\]/gi.test(gameId)) {
				e = new playerio.generated.PlayerIOError("The Player.IO Game id \"" + gameId + "\" contains invalid characters, did you insert your game id?",1);
				if(errorHandler != null) {
					errorHandler(e);
					return;
				}
				throw e;
			}
			if(legacy) {
				url = "http://fb.playerio.com/fb/" + gameId + "/_fb_quickconnect_oauth";
			} else {
				url = "http://" + gameId + ".fb.playerio.com/fb/_fb_quickconnect_oauth";
			}
			variables = new URLVariables();
			commid = Math.floor(new Date().getTime()).toString() + (Math.random() * 999999 >> 0).toString();
			variables.req_perms = !!permissions ? permissions.join(",") : "";
			variables.communicationId = commid;
			variables.partnerId = partnerId;
			variables.clientapi = Utilities.clientAPI;
			variables.clientinfo = Utilities.getSystemInfoString();
			variables.playerinsightsegments = (playerInsightSegments || []).join(",");
			request = new URLRequest(url);
			request.data = variables;
			request.method = "POST";
			try {
				navigateToURL(request,window);
			}
			catch(e:Error) {
				trace("Error occurred!");
			}
			receivingLC = new LocalConnection();
			connections.push(receivingLC);
			receivingLC.client = {"oauth2":function(param1:String, param2:String, param3:String, param4:String = "", param5:Boolean = true, param6:String = "", param7:String = null, param8:String = "-1", param9:String = ""):void {
				var _local11:int = 0;
				var _local13:Array = null;
				var _local10:KeyValuePair = null;
				if(param5 && Minilogo.showLogo) {
					stage.addChild(new Minilogo());
				}
				var _local15:HTTPChannel = PlayerIO._internal_getChannel();
				_local15.token = param1;
				var _local12:PlayerInsightState = new PlayerInsightState();
				_local12.playersOnline = parseInt(param8 || "-1");
				var _local14:Array = (param9 || "").split(",");
				_local11 = 0;
				while(_local11 < _local14.length) {
					_local13 = _local14[_local11].split(":");
					_local10 = new KeyValuePair();
					_local10.key = _local13[0];
					_local10.value = _local13[1];
					_local12.segments.push(_local10);
					_local11++;
				}
				callback(new Client(stage,_local15,gameId,param6,param1,param4,param5,_local12),param2,param3);
			}};
			receivingLC.allowDomain("*");
			receivingLC.connect("_facebook_" + commid);
		}
		
		public function facebookConnectPopup(stage:Stage, gameId:String, window:String, permissions:Array = null, partnerId:* = null, callback:* = null, errorHandler:* = null) : void {
			throw new Error("FacebookConnectPopup is no longer supported by Facebook. Please use FacebookConnectOAuthPopup");
		}
	}
}

