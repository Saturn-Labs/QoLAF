package core.engine {
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.ship.Ship;
	import data.DataLocator;
	import data.IDataManager;
	
	public class EngineFactory {
		public function EngineFactory() {
			super();
		}
		
		public static function create(key:String, g:Game, s:Ship) : Engine {
			var _local5:Engine = null;
			var _local4:PlayerShip = null;
			var _local7:IDataManager = DataLocator.getService();
			var _local6:Object = _local7.loadKey("Engines",key);
			if(!g.isLeaving) {
				_local5 = new Engine(g);
				_local5.obj = _local6;
				_local5.name = _local6.name;
				_local5.ship = s;
				_local5.speed = _local6.speed == 0 ? 0.000001 : _local6.speed;
				_local5.acceleration = _local6.acceleration == 0 ? 0.000001 : _local6.acceleration;
				_local5.rotationSpeed = _local6.rotationSpeed == 0 ? 0.000001 : _local6.rotationSpeed;
				if(!_local6.ribbonTrail) {
				}
				if(s is PlayerShip) {
					_local4 = s as PlayerShip;
					_local5.rotationMod = _local4.player.rotationSpeedMod;
				}
				if(_local6.dual) {
					_local5.dual = true;
				}
				if(_local6.dualDistance) {
					_local5.dualDistance = _local6.dualDistance;
				}
				_local5.alive = true;
				_local5.accelerating = false;
				return _local5;
			}
			return null;
		}
	}
}

