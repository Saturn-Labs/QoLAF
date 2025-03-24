package core.hud.components {
	import core.scene.SceneBase;
	import data.DataLocator;
	import data.IDataManager;
	import generics.Util;
	import starling.display.Image;
	import starling.display.Sprite;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class PriceCommodities extends Sprite {
		private static const THRESHHOLD:int = 10000;
		
		public var table:String;
		
		public var item:String;
		
		public var amount:int;
		
		public var type:String;
		
		private var dataManager:IDataManager;
		
		private var textureManager:ITextureManager;
		
		private var itemImage:Image;
		
		private var nameText:Text = new Text();
		
		private var quantityText:Text = new Text();
		
		private var color:uint;
		
		private var sb:SceneBase;
		
		public function PriceCommodities(sb:SceneBase, item:String, amount:int, font:String = "", size:int = -1) {
			super();
			this.sb = sb;
			this.table = "Commodities";
			this.item = item;
			this.amount = amount;
			if(size > -1) {
				nameText.size = size;
				quantityText.size = size;
			} else {
				nameText.size = 12;
				quantityText.size = 12;
			}
			if(font == "") {
				font = "Verdana";
			}
			if(font != "") {
				nameText.font = font;
				quantityText.font = font;
			}
			load();
		}
		
		public function canAfford() : Boolean {
			return sb.myCargo.hasCommodities(item,amount);
		}
		
		public function load() : void {
			if(sb.myCargo.hasCommodities(item,amount)) {
				color = Style.COLOR_VALID;
			} else {
				color = Style.COLOR_INVALID;
			}
			dataManager = DataLocator.getService();
			textureManager = TextureLocator.getService();
			var _local1:Object = dataManager.loadKey(table,item);
			itemImage = new Image(textureManager.getTextureGUIByKey(_local1.bitmap));
			itemImage.y = 3;
			nameText.text = _local1.name + " " + Util.formatAmount(amount);
			nameText.x = 20;
			nameText.color = color;
			quantityText.text = "(" + Util.formatAmount(sb.myCargo.getCommoditiesAmount(item)) + ")";
			quantityText.x = nameText.x + nameText.width + 6;
			quantityText.color = 0xaaaaaa;
			addChild(itemImage);
			addChild(nameText);
			addChild(quantityText);
		}
	}
}

