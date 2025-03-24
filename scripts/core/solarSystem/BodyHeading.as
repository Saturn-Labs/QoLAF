package core.solarSystem {
	import flash.geom.Point;
	
	public class BodyHeading {
		public var time:Number = 0;
		
		public var pos:Point = new Point();
		
		public var angle:Number = 0;
		
		public var orbitAngle:Number = 0;
		
		public var orbitRadius:Number = 0;
		
		public var orbitSpeed:Number = 0;
		
		public var rotationSpeed:Number = 0;
		
		private var body:Body;
		
		public function BodyHeading(body:Body) {
			super();
			this.body = body;
			pos = new Point();
		}
		
		public function update(startTime:Number, currentTime:Number) : void {
			var _local3:Number = NaN;
			var _local4:Number = NaN;
			var _local5:Number = NaN;
			var _local6:Number = NaN;
			if(body.parentBody != null) {
				_local3 = body.parentBody.pos.x;
				_local4 = body.parentBody.pos.y;
				_local5 = orbitRadius * Math.cos(orbitAngle + orbitSpeed * (33 / 1000) * (currentTime - startTime));
				_local6 = orbitRadius * Math.sin(orbitAngle + orbitSpeed * (33 / 1000) * (currentTime - startTime));
				pos.x = _local5 + _local3;
				pos.y = _local6 + _local4;
			}
			angle += rotationSpeed;
			time += 33;
		}
		
		public function parseJSON(obj:Object) : void {
			this.time = obj.time;
			this.pos.x = obj.x;
			this.pos.y = obj.y;
			this.angle = obj.angle;
			this.orbitAngle = obj.orbitAngle;
			this.orbitRadius = obj.orbitRadius;
			this.orbitSpeed = obj.orbitSpeed;
			this.rotationSpeed = obj.rotationSpeed;
		}
		
		public function clone() : BodyHeading {
			var _local1:BodyHeading = new BodyHeading(body);
			_local1.angle = this.angle;
			_local1.orbitAngle = this.orbitAngle;
			_local1.orbitRadius = this.orbitRadius;
			_local1.orbitSpeed = this.orbitSpeed;
			_local1.rotationSpeed = this.rotationSpeed;
			_local1.pos.x = this.pos.x;
			_local1.pos.y = this.pos.y;
			_local1.time = this.time;
			return _local1;
		}
		
		public function toString() : String {
			return "pos: " + pos.toString() + ", orbitAngle: " + orbitAngle + ", orbitSpeed: " + orbitSpeed + ", orbitRadius: " + orbitRadius + ", rotationSpeed: " + rotationSpeed + ", time:" + time;
		}
	}
}

