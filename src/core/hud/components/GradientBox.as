package core.hud.components
{
	import flash.display.Sprite;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	import textures.TextureManager;
	
	public class GradientBox extends starling.display.Sprite
	{
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
		
		public function GradientBox(param1:Number, param2:Number, param3:uint = 0, param4:Number = 1, param5:Number = 15, param6:uint = 16777215)
		{
			super();
			w = param1;
			h = param2;
			this.color = param3;
			this.colorAlpha = param4;
			this.padding = param5;
			this.headerTint = param6;
			addBorder(1842204, 1, 2);
			addEventListener("removedFromStage", clean);
		}
		
		public function load():void
		{
			var _loc1_:ITextureManager = TextureLocator.getService();
			headerBitmapData = _loc1_.getTextureGUIByTextureName("gradient_box_header.png");
			headerBmp = new Image(headerBitmapData);
			headerBmp.width = w + padding * 2 - borderWidth;
			headerBmp.x = -padding + borderWidth / 2;
			headerBmp.y = -padding + borderWidth / 2;
			headerBmp.color = headerTint;
			addChild(headerBmp);
		}
		
		public function addBorder(param1:uint, param2:Number, param3:Number):void
		{
			this.borderWidth = param3;
			this.borderColor = param1;
			this.borderAlpha = param2;
			draw();
		}
		
		override public function set width(param1:Number):void
		{
			w = param1;
			draw();
		}
		
		override public function set height(param1:Number):void
		{
			h = param1;
			draw();
		}
		
		public function set color(param1:uint):void
		{
			_color = param1;
			draw();
		}
		
		protected function draw():void
		{
			drawBox();
		}
		
		private function drawBox():void
		{
			if (background != null)
			{
				removeChild(background);
				background.dispose();
				backgroundTexture.dispose();
			}
			var _loc3_:Vector.<int> = new Vector.<int>();
			var _loc1_:Vector.<Number> = new Vector.<Number>();
			_loc3_.push(1, 2, 2, 2, 2);
			_loc1_.push(0 - padding, 0 - padding);
			_loc1_.push(0 - padding, h + padding);
			_loc1_.push(w + padding, h + padding);
			_loc1_.push(w + padding, 0 - padding);
			_loc1_.push(0 - padding, 0 - padding);
			var _loc2_:flash.display.Sprite = new flash.display.Sprite();
			_loc2_.graphics.beginFill(_color, colorAlpha);
			_loc2_.graphics.drawPath(_loc3_, _loc1_);
			_loc2_.graphics.endFill();
			backgroundTexture = TextureManager.textureFromDisplayObject(_loc2_);
			background = new Image(backgroundTexture);
			background.x = -padding;
			addChildAt(background, 0);
		}
		
		private function clean(param1:Event = null):void
		{
			removeEventListeners();
			if (background != null)
			{
				removeChild(background);
				background.dispose();
				backgroundTexture.dispose();
			}
		}
	}
}
