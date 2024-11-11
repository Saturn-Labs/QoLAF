package core.hud.components
{
	import core.scene.SceneBase;
	import data.DataLocator;
	import data.IDataManager;
	import generics.Util;
	import starling.display.Image;
	import starling.display.Sprite;
	import textures.ITextureManager;
	import textures.TextureLocator;

	public class PriceCommodities extends Sprite
	{
		private static const THRESHHOLD:int = 10000;

		public var table:String;
		public var item:String;
		public var amount:int;
		public var type:String;
		private var dataManager:IDataManager;
		private var textureManager:ITextureManager;
		private var itemImage:Image;
		private var nameText:Text;
		private var quantityText:Text;
		private var color:uint;
		private var sb:SceneBase;
		public function PriceCommodities(param1:SceneBase, param2:String, param3:int, param4:String = "", param5:int = -1)
		{
			nameText = new Text();
			quantityText = new Text();
			super();
			this.sb = param1;
			this.table = "Commodities";
			this.item = param2;
			this.amount = param3;
			if (param5 > -1)
			{
				nameText.size = param5;
				quantityText.size = param5;
			}
			else
			{
				nameText.size = 12;
				quantityText.size = 12;
			}
			if (param4 == "")
			{
				param4 = "Verdana";
			}
			if (param4 != "")
			{
				nameText.font = param4;
				quantityText.font = param4;
			}
			load();
		}

		public function canAfford():Boolean
		{
			return sb.myCargo.hasCommodities(item, amount);
		}

		public function load():void
		{
			if (sb.myCargo.hasCommodities(item, amount))
			{
				color = Style.COLOR_VALID;
			}
			else
			{
				color = Style.COLOR_INVALID;
			}
			dataManager = DataLocator.getService();
			textureManager = TextureLocator.getService();
			var _loc1_:Object = dataManager.loadKey(table, item);
			itemImage = new Image(textureManager.getTextureGUIByKey(_loc1_.bitmap));
			itemImage.y = 3;
			nameText.text = _loc1_.name + " " + Util.formatAmount(amount);
			nameText.x = 20;
			nameText.color = color;
			quantityText.text = "(" + Util.formatAmount(sb.myCargo.getCommoditiesAmount(item)) + ")";
			quantityText.x = nameText.x + nameText.width + 6;
			quantityText.color = 11184810;
			addChild(itemImage);
			addChild(nameText);
			addChild(quantityText);
		}
	}
}
