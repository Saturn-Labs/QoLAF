package core.hud.components {
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class ButtonPlayers extends ButtonHud {
		private var captionText:TextField;
		
		public function ButtonPlayers(clickCallback:Function) {
			super(clickCallback,"button_players.png");
			captionText = new TextField(20,15,"1",new TextFormat("font13",13,0xaaaaaa));
			captionText.x = 10;
			captionText.y = 5;
			captionText.touchable = false;
			captionText.batchable = true;
			addChild(captionText);
		}
		
		public function set text(value:String) : void {
			captionText.text = value;
		}
	}
}

