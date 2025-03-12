package core.hud.components.credits
{
	import core.scene.Game;
	import generics.Localize;
	import playerio.Message;
	import starling.display.Sprite;
	
	public class CreditXpProtection extends CreditDayItem
	{
		private var selectedDays:int;
		
		private var price:int;
		
		public function CreditXpProtection(param1:Game, param2:Sprite)
		{
			super(param1, param2);
			bitmap = "ti_xp_protection.png";
			description = Localize.t("Protects you from losing xp when you are killed.");
			itemLabel = Localize.t("Xp Protection");
			preview = "xp_protection_preview.png";
			confirmText = Localize.t("This will add xp protection to your ship.");
			aquired = param1.me.hasXpProtection();
			expiryTime = param1.me.xpProtection;
			bundles.push({"days": 1, "cost": 75});
			bundles.push({"days": 3, "cost": 215});
			bundles.push({"days": 7, "cost": 425});
			super.load();
		}
		
		override protected function onBuy(param1:int):void
		{
			super.onBuy(param1);
			selectedDays = param1;
			if (param1 == 1)
			{
				price = CreditDayItem.PRICE_1_DAY;
			}
			if (param1 == 3)
			{
				price = CreditDayItem.PRICE_3_DAY;
			}
			if (param1 == 7)
			{
				price = CreditDayItem.PRICE_7_DAY;
			}
			g.rpc("buyXpProtection", onBuyXpProtection, param1);
		}
		
		private function onBuyXpProtection(param1:Message):void
		{
			if (!param1.getBoolean(0))
			{
				showFailed(param1.getString(1));
				return;
			}
			Game.trackEvent("used flux", "xp protection", selectedDays + " days", price);
			g.infoMessageDialog(Localize.t("Purchase successful!"));
			g.me.xpProtection = param1.getNumber(1);
			expiryTime = param1.getNumber(1);
			aquired = g.me.hasXpProtection();
			updateAquiredText();
			updateContainers();
			dispatchEventWith("bought");
		}
		
		override protected function updateAquiredText():void
		{
			super.updateAquiredText();
			if (g.me.level <= 15)
			{
				aquiredText.text = "Aquired!\nFree for all players below level 16.";
			}
		}
	}
}
