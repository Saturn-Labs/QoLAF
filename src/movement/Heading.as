package movement
{
	import flash.geom.Point;
	import generics.Util;
	import playerio.Message;

	public class Heading
	{
		public static const NR_OF_VARS:int = 10;

		public var time:Number = 0;
		public var pos:Point;
		public var rotation:Number = 0;
		public var speed:Point;
		public var rotateLeft:Boolean = false;
		public var rotateRight:Boolean = false;
		public var accelerate:Boolean = false;
		public var deaccelerate:Boolean = false;
		public var roll:Boolean = false;
		public function Heading()
		{
			pos = new Point();
			speed = new Point();
			super();
		}

		public function parseMessage(param1:Message, param2:int):int
		{
			this.time = param1.getNumber(param2);
			this.pos.x = 0.01 * param1.getInt(param2 + 1);
			this.pos.y = 0.01 * param1.getInt(param2 + 2);
			this.speed.x = 0.01 * param1.getInt(param2 + 3);
			this.speed.y = 0.01 * param1.getInt(param2 + 4);
			this.rotation = 0.001 * param1.getInt(param2 + 5);
			this.accelerate = param1.getBoolean(param2 + 6);
			this.deaccelerate = param1.getBoolean(param2 + 7);
			this.rotateLeft = param1.getBoolean(param2 + 8);
			this.rotateRight = param1.getBoolean(param2 + 9);
			return param2 + 10;
		}

		public function populateMessage(param1:Message):Message
		{
			param1.add(time);
			param1.add(pos.x);
			param1.add(pos.y);
			param1.add(speed.x);
			param1.add(speed.y);
			param1.add(rotation);
			param1.add(accelerate);
			param1.add(deaccelerate);
			param1.add(rotateLeft);
			param1.add(rotateRight);
			return param1;
		}

		public function almostEqual(param1:Heading):Boolean
		{
			var _loc2_:Number = 0.01;
			if (Math.abs(this.pos.x - param1.pos.x) > _loc2_)
			{
				return false;
			}
			if (Math.abs(this.pos.y - param1.pos.y) > _loc2_)
			{
				return false;
			}
			if (Math.abs(this.rotation - param1.rotation) > _loc2_)
			{
				return false;
			}
			if (Math.abs(this.speed.x - param1.speed.x) > _loc2_)
			{
				return false;
			}
			if (Math.abs(this.speed.y - param1.speed.y) > _loc2_)
			{
				return false;
			}
			return true;
		}

		public function copy(param1:Heading):void
		{
			this.time = param1.time;
			this.pos.x = param1.pos.x;
			this.pos.y = param1.pos.y;
			this.rotation = param1.rotation;
			this.speed.x = param1.speed.x;
			this.speed.y = param1.speed.y;
			this.accelerate = param1.accelerate;
			this.deaccelerate = param1.deaccelerate;
			this.rotateLeft = param1.rotateLeft;
			this.rotateRight = param1.rotateRight;
		}

		public function clone():Heading
		{
			var _loc1_:Heading = new Heading();
			_loc1_.copy(this);
			return _loc1_;
		}

		public function runCommand(param1:Command):void
		{
			switch (param1.type)
			{
				case 0:
					this.accelerate = param1.active;
					break;
				case 1:
					this.rotateLeft = param1.active;
					break;
				case 2:
					this.rotateRight = param1.active;
					break;
				case 4:
					accelerate = true;
					deaccelerate = true;
					rotateLeft = false;
					rotateRight = false;
					break;
				case 8:
					this.deaccelerate = param1.active;
			}
		}

		public function toString():String
		{
			return "x:" + Util.formatDecimal(pos.x, 1) + ", y:" + Util.formatDecimal(pos.y, 1) + ", angle:" + Util.formatDecimal(rotation, 1) + ", speedX:" + Util.formatDecimal(speed.x, 1) + ", speedY:" + Util.formatDecimal(speed.y, 1) + ", time:" + time;
		}

		public function reset():void
		{
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
