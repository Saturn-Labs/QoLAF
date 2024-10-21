package
{
	import flash.utils.ByteArray;
	
	[Embed(source = "../texts/cache.json", mimeType = "application/octet-stream")]
	public class CacheJson extends ByteArray
	{
		public function CacheJson()
		{
			super();
		}
	}
}
