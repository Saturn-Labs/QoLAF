package core.hud.components
{
	import core.credits.CreditManager;
	import core.hud.components.credits.BuyFlux;
	import core.scene.Game;
	import generics.Localize;
	import generics.Util;
	import starling.display.Image;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class BuyFluxButton extends ButtonHud
	{
		private var g:Game;
		
		private var creditText:TextField;
		
		private var fluxIcon:Image;
		
		public function BuyFluxButton(param1:Game)
		{
			var textureManager:ITextureManager;
			var payButton:ButtonHud;
			var g:Game = param1;
			super(openBuyFlux, "button_shop_bg");
			this.g = g;
			textureManager = TextureLocator.getService();
			fluxIcon = new Image(textureManager.getTextureGUIByTextureName("button_credit"));
			fluxIcon.scaleX = fluxIcon.scaleY = 0.8;
			fluxIcon.touchable = false;
			fluxIcon.x = 8;
			fluxIcon.y = 5;
			addChild(fluxIcon);
			payButton = new ButtonHud(function():void
			{
			}, "button_pay.png");
			payButton.x = 66;
			payButton.y = 4;
			addChild(payButton);
			new ToolTip(g, payButton, Localize.t("Buy Flux and support the game!"));
			creditText = new TextField(46, 20, "---", new TextFormat("font13", 13, 16777028));
			creditText.x = 20;
			creditText.y = 2;
			creditText.touchable = false;
			creditText.batchable = true;
			addChild(creditText);
			g.creditManager.refresh(function():void
			{
				updateCredits();
			});
		}
		
		private function openBuyFlux(param1:Event = null):void
		{
			var e:Event = param1;
			var buyFlux:BuyFlux = new BuyFlux(g);
			buyFlux.addEventListener("buyFluxClose", function():void
			{
				buyFlux.removeEventListeners();
				g.removeChildFromOverlay(buyFlux);
				g.creditManager.refresh(function():void
				{
					updateCredits();
				});
			});
			g.addChildToOverlay(buyFlux);
		}
		
		public function updateCredits():void
		{
			creditText.text = Util.formatAmount(CreditManager.FLUX);
			if (CreditManager.FLUX > 9999)
			{
				fluxIcon.x = 4;
				creditText.x = 20;
			}
			else
			{
				fluxIcon.x = 8;
				creditText.x = 24;
			}
		}
	}
}
