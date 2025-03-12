package core.unit
{
	import core.scene.Game;
	import core.ship.PlayerShip;
	import starling.display.Sprite;
	
	public class UnitManager
	{
		private var g:Game;
		
		public var units:Vector.<Unit>;
		
		public function UnitManager(param1:Game)
		{
			units = new Vector.<Unit>();
			super();
			this.g = param1;
		}
		
		public function add(param1:Unit, param2:Sprite, param3:Boolean = true):void
		{
			units.push(param1);
			if (param3)
			{
				g.hud.radar.add(param1);
			}
			param1.canvas = param2;
			if (param1.isBossUnit)
			{
				param1.addToCanvas();
			}
			if (param1 is PlayerShip)
			{
				param1.addToCanvas();
			}
		}
		
		public function remove(param1:Unit):void
		{
			units.splice(units.indexOf(param1), 1);
			g.hud.radar.remove(param1);
			param1.removeFromCanvas();
			param1.reset();
		}
		
		public function forceUpdate():void
		{
			var _loc1_:Unit = null;
			var _loc2_:int = 0;
			_loc2_ = 0;
			while (_loc2_ < units.length)
			{
				_loc1_ = units[_loc2_];
				_loc1_.nextDistanceCalculation = -1;
				_loc2_++;
			}
		}
		
		public function getTarget(param1:int):Unit
		{
			for each (var _loc2_:* in units)
			{
				if (_loc2_.id == param1)
				{
					return _loc2_;
				}
			}
			return null;
		}
	}
}
