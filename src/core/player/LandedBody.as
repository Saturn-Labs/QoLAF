package core.player
{
	
	public class LandedBody
	{
		public var key:String;
		
		public var cleared:Boolean;
		
		public function LandedBody(param1:String, param2:Boolean = false)
		{
			super();
			this.key = param1;
			this.cleared = param2;
		}
	}
}
