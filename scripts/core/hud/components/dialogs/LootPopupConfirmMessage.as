package core.hud.components.dialogs {
	import core.hud.components.LootItem;
	import starling.events.Event;
	
	public class LootPopupConfirmMessage extends PopupConfirmMessage {
		private var items:Vector.<LootItem> = new Vector.<LootItem>();
		
		public function LootPopupConfirmMessage(confirmText:String = "Confirm", cancelText:String = "Cancel") {
			super(confirmText,cancelText);
		}
		
		public function addItem(item:LootItem) : void {
			item.y = textField.height + 40 * items.length;
			box.addChild(item);
			items.push(item);
			if(stage != null) {
				redraw();
			}
		}
		
		override protected function redraw(e:Event = null) : void {
			super.redraw();
			var _local2:Number = textField.height + items.length * 40 + 45;
			box.width = 320;
			box.height = _local2;
			closeButton.y = _local2 - 25;
			confirmButton.y = _local2 - 25;
			box.x = Math.round(stage.stageWidth / 2 - box.width / 2);
			box.y = Math.round(stage.stageHeight / 2 - box.height / 2);
			bgr.width = stage.stageWidth;
			bgr.height = stage.stageHeight;
		}
	}
}

