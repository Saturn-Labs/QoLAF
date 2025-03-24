package core.unit {
	import core.scene.Game;
	import core.ship.PlayerShip;
	import starling.display.Sprite;
	
	public class UnitManager {
		private var g:Game;
		
		public var units:Vector.<Unit> = new Vector.<Unit>();
		
		public function UnitManager(g:Game) {
			super();
			this.g = g;
		}
		
		public function add(unit:Unit, canvas:Sprite, addToRadar:Boolean = true) : void {
			units.push(unit);
			if(addToRadar) {
				g.hud.radar.add(unit);
			}
			unit.canvas = canvas;
			if(unit.isBossUnit) {
				unit.addToCanvas();
			}
			if(unit is PlayerShip) {
				unit.addToCanvas();
			}
		}
		
		public function remove(unit:Unit) : void {
			units.splice(units.indexOf(unit),1);
			g.hud.radar.remove(unit);
			unit.removeFromCanvas();
			unit.reset();
		}
		
		public function forceUpdate() : void {
			var _local1:Unit = null;
			var _local2:int = 0;
			_local2 = 0;
			while(_local2 < units.length) {
				_local1 = units[_local2];
				_local1.nextDistanceCalculation = -1;
				_local2++;
			}
		}
		
		public function getTarget(targetId:int) : Unit {
			for each(var _local2 in units) {
				if(_local2.id == targetId) {
					return _local2;
				}
			}
			return null;
		}
	}
}

