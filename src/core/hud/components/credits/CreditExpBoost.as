package core.hud.components.credits
{
	import core.scene.Game;
	import generics.Localize;
	import playerio.Message;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class CreditExpBoost extends CreditDayItem
	{
		private var selectedDays:int;
		
		private var price:int;
		
		public function CreditExpBoost(param1:Game, param2:Sprite)
		{
			super(param1, param2);
			bitmap = "ti_xp_boost.png";
			description = Localize.t("Increases experience gain with 100% for enemy kills and 30% for PvP and missions.");
			itemLabel = Localize.t("XP Boost");
			preview = "xp_boost_preview.png";
			confirmText = Localize.t("This will add xp boost to your ship.");
			aquired = param1.me.hasExpBoost;
			expiryTime = param1.me.expBoost;
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
			g.rpc("buyExpBoost", onBuyTractorBeam, param1);
		}
		
		private function onBuyTractorBeam(param1:Message):void
		{
			if (!param1.getBoolean(0))
			{
				showFailed(param1.getString(1));
				return;
			}
			Game.trackEvent("used flux", "xp boost", selectedDays + " days", price);
			g.infoMessageDialog(Localize.t("Purchase successful!"));
			g.me.expBoost = param1.getNumber(1);
			expiryTime = param1.getNumber(1);
			aquired = g.me.hasExpBoost;
			updateAquiredText();
			updateContainers();
			dispatchEvent(new Event("bought"));
		}
	}
}
