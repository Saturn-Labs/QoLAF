package core.hud.components.dialogs {
	import core.hud.components.LootItem;
	import starling.events.Event;
	
	public class LootPopupMessage extends PopupMessage {
		private var items:Vector.<LootItem> = new Vector.<LootItem>();
		
		public function LootPopupMessage(takeMessage:String = "Take All") {
			super(takeMessage);
		}
		
		public function addItem(item:LootItem) : void {
			item.y = 40 * items.length;
			box.addChild(item);
			items.push(item);
			redraw();
		}
		
		override protected function redraw(e:Event = null) : void {
			var _local2:Number = 230;
			if(items.length > 0) {
				_local2 = items[0].width;
			}
			if(_local2 < 200) {
				_local2 = 200;
			}
			closeButton.y = Math.round(items.length * 40 + 5);
			closeButton.x = Math.round(_local2 / 2 - closeButton.width / 2);
			box.width = _local2;
			box.height = items.length * 40 + 25;
			box.x = Math.round(stage.stageWidth / 2 - box.width / 2);
			box.y = Math.round(stage.stageHeight / 2 - box.height / 2);
			bgr.width = stage.stageWidth;
			bgr.height = stage.stageHeight;
		}
	}
}

