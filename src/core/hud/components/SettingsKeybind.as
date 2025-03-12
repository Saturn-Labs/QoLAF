package core.hud.components
{
	import data.KeyBinds;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.TouchEvent;
	
	public class SettingsKeybind extends Sprite
	{
		private var type:int;
		
		private var bg:Box;
		
		private var description:Text;
		
		private var buttonOne:Button;
		
		private var buttonTwo:Button;
		
		private var keybinds:KeyBinds;
		
		private var currentButton:Button;
		
		private var currentNumber:int;
		
		public function SettingsKeybind(param1:KeyBinds, param2:int, param3:int, param4:int)
		{
			super();
			this.keybinds = param1;
			this.type = param2;
			this.x = param3;
			this.y = param4;
			load();
		}
		
		public function update():void
		{
			buttonOne.text = keybinds.getKeyName(type, 1);
			buttonTwo.text = keybinds.getKeyName(type, 2);
		}
		
		private function load():void
		{
			bg = new Box(610, 24, "highlight", 0.5, 10);
			description = new Text();
			description.text = keybinds.getName(type);
			description.x = 20;
			description.y = 5;
			buttonOne = new Button(listenButton, keybinds.getKeyName(type, 1), "positive");
			buttonOne.width = 160;
			buttonOne.x = 240;
			buttonOne.y = 0;
			buttonTwo = new Button(listenButton, keybinds.getKeyName(type, 2), "positive");
			buttonTwo.width = 160;
			buttonTwo.x = 420;
			buttonTwo.y = 0;
			bg.addChild(description);
			bg.addChild(buttonOne);
			bg.addChild(buttonTwo);
			addChild(bg);
		}
		
		private function listenButton(param1:TouchEvent):void
		{
			if (param1.interactsWith(buttonOne))
			{
				currentNumber = 1;
				currentButton = buttonOne;
			}
			else
			{
				currentNumber = 2;
				currentButton = buttonTwo;
			}
			if (currentButton.text != "Push a Button")
			{
				currentButton.text = "Push a Button";
				stage.addEventListener("keyDown", onClickButton);
				stage.addEventListener("touch", onMouseTouch);
				stage.addEventListener("rightClick", rightClick);
			}
			else
			{
				currentButton.text = "Mouse1";
				keybinds.setBindKey(-2, type, currentNumber);
				stage.removeEventListener("keyDown", onClickButton);
				stage.removeEventListener("touch", onMouseTouch);
				stage.removeEventListener("rightClick", rightClick);
				dispatchEventWith("updateButtons", true);
			}
			currentButton.touchable = true;
			currentButton.enabled = true;
		}
		
		private function onMouseTouch(param1:TouchEvent):void
		{
			param1.stopImmediatePropagation();
			if (param1.getTouch(stage, "began") && !param1.interactsWith(currentButton))
			{
				stage.removeEventListener("keyDown", onClickButton);
				stage.removeEventListener("touch", onMouseTouch);
				stage.removeEventListener("rightClick", rightClick);
				param1.stopImmediatePropagation();
				currentButton.text = keybinds.getKeyName(type, currentNumber);
				currentButton.touchable = true;
				currentButton.enabled = true;
			}
		}
		
		private function rightClick(param1:Event):void
		{
			currentButton.text = "Mouse2";
			keybinds.setBindKey(-3, type, currentNumber);
			stage.removeEventListener("keyDown", onClickButton);
			stage.removeEventListener("touch", onMouseTouch);
			stage.removeEventListener("rightClick", rightClick);
			dispatchEventWith("updateButtons", true);
			currentButton.touchable = true;
			currentButton.enabled = true;
		}
		
		private function onClickButton(param1:KeyboardEvent):void
		{
			stage.removeEventListener("keyDown", onClickButton);
			stage.removeEventListener("touch", onMouseTouch);
			stage.removeEventListener("rightClick", rightClick);
			param1.stopImmediatePropagation();
			if (param1.keyCode == 13 || param1.keyCode == 27)
			{
				currentButton.text = keybinds.getKeyName(type, currentNumber);
			}
			else
			{
				keybinds.setBindKey(param1.keyCode, type, currentNumber);
				currentButton.text = keybinds.getKeyName(type, currentNumber);
				dispatchEventWith("updateButtons", true);
			}
			currentButton.touchable = true;
			currentButton.enabled = true;
		}
	}
}
