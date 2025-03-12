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
	
	public class CreditBeginnerPackage extends CreditPackageItem
	{
		private var previewBox:Box;
		
		private var overlay:Quad;
		
		public function CreditBeginnerPackage(param1:Game, param2:Sprite, param3:Boolean = false)
		{
			super(param1, param2, param3);
			load();
		}
		
		override protected function load():void
		{
			var scrollContainer:ScrollContainer;
			var previewButton:Button;
			var closeButton:Button;
			description = Localize.t("Buy the beginner package and get started quickly! <font color='#ffaa44'>\n\n- [flux] Flux\n- [days] days of Tractor Beam\n- New ship (Neutron X)</font>").replace("[flux]", 500).replace("[days]", 3);
			checkoutDescription = Localize.t("Beginner Package:\n\n- [flux] Flux\n- [days] days of Tractor Beam\n- Neutron X (new ship)").replace("[flux]", 500).replace("[days]", 3);
			checkoutDescriptionShort = Localize.t("[flux] Flux + [days] days of Tractor Beam + Neutron X (new ship)").replace("[flux]", 500).replace("[days]", 3);
			bitmap = "ti_beginnerpackage.png";
			itemLabel = Localize.t("Beginner Package");
			itemKey = "beginnerpackage";
			buyButtonText = Localize.t("Buy");
			rpcFunction = "buyBeginnerPackage";
			preview = "beginnerpackage_preview.png";
			previewBox = new Box(440, 460, "buy");
			previewBox.x = g.stage.stageWidth / 2 - 200;
			previewBox.y = g.stage.stageHeight / 2 - 250;
			overlay = new Quad(g.stage.stageWidth, g.stage.stageHeight, 0);
			overlay.alpha = 0.8;
			scrollContainer = new ScrollContainer();
			scrollContainer.width = 410;
			scrollContainer.height = 410;
			scrollContainer.x = 20;
			scrollContainer.y = 20;
			previewBox.addChild(scrollContainer);
			previewButton = new Button(function():void
			{
				var _loc1_:SkinItem = new SkinItem(g, g.dataManager.loadKey("Skins", "kBGo5xJkZUivH1h4MCxIkA"), 2);
				scrollContainer.addChild(_loc1_);
				g.addChildToOverlay(overlay, true);
				g.addChildToOverlay(previewBox, true);
			}, "Preview", "highlight");
			previewButton.autoEnableAfterClick = true;
			previewButton.y = 253;
			previewButton.x = 200;
			previewButton.size = 10;
			infoContainer.addChild(previewButton);
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
			aquired = g.me.beginnerPackage;
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
			g.showMessageDialog(Localize.t("<font color='#88ff88'>Thanks for buying!</font><br><br><font color='#ffff88'>If not everything is updated, please reload the game!</font>"));
			g.me.addNewSkin(param1.getString(1));
			g.me.tractorBeam = param1.getNumber(2);
			g.creditManager.refresh();
			aquired = true;
			g.me.beginnerPackage = true;
			updateAquiredText();
			updateContainers();
			g.hud.update();
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
