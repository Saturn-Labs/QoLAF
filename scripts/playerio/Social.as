package playerio {
	import playerio.generated.Social;
	import playerio.generated.messages.SocialProfile;
	import playerio.utils.HTTPChannel;
	import playerio.utils.Utilities;
	
	internal class Social extends playerio.generated.Social {
		public function Social(channel:HTTPChannel, client:Client) {
			super(channel,client);
		}
		
		public function refresh(callback:Function, errorCallback:Function) : void {
			_socialRefresh(function(param1:SocialProfile, param2:Array, param3:Array):void {
				if(callback != null) {
					callback(param1,param2,param3);
				}
			},errorCallback);
		}
		
		public function loadProfile(userIds:Array, callback:Function, errorCallback:Function) : void {
			if(callback != null) {
				_socialLoadProfiles(userIds,function(param1:Array):void {
					var found:SocialProfile;
					var yp:PublishingNetworkProfile;
					var profiles:Array = param1;
					var resultProfile:Array = [];
					var i:int = 0;
					while(i < userIds.length) {
						found = (profiles != null ? Utilities.find(profiles,function(param1:SocialProfile):Boolean {
							return param1.userId == userIds[i];
						}) : null) as SocialProfile;
						if(found != null) {
							yp = new PublishingNetworkProfile();
							yp._internal_initialize(found);
							resultProfile.push(yp);
						} else {
							resultProfile.push(null);
						}
						i++;
					}
					callback(resultProfile);
				},errorCallback);
			} else {
				callback([]);
			}
		}
	}
}

