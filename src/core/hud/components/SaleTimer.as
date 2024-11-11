package core.hud.components
{
	import starling.display.Sprite;
	import starling.events.Event;

	public class SaleTimer extends Sprite
	{
		private var hudTimer:HudTimer;
		private var text:Text;
		private var callback:Function = null;
		public function SaleTimer(param1:*, param2:Number, param3:Number, param4:Function)
		{
			var g:* = param1;
			var start:Number = param2;
			var end:Number = param3;
			var callback:Function = param4;
			super();
			this.callback = callback;
			text = new Text();
			text.size = 18;
			text.text = "Offer ends in";
			addChild(text);
			hudTimer = new HudTimer(g, 18);
			hudTimer.x = text.x + 35;
			hudTimer.y = text.y + text.height / 2 + 5;
			hudTimer.start(start, end);
			addChild(hudTimer);
			addEventListener("enterFrame", update);
			addEventListener("removedFromStage", function(param1:Event):void
				{
					removeEventListeners();
				});
		}

		private function update(param1:Event):void
		{
			hudTimer.update();
			if (hudTimer.isComplete() && callback != null)
			{
				callback();
			}
		}
	}
}
