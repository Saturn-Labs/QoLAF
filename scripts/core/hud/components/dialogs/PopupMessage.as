package core.hud.components.dialogs {
	import core.hud.components.Box;
	import core.hud.components.Button;
	import core.hud.components.Text;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.TouchEvent;
	
	public class PopupMessage extends Sprite {
		protected var textField:Text;
		
		protected var box:Box = new Box(200,100,"highlight",1,15);
		
		public var closeButton:Button;
		
		public var callback:Function;
		
		protected var bgr:Quad = new Quad(100,100,0x22000000);
		
		public function PopupMessage(closeText:String = "OK", borderColor:uint = 5592405) {
			super();
			textField = new Text();
			textField.size = 12;
			textField.width = 5 * 60;
			textField.wordWrap = true;
			textField.color = 0xffffff;
			closeButton = new Button(close,closeText);
			bgr.alpha = 0.5;
			addChild(bgr);
			addChild(box);
			box.addChild(textField);
			box.addChild(closeButton);
			addEventListener("addedToStage",stageAddHandler);
		}
		
		private function stageAddHandler(e:Event) : void {
			addEventListener("removedFromStage",clean);
			stage.addEventListener("keyDown",keyDown);
			stage.addEventListener("resize",redraw);
			bgr.width = stage.stageWidth;
			bgr.height = stage.stageHeight;
			redraw();
		}
		
		public function enableCloseButton(value:Boolean) : void {
			closeButton.enabled = value;
		}
		
		protected function keyDown(e:KeyboardEvent) : void {
			if(e.keyCode == 13) {
				e.stopImmediatePropagation();
				close();
			}
		}
		
		protected function close(e:TouchEvent = null) : void {
			dispatchEventWith("close");
			removeEventListeners();
			if(callback != null) {
				callback();
			}
		}
		
		public function set text(newText:String) : void {
			textField.htmlText = newText;
			if(stage) {
				redraw();
			}
		}
		
		protected function redraw(e:Event = null) : void {
			if(stage == null) {
				return;
			}
			closeButton.y = Math.round(textField.height + 15);
			closeButton.x = Math.round(textField.width / 2 - closeButton.width / 2);
			var _local2:int = closeButton.y + closeButton.height - 3;
			box.width = textField.width;
			box.height = _local2;
			box.x = Math.round(stage.stageWidth / 2 - box.width / 2);
			box.y = Math.round(stage.stageHeight / 2 - box.height / 2);
			bgr.width = stage.stageWidth;
			bgr.height = stage.stageHeight;
		}
		
		protected function clean(e:Event) : void {
			stage.removeEventListener("resize",redraw);
			stage.removeEventListener("keyDown",keyDown);
			removeEventListener("removedFromStage",clean);
			removeEventListener("addedToStage",stageAddHandler);
			dispose();
		}
	}
}

