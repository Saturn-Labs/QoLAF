package core.hud.components {
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class ButtonPvPMenu extends ButtonHud {
		private var captionText:TextField;
		
		public function ButtonPvPMenu(clickCallback:Function, text:String) {
			super(clickCallback,"button_pvpmatch.png");
			captionText = new TextField(20,15,"",new TextFormat("font13",13,0xaaaaaa));
			captionText.x = 10;
			captionText.y = 5;
			captionText.batchable = true;
			addChild(captionText);
		}
		
		public function set text(value:String) : void {
			captionText.text = value;
		}
	}
}

