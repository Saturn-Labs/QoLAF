package core.hud.components {
	import data.DataLocator;
	import data.IDataManager;
	import playerio.DatabaseObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class LootItem extends Sprite {
		private var dataManager:IDataManager;
		
		private var textureManager:ITextureManager;
		
		private var obj:DatabaseObject;
		
		private var image:Image;
		
		private var bgr:Quad;
		
		public function LootItem(table:String, item:String, amount:int, size:int = 12) {
			var _local6:TextBitmap = null;
			bgr = new Quad(230,32,1450513);
			super();
			dataManager = DataLocator.getService();
			textureManager = TextureLocator.getService();
			var _local7:Object = dataManager.loadKey(table,item);
			var _local8:String = "";
			if(table == "Weapons") {
				_local8 = _local7.techIcon;
			} else {
				_local8 = _local7.bitmap;
			}
			addChild(bgr);
			image = new Image(textureManager.getTextureGUIByKey(_local8));
			image.x = 16;
			image.y = 16;
			image.pivotX = Math.round(image.width / 2);
			image.pivotY = Math.round(image.height / 2);
			addChild(image);
			var _local5:TextBitmap = new TextBitmap(35,8);
			_local5.text = _local7.name;
			_local5.format.color = 0x666666;
			_local5.size = 12;
			addChild(_local5);
			if(table == "Weapons") {
				_local5.size = size + 4;
			}
			if(table != "Weapons") {
				_local6 = new TextBitmap(0,5);
				_local6.text = amount.toString();
				_local6.format.color = 0xffffff;
				_local6.size = 16;
				_local6.alignRight();
				_local6.x = 220;
				addChild(_local6);
			}
		}
	}
}

