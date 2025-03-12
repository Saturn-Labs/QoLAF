package core.weapon
{
	import core.scene.Game;
	
	public class WeaponManager
	{
		public var weapons:Vector.<Weapon>;
		
		private var g:Game;
		
		public function WeaponManager(param1:Game)
		{
			weapons = new Vector.<Weapon>();
			super();
			this.g = param1;
		}
		
		public function update():void
		{
			var _loc3_:int = 0;
			var _loc1_:Weapon = null;
			var _loc2_:int = int(weapons.length);
			_loc3_ = _loc2_ - 1;
			while (_loc3_ > -1)
			{
				_loc1_ = weapons[_loc3_];
				if (!_loc1_.alive)
				{
					removeWeapon(_loc3_);
				}
				_loc3_--;
			}
		}
		
		public function getWeapon(param1:String):Weapon
		{
			var _loc2_:Weapon = null;
			switch (param1)
			{
			case "blaster": 
				_loc2_ = new Blaster(g);
				break;
			case "instant": 
				_loc2_ = new Instant(g);
				break;
			case "beam": 
				_loc2_ = new Beam(g);
				break;
			case "smartGun": 
				_loc2_ = new SmartGun(g);
				break;
			case "teleport": 
				_loc2_ = new Teleport(g);
				break;
			case "cloak": 
				_loc2_ = new Cloak(g);
				break;
			case "petSpawner": 
				_loc2_ = new PetSpawner(g);
				break;
			default: 
				_loc2_ = new ProjectileGun(g);
			}
			_loc2_.reset();
			weapons.push(_loc2_);
			return _loc2_;
		}
		
		private function removeWeapon(param1:int):void
		{
			weapons.splice(param1, 1);
		}
	}
}
