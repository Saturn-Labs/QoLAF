package core.hud.components.credits
{
	import core.scene.Game;
	import generics.Localize;
	import playerio.Message;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class CreditTractorBeam extends CreditDayItem
	{
		private var selectedDays:int;
		
		private var price:int;
		
		public function CreditTractorBeam(param1:Game, param2:Sprite)
		{
			super(param1, param2);
			bitmap = "ti_tractor_beam.png";
			description = Localize.t("Junk nearby the ship will be locked to a tractor beam and pulled in automatically.");
			itemLabel = Localize.t("Tractor Beam");
			preview = "tractor_beam_preview.png";
			confirmText = Localize.t("This will add tractor beam to your ship.");
			aquired = param1.me.hasTractorBeam();
			expiryTime = param1.me.tractorBeam;
			bundles.push({"days": 1, "cost": CreditDayItem.PRICE_1_DAY});
			bundles.push({"days": 3, "cost": CreditDayItem.PRICE_3_DAY});
			bundles.push({"days": 7, "cost": CreditDayItem.PRICE_7_DAY});
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
			g.rpc("buyTractorBeam", onBuyTractorBeam, param1);
		}
		
		private function onBuyTractorBeam(param1:Message):void
		{
			if (!param1.getBoolean(0))
			{
				showFailed(param1.getString(1));
				return;
			}
			Game.trackEvent("used flux", "tractor beam", selectedDays + " days", price);
			g.infoMessageDialog(Localize.t("Purchase successful!"));
			g.me.tractorBeam = param1.getNumber(1);
			expiryTime = param1.getNumber(1);
			aquired = g.me.hasTractorBeam();
			updateAquiredText();
			updateContainers();
			dispatchEvent(new Event("bought"));
		}
	}
}
