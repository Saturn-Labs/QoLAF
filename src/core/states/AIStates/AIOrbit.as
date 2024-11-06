package core.states.AIStates
{
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.states.IState;
	import core.states.StateMachine;
	import flash.geom.Point;
	import generics.Util;
	import movement.Heading;

	public class AIOrbit implements IState
	{
		private static const HALF_PI:Number = 1.5707963267948966;

		private static const TICK_LENGTH_MS:Number = 0.033;

		private static const TICK_LENGTH_W:Number = 30.303030303030305;

		private var g:Game;
		private var s:EnemyShip;
		private var sm:StateMachine;
		private var lastCourse:Heading;
		private var error:Point;
		private var errorAngle:Number;
		private var convergeTime:Number = 1000;
		private var convergeStartTime:Number;
		public function AIOrbit(param1:Game, param2:EnemyShip, param3:Boolean = false)
		{
			super();
			this.g = param1;
			this.s = param2;
			error = new Point();
			errorAngle = 0;
			if (param3)
			{
				lastCourse = param2.course.clone();
			}
			else
			{
				lastCourse = null;
			}
		}

		public function enter():void
		{
			s.target = null;
			s.setAngleTargetPos(null);
			s.stopShooting();
			s.accelerate = true;
			s.forceupdate = true;
		}

		public function execute():void
		{
			var _loc5_:Number = NaN;
			var _loc10_:Number = NaN;
			var _loc2_:Point = null;
			if (s.spawner == null || s.spawner.parentObj == null)
			{
				return;
			}
			if (!s.isAddedToCanvas && !s.forceupdate && !s.spawner.isBossUnit)
			{
				return;
			}
			s.forceupdate = false;
			var _loc6_:Point = s.spawner.parentObj.pos;
			var _loc1_:Number = g.time;
			var _loc8_:Number = s.orbitAngle + 0.001 * s.angleVelocity * 33 * (_loc1_ - s.orbitStartTime);
			var _loc3_:Number = s.orbitRadius * s.ellipseFactor * Math.cos(_loc8_);
			var _loc7_:Number = s.orbitRadius * Math.sin(_loc8_);
			var _loc9_:Number = s.ellipseAlpha;
			var _loc12_:Number = _loc3_ * Math.cos(_loc9_) - _loc7_ * Math.sin(_loc9_) + _loc6_.x;
			var _loc11_:Number = _loc3_ * Math.sin(_loc9_) + _loc7_ * Math.cos(_loc9_) + _loc6_.y;
			var _loc4_:Number = 0.5 * (1 - s.orbitRadius / 500);
			if (_loc4_ > 0.5)
			{
				_loc4_ = 0.5;
			}
			else if (_loc4_ < 0)
			{
				_loc4_ = 0;
			}
			_loc5_ = -Math.atan2(_loc12_ - _loc6_.x, _loc11_ - _loc6_.y) - 1.5707963267948966 - Util.sign(s.angleVelocity) * (1.5707963267948966 - _loc4_);
			if (!s.aiCloak)
			{
				if (lastCourse != null)
				{
					error.x = lastCourse.pos.x - _loc12_;
					error.y = lastCourse.pos.y - _loc11_;
					errorAngle = Util.angleDifference(lastCourse.rotation, _loc5_);
					convergeStartTime = _loc1_;
					lastCourse = null;
				}
				if (error.x != 0 || error.y != 0)
				{
					_loc10_ = (convergeTime - (_loc1_ - convergeStartTime)) / convergeTime;
					if (_loc10_ > 0)
					{
						_loc12_ += _loc10_ * error.x;
						_loc12_ = _loc12_ + _loc10_ * error.y;
						_loc5_ += _loc10_ * errorAngle;
					}
					else
					{
						error.x = 0;
						error.y = 0;
					}
				}
				_loc2_ = s.pos;
				_loc2_.x = _loc12_;
				_loc2_.y = _loc11_;
			}
			s.rotation = _loc5_;
			s.engine.update();
			s.updateWeapons();
			s.updateHealthBars();
			s.regenerateShield();
			s.regenerateHP();
		}

		public function exit():void
		{
			var _loc1_:Heading = null;
			if (!s.aiCloak)
			{
				_loc1_ = new Heading();
				_loc1_.rotation = s.rotation;
				_loc1_.pos = s.pos;
				_loc1_.speed = s.calculateOrbitSpeed();
				_loc1_.time = g.time;
				s.course = _loc1_;
			}
		}

		public function set stateMachine(param1:StateMachine):void
		{
			this.sm = param1;
		}

		public function get type():String
		{
			return "AIOrbit";
		}
	}
}
