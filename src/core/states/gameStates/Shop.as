package core.states.gameStates
{
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
	
	public class Shop extends Sprite
	{
		private var g:Game;
		
		private var container:Sprite;
		
		private var infoContainer:Sprite;
		
		private var bg:Image;
		
		private var items:Array;
		
		private var closeButton:ButtonExpandableHud;
		
		private var balance:CreditLabel;
		
		private var textureManager:ITextureManager;
		
		private var redeemButton:Button;
		
		private var state:String;
		
		private var pods:CreditPods;
		
		public function Shop(param1:Game, param2:String = "")
		{
			var g:Game = param1;
			var state:String = param2;
			container = new ScrollContainer();
			infoContainer = new Sprite();
			items = [];
			balance = new CreditLabel();
			super();
			this.g = g;
			this.state = state;
			textureManager = TextureLocator.getService();
			closeButton = new ButtonExpandableHud(function():void
			{
				dispatchEventWith("close");
			}, Localize.t("close"));
		}
		
		public function load(param1:Function):void
		{
			var name:TextBitmap;
			var description:TextBitmap;
			var getMoreButton:Button;
			var callback:Function = param1;
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
			name = new TextBitmap(60, 50, Localize.t("Flux Shop"), 30);
			addChild(name);
			description = new TextBitmap();
			description.text = Localize.t("Buy cool stuff to support the game");
			description.format.color = 11184810;
			description.x = 60;
			description.y = name.y + name.height + 5;
			addChild(description);
			balance.x = 570;
			balance.y = 70;
			balance.size = 12;
			addChild(balance);
			refreshCreditManager();
			getMoreButton = new Button(function():void
			{
				var buyFlux:BuyFlux;
				select(pods);
				buyFlux = new BuyFlux(g);
				buyFlux.addEventListener("buyFluxClose", function():void
				{
					buyFlux.removeEventListeners("buyFluxClose");
					g.removeChildFromOverlay(buyFlux);
					refreshCreditManager();
					getMoreButton.enabled = true;
				});
				g.addChildToOverlay(buyFlux);
			}, Localize.t("Get more"), "positive");
			getMoreButton.x = balance.x + 45;
			getMoreButton.y = balance.y;
			getMoreButton.alignWithText();
			addChild(getMoreButton);
			redeemButton = new Button(onRedeem, Localize.t("Redeem"), "positive");
			redeemButton.x = getMoreButton.x;
			redeemButton.y = getMoreButton.y + getMoreButton.height + 15;
			redeemButton.width = getMoreButton.width;
			redeemButton.alignWithText();
			addChild(redeemButton);
			g.creditManager.addEventListener("refresh", updateCreditText);
			loadItems();
			callback();
		}
		
		private function loadItems():void
		{
			var _loc8_:int = 0;
			pods = new CreditPods(g, infoContainer);
			pods.y = _loc8_;
			container.addChild(pods);
			items.push(pods);
			pods.addEventListener("select", onSelect);
			_loc8_ += 52;
			var _loc4_:CreditBeginnerPackage = new CreditBeginnerPackage(g, infoContainer);
			_loc4_.y = _loc8_;
			container.addChild(_loc4_);
			items.push(_loc4_);
			_loc4_.addEventListener("select", onSelect);
			_loc4_.addEventListener("bought", bought);
			_loc8_ += 52;
			var _loc7_:CreditPowerPackage = new CreditPowerPackage(g, infoContainer, false);
			_loc7_.y = _loc8_;
			container.addChild(_loc7_);
			items.push(_loc7_);
			_loc7_.addEventListener("select", onSelect);
			_loc7_.addEventListener("bought", bought);
			_loc8_ += 52;
			var _loc5_:CreditMegaPackage = new CreditMegaPackage(g, infoContainer, false);
			_loc5_.y = _loc8_;
			container.addChild(_loc5_);
			items.push(_loc5_);
			_loc5_.addEventListener("select", onSelect);
			_loc5_.addEventListener("bought", bought);
			_loc8_ += 52;
			var _loc3_:CreditSupporterItem = new CreditSupporterItem(g, infoContainer);
			_loc3_.y = _loc8_;
			container.addChild(_loc3_);
			items.push(_loc3_);
			_loc3_.addEventListener("select", onSelect);
			_loc3_.addEventListener("bought", bought);
			_loc8_ += 52;
			var _loc2_:CreditTractorBeam = new CreditTractorBeam(g, infoContainer);
			container.addChild(_loc2_);
			items.push(_loc2_);
			_loc2_.y = _loc8_;
			_loc2_.addEventListener("select", onSelect);
			_loc2_.addEventListener("bought", bought);
			_loc8_ += 52;
			var _loc9_:CreditExpBoost = new CreditExpBoost(g, infoContainer);
			_loc9_.y = _loc8_;
			container.addChild(_loc9_);
			items.push(_loc9_);
			_loc9_.addEventListener("select", onSelect);
			_loc9_.addEventListener("bought", bought);
			_loc8_ += 52;
			var _loc1_:CreditXpProtection = new CreditXpProtection(g, infoContainer);
			_loc1_.y = _loc8_;
			container.addChild(_loc1_);
			items.push(_loc1_);
			_loc1_.addEventListener("select", onSelect);
			_loc1_.addEventListener("bought", bought);
			_loc8_ += 52;
			var _loc6_:CreditCargoProtection = new CreditCargoProtection(g, infoContainer);
			_loc6_.y = _loc8_;
			container.addChild(_loc6_);
			items.push(_loc6_);
			_loc6_.addEventListener("select", onSelect);
			_loc6_.addEventListener("bought", bought);
			if (state == "tractorBeam")
			{
				_loc2_.select();
			}
			else if (state == "xpBoost")
			{
				_loc9_.select();
			}
			else if (state == "xpProtection")
			{
				_loc1_.select();
			}
			else if (state == "cargoProtection")
			{
				_loc6_.select();
			}
			else if (state == "supporterPackage")
			{
				_loc3_.select();
			}
			else if (state == "podPackage")
			{
				pods.select();
			}
		}
		
		private function onRedeem(param1:TouchEvent):void
		{
			var redeem:Redeem;
			var e:TouchEvent = param1;
			select(pods);
			redeem = new Redeem(g);
			redeem.addEventListener("close", function(param1:Event):void
			{
				redeem.removeEventListeners();
				g.removeChildFromOverlay(redeem);
				redeemButton.enabled = true;
			});
			redeem.addEventListener("success", function(param1:Event):void
			{
				redeem.removeEventListeners();
				g.removeChildFromOverlay(redeem);
				dispatchEventWith("close");
			});
			g.addChildToOverlay(redeem);
		}
		
		private function refreshCreditManager():void
		{
			g.creditManager.refresh(function():void
			{
				updateCreditText();
			});
		}
		
		private function updateCreditText(param1:Event = null):void
		{
			balance.text = Localize.t("You have: ") + CreditManager.FLUX;
			balance.alignRight();
		}
		
		private function onSelect(param1:TouchEvent):void
		{
			var _loc2_:ICreditItem = param1.target as ICreditItem;
			for each (var _loc3_:* in items)
			{
				if (_loc2_ != _loc3_)
				{
					_loc3_.deselect();
				}
			}
		}
		
		private function select(param1:ICreditItem):void
		{
			deselectAll();
			param1.select();
		}
		
		private function deselectAll():void
		{
			for each (var _loc1_:* in items)
			{
				_loc1_.deselect();
			}
		}
		
		private function bought(param1:Event):void
		{
			refreshCreditManager();
			for each (var _loc2_:* in items)
			{
				_loc2_.update();
			}
		}
		
		public function update():void
		{
		}
		
		public function exit():void
		{
			for each (var _loc2_:* in items)
			{
				_loc2_.exit();
			}
			g.creditManager.removeEventListener("refresh", refreshCreditManager);
			for each (var _loc1_:* in items)
			{
				_loc1_.removeEventListeners();
			}
			removeChild(container, true);
		}
	}
}
