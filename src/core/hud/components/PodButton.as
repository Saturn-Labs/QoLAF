package core.hud.components
{
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
	
	public class PodButton extends Sprite
	{
		protected static var normalTexture:Texture;
		
		protected static var highlightTexture:Texture;
		
		protected static var positiveTexture:Texture;
		
		protected static var warningTexture:Texture;
		
		protected static const BUTTON_SCALE_9_GRID:Rectangle = new Rectangle(25, 11, 8, 4);
		protected var image:Image;
		
		protected var styleImage:Image;
		
		protected var hoverImage:Image;
		
		protected var style:String;
		
		protected var tf:TextField;
		
		protected var autoscale:Boolean = true;
		protected var padding:int = 10;
		public var autoEnableAfterClick:Boolean = false;
		public var callback:Function;
		
		public function PodButton(param1:Function, param2:String = "I'm a button yeah", param3:String = "normal", param4:int = 13, param5:String = "font13")
		{
			super();
			this.callback = param1;
			this.style = param3;
			useHandCursor = true;
			var _loc6_:ITextureManager = TextureLocator.getService();
			normalTexture = _loc6_.getTextureGUIByTextureName("button-normal");
			highlightTexture = _loc6_.getTextureGUIByTextureName("button-highlight");
			positiveTexture = _loc6_.getTextureGUIByTextureName("button-positive");
			warningTexture = _loc6_.getTextureGUIByTextureName("button-warning");
			updateStyle();
			addChild(styleImage);
			addChild(hoverImage);
			if (param2 == "")
			{
				param2 = "Button Text";
			}
			tf = new TextField(500, param4 * 1.6, param2, new TextFormat(param5, param4, 16777215));
			tf.width = tf.textBounds.width + 2 * padding;
			tf.touchable = false;
			tf.batchable = true;
			addChild(tf);
			image = new Image(TextureLocator.getService().getTextureGUIByTextureName("button_pod"));
			image.scaleX = 0.6;
			image.scaleY = 0.6;
			addChild(image);
			update();
			addEventListener("touch", onTouch);
			addEventListener("addedToStage", update);
		}
		
		protected function update(param1:Event = null):void
		{
			if (!this.stage)
			{
				return;
			}
			if (autoscale)
			{
				tf.width = tf.textBounds.width + 2 * padding;
			}
			image.x = tf.x + tf.width - 5;
			image.y = 5;
			hoverImage.width = styleImage.width = tf.width + image.width;
			hoverImage.height = styleImage.height = tf.height < image.height ? image.height + 10 : tf.height;
			if (hasEventListener("addedToStage"))
			{
				removeEventListener("addedToStage", update);
			}
		}
		
		public function centerPivot():void
		{
			pivotX = width / 2;
			pivotY = height / 2;
		}
		
		protected function updateStyle():void
		{
			var _loc1_:Texture = null;
			if (style == "highlight")
			{
				_loc1_ = highlightTexture;
			}
			else if (style == "positive" || style == "buy" || style == "reward")
			{
				_loc1_ = positiveTexture;
			}
			else if (style == "negative")
			{
				_loc1_ = warningTexture;
			}
			else
			{
				_loc1_ = normalTexture;
			}
			styleImage = new Image(_loc1_);
			hoverImage = new Image(_loc1_);
			styleImage.scale9Grid = BUTTON_SCALE_9_GRID;
			hoverImage.scale9Grid = BUTTON_SCALE_9_GRID;
			hoverImage.blendMode = "screen";
			hoverImage.visible = false;
		}
		
		public function set text(param1:String):void
		{
			tf.text = param1;
			update();
		}
		
		public function get text():String
		{
			return tf.text;
		}
		
		override public function set width(param1:Number):void
		{
			tf.width = param1;
			autoscale = false;
			update();
		}
		
		override public function get width():Number
		{
			return tf.width + image.width;
		}
		
		public function set size(param1:int):void
		{
			var _loc2_:int = autoscale ? 500 : tf.width;
			tf.format.size = param1;
			update();
		}
		
		public function set enabled(param1:Boolean):void
		{
			if (param1)
			{
				alpha = 1;
				if (!hasEventListener("touch"))
				{
					addEventListener("touch", onTouch);
				}
			}
			else
			{
				alpha = 0.2;
				removeEventListener("touch", onTouch);
			}
			useHandCursor = param1;
		}
		
		public function alignWithText():void
		{
			y -= Math.round((tf.height - 14) / 2);
		}
		
		private function onTouch(param1:TouchEvent):void
		{
			if (param1.getTouch(this, "began"))
			{
				onClick(param1);
				param1.stopPropagation();
			}
			else if (param1.interactsWith(this))
			{
				mouseOver(param1);
			}
			else if (!param1.interactsWith(this))
			{
				mouseOut(param1);
			}
		}
		
		private function onClick(param1:TouchEvent):void
		{
			var _loc2_:ISound = SoundLocator.getService();
			if (_loc2_ != null)
			{
				_loc2_.play("3hVYqbNNSUWoDGk_pK1BdQ");
			}
			if (!autoEnableAfterClick)
			{
				enabled = false;
			}
			hoverImage.visible = false;
			if (callback != null)
			{
				callback(param1);
			}
		}
		
		private function mouseOver(param1:TouchEvent):void
		{
			hoverImage.visible = true;
		}
		
		private function mouseOut(param1:TouchEvent):void
		{
			hoverImage.visible = false;
		}
		
		override public function set x(param1:Number):void
		{
			super.x = Math.round(param1);
		}
		
		override public function set y(param1:Number):void
		{
			super.y = Math.round(param1);
		}
	}
}
