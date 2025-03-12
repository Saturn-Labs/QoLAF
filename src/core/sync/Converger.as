package core.sync
{
	import core.deathLine.DeathLine;
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.ship.PlayerShip;
	import core.ship.Ship;
	import core.solarSystem.Body;
	import flash.geom.Point;
	import generics.Util;
	import movement.Heading;
	
	public class Converger
	{
		public static const PI_DIVIDED_BY_8:Number = 0.39269908169872414;
		private const BLIP_OFFSET:Number = 30;
		public var course:Heading;
		
		private var target:Heading;
		
		private var error:Point;
		
		private var errorAngle:Number;
		
		private var convergeTime:Number = 1000;
		private var convergeStartTime:Number;
		
		private var errorOldTime:Number;
		
		private var ship:Ship;
		
		private var g:Game;
		
		private var angleTargetPos:Point;
		
		private var isFacingTarget:Boolean;
		
		private var nextTurnDirection:int;
		
		private const RIGHT:int = 1;
		private const LEFT:int = -1;
		private const NONE:int = 0;
		public function Converger(param1:Ship, param2:Game)
		{
			course = new Heading();
			error = new Point();
			super();
			this.ship = param1;
			this.g = param2;
			angleTargetPos = null;
			nextTurnDirection = 0;
		}
		
		public function run():void
		{
			if (course == null || course.time > g.time - 33)
			{
				return;
			}
			if (ship is EnemyShip)
			{
				aiRemoveError(course);
				updateHeading(course);
				aiAddError(course);
			}
			else
			{
				updateHeading(course);
				if (target != null)
				{
					calculateOffset();
				}
			}
		}
		
		public function calculateOffset():void
		{
			var _loc8_:Number = NaN;
			var _loc11_:Number = NaN;
			var _loc6_:* = undefined;
			var _loc4_:int = 0;
			var _loc10_:int = 0;
			var _loc5_:DeathLine = null;
			while (target.time < course.time)
			{
				_loc8_ = target.pos.y;
				_loc11_ = target.pos.x;
				updateHeading(target);
				_loc6_ = g.deathLineManager.lines;
				_loc4_ = int(_loc6_.length);
				_loc10_ = 0;
				while (_loc10_ < _loc4_)
				{
					_loc5_ = _loc6_[_loc10_];
					if (_loc5_.lineIntersection2(course.pos.x, course.pos.y, _loc11_, _loc8_, ship.collisionRadius))
					{
						target.pos.x = _loc11_;
						target.pos.y = _loc8_;
						target.speed.x = 0;
						target.speed.y = 0;
						break;
					}
					_loc10_++;
				}
			}
			var _loc3_:Number = target.pos.x - course.pos.x;
			var _loc9_:Number = target.pos.y - course.pos.y;
			var _loc1_:Number = Math.sqrt(_loc3_ * _loc3_ + _loc9_ * _loc9_);
			var _loc2_:Number = Util.angleDifference(target.rotation, course.rotation);
			if (_loc1_ > 30)
			{
				setCourse(target);
				return;
			}
			if (_loc2_ > 0.39269908169872414 || _loc2_ < -0.39269908169872414)
			{
				course.rotation = target.rotation;
				return;
			}
			var _loc7_:Number = 0.4;
			course.speed.x = target.speed.x + _loc7_ * _loc3_;
			course.speed.y = target.speed.y + _loc7_ * _loc9_;
			course.rotation += _loc2_ * 0.05;
			course.rotation = Util.clampRadians(course.rotation);
		}
		
		private function aiAddError(param1:Heading):void
		{
			if (error.x == 0 && error.y == 0)
			{
				return;
			}
			var _loc2_:Number = g.time;
			var _loc3_:Number = (convergeTime - (_loc2_ - convergeStartTime)) / convergeTime;
			var _loc4_:Number = 3 * _loc3_ * _loc3_ - 2 * _loc3_ * _loc3_ * _loc3_;
			if (_loc3_ > 0)
			{
				param1.pos.x += _loc4_ * error.x;
				param1.pos.y += _loc4_ * error.y;
				param1.rotation += _loc4_ * errorAngle;
				errorOldTime = _loc2_;
			}
			else
			{
				error.x = 0;
				error.y = 0;
				errorOldTime = 0;
			}
		}
		
		private function aiRemoveError(param1:Heading):void
		{
			if (error.x == 0 && error.y == 0 || errorOldTime == 0)
			{
				return;
			}
			var _loc2_:Number = (convergeTime - (errorOldTime - convergeStartTime)) / convergeTime;
			var _loc3_:Number = 3 * _loc2_ * _loc2_ - 2 * _loc2_ * _loc2_ * _loc2_;
			param1.pos.x -= _loc3_ * error.x;
			param1.pos.y -= _loc3_ * error.y;
			param1.rotation -= _loc3_ * errorAngle;
		}
		
		public function setNextTurnDirection(param1:int):void
		{
			nextTurnDirection = param1;
		}
		
		public function setConvergeTarget(param1:Heading):void
		{
			target = param1;
			if (ship is EnemyShip)
			{
				error.x = course.pos.x - target.pos.x;
				error.y = course.pos.y - target.pos.y;
				errorAngle = Util.angleDifference(course.rotation, target.rotation);
				convergeStartTime = g.time;
				course.speed = target.speed;
				course.pos = target.pos;
				course.rotation = target.rotation;
				course.time = target.time;
				aiAddError(course);
			}
		}
		
		public function clearConvergeTarget():void
		{
			target = null;
			error.x = 0;
			error.y = 0;
		}
		
		public function setCourse(param1:Heading, param2:Boolean = true):void
		{
			if (param2)
			{
				fastforwardToServerTime(param1);
			}
			course = param1;
			target = null;
		}
		
		public function setAngleTargetPos(param1:Point):void
		{
			isFacingTarget = false;
			angleTargetPos = param1;
		}
		
		public function isFacingAngleTarget():Boolean
		{
			return isFacingTarget;
		}
		
		public function fastforwardToServerTime(param1:Heading):void
		{
			if (param1 == null)
			{
				return;
			}
			while (param1.time < g.time - 33)
			{
				updateHeading(param1);
			}
		}
		
		public function updateHeading(param1:Heading):void
		{
			var _loc8_:Point = null;
			var _loc9_:Number = NaN;
			var _loc7_:Number = NaN;
			var _loc26_:Number = NaN;
			var _loc5_:Number = NaN;
			var _loc6_:Boolean = false;
			var _loc15_:Number = NaN;
			var _loc24_:EnemyShip = null;
			var _loc14_:Number = NaN;
			var _loc13_:Number = NaN;
			var _loc12_:Number = NaN;
			var _loc16_:Number = NaN;
			var _loc11_:Number = NaN;
			var _loc25_:Number = NaN;
			var _loc10_:Number = NaN;
			var _loc4_:Number = NaN;
			var _loc3_:Number = NaN;
			var _loc28_:* = undefined;
			var _loc20_:int = 0;
			var _loc22_:int = 0;
			var _loc17_:Body = null;
			var _loc18_:Number = NaN;
			var _loc23_:Number = NaN;
			var _loc19_:Number = NaN;
			var _loc21_:Number = NaN;
			var _loc27_:Number = NaN;
			var _loc2_:Number = 33;
			if (ship is EnemyShip)
			{
			}
			if (ship is EnemyShip && angleTargetPos != null)
			{
				_loc8_ = ship.pos;
				_loc9_ = ship.rotation;
				_loc7_ = Math.atan2(angleTargetPos.y - _loc8_.y, angleTargetPos.x - _loc8_.x);
				_loc26_ = Util.angleDifference(_loc9_, _loc7_ + 3.141592653589793);
				_loc5_ = 0.001 * ship.engine.rotationSpeed * _loc2_;
				_loc6_ = _loc26_ > 0.5 * 3.141592653589793 || _loc26_ < -0.5 * 3.141592653589793;
				_loc15_ = (angleTargetPos.y - _loc8_.y) * (angleTargetPos.y - _loc8_.y) + (angleTargetPos.x - _loc8_.x) * (angleTargetPos.x - _loc8_.x);
				_loc24_ = ship as EnemyShip;
				if (_loc15_ < 2500 && _loc24_.meleeCharge)
				{
					isFacingTarget = false;
				}
				else if (!_loc6_)
				{
					param1.accelerate = true;
					param1.roll = false;
					if (_loc26_ > 0 && _loc26_ < 3.141592653589793 - _loc5_)
					{
						param1.rotation += _loc5_;
						param1.rotation = Util.clampRadians(param1.rotation);
						isFacingTarget = false;
					}
					else if (_loc26_ <= 0 && _loc26_ > -3.141592653589793 + _loc5_)
					{
						param1.rotation -= _loc5_;
						param1.rotation = Util.clampRadians(param1.rotation);
						isFacingTarget = false;
					}
				}
				else if (_loc26_ > 0 && _loc26_ < 3.141592653589793 - _loc5_)
				{
					param1.rotation += _loc5_;
					param1.rotation = Util.clampRadians(param1.rotation);
					isFacingTarget = false;
				}
				else if (_loc26_ <= 0 && _loc26_ > -3.141592653589793 + _loc5_)
				{
					param1.rotation -= _loc5_;
					param1.rotation = Util.clampRadians(param1.rotation);
					isFacingTarget = false;
				}
				else
				{
					isFacingTarget = true;
					param1.rotation = Util.clampRadians(_loc7_);
				}
			}
			else
			{
				if (param1.rotateLeft)
				{
					param1.rotation -= 0.001 * ship.engine.rotationSpeed * _loc2_;
					param1.rotation = Util.clampRadians(param1.rotation);
				}
				if (param1.rotateRight)
				{
					param1.rotation += 0.001 * ship.engine.rotationSpeed * _loc2_;
					param1.rotation = Util.clampRadians(param1.rotation);
				}
			}
			if (param1.accelerate)
			{
				_loc14_ = param1.speed.x;
				_loc13_ = param1.speed.y;
				_loc12_ = _loc14_ * _loc14_ + _loc13_ * _loc13_;
				_loc16_ = param1.rotation + ship.rollDir * ship.rollMod * ship.rollPassive;
				_loc11_ = ship.engine.acceleration * 0.5 * Math.pow(_loc2_, 2);
				if (ship is EnemyShip)
				{
					_loc14_ += Math.cos(_loc16_) * _loc11_;
					_loc13_ += Math.sin(_loc16_) * _loc11_;
				}
				else
				{
					_loc14_ += Math.cos(param1.rotation) * _loc11_;
					_loc13_ += Math.sin(param1.rotation) * _loc11_;
				}
				_loc25_ = ship.engine.speed;
				if (ship.usingBoost)
				{
					_loc25_ = 0.01 * _loc25_ * (100 + ship.boostBonus);
				}
				else if (_loc12_ > _loc25_ * _loc25_)
				{
					_loc25_ = Math.sqrt(_loc12_);
				}
				_loc12_ = _loc14_ * _loc14_ + _loc13_ * _loc13_;
				if (_loc12_ <= _loc25_ * _loc25_)
				{
					param1.speed.x = _loc14_;
					param1.speed.y = _loc13_;
				}
				else
				{
					_loc10_ = Math.sqrt(_loc12_);
					_loc4_ = _loc14_ / _loc10_ * _loc25_;
					_loc3_ = _loc13_ / _loc10_ * _loc25_;
					param1.speed.x = _loc4_;
					param1.speed.y = _loc3_;
				}
			}
			else if (param1.deaccelerate)
			{
				param1.speed.x = 0.9 * param1.speed.x;
				param1.speed.y = 0.9 * param1.speed.y;
			}
			else if (ship is EnemyShip && param1.roll)
			{
				_loc14_ = param1.speed.x;
				_loc13_ = param1.speed.y;
				_loc12_ = _loc14_ * _loc14_ + _loc13_ * _loc13_;
				if (_loc12_ <= ship.rollSpeed * ship.rollSpeed)
				{
					_loc16_ = param1.rotation + ship.rollDir * ship.rollMod * 3.141592653589793 * 0.5;
					_loc11_ = ship.engine.acceleration * 0.5 * Math.pow(_loc2_, 2);
					_loc14_ += Math.cos(_loc16_) * _loc11_;
					_loc13_ += Math.sin(_loc16_) * _loc11_;
					_loc12_ = _loc14_ * _loc14_ + _loc13_ * _loc13_;
					if (_loc12_ <= ship.rollSpeed * ship.rollSpeed)
					{
						param1.speed.x = _loc14_;
						param1.speed.y = _loc13_;
					}
					else
					{
						_loc10_ = Math.sqrt(_loc12_);
						_loc4_ = _loc14_ / _loc10_ * ship.rollSpeed;
						_loc3_ = _loc13_ / _loc10_ * ship.rollSpeed;
						param1.speed.x = _loc4_;
						param1.speed.y = _loc3_;
					}
				}
				else
				{
					param1.speed.x -= 0.02 * param1.speed.x;
					param1.speed.y -= 0.02 * param1.speed.y;
				}
			}
			if (ship is EnemyShip && !param1.accelerate)
			{
				param1.speed.x = 0.9 * param1.speed.x;
				param1.speed.y = 0.9 * param1.speed.y;
			}
			else
			{
				param1.speed.x -= 0.009 * param1.speed.x;
				param1.speed.y -= 0.009 * param1.speed.y;
			}
			if (ship is PlayerShip)
			{
				_loc28_ = g.bodyManager.bodies;
				_loc20_ = int(_loc28_.length);
				_loc22_ = 0;
				while (_loc22_ < _loc20_)
				{
					_loc17_ = _loc28_[_loc22_];
					if (_loc17_.type == "sun")
					{
						_loc18_ = _loc17_.pos.x - param1.pos.x;
						_loc23_ = _loc17_.pos.y - param1.pos.y;
						_loc19_ = _loc18_ * _loc18_ + _loc23_ * _loc23_;
						if (_loc19_ <= _loc17_.gravityDistance)
						{
							if (_loc19_ != 0)
							{
								if (_loc19_ < _loc17_.gravityMin)
								{
									_loc19_ = _loc17_.gravityMin;
								}
								_loc21_ = Math.atan2(_loc23_, _loc18_);
								_loc21_ = Util.clampRadians(_loc21_);
								_loc27_ = _loc17_.gravityForce / _loc19_ * _loc2_ * 0.001;
								param1.speed.x += Math.cos(_loc21_) * _loc27_;
								param1.speed.y += Math.sin(_loc21_) * _loc27_;
							}
						}
					}
					_loc22_++;
				}
			}
			param1.pos.x += param1.speed.x * _loc2_ * 0.001;
			param1.pos.y += param1.speed.y * _loc2_ * 0.001;
			param1.time += _loc2_;
		}
	}
}
