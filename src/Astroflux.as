package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.Font;
	
	public class Astroflux extends Sprite
	{
		public function Astroflux(info:Object = null)
		{
			super();
			Font.registerFont(VerdanaFont);
			Font.registerFont(RussoOneFont);
			addChild(new RymdenRunt(info));
		}
	}
}
