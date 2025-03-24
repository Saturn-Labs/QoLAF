package playerio {
	import playerio.generated.PlayerIOError;
	import playerio.generated.messages.SocialProfile;
	import playerio.utils.Utilities;
	
	internal class PublishingNetworkRelations {
		private var _client:Client;
		
		private var _friends:Array;
		
		private var _friendLookup:Object;
		
		private var _blockedLookup:Object;
		
		private var _publishingnetwork:PublishingNetwork;
		
		public function PublishingNetworkRelations(client:Client, publishingnetwork:PublishingNetwork) {
			super();
			this._client = client;
			this._publishingnetwork = publishingnetwork;
		}
		
		internal function _internal_refreshed(myProfile:SocialProfile, friends:Array, blocked:Array) : void {
			var friend:PublishingNetworkProfile;
			var ignored:String;
			this._friends = Utilities.converter(friends,function(param1:SocialProfile):PublishingNetworkProfile {
				var _local2:PublishingNetworkProfile = new PublishingNetworkProfile();
				_local2._internal_initialize(param1);
				return _local2;
			});
			_friendLookup = {};
			for each(friend in this._friends) {
				_friendLookup[friend.userId] = true;
			}
			_blockedLookup = {};
			if(blocked != null) {
				for each(ignored in blocked) {
					_blockedLookup[ignored] = true;
				}
			}
		}
		
		public function get friends() : Array {
			if(_friends == null) {
				throw new playerio.generated.PlayerIOError("Cannot access friends before Publishing Network has loaded. Please call client.publishingnetwork.refresh() first.",playerio.PlayerIOError.PublishingNetworkNotLoaded.errorID);
			}
			return _friends;
		}
		
		public function isFriend(userId:String) : Boolean {
			if(_friendLookup == null) {
				throw new playerio.generated.PlayerIOError("Cannot access friends before Publishing Network has loaded. Please call client.publishingnetwork.refresh() first.",playerio.PlayerIOError.PublishingNetworkNotLoaded.errorID);
			}
			return _friendLookup[userId] != undefined;
		}
		
		public function isBlocked(userId:String) : Boolean {
			if(_blockedLookup == null) {
				throw new playerio.generated.PlayerIOError("Cannot access friends before Publishing Network has loaded. Please call client.publishingnetwork.refresh() first.",playerio.PlayerIOError.PublishingNetworkNotLoaded.errorID);
			}
			return _blockedLookup[userId] != undefined;
		}
		
		public function showRequestFriendshipDialog(userId:String, closedCallback:Function) : void {
			PublishingNetwork._internal_showDialog("requestfriendship",{"userId":userId},_client.channel,function():void {
				if(closedCallback != null) {
					closedCallback();
				}
			});
		}
		
		public function showRequestBlockUserDialog(userId:String, closedCallback:Function) : void {
			PublishingNetwork._internal_showDialog("requestblockuser",{"userId":userId},_client.channel,function():void {
				_publishingnetwork.refresh(function():void {
					if(closedCallback != null) {
						closedCallback();
					}
				},function():void {
					if(closedCallback != null) {
						closedCallback();
					}
				});
			});
		}
		
		public function showFriendsManager(closedCallback:Function) : void {
			PublishingNetwork._internal_showDialog("friendsmanager",{},_client.channel,function(param1:Object):void {
				var result:Object = param1;
				if(result["updated"] != undefined) {
					_publishingnetwork.refresh(function():void {
						if(closedCallback != null) {
							closedCallback();
						}
					},function():void {
						if(closedCallback != null) {
							closedCallback();
						}
					});
				} else if(closedCallback != null) {
					closedCallback();
				}
			});
		}
		
		public function showBlockedUsersManager(closedCallback:Function) : void {
			PublishingNetwork._internal_showDialog("blockedusersmanager",{},_client.channel,function(param1:Object):void {
				var result:Object = param1;
				if(result["updated"] != undefined) {
					_publishingnetwork.refresh(function():void {
						if(closedCallback != null) {
							closedCallback();
						}
					},function():void {
						if(closedCallback != null) {
							closedCallback();
						}
					});
				} else if(closedCallback != null) {
					closedCallback();
				}
			});
		}
	}
}

