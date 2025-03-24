package core.weapon {
	import core.scene.Game;
	import core.ship.PlayerShip;
	
	public class Heat {
		public static const LOCKOUT_TIME:int = 2000;
		
		public static const MAX:Number = 1;
		
		public static const REGEN:Number = 0.05;
		
		private var _lastUpdate:Number;
		
		private var _regen:Number;
		
		private var _current:Number;
		
		private var _max:Number = 1;
		
		private var _lockoutEnd:Number;
		
		private var g:Game;
		
		private var time:Number;
		
		private var reg:Number;
		
		private var cost:Number;
		
		private var n:int;
		
		private var s:PlayerShip;
		
		public function Heat(g:Game, ship:PlayerShip) {
			super();
			this.s = ship;
			this.g = g;
			_lockoutEnd = 0;
			_max = 1;
			_regen = 0.05;
			_current = _max;
			_lastUpdate = 0;
		}
		
		public function setBonuses(bonus_max:Number, bonus_reg:Number) : void {
			_max = 1 * bonus_max;
			_regen = 0.05 * bonus_reg;
		}
		
		public function pause(seconds:Number) : void {
			_lockoutEnd = g.time + seconds * 1000;
		}
		
		public function update() : void {
			var _local1:Number = g.time;
			if(_lockoutEnd > _local1) {
				_lastUpdate = _local1;
				return;
			}
			if(_current > 0.25) {
				_current += 4 * _regen * (_local1 - _lastUpdate) / 1000;
			} else {
				_current += 2 * _regen * (_local1 - _lastUpdate) / 1000;
			}
			_lastUpdate = _local1;
			if(_current > _max) {
				_current = _max;
			}
		}
		
		public function canFire(energyCost:Number, forced:Boolean = false) : Boolean {
			if(s != null && s.usingDmgBoost) {
				energyCost *= 1 + s.dmgBoostCost;
			}
			if(_current < energyCost && !forced) {
				return false;
			}
			_current -= energyCost;
			return true;
		}
		
		public function setHeat(value:Number) : void {
			_current = value;
		}
		
		public function get max() : Number {
			return _max;
		}
		
		public function get heat() : Number {
			if(_current < 0) {
				return 0;
			}
			if(_current > _max) {
				return _max;
			}
			return _current;
		}
	}
}

