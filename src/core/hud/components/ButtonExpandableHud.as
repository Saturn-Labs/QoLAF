package core.hud.components
{
	import flash.geom.Rectangle;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class ButtonExpandableHud extends DisplayObjectContainer
	{
		private static var bgrLeftTexture:Texture;
		
		private static var bgrMidTexture:Texture;
		
		private static var bgrRightTexture:Texture;
		
		private static var hoverLeftTexture:Texture;
		
		private static var hoverMidTexture:Texture;
		
		private static var hoverRightTexture:Texture;
		
		private var captionText:TextBitmap;
		
		private var padding:Number = 8;
		
		private var hoverContainer:Sprite;
		
		private var callback:Function;
		
		private var _enabled:Boolean = true;
		
		public function ButtonExpandableHud(param1:Function, param2:String)
		{
			hoverContainer = new Sprite();
			super();
			callback = param1;
			captionText = new TextBitmap(padding, 2, param2);
			captionText.format.color = Style.COLOR_HIGHLIGHT;
			useHandCursor = true;
			addEventListener("removedFromStage", clean);
			load();
		}
		
		public function set text(param1:String):void
		{
			captionText.text = param1;
		}
		
		public function load():void
		{
			var _loc1_:ITextureManager = TextureLocator.getService();
			var _loc9_:Texture = _loc1_.getTextureGUIByTextureName("button.png");
			if (bgrLeftTexture == null)
			{
				bgrLeftTexture = Texture.fromTexture(_loc9_, new Rectangle(0, 0, padding, 21));
				bgrMidTexture = Texture.fromTexture(_loc9_, new Rectangle(padding, 0, padding, 21));
				bgrRightTexture = Texture.fromTexture(_loc9_, new Rectangle(_loc9_.width - padding, 0, padding, 21));
			}
			var _loc8_:Image = new Image(bgrLeftTexture);
			var _loc3_:Image = new Image(bgrMidTexture);
			var _loc6_:Image = new Image(bgrRightTexture);
			_loc3_.x = padding;
			_loc3_.width = captionText.width;
			_loc6_.x = _loc3_.x + _loc3_.width;
			addChild(_loc8_);
			addChild(_loc3_);
			addChild(_loc6_);
			var _loc2_:Texture = _loc1_.getTextureGUIByTextureName("button_hover.png");
			if (hoverLeftTexture == null)
			{
				hoverLeftTexture = Texture.fromTexture(_loc2_, new Rectangle(0, 0, padding, 21));
				hoverMidTexture = Texture.fromTexture(_loc2_, new Rectangle(padding, 0, padding, 21));
				hoverRightTexture = Texture.fromTexture(_loc2_, new Rectangle(_loc9_.width - padding, 0, padding, 21));
			}
			var _loc5_:Image = new Image(hoverLeftTexture);
			var _loc7_:Image = new Image(hoverMidTexture);
			var _loc4_:Image = new Image(hoverRightTexture);
			_loc7_.x = padding;
			_loc7_.width = captionText.width;
			_loc4_.x = _loc3_.x + _loc3_.width;
			hoverContainer.addChild(_loc5_);
			hoverContainer.addChild(_loc7_);
			hoverContainer.addChild(_loc4_);
			hoverContainer.visible = false;
			addChild(hoverContainer);
			addEventListener("touch", onTouch);
			addChild(captionText);
		}
		
		private function onMouseOver(param1:TouchEvent):void
		{
			hoverContainer.visible = true;
		}
		
		private function onMouseOut(param1:TouchEvent):void
		{
			hoverContainer.visible = false;
		}
		
		private function onClick(param1:TouchEvent):void
		{
			var _loc2_:ISound = SoundLocator.getService();
			if (_loc2_ != null)
			{
				_loc2_.play("3hVYqbNNSUWoDGk_pK1BdQ");
			}
			hoverContainer.visible = false;
			enabled = false;
			if (callback == null)
			{
				return;
			}
			callback();
		}
		
		public function set enabled(param1:Boolean):void
		{
			_enabled = param1;
			if (param1)
			{
				alpha = 1;
			}
			else
			{
				alpha = 0.5;
			}
		}
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set select(param1:Boolean):void
		{
			if (param1)
			{
				captionText.format.color = 16777130;
			}
			else
			{
				captionText.format.color = Style.COLOR_HIGHLIGHT;
			}
		}
		
		private function onTouch(param1:TouchEvent):void
		{
			if (!_enabled)
			{
				return;
			}
			if (param1.getTouch(this, "ended"))
			{
				onClick(param1);
			}
			else if (param1.interactsWith(this))
			{
				onMouseOver(param1);
			}
			else if (!param1.interactsWith(this))
			{
				onMouseOut(param1);
			}
		}
		
		private function clean(param1:Event = null):void
		{
			removeEventListener("touch", onTouch);
			removeEventListener("removedFromStage", clean);
		}
	}
}
