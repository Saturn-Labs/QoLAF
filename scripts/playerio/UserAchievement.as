package playerio {
	internal class UserAchievement {
		private var _userId:String = "";
		
		private var _achievements:Array = [];
		
		public function UserAchievement(userId:String, achievements:Array) {
			super();
			_achievements = achievements;
			_userId = userId;
		}
		
		public function get userId() : String {
			return _userId;
		}
		
		public function get achievements() : Array {
			return _achievements;
		}
	}
}

