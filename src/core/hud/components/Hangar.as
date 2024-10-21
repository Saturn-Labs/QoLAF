package core.hud.components
{
	import core.hud.components.hangar.SkinItem;
	import core.player.FleetObj;
	import core.scene.Game;
	import core.ship.ShipFactory;
	import core.solarSystem.Body;
	import feathers.controls.List;
	import feathers.controls.ScrollContainer;
	import feathers.data.ListCollection;
	import generics.Localize;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.filters.ColorMatrixFilter;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class Hangar extends Sprite
	{
		private var textureManager:ITextureManager;
		
		private var selectedItemContainer:ScrollContainer;
		
		private var g:Game;
		
		private var body:Body;
		
		private var mode:int;
		
		private const MODE_SHOP:int = 1;
		
		private const MODE_SWITCH_SKIN:int = 2;
		
		private var skins:Array;
		
		private var skinsItems:Array;
		
		private var list:List;
		
		public function Hangar(param1:Game, param2:Body = null)
		{
			selectedItemContainer = new ScrollContainer();
			skins = [];
			list = new List();
			super();
			this.g = param1;
			this.body = param2;
			if (param2 == null)
			{
				mode = 2;
			}
			else
			{
				mode = 1;
			}
			textureManager = TextureLocator.getService();
			var _loc3_:Text = new Text();
			_loc3_.size = 36;
			mode == 1 ? (_loc3_.text = Localize.t("Hangar")) : (_loc3_.text = Localize.t("Fleet"));
			_loc3_.y = 60;
			_loc3_.x = 60;
			addChild(_loc3_);
			selectedItemContainer.x = 330;
			selectedItemContainer.y = 50;
			selectedItemContainer.width = 390;
			selectedItemContainer.height = 500;
			addChild(selectedItemContainer);
			drawMenu();
		}
		
		private function drawMenu():void
		{
			var s:Object;
			var f:FleetObj;
			var keys:Array;
			var skin:Object;
			var array:Array;
			var obj:Object;
			var emptySlot:Object;
			if (mode == 1)
			{
				for each (s in body.obj.shopItems)
				{
					if (s.available)
					{
						skins.push(s.item);
					}
				}
			}
			else if (mode == 2)
			{
				g.me.fleet.sort(function(param1:FleetObj, param2:FleetObj):int
				{
					if (param1.lastUsed > param2.lastUsed)
					{
						return 1;
					}
					return -1;
				});
				for each (f in g.me.fleet)
				{
					skins.push(f.skin);
				}
				skins.reverse();
			}
			skinsItems = g.dataManager.loadKeys("Skins", skins);
			keys = [];
			for each (skin in skinsItems)
			{
				if (skin.payVaultItem != null)
				{
					keys.push(skin.payVaultItem);
				}
			}
			if (mode == 1)
			{
				array = g.dataManager.loadKeys("PayVaultItems", keys);
				for each (obj in array)
				{
					if (obj != null)
					{
						for each (skin in skinsItems)
						{
							if (skin.payVaultItem == obj.key)
							{
								skin.price = obj.PriceCoins;
								if (g.salesManager.isSkinSale(skin.key))
								{
									skin.salePrice = g.salesManager.getSkinSale(skin.key).salePrice;
								}
							}
						}
					}
				}
				skinsItems.sortOn("price", 16);
				drawList();
			}
			else if (mode == 2)
			{
				if (skinsItems.length == 1)
				{
					emptySlot = {"name": Localize.t("Empty Slot"), "emptySlot": true, "ship": skinsItems[0].ship};
					skinsItems.push(emptySlot);
				}
				drawList();
			}
		}
		
		private function drawList():void
		{
			var _loc11_:int = 0;
			var _loc10_:Object = null;
			var _loc6_:FleetObj = null;
			var _loc8_:Object = null;
			var _loc7_:Object = null;
			var _loc2_:Sprite = null;
			var _loc5_:Image = null;
			var _loc9_:int = 0;
			var _loc3_:Quad = null;
			var _loc1_:ColorMatrixFilter = null;
			_loc11_ = 0;
			while (_loc11_ < skinsItems.length)
			{
				_loc10_ = skinsItems[_loc11_];
				_loc6_ = g.me.getFleetObj(_loc10_.key);
				_loc8_ = g.dataManager.loadKey("Ships", _loc10_.ship);
				_loc7_ = g.dataManager.loadKey("Images", _loc8_.bitmap);
				_loc2_ = new Sprite();
				_loc5_ = new Image(textureManager.getTextureMainByTextureName(_loc7_.textureName + "1"));
				_loc9_ = _loc5_.height % 2 == 0 ? _loc5_.height : _loc5_.height + 1;
				_loc3_ = new Quad(40, _loc9_, 0);
				_loc3_.alpha = 0;
				if (_loc10_.emptySlot)
				{
					_loc1_ = new ColorMatrixFilter();
					_loc1_.adjustSaturation(-1);
					_loc1_.adjustBrightness(-0.35);
					_loc1_.adjustHue(0.75);
					_loc5_.filter = _loc1_;
					_loc5_.filter.cache();
				}
				if (mode == 2 && !_loc10_.emptySlot)
				{
					_loc5_.filter = ShipFactory.createPlayerShipColorMatrixFilter(_loc6_);
				}
				_loc2_.addChild(_loc3_);
				_loc2_.addChild(_loc5_);
				_loc10_.icon = _loc2_;
				_loc11_++;
			}
			var _loc4_:ListCollection = new ListCollection(skinsItems);
			list.width = 270;
			list.height = 400;
			list.y = 140;
			list.x = 50;
			list.styleNameList.add("shop");
			addChild(list);
			list.dataProvider = _loc4_;
			list.itemRendererProperties.labelField = "name";
			list.addEventListener("change", onSelect);
			setSelectedItem();
		}
		
		private function setSelectedItem():void
		{
			var _loc1_:* = null;
			if (mode == 1)
			{
				_loc1_ = skinsItems.length > 0 ? skinsItems[0] : null;
			}
			else if (mode == 2)
			{
				for each (var _loc2_:* in skinsItems)
				{
					if (_loc2_.key == g.me.activeSkin)
					{
						_loc1_ = _loc2_;
						break;
					}
				}
			}
			if (_loc1_)
			{
				list.selectedItem = _loc1_;
			}
		}
		
		private function onSelect(param1:Event):void
		{
			var _loc3_:Sprite = null;
			var _loc2_:Text = null;
			var _loc4_:List = List(param1.currentTarget);
			selectedItemContainer.removeChildren(0, -1, true);
			var _loc5_:int = 0;
			if (mode == 1)
			{
				_loc5_ = 1;
			}
			if (_loc4_.selectedItem.emptySlot)
			{
				_loc3_ = new Sprite();
				_loc2_ = new Text(15, 110);
				_loc2_.text = Localize.t("Visit the hangar to get more ships.");
				_loc2_.size = 14;
				_loc2_.width = 370;
				_loc3_.addChild(_loc2_);
				selectedItemContainer.addChild(_loc3_);
			}
			else
			{
				selectedItemContainer.addChild(new SkinItem(g, _loc4_.selectedItem, _loc5_));
			}
		}
	}
}
