package core.engine
{
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.ship.Ship;
	import data.DataLocator;
	import data.IDataManager;
	
	public class EngineFactory
	{
		public function EngineFactory()
		{
			super();
		}
		
		public static function create(param1:String, param2:Game, param3:Ship):Engine
		{
			var _loc4_:Engine = null;
			var _loc6_:PlayerShip = null;
			var _loc7_:IDataManager = DataLocator.getService();
			var _loc5_:Object = _loc7_.loadKey("Engines", param1);
			if (!param2.isLeaving)
			{
				_loc4_ = new Engine(param2);
				_loc4_.obj = _loc5_;
				_loc4_.name = _loc5_.name;
				_loc4_.ship = param3;
				_loc4_.speed = _loc5_.speed == 0 ? 0.000001 : _loc5_.speed;
				_loc4_.acceleration = _loc5_.acceleration == 0 ? 0.000001 : _loc5_.acceleration;
				_loc4_.rotationSpeed = _loc5_.rotationSpeed == 0 ? 0.000001 : _loc5_.rotationSpeed;
				if (!_loc5_.ribbonTrail)
				{
				}
				if (param3 is PlayerShip)
				{
					_loc6_ = param3 as PlayerShip;
					_loc4_.rotationMod = _loc6_.player.rotationSpeedMod;
				}
				if (_loc5_.dual)
				{
					_loc4_.dual = true;
				}
				if (_loc5_.dualDistance)
				{
					_loc4_.dualDistance = _loc5_.dualDistance;
				}
				_loc4_.alive = true;
				_loc4_.accelerating = false;
				return _loc4_;
			}
			return null;
		}
	}
}
