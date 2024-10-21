package
{
	import flash.utils.ByteArray;
	
	[Embed(source = "../texts/lang.json", mimeType = "application/octet-stream")]
	public class LangJson extends ByteArray
	{
		public function LangJson()
		{
			super();
		}
	}
}