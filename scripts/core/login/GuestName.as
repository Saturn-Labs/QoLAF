package core.login {
	import core.hud.components.Box;
	import core.hud.components.Button;
	import core.hud.components.InputText;
	import core.hud.components.Style;
	import core.hud.components.Text;
	import generics.Localize;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	
	public class GuestName extends Sprite {
		public var nameInput:InputText;
		
		private var errorText:Text;
		
		private var text:Text;
		
		private var button:Button;
		
		public function GuestName(startName:String = "Guest-") {
			super();
			var _local2:Box = new Box(250,60,"normal",1,25);
			addChild(_local2);
			text = new Text();
			text.size = 13;
			text.text = Localize.t("Enter your name") + ":";
			text.color = Style.COLOR_H2;
			_local2.addChild(text);
			var _local4:int = 999;
			var _local3:int = 100;
			nameInput = new InputText(0,33,167,23);
			nameInput.text = startName + (Math.floor(Math.random() * (_local4 - _local3 + 1)) + _local3);
			nameInput.restrict = "a-zA-Z0-9\\-_";
			nameInput.maxChars = 15;
			nameInput.addEventListener("enter",onEnter);
			_local2.addChild(nameInput);
			button = new Button(onClick," " + Localize.t("Ok") + " ","positive");
			button.x = 190;
			button.y = 31;
			_local2.addChild(button);
			errorText = new Text();
			errorText.y = 0;
			addChild(errorText);
			addEventListener("addedToStage",addedToStage);
		}
		
		private function addedToStage(e:Event) : void {
			removeEventListener("addedToStage",addedToStage);
			nameInput.setFocus();
			nameInput.selectRange(0,-1);
		}
		
		private function onEnter(e:Event = null) : void {
			if(nameInput.text.length < 3) {
				button.enabled = true;
				text.visible = false;
				errorText.text = Localize.t("Minimum of [n] characters.").replace("[n]",3);
				return;
			}
			nameInput.removeEventListener("enter",onEnter);
			var _local2:Event = new Event("nameEntered",false,nameInput.text);
			dispatchEvent(_local2);
		}
		
		private function onClick(e:TouchEvent) : void {
			onEnter();
		}
	}
}

