package core.weapon
{
	import core.scene.Game;
	import core.ship.PlayerShip;
	
	public class PetSpawner extends Weapon
	{
		public var maxPets:int;
		
		public function PetSpawner(param1:Game)
		{
			super(param1);
		}
		
		override public function init(param1:Object, param2:int, param3:int = -1, param4:String = ""):void
		{
			var _loc6_:int = 0;
			var _loc5_:Object = null;
			super.init(param1, param2, param3, param4);
			maxPets = 1;
			if (param1.hasOwnProperty("maxPets"))
			{
				maxPets = param1.maxPets;
			}
			if (param2 > 0)
			{
				_loc5_ = param1.techLevels[param2 - 1];
				if (_loc5_.hasOwnProperty("maxPets"))
				{
					maxPets = _loc5_.maxPets;
				}
			}
			reloadTime = 2400;
		}
		
		override protected function shoot():void
		{
			var _loc2_:PlayerShip = null;
			var _loc3_:Number = NaN;
			var _loc1_:Number = Number(g.time.valueOf());
			if (fireNextTime < g.time)
			{
				if (unit is PlayerShip)
				{
					_loc2_ = unit as PlayerShip;
					if (!_loc2_.weaponHeat.canFire(heatCost))
					{
						fireNextTime += 2400;
						return;
					}
				}
				_loc3_ = 2400;
				if (fireNextTime == 0 || lastFire == 0 || burstCurrent > 1)
				{
					fireNextTime = _loc1_ + _loc3_ - 33;
				}
				else
				{
					fireNextTime += _loc3_;
				}
				lastFire = g.time;
			}
		}
	}
}
