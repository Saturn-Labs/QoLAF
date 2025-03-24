package core.hud.components {
	import flash.errors.IllegalOperationError;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.events.TouchEvent;
	import starling.textures.Texture;
	
	public class InteractiveImage extends DisplayObjectContainer {
		protected var layer:Image;
		
		protected var source:Texture;
		
		protected var sourceHover:Texture;
		
		protected var captionText:Text = new Text();
		
		private var _captionPos:String = Position.CENTER;
		
		protected var _enabled:Boolean = true;
		
		private var alwaysShowCaption:Boolean = false;
		
		public function InteractiveImage(txt:Texture = null, hoverBd:Texture = null, caption:String = null, alwaysShowCaption:Boolean = false) {
			super();
			if(txt != null) {
				layer = new Image(txt);
				touchable = true;
				useHandCursor = true;
				texture = txt;
				source = txt;
				sourceHover = hoverBd;
				addChild(layer);
				this.caption = caption;
				addChild(captionText);
				this.alwaysShowCaption = alwaysShowCaption;
				if(!alwaysShowCaption) {
					hideCaption();
				}
				addListeners();
				return;
			}
			throw IllegalOperationError("You tried to create a hotkey without texture.");
		}
		
		public function set texture(bd:Texture) : void {
			if(bd == null) {
				return;
			}
			layer.texture = bd;
			source = bd;
			layer.readjustSize();
		}
		
		public function set hoverTexture(bd:Texture) : void {
			sourceHover = bd;
		}
		
		public function set captionPosition(pos:String) : void {
			_captionPos = pos;
			if(_captionPos == Position.LEFT) {
				captionText.y = 0;
				captionText.x = -captionText.width;
			} else if(_captionPos == Position.RIGHT) {
				captionText.y = 0;
				captionText.x = layer.width;
			} else if(_captionPos == Position.BOTTOM) {
				captionText.y = layer.height;
				captionText.x = 0;
			} else if(_captionPos == Position.INNER_RIGHT) {
				captionText.y = 5;
				captionText.x = layer.width - captionText.width - 5;
			} else if(_captionPos == Position.INNER_LEFT) {
				captionText.y = 5;
				captionText.x = 5;
			} else if(_captionPos == Position.CENTER) {
				captionText.y = layer.height / 2 - captionText.height / 2;
				captionText.x = layer.width / 2 - captionText.width / 2 + 0.5;
			}
		}
		
		public function showCaption() : void {
			if(captionText.text != null || captionText.text != "") {
				captionText.visible = true;
			}
		}
		
		public function hideCaption() : void {
			captionText.visible = false;
		}
		
		public function set caption(value:String) : void {
			captionText.text = value;
			captionPosition = _captionPos;
		}
		
		public function get caption() : String {
			return captionText.text;
		}
		
		public function set captionColor(value:uint) : void {
			captionText.color = value;
		}
		
		public function set captionSize(value:Number) : void {
			captionText.size = value;
		}
		
		public function set enabled(value:Boolean) : void {
			if(!_enabled && value) {
				addListeners();
			} else if(_enabled && !value) {
				removeListeners();
			}
			_enabled = value;
		}
		
		protected function onClick(e:TouchEvent) : void {
		}
		
		protected function onOver(e:TouchEvent) : void {
			if(!alwaysShowCaption) {
				showCaption();
			}
			if(sourceHover != null) {
				layer.texture = sourceHover;
			}
		}
		
		protected function onOut(e:TouchEvent) : void {
			if(!alwaysShowCaption) {
				hideCaption();
			}
			layer.texture = source;
		}
		
		private function onTouch(e:TouchEvent) : void {
			if(e.getTouch(this,"ended")) {
				onClick(e);
			} else if(e.interactsWith(this)) {
				onOver(e);
			} else if(!e.interactsWith(this)) {
				onOut(e);
			}
		}
		
		protected function addListeners() : void {
			addEventListener("touch",onTouch);
		}
		
		protected function removeListeners() : void {
			removeEventListener("touch",onTouch);
		}
	}
}

