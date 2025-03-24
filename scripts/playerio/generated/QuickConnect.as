package playerio.generated {
	import flash.events.EventDispatcher;
	import playerio.generated.messages.FacebookOAuthConnectArgs;
	import playerio.generated.messages.FacebookOAuthConnectError;
	import playerio.generated.messages.FacebookOAuthConnectOutput;
	import playerio.generated.messages.KongregateConnectArgs;
	import playerio.generated.messages.KongregateConnectError;
	import playerio.generated.messages.KongregateConnectOutput;
	import playerio.generated.messages.SimpleConnectArgs;
	import playerio.generated.messages.SimpleConnectError;
	import playerio.generated.messages.SimpleConnectOutput;
	import playerio.generated.messages.SimpleGetCaptchaArgs;
	import playerio.generated.messages.SimpleGetCaptchaError;
	import playerio.generated.messages.SimpleGetCaptchaOutput;
	import playerio.generated.messages.SimpleRecoverPasswordArgs;
	import playerio.generated.messages.SimpleRecoverPasswordError;
	import playerio.generated.messages.SimpleRecoverPasswordOutput;
	import playerio.generated.messages.SimpleRegisterArgs;
	import playerio.generated.messages.SimpleRegisterError;
	import playerio.generated.messages.SimpleRegisterOutput;
	import playerio.generated.messages.SimpleUserGetSecureLoginInfoArgs;
	import playerio.generated.messages.SimpleUserGetSecureLoginInfoError;
	import playerio.generated.messages.SimpleUserGetSecureLoginInfoOutput;
	import playerio.generated.messages.SteamConnectArgs;
	import playerio.generated.messages.SteamConnectError;
	import playerio.generated.messages.SteamConnectOutput;
	import playerio.utils.Converter;
	import playerio.utils.HTTPChannel;
	
	public class QuickConnect extends EventDispatcher {
		protected var channel:HTTPChannel;
		
		public function QuickConnect(channel:HTTPChannel) {
			super();
			this.channel = channel;
		}
		
		public function simpleUserGetSecureLoginInfo(callback:Function = null, errorHandler:Function = null) : void {
			var input:SimpleUserGetSecureLoginInfoArgs = new SimpleUserGetSecureLoginInfoArgs();
			var output:SimpleUserGetSecureLoginInfoOutput = new SimpleUserGetSecureLoginInfoOutput();
			channel.Request(424,input,output,new SimpleUserGetSecureLoginInfoError(),function(param1:SimpleUserGetSecureLoginInfoOutput):void {
				if(callback != null) {
					callback(param1.publicKey,param1.nonce);
				}
			},function(param1:SimpleUserGetSecureLoginInfoError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _simpleConnect(gameId:String, usernameOrEmail:String, password:String, playerInsightSegments:Array, clientAPI:String, clientInfo:Object, callback:Function = null, errorHandler:Function = null) : void {
			var input:SimpleConnectArgs = new SimpleConnectArgs(gameId,usernameOrEmail,password,playerInsightSegments,clientAPI,Converter.toKeyValueArray(clientInfo));
			var output:SimpleConnectOutput = new SimpleConnectOutput();
			channel.Request(400,input,output,new SimpleConnectError(),function(param1:SimpleConnectOutput):void {
				if(callback != null) {
					callback(param1.token,param1.userId,param1.showBranding,param1.gameFSRedirectMap,param1.partnerId,param1.playerInsightState);
				}
			},function(param1:SimpleConnectError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		public function simpleGetCaptcha(gameId:String, width:int, height:int, callback:Function = null, errorHandler:Function = null) : void {
			var input:SimpleGetCaptchaArgs = new SimpleGetCaptchaArgs(gameId,width,height);
			var output:SimpleGetCaptchaOutput = new SimpleGetCaptchaOutput();
			channel.Request(415,input,output,new SimpleGetCaptchaError(),function(param1:SimpleGetCaptchaOutput):void {
				if(callback != null) {
					callback(param1.captchaKey,param1.captchaImageUrl);
				}
			},function(param1:SimpleGetCaptchaError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _simpleRegister(gameId:String, username:String, password:String, email:String, captchaKey:String, captchaValue:String, extraData:Object, partnerId:String, playerInsightSegments:Array, clientAPI:String, clientInfo:Object, callback:Function = null, errorHandler:Function = null) : void {
			var input:SimpleRegisterArgs = new SimpleRegisterArgs(gameId,username,password,email,captchaKey,captchaValue,Converter.toKeyValueArray(extraData),partnerId,playerInsightSegments,clientAPI,Converter.toKeyValueArray(clientInfo));
			var output:SimpleRegisterOutput = new SimpleRegisterOutput();
			channel.Request(403,input,output,new SimpleRegisterError(),function(param1:SimpleRegisterOutput):void {
				if(callback != null) {
					callback(param1.token,param1.userId,param1.showBranding,param1.gameFSRedirectMap,param1.partnerId,param1.playerInsightState);
				}
			},function(param1:SimpleRegisterError):void {
				var _local2:PlayerIORegistrationError = new PlayerIORegistrationError(param1.message,param1.errorCode,param1.usernameError,param1.passwordError,param1.emailError,param1.captchaError);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		public function simpleRecoverPassword(gameId:String, usernameOrEmail:String, callback:Function = null, errorHandler:Function = null) : void {
			var input:SimpleRecoverPasswordArgs = new SimpleRecoverPasswordArgs(gameId,usernameOrEmail);
			var output:SimpleRecoverPasswordOutput = new SimpleRecoverPasswordOutput();
			channel.Request(406,input,output,new SimpleRecoverPasswordError(),function(param1:SimpleRecoverPasswordOutput):void {
				if(callback != null) {
					callback();
				}
			},function(param1:SimpleRecoverPasswordError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _kongregateConnect(gameId:String, userId:String, gameAuthToken:String, playerInsightSegments:Array, clientAPI:String, clientInfo:Object, callback:Function = null, errorHandler:Function = null) : void {
			var input:KongregateConnectArgs = new KongregateConnectArgs(gameId,userId,gameAuthToken,playerInsightSegments,clientAPI,Converter.toKeyValueArray(clientInfo));
			var output:KongregateConnectOutput = new KongregateConnectOutput();
			channel.Request(412,input,output,new KongregateConnectError(),function(param1:KongregateConnectOutput):void {
				if(callback != null) {
					callback(param1.token,param1.userId,param1.showBranding,param1.gameFSRedirectMap,param1.playerInsightState);
				}
			},function(param1:KongregateConnectError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _facebookOAuthConnect(gameId:String, accessToken:String, partnerId:String, playerInsightSegments:Array, clientAPI:String, clientInfo:Object, callback:Function = null, errorHandler:Function = null) : void {
			var input:FacebookOAuthConnectArgs = new FacebookOAuthConnectArgs(gameId,accessToken,partnerId,playerInsightSegments,clientAPI,Converter.toKeyValueArray(clientInfo));
			var output:FacebookOAuthConnectOutput = new FacebookOAuthConnectOutput();
			channel.Request(418,input,output,new FacebookOAuthConnectError(),function(param1:FacebookOAuthConnectOutput):void {
				if(callback != null) {
					callback(param1.token,param1.userId,param1.showBranding,param1.gameFSRedirectMap,param1.facebookUserId,param1.partnerId,param1.playerInsightState);
				}
			},function(param1:FacebookOAuthConnectError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		public function steamConnect(gameId:String, steamAppId:String, steamSessionTicket:String, playerInsightSegments:Array, clientAPI:String, clientInfo:Object, callback:Function = null, errorHandler:Function = null) : void {
			var input:SteamConnectArgs = new SteamConnectArgs(gameId,steamAppId,steamSessionTicket,playerInsightSegments,clientAPI,Converter.toKeyValueArray(clientInfo));
			var output:SteamConnectOutput = new SteamConnectOutput();
			channel.Request(421,input,output,new SteamConnectError(),function(param1:SteamConnectOutput):void {
				if(callback != null) {
					callback(param1.token,param1.userId,param1.showBranding,param1.gameFSRedirectMap,param1.partnerId,param1.playerInsightState);
				}
			},function(param1:SteamConnectError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
	}
}

