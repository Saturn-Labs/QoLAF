package core.hud.components {
	import com.greensock.TweenMax;
	import core.credits.Sale;
	import core.hud.components.credits.BuyFlux;
	import core.hud.components.credits.CreditBeginnerPackage;
	import core.hud.components.credits.CreditMegaPackage;
	import core.hud.components.credits.CreditPowerPackage;
	import core.hud.components.credits.CreditSupporterItem;
	import core.hud.components.dialogs.PopupMessage;
	import core.hud.components.hangar.SkinItem;
	import core.scene.Game;
	import feathers.controls.ScrollContainer;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.filters.GlowFilter;
	import textures.TextureLocator;
	
	public class SaleSpinner extends PopupMessage {
		private var g:Game;
		
		private var container:Sprite = new Sprite();
		
		private var sales:Vector.<Sale> = new Vector.<Sale>();
		
		private var current:int = 0;
		
		private var tween:TweenMax;
		
		private var supporterPackage:CreditSupporterItem;
		
		private var beginnerPackage:CreditBeginnerPackage;
		
		private var powerPackage:CreditPowerPackage;
		
		private var megaPackage:CreditMegaPackage;
		
		public function SaleSpinner(g:Game) {
			super("close",Style.COLOR_HIGHLIGHT);
			this.g = g;
			var _local2:ImageButton = new ImageButton(previous,TextureLocator.getService().getTextureGUIByTextureName("sale_spinner_arrow"),TextureLocator.getService().getTextureGUIByTextureName("sale_spinner_arrow"));
			_local2.y = 200;
			_local2.x = 580;
			_local2.pivotX = _local2.width / 2;
			_local2.pivotY = _local2.height / 2;
			box.addChild(_local2);
			var _local3:ImageButton = new ImageButton(next,TextureLocator.getService().getTextureGUIByTextureName("sale_spinner_arrow"),TextureLocator.getService().getTextureGUIByTextureName("sale_spinner_arrow"));
			_local3.y = 200;
			_local3.x = 20;
			_local3.pivotX = _local3.width / 2;
			_local3.pivotY = _local3.height / 2;
			_local3.rotation = 3.141592653589793;
			box.addChild(_local3);
			box.addChild(container);
			sales = sales.concat(g.salesManager.getPackageSales());
			sales = sales.concat(g.salesManager.getSkinSales());
			sales = sales.concat(g.salesManager.getSpecialSkinSales());
			if(g.salesManager.isFluxSale()) {
				sales.push(g.salesManager.getFluxSale());
			}
			if(sales.length == 0) {
				return;
			}
			if(sales.length == 1) {
				_local3.visible = false;
				_local2.visible = false;
			}
			current = Math.floor(Math.random() * sales.length);
			if(g.me.level < 10 && !g.me.beginnerPackage) {
				current = 0;
			}
			loadSale(sales[current]);
		}
		
		private function loadSale(sale:Sale) : void {
			var scrollContainer:ScrollContainer;
			var description:Array;
			var saleSticker:SaleSticker;
			var skinObj:Object;
			var skin:SkinItem;
			var skinObj2:Object;
			var skin2:SkinItem;
			var creditImage:Image;
			var blurFilter:GlowFilter;
			var button:Button;
			var saleTimer:SaleTimer;
			container.removeChildren(0,-1,true);
			if(tween) {
				tween.kill();
			}
			if(sale.endTime < g.time) {
				if(sales.length > 1) {
					next();
				} else {
					close();
				}
			}
			scrollContainer = new ScrollContainer();
			scrollContainer.x = 100;
			scrollContainer.y = 80;
			scrollContainer.width = 400;
			scrollContainer.height = 320;
			container.addChild(scrollContainer);
			description = sale.description.split("|");
			saleSticker = new SaleSticker(description[1],description[2],description[0]);
			saleSticker.rotation = 3.141592653589793 * 0.08;
			container.addChild(saleSticker);
			if(sale.type == "item") {
				skinObj = g.dataManager.loadKey("Skins",sale.key);
				skinObj.price = sale.normalPrice;
				skinObj.salePrice = sale.salePrice;
				skin = new SkinItem(g,skinObj,3);
				scrollContainer.addChild(skin);
				skin.buyContainer.y = 400;
				skin.buyContainer.x = 0;
				container.addChild(skin.buyContainer);
			} else if(sale.type == "sskin") {
				skinObj2 = g.dataManager.loadKey("Skins",sale.key);
				skinObj2.price = sale.normalPrice;
				skin2 = new SkinItem(g,skinObj2,3);
				scrollContainer.addChild(skin2);
				skin2.buyContainer.y = 400;
				skin2.buyContainer.x = 0;
				container.addChild(skin2.buyContainer);
			} else if(sale.type == "pack") {
				if(sale.key == "beginnerpackage_sale") {
					beginnerPackage = new CreditBeginnerPackage(g,this,true);
					scrollContainer.addChild(beginnerPackage);
					beginnerPackage.buyContainer.y = 400;
					beginnerPackage.buyContainer.x = 200;
					container.addChild(beginnerPackage.buyContainer);
				} else if(sale.key == "powerpackage_sale") {
					powerPackage = new CreditPowerPackage(g,this,true);
					scrollContainer.addChild(powerPackage);
					powerPackage.buyContainer.y = 400;
					powerPackage.buyContainer.x = 200;
					container.addChild(powerPackage.buyContainer);
				} else if(sale.key == "megapackage_sale") {
					megaPackage = new CreditMegaPackage(g,this,true);
					scrollContainer.addChild(megaPackage);
					megaPackage.buyContainer.y = 400;
					megaPackage.buyContainer.x = 200;
					container.addChild(megaPackage.buyContainer);
				} else if(sale.key == "supporter_sale") {
					supporterPackage = new CreditSupporterItem(g,this,true);
					scrollContainer.addChild(supporterPackage);
					supporterPackage.buyContainer.y = 400;
					supporterPackage.buyContainer.x = 200;
					container.addChild(supporterPackage.buyContainer);
				}
			} else if(sale.type == "flux") {
				creditImage = new Image(TextureLocator.getService().getTextureGUIByTextureName("credit"));
				creditImage.x = box.width / 2 - 60;
				creditImage.y = box.height / 2 - 60;
				creditImage.pivotX = creditImage.width / 2;
				creditImage.pivotY = creditImage.height / 2;
				blurFilter = new GlowFilter();
				creditImage.filter = blurFilter;
				tween = TweenMax.fromTo(blurFilter,2,{
					"blurX":0,
					"blurY":0
				},{
					"blurX":20,
					"blurY":20,
					"yoyo":true,
					"repeat":-1,
					"onUpdate":function():void {
						creditImage.filter = blurFilter;
					}
				});
				container.addChild(creditImage);
				button = new Button(function():void {
					var buyFlux:BuyFlux = new BuyFlux(g);
					buyFlux.addEventListener("buyFluxClose",function():void {
						g.removeChildFromOverlay(buyFlux);
						button.enabled = true;
						g.creditManager.refresh(function():void {
						});
					});
					g.addChildToOverlay(buyFlux);
				},"Get Flux now!","buy");
				button.x = creditImage.x - button.width / 2;
				button.y = creditImage.y + creditImage.height / 2 + 100;
				container.addChild(button);
			}
			saleTimer = new SaleTimer(g,sale.startTime,sale.endTime,function():void {
				if(sales.length > 1) {
					next();
				} else {
					close();
				}
			});
			saleTimer.x = 100;
			saleTimer.y = 10;
			container.addChild(saleTimer);
			redraw();
		}
		
		private function next(ib:ImageButton = null) : void {
			current++;
			current = current == sales.length ? 0 : current;
			if(supporterPackage != null) {
				supporterPackage.exit();
			}
			if(megaPackage != null) {
				megaPackage.exit();
			}
			if(powerPackage != null) {
				powerPackage.exit();
			}
			if(beginnerPackage != null) {
				beginnerPackage.exit();
			}
			loadSale(sales[current]);
		}
		
		private function previous(ib:ImageButton = null) : void {
			current--;
			current = current == -1 ? sales.length - 1 : current;
			if(supporterPackage != null) {
				supporterPackage.exit();
			}
			if(megaPackage != null) {
				megaPackage.exit();
			}
			if(powerPackage != null) {
				powerPackage.exit();
			}
			if(beginnerPackage != null) {
				beginnerPackage.exit();
			}
			loadSale(sales[current]);
		}
		
		override protected function redraw(e:Event = null) : void {
			if(stage == null) {
				return;
			}
			closeButton.y = 10;
			closeButton.x = Math.round(590 - closeButton.width);
			box.width = 10 * 60;
			box.height = 450;
			box.x = Math.round(stage.stageWidth / 2 - box.width / 2);
			box.y = Math.round(stage.stageHeight / 2 + 50 - box.height / 2);
			bgr.width = stage.stageWidth;
			bgr.height = stage.stageHeight;
			if(megaPackage != null) {
				megaPackage.redraw();
			}
			if(powerPackage != null) {
				powerPackage.redraw();
			}
			if(beginnerPackage != null) {
				beginnerPackage.redraw();
			}
		}
		
		override protected function clean(e:Event) : void {
			if(supporterPackage != null) {
				supporterPackage.exit();
			}
			if(beginnerPackage != null) {
				beginnerPackage.exit();
			}
			if(powerPackage != null) {
				powerPackage.exit();
			}
			if(megaPackage != null) {
				megaPackage.exit();
			}
			if(tween) {
				tween.kill();
			}
			removeChildren(0,-1,true);
			super.clean(e);
		}
	}
}

