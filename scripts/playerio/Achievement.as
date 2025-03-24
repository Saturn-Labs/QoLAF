package playerio {
	import playerio.generated.messages.Achievement;
	
	public class Achievement {
		private var _id:String;
		
		private var _title:String;
		
		private var _description:String;
		
		private var _imageUrl:String;
		
		private var _progress:int;
		
		private var _progressGoal:int;
		
		private var _lastUpdated:Date;
		
		public function Achievement() {
			super();
		}
		
		public function get id() : String {
			return this._id;
		}
		
		public function get title() : String {
			return _title;
		}
		
		public function get description() : String {
			return _description;
		}
		
		public function get imageUrl() : String {
			return _imageUrl;
		}
		
		public function get progress() : int {
			return _progress;
		}
		
		public function get progressGoal() : int {
			return _progressGoal;
		}
		
		public function get lastUpdated() : Date {
			return _lastUpdated;
		}
		
		public function get progressRatio() : Number {
			return _progress / _progressGoal;
		}
		
		public function get completed() : Boolean {
			return _progress == _progressGoal;
		}
		
		internal function _internal_initialize(achievement:playerio.generated.messages.Achievement) : void {
			this._id = achievement.identifier;
			this._title = achievement.title;
			this._description = achievement.description;
			this._imageUrl = achievement.imageUrl;
			this._progress = achievement.progress;
			this._progressGoal = achievement.progressGoal;
			this._lastUpdated = new Date(achievement.lastUpdated * 1000);
		}
	}
}

