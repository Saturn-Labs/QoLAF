package core.hud.components.credits {
	import core.credits.Sale;
	import core.hud.components.NativeImageButton;
	import core.hud.components.SaleTimer;
	import core.hud.components.Style;
	import core.hud.components.Text;
	import core.hud.components.dialogs.PopupMessage;
	import core.scene.Game;
	import facebook.FB;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import generics.Localize;
	import playerio.Message;
	import playerio.PayVault;
	import playerio.PlayerIOError;
	import playerio.generated.messages.PayVaultBuyItemInfo;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	
	public class CreditSupporterItem extends CreditBaseItem {
		public var button:NativeImageButton;
		
		private var price:Text;
		
		public var buyContainer:starling.display.Sprite = new starling.display.Sprite();
		
		protected var descriptionContainer:starling.display.Sprite = new starling.display.Sprite();
		
		protected var aquiredContainer:starling.display.Sprite = new starling.display.Sprite();
		
		protected var waitingContainer:starling.display.Sprite = new starling.display.Sprite();
		
		protected var description:String;
		
		protected var checkoutDescriptionShort:String;
		
		private var nativeLayer:flash.display.Sprite = new flash.display.Sprite();
		
		private var BuyButtonAsset:Class = §buyButton_png$360ba7d2547d196a47716679804036e1-1565431473§;
		
		protected var preview:String = "supporter_preview.png";
		
		protected var aquiredText:Text = new Text();
		
		protected var expiryTime:Number;
		
		protected var aquired:Boolean = false;
		
		protected var itemKey:String = "supporter";
		
		public function CreditSupporterItem(g:Game, parent:starling.display.Sprite, spinner:Boolean = false) {
			super(g,parent,spinner);
			load();
		}
		
		override protected function load() : void {
			bitmap = "ti_supporter.png";
			itemLabel = Localize.t("Supporter Package");
			description = Localize.t("Support the game and buy this package, you will recieve <font color=\'#ffaa44\'>[months] months</font>:<br><br><font color=\'#ffaa44\'>- Tractor Beam<br>- Experience Boost<br>- Cargo Protection<br>- Experience Protection<br>- Free Resets<br>- Free Paint Jobs<br></font><br>And a <font color=\'#ffaa44\'>supporter icon</FONT> to show your support for the game to other players.").replace("[months]",3);
			if(g.salesManager.isPackageSale(itemKey + "_sale")) {
				itemKey += "_sale";
			}
			checkoutDescriptionShort = Localize.t("Three months Tractor Beam + Experience Boost + Cargo Protection + Experience Protection and a supporter icon to show your support for the game to other players.");
			aquired = g.me.hasSupporter();
			expiryTime = g.me.supporter;
			addBuyButton();
			addDescription();
			addAquired();
			addWaiting();
			updateAquiredText();
			updateContainers();
			Starling.current.nativeStage.addChild(nativeLayer);
			super.load();
		}
		
		private function addBuyButton() : void {
			var obj:Object;
			var unit:String;
			var extraZero:String;
			var oldPrice:Text;
			var sale:Sale;
			var crossOver:Image;
			var saleTimer:SaleTimer;
			var bitmap:Bitmap = new BuyButtonAsset();
			button = new NativeImageButton(function():void {
				Starling.current.nativeStage.removeChild(nativeLayer);
				if(Login.currentState == "facebook") {
					onBuyFacebook();
				} else if(Login.currentState == "steam") {
					onBuySteam();
				} else if(Login.currentState == "kongregate") {
					onBuyKred();
				} else {
					onBuyPaypal();
				}
			},bitmap.bitmapData);
			button.x = 30;
			button.y = 20;
			button.visible = false;
			nativeLayer.addChild(button);
			infoContainer.addChild(buyContainer);
			obj = g.dataManager.loadKey("PayVaultItems",itemKey);
			unit = Login.currentState != "kongregate" ? "$" : "Kreds ";
			extraZero = Login.currentState != "kongregate" ? "" : "0";
			if(itemKey.search("_sale") == -1) {
				price = new Text();
				price.text = unit + Math.floor(obj.PriceUSD / 100) + extraZero;
				price.size = 16;
				price.x = 5;
				price.y = 18;
				button.x = price.x + price.width + 5;
				buyContainer.addChild(price);
			} else {
				oldPrice = new Text();
				sale = g.salesManager.getPackageSale(itemKey);
				if(sale == null) {
					return;
				}
				oldPrice.text = unit + Math.floor(sale.normalPrice / 100) + extraZero;
				oldPrice.size = 18;
				oldPrice.color = 0xaaaaaa;
				oldPrice.x = 5;
				oldPrice.y = 18;
				buyContainer.addChild(oldPrice);
				crossOver = new Image(textureManager.getTextureGUIByTextureName("cross_over"));
				crossOver.x = oldPrice.x + oldPrice.width / 2;
				crossOver.y = oldPrice.y + oldPrice.height / 2;
				crossOver.pivotX = crossOver.width / 2;
				crossOver.pivotY = crossOver.height / 2;
				buyContainer.addChild(crossOver);
				price = new Text();
				price.text = unit + Math.floor(obj.PriceUSD / 100) + extraZero;
				price.size = 18;
				price.x = crossOver.x + crossOver.width / 2 + 5;
				price.y = 18;
				button.x = price.x + price.width + 5;
				buyContainer.addChild(price);
				if(!spinner) {
					saleTimer = new SaleTimer(g,sale.startTime,sale.endTime,function():void {
						if(button != null) {
							button.visible = !aquired;
						}
					});
					saleTimer.x = button.x + button.width + 40;
					buyContainer.addChild(saleTimer);
				}
			}
			if(spinner) {
				select();
			}
		}
		
		private function onBuyPaypal() : void {
			var popup:PopupMessage;
			g.client.payVault.getBuyDirectInfo("paypal",{
				"currency":"USD",
				"item_name":Localize.t("Supporter Package")
			},[{"itemKey":itemKey}],function(param1:Object):void {
				navigateToURL(new URLRequest(param1.paypalurl + "&os0=" + Login.currentState + "&on0=Info"),"_blank");
			},function(param1:PlayerIOError):void {
				g.showMessageDialog("Unable to buy item");
			});
			popup = new PopupMessage();
			popup.text = Localize.t("Click me when transaction is finished. If your supporter package is not shown instantly, try reloading the game.");
			g.addChildToOverlay(popup);
			popup.addEventListener("close",(function():* {
				var closePopup:Function;
				return closePopup = function(param1:Event):void {
					g.removeChildFromOverlay(popup);
					popup.removeEventListeners();
					onClose();
				};
			})());
		}
		
		override protected function showInfo(value:Boolean) : void {
			var _local2:Point = null;
			if(value == true) {
				Starling.current.nativeStage.addChild(nativeLayer);
			} else if(Starling.current.nativeStage.contains(nativeLayer)) {
				Starling.current.nativeStage.removeChild(nativeLayer);
			}
			button.visible = value;
			if(aquired) {
				button.visible = false;
			}
			super.showInfo(value);
			if(value == true && price != null) {
				_local2 = price.localToGlobal(new Point(price.x,price.y));
				if(itemKey.search("_sale") == -1) {
					button.x = _local2.x + price.width + 1;
					button.y = _local2.y - price.height + 4;
				} else {
					button.x = _local2.x;
					button.y = _local2.y - price.height + 8;
				}
			}
		}
		
		override public function exit() : void {
			if(Starling.current.nativeStage.contains(nativeLayer)) {
				Starling.current.nativeStage.removeChild(nativeLayer);
			}
		}
		
		private function onBuyFacebook() : void {
			var popup:PopupMessage;
			Starling.current.nativeStage.displayState = "normal";
			g.client.payVault.getBuyDirectInfo("facebookv2",{
				"title":Localize.t("Supporter Package"),
				"description":Localize.t("Supporter package with tractor beam, experience boost, experience protection, cargo protection and a supporter icon."),
				"image":g.client.gameFS.getUrl("/img/techicons/ti_supporter.png",Login.useSecure),
				"currencies":"USD"
			},[{"itemKey":itemKey}],function(param1:Object):void {
				var info:Object = param1;
				FB.ui(info,function(param1:Object):void {
					if(param1.status != "completed") {
						g.showErrorDialog(Localize.t("Buying supporter package failed!"),false);
						Starling.current.nativeStage.addChild(nativeLayer);
					}
				});
			},function(param1:PlayerIOError):void {
				g.showErrorDialog(Localize.t("Unable to buy item!"));
				Starling.current.nativeStage.addChild(nativeLayer);
			});
			popup = new PopupMessage();
			popup.text = Localize.t("Click me when transaction is finished. If your supporter package is not shown instantly, try reloading the game. You need to land on a station to switch active ship.");
			g.addChildToOverlay(popup);
			popup.addEventListener("close",(function():* {
				var closePopup:Function;
				return closePopup = function(param1:Event):void {
					g.removeChildFromOverlay(popup);
					popup.removeEventListeners();
					onClose();
				};
			})());
		}
		
		private function onBuySteam() : void {
			var info:Object = {
				"steamid":RymdenRunt.info.userId,
				"appid":RymdenRunt.info.appId,
				"language":"EN",
				"currency":"USD"
			};
			var vault:PayVault = g.client.payVault;
			var buyItemInfo:PayVaultBuyItemInfo = new PayVaultBuyItemInfo();
			buyItemInfo.itemKey = itemKey;
			vault.getBuyDirectInfo("steam",info,[buyItemInfo],function(param1:Object):void {
				var SteamBuySuccess:Function;
				var SteamBuyFail:Function;
				var obj:Object = param1;
				info.orderid = obj.orderid;
				SteamBuySuccess = function():void {
					RymdenRunt.instance.removeEventListener("steambuysuccess",SteamBuySuccess);
					RymdenRunt.instance.removeEventListener("steambuyfail",SteamBuyFail);
					vault.usePaymentInfo("steam",info,function(param1:Object):void {
						onClose();
					},function(param1:PlayerIOError):void {
						g.showErrorDialog(param1.message,false);
						Starling.current.nativeStage.addChild(nativeLayer);
					});
				};
				SteamBuyFail = function():void {
					RymdenRunt.instance.removeEventListener("steambuysuccess",SteamBuySuccess);
					RymdenRunt.instance.removeEventListener("steambuyfail",SteamBuyFail);
					Starling.current.nativeStage.addChild(nativeLayer);
				};
				RymdenRunt.instance.addEventListener("steambuysuccess",SteamBuySuccess);
				RymdenRunt.instance.addEventListener("steambuyfail",SteamBuyFail);
			},function(param1:PlayerIOError):void {
				g.showErrorDialog("Buying package failed! " + param1.message,false);
				Starling.current.nativeStage.addChild(nativeLayer);
			});
		}
		
		private function onBuyKred() : void {
			Starling.current.nativeStage.displayState = "normal";
			Login.kongregate.mtx.purchaseItems(["item" + itemKey],function(param1:Object):void {
				if(param1.success) {
					onClose(null);
				} else {
					g.showMessageDialog(Localize.t("Buying supporter package failed!"));
					Starling.current.nativeStage.addChild(nativeLayer);
				}
			});
		}
		
		private function onClose(e:TouchEvent = null) : void {
			if(Starling.current.nativeStage.contains(nativeLayer)) {
				Starling.current.nativeStage.removeChild(nativeLayer);
			}
			g.rpc("buySupporterPackage",function(param1:Message):void {
				if(param1.getBoolean(0)) {
					if(!g.me.hasSkin(param1.getString(2))) {
						g.showMessageDialog(Localize.t("<font color=\'#88ff88\'>Thanks for supporting us!</font><br><br>To thank you we have expanded your fleet with a <font color=\'#88ff88\'>Bonus Ship</font>.<br><br><font color=\'#ffff88\'>Please reload the game!</font> You need to land on a station to switch active ship."));
					} else {
						g.showMessageDialog(Localize.t("<font color=\'#88ff88\'>Thanks for supporting us!</font><br><br> Enjoy your tractor beam ;-)<br><br><font color=\'#ffff88\'>Please reload the game!</font>"));
					}
					g.me.supporter = g.me.expBoost = g.me.cargoProtection = g.me.xpProtection = g.me.tractorBeam = param1.getNumber(1);
					g.me.addNewSkin(param1.getString(2));
					aquired = true;
					updateAquiredText();
					updateContainers();
					g.hud.update();
				} else {
					g.showErrorDialog(param1.getString(1),true);
				}
			});
		}
		
		protected function addDescription() : void {
			var _local2:int = 0;
			var _local4:Image = null;
			var _local1:Quad = null;
			var _local3:Text = new Text();
			_local3.color = 0xaaaaaa;
			_local3.htmlText = description;
			_local3.width = 5 * 60;
			_local3.height = 5 * 60;
			_local3.wordWrap = true;
			_local3.y = 2 * 60;
			descriptionContainer.addChild(_local3);
			if(preview != null) {
				_local2 = 4;
				_local4 = new Image(textureManager.getTextureGUIByTextureName(preview));
				_local4.x = 4;
				_local4.y = 0;
				_local1 = new Quad(_local4.width + 6,_local4.height + 6,0xaaaaaa);
				_local1.x = _local4.x - 3;
				_local1.y = _local4.y - 3;
				descriptionContainer.addChild(_local1);
				descriptionContainer.addChild(_local4);
			}
			descriptionContainer.y = 70;
			infoContainer.addChild(descriptionContainer);
		}
		
		protected function addWaiting() : void {
			var _local1:Text = new Text();
			_local1.text = Localize.t("waiting...");
			_local1.x = 60;
			_local1.y = 20;
			waitingContainer.addChild(_local1);
			waitingContainer.visible = false;
			infoContainer.addChild(waitingContainer);
		}
		
		protected function addAquired() : void {
			aquiredText.x = 0;
			aquiredText.y = 20;
			aquiredText.color = Style.COLOR_HIGHLIGHT;
			aquiredText.wordWrap = true;
			aquiredText.width = 5 * 60;
			aquiredContainer.addChild(aquiredText);
			aquiredContainer.visible = false;
			infoContainer.addChild(aquiredContainer);
		}
		
		protected function updateContainers() : void {
			buyContainer.visible = !aquired;
			aquiredContainer.visible = aquired;
			waitingContainer.visible = false;
		}
		
		protected function updateAquiredText() : void {
			var _local2:Number = NaN;
			var _local1:Date = null;
			if(aquired) {
				_local2 = expiryTime - g.time;
				_local1 = new Date();
				_local1.milliseconds += _local2;
				aquiredText.text = Localize.t("Aquired!\nActive until:") + " " + _local1.toLocaleDateString();
			}
		}
		
		protected function showFailed(s:String) : void {
			g.showErrorDialog(s);
			buyContainer.visible = true;
			waitingContainer.visible = false;
		}
	}
}

