package playerio {
	import playerio.generated.PlayerIOError;
	
	internal class PublishingNetworkProfiles {
		private var _client:Client;
		
		private var _myProfile:PublishingNetworkProfile;
		
		public function PublishingNetworkProfiles(client:Client) {
			super();
			_client = client;
		}
		
		public function get myProfile() : PublishingNetworkProfile {
			if(_myProfile == null) {
				throw new playerio.generated.PlayerIOError("Cannot access profile before Publishing Network has loaded. Please call client.publishingnetwork.Refresh() first",playerio.PlayerIOError.PublishingNetworkNotLoaded.errorID);
			}
			return _myProfile;
		}
		
		internal function _internal_refreshed(p:PublishingNetworkProfile) : void {
			this._myProfile = p;
		}
		
		public function showProfile(userId:String, callback:Function) : void {
			PublishingNetwork._internal_showDialog("profile",{"userId":userId},_client.channel,callback);
		}
		
		public function loadProfiles(userIds:Array, callback:Function, errorCallback:Function) : void {
			_client._internal_social.loadProfile(userIds,callback,errorCallback);
		}
	}
}

