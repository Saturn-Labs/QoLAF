package core.hud.components.dialogs
{
	import core.hud.components.Box;
	import core.hud.components.Button;
	import core.hud.components.Text;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.TouchEvent;
	
	public class PopupMessage extends Sprite
	{
		protected var textField:Text;
		
		protected var box:Box;
		
		public var closeButton:Button;
		
		public var callback:Function;
		
		protected var bgr:Quad;
		
		public function PopupMessage(param1:String = "OK", param2:uint = 5592405)
		{
			box = new Box(200, 100, "highlight", 1, 15);
			bgr = new Quad(100, 100, 570425344);
			super();
			textField = new Text();
			textField.size = 12;
			textField.width = 300;
			textField.wordWrap = true;
			textField.color = 16777215;
			closeButton = new Button(close, param1);
			bgr.alpha = 0.5;
			addChild(bgr);
			addChild(box);
			box.addChild(textField);
			box.addChild(closeButton);
			addEventListener("addedToStage", stageAddHandler);
		}
		
		private function stageAddHandler(param1:Event):void
		{
			addEventListener("removedFromStage", clean);
			stage.addEventListener("keyDown", keyDown);
			stage.addEventListener("resize", redraw);
			bgr.width = stage.stageWidth;
			bgr.height = stage.stageHeight;
			redraw();
		}
		
		public function enableCloseButton(param1:Boolean):void
		{
			closeButton.enabled = param1;
		}
		
		protected function keyDown(param1:KeyboardEvent):void
		{
			if (param1.keyCode == 13)
			{
				param1.stopImmediatePropagation();
				close();
			}
		}
		
		protected function close(param1:TouchEvent = null):void
		{
			dispatchEventWith("close");
			removeEventListeners();
			if (callback != null)
			{
				callback();
			}
		}
		
		public function set text(param1:String):void
		{
			textField.htmlText = param1;
			if (stage)
			{
				redraw();
			}
		}
		
		protected function redraw(param1:Event = null):void
		{
			if (stage == null)
			{
				return;
			}
			closeButton.y = Math.round(textField.height + 15);
			closeButton.x = Math.round(textField.width / 2 - closeButton.width / 2);
			var _loc2_:int = closeButton.y + closeButton.height - 3;
			box.width = textField.width;
			box.height = _loc2_;
			box.x = Math.round(stage.stageWidth / 2 - box.width / 2);
			box.y = Math.round(stage.stageHeight / 2 - box.height / 2);
			bgr.width = stage.stageWidth;
			bgr.height = stage.stageHeight;
		}
		
		protected function clean(param1:Event):void
		{
			stage.removeEventListener("resize", redraw);
			stage.removeEventListener("keyDown", keyDown);
			removeEventListener("removedFromStage", clean);
			removeEventListener("addedToStage", stageAddHandler);
			dispose();
		}
	}
}
