package core.states.AIStates
{
	import core.particle.Emitter;
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.ship.PlayerShip;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	import core.weapon.Blaster;
	import core.weapon.Weapon;
	import flash.geom.Point;
	import generics.Random;
	import generics.Util;
	import movement.Heading;
	
	public class AIMelee implements IState
	{
		private var g:Game;
		
		private var s:EnemyShip;
		
		private var sm:StateMachine;
		
		private var targetAngleDiff:Number;
		
		private var targetStartAngle:Number;
		
		private var error:Point;
		
		private var errorAngle:Number;
		
		private var convergeTime:Number = 400;
		private var convergeStartTime:Number;
		
		private var speedRotFactor:Number;
		
		private var closeRangeSQ:Number;
		
		public function AIMelee(param1:Game, param2:EnemyShip, param3:Unit, param4:Heading, param5:int)
		{
			super();
			param2.target = param3;
			if (!param2.aiCloak)
			{
				param2.setConvergeTarget(param4);
			}
			param2.nextTurnDir = param5;
			this.s = param2;
			this.g = param1;
			if (!(param2.target is PlayerShip) && param2.factions.length == 0)
			{
				param2.factions.push("tempFaction");
			}
		}
		
		public function enter():void
		{
			s.accelerate = true;
			s.meleeStuck = false;
			error = null;
			errorAngle = 0;
			var _loc1_:Random = new Random(1 / s.id);
			_loc1_.stepTo(5);
			closeRangeSQ = 66 + 0.8 * _loc1_.random(80) + s.collisionRadius;
			closeRangeSQ *= closeRangeSQ;
			speedRotFactor = s.engine.speed / (0.5 * s.engine.rotationSpeed);
		}
		
		public function execute():void
		{
			var _loc3_:Point = null;
			var _loc1_:Number = NaN;
			var _loc5_:Point = null;
			var _loc4_:Number = NaN;
			var _loc8_:Number = NaN;
			var _loc6_:Number = NaN;
			var _loc7_:Number = NaN;
			if (s.target != null && s.target.alive)
			{
				s.setAngleTargetPos(s.target.pos);
				_loc3_ = new Point(s.pos.x - s.target.pos.x, s.pos.y - s.target.pos.y);
				_loc1_ = _loc3_.x * _loc3_.x + _loc3_.y * _loc3_.y;
				if (s.meleeCanGrab && _loc1_ < s.chaseRange && s.meleeChargeEndTime != 0 && s.meleeCanGrab)
				{
					s.meleeChargeEndTime = 1;
				}
				if (s.meleeChargeEndTime < g.time && s.meleeChargeEndTime != 0)
				{
					s.engine.speed = s.oldSpeed;
					s.engine.rotationSpeed = s.oldTurningSpeed;
					s.meleeChargeEndTime = 0;
					for each (var _loc2_:* in s.chargeEffect)
					{
						_loc2_.killEmitter();
					}
				}
				if (s.meleeStuck)
				{
					if (error == null)
					{
						_loc5_ = s.pos.clone();
						errorAngle = s.target.rotation + s.meleeTargetAngleDiff - s.rotation;
					}
					s.speed.x = 0;
					s.speed.y = 0;
					s.rotation = s.target.rotation + s.meleeTargetAngleDiff;
					_loc4_ = Util.clampRadians(s.target.rotation - s.meleeTargetStartAngle);
					s.pos.x = s.target.pos.x + Math.cos(_loc4_) * s.meleeOffset.x - Math.sin(_loc4_) * s.meleeOffset.y;
					s.pos.y = s.target.pos.y + Math.sin(_loc4_) * s.meleeOffset.x + Math.cos(_loc4_) * s.meleeOffset.y;
					s.accelerate = false;
					if (error == null)
					{
						convergeStartTime = g.time;
						error = new Point(_loc5_.x - s.pos.x, _loc5_.y - s.pos.y);
						convergeTime = error.length / s.engine.speed * 1000;
					}
					if (error != null)
					{
						_loc8_ = (convergeTime - (g.time - convergeStartTime)) / convergeTime;
						if (_loc8_ > 0)
						{
							s.pos.x += _loc8_ * error.x;
							s.pos.y += _loc8_ * error.y;
							s.rotation += _loc8_ * errorAngle;
						}
					}
				}
				else
				{
					if (s.stopWhenClose && _loc1_ < closeRangeSQ)
					{
						s.accelerate = false;
					}
					else if (s.meleeChargeEndTime < g.time && _loc1_ < speedRotFactor * speedRotFactor)
					{
						_loc6_ = Math.atan2(s.course.pos.y - s.target.pos.y, s.course.pos.x - s.target.pos.x);
						_loc4_ = Util.angleDifference(s.course.rotation, _loc6_ + 3.141592653589793);
						if (_loc4_ > 0.4 * 3.141592653589793 && _loc4_ < 0.65 * 3.141592653589793 || _loc4_ < -0.4 * 3.141592653589793 && _loc4_ > -0.65 * 3.141592653589793)
						{
							s.accelerate = false;
						}
						else
						{
							s.accelerate = true;
						}
					}
					else
					{
						s.accelerate = true;
					}
					error = null;
					if (!s.aiCloak)
					{
						s.runConverger();
					}
				}
			}
			if (isNaN(s.pos.x))
			{
				trace("NaN Melee");
			}
			s.regenerateShield();
			s.updateHealthBars();
			s.engine.update();
			if (s.target != null)
			{
				_loc7_ = s.rotation;
				s.updateBeamWeapons();
				s.rotation = aim();
				s.updateNonBeamWeapons();
				s.rotation = _loc7_;
			}
		}
		
		public function aim():Number
		{
			var _loc7_:int = 0;
			var _loc3_:Number = NaN;
			var _loc4_:Number = NaN;
			var _loc6_:Number = NaN;
			var _loc2_:Number = NaN;
			var _loc5_:Point = null;
			var _loc1_:Weapon = null;
			_loc7_ = 0;
			while (_loc7_ < s.weapons.length)
			{
				_loc1_ = s.weapons[_loc7_];
				if (_loc1_.fire && _loc1_ is Blaster)
				{
					if (s.aimSkill == 0)
					{
						return s.course.rotation;
					}
					_loc3_ = s.target.pos.x - s.course.pos.x;
					_loc4_ = s.target.pos.y - s.course.pos.y;
					_loc6_ = Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_);
					_loc3_ /= _loc6_;
					_loc4_ /= _loc6_;
					_loc2_ = _loc6_ / (_loc1_.speed - Util.dotProduct(s.target.speed.x, s.target.speed.y, _loc3_, _loc4_));
					_loc5_ = new Point(s.target.pos.x + s.target.speed.x * _loc2_ * s.aimSkill, s.target.pos.y + s.target.speed.y * _loc2_ * s.aimSkill);
					return Math.atan2(_loc5_.y - s.course.pos.y, _loc5_.x - s.course.pos.x);
				}
				_loc7_++;
			}
			return s.course.rotation;
		}
		
		public function exit():void
		{
			if (s.meleeChargeEndTime != 0)
			{
				s.engine.speed = s.oldSpeed;
				s.engine.rotationSpeed = s.oldTurningSpeed;
				s.meleeChargeEndTime = 0;
				for each (var _loc1_:* in s.chargeEffect)
				{
					_loc1_.killEmitter();
				}
			}
		}
		
		public function set stateMachine(param1:StateMachine):void
		{
			this.sm = param1;
		}
		
		public function get type():String
		{
			return "AIMelee";
		}
	}
}
