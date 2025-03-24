package core.hud.components.credits {
	import core.scene.Game;
	import generics.Localize;
	import playerio.Message;
	import starling.display.Sprite;
	
	public class CreditXpProtection extends CreditDayItem {
		private var selectedDays:int;
		
		private var price:int;
		
		public function CreditXpProtection(g:Game, parent:Sprite) {
			super(g,parent);
			bitmap = "ti_xp_protection.png";
			description = Localize.t("Protects you from losing xp when you are killed.");
			itemLabel = Localize.t("Xp Protection");
			preview = "xp_protection_preview.png";
			confirmText = Localize.t("This will add xp protection to your ship.");
			aquired = g.me.hasXpProtection();
			expiryTime = g.me.xpProtection;
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
			g.rpc("buyXpProtection",onBuyXpProtection,days);
		}
		
		private function onBuyXpProtection(m:Message) : void {
			if(!m.getBoolean(0)) {
				showFailed(m.getString(1));
				return;
			}
			Game.trackEvent("used flux","xp protection",selectedDays + " days",price);
			g.infoMessageDialog(Localize.t("Purchase successful!"));
			g.me.xpProtection = m.getNumber(1);
			expiryTime = m.getNumber(1);
			aquired = g.me.hasXpProtection();
			updateAquiredText();
			updateContainers();
			dispatchEventWith("bought");
		}
		
		override protected function updateAquiredText() : void {
			super.updateAquiredText();
			if(g.me.level <= 15) {
				aquiredText.text = "Aquired!\nFree for all players below level 16.";
			}
		}
	}
}

