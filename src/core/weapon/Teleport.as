package core.weapon
{
	import core.scene.Game;
	import core.ship.PlayerShip;
	
	public class Teleport extends Weapon
	{
		public function Teleport(param1:Game)
		{
			super(param1);
		}
		
		override protected function shoot():void
		{
			var _loc1_:PlayerShip = null;
			if (hasChargeUp)
			{
				_loc1_ = unit as PlayerShip;
				if (fireNextTime < g.time)
				{
					if (chargeUpTime == 0)
					{
						if (fireEffect != "")
						{
							_loc1_.startChargeUpEffect(fireEffect);
						}
						else
						{
							_loc1_.startChargeUpEffect();
						}
					}
					chargeUpTime += 33;
					if (_loc1_.player.isMe)
					{
						if (chargeUpTime < chargeUpTimeMax)
						{
							g.hud.powerBar.updateLoadBar(chargeUpTime / chargeUpTimeMax);
						}
						else
						{
							g.hud.powerBar.updateLoadBar(1);
						}
					}
				}
				else if (_loc1_.player.isMe)
				{
					g.hud.powerBar.updateLoadBar(0);
					chargeUpTime = 0;
				}
				return;
			}
		}
		
		public function updateCooldown():void
		{
			if (fireCallback != null && this.hasChargeUp == true && (projectiles.length + 1 < maxProjectiles || maxProjectiles == 0))
			{
				lastFire = g.time;
				fireNextTime = g.time + reloadTime;
				fireCallback();
			}
		}
	}
}
