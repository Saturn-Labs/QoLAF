package core.hud.components.shipMenu
{
	import core.hud.components.Text;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import starling.filters.ColorMatrixFilter;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	import textures.TextureManager;
	
	public class MenuSelectIcon extends Sprite
	{
		private static const WIDTH:int = 40;
		private static const HEIGHT:int = 40;
		public static const BITMAP_WEAPON:String = "slot_weapon.png";
		public static const BITMAP_ARTIFACT:String = "slot_artifact.png";
		public static const BITMAP_CREW:String = "slot_crew.png";
		public static const BITMAP_FRIEND:String = "slot_friend.png";
		private var bmp:Image;
		
		private var bgrBmp:Image;
		
		private var lockBmp:Image;
		
		public var number:int = 0;
		private var _captionText:Text;
		
		private var _levelText:Text;
		
		private var _numberText:Text;
		
		private var textureManager:ITextureManager;
		
		private var _locked:Boolean;
		
		private var _inUse:Boolean;
		
		public function MenuSelectIcon(param1:int, param2:Texture, param3:String, param4:Boolean, param5:Boolean, param6:Boolean, param7:int = 0, param8:String = null)
		{
			var that:Sprite;
			var texture2:Texture;
			var texture3:Texture;
			var number:int = param1;
			var texture:Texture = param2;
			var type:String = param3;
			var locked:Boolean = param4;
			var inUse:Boolean = param5;
			var enabled:Boolean = param6;
			var level:int = param7;
			var caption:String = param8;
			_captionText = new Text();
			_levelText = new Text();
			_numberText = new Text();
			super();
			this.bmp = texture == null ? new Image(TextureManager.BASIC_TEXTURE) : new Image(texture);
			bgrBmp = new Image(TextureManager.BASIC_TEXTURE);
			lockBmp = new Image(TextureManager.BASIC_TEXTURE);
			bmp.width = 40;
			bmp.height = 40;
			textureManager = TextureLocator.getService();
			this.locked = locked;
			this.level = level;
			this.caption = caption;
			this.inUse = inUse;
			this.number = number;
			that = this;
			if (enabled)
			{
				useHandCursor = true;
				_numberText.color = 16777215;
				addEventListener("touch", function(param1:TouchEvent):void
				{
					var _loc2_:ColorMatrixFilter = null;
					if (param1.interactsWith(that))
					{
						_loc2_ = new ColorMatrixFilter();
						_loc2_.adjustBrightness(0.2);
						filter = _loc2_;
					}
					else if (filter)
					{
						filter.dispose();
						filter = null;
					}
				});
			}
			else
			{
				useHandCursor = false;
				alpha = 0.3;
				_numberText.color = 11119017;
			}
			_numberText.text = number.toString();
			_numberText.x = 40 / 2 - _numberText.width / 2 + 1;
			addChild(bmp);
			addChild(bgrBmp);
			addChild(lockBmp);
			texture2 = textureManager.getTextureGUIByTextureName(type);
			bgrBmp.texture = texture2;
			bgrBmp.readjustSize();
			texture3 = textureManager.getTextureGUIByTextureName("lock.png");
			lockBmp.texture = texture3;
			lockBmp.readjustSize();
			lockBmp.x = 40 / 2 - lockBmp.width / 2;
			lockBmp.y = 40 / 2 - lockBmp.height / 2;
			this.locked = locked;
			addChild(_levelText);
			addChild(_captionText);
			addChild(_numberText);
		}
		
		public function get locked():Boolean
		{
			return _locked;
		}
		
		public function set locked(param1:Boolean):void
		{
			_locked = param1;
			lockBmp.visible = param1;
			bgrBmp.visible = param1;
			if (param1)
			{
				_numberText.size = 10;
				_numberText.y = 17;
				bmp.visible = false;
				_captionText.visible = false;
				_levelText.visible = false;
			}
			else
			{
				_numberText.size = 16;
				_numberText.y = 10;
				_numberText.touchable = true;
			}
		}
		
		public function changeBitmapData(param1:Texture):void
		{
			bmp.texture = param1;
		}
		
		public function set inUse(param1:Boolean):void
		{
			_inUse = param1;
			bgrBmp.visible = !param1;
			bmp.visible = param1;
			_numberText.visible = !param1;
			_captionText.visible = param1;
			_levelText.visible = param1;
		}
		
		public function set caption(param1:String):void
		{
			_captionText.glowIn(0, 1, 2, 8);
			_captionText.color = 16777215;
			_captionText.text = param1;
			_captionText.x = 38 - _captionText.width;
			_captionText.y = 2;
		}
		
		public function set level(param1:int):void
		{
			if (param1 == 0)
			{
				return;
			}
			_levelText.text = param1.toString();
			_levelText.color = 11119017;
			_levelText.center();
			_levelText.x = 20;
			_levelText.y = 48;
		}
	}
}
