package core.hud.components
{
	import core.scene.Game;
	import flash.geom.Rectangle;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class Box extends Sprite
	{
		protected static var normalTexture:Texture;
		
		protected static var highlightTexture:Texture;
		
		protected static var buyTexture:Texture;
		
		protected static var lightTexture:Texture;
		
		protected static var themeLoaded:Boolean;
		
		public static const STYLE_HIGHLIGHT:String = "highlight";
		
		public static const STYLE_NORMAL:String = "normal";
		
		public static const STYLE_BUY:String = "buy";
		
		public static const STYLE_DARK_GRAY:String = "light";
		
		protected static const BUTTON_SCALE_9_GRID:Rectangle = new Rectangle(25, 25, 8, 4);
		
		protected var w:Number;
		
		protected var h:Number;
		
		protected var styleImage:Image;
		
		protected var _style:String;
		
		protected var _padding:Number;
		
		public function Box(param1:Number, param2:Number, param3:String = "normal", param4:Number = 1, param5:Number = 20)
		{
			super();
			if (!Box.themeLoaded && normalTexture == null)
			{
				normalTexture = Game.assets.getTexture("box_normal");
				highlightTexture = Game.assets.getTexture("box_highlight");
			}
			this._style = param3;
			updateStyle();
			styleImage.alpha = param4;
			this._padding = param5;
			this.width = param1;
			this.height = param2;
		}
		
		public static function loadTheme():void
		{
			themeLoaded = true;
			var _loc1_:ITextureManager = TextureLocator.getService();
			normalTexture = _loc1_.getTextureGUIByTextureName("box-normal");
			highlightTexture = _loc1_.getTextureGUIByTextureName("box-highlight");
			buyTexture = _loc1_.getTextureGUIByTextureName("box-buy");
			lightTexture = _loc1_.getTextureGUIByTextureName("box-light");
		}
		
		public function set style(param1:String):void
		{
			_style = param1;
			updateStyle();
		}
		
		public function get style():String
		{
			return _style;
		}
		
		public function updateStyle():void
		{
			var _loc1_:Texture = null;
			if (style == "highlight")
			{
				_loc1_ = highlightTexture;
			}
			else if (style == "buy")
			{
				_loc1_ = buyTexture;
			}
			else if (style == "light")
			{
				_loc1_ = lightTexture;
			}
			else
			{
				_loc1_ = normalTexture;
			}
			if (styleImage)
			{
				removeChild(styleImage);
			}
			styleImage = new Image(_loc1_);
			styleImage.scale9Grid = BUTTON_SCALE_9_GRID;
			addChildAt(styleImage, 0);
			draw();
		}
		
		public function get padding():Number
		{
			return _padding;
		}
		
		override public function set alpha(param1:Number):void
		{
			styleImage.alpha = param1;
		}
		
		override public function set width(param1:Number):void
		{
			w = param1 + padding * 2;
			draw();
		}
		
		override public function set height(param1:Number):void
		{
			h = param1 + padding * 2;
			draw();
		}
		
		protected function draw():void
		{
			if (padding && w && h)
			{
				styleImage.x = -padding;
				styleImage.y = -padding;
				styleImage.width = w;
				styleImage.height = h;
			}
		}
	}
}
