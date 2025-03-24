package core.hud.components.credits {
	import core.scene.Game;
	import generics.Localize;
	import playerio.Message;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class CreditExpBoost extends CreditDayItem {
		private var selectedDays:int;
		
		private var price:int;
		
		public function CreditExpBoost(g:Game, parent:Sprite) {
			super(g,parent);
			bitmap = "ti_xp_boost.png";
			description = Localize.t("Increases experience gain with 100% for enemy kills and 30% for PvP and missions.");
			itemLabel = Localize.t("XP Boost");
			preview = "xp_boost_preview.png";
			confirmText = Localize.t("This will add xp boost to your ship.");
			aquired = g.me.hasExpBoost;
			expiryTime = g.me.expBoost;
			bundles.push({
				"days":1,
				"cost":75
			});
			bundles.push({
				"days":3,
				"cost":215
			});
			bundles.push({
				"days":7,
				"cost":425
			});
			super.load();
		}
		
		override protected function onBuy(days:int) : void {
			super.onBuy(days);
			selectedDays = days;
			if(days == 1) {
				price = CreditDayItem.PRICE_1_DAY;
			}
			if(days == 3) {
				price = CreditDayItem.PRICE_3_DAY;
			}
			if(days == 7) {
				price = CreditDayItem.PRICE_7_DAY;
			}
			g.rpc("buyExpBoost",onBuyTractorBeam,days);
		}
		
		private function onBuyTractorBeam(m:Message) : void {
			if(!m.getBoolean(0)) {
				showFailed(m.getString(1));
				return;
			}
			Game.trackEvent("used flux","xp boost",selectedDays + " days",price);
			g.infoMessageDialog(Localize.t("Purchase successful!"));
			g.me.expBoost = m.getNumber(1);
			expiryTime = m.getNumber(1);
			aquired = g.me.hasExpBoost;
			updateAquiredText();
			updateContainers();
			dispatchEvent(new Event("bought"));
		}
	}
}

