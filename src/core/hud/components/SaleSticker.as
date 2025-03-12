package core.hud.components
{
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import textures.TextureLocator;
	
	public class SaleSticker extends Sprite
	{
		public function SaleSticker(param1:String = "", param2:String = "", param3:String = "", param4:uint = 14942208, param5:Texture = null, param6:Texture = null)
		{
			var _loc11_:Image = null;
			super();
			var _loc10_:Image = new Image(param5 == null ? TextureLocator.getService().getTextureGUIByTextureName("sale_sticker") : param5);
			_loc10_.pivotX = _loc10_.texture.width / 2;
			_loc10_.pivotY = _loc10_.texture.height / 2;
			_loc10_.color = param4;
			addChild(_loc10_);
			if (Login.currentState == "facebook")
			{
				_loc11_ = new Image(param5 == null ? TextureLocator.getService().getTextureGUIByTextureName("fb_sale_lg") : param6);
				_loc11_.y = _loc10_.y + _loc10_.height / 2 - 45;
				_loc11_.pivotX = _loc11_.width / 2;
				_loc11_.x = _loc10_.x + 1;
				addChild(_loc11_);
			}
			var _loc7_:Text = new Text();
			_loc7_.size = 36;
			_loc7_.width = 110;
			_loc7_.htmlText = param1;
			_loc7_.centerPivot();
			addChild(_loc7_);
			var _loc9_:Text = new Text();
			_loc9_.size = 18;
			_loc9_.width = 110;
			_loc9_.htmlText = param3;
			_loc9_.y = -_loc7_.height / 2 - 5;
			_loc9_.centerPivot();
			addChild(_loc9_);
			var _loc8_:Text = new Text();
			_loc8_.size = 18;
			_loc8_.width = 110;
			_loc8_.htmlText = param2;
			_loc8_.y = _loc7_.height / 2 + 5;
			_loc8_.centerPivot();
			addChild(_loc8_);
		}
	}
}
