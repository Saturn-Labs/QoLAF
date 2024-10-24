package
{
	import embeds.RussoOneFont;
	import embeds.VerdanaFont;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.Font;
	
	public class Astroflux extends Sprite
	{
		public static const VERSION_NAME:String = "QoLAF - PROTOTYPE";
		public static const VERSION_NUMBER:String = "v0.1.0";
		
		public function Astroflux(info:Object = null)
		{
			super();
			Font.registerFont(VerdanaFont);
			Font.registerFont(RussoOneFont);
			addChild(new RymdenRunt(info));
		}
	}
}
