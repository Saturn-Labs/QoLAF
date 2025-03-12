package core.login
{
	import core.hud.components.Box;
	import core.hud.components.Button;
	import core.hud.components.InputText;
	import core.hud.components.Style;
	import core.hud.components.Text;
	import generics.Localize;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	
	public class GuestName extends Sprite
	{
		public var nameInput:InputText;
		
		private var errorText:Text;
		
		private var text:Text;
		
		private var button:Button;
		
		public function GuestName(param1:String = "Guest-")
		{
			super();
			var _loc4_:Box = new Box(250, 60, "normal", 1, 25);
			addChild(_loc4_);
			text = new Text();
			text.size = 13;
			text.text = Localize.t("Enter your name") + ":";
			text.color = Style.COLOR_H2;
			_loc4_.addChild(text);
			var _loc3_:int = 999;
			var _loc2_:int = 100;
			nameInput = new InputText(0, 33, 167, 23);
			nameInput.text = param1 + (Math.floor(Math.random() * (_loc3_ - _loc2_ + 1)) + _loc2_);
			nameInput.restrict = "a-zA-Z0-9\\-_";
			nameInput.maxChars = 15;
			nameInput.addEventListener("enter", onEnter);
			_loc4_.addChild(nameInput);
			button = new Button(onClick, " " + Localize.t("Ok") + " ", "positive");
			button.x = 190;
			button.y = 31;
			_loc4_.addChild(button);
			errorText = new Text();
			errorText.y = 0;
			addChild(errorText);
			addEventListener("addedToStage", addedToStage);
		}
		
		private function addedToStage(param1:Event):void
		{
			removeEventListener("addedToStage", addedToStage);
			nameInput.setFocus();
			nameInput.selectRange(0, -1);
		}
		
		private function onEnter(param1:Event = null):void
		{
			if (nameInput.text.length < 3)
			{
				button.enabled = true;
				text.visible = false;
				errorText.text = Localize.t("Minimum of [n] characters.").replace("[n]", 3);
				return;
			}
			nameInput.removeEventListener("enter", onEnter);
			var _loc2_:Event = new Event("nameEntered", false, nameInput.text);
			dispatchEvent(_loc2_);
		}
		
		private function onClick(param1:TouchEvent):void
		{
			onEnter();
		}
	}
}
