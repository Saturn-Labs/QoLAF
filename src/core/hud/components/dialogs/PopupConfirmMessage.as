package core.hud.components.dialogs
{
	import core.hud.components.Button;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.TouchEvent;
	
	public class PopupConfirmMessage extends PopupMessage
	{
		public var confirmButton:Button;
		
		public function PopupConfirmMessage(param1:String = "Confirm", param2:String = "Cancel", param3:String = "positive")
		{
			super(param2);
			confirmButton = new Button(confirm, param1, param3);
			box.addChild(confirmButton);
		}
		
		override protected function keyDown(param1:KeyboardEvent):void
		{
			if (param1.keyCode == 13)
			{
				param1.stopImmediatePropagation();
				confirm();
			}
		}
		
		protected function confirm(param1:TouchEvent = null):void
		{
			dispatchEventWith("accept");
			removeEventListeners();
		}
		
		override protected function redraw(param1:Event = null):void
		{
			super.redraw();
			confirmButton.y = Math.round(textField.height + 15);
			confirmButton.x = 0;
			closeButton.y = Math.round(textField.height + 15);
			closeButton.x = confirmButton.x + confirmButton.width + 10;
			var _loc2_:int = confirmButton.y + confirmButton.height + 20;
			box.width = textField.width > closeButton.x + closeButton.width ? textField.width : closeButton.x + closeButton.width;
			box.height = _loc2_;
		}
	}
}
