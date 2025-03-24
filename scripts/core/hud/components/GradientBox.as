package core.hud.components {
	import flash.display.Sprite;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	import textures.TextureManager;
	
	public class GradientBox extends starling.display.Sprite {
		protected var radius:Number;
		
		protected var _color:uint;
		
		protected var colorAlpha:Number;
		
		public var padding:Number;
		
		protected var w:Number;
		
		protected var h:Number;
		
		private var background:Image;
		
		private var backgroundTexture:Texture;
		
		protected var borderWidth:Number = 0;
		
		protected var borderColor:uint = 0;
		
		protected var borderAlpha:Number = 0;
		
		private var headerBmp:Image;
		
		private var headerTint:uint;
		
		private var headerBitmapData:Texture;
		
		public function GradientBox(width:Number, height:Number, color:uint = 0, alpha:Number = 1, padding:Number = 15, headerTint:uint = 16777215) {
			super();
			w = width;
			h = height;
			this.color = color;
			this.colorAlpha = alpha;
			this.padding = padding;
			this.headerTint = headerTint;
			addBorder(0x1c1c1c,1,2);
			addEventListener("removedFromStage",clean);
		}
		
		public function load() : void {
			var _local1:ITextureManager = TextureLocator.getService();
			headerBitmapData = _local1.getTextureGUIByTextureName("gradient_box_header.png");
			headerBmp = new Image(headerBitmapData);
			headerBmp.width = w + padding * 2 - borderWidth;
			headerBmp.x = -padding + borderWidth / 2;
			headerBmp.y = -padding + borderWidth / 2;
			headerBmp.color = headerTint;
			addChild(headerBmp);
		}
		
		public function addBorder(borderColor:uint, borderAlpha:Number, borderWidth:Number) : void {
			this.borderWidth = borderWidth;
			this.borderColor = borderColor;
			this.borderAlpha = borderAlpha;
			draw();
		}
		
		override public function set width(value:Number) : void {
			w = value;
			draw();
		}
		
		override public function set height(value:Number) : void {
			h = value;
			draw();
		}
		
		public function set color(value:uint) : void {
			_color = value;
			draw();
		}
		
		protected function draw() : void {
			drawBox();
		}
		
		private function drawBox() : void {
			if(background != null) {
				removeChild(background);
				background.dispose();
				backgroundTexture.dispose();
			}
			var _local2:Vector.<int> = new Vector.<int>();
			var _local3:Vector.<Number> = new Vector.<Number>();
			_local2.push(1,2,2,2,2);
			_local3.push(0 - padding,0 - padding);
			_local3.push(0 - padding,h + padding);
			_local3.push(w + padding,h + padding);
			_local3.push(w + padding,0 - padding);
			_local3.push(0 - padding,0 - padding);
			var _local1:flash.display.Sprite = new flash.display.Sprite();
			_local1.graphics.beginFill(_color,colorAlpha);
			_local1.graphics.drawPath(_local2,_local3);
			_local1.graphics.endFill();
			backgroundTexture = TextureManager.textureFromDisplayObject(_local1);
			background = new Image(backgroundTexture);
			background.x = -padding;
			addChildAt(background,0);
		}
		
		private function clean(e:Event = null) : void {
			removeEventListeners();
			if(background != null) {
				removeChild(background);
				background.dispose();
				backgroundTexture.dispose();
			}
		}
	}
}

