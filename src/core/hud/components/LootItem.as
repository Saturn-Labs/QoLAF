package core.hud.components
{
	import data.DataLocator;
	import data.IDataManager;
	import playerio.DatabaseObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class LootItem extends Sprite
	{
		private var dataManager:IDataManager;
		
		private var textureManager:ITextureManager;
		
		private var obj:DatabaseObject;
		
		private var image:Image;
		
		private var bgr:Quad;
		
		public function LootItem(param1:String, param2:String, param3:int, param4:int = 12)
		{
			var _loc6_:TextBitmap = null;
			bgr = new Quad(230, 32, 1450513);
			super();
			dataManager = DataLocator.getService();
			textureManager = TextureLocator.getService();
			var _loc7_:Object = dataManager.loadKey(param1, param2);
			var _loc5_:String = "";
			if (param1 == "Weapons")
			{
				_loc5_ = _loc7_.techIcon;
			}
			else
			{
				_loc5_ = _loc7_.bitmap;
			}
			addChild(bgr);
			image = new Image(textureManager.getTextureGUIByKey(_loc5_));
			image.x = 16;
			image.y = 16;
			image.pivotX = Math.round(image.width / 2);
			image.pivotY = Math.round(image.height / 2);
			addChild(image);
			var _loc8_:TextBitmap = new TextBitmap(35, 8);
			_loc8_.text = _loc7_.name;
			_loc8_.format.color = 6710886;
			_loc8_.size = 12;
			addChild(_loc8_);
			if (param1 == "Weapons")
			{
				_loc8_.size = param4 + 4;
			}
			if (param1 != "Weapons")
			{
				_loc6_ = new TextBitmap(0, 5);
				_loc6_.text = param3.toString();
				_loc6_.format.color = 16777215;
				_loc6_.size = 16;
				_loc6_.alignRight();
				_loc6_.x = 220;
				addChild(_loc6_);
			}
		}
	}
}
