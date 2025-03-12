package core.solarSystem
{
	import flash.geom.Point;
	
	public class BodyHeading
	{
		public var time:Number = 0;
		public var pos:Point;
		
		public var angle:Number = 0;
		public var orbitAngle:Number = 0;
		public var orbitRadius:Number = 0;
		public var orbitSpeed:Number = 0;
		public var rotationSpeed:Number = 0;
		private var body:Body;
		
		public function BodyHeading(param1:Body)
		{
			pos = new Point();
			super();
			this.body = param1;
			pos = new Point();
		}
		
		public function update(param1:Number, param2:Number):void
		{
			var _loc6_:Number = NaN;
			var _loc5_:Number = NaN;
			var _loc3_:Number = NaN;
			var _loc4_:Number = NaN;
			if (body.parentBody != null)
			{
				_loc6_ = body.parentBody.pos.x;
				_loc5_ = body.parentBody.pos.y;
				_loc3_ = orbitRadius * Math.cos(orbitAngle + orbitSpeed * (33 / 1000) * (param2 - param1));
				_loc4_ = orbitRadius * Math.sin(orbitAngle + orbitSpeed * (33 / 1000) * (param2 - param1));
				pos.x = _loc3_ + _loc6_;
				pos.y = _loc4_ + _loc5_;
			}
			angle += rotationSpeed;
			time += 33;
		}
		
		public function parseJSON(param1:Object):void
		{
			this.time = param1.time;
			this.pos.x = param1.x;
			this.pos.y = param1.y;
			this.angle = param1.angle;
			this.orbitAngle = param1.orbitAngle;
			this.orbitRadius = param1.orbitRadius;
			this.orbitSpeed = param1.orbitSpeed;
			this.rotationSpeed = param1.rotationSpeed;
		}
		
		public function clone():BodyHeading
		{
			var _loc1_:BodyHeading = new BodyHeading(body);
			_loc1_.angle = this.angle;
			_loc1_.orbitAngle = this.orbitAngle;
			_loc1_.orbitRadius = this.orbitRadius;
			_loc1_.orbitSpeed = this.orbitSpeed;
			_loc1_.rotationSpeed = this.rotationSpeed;
			_loc1_.pos.x = this.pos.x;
			_loc1_.pos.y = this.pos.y;
			_loc1_.time = this.time;
			return _loc1_;
		}
		
		public function toString():String
		{
			return "pos: " + pos.toString() + ", orbitAngle: " + orbitAngle + ", orbitSpeed: " + orbitSpeed + ", orbitRadius: " + orbitRadius + ", rotationSpeed: " + rotationSpeed + ", time:" + time;
		}
	}
}
