package core.states.AIStates
{
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
	
	public class AIChase implements IState
	{
		private var g:Game;
		
		private var s:EnemyShip;
		
		private var sm:StateMachine;
		
		private var closeRangeSQ:Number;
		
		private var speedRotFactor:Number;
		
		private var rollPeriod:Number;
		
		private var rollPeriodFactor:Number;
		
		public function AIChase(param1:Game, param2:EnemyShip, param3:Unit, param4:Heading, param5:int)
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
			var _loc1_:Random = new Random(1 / s.id);
			_loc1_.stepTo(5);
			closeRangeSQ = 66 + 0.8 * _loc1_.random(80) + s.collisionRadius;
			closeRangeSQ *= closeRangeSQ;
			if (_loc1_.random(2) == 0)
			{
				s.rollDir = -1;
			}
			else
			{
				s.rollDir = 1;
			}
			s.rollSpeed = (0.1 + 0.001 * _loc1_.random(501)) * s.engine.speed;
			s.rollPassive = 0.1 + 0.001 * _loc1_.random(301);
			rollPeriod = 10000 + _loc1_.random(10000);
			rollPeriodFactor = 0.25 + 0.001 * _loc1_.random(501);
			s.rollMod = g.time % rollPeriod > rollPeriodFactor * rollPeriod ? 1 : -1;
			speedRotFactor = s.engine.speed / (0.5 * s.engine.rotationSpeed);
			s.accelerate = true;
			s.roll = false;
			s.engine.accelerate();
		}
		
		public function execute():void
		{
			var _loc6_:Point = null;
			var _loc3_:Point = null;
			var _loc2_:Number = NaN;
			var _loc5_:Number = NaN;
			var _loc1_:Number = NaN;
			var _loc4_:Number = NaN;
			if (s.target != null)
			{
				_loc6_ = s.course.pos;
				_loc3_ = s.target.pos;
				s.setAngleTargetPos(_loc3_);
				_loc2_ = _loc6_.x - _loc3_.x;
				_loc5_ = _loc6_.y - _loc3_.y;
				_loc1_ = _loc2_ * _loc2_ + _loc5_ * _loc5_;
				if (s.sniper && _loc1_ < s.sniperMinRange * s.sniperMinRange)
				{
					s.accelerate = false;
					s.roll = true;
				}
				else if (s.stopWhenClose && _loc1_ < closeRangeSQ)
				{
					s.accelerate = false;
					s.roll = true;
				}
				else
				{
					s.accelerate = true;
					s.roll = false;
				}
			}
			s.rollMod = g.time % rollPeriod > rollPeriodFactor * rollPeriod ? 1 : -1;
			if (!s.aiCloak)
			{
				s.runConverger();
			}
			s.regenerateShield();
			s.updateHealthBars();
			s.engine.update();
			if (s.target != null)
			{
				_loc4_ = s.rotation;
				s.updateBeamWeapons();
				s.rotation = aim();
				s.updateNonBeamWeapons();
				s.rotation = _loc4_;
			}
		}
		
		public function aim():Number
		{
			var _loc7_:int = 0;
			var _loc14_:Number = NaN;
			var _loc2_:Number = NaN;
			var _loc11_:Number = NaN;
			var _loc5_:Number = NaN;
			var _loc6_:Number = NaN;
			var _loc8_:Weapon = null;
			var _loc9_:Number = s.target.pos.x;
			var _loc10_:Number = s.target.pos.y;
			var _loc1_:Number = s.course.pos.x;
			var _loc4_:Number = s.course.pos.y;
			var _loc12_:Number = 0;
			var _loc13_:Number = 0;
			var _loc3_:int = int(s.weapons.length);
			_loc7_ = 0;
			while (_loc7_ < _loc3_)
			{
				_loc8_ = s.weapons[_loc7_];
				if (_loc8_.fire && _loc8_ is Blaster)
				{
					if (s.aimSkill == 0)
					{
						return s.course.rotation;
					}
					_loc12_ = _loc9_ - _loc1_;
					_loc13_ = _loc10_ - _loc4_;
					_loc14_ = Math.sqrt(_loc12_ * _loc12_ + _loc13_ * _loc13_);
					_loc12_ /= _loc14_;
					_loc13_ /= _loc14_;
					_loc2_ = 0.991;
					_loc11_ = _loc14_ / (_loc8_.speed - Util.dotProduct(s.target.speed.x, s.target.speed.y, _loc12_, _loc13_) * _loc2_);
					_loc5_ = _loc9_ + s.target.speed.x * _loc11_ * _loc2_ * s.aimSkill;
					_loc6_ = _loc10_ + s.target.speed.y * _loc11_ * _loc2_ * s.aimSkill;
					return Math.atan2(_loc6_ - _loc4_, _loc5_ - _loc1_);
				}
				_loc7_++;
			}
			return s.course.rotation;
		}
		
		public function exit():void
		{
			s.rollPassive = 0;
			s.rollSpeed = 0;
			s.rollMod = 0;
			s.rollDir = 0;
		}
		
		public function set stateMachine(param1:StateMachine):void
		{
			this.sm = param1;
		}
		
		public function get type():String
		{
			return "AIChase";
		}
	}
}
