package core.weapon
{
	import core.scene.Game;
	import core.ship.PlayerShip;

	public class Heat
	{
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
		public function Heat(param1:Game, param2:PlayerShip)
		{
			super();
			this.s = param2;
			this.g = param1;
			_lockoutEnd = 0;
			_max = 1;
			_regen = 0.05;
			_current = _max;
			_lastUpdate = 0;
		}

		public function setBonuses(param1:Number, param2:Number):void
		{
			_max = 1 * param1;
			_regen = 0.05 * param2;
		}

		public function pause(param1:Number):void
		{
			_lockoutEnd = g.time + param1 * 1000;
		}

		public function update():void
		{
			var _loc1_:Number = g.time;
			if (_lockoutEnd > _loc1_)
			{
				_lastUpdate = _loc1_;
				return;
			}
			if (_current > 0.25)
			{
				_current += 4 * _regen * (_loc1_ - _lastUpdate) / 1000;
			}
			else
			{
				_current += 2 * _regen * (_loc1_ - _lastUpdate) / 1000;
			}
			_lastUpdate = _loc1_;
			if (_current > _max)
			{
				_current = _max;
			}
		}

		public function canFire(param1:Number, param2:Boolean = false):Boolean
		{
			if (s != null && s.usingDmgBoost)
			{
				param1 *= 1 + s.dmgBoostCost;
			}
			if (_current < param1 && !param2)
			{
				return false;
			}
			_current -= param1;
			return true;
		}

		public function setHeat(param1:Number):void
		{
			_current = param1;
		}

		public function get max():Number
		{
			return _max;
		}

		public function get heat():Number
		{
			if (_current < 0)
			{
				return 0;
			}
			if (_current > _max)
			{
				return _max;
			}
			return _current;
		}
	}
}
