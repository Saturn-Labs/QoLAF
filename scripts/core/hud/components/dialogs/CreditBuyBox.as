package core.hud.components.dialogs {
	import core.credits.CreditManager;
	import core.hud.components.Box;
	import core.hud.components.Button;
	import core.hud.components.Text;
	import core.hud.components.TextBitmap;
	import core.hud.components.credits.BuyFlux;
	import core.scene.Game;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class CreditBuyBox extends Sprite {
		private var g:Game;
		
		private var cost:int;
		
		private var caption:String;
		
		private var textureManager:ITextureManager;
		
		private var countText:Text = new Text();
		
		private var captionText:Text = new Text();
		
		private var box:Box;
		
		private var cancelButton:Button;
		
		private var acceptButton:Button;
		
		private var bgr:Quad = new Quad(100,100,0);
		
		public function CreditBuyBox(g:Game, cost:int, caption:String) {
			super();
			this.g = g;
			this.cost = cost;
			this.caption = caption;
			textureManager = TextureLocator.getService();
			addChild(bgr);
			load();
			redraw();
			g.addResizeListener(redraw);
		}
		
		private function redraw(e:Event = null) : void {
			bgr.alpha = 0.5;
			bgr.width = g.stage.stageWidth;
			bgr.height = g.stage.stageHeight;
			box.x = Math.round(g.stage.stageWidth / 2 - box.width / 2);
			box.y = Math.round(g.stage.stageHeight / 2 - box.height / 2);
		}
		
		private function load() : void {
			var youHave:TextBitmap;
			var style:String;
			var getMoreButton:Button;
			var txt:Texture;
			var creditIcon:Image;
			box = new Box(260,4 * 60,"buy",0.8,20);
			addChild(box);
			countText.text = cost.toString();
			if(cost < 10) {
				countText.x = 60;
			} else {
				countText.x = 30;
			}
			countText.size = 50;
			countText.glow = true;
			box.addChild(countText);
			youHave = new TextBitmap(0,countText.y + countText.height + 15,"You have: " + CreditManager.FLUX);
			box.addChild(youHave);
			style = "highlight";
			if(cost > CreditManager.FLUX) {
				style = "positive";
			}
			getMoreButton = new Button(function():void {
				var buyFlux:BuyFlux = new BuyFlux(g);
				buyFlux.addEventListener("buyFluxClose",function():void {
					buyFlux.removeEventListeners();
					g.removeChildFromOverlay(buyFlux);
					g.creditManager.refresh(function():void {
						youHave.text = "You have: " + CreditManager.FLUX;
					});
					getMoreButton.enabled = true;
				});
				g.addChildToOverlay(buyFlux);
			},"Get more",style);
			getMoreButton.x = youHave.x + youHave.width + 20;
			getMoreButton.y = youHave.y;
			getMoreButton.alignWithText();
			box.addChild(getMoreButton);
			captionText.text = caption;
			captionText.wordWrap = true;
			captionText.width = box.width - 40;
			captionText.height = 40;
			captionText.x = youHave.x;
			captionText.y = youHave.y + youHave.height + 25;
			captionText.touchable = false;
			box.addChild(captionText);
			acceptButton = new Button(accept,"Buy","positive");
			acceptButton.x = 40;
			acceptButton.y = captionText.y + captionText.height + 35;
			box.addChild(acceptButton);
			cancelButton = new Button(close,"Cancel");
			cancelButton.x = acceptButton.width + acceptButton.x + 40;
			cancelButton.y = acceptButton.y;
			box.addChild(cancelButton);
			box.height = acceptButton.y + acceptButton.height;
			if(cost > CreditManager.FLUX) {
				acceptButton.enabled = false;
			}
			txt = textureManager.getTextureGUIByTextureName("credit_medium.png");
			creditIcon = new Image(txt);
			creditIcon.x = countText.x + countText.width + 20;
			creditIcon.y = 10;
			box.addChild(creditIcon);
		}
		
		public function reload() : void {
			removeChild(box,true);
			load();
			redraw();
		}
		
		private function close(e:TouchEvent) : void {
			dispatchEventWith("close");
			g.removeResizeListener(redraw);
			g.removeChildFromOverlay(this,true);
		}
		
		private function accept(e:TouchEvent) : void {
			dispatchEventWith("accept");
			g.removeResizeListener(redraw);
			g.removeChildFromOverlay(this,true);
		}
	}
}

