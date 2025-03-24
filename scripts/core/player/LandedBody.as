package core.player {
	public class LandedBody {
		public var key:String;
		
		public var cleared:Boolean;
		
		public function LandedBody(key:String, cleared:Boolean = false) {
			super();
			this.key = key;
			this.cleared = cleared;
		}
	}
}

