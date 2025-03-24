package core.states.gameStates {
	import core.credits.CreditManager;
	import core.hud.components.Button;
	import core.hud.components.ButtonExpandableHud;
	import core.hud.components.TextBitmap;
	import core.hud.components.credits.BuyFlux;
	import core.hud.components.credits.CreditBeginnerPackage;
	import core.hud.components.credits.CreditCargoProtection;
	import core.hud.components.credits.CreditExpBoost;
	import core.hud.components.credits.CreditLabel;
	import core.hud.components.credits.CreditMegaPackage;
	import core.hud.components.credits.CreditPods;
	import core.hud.components.credits.CreditPowerPackage;
	import core.hud.components.credits.CreditSupporterItem;
	import core.hud.components.credits.CreditTractorBeam;
	import core.hud.components.credits.CreditXpProtection;
	import core.hud.components.credits.ICreditItem;
	import core.hud.components.credits.Redeem;
	import core.scene.Game;
	import feathers.controls.ScrollContainer;
	import generics.Localize;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class Shop extends Sprite {
		private var g:Game;
		
		private var container:Sprite = new ScrollContainer();
		
		private var infoContainer:Sprite = new Sprite();
		
		private var bg:Image;
		
		private var items:Array = [];
		
		private var closeButton:ButtonExpandableHud;
		
		private var balance:CreditLabel = new CreditLabel();
		
		private var textureManager:ITextureManager;
		
		private var redeemButton:Button;
		
		private var state:String;
		
		private var pods:CreditPods;
		
		public function Shop(g:Game, state:String = "") {
			super();
			this.g = g;
			this.state = state;
			textureManager = TextureLocator.getService();
			closeButton = new ButtonExpandableHud(function():void {
				dispatchEventWith("close");
			},Localize.t("close"));
		}
		
		public function load(callback:Function) : void {
			var name:TextBitmap;
			var description:TextBitmap;
			var getMoreButton:Button;
			bg = new Image(textureManager.getTextureGUIByTextureName("map_bgr.png"));
			addChild(bg);
			closeButton.x = 760 - 46 - closeButton.width;
			closeButton.y = 0;
			addChild(closeButton);
			container.x = 60;
			container.y = 140;
			container.height = 410;
			container.width = 275;
			addChild(container);
			infoContainer.x = 340;
			infoContainer.y = 140;
			addChild(infoContainer);
			name = new TextBitmap(60,50,Localize.t("Flux Shop"),30);
			addChild(name);
			description = new TextBitmap();
			description.text = Localize.t("Buy cool stuff to support the game");
			description.format.color = 0xaaaaaa;
			description.x = 60;
			description.y = name.y + name.height + 5;
			addChild(description);
			balance.x = 570;
			balance.y = 70;
			balance.size = 12;
			addChild(balance);
			refreshCreditManager();
			getMoreButton = new Button(function():void {
				var buyFlux:BuyFlux;
				select(pods);
				buyFlux = new BuyFlux(g);
				buyFlux.addEventListener("buyFluxClose",function():void {
					buyFlux.removeEventListeners("buyFluxClose");
					g.removeChildFromOverlay(buyFlux);
					refreshCreditManager();
					getMoreButton.enabled = true;
				});
				g.addChildToOverlay(buyFlux);
			},Localize.t("Get more"),"positive");
			getMoreButton.x = balance.x + 45;
			getMoreButton.y = balance.y;
			getMoreButton.alignWithText();
			addChild(getMoreButton);
			redeemButton = new Button(onRedeem,Localize.t("Redeem"),"positive");
			redeemButton.x = getMoreButton.x;
			redeemButton.y = getMoreButton.y + getMoreButton.height + 15;
			redeemButton.width = getMoreButton.width;
			redeemButton.alignWithText();
			addChild(redeemButton);
			g.creditManager.addEventListener("refresh",updateCreditText);
			loadItems();
			callback();
		}
		
		private function loadItems() : void {
			var _local6:int = 0;
			pods = new CreditPods(g,infoContainer);
			pods.y = _local6;
			container.addChild(pods);
			items.push(pods);
			pods.addEventListener("select",onSelect);
			_local6 += 52;
			var _local9:CreditBeginnerPackage = new CreditBeginnerPackage(g,infoContainer);
			_local9.y = _local6;
			container.addChild(_local9);
			items.push(_local9);
			_local9.addEventListener("select",onSelect);
			_local9.addEventListener("bought",bought);
			_local6 += 52;
			var _local4:CreditPowerPackage = new CreditPowerPackage(g,infoContainer,false);
			_local4.y = _local6;
			container.addChild(_local4);
			items.push(_local4);
			_local4.addEventListener("select",onSelect);
			_local4.addEventListener("bought",bought);
			_local6 += 52;
			var _local3:CreditMegaPackage = new CreditMegaPackage(g,infoContainer,false);
			_local3.y = _local6;
			container.addChild(_local3);
			items.push(_local3);
			_local3.addEventListener("select",onSelect);
			_local3.addEventListener("bought",bought);
			_local6 += 52;
			var _local5:CreditSupporterItem = new CreditSupporterItem(g,infoContainer);
			_local5.y = _local6;
			container.addChild(_local5);
			items.push(_local5);
			_local5.addEventListener("select",onSelect);
			_local5.addEventListener("bought",bought);
			_local6 += 52;
			var _local8:CreditTractorBeam = new CreditTractorBeam(g,infoContainer);
			container.addChild(_local8);
			items.push(_local8);
			_local8.y = _local6;
			_local8.addEventListener("select",onSelect);
			_local8.addEventListener("bought",bought);
			_local6 += 52;
			var _local1:CreditExpBoost = new CreditExpBoost(g,infoContainer);
			_local1.y = _local6;
			container.addChild(_local1);
			items.push(_local1);
			_local1.addEventListener("select",onSelect);
			_local1.addEventListener("bought",bought);
			_local6 += 52;
			var _local7:CreditXpProtection = new CreditXpProtection(g,infoContainer);
			_local7.y = _local6;
			container.addChild(_local7);
			items.push(_local7);
			_local7.addEventListener("select",onSelect);
			_local7.addEventListener("bought",bought);
			_local6 += 52;
			var _local2:CreditCargoProtection = new CreditCargoProtection(g,infoContainer);
			_local2.y = _local6;
			container.addChild(_local2);
			items.push(_local2);
			_local2.addEventListener("select",onSelect);
			_local2.addEventListener("bought",bought);
			if(state == "tractorBeam") {
				_local8.select();
			} else if(state == "xpBoost") {
				_local1.select();
			} else if(state == "xpProtection") {
				_local7.select();
			} else if(state == "cargoProtection") {
				_local2.select();
			} else if(state == "supporterPackage") {
				_local5.select();
			} else if(state == "podPackage") {
				pods.select();
			}
		}
		
		private function onRedeem(e:TouchEvent) : void {
			var redeem:Redeem;
			select(pods);
			redeem = new Redeem(g);
			redeem.addEventListener("close",function(param1:Event):void {
				redeem.removeEventListeners();
				g.removeChildFromOverlay(redeem);
				redeemButton.enabled = true;
			});
			redeem.addEventListener("success",function(param1:Event):void {
				redeem.removeEventListeners();
				g.removeChildFromOverlay(redeem);
				dispatchEventWith("close");
			});
			g.addChildToOverlay(redeem);
		}
		
		private function refreshCreditManager() : void {
			g.creditManager.refresh(function():void {
				updateCreditText();
			});
		}
		
		private function updateCreditText(e:Event = null) : void {
			balance.text = Localize.t("You have: ") + CreditManager.FLUX;
			balance.alignRight();
		}
		
		private function onSelect(e:TouchEvent) : void {
			var _local3:ICreditItem = e.target as ICreditItem;
			for each(var _local2 in items) {
				if(_local3 != _local2) {
					_local2.deselect();
				}
			}
		}
		
		private function select(selectedItem:ICreditItem) : void {
			deselectAll();
			selectedItem.select();
		}
		
		private function deselectAll() : void {
			for each(var _local1 in items) {
				_local1.deselect();
			}
		}
		
		private function bought(e:Event) : void {
			refreshCreditManager();
			for each(var _local2 in items) {
				_local2.update();
			}
		}
		
		public function update() : void {
		}
		
		public function exit() : void {
			for each(var _local2 in items) {
				_local2.exit();
			}
			g.creditManager.removeEventListener("refresh",refreshCreditManager);
			for each(var _local1 in items) {
				_local1.removeEventListeners();
			}
			removeChild(container,true);
		}
	}
}

