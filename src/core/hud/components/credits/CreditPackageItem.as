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
	
	public class CreditPackageItem extends CreditBaseItem {
		public var button:NativeImageButton;
		public var buyContainer:starling.display.Sprite = new starling.display.Sprite();
		private var price:Text;
		protected var descriptionContainer:starling.display.Sprite = new starling.display.Sprite();
		protected var waitingContainer:starling.display.Sprite = new starling.display.Sprite();
		protected var aquiredContainer:starling.display.Sprite = new starling.display.Sprite();
		protected var aquiredText:Text = new Text();
		protected var aquired:Boolean = false;
		private var nativeLayer:flash.display.Sprite = new flash.display.Sprite();
		protected var description:String = "";
		protected var checkoutDescription:String = "";
		protected var checkoutDescriptionShort:String = "";
		protected var preview:String = "";
		protected var buyButtonText:String = "";
		protected var itemKey:String = "";
		protected var rpcFunction:String = "";
		
		public function CreditPackageItem(g:Game, parent:starling.display.Sprite, spinner:Boolean = false) {
			super(g,parent,spinner);
		}
		
		override protected function load() : void {
			if(g.salesManager.isPackageSale(itemKey + "_sale")) {
				itemKey += "_sale";
			}
			addBuyButton();
			addDescription();
			addAquired();
			addWaiting();
			updateAquiredText();
			updateContainers();
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
			var bitmap:Bitmap = new EmbeddedAssets.BuyButtonBitmap();
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
			if(!spinner) {
				infoContainer.addChild(buyContainer);
			}
			obj = g.dataManager.loadKey("PayVaultItems",itemKey);
			unit = Login.currentState != "kongregate" ? "$" : "Kreds ";
			extraZero = Login.currentState != "kongregate" ? "" : "0";
			if(itemKey.search("_sale") == -1) {
				price = new Text();
				price.text = unit + Math.floor(obj.PriceUSD / 100) + extraZero;
				price.size = 16;
				price.x = 5;
				price.y = 18;
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
				price.x = crossOver.x + crossOver.width / 2 + 7;
				price.y = 18;
				buyContainer.addChild(price);
				if(!spinner) {
					saleTimer = new SaleTimer(g,sale.startTime,sale.endTime,function():void {
						if(button != null) {
							button.visible = !aquired;
						}
					});
					saleTimer.x = price.x + 140;
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
				"item_name":itemLabel
			},[{"itemKey":itemKey}],function(param1:Object):void {
				navigateToURL(new URLRequest(param1.paypalurl + "&os0=" + Login.currentState + "&on0=Info"),"_blank");
			},function(param1:PlayerIOError):void {
				g.showMessageDialog("Unable to buy item");
				Starling.current.nativeStage.addChild(nativeLayer);
			});
			popup = new PopupMessage();
			popup.text = "Click me when transaction is finished. If your package content is not shown instantly, try reloading the game. You need to land on a station to switch active ship.";
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
		
		public function redraw() : void {
			var _local1:Point = price.localToGlobal(new Point(price.x,price.y));
			button.x = _local1.x;
			button.y = _local1.y - price.height + 10;
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
		
		private function onBuyFacebook() : void {
			var popup:PopupMessage;
			Starling.current.nativeStage.displayState = "normal";
			g.client.payVault.getBuyDirectInfo("facebookv2",{
				"title":itemLabel,
				"description":checkoutDescription,
				"image":g.client.gameFS.getUrl("/img/techicons/" + bitmap,Login.useSecure),
				"currencies":"USD"
			},[{"itemKey":itemKey}],function(param1:Object):void {
				var info:Object = param1;
				FB.ui(info,function(param1:Object):void {
					if(param1.status != "completed") {
						g.showErrorDialog("Buying package failed!",false);
						Starling.current.nativeStage.addChild(nativeLayer);
					}
				});
			},function(param1:PlayerIOError):void {
				g.showErrorDialog("Unable to buy item!");
				Starling.current.nativeStage.addChild(nativeLayer);
			});
			popup = new PopupMessage();
			popup.text = "Click me when transaction is finished. If your package content is not shown instantly, try reloading the game. You need to land on a station to switch active ship.";
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
		
		private function onBuyKred() : void {
			Starling.current.nativeStage.displayState = "normal";
			Login.kongregate.mtx.purchaseItems(["item" + itemKey],function(param1:Object):void {
				if(param1.success) {
					onClose(null);
				} else {
					g.showMessageDialog("Buying package failed!");
				}
			});
		}
		
		override public function exit() : void {
			if(Starling.current.nativeStage.contains(nativeLayer)) {
				Starling.current.nativeStage.removeChild(nativeLayer);
			}
		}
		
		private function onClose(e:TouchEvent = null) : void {
			g.rpc(rpcFunction,function(param1:Message):void {
				if(param1.getBoolean(0)) {
					onSuccess(param1);
				} else {
					g.showErrorDialog(param1.getString(1),true);
				}
			});
		}
		
		protected function onSuccess(m:Message) : void {
			updateAquiredText();
		}
		
		protected function addDescription() : void {
			var _local3:int = 0;
			var _local2:Image = null;
			var _local4:Quad = null;
			var _local1:Text = new Text();
			_local1.color = 0xaaaaaa;
			_local1.htmlText = description;
			_local1.width = 5 * 60;
			_local1.height = 5 * 60;
			_local1.wordWrap = true;
			_local1.y = 2 * 60;
			descriptionContainer.addChild(_local1);
			if(preview != null) {
				_local3 = 4;
				_local2 = new Image(textureManager.getTextureGUIByTextureName(preview));
				_local2.x = 4;
				_local2.y = 0;
				_local4 = new Quad(_local2.width + 6,_local2.height + 6,0xaaaaaa);
				_local4.x = _local2.x - 3;
				_local4.y = _local2.y - 3;
				descriptionContainer.addChild(_local4);
				descriptionContainer.addChild(_local2);
			}
			descriptionContainer.y = 70;
			infoContainer.addChild(descriptionContainer);
		}
		
		protected function addWaiting() : void {
			var _local1:Text = new Text();
			_local1.text = "waiting...";
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
			if(aquired) {
				aquiredText.text = "Aquired!";
			}
		}
		
		protected function showFailed(s:String) : void {
			g.showErrorDialog(s);
			buyContainer.visible = true;
			waitingContainer.visible = false;
		}
	}
}

