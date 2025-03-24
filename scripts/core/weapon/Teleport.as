package core.weapon {
	import core.scene.Game;
	import core.ship.PlayerShip;
	
	public class Teleport extends Weapon {
		public function Teleport(g:Game) {
			super(g);
		}
		
		override protected function shoot() : void {
			var _local1:PlayerShip = null;
			if(hasChargeUp) {
				_local1 = unit as PlayerShip;
				if(fireNextTime < g.time) {
					if(chargeUpTime == 0) {
						if(fireEffect != "") {
							_local1.startChargeUpEffect(fireEffect);
						} else {
							_local1.startChargeUpEffect();
						}
					}
					chargeUpTime += 33;
					if(_local1.player.isMe) {
						if(chargeUpTime < chargeUpTimeMax) {
							g.hud.powerBar.updateLoadBar(chargeUpTime / chargeUpTimeMax);
						} else {
							g.hud.powerBar.updateLoadBar(1);
						}
					}
				} else if(_local1.player.isMe) {
					g.hud.powerBar.updateLoadBar(0);
					chargeUpTime = 0;
				}
				return;
			}
		}
		
		public function updateCooldown() : void {
			if(fireCallback != null && this.hasChargeUp == true && (projectiles.length + 1 < maxProjectiles || maxProjectiles == 0)) {
				lastFire = g.time;
				fireNextTime = g.time + reloadTime;
				fireCallback();
			}
		}
	}
}

