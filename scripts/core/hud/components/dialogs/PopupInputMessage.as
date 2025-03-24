package core.hud.components.dialogs {
	import core.hud.components.InputText;
	import starling.events.Event;
	
	public class PopupInputMessage extends PopupConfirmMessage {
		public var input:InputText = new InputText(0,0,200,20);
		
		public function PopupInputMessage(confirmText:String = "Confirm", cancelText:String = "Cancel") {
			super(confirmText,cancelText);
			box.addChild(input);
		}
		
		public function get text() : String {
			return input.text;
		}
		
		override protected function redraw(e:Event = null) : void {
			super.redraw();
			confirmButton.y = closeButton.y = input.y + input.height + 10;
		}
	}
}

