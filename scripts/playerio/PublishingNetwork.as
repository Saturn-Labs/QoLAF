package playerio {
	import flash.events.EventDispatcher;
	import playerio.generated.messages.SocialProfile;
	import playerio.utils.HTTPChannel;
	
	public class PublishingNetwork extends EventDispatcher {
		private var _client:Client;
		
		private var _profiles:PublishingNetworkProfiles;
		
		private var _payments:PublishingNetworkPayments;
		
		private var _relations:PublishingNetworkRelations;
		
		private var _userToken:String;
		
		public function PublishingNetwork(client:Client) {
			super();
			this._client = client;
			_profiles = new PublishingNetworkProfiles(client);
			_relations = new PublishingNetworkRelations(client,this);
			_payments = new PublishingNetworkPayments(client);
			_userToken = null;
		}
		
		internal static function _internal_showDialog(dialog:String, arguments:Object, channel:HTTPChannel, callback:Function) : void {
			PublishingNetworkDialog.showDialog(dialog,arguments,channel,callback);
		}
		
		public function get profiles() : PublishingNetworkProfiles {
			return _profiles;
		}
		
		public function get payments() : PublishingNetworkPayments {
			return _payments;
		}
		
		public function get relations() : PublishingNetworkRelations {
			return _relations;
		}
		
		public function get userToken() : String {
			return _userToken;
		}
		
		public function refresh(callback:Function, errorCallback:Function) : void {
			_client._internal_social.refresh(function(param1:SocialProfile, param2:Array, param3:Array):void {
				var _local4:PublishingNetworkProfile = new PublishingNetworkProfile();
				_local4._internal_initialize(param1);
				_profiles._internal_refreshed(_local4);
				_relations._internal_refreshed(param1,param2,param3);
				_userToken = param1.userToken;
				if(callback != null) {
					callback();
				}
			},errorCallback);
		}
	}
}

