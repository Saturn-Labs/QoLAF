package embeds.qolaf
{
	import flash.utils.ByteArray;
	
	[Embed(source = "/texts/qolaf/debuff/debuffs.json", mimeType = "application/octet-stream")]
	public class DebuffsJson extends ByteArray
	{
		public function DebuffsJson()
		{
			super();
		}
	}
}
