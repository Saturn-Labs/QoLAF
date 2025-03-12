package core.boss
{
	import core.scene.Game;
	import core.solarSystem.Body;
	import flash.geom.Point;
	
	public class Waypoint
	{
		private var _pos:Point;
		
		private var target:Body;
		
		public var id:int;
		
		public function Waypoint(param1:Game, param2:String, param3:Number, param4:Number, param5:int)
		{
			super();
			this.id = param5;
			if (param2 != null)
			{
				target = param1.bodyManager.getBodyByKey(param2);
			}
			if (target == null)
			{
				_pos = new Point(param3, param4);
			}
		}
		
		public function get pos():Point
		{
			if (target != null)
			{
				return new Point(target.pos.x, target.pos.y);
			}
			return _pos;
		}
	}
}
