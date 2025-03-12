package core.hud.components.dialogs
{
	import core.hud.components.LootItem;
	import starling.events.Event;
	
	public class LootPopupMessage extends PopupMessage
	{
		private var items:Vector.<LootItem>;
		
		public function LootPopupMessage(param1:String = "Take All")
		{
			items = new Vector.<LootItem>();
			super(param1);
		}
		
		public function addItem(param1:LootItem):void
		{
			param1.y = 40 * items.length;
			box.addChild(param1);
			items.push(param1);
			redraw();
		}
		
		override protected function redraw(param1:Event = null):void
		{
			var _loc2_:Number = 230;
			if (items.length > 0)
			{
				_loc2_ = items[0].width;
			}
			if (_loc2_ < 200)
			{
				_loc2_ = 200;
			}
			closeButton.y = Math.round(items.length * 40 + 5);
			closeButton.x = Math.round(_loc2_ / 2 - closeButton.width / 2);
			box.width = _loc2_;
			box.height = items.length * 40 + 25;
			box.x = Math.round(stage.stageWidth / 2 - box.width / 2);
			box.y = Math.round(stage.stageHeight / 2 - box.height / 2);
			bgr.width = stage.stageWidth;
			bgr.height = stage.stageHeight;
		}
	}
}
