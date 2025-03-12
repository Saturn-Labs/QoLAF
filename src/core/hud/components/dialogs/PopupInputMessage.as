package core.hud.components.dialogs
{
	import core.hud.components.InputText;
	import starling.events.Event;
	
	public class PopupInputMessage extends PopupConfirmMessage
	{
		public var input:InputText;
		
		public function PopupInputMessage(param1:String = "Confirm", param2:String = "Cancel")
		{
			input = new InputText(0, 0, 200, 20);
			super(param1, param2);
			box.addChild(input);
		}
		
		public function get text():String
		{
			return input.text;
		}
		
		override protected function redraw(param1:Event = null):void
		{
			super.redraw();
			confirmButton.y = closeButton.y = input.y + input.height + 10;
		}
	}
}
