package core.ship
{
	import core.engine.Engine;
	import core.scene.Game;
	import core.sync.Converger;
	import core.unit.Unit;
	import core.weapon.Beam;
	import core.weapon.Weapon;
	import flash.geom.Point;
	import movement.Heading;

	public class Ship extends Unit
	{
		public var engine:Engine;
		public var weapons:Vector.<Weapon>;

		protected var _usingBoost:Boolean;
		public var boostBonus:int;
		public var isTeleporting:Boolean;
		private var converger:Converger;
		public var isVisible:Boolean = false;
		public var nextUpdate:Number = 0;
		public var rollDir:Number = 0;
		public var rollMod:Number = 0;
		public var rollSpeed:Number = 0;
		public var rollPassive:Number = 0;
		public function Ship(param1:Game)
		{
			weapons = new Vector.<Weapon>();
			converger = new Converger(this, param1);
			super(param1);
			enginePos = new Point();
			weaponPos = new Point();
		}

		override public function update():void
		{
			var _loc1_:Number = NaN;
			if (isNaN(pos.x))
			{
				return;
			}
			var _loc2_:Heading = converger.course;
			if (_loc2_ == null)
			{
				return;
			}
			stateMachine.update();
			super.update();
			if (!isAddedToCanvas)
			{
				return;
			}
			if (_loc2_.accelerate || _loc2_.deaccelerate && speed.length > 5)
			{
				engine.accelerate();
			}
			else
			{
				engine.idle();
			}
			if (lastDmgText != null)
			{
				_loc1_ = 33;
				lastDmgText.x += _loc2_.speed.x * _loc1_ / 1000;
				lastDmgText.y += _loc2_.speed.y * _loc1_ / 1000;
				if (lastDmgTime < g.time - 1000)
				{
					lastDmgText = null;
					lastDmg = 0;
				}
			}
			if (lastHealText != null)
			{
				_loc1_ = 33;
				lastHealText.x += _loc2_.speed.x * _loc1_ / 1000;
				lastHealText.y += _loc2_.speed.y * _loc1_ / 1000;
				if (lastHealTime < g.time - 1000)
				{
					lastHealText = null;
					lastHeal = 0;
				}
			}
		}

		public function updateWeapons():void
		{
			var _loc1_:Weapon = null;
			var _loc3_:int = 0;
			var _loc2_:Number = weapons.length;
			_loc3_;
			while (_loc3_ < _loc2_)
			{
				_loc1_ = weapons[_loc3_];
				_loc1_.update();
				_loc3_++;
			}
		}

		public function updateBeamWeapons():void
		{
			var _loc1_:Weapon = null;
			var _loc3_:int = 0;
			var _loc2_:Number = weapons.length;
			_loc3_;
			while (_loc3_ < _loc2_)
			{
				_loc1_ = weapons[_loc3_];
				if (_loc1_ is Beam)
				{
					_loc1_.update();
				}
				_loc3_++;
			}
		}

		public function updateNonBeamWeapons():void
		{
			var _loc1_:Weapon = null;
			var _loc3_:int = 0;
			var _loc2_:Number = weapons.length;
			_loc3_;
			while (_loc3_ < _loc2_)
			{
				_loc1_ = weapons[_loc3_];
				if (!(_loc1_ is Beam))
				{
					_loc1_.update();
				}
				_loc3_++;
			}
		}

		override public function destroy(param1:Boolean = true):void
		{
			engine.destroy();
			for each (var _loc2_:* in weapons)
			{
				_loc2_.destroy();
			}
			super.destroy(param1);
		}

		public function runConverger():void
		{
			if (converger != null)
			{
				converger.run();
			}
		}

		override public function set pos(param1:Point):void
		{
			if (course != null)
			{
				course.pos = param1;
			}
		}

		override public function get pos():Point
		{
			if (converger == null || converger.course == null)
			{
				return new Point();
			}
			return converger.course.pos;
		}

		override public function set x(param1:Number):void
		{
			pos.x = param1;
		}

		override public function set y(param1:Number):void
		{
			pos.y = param1;
		}

		override public function get x():Number
		{
			return pos.x;
		}

		override public function get y():Number
		{
			return pos.y;
		}

		override public function set speed(param1:Point):void
		{
			if (course != null)
			{
				course.speed = param1;
			}
		}

		override public function get speed():Point
		{
			if (course != null)
			{
				return course.speed;
			}
			return new Point();
		}

		override public function set rotation(param1:Number):void
		{
			if (course != null)
			{
				course.rotation = param1;
			}
		}

		override public function get rotation():Number
		{
			if (course != null)
			{
				return course.rotation;
			}
			return 0;
		}

		public function initCourse(param1:Heading):void
		{
			if (course != null)
			{
				converger.setCourse(param1, false);
			}
		}

		public function set course(param1:Heading):void
		{
			if (course != null)
			{
				converger.setCourse(param1);
			}
		}

		public function get course():Heading
		{
			if (converger != null)
			{
				return converger.course;
			}
			return null;
		}

		public function set accelerate(param1:Boolean):void
		{
			if (course != null)
			{
				course.accelerate = param1;
			}
		}

		public function get accelerate():Boolean
		{
			if (course != null)
			{
				return course.accelerate;
			}
			return false;
		}

		public function setConvergeTarget(param1:Heading):void
		{
			converger.setConvergeTarget(param1);
		}

		public function clearConvergeTarget():void
		{
			converger.clearConvergeTarget();
		}

		public function getConverger():Converger
		{
			return converger;
		}

		public function convergerUpdateHeading(param1:Heading):void
		{
			converger.updateHeading(param1);
		}

		public function setAngleTargetPos(param1:Point):void
		{
			converger.setAngleTargetPos(param1);
		}

		public function isFacingAngleTarget():Boolean
		{
			return converger.isFacingAngleTarget();
		}

		public function setNextTurnDirection(param1:int):void
		{
			converger.setNextTurnDirection(param1);
		}

		override public function reset():void
		{
			engine = null;
			_usingBoost = false;
			boostBonus = 0;
			isVisible = false;
			nextUpdate = 0;
			converger = new Converger(this, g);
			isTeleporting = false;
			weapons.splice(0, weapons.length);
			super.reset();
		}

		override public function addToCanvasForReal():void
		{
			super.addToCanvas();
			engine.show();
		}

		override public function removeFromCanvas():void
		{
			if (!isAddedToCanvas)
			{
				return;
			}
			engine.hide();
			super.removeFromCanvas();
		}

		override public function get type():String
		{
			return "ship";
		}

		public function get usingBoost():Boolean
		{
			return _usingBoost;
		}
	}
}
