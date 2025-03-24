package core.hud.components.cargo {
	import core.hud.components.TextBitmap;
	import core.hud.components.ToolTip;
	import core.scene.SceneBase;
	import data.DataLocator;
	import data.IDataManager;
	import generics.Localize;
	import generics.Util;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class CargoItem extends Sprite {
		public static const STYLE_HUD:String = "hud";
		
		public static const STYLE_CARGO:String = "cargo";
		
		public var table:String;
		
		public var item:String;
		
		public var amount:int;
		
		public var type:String;
		
		private var dataManager:IDataManager;
		
		private var textureManager:ITextureManager;
		
		private var itemImage:Image;
		
		private var nameText:TextBitmap;
		
		private var quantityText:TextBitmap;
		
		public var itemName:String;
		
		private var toolTip:ToolTip;
		
		private var style:String;
		
		private var g:SceneBase;
		
		private var bgr:Quad;
		
		public function CargoItem(g:SceneBase, table:String, item:String, type:String, amount:int) {
			super();
			this.table = table;
			this.item = item;
			this.type = type;
			this.amount = amount;
			dataManager = DataLocator.getService();
			textureManager = TextureLocator.getService();
			var _local7:Object = dataManager.loadKey(table,item);
			itemName = Localize.t(_local7.name);
			bgr = new Quad(6 * 60,30,2233873);
			addChild(bgr);
			var _local6:Texture = textureManager.getTextureGUIByKey(_local7.bitmap);
			itemImage = new Image(_local6);
			itemImage.pivotX = Math.round(itemImage.width / 2);
			itemImage.pivotY = Math.round(itemImage.height / 2);
			addChild(itemImage);
			nameText = new TextBitmap(40,7);
			nameText.batchable = true;
			quantityText = new TextBitmap(0,0);
			quantityText.batchable = true;
			addChild(quantityText);
			toolTip = new ToolTip(g,itemImage,"");
		}
		
		private function load() : void {
			if(style == "cargo") {
				itemImage.y = 16;
				itemImage.x = 15;
				nameText.text = itemName;
				nameText.format.color = 0xaaaaaa;
				addChild(nameText);
				quantityText.text = Util.formatAmount(amount);
				quantityText.format.color = 0xaaaaaa;
				quantityText.x = 5 * 60;
				quantityText.y = nameText.y;
				bgr.visible = true;
				if(this.amount == 0) {
					this.alpha = 0.3;
				}
			} else if(style == "hud") {
				itemImage.x = 10;
				itemImage.y = 11 - itemImage.height / 12;
				quantityText.text = Util.formatAmount(amount);
				quantityText.x = 15;
				quantityText.y = 1;
				quantityText.format.color = 0xffffff;
				bgr.visible = false;
			}
			toolTip.text = itemName + ": <FONT COLOR=\'#ffffff\'>" + amount + "</FONT>";
		}
		
		public function draw(style:String = "cargo") : void {
			this.style = style;
			load();
		}
	}
}

