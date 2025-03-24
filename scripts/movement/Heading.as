package movement {
	import flash.geom.Point;
	import generics.Util;
	import playerio.Message;
	
	public class Heading {
		public static const NR_OF_VARS:int = 10;
		
		public var time:Number = 0;
		
		public var pos:Point = new Point();
		
		public var rotation:Number = 0;
		
		public var speed:Point = new Point();
		
		public var rotateLeft:Boolean = false;
		
		public var rotateRight:Boolean = false;
		
		public var accelerate:Boolean = false;
		
		public var deaccelerate:Boolean = false;
		
		public var roll:Boolean = false;
		
		public function Heading() {
			super();
		}
		
		public function parseMessage(m:Message, i:int) : int {
			this.time = m.getNumber(i);
			this.pos.x = 0.01 * m.getInt(i + 1);
			this.pos.y = 0.01 * m.getInt(i + 2);
			this.speed.x = 0.01 * m.getInt(i + 3);
			this.speed.y = 0.01 * m.getInt(i + 4);
			this.rotation = 0.001 * m.getInt(i + 5);
			this.accelerate = m.getBoolean(i + 6);
			this.deaccelerate = m.getBoolean(i + 7);
			this.rotateLeft = m.getBoolean(i + 8);
			this.rotateRight = m.getBoolean(i + 9);
			return i + 10;
		}
		
		public function populateMessage(m:Message) : Message {
			m.add(time);
			m.add(pos.x);
			m.add(pos.y);
			m.add(speed.x);
			m.add(speed.y);
			m.add(rotation);
			m.add(accelerate);
			m.add(deaccelerate);
			m.add(rotateLeft);
			m.add(rotateRight);
			return m;
		}
		
		public function almostEqual(h2:Heading) : Boolean {
			var _local2:Number = 0.01;
			if(Math.abs(this.pos.x - h2.pos.x) > _local2) {
				return false;
			}
			if(Math.abs(this.pos.y - h2.pos.y) > _local2) {
				return false;
			}
			if(Math.abs(this.rotation - h2.rotation) > _local2) {
				return false;
			}
			if(Math.abs(this.speed.x - h2.speed.x) > _local2) {
				return false;
			}
			if(Math.abs(this.speed.y - h2.speed.y) > _local2) {
				return false;
			}
			return true;
		}
		
		public function copy(heading:Heading) : void {
			this.time = heading.time;
			this.pos.x = heading.pos.x;
			this.pos.y = heading.pos.y;
			this.rotation = heading.rotation;
			this.speed.x = heading.speed.x;
			this.speed.y = heading.speed.y;
			this.accelerate = heading.accelerate;
			this.deaccelerate = heading.deaccelerate;
			this.rotateLeft = heading.rotateLeft;
			this.rotateRight = heading.rotateRight;
		}
		
		public function clone() : Heading {
			var _local1:Heading = new Heading();
			_local1.copy(this);
			return _local1;
		}
		
		public function runCommand(cmd:Command) : void {
			switch(cmd.type) {
				case 0:
					this.accelerate = cmd.active;
					break;
				case 1:
					this.rotateLeft = cmd.active;
					break;
				case 2:
					this.rotateRight = cmd.active;
					break;
				case 4:
					accelerate = true;
					deaccelerate = true;
					rotateLeft = false;
					rotateRight = false;
					break;
				case 8:
					this.deaccelerate = cmd.active;
			}
		}
		
		public function toString() : String {
			return "x:" + Util.formatDecimal(pos.x,1) + ", y:" + Util.formatDecimal(pos.y,1) + ", angle:" + Util.formatDecimal(rotation,1) + ", speedX:" + Util.formatDecimal(speed.x,1) + ", speedY:" + Util.formatDecimal(speed.y,1) + ", time:" + time;
		}
		
		public function reset() : void {
			this.time = 0;
			this.pos.x = 0;
			this.pos.y = 0;
			this.rotation = 0;
			this.speed.x = 0;
			this.speed.y = 0;
			this.accelerate = false;
			this.deaccelerate = false;
			this.rotateLeft = false;
			this.rotateRight = false;
		}
	}
}

