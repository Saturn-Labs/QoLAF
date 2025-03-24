package core.hud.components {
	import core.scene.Game;
	import flash.geom.Rectangle;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class Box extends Sprite {
		protected static var normalTexture:Texture;
		
		protected static var highlightTexture:Texture;
		
		protected static var buyTexture:Texture;
		
		protected static var lightTexture:Texture;
		
		protected static var themeLoaded:Boolean;
		
		public static const STYLE_HIGHLIGHT:String = "highlight";
		
		public static const STYLE_NORMAL:String = "normal";
		
		public static const STYLE_BUY:String = "buy";
		
		public static const STYLE_DARK_GRAY:String = "light";
		
		protected static const BUTTON_SCALE_9_GRID:Rectangle = new Rectangle(25,25,8,4);
		
		protected var w:Number;
		
		protected var h:Number;
		
		protected var styleImage:Image;
		
		protected var _style:String;
		
		protected var _padding:Number;
		
		public function Box(width:Number, height:Number, style:String = "normal", alpha:Number = 1, padding:Number = 20) {
			super();
			if(!Box.themeLoaded && normalTexture == null) {
				normalTexture = Game.assets.getTexture("box_normal");
				highlightTexture = Game.assets.getTexture("box_highlight");
			}
			this._style = style;
			updateStyle();
			styleImage.alpha = alpha;
			this._padding = padding;
			this.width = width;
			this.height = height;
		}
		
		public static function loadTheme() : void {
			themeLoaded = true;
			var _local1:ITextureManager = TextureLocator.getService();
			normalTexture = _local1.getTextureGUIByTextureName("box-normal");
			highlightTexture = _local1.getTextureGUIByTextureName("box-highlight");
			buyTexture = _local1.getTextureGUIByTextureName("box-buy");
			lightTexture = _local1.getTextureGUIByTextureName("box-light");
		}
		
		public function set style(value:String) : void {
			_style = value;
			updateStyle();
		}
		
		public function get style() : String {
			return _style;
		}
		
		public function updateStyle() : void {
			var _local1:Texture = null;
			if(style == "highlight") {
				_local1 = highlightTexture;
			} else if(style == "buy") {
				_local1 = buyTexture;
			} else if(style == "light") {
				_local1 = lightTexture;
			} else {
				_local1 = normalTexture;
			}
			if(styleImage) {
				removeChild(styleImage);
			}
			styleImage = new Image(_local1);
			styleImage.scale9Grid = BUTTON_SCALE_9_GRID;
			addChildAt(styleImage,0);
			draw();
		}
		
		public function get padding() : Number {
			return _padding;
		}
		
		override public function set alpha(value:Number) : void {
			styleImage.alpha = value;
		}
		
		override public function set width(value:Number) : void {
			w = value + padding * 2;
			draw();
		}
		
		override public function set height(value:Number) : void {
			h = value + padding * 2;
			draw();
		}
		
		protected function draw() : void {
			if(padding && w && h) {
				styleImage.x = -padding;
				styleImage.y = -padding;
				styleImage.width = w;
				styleImage.height = h;
			}
		}
	}
}

