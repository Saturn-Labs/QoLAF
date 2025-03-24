package core.weapon {
	import core.scene.Game;
	
	public class WeaponManager {
		public var weapons:Vector.<Weapon> = new Vector.<Weapon>();
		
		private var g:Game;
		
		public function WeaponManager(g:Game) {
			super();
			this.g = g;
		}
		
		public function update() : void {
			var _local2:int = 0;
			var _local1:Weapon = null;
			var _local3:int = int(weapons.length);
			_local2 = _local3 - 1;
			while(_local2 > -1) {
				_local1 = weapons[_local2];
				if(!_local1.alive) {
					removeWeapon(_local2);
				}
				_local2--;
			}
		}
		
		public function getWeapon(type:String) : Weapon {
			var _local2:Weapon = null;
			switch(type) {
				case "blaster":
					_local2 = new Blaster(g);
					break;
				case "instant":
					_local2 = new Instant(g);
					break;
				case "beam":
					_local2 = new Beam(g);
					break;
				case "smartGun":
					_local2 = new SmartGun(g);
					break;
				case "teleport":
					_local2 = new Teleport(g);
					break;
				case "cloak":
					_local2 = new Cloak(g);
					break;
				case "petSpawner":
					_local2 = new PetSpawner(g);
					break;
				default:
					_local2 = new ProjectileGun(g);
			}
			_local2.reset();
			weapons.push(_local2);
			return _local2;
		}
		
		private function removeWeapon(index:int) : void {
			weapons.splice(index,1);
		}
	}
}

