package playerio.generated.messages {
	import com.protobuf.Message;
	
	public final class AchievementsRefreshArgs extends Message {
		public var lastVersion:String;
		
		public function AchievementsRefreshArgs(lastVersion:String) {
			super();
			registerField("lastVersion","",9,1,1);
			this.lastVersion = lastVersion;
		}
	}
}

