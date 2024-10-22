package core.hud.components.credits
{
	import core.credits.Sale;
	import core.hud.components.Box;
	import core.hud.components.Button;
	import core.hud.components.NativeImageButton;
	import core.hud.components.SaleSticker;
	import core.hud.components.SaleTimer;
	import core.hud.components.TextBitmap;
	import core.hud.components.dialogs.PopupMessage;
	import core.scene.Game;
	import debug.Console;
	import embeds.BuyButtonBitmap;
	import embeds.GetFluxNowButtonBitmap;
	import facebook.FB;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import generics.Localize;
	import playerio.PayVault;
	import playerio.PlayerIOError;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import textures.ITextureManager;
	import textures.TextureLocator;

	public class BuyFlux extends starling.display.Sprite
	{
		private var g:Game;

		private var textureManager:ITextureManager;

		private var bgrQuad:Quad;

		private var bundles:Array;

		private var box:Box;

		private var textLayer:starling.display.Sprite;

		private var buttonLayer:starling.display.Sprite;

		private var nativeLayer:flash.display.Sprite;

		private const DARK_GREY:uint = 2302755;

		private const LIGHT_GREY:uint = 5131854;

		private const GREEN:uint = 4718367;

		private const YELLOW:uint = 15582483;

		private const GOLD:uint = 15526144;

		private var BuyButtonAsset:Class;

		private var GetFluxNowButtonAsset:Class;

		public var sale:Boolean = false;

		public var saleMultiplier:Number = 2;

		public var saleDesc:String = "";

		public var saleEvent:Sale;

		public var bgWidth:int;

		public function BuyFlux(param1:Game)
		{
			var i:int;
			var h:int;
			var close:Button;
			var description:Array;
			var saleSticker:SaleSticker;
			var saleTimer:SaleTimer;
			var g:Game = param1;
			bgrQuad = new Quad(100, 100, 2852126720);
			bundles = [];
			textLayer = new starling.display.Sprite();
			buttonLayer = new starling.display.Sprite();
			nativeLayer = new flash.display.Sprite();
			BuyButtonAsset = embeds.BuyButtonBitmap;
			GetFluxNowButtonAsset = embeds.GetFluxNowButtonBitmap;
			super();
			this.g = g;
			sale = g.salesManager.isFluxSale();
			if (sale)
			{
				saleEvent = g.salesManager.getFluxSale();
				if (saleEvent != null)
				{
					saleMultiplier = (100 + saleEvent.saleBonus) / 100;
					saleDesc = saleEvent.description;
				}
				else
				{
					saleMultiplier = 1;
				}
			}
			textureManager = TextureLocator.getService();
			if (Login.currentState == "facebook")
			{
				bundles.push( {
							"amount": 8500,
							"price": "$50",
							"bonus": 3500,
							"bonusLabel": Localize.t("Best Value!"),
							"size": 26
						});
				bundles.push( {
							"amount": 5600,
							"price": "$35",
							"bonus": 2100,
							"size": 24
						});
				bundles.push( {
							"amount": 3000,
							"price": "$20",
							"bonus": 1000,
							"bonusLabel": Localize.t("Most Popular!"),
							"size": 22
						});
				bundles.push( {
							"amount": 1100,
							"price": "$10",
							"bonus": 100,
							"size": 20
						});
				bundles.push( {
							"amount": 500,
							"price": "$5",
							"size": 18
						});
				bundles.push( {
							"amount": 100,
							"type": "fb"
						});
				bundles.push( {
							"amount": 100,
							"type": "invite"
						});
			}
			else if (Login.currentState == "steam")
			{
				bundles.push( {
							"amount": 8500,
							"price": "$50",
							"bonus": 3500,
							"bonusLabel": Localize.t("Best Value!"),
							"size": 26
						});
				bundles.push( {
							"amount": 5600,
							"price": "$35",
							"bonus": 2100,
							"size": 24
						});
				bundles.push( {
							"amount": 3000,
							"price": "$20",
							"bonus": 1000,
							"bonusLabel": Localize.t("Most Popular!"),
							"size": 22
						});
				bundles.push( {
							"amount": 1100,
							"price": "$10",
							"bonus": 100,
							"size": 20
						});
				bundles.push( {
							"amount": 500,
							"price": "$5",
							"size": 18
						});
			}
			else if (Login.currentState == "kongregate")
			{
				bundles.push( {
							"amount": 8500,
							"price": "500",
							"image": "kred",
							"bonus": 3500,
							"bonusLabel": Localize.t("Best Value!"),
							"size": 26
						});
				bundles.push( {
							"amount": 5600,
							"price": "350",
							"image": "kred",
							"bonus": 2100,
							"size": 24
						});
				bundles.push( {
							"amount": 3000,
							"price": "200",
							"image": "kred",
							"bonus": 1000,
							"bonusLabel": Localize.t("Most Popular!"),
							"size": 22
						});
				bundles.push( {
							"amount": 1100,
							"price": "100",
							"image": "kred",
							"bonus": 100,
							"size": 20
						});
				bundles.push( {
							"amount": 500,
							"price": "50",
							"image": "kred",
							"size": 18
						});
			}
			else
			{
				bundles.push( {
							"amount": 8500,
							"price": "$50",
							"bonus": 3500,
							"bonusLabel": Localize.t("Best Value!"),
							"size": 26
						});
				bundles.push( {
							"amount": 5600,
							"price": "$35",
							"bonus": 2100,
							"size": 24
						});
				bundles.push( {
							"amount": 3000,
							"price": "$20",
							"bonus": 1000,
							"bonusLabel": Localize.t("Most Popular!"),
							"size": 22
						});
				bundles.push( {
							"amount": 1100,
							"price": "$10",
							"bonus": 100,
							"size": 20
						});
				bundles.push( {
							"amount": 500,
							"price": "$5",
							"size": 18
						});
			}
			i = 0;
			while (i < bundles.length)
			{
				addBundle(bundles[i], i);
				i++;
			}
			bgWidth = sale ? 640 : textLayer.width;
			addPaymentInfo();
			addSuperRewards();
			h = nativeLayer.height > textLayer.height ? nativeLayer.height : textLayer.height;
			h += 40;
			box = new Box(bgWidth, h, "highlight", 1, 20);
			close = new Button(function():void
				{
					onClose();
					dispatchClose();
				}, "close");
			close.x = bgWidth - close.width;
			close.y = Math.round(h - close.height / 2 - 20);
			buttonLayer.addChild(close);
			if (sale)
			{
				description = saleDesc.split("|");
				saleSticker = new SaleSticker(description[1], description[2], description[0]);
				saleSticker.x = box.width - 120;
				saleSticker.y = box.y + 40;
				box.addChild(saleSticker);
				saleTimer = new SaleTimer(g, saleEvent.startTime, saleEvent.endTime, onClose);
				saleTimer.x = saleSticker.x - saleTimer.width / 2;
				saleTimer.y = 190;
				box.addChild(saleTimer);
			}
			addChild(bgrQuad);
			addChild(box);
			box.addChild(textLayer);
			box.addChild(buttonLayer);
			Starling.current.nativeStage.addChild(nativeLayer);
			g.addResizeListener(redraw);
			redraw();
			Game.trackPageView("viewbuyflux");
		}

		private function addBundle(param1:Object, param2:int):void
		{
			var fluxIcon:Image;
			var size:Number;
			var amount:TextBitmap;
			var invButton:FBInvite;
			var crossOver:Image;
			var price:TextBitmap;
			var img:Image;
			var bonus:TextBitmap;
			var bonusLabel:TextBitmap;
			var label:TextBitmap;
			var status:TextBitmap;
			var bitmap:Bitmap;
			var button:NativeImageButton;
			var obj:Object = param1;
			var i:int = param2;
			var boxWidth:int = sale ? 450 : 400;
			var bg:Box = new Box(boxWidth, 25, "light", 1, 10);
			bg.x = 10;
			bg.y = 10 + 62 * i;
			fluxIcon = new Image(textureManager.getTextureGUIByTextureName("credit_medium"));
			fluxIcon.color = 15526144;
			fluxIcon.scaleX = fluxIcon.scaleY = 0.6;
			bg.addChild(fluxIcon);
			size = Number(!!obj.size ? obj.size : 14);
			if (obj.type && obj.type == "invite")
			{
				amount = new TextBitmap(50, 0, obj.amount + " " + Localize.t("Flux on Accept"), 14);
				bg.addChild(amount);
				amount = new TextBitmap(49, 14, obj.amount + " " + Localize.t("extra Flux at lvl 10"), 14);
				amount.format.color = 15582483;
				bg.addChild(amount);
				if (Login.currentState == "facebook")
				{
					invButton = new FBInvite(g);
					invButton.x = 260;
					invButton.y = bg.y;
					invButton.width = 150;
					buttonLayer.addChild(invButton);
				}
				else if (Login.currentState == "kongregate")
				{
				}
			}
			else if (obj.amount)
			{
				if (sale && !obj.type)
				{
					amount = new TextBitmap(50, 6, obj.amount + " Flux", 13);
					amount.format.color = 11184810;
					bg.addChild(amount);
					crossOver = new Image(TextureLocator.getService().getTextureGUIByTextureName("cross_over"));
					crossOver.x = 50;
					crossOver.y = -1;
					bg.addChild(crossOver);
					amount = new TextBitmap(amount.x + amount.width + 10, 0, Math.floor(obj.amount * saleMultiplier) + " Flux", size);
					bg.addChild(amount);
				}
				else
				{
					amount = new TextBitmap(50, 0, obj.amount + " Flux", size);
					bg.addChild(amount);
				}
			}
			if (obj.price)
			{
				price = new TextBitmap(280 + (sale ? 50 : 0), 5, obj.price, 14);
				bg.addChild(price);
				if (obj.image)
				{
					price.x = 250 + (sale ? 50 : 0);
					img = new Image(textureManager.getTextureGUIByTextureName(obj.image));
					img.x = price.x + price.width + 5;
					img.y = price.y - 3;
					bg.addChild(img);
				}
			}
			if (obj.bonus && !sale)
			{
				bonus = new TextBitmap(bg.width + 10, bg.y + 3, Localize.t("[amount] extra!").replace("[amount]", obj.bonus), 16);
				bonus.format.color = 15582483;
				textLayer.addChild(bonus);
			}
			if (obj.bonusLabel && !sale)
			{
				bonusLabel = new TextBitmap(bg.width + 140, bg.y + 3, obj.bonusLabel);
				bonusLabel.format.color = 4718367;
				textLayer.addChild(bonusLabel);
			}
			if (obj.type && obj.type == "fb" && Login.currentState == "facebook")
			{
				label = new TextBitmap(220, 5, Localize.t("Like us in Facebook"), 14);
				bg.addChild(label);
				if (g.me.fbLike)
				{
					status = new TextBitmap(bg.width + 10, bg.y + 3, Localize.t("OK!"), 16);
					status.format.color = 4718367;
					textLayer.addChild(status);
				}
			}
			textLayer.addChild(bg);
			if (obj.price)
			{
				bitmap = new BuyButtonAsset();
				button = new NativeImageButton(function():void
					{
						Starling.current.nativeStage.removeChild(nativeLayer);
						if (Login.currentState == "facebook")
						{
							onBuyFacebook(obj);
						}
						else if (Login.currentState == "steam")
						{
							onBuySteam(obj);
						}
						else if (Login.currentState == "kongregate")
						{
							onBuyKred(obj);
						}
						else
						{
							onBuyPaypal(obj);
						}
					}, bitmap.bitmapData);
				button.x = bg.x + bg.width - button.width - 25;
				button.y = bg.y;
				nativeLayer.addChild(button);
			}
		}

		private function addPaymentInfo():void
		{
			if (Login.currentState != "site")
			{
				return;
			}
			var _loc2_:Quad = new Quad(bgWidth, 3, 5131854);
			_loc2_.y = textLayer.height + 30;
			textLayer.addChild(_loc2_);
			var _loc1_:Image = new Image(textureManager.getTextureGUIByTextureName("paypal_secure"));
			_loc1_.x = bgWidth - _loc1_.width;
			_loc1_.y = _loc2_.y - _loc1_.height - 10;
			textLayer.addChild(_loc1_);
		}

		private function addSuperRewards():void
		{
			if (Login.currentState != "site")
			{
				return;
			}
			var _loc5_:TextBitmap = new TextBitmap(0, textLayer.height + 20, Localize.t("Earn flux and Mobile Payment"), 16);
			_loc5_.format.color = 15582483;
			textLayer.addChild(_loc5_);
			var _loc1_:TextField = new TextField(500, 30, Localize.t("Earn flux or pay with your mobile, game cards or other payment method"), new TextFormat("Verdana", 12, 16777215, "left"));
			_loc1_.x = 0;
			_loc1_.y = _loc5_.y + 20;
			textLayer.addChild(_loc1_);
			var _loc4_:Image = new Image(textureManager.getTextureGUIByTextureName("superrewards_large"));
			_loc4_.x = bgWidth - _loc4_.width;
			_loc4_.y = _loc5_.y;
			textLayer.addChild(_loc4_);
			var _loc2_:Bitmap = new GetFluxNowButtonAsset();
			var _loc3_:NativeImageButton = new NativeImageButton(onBuySuperRewards, _loc2_.bitmapData);
			_loc3_.y = _loc1_.y + _loc1_.height + 10;
			nativeLayer.addChild(_loc3_);
		}

		private function onBuySuperRewards():void
		{
			var url:String;
			var popup:PopupMessage;
			Starling.current.nativeStage.removeChild(nativeLayer);
			url = "http://api.playerio.com/payvault/superrewards/coinsredirect?gameid=rymdenrunt-k9qmg7cvt0ylialudmldvg&connectuserid=" + g.me.id + "&connection=public";
			navigateToURL(new URLRequest(url), "_blank");
			popup = new PopupMessage();
			popup.text = Localize.t("Click me when transaction is finished.\n\nIt can take up to 48 hours for free flux to appear.");
			g.addChildToOverlay(popup);
			popup.addEventListener("close", (function():*
					{
						var closePopup:Function;
						return closePopup = function(param1:Event):void
						{
							g.removeChildFromOverlay(popup);
							popup.removeEventListeners();
							onClose();
							dispatchClose();
						};
					})());
		}

		private function onBuyPaypal(param1:Object):void
		{
			var url:String;
			var popup:PopupMessage;
			var obj:Object = param1;
			if (!RymdenRunt.isDesktop)
			{
				Starling.current.nativeStage.displayState = "normal";
			}
			url = "http://api.playerio.com/payvault/paypal/coinsredirect?gameid=rymdenrunt-k9qmg7cvt0ylialudmldvg";
			url += "&connectuserid=" + g.me.id;
			url += "&connection=public&coinamount=" + obj.amount;
			if (sale)
			{
				url += "&currency=USD&item_name=" + (obj.amount * saleMultiplier).toFixed(0) + "%20Flux";
			}
			else
			{
				url += "&currency=USD&item_name=" + obj.amount + "%20Flux";
			}
			url += "&lc=US";
			url += "&os0=" + Login.currentState;
			url += "&on0=Info";
			navigateToURL(new URLRequest(url), "_blank");
			popup = new PopupMessage();
			popup.text = Localize.t("Click me when transaction is finished. If your flux is not shown instantly, try reloading the game.");
			g.addChildToOverlay(popup);
			popup.addEventListener("close", (function():*
					{
						var closePopup:Function;
						return closePopup = function(param1:Event):void
						{
							g.removeChildFromOverlay(popup, true);
							onClose();
							dispatchClose();
						};
					})());
		}

		private function onBuySteam(param1:Object):void
		{
			var desc:String;
			var info:Object;
			var vault:PayVault;
			var obj:Object = param1;
			if (sale)
			{
				desc = (obj.amount * saleMultiplier).toFixed(0) + " Flux";
			}
			else
			{
				desc = obj.amount + " Flux";
			}
			info = {
					"steamid": RymdenRunt.info.userId,
					"appid": RymdenRunt.info.appId,
					"language": "EN",
					"coinamount": obj.amount,
					"description": desc,
					"currency": "USD"
				};
			vault = g.client.payVault;
			vault.getBuyCoinsInfo("steam", info, function(param1:Object):void
				{
					var SteamBuySuccess:Function;
					var SteamBuyFail:Function;
					var obj:Object = param1;
					info.orderid = obj.orderid;
					SteamBuySuccess = function():void
					{
						RymdenRunt.instance.removeEventListener("steambuysuccess", SteamBuySuccess);
						RymdenRunt.instance.removeEventListener("steambuyfail", SteamBuyFail);
						vault.usePaymentInfo("steam", info, function(param1:Object):void
							{
								Starling.current.nativeStage.addChild(nativeLayer);
								Game.trackEvent("buy", "boughtflux", "steam", obj.amount);
								onSuccess();
							}, function(param1:Object):void
							{
								Starling.current.nativeStage.addChild(nativeLayer);
								onFail();
							});
					};
					SteamBuyFail = function():void
					{
						RymdenRunt.instance.removeEventListener("steambuysuccess", SteamBuySuccess);
						RymdenRunt.instance.removeEventListener("steambuyfail", SteamBuyFail);
						Starling.current.nativeStage.addChild(nativeLayer);
					};
					RymdenRunt.instance.addEventListener("steambuysuccess", SteamBuySuccess);
					RymdenRunt.instance.addEventListener("steambuyfail", SteamBuyFail);
				}, function(param1:Object):void
				{
					Starling.current.nativeStage.addChild(nativeLayer);
					onFail();
				});
		}

		private function onBuyFacebook(param1:Object):void
		{
			var desc:String;
			var obj:Object = param1;
			Starling.current.nativeStage.displayState = "normal";
			if (sale)
			{
				desc = (obj.amount * saleMultiplier).toFixed(0) + " Flux";
			}
			else
			{
				desc = obj.amount + " Flux";
			}
			g.client.payVault.getBuyCoinsInfo("facebookv2", {
						"coinamount": obj.amount,
						"title": desc,
						"description": Localize.t("Thank you for supporting the game."),
						"image": g.client.gameFS.getUrl("/img/credit_small_dark.png", Login.useSecure),
						"currencies": "USD"
					}, function(param1:Object):void
					{
						var info:Object = param1;
						FB.ui(info, function(param1:Object):void
							{
								if (param1.status == "completed")
								{
									onSuccess();
								}
								else
								{
									Starling.current.nativeStage.addChild(nativeLayer);
									onFail();
									Console.write("Purchase failed.");
								}
							});
					}, function(param1:PlayerIOError):void
					{
						Console.write("Unable to buy coins", param1);
					});
		}

		private function onBuyKred(param1:Object):void
		{
			var obj:Object = param1;
			Starling.current.nativeStage.displayState = "normal";
			Login.kongregate.mtx.purchaseItems(["coins" + obj.amount], function(param1:Object):void
				{
					if (param1.success)
					{
						onSuccess();
					}
					else
					{
						Starling.current.nativeStage.addChild(nativeLayer);
						onFail();
					}
				});
		}

		private function onSuccess():void
		{
			var popup:PopupMessage;
			onClose();
			popup = new PopupMessage();
			popup.text = Localize.t("Your transaction has finished successfully. If your flux is not shown instantly, try reloading the game.");
			g.addChildToOverlay(popup);
			popup.addEventListener("close", (function():*
					{
						var closePopup:Function;
						return closePopup = function(param1:Event):void
						{
							g.removeChildFromOverlay(popup);
							popup.removeEventListeners();
							dispatchClose();
						};
					})());
		}

		private function onFail():void
		{
			var popup:PopupMessage;
			onClose();
			popup = new PopupMessage();
			popup.text = Localize.t("The transaction failed.");
			g.addChildToOverlay(popup);
			popup.addEventListener("close", (function():*
					{
						var closePopup:Function;
						return closePopup = function(param1:Event):void
						{
							g.removeChildFromOverlay(popup);
							popup.removeEventListeners();
							dispatchClose();
						};
					})());
		}

		private function dispatchClose():void
		{
			dispatchEventWith("buyFluxClose");
		}

		private function onClose(param1:TouchEvent = null):void
		{
			if (Starling.current.nativeStage.contains(nativeLayer))
			{
				Starling.current.nativeStage.removeChild(nativeLayer);
			}
		}

		private function redraw(param1:Event = null):void
		{
			var _loc2_:int = g.stage.stageWidth;
			var _loc3_:int = g.stage.stageHeight;
			bgrQuad.width = _loc2_;
			bgrQuad.height = _loc3_;
			box.x = Math.round(_loc2_ / 2 - box.width / 2);
			box.y = Math.round(_loc3_ / 2 - box.height / 2);
			nativeLayer.x = box.x;
			nativeLayer.y = box.y;
		}
	}
}
