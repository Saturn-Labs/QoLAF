package core.hud.components.credits {
	import core.scene.Game;
	import generics.Localize;
	import playerio.Message;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class CreditTractorBeam extends CreditDayItem {
		private var selectedDays:int;
		
		private var price:int;
		
		public function CreditTractorBeam(g:Game, parent:Sprite) {
			super(g,parent);
			bitmap = "ti_tractor_beam.png";
			description = Localize.t("Junk nearby the ship will be locked to a tractor beam and pulled in automatically.");
			itemLabel = Localize.t("Tractor Beam");
			preview = "tractor_beam_preview.png";
			confirmText = Localize.t("This will add tractor beam to your ship.");
			aquired = g.me.hasTractorBeam();
			expiryTime = g.me.tractorBeam;
			bundles.push({
				"days":1,
				"cost":CreditDayItem.PRICE_1_DAY
			});
			bundles.push({
				"days":3,
				"cost":CreditDayItem.PRICE_3_DAY
			});
			bundles.push({
				"days":7,
				"cost":CreditDayItem.PRICE_7_DAY
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
			g.rpc("buyTractorBeam",onBuyTractorBeam,days);
		}
		
		private function onBuyTractorBeam(m:Message) : void {
			if(!m.getBoolean(0)) {
				showFailed(m.getString(1));
				return;
			}
			Game.trackEvent("used flux","tractor beam",selectedDays + " days",price);
			g.infoMessageDialog(Localize.t("Purchase successful!"));
			g.me.tractorBeam = m.getNumber(1);
			expiryTime = m.getNumber(1);
			aquired = g.me.hasTractorBeam();
			updateAquiredText();
			updateContainers();
			dispatchEvent(new Event("bought"));
		}
	}
}

