package embeds.qolaf
{
	import flash.utils.ByteArray;

	[Embed(source="/texts/qolaf/modifiers.json", mimeType="application/octet-stream")]
	public class ModifiersJson extends ByteArray
	{
		public function ModifiersJson()
		{
			super();
		}
	}
}
