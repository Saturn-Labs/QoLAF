package core.drops
{
	
	public class DropBase
	{
		public var items:Vector.<DropItem>;
		
		public var crate:Boolean;
		
		public var flux:int;
		
		public var xp:int;
		
		public var reputation:int;
		
		public var containsArtifact:Boolean;
		
		public var artifactAmount:int;
		
		public var artifactLevel:int;
		
		public function DropBase()
		{
			items = new Vector.<DropItem>();
			super();
		}
	}
}
