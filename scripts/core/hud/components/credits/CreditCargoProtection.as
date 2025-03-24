package core.hud.components.credits {
	import core.scene.Game;
	import generics.Localize;
	import playerio.Message;
	import starling.display.Sprite;
	
	public class CreditCargoProtection extends CreditDayItem {
		private var selectedDays:int;
		
		private var price:int;
		
		public function CreditCargoProtection(g:Game, parent:Sprite) {
			super(g,parent);
			bitmap = "ti_cargo_protection.png";
			description = Localize.t("Junk is valuable. Make sure you don\'t lose it. This will keep your junk in cargo when you are killed.");
			itemLabel = Localize.t("Cargo Protection");
			preview = "cargo_protection_preview.png";
			confirmText = Localize.t("This will add cargo protection to your ship.");
			aquired = g.me.hasCargoProtection();
			expiryTime = g.me.cargoProtection;
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
			g.rpc("buyCargoProtection",onBuyCargoProtection,days);
		}
		
		private function onBuyCargoProtection(m:Message) : void {
			if(!m.getBoolean(0)) {
				showFailed(m.getString(1));
				return;
			}
			Game.trackEvent("used flux","cargo protection",selectedDays + " days",price);
			g.infoMessageDialog(Localize.t("Purchase successful!"));
			g.me.cargoProtection = m.getNumber(1);
			expiryTime = m.getNumber(1);
			aquired = g.me.hasCargoProtection();
			updateAquiredText();
			updateContainers();
			dispatchEventWith("bought");
		}
	}
}

