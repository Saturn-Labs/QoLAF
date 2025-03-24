package core.hud.components {
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
	
	public class Hangar extends Sprite {
		private var textureManager:ITextureManager;
		
		private var selectedItemContainer:ScrollContainer = new ScrollContainer();
		
		private var g:Game;
		
		private var body:Body;
		
		private var mode:int;
		
		private const MODE_SHOP:int = 1;
		
		private const MODE_SWITCH_SKIN:int = 2;
		
		private var skins:Array = [];
		
		private var skinsItems:Array;
		
		private var list:List = new List();
		
		public function Hangar(g:Game, body:Body = null) {
			super();
			this.g = g;
			this.body = body;
			if(body == null) {
				mode = 2;
			} else {
				mode = 1;
			}
			textureManager = TextureLocator.getService();
			var _local3:Text = new Text();
			_local3.size = 36;
			mode == 1 ? (_local3.text = Localize.t("Hangar")) : (_local3.text = Localize.t("Fleet"));
			_local3.y = 60;
			_local3.x = 60;
			addChild(_local3);
			selectedItemContainer.x = 330;
			selectedItemContainer.y = 50;
			selectedItemContainer.width = 390;
			selectedItemContainer.height = 500;
			addChild(selectedItemContainer);
			drawMenu();
		}
		
		private function drawMenu() : void {
			var s:Object;
			var f:FleetObj;
			var keys:Array;
			var skin:Object;
			var array:Array;
			var obj:Object;
			var emptySlot:Object;
			if(mode == 1) {
				for each(s in body.obj.shopItems) {
					if(s.available) {
						skins.push(s.item);
					}
				}
			} else if(mode == 2) {
				g.me.fleet.sort(function(param1:FleetObj, param2:FleetObj):int {
					if(param1.lastUsed > param2.lastUsed) {
						return 1;
					}
					return -1;
				});
				for each(f in g.me.fleet) {
					skins.push(f.skin);
				}
				skins.reverse();
			}
			skinsItems = g.dataManager.loadKeys("Skins",skins);
			keys = [];
			for each(skin in skinsItems) {
				if(skin.payVaultItem != null) {
					keys.push(skin.payVaultItem);
				}
			}
			if(mode == 1) {
				array = g.dataManager.loadKeys("PayVaultItems",keys);
				for each(obj in array) {
					if(obj != null) {
						for each(skin in skinsItems) {
							if(skin.payVaultItem == obj.key) {
								skin.price = obj.PriceCoins;
								if(g.salesManager.isSkinSale(skin.key)) {
									skin.salePrice = g.salesManager.getSkinSale(skin.key).salePrice;
								}
							}
						}
					}
				}
				skinsItems.sortOn("price",16);
				drawList();
			} else if(mode == 2) {
				if(skinsItems.length == 1) {
					emptySlot = {
						"name":Localize.t("Empty Slot"),
						"emptySlot":true,
						"ship":skinsItems[0].ship
					};
					skinsItems.push(emptySlot);
				}
				drawList();
			}
		}
		
		private function drawList() : void {
			var _local7:int = 0;
			var _local4:Object = null;
			var _local10:FleetObj = null;
			var _local8:Object = null;
			var _local11:Object = null;
			var _local5:Sprite = null;
			var _local2:Image = null;
			var _local6:int = 0;
			var _local1:Quad = null;
			var _local9:ColorMatrixFilter = null;
			_local7 = 0;
			while(_local7 < skinsItems.length) {
				_local4 = skinsItems[_local7];
				_local10 = g.me.getFleetObj(_local4.key);
				_local8 = g.dataManager.loadKey("Ships",_local4.ship);
				_local11 = g.dataManager.loadKey("Images",_local8.bitmap);
				_local5 = new Sprite();
				_local2 = new Image(textureManager.getTextureMainByTextureName(_local11.textureName + "1"));
				_local6 = _local2.height % 2 == 0 ? _local2.height : _local2.height + 1;
				_local1 = new Quad(40,_local6,0);
				_local1.alpha = 0;
				if(_local4.emptySlot) {
					_local9 = new ColorMatrixFilter();
					_local9.adjustSaturation(-1);
					_local9.adjustBrightness(-0.35);
					_local9.adjustHue(0.75);
					_local2.filter = _local9;
					_local2.filter.cache();
				}
				if(mode == 2 && !_local4.emptySlot) {
					_local2.filter = ShipFactory.createPlayerShipColorMatrixFilter(_local10);
				}
				_local5.addChild(_local1);
				_local5.addChild(_local2);
				_local4.icon = _local5;
				_local7++;
			}
			var _local3:ListCollection = new ListCollection(skinsItems);
			list.width = 270;
			list.height = 400;
			list.y = 140;
			list.x = 50;
			list.styleNameList.add("shop");
			addChild(list);
			list.dataProvider = _local3;
			list.itemRendererProperties.labelField = "name";
			list.addEventListener("change",onSelect);
			setSelectedItem();
		}
		
		private function setSelectedItem() : void {
			var _local1:* = null;
			if(mode == 1) {
				_local1 = skinsItems.length > 0 ? skinsItems[0] : null;
			} else if(mode == 2) {
				for each(var _local2 in skinsItems) {
					if(_local2.key == g.me.activeSkin) {
						_local1 = _local2;
						break;
					}
				}
			}
			if(_local1) {
				list.selectedItem = _local1;
			}
		}
		
		private function onSelect(event:Event) : void {
			var _local2:Sprite = null;
			var _local3:Text = null;
			var _local4:List = List(event.currentTarget);
			selectedItemContainer.removeChildren(0,-1,true);
			var _local5:int = 0;
			if(mode == 1) {
				_local5 = 1;
			}
			if(_local4.selectedItem.emptySlot) {
				_local2 = new Sprite();
				_local3 = new Text(15,110);
				_local3.text = Localize.t("Visit the hangar to get more ships.");
				_local3.size = 14;
				_local3.width = 370;
				_local2.addChild(_local3);
				selectedItemContainer.addChild(_local2);
			} else {
				selectedItemContainer.addChild(new SkinItem(g,_local4.selectedItem,_local5));
			}
		}
	}
}

