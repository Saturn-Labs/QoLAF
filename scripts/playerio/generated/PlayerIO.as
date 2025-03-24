package playerio.generated {
	import flash.display.MovieClip;
	import playerio.generated.messages.AuthenticateArgs;
	import playerio.generated.messages.AuthenticateError;
	import playerio.generated.messages.AuthenticateOutput;
	import playerio.generated.messages.ConnectArgs;
	import playerio.generated.messages.ConnectError;
	import playerio.generated.messages.ConnectOutput;
	import playerio.utils.Converter;
	import playerio.utils.HTTPChannel;
	
	public class PlayerIO extends MovieClip {
		public function PlayerIO() {
			super();
		}
		
		protected function _connect(channel:HTTPChannel, gameId:String, connectionId:String, userId:String, auth:String, partnerId:String, playerInsightSegments:Array, clientAPI:String, clientInfo:Object, callback:Function = null, errorHandler:Function = null) : void {
			var input:ConnectArgs = new ConnectArgs(gameId,connectionId,userId,auth,partnerId,playerInsightSegments,clientAPI,Converter.toKeyValueArray(clientInfo));
			var output:ConnectOutput = new ConnectOutput();
			channel.Request(10,input,output,new ConnectError(),function(param1:ConnectOutput):void {
				if(callback != null) {
					callback(param1.token,param1.userId,param1.showBranding,param1.gameFSRedirectMap,param1.partnerId,param1.playerInsightState);
				}
			},function(param1:ConnectError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _authenticate(channel:HTTPChannel, gameId:String, connectionId:String, authenticationArguments:Object, playerInsightSegments:Array, clientAPI:String, clientInfo:Object, playCodes:Array, callback:Function = null, errorHandler:Function = null) : void {
			var input:AuthenticateArgs = new AuthenticateArgs(gameId,connectionId,Converter.toKeyValueArray(authenticationArguments),playerInsightSegments,clientAPI,Converter.toKeyValueArray(clientInfo),playCodes);
			var output:AuthenticateOutput = new AuthenticateOutput();
			channel.Request(13,input,output,new AuthenticateError(),function(param1:AuthenticateOutput):void {
				if(callback != null) {
					callback(param1.token,param1.userId,param1.showBranding,param1.gameFSRedirectMap,param1.playerInsightState,param1.startDialogs,param1.isSocialNetworkUser,param1.newPlayCodes,param1.notificationClickPayload,param1.isInstalledByPublishingNetwork,param1.deprecated1,param1.apiSecurity,param1.apiServerHosts);
				}
			},function(param1:AuthenticateError):void {
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

