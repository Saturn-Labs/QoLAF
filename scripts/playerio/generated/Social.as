package playerio.generated {
	import flash.events.EventDispatcher;
	import playerio.Client;
	import playerio.generated.messages.SocialLoadProfilesArgs;
	import playerio.generated.messages.SocialLoadProfilesError;
	import playerio.generated.messages.SocialLoadProfilesOutput;
	import playerio.generated.messages.SocialRefreshArgs;
	import playerio.generated.messages.SocialRefreshError;
	import playerio.generated.messages.SocialRefreshOutput;
	import playerio.utils.HTTPChannel;
	
	public class Social extends EventDispatcher {
		protected var channel:HTTPChannel;
		
		protected var client:Client;
		
		public function Social(channel:HTTPChannel, client:Client) {
			super();
			this.channel = channel;
			this.client = client;
		}
		
		protected function _socialRefresh(callback:Function = null, errorHandler:Function = null) : void {
			var input:SocialRefreshArgs = new SocialRefreshArgs();
			var output:SocialRefreshOutput = new SocialRefreshOutput();
			channel.Request(601,input,output,new SocialRefreshError(),function(param1:SocialRefreshOutput):void {
				if(callback != null) {
					try {
						callback(param1.myProfile,param1.friends,param1.blocked);
					}
					catch(e:Error) {
						client.handleCallbackError("Social.socialRefresh",e);
						throw e;
					}
				}
			},function(param1:SocialRefreshError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _socialLoadProfiles(userIds:Array, callback:Function = null, errorHandler:Function = null) : void {
			var input:SocialLoadProfilesArgs = new SocialLoadProfilesArgs(userIds);
			var output:SocialLoadProfilesOutput = new SocialLoadProfilesOutput();
			channel.Request(604,input,output,new SocialLoadProfilesError(),function(param1:SocialLoadProfilesOutput):void {
				if(callback != null) {
					try {
						callback(param1.profiles);
					}
					catch(e:Error) {
						client.handleCallbackError("Social.socialLoadProfiles",e);
						throw e;
					}
				}
			},function(param1:SocialLoadProfilesError):void {
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

