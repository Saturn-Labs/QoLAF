package core.boss {
	import core.scene.Game;
	import core.solarSystem.Body;
	import flash.geom.Point;
	
	public class Waypoint {
		private var _pos:Point;
		
		private var target:Body;
		
		public var id:int;
		
		public function Waypoint(g:Game, key:String, x:Number, y:Number, id:int) {
			super();
			this.id = id;
			if(key != null) {
				target = g.bodyManager.getBodyByKey(key);
			}
			if(target == null) {
				_pos = new Point(x,y);
			}
		}
		
		public function get pos() : Point {
			if(target != null) {
				return new Point(target.pos.x,target.pos.y);
			}
			return _pos;
		}
	}
}

