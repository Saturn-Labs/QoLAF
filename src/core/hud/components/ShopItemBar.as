package core.hud.components
{
	import com.greensock.TweenMax;
	import core.hud.components.dialogs.CreditBuyBox;
	import core.scene.Game;
	import data.DataLocator;
	import data.IDataManager;
	import debug.Console;
	import generics.Localize;
	import playerio.Message;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import textures.ITextureManager;
	import textures.TextureLocator;

	public class ShopItemBar extends Sprite
	{
		private static var SPECIAL_WEAPON_BLOOD_CLAW:String = "P6XvSQpMr0q7kQUsjeHvwQ";
		private static var SPECIAL_WEAPON_X27S:String = "w3-ZtQ-y_kiefCpnvFo88A";
		private static var SPECIAL_WEAPON_SPORE:String = "nRRv5U5g30adeYN9X2C78Q";
		private var priceItems:Vector.<PriceCommodities>;

		private var dataManager:IDataManager;
		private var textureManager:ITextureManager;
		private var buyObj:Object;
		private var alreadyAquiredText:TextBitmap;
		private var buyButton:Button;
		private var buyWithFluxButton:Button;
		private var confirmBuyWithFlux:CreditBuyBox;
		private var nameText:TextBitmap;
		private var weaponIcon:Image;
		private var g:Game;
		private var _canAfford:Boolean = true;
		private var _hasItem:Boolean = false;
		private var infoContainer:Sprite;
		private var selectContainer:Sprite;
		private var selectQuad:Quad;
		private var selected:Boolean = false;
		private var hover:Boolean = false;
		private var table:String;
		private var key:String;
		private var orText:TextBitmap;
		private var fluxCost:int;
		public function ShopItemBar(param1:Game, param2:Sprite, param3:Object, param4:int)
		{
			var table:String;
			var item:String;
			var obj:Object;
			var array:Array;
			var i:int;
			var h:Number;
			var specialWeapon:Boolean;
			var t:TextField;
			var troonImg:Image;
			var priceItemItem:String;
			var priceItemAmount:int;
			var priceItem:PriceCommodities;
			var g:Game = param1;
			var parent:Sprite = param2;
			var shopItem:Object = param3;
			var fluxCost:int = param4;
			alreadyAquiredText = new TextBitmap(0, 0, "font13");
			infoContainer = new Sprite();
			selectContainer = new Sprite();
			selectQuad = new Quad(100, 100);
			super();
			this.g = g;
			this.fluxCost = fluxCost;
			table = shopItem.table;
			item = shopItem.item;
			dataManager = DataLocator.getService();
			textureManager = TextureLocator.getService();
			priceItems = new Vector.<PriceCommodities>();
			infoContainer.visible = false;
			parent.addChild(infoContainer);
			selectContainer.addChild(selectQuad);
			addChild(selectContainer);
			addEventListener("touch", onTouch);
			drawSelectContainer();
			obj = dataManager.loadKey(table, item);
			buyObj = obj;
			this.table = table;
			this.key = item;
			weaponIcon = new Image(textureManager.getTextureGUIByKey(obj.techIcon));
			weaponIcon.x = 5;
			weaponIcon.y = 5;
			selectContainer.addChild(weaponIcon);
			nameText = new TextBitmap(0, 0, "font13");
			nameText.format.color = 11184810;
			nameText.text = obj.name;
			nameText.size = 14;
			nameText.y = weaponIcon.y + weaponIcon.height / 2 - nameText.height / 2;
			nameText.x = weaponIcon.x + weaponIcon.width + 10;
			selectContainer.addChild(nameText);
			array = shopItem.priceItems;
			i = 0;
			buyButton = new Button(function():void
				{
					g.rpc("buy", bought, table, item);
				}, Localize.t("Produce"), "positive");
			buyButton.x = 0;
			buyButton.y = 0;
			alreadyAquiredText.text = Localize.t("Aquired!");
			alreadyAquiredText.format.color = 4521796;
			alreadyAquiredText.size = 10;
			infoContainer.addChild(alreadyAquiredText);
			infoContainer.addChild(buyButton);
			canAfford = true;
			h = 0;
			specialWeapon = false;
			if (obj.key == SPECIAL_WEAPON_BLOOD_CLAW || obj.key == SPECIAL_WEAPON_X27S || obj.key == SPECIAL_WEAPON_SPORE)
			{
				t = new TextField(infoContainer.width, 15, "", new TextFormat("DAIDRR", 13, 11184810));
				t.y = 40;
				t.isHtmlText = true;
				if (obj.key == SPECIAL_WEAPON_BLOOD_CLAW && g.me.troons < 85000)
				{
					t.text = "<FONT COLOR='#FFFF44'>85 000</FONT> (" + g.me.troons + ")";
					canAfford = false;
				}
				if (obj.key == SPECIAL_WEAPON_SPORE && g.me.troons < 150000)
				{
					t.text = "<FONT COLOR='#FFFF44'>150 000</FONT> (" + g.me.troons + ")";
					canAfford = false;
				}
				if (obj.key == SPECIAL_WEAPON_X27S && g.me.troons < 350000)
				{
					t.text = "<FONT COLOR='#FFFF44'>350 000</FONT> (" + g.me.troons + ")";
					canAfford = false;
				}
				specialWeapon = true;
				infoContainer.addChild(t);
				troonImg = new Image(textureManager.getTextureGUIByTextureName("troon.png"));
				troonImg.x = t.x + t.width + 5;
				troonImg.y = t.y - 5;
				infoContainer.addChild(troonImg);
				h = 40;
			}
			else
			{
				i = 0;
				while (i < array.length)
				{
					priceItemItem = array[i].item;
					priceItemAmount = int(array[i].amount);
					if (!g.myCargo.hasCommodities(priceItemItem, priceItemAmount))
					{
						canAfford = false;
					}
					priceItem = new PriceCommodities(g, priceItemItem, priceItemAmount);
					priceItem.x = 0;
					priceItem.y = buyButton.y + buyButton.height + 10 + i * 20;
					priceItems.push(priceItem);
					infoContainer.addChild(priceItem);
					h = Math.max(priceItem.y, h);
					i++;
				}
			}
			orText = new TextBitmap(0, 0, "font13");
			orText.text = Localize.t("or").toLowerCase();
			orText.x = buyButton.width + 10;
			orText.y = buyButton.y + 5;
			orText.visible = !specialWeapon;
			infoContainer.addChild(orText);
			buyWithFluxButton = new Button(function():void
				{
					g.creditManager.refresh(function():void
						{
							confirmBuyWithFlux = new CreditBuyBox(g, fluxCost, Localize.t("Are you sure you want to buy the [name]?").replace("[name]", obj.name));
							g.addChildToOverlay(confirmBuyWithFlux);
							confirmBuyWithFlux.addEventListener("accept", onAccept);
							confirmBuyWithFlux.addEventListener("close", onClose);
						});
				}, Localize.t("Buy for [flux] Flux").replace("[flux]", fluxCost), "highlight");
			buyWithFluxButton.y = buyButton.y;
			buyWithFluxButton.x = orText.x + orText.width + 10;
			buyWithFluxButton.visible = !specialWeapon;
			infoContainer.addChild(buyWithFluxButton);
			hasItem = g.me.hasTechSkill(table, item);
			addDescription(obj);
			this.addEventListener("removedFromStage", clean);
		}

		private function onAccept(param1:Event):void
		{
			g.rpc("buyWeaponWithFlux", boughtWeaponWithFlux, key, table);
			confirmBuyWithFlux.removeEventListener("accept", onAccept);
			confirmBuyWithFlux.removeEventListener("close", onClose);
		}

		private function boughtWeaponWithFlux(param1:Message):void
		{
			if (param1.getBoolean(0))
			{
				g.me.addTechSkill(buyObj.name, table, key);
				Console.write("Bought Weapon: " + key, param1);
				hasItem = true;
				this.dispatchEvent(new Event("bought"));
				animate();
				g.creditManager.refresh();
			}
			else
			{
				buyWithFluxButton.enabled = true;
				if (param1.length > 1)
				{
					g.showErrorDialog(param1.getString(1));
				}
			}
		}

		private function onClose(param1:Event):void
		{
			confirmBuyWithFlux.removeEventListener("accept", onAccept);
			confirmBuyWithFlux.removeEventListener("close", onClose);
			buyWithFluxButton.enabled = true;
		}

		private function addDescription(param1:Object):void
		{
			var _loc2_:ShopItemBarStats = new ShopItemBarStats(param1);
			_loc2_.y = buyButton.y + buyButton.height;
			infoContainer.addChild(_loc2_);
		}

		public function update():void
		{
			for each (var _loc1_:* in priceItems)
			{
				_loc1_.load();
			}
		}

		private function bought(param1:Message):void
		{
			if (param1.getBoolean(0))
			{
				hasItem = true;
				g.me.addTechSkill(buyObj.name, table, key);
				for each (var _loc2_:* in priceItems)
				{
					g.myCargo.removeMinerals(_loc2_.item, _loc2_.amount);
				}
				this.dispatchEvent(new Event("bought"));
				animate();
			}
		}

		private function animate():void
		{
			var soundManager:ISound = SoundLocator.getService();
			soundManager.preCacheSound("7zeIcPFb-UWzgtR_3nrZ8Q", function():void
				{
					TweenMax.from(alreadyAquiredText, 1, {
								"scaleX": 8,
								"scaleY": 8,
								"alpha": 0
							});
					TweenMax.from(weaponIcon, 1, {
								"scaleX": 8,
								"scaleY": 8,
								"alpha": 0
							});
					soundManager.play("7zeIcPFb-UWzgtR_3nrZ8Q");
				});
		}

		private function set hasItem(param1:Boolean):void
		{
			alreadyAquiredText.visible = param1;
			buyButton.visible = !param1;
			buyWithFluxButton.visible = !param1;
			orText.visible = !param1;
			_hasItem = param1;
			enabled = param1 ? false : _canAfford;
			if (buyObj.key == SPECIAL_WEAPON_BLOOD_CLAW || buyObj.key == SPECIAL_WEAPON_X27S || buyObj.key == SPECIAL_WEAPON_SPORE)
			{
				orText.visible = false;
				buyWithFluxButton.visible = false;
			}
		}

		private function set canAfford(param1:Boolean):void
		{
			_canAfford = param1;
			enabled = _hasItem ? false : param1;
		}

		private function set enabled(param1:Boolean):void
		{
			buyButton.enabled = param1;
		}

		private function showInfo(param1:Boolean):void
		{
			infoContainer.visible = param1;
		}

		public function deselect():void
		{
			selected = false;
			drawSelectContainer();
			showInfo(selected);
		}

		private function click(param1:TouchEvent):void
		{
			param1.stopPropagation();
			selected = selected ? false : true;
			var _loc2_:ISound = SoundLocator.getService();
			_loc2_.play("3hVYqbNNSUWoDGk_pK1BdQ");
			drawSelectContainer();
			showInfo(selected);
			dispatchEvent(new TouchEvent("select", param1.touches));
		}

		private function drawSelectContainer():void
		{
			selectQuad.width = 300;
			selectQuad.height = 50;
			if (hover && !selected)
			{
				selectQuad.color = 6719743;
				selectQuad.alpha = 0.1;
			}
			else if (!selected)
			{
				selectQuad.color = 0;
				selectQuad.alpha = 0.5;
			}
			else
			{
				selectQuad.color = 6719743;
				selectQuad.alpha = 0.3;
			}
		}

		private function mOut(param1:TouchEvent):void
		{
			hover = false;
			drawSelectContainer();
		}

		private function mOver(param1:TouchEvent):void
		{
			hover = true;
			drawSelectContainer();
		}

		private function onTouch(param1:TouchEvent):void
		{
			if (param1.getTouch(this, "ended"))
			{
				click(param1);
			}
			else if (param1.interactsWith(this))
			{
				mOver(param1);
			}
			else if (!param1.interactsWith(this))
			{
				mOut(param1);
			}
		}

		private function clean(param1:Event = null):void
		{
			removeEventListener("removedFromStage", clean);
			removeEventListener("touch", onTouch);
			dispose();
		}
	}
}
