package core.hud.components.dialogs
{
	import core.hud.components.LootItem;
	import starling.events.Event;
	
	public class LootPopupConfirmMessage extends PopupConfirmMessage
	{
		private var items:Vector.<LootItem>;
		
		public function LootPopupConfirmMessage(param1:String = "Confirm", param2:String = "Cancel")
		{
			items = new Vector.<LootItem>();
			super(param1, param2);
		}
		
		public function addItem(param1:LootItem):void
		{
			param1.y = textField.height + 40 * items.length;
			box.addChild(param1);
			items.push(param1);
			if (stage != null)
			{
				redraw();
			}
		}
		
		override protected function redraw(param1:Event = null):void
		{
			super.redraw();
			var _loc2_:Number = textField.height + items.length * 40 + 45;
			box.width = 320;
			box.height = _loc2_;
			closeButton.y = _loc2_ - 25;
			confirmButton.y = _loc2_ - 25;
			box.x = Math.round(stage.stageWidth / 2 - box.width / 2);
			box.y = Math.round(stage.stageHeight / 2 - box.height / 2);
			bgr.width = stage.stageWidth;
			bgr.height = stage.stageHeight;
		}
	}
}
