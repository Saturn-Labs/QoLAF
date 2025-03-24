package playerio {
	import flash.utils.Dictionary;
	import playerio.generated.Achievements;
	import playerio.generated.PlayerIOError;
	import playerio.generated.messages.Achievement;
	import playerio.utils.HTTPChannel;
	
	public class Achievements extends playerio.generated.Achievements {
		private var _version:String = null;
		
		private var _myAchievements:Array = null;
		
		private var _onCompletedHandler:Function = null;
		
		public function Achievements(channel:HTTPChannel, client:Client) {
			super(channel,client);
		}
		
		public function set onCompletedHandler(completedHanlder:Function) : void {
			_onCompletedHandler = completedHanlder;
		}
		
		public function get myAchievements() : Array {
			if(_myAchievements != null) {
				return _myAchievements;
			}
			throw new playerio.generated.PlayerIOError("Cannot access myAchievements before \'achievements\' has been loaded. Please refresh the achievements first",playerio.PlayerIOError.AchievementsNotLoaded.errorID);
		}
		
		public function get(achievementId:String) : playerio.Achievement {
			for each(var _local2 in _myAchievements) {
				if(_local2.id == achievementId) {
					return _local2;
				}
			}
			return null;
		}
		
		public function refresh(callback:Function = null, errorHandler:Function = null) : void {
			_achievementsRefresh(_version,function(param1:String, param2:Array):void {
				refreshAchiemeventsHelper(param1,param2);
				if(callback != null) {
					callback();
				}
			},errorHandler);
		}
		
		public function load(userIds:Array, callback:Function = null, errorHandler:Function = null) : void {
			_achievementsLoad(userIds,function(param1:Array):void {
				var _local2:Dictionary = null;
				if(callback != null) {
					_local2 = parseUserAchievements(param1);
					callback(_local2);
				}
			},errorHandler);
		}
		
		public function progressSet(achievementId:String, progress:int, callback:Function, errorHandler:Function) : void {
			_achievementsProgressSet(achievementId,progress,function(param1:playerio.generated.messages.Achievement, param2:Boolean):void {
				processResults(param1,param2,callback);
			},errorHandler);
		}
		
		public function progressAdd(achievementId:String, progressDelta:int, callback:Function, errorHandler:Function) : void {
			_achievementsProgressAdd(achievementId,progressDelta,function(param1:playerio.generated.messages.Achievement, param2:Boolean):void {
				processResults(param1,param2,callback);
			},errorHandler);
		}
		
		public function progressMax(achievementId:String, progress:int, callback:Function, errorHandler:Function) : void {
			_achievementsProgressMax(achievementId,progress,function(param1:playerio.generated.messages.Achievement, param2:Boolean):void {
				processResults(param1,param2,callback);
			},errorHandler);
		}
		
		public function progressComplete(achievementId:String, callback:Function, errorHandler:Function) : void {
			_achievementsProgressComplete(achievementId,function(param1:playerio.generated.messages.Achievement, param2:Boolean):void {
				processResults(param1,param2,callback);
			},errorHandler);
		}
		
		private function refreshAchiemeventsHelper(version:String, achievements:Array) : void {
			_version = version;
			_myAchievements = parseAchievements(achievements);
		}
		
		private function parseUserAchievements(userAchievements:Array) : Dictionary {
			var _local3:int = 0;
			var _local2:Dictionary = new Dictionary();
			_local3 = 0;
			while(_local3 < userAchievements.length) {
				_local2[userAchievements[_local3].userId] = new UserAchievement(userAchievements[_local3].userId,parseAchievements(userAchievements[_local3].achievements)).achievements;
				_local3++;
			}
			return _local2;
		}
		
		private function parseAchievements(achievements:Array) : Array {
			var _local4:int = 0;
			var _local2:playerio.Achievement = null;
			var _local3:Array = [];
			_local4 = 0;
			while(_local4 < achievements.length) {
				_local2 = new playerio.Achievement();
				_local2._internal_initialize(achievements[_local4] as playerio.generated.messages.Achievement);
				_local3.push(_local2);
				_local4++;
			}
			return _local3;
		}
		
		private function processResults(achievement:playerio.generated.messages.Achievement, completedNow:Boolean, callback:Function) : void {
			var _local5:int = 0;
			var _local4:playerio.Achievement = null;
			if(_myAchievements != null) {
				_local5 = 0;
				while(_local5 < _myAchievements.length) {
					if(_myAchievements[_local5].id == achievement.identifier) {
						_local4 = _myAchievements[_local5];
						_local4._internal_initialize(achievement);
						break;
					}
					_local5++;
				}
				if(_local4 == null) {
					_local4 = new playerio.Achievement();
					_local4._internal_initialize(achievement);
					_myAchievements.push(_local4);
				}
			} else {
				_local4 = new playerio.Achievement();
				_local4._internal_initialize(achievement);
			}
			if(completedNow && _onCompletedHandler != null) {
				_onCompletedHandler(_local4);
			}
			if(callback != null) {
				callback(_local4);
			}
		}
	}
}

