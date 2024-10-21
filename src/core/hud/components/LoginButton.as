package core.hud.components
{
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class LoginButton extends Sprite
	{
		private var displayText:TextField;
		
		private var callback:Function;
		
		private var _enabled:Boolean = true;
		
		public function LoginButton(param1:String, param2:Function, param3:uint = 16777215, param4:int = 0)
		{
			super();
			this.callback = param2;
			var _loc6_:TextFormat = new TextFormat("DAIDRR", 12, param3);
			var _loc5_:int = 120;
			var _loc7_:Quad = new Quad(_loc5_, 41, param4);
			_loc7_.alpha = 0.7;
			addChild(_loc7_);
			displayText = new TextField(_loc5_, 30, param1, _loc6_);
			displayText.y = 6;
			addChild(displayText);
			this.text = param1;
			useHandCursor = true;
			addEventListener("touch", onTouch);
		}
		
		private function onTouch(param1:TouchEvent):void
		{
			if (param1.getTouch(this, "ended"))
			{
				callback();
			}
		}
		
		public function get text():String
		{
			return displayText.text;
		}
		
		public function set text(param1:String):void
		{
			displayText.text = param1.toUpperCase();
		}
		
		public function set enabled(param1:Boolean):void
		{
			_enabled = param1;
		}
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
	}
}
