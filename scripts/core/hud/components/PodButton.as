package core.hud.components {
	import flash.geom.Rectangle;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class PodButton extends Sprite {
		protected static var normalTexture:Texture;
		
		protected static var highlightTexture:Texture;
		
		protected static var positiveTexture:Texture;
		
		protected static var warningTexture:Texture;
		
		protected static const BUTTON_SCALE_9_GRID:Rectangle = new Rectangle(25,11,8,4);
		
		protected var image:Image;
		
		protected var styleImage:Image;
		
		protected var hoverImage:Image;
		
		protected var style:String;
		
		protected var tf:TextField;
		
		protected var autoscale:Boolean = true;
		
		protected var padding:int = 10;
		
		public var autoEnableAfterClick:Boolean = false;
		
		public var callback:Function;
		
		public function PodButton(callback:Function, buttonText:String = "I\'m a button yeah", style:String = "normal", size:int = 13, font:String = "font13") {
			super();
			this.callback = callback;
			this.style = style;
			useHandCursor = true;
			var _local6:ITextureManager = TextureLocator.getService();
			normalTexture = _local6.getTextureGUIByTextureName("button-normal");
			highlightTexture = _local6.getTextureGUIByTextureName("button-highlight");
			positiveTexture = _local6.getTextureGUIByTextureName("button-positive");
			warningTexture = _local6.getTextureGUIByTextureName("button-warning");
			updateStyle();
			addChild(styleImage);
			addChild(hoverImage);
			if(buttonText == "") {
				buttonText = "Button Text";
			}
			tf = new TextField(500,size * 1.6,buttonText,new TextFormat(font,size,0xffffff));
			tf.width = tf.textBounds.width + 2 * padding;
			tf.touchable = false;
			tf.batchable = true;
			addChild(tf);
			image = new Image(TextureLocator.getService().getTextureGUIByTextureName("button_pod"));
			image.scaleX = 0.6;
			image.scaleY = 0.6;
			addChild(image);
			update();
			addEventListener("touch",onTouch);
			addEventListener("addedToStage",update);
		}
		
		protected function update(e:Event = null) : void {
			if(!this.stage) {
				return;
			}
			if(autoscale) {
				tf.width = tf.textBounds.width + 2 * padding;
			}
			image.x = tf.x + tf.width - 5;
			image.y = 5;
			hoverImage.width = styleImage.width = tf.width + image.width;
			hoverImage.height = styleImage.height = tf.height < image.height ? image.height + 10 : tf.height;
			if(hasEventListener("addedToStage")) {
				removeEventListener("addedToStage",update);
			}
		}
		
		public function centerPivot() : void {
			pivotX = width / 2;
			pivotY = height / 2;
		}
		
		protected function updateStyle() : void {
			var _local1:Texture = null;
			if(style == "highlight") {
				_local1 = highlightTexture;
			} else if(style == "positive" || style == "buy" || style == "reward") {
				_local1 = positiveTexture;
			} else if(style == "negative") {
				_local1 = warningTexture;
			} else {
				_local1 = normalTexture;
			}
			styleImage = new Image(_local1);
			hoverImage = new Image(_local1);
			styleImage.scale9Grid = BUTTON_SCALE_9_GRID;
			hoverImage.scale9Grid = BUTTON_SCALE_9_GRID;
			hoverImage.blendMode = "screen";
			hoverImage.visible = false;
		}
		
		public function set text(value:String) : void {
			tf.text = value;
			update();
		}
		
		public function get text() : String {
			return tf.text;
		}
		
		override public function set width(value:Number) : void {
			tf.width = value;
			autoscale = false;
			update();
		}
		
		override public function get width() : Number {
			return tf.width + image.width;
		}
		
		public function set size(value:int) : void {
			var _local2:int = autoscale ? 500 : tf.width;
			tf.format.size = value;
			update();
		}
		
		public function set enabled(value:Boolean) : void {
			if(value) {
				alpha = 1;
				if(!hasEventListener("touch")) {
					addEventListener("touch",onTouch);
				}
			} else {
				alpha = 0.2;
				removeEventListener("touch",onTouch);
			}
			useHandCursor = value;
		}
		
		public function alignWithText() : void {
			y -= Math.round((tf.height - 14) / 2);
		}
		
		private function onTouch(e:TouchEvent) : void {
			if(e.getTouch(this,"began")) {
				onClick(e);
				e.stopPropagation();
			} else if(e.interactsWith(this)) {
				mouseOver(e);
			} else if(!e.interactsWith(this)) {
				mouseOut(e);
			}
		}
		
		private function onClick(e:TouchEvent) : void {
			var _local2:ISound = SoundLocator.getService();
			if(_local2 != null) {
				_local2.play("3hVYqbNNSUWoDGk_pK1BdQ");
			}
			if(!autoEnableAfterClick) {
				enabled = false;
			}
			hoverImage.visible = false;
			if(callback != null) {
				callback(e);
			}
		}
		
		private function mouseOver(e:TouchEvent) : void {
			hoverImage.visible = true;
		}
		
		private function mouseOut(e:TouchEvent) : void {
			hoverImage.visible = false;
		}
		
		override public function set x(value:Number) : void {
			super.x = Math.round(value);
		}
		
		override public function set y(value:Number) : void {
			super.y = Math.round(value);
		}
	}
}

