package core.hud.components.credits
{
	import core.scene.Game;
	import generics.Localize;
	import playerio.Message;
	import starling.display.Sprite;
	
	public class CreditCargoProtection extends CreditDayItem
	{
		private var selectedDays:int;
		
		private var price:int;
		
		public function CreditCargoProtection(param1:Game, param2:Sprite)
		{
			super(param1, param2);
			bitmap = "ti_cargo_protection.png";
			description = Localize.t("Junk is valuable. Make sure you don't lose it. This will keep your junk in cargo when you are killed.");
			itemLabel = Localize.t("Cargo Protection");
			preview = "cargo_protection_preview.png";
			confirmText = Localize.t("This will add cargo protection to your ship.");
			aquired = param1.me.hasCargoProtection();
			expiryTime = param1.me.cargoProtection;
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
			g.rpc("buyCargoProtection", onBuyCargoProtection, param1);
		}
		
		private function onBuyCargoProtection(param1:Message):void
		{
			if (!param1.getBoolean(0))
			{
				showFailed(param1.getString(1));
				return;
			}
			Game.trackEvent("used flux", "cargo protection", selectedDays + " days", price);
			g.infoMessageDialog(Localize.t("Purchase successful!"));
			g.me.cargoProtection = param1.getNumber(1);
			expiryTime = param1.getNumber(1);
			aquired = g.me.hasCargoProtection();
			updateAquiredText();
			updateContainers();
			dispatchEventWith("bought");
		}
	}
}
