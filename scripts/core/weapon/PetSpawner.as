package core.weapon {
	import core.scene.Game;
	import core.ship.PlayerShip;
	
	public class PetSpawner extends Weapon {
		public var maxPets:int;
		
		public function PetSpawner(g:Game) {
			super(g);
		}
		
		override public function init(obj:Object, techLevel:int, eliteTechLevel:int = -1, eliteTech:String = "") : void {
			var _local5:int = 0;
			var _local6:Object = null;
			super.init(obj,techLevel,eliteTechLevel,eliteTech);
			maxPets = 1;
			if(obj.hasOwnProperty("maxPets")) {
				maxPets = obj.maxPets;
			}
			if(techLevel > 0) {
				_local6 = obj.techLevels[techLevel - 1];
				if(_local6.hasOwnProperty("maxPets")) {
					maxPets = _local6.maxPets;
				}
			}
			reloadTime = 40 * 60;
		}
		
		override protected function shoot() : void {
			var _local2:PlayerShip = null;
			var _local3:Number = NaN;
			var _local1:Number = Number(g.time.valueOf());
			if(fireNextTime < g.time) {
				if(unit is PlayerShip) {
					_local2 = unit as PlayerShip;
					if(!_local2.weaponHeat.canFire(heatCost)) {
						fireNextTime += 40 * 60;
						return;
					}
				}
				_local3 = 40 * 60;
				if(fireNextTime == 0 || lastFire == 0 || burstCurrent > 1) {
					fireNextTime = _local1 + _local3 - 33;
				} else {
					fireNextTime += _local3;
				}
				lastFire = g.time;
			}
		}
	}
}

