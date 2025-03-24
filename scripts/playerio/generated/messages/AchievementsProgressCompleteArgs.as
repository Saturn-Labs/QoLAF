package playerio.generated.messages {
	import com.protobuf.Message;
	
	public final class AchievementsProgressCompleteArgs extends Message {
		public var achievementId:String;
		
		public function AchievementsProgressCompleteArgs(achievementId:String) {
			super();
			registerField("achievementId","",9,1,1);
			this.achievementId = achievementId;
		}
	}
}

