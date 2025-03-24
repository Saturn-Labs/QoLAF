package core.hud.components {
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class LoginButton extends Sprite {
		private var displayText:TextField;
		
		private var callback:Function;
		
		private var _enabled:Boolean = true;
		
		public function LoginButton(text:String, callback:Function, textColor:uint = 16777215, bgColor:int = 0) {
			super();
			this.callback = callback;
			var _local7:TextFormat = new TextFormat("DAIDRR",12,textColor);
			var _local6:int = 2 * 60;
			var _local5:Quad = new Quad(_local6,41,bgColor);
			_local5.alpha = 0.7;
			addChild(_local5);
			displayText = new TextField(_local6,30,text,_local7);
			displayText.y = 6;
			addChild(displayText);
			this.text = text;
			useHandCursor = true;
			addEventListener("touch",onTouch);
		}
		
		private function onTouch(e:TouchEvent) : void {
			if(e.getTouch(this,"ended")) {
				callback();
			}
		}
		
		public function get text() : String {
			return displayText.text;
		}
		
		public function set text(value:String) : void {
			displayText.text = value.toUpperCase();
		}
		
		public function set enabled(v:Boolean) : void {
			_enabled = v;
		}
		
		public function get enabled() : Boolean {
			return _enabled;
		}
	}
}

