package playerio {
	import playerio.generated.messages.SocialProfile;
	
	public class PublishingNetworkProfile {
		private var _userId:String;
		
		private var _displayName:String;
		
		private var _avatarUrl:String;
		
		private var _lastOnline:Date;
		
		private var _countryCode:String;
		
		public function PublishingNetworkProfile() {
			super();
		}
		
		internal function _internal_initialize(profile:SocialProfile) : void {
			this._userId = profile.userId;
			this._avatarUrl = profile.avatarUrl;
			this._countryCode = profile.countryCode;
			this._displayName = profile.displayName;
			this._lastOnline = new Date(profile.lastOnline * 1000);
		}
		
		public function get userId() : String {
			return _userId;
		}
		
		public function get displayName() : String {
			return _displayName;
		}
		
		public function get avatarUrl() : String {
			return _avatarUrl;
		}
		
		public function get lastOnline() : Date {
			return _lastOnline;
		}
		
		public function get countryCode() : String {
			return _countryCode;
		}
	}
}

