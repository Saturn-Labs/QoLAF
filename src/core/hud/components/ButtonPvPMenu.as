package core.hud.components
{
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class ButtonPvPMenu extends ButtonHud
	{
		private var captionText:TextField;
		
		public function ButtonPvPMenu(param1:Function, param2:String)
		{
			super(param1, "button_pvpmatch.png");
			captionText = new TextField(20, 15, "", new TextFormat("font13", 13, 11184810));
			captionText.x = 10;
			captionText.y = 5;
			captionText.batchable = true;
			addChild(captionText);
		}
		
		public function set text(param1:String):void
		{
			captionText.text = param1;
		}
	}
}
