package core.hud.components.credits
{
	import core.hud.components.Box;
	import core.hud.components.Button;
	import core.hud.components.hangar.SkinItem;
	import core.scene.Game;
	import feathers.controls.ScrollContainer;
	import generics.Localize;
	import playerio.Message;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class CreditMegaPackage extends CreditPackageItem
	{
		private var previewBox:Box;
		
		private var overlay:Quad;
		
		public function CreditMegaPackage(param1:Game, param2:Sprite, param3:Boolean = false)
		{
			super(param1, param2, param3);
			load();
		}
		
		override protected function load():void
		{
			var scrollContainer:ScrollContainer;
			var previewButton:Button;
			var previewButton2:Button;
			var previewButton3:Button;
			var closeButton:Button;
			description = Localize.t("Buy the mega package, get a versatile fleet and a lot of Flux for upgrades!<font color='#ffaa44'>\n\n- [amount] Flux\n\n- Tanker A1 (new ship)\n\n- Crystal (new ship)\n\n- Medic C2 (new ship)</font>").replace("[amount]", "10 000");
			checkoutDescription = Localize.t("Mega Package:\n\n- [amount] Flux\n- Tanker A1 (new ship)\n- Crystal (new ship)\n- Medic C2 (new ship)").replace("[amount]", "10 000");
			checkoutDescriptionShort = Localize.t("[amount] Flux + Tanker A1 (new ship) + Crystal (new ship) + Medic C2 (new ship)").replace("[amount]", "10 000");
			bitmap = "ti_megapackage.png";
			itemLabel = Localize.t("Mega Package");
			itemKey = "megapackage";
			buyButtonText = Localize.t("Buy");
			rpcFunction = "buyMegaPackage";
			preview = "megapackage_preview.png";
			aquired = g.me.megaPackage;
			previewBox = new Box(440, 460, "buy");
			previewBox.x = g.stage.stageWidth / 2 - 200;
			previewBox.y = g.stage.stageHeight / 2 - 250;
			overlay = new Quad(g.stage.stageWidth, g.stage.stageHeight, 0);
			overlay.alpha = 0.8;
			scrollContainer = new ScrollContainer();
			scrollContainer.width = 400;
			scrollContainer.height = 410;
			scrollContainer.x = 20;
			scrollContainer.y = 20;
			previewBox.addChild(scrollContainer);
			previewButton = new Button(function():void
			{
				var _loc1_:SkinItem = new SkinItem(g, g.dataManager.loadKey("Skins", "GOUN-DLB8k6x3dliHEX0XQ"), 2);
				scrollContainer.addChild(_loc1_);
				g.addChildToOverlay(overlay, true);
				g.addChildToOverlay(previewBox, true);
			}, Localize.t("Preview"), "highlight");
			previewButton.autoEnableAfterClick = true;
			previewButton.y = 280;
			previewButton.x = 180;
			previewButton.size = 10;
			infoContainer.addChild(previewButton);
			previewButton2 = new Button(function():void
			{
				var _loc1_:SkinItem = new SkinItem(g, g.dataManager.loadKey("Skins", "qR4l2lErdUugZRSToo10fw"), 2);
				scrollContainer.addChild(_loc1_);
				g.addChildToOverlay(overlay, true);
				g.addChildToOverlay(previewBox, true);
			}, Localize.t("Preview"), "highlight");
			previewButton2.autoEnableAfterClick = true;
			previewButton2.y = previewButton.y + previewButton.height + 15;
			previewButton2.x = 180;
			previewButton2.size = 10;
			infoContainer.addChild(previewButton2);
			previewButton3 = new Button(function():void
			{
				var _loc1_:SkinItem = new SkinItem(g, g.dataManager.loadKey("Skins", "xxGYahwdREakkrJusV0zHA"), 2);
				scrollContainer.addChild(_loc1_);
				g.addChildToOverlay(overlay, true);
				g.addChildToOverlay(previewBox, true);
			}, Localize.t("Preview"), "highlight");
			previewButton3.autoEnableAfterClick = true;
			previewButton3.y = previewButton2.y + previewButton2.height + 15;
			previewButton3.x = 180;
			previewButton3.size = 10;
			infoContainer.addChild(previewButton3);
			closeButton = new Button(function():void
			{
				scrollContainer.removeChildren();
				g.removeChildFromOverlay(overlay);
				g.removeChildFromOverlay(previewBox);
			}, Localize.t("Close"));
			closeButton.autoEnableAfterClick = true;
			closeButton.x = 360;
			closeButton.y = 435;
			previewBox.addChild(closeButton);
			super.load();
			g.addResizeListener(resize);
		}
		
		private function resize(param1:Event = null):void
		{
			previewBox.x = g.stage.stageWidth / 2 - 200;
			previewBox.y = g.stage.stageHeight / 2 - 250;
			overlay.width = g.stage.stageWidth;
			overlay.height = g.stage.stageHeight;
		}
		
		override protected function onSuccess(param1:Message):void
		{
			g.showMessageDialog(Localize.t("<font color='#88ff88'>Thanks!</font>.<br><br><font color='#ffff88'>Please reload the game to make sure everything is updated!</font>"));
			g.me.addNewSkin(param1.getString(1));
			g.me.addNewSkin(param1.getString(2));
			g.me.addNewSkin(param1.getString(3));
			g.creditManager.refresh();
			aquired = true;
			g.me.megaPackage = true;
			updateAquiredText();
			updateContainers();
		}
		
		override protected function updateContainers():void
		{
			super.updateContainers();
		}
		
		override public function dispose():void
		{
			g.removeResizeListener(resize);
			super.dispose();
		}
	}
}
