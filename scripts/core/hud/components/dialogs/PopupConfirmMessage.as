package core.hud.components.dialogs {
	import core.hud.components.Button;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.TouchEvent;
	
	public class PopupConfirmMessage extends PopupMessage {
		public var confirmButton:Button;
		
		public function PopupConfirmMessage(confirmText:String = "Confirm", cancelText:String = "Cancel", style:String = "positive") {
			super(cancelText);
			confirmButton = new Button(confirm,confirmText,style);
			box.addChild(confirmButton);
		}
		
		override protected function keyDown(e:KeyboardEvent) : void {
			if(e.keyCode == 13) {
				e.stopImmediatePropagation();
				confirm();
			}
		}
		
		protected function confirm(e:TouchEvent = null) : void {
			dispatchEventWith("accept");
			removeEventListeners();
		}
		
		override protected function redraw(e:Event = null) : void {
			super.redraw();
			confirmButton.y = Math.round(textField.height + 15);
			confirmButton.x = 0;
			closeButton.y = Math.round(textField.height + 15);
			closeButton.x = confirmButton.x + confirmButton.width + 10;
			var _local2:int = confirmButton.y + confirmButton.height + 20;
			box.width = textField.width > closeButton.x + closeButton.width ? textField.width : closeButton.x + closeButton.width;
			box.height = _local2;
		}
	}
}

