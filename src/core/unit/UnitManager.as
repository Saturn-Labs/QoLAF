package core.unit
{
	import flash.geom.Rectangle;
	import starling.display.Quad;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import starling.events.Touch;
	import starling.events.Event;
	import starling.events.TouchPhase;
	import starling.filters.GlowFilter;
	import qolaf.target.TargetSystem;
	
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
		
		public function add(unit:Unit, canvas:Sprite, param3:Boolean = true):void
		{
			units.push(unit);
			if (param3)
			{
				g.hud.radar.add(unit);
			}
			
			unit.canvas = canvas;
			
			// QoLAF
			if (TargetSystem.CanTargetUnit(unit)) {
				unit.movieClip.touchable = true;
				unit.movieClip.addEventListener(TouchEvent.TOUCH, function(event:TouchEvent):void {
					var touch:Touch = event.getTouch(unit.movieClip);
					if (touch && touch.phase == TouchPhase.BEGAN) {
						Game.instance.targetSystem.SetCurrentUnit(unit);
					}
				});
			}
			
			
			if (unit.isBossUnit)
			{
				unit.addToCanvas();
			}
			if (unit is PlayerShip)
			{
				unit.addToCanvas();
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
