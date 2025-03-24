package playerio.generated.messages {
	import com.protobuf.Message;
	
	public final class PlayerInsightTrackInvitedByArgs extends Message {
		public var invitingUserId:String;
		
		public var invitationChannel:String;
		
		public function PlayerInsightTrackInvitedByArgs(invitingUserId:String, invitationChannel:String) {
			super();
			registerField("invitingUserId","",9,1,1);
			registerField("invitationChannel","",9,1,2);
			this.invitingUserId = invitingUserId;
			this.invitationChannel = invitationChannel;
		}
	}
}

