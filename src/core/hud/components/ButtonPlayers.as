package core.hud.components
{
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class ButtonPlayers extends ButtonHud
	{
		private var captionText:TextField;
		
		public function ButtonPlayers(param1:Function)
		{
			super(param1, "button_players.png");
			captionText = new TextField(20, 15, "1", new TextFormat("font13", 13, 11184810));
			captionText.x = 10;
			captionText.y = 5;
			captionText.touchable = false;
			captionText.batchable = true;
			addChild(captionText);
		}
		
		public function set text(param1:String):void
		{
			captionText.text = param1;
		}
	}
}
