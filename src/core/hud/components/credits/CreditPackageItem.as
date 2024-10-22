package core.hud.components.credits
{
   import core.credits.Sale;
   import core.hud.components.NativeImageButton;
   import core.hud.components.SaleTimer;
   import core.hud.components.Style;
   import core.hud.components.Text;
   import core.hud.components.dialogs.PopupMessage;
   import core.scene.Game;
   import embeds.BuyButtonBitmap;
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

   public class CreditPackageItem extends CreditBaseItem
   {
      public var button:NativeImageButton;

      public var buyContainer:starling.display.Sprite;

      private var price:Text;

      protected var descriptionContainer:starling.display.Sprite;

      protected var waitingContainer:starling.display.Sprite;

      protected var aquiredContainer:starling.display.Sprite;

      protected var aquiredText:Text;

      protected var aquired:Boolean = false;

      private var nativeLayer:flash.display.Sprite;

      private var BuyButtonAsset:Class;

      protected var description:String = "";

      protected var checkoutDescription:String = "";

      protected var checkoutDescriptionShort:String = "";

      protected var preview:String = "";

      protected var buyButtonText:String = "";

      protected var itemKey:String = "";

      protected var rpcFunction:String = "";

      public function CreditPackageItem(param1:Game, param2:starling.display.Sprite, param3:Boolean = false)
      {
         buyContainer = new starling.display.Sprite();
         descriptionContainer = new starling.display.Sprite();
         waitingContainer = new starling.display.Sprite();
         aquiredContainer = new starling.display.Sprite();
         aquiredText = new Text();
         nativeLayer = new flash.display.Sprite();
         BuyButtonAsset = embeds.BuyButtonBitmap;
         super(param1, param2, param3);
      }

      override protected function load():void
      {
         if (g.salesManager.isPackageSale(itemKey + "_sale"))
         {
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

      private function addBuyButton():void
      {
         var obj:Object;
         var unit:String;
         var extraZero:String;
         var oldPrice:Text;
         var sale:Sale;
         var crossOver:Image;
         var saleTimer:SaleTimer;
         var bitmap:Bitmap = new BuyButtonAsset();
         button = new NativeImageButton(function():void
            {
               Starling.current.nativeStage.removeChild(nativeLayer);
               if (Login.currentState == "facebook")
               {
                  onBuyFacebook();
               }
               else if (Login.currentState == "steam")
               {
                  onBuySteam();
               }
               else if (Login.currentState == "kongregate")
               {
                  onBuyKred();
               }
               else
               {
                  onBuyPaypal();
               }
            }, bitmap.bitmapData);
         button.x = 30;
         button.y = 20;
         button.visible = false;
         nativeLayer.addChild(button);
         if (!spinner)
         {
            infoContainer.addChild(buyContainer);
         }
         obj = g.dataManager.loadKey("PayVaultItems", itemKey);
         unit = Login.currentState != "kongregate" ? "$" : "Kreds ";
         extraZero = Login.currentState != "kongregate" ? "" : "0";
         if (itemKey.search("_sale") == -1)
         {
            price = new Text();
            price.text = unit + Math.floor(obj.PriceUSD / 100) + extraZero;
            price.size = 16;
            price.x = 5;
            price.y = 18;
            buyContainer.addChild(price);
         }
         else
         {
            oldPrice = new Text();
            sale = g.salesManager.getPackageSale(itemKey);
            if (sale == null)
            {
               return;
            }
            oldPrice.text = unit + Math.floor(sale.normalPrice / 100) + extraZero;
            oldPrice.size = 18;
            oldPrice.color = 11184810;
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
            if (!spinner)
            {
               saleTimer = new SaleTimer(g, sale.startTime, sale.endTime, function():void
                  {
                     if (button != null)
                     {
                        button.visible = !aquired;
                     }
                  });
               saleTimer.x = price.x + 140;
               buyContainer.addChild(saleTimer);
            }
         }
         if (spinner)
         {
            select();
         }
      }

      private function onBuyPaypal():void
      {
         var popup:PopupMessage;
         g.client.payVault.getBuyDirectInfo("paypal", {
                  "currency": "USD",
                  "item_name": itemLabel
               }, [ {"itemKey": itemKey}], function(param1:Object):void
               {
                  navigateToURL(new URLRequest(param1.paypalurl + "&os0=" + Login.currentState + "&on0=Info"), "_blank");
               }, function(param1:PlayerIOError):void
               {
                  g.showMessageDialog("Unable to buy item");
                  Starling.current.nativeStage.addChild(nativeLayer);
               });
         popup = new PopupMessage();
         popup.text = "Click me when transaction is finished. If your package content is not shown instantly, try reloading the game. You need to land on a station to switch active ship.";
         g.addChildToOverlay(popup);
         popup.addEventListener("close", (function():*
               {
                  var closePopup:Function;
                  return closePopup = function(param1:Event):void
                  {
                     g.removeChildFromOverlay(popup);
                     popup.removeEventListeners();
                     onClose();
                  };
               })());
      }

      public function redraw():void
      {
         var _loc1_:Point = price.localToGlobal(new Point(price.x, price.y));
         button.x = _loc1_.x;
         button.y = _loc1_.y - price.height + 10;
      }

      override protected function showInfo(param1:Boolean):void
      {
         var _loc2_:Point = null;
         if (param1 == true)
         {
            Starling.current.nativeStage.addChild(nativeLayer);
         }
         else if (Starling.current.nativeStage.contains(nativeLayer))
         {
            Starling.current.nativeStage.removeChild(nativeLayer);
         }
         button.visible = param1;
         if (aquired)
         {
            button.visible = false;
         }
         super.showInfo(param1);
         if (param1 == true && price != null)
         {
            _loc2_ = price.localToGlobal(new Point(price.x, price.y));
            if (itemKey.search("_sale") == -1)
            {
               button.x = _loc2_.x + price.width + 1;
               button.y = _loc2_.y - price.height + 4;
            }
            else
            {
               button.x = _loc2_.x;
               button.y = _loc2_.y - price.height + 8;
            }
         }
      }

      private function onBuySteam():void
      {
         var info:Object = {
               "steamid": RymdenRunt.info.userId,
               "appid": RymdenRunt.info.appId,
               "language": "EN",
               "currency": "USD"
            };
         var vault:PayVault = g.client.payVault;
         var buyItemInfo:PayVaultBuyItemInfo = new PayVaultBuyItemInfo();
         buyItemInfo.itemKey = itemKey;
         vault.getBuyDirectInfo("steam", info, [buyItemInfo], function(param1:Object):void
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
                        onClose();
                     }, function(param1:PlayerIOError):void
                     {
                        g.showErrorDialog(param1.message, false);
                        Starling.current.nativeStage.addChild(nativeLayer);
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
            }, function(param1:PlayerIOError):void
            {
               g.showErrorDialog("Buying package failed! " + param1.message, false);
               Starling.current.nativeStage.addChild(nativeLayer);
            });
      }

      private function onBuyFacebook():void
      {
         var popup:PopupMessage;
         Starling.current.nativeStage.displayState = "normal";
         g.client.payVault.getBuyDirectInfo("facebookv2", {
                  "title": itemLabel,
                  "description": checkoutDescription,
                  "image": g.client.gameFS.getUrl("/img/techicons/" + bitmap, Login.useSecure),
                  "currencies": "USD"
               }, [ {"itemKey": itemKey}], function(param1:Object):void
               {
                  var info:Object = param1;
                  FB.ui(info, function(param1:Object):void
                     {
                        if (param1.status != "completed")
                        {
                           g.showErrorDialog("Buying package failed!", false);
                           Starling.current.nativeStage.addChild(nativeLayer);
                        }
                     });
               }, function(param1:PlayerIOError):void
               {
                  g.showErrorDialog("Unable to buy item!");
                  Starling.current.nativeStage.addChild(nativeLayer);
               });
         popup = new PopupMessage();
         popup.text = "Click me when transaction is finished. If your package content is not shown instantly, try reloading the game. You need to land on a station to switch active ship.";
         g.addChildToOverlay(popup);
         popup.addEventListener("close", (function():*
               {
                  var closePopup:Function;
                  return closePopup = function(param1:Event):void
                  {
                     g.removeChildFromOverlay(popup);
                     popup.removeEventListeners();
                     onClose();
                  };
               })());
      }

      private function onBuyKred():void
      {
         Starling.current.nativeStage.displayState = "normal";
         Login.kongregate.mtx.purchaseItems(["item" + itemKey], function(param1:Object):void
            {
               if (param1.success)
               {
                  onClose(null);
               }
               else
               {
                  g.showMessageDialog("Buying package failed!");
               }
            });
      }

      override public function exit():void
      {
         if (Starling.current.nativeStage.contains(nativeLayer))
         {
            Starling.current.nativeStage.removeChild(nativeLayer);
         }
      }

      private function onClose(param1:TouchEvent = null):void
      {
         var e:TouchEvent = param1;
         g.rpc(rpcFunction, function(param1:Message):void
            {
               if (param1.getBoolean(0))
               {
                  onSuccess(param1);
               }
               else
               {
                  g.showErrorDialog(param1.getString(1), true);
               }
            });
      }

      protected function onSuccess(param1:Message):void
      {
         updateAquiredText();
      }

      protected function addDescription():void
      {
         var _loc3_:int = 0;
         var _loc2_:Image = null;
         var _loc4_:Quad = null;
         var _loc1_:Text = new Text();
         _loc1_.color = 11184810;
         _loc1_.htmlText = description;
         _loc1_.width = 300;
         _loc1_.height = 300;
         _loc1_.wordWrap = true;
         _loc1_.y = 120;
         descriptionContainer.addChild(_loc1_);
         if (preview != null)
         {
            _loc3_ = 4;
            _loc2_ = new Image(textureManager.getTextureGUIByTextureName(preview));
            _loc2_.x = 4;
            _loc2_.y = 0;
            _loc4_ = new Quad(_loc2_.width + 6, _loc2_.height + 6, 11184810);
            _loc4_.x = _loc2_.x - 3;
            _loc4_.y = _loc2_.y - 3;
            descriptionContainer.addChild(_loc4_);
            descriptionContainer.addChild(_loc2_);
         }
         descriptionContainer.y = 70;
         infoContainer.addChild(descriptionContainer);
      }

      protected function addWaiting():void
      {
         var _loc1_:Text = new Text();
         _loc1_.text = "waiting...";
         _loc1_.x = 60;
         _loc1_.y = 20;
         waitingContainer.addChild(_loc1_);
         waitingContainer.visible = false;
         infoContainer.addChild(waitingContainer);
      }

      protected function addAquired():void
      {
         aquiredText.x = 0;
         aquiredText.y = 20;
         aquiredText.color = Style.COLOR_HIGHLIGHT;
         aquiredText.wordWrap = true;
         aquiredText.width = 300;
         aquiredContainer.addChild(aquiredText);
         aquiredContainer.visible = false;
         infoContainer.addChild(aquiredContainer);
      }

      protected function updateContainers():void
      {
         buyContainer.visible = !aquired;
         aquiredContainer.visible = aquired;
         waitingContainer.visible = false;
      }

      protected function updateAquiredText():void
      {
         if (aquired)
         {
            aquiredText.text = "Aquired!";
         }
      }

      protected function showFailed(param1:String):void
      {
         g.showErrorDialog(param1);
         buyContainer.visible = true;
         waitingContainer.visible = false;
      }
   }
}
