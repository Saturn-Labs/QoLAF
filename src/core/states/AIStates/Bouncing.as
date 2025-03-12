package core.states.AIStates
{
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	import flash.geom.Point;
	import generics.Util;
	
	public class Bouncing implements IState
	{
		protected var m:Game;
		
		protected var p:Projectile;
		
		private var sm:StateMachine;
		
		private var isEnemy:Boolean;
		
		private var globalInterval:Number = 1000;
		private var localTargetList:Vector.<Unit>;
		
		private var nextGlobalUpdate:Number;
		
		private var nextLocalUpdate:Number;
		
		private var localRangeSQ:Number;
		
		private var firstUpdate:Boolean;
		
		public function Bouncing(param1:Game, param2:Projectile)
		{
			super();
			this.m = param1;
			this.p = param2;
			param2.target = null;
			if (param2.isHeal || param2.unit.factions.length > 0)
			{
				this.isEnemy = false;
			}
			else
			{
				this.isEnemy = param2.unit.type == "enemyShip" || param2.unit.type == "turret";
			}
		}
		
		public function enter():void
		{
			if (p.ttl < globalInterval)
			{
				globalInterval = p.ttl;
			}
			localTargetList = new Vector.<Unit>();
			firstUpdate = true;
			nextGlobalUpdate = 0;
			nextLocalUpdate = 0;
			localRangeSQ = globalInterval * 0.001 * (p.speedMax + 400);
			localRangeSQ *= localRangeSQ;
			if (p.unit.lastBulletTargetList != null)
			{
				if (p.unit.lastBulletGlobal > m.time)
				{
					nextGlobalUpdate = p.unit.lastBulletGlobal;
					localTargetList = p.unit.lastBulletTargetList;
					firstUpdate = false;
				}
				else
				{
					p.unit.lastBulletTargetList = null;
					firstUpdate = true;
				}
				if (p.unit.lastBulletLocal > m.time + 50)
				{
					nextLocalUpdate = p.unit.lastBulletLocal - 50;
					firstUpdate = false;
				}
			}
		}
		
		public function execute():void
		{
			var _loc23_:Unit = null;
			var _loc15_:Number = NaN;
			var _loc20_:Number = NaN;
			var _loc6_:Number = NaN;
			var _loc7_:Number = NaN;
			var _loc19_:int = 0;
			var _loc22_:int = 0;
			var _loc12_:Number = NaN;
			var _loc25_:* = undefined;
			var _loc3_:Boolean = false;
			if (p.target != null)
			{
				nextLocalUpdate = m.time;
				nextGlobalUpdate = m.time;
				aim(p.target);
				p.target = null;
				p.error = null;
			}
			var _loc1_:Number = 33;
			var _loc14_:int = (p.convergenceTime - p.convergenceCounter) / p.convergenceTime;
			if (_loc14_ <= 0)
			{
				p.error = null;
			}
			if (p.error != null)
			{
				p.course.pos.x += p.error.x * _loc14_;
				p.course.pos.y += p.error.y * _loc14_;
			}
			p.oldPos.x = p.course.pos.x;
			p.oldPos.y = p.course.pos.y;
			p.updateHeading(p.course);
			if (p.error != null)
			{
				p.convergenceCounter++;
				_loc14_ = (p.convergenceTime - p.convergenceCounter) / p.convergenceTime;
				p.course.pos.x -= p.error.x * _loc14_;
				p.course.pos.y -= p.error.y * _loc14_;
			}
			if (nextLocalUpdate > m.time)
			{
				return;
			}
			var _loc13_:* = 100000000;
			var _loc4_:Point = p.course.pos;
			if (_loc4_.y == p.oldPos.y && _loc4_.x == p.oldPos.x)
			{
				return;
			}
			var _loc21_:Number = -Math.atan2(_loc4_.y - p.oldPos.y, _loc4_.x - p.oldPos.x);
			var _loc26_:Number = Math.cos(_loc21_);
			var _loc11_:Number = Math.sin(_loc21_);
			var _loc8_:Number = p.oldPos.x * _loc26_ - p.oldPos.y * _loc11_;
			var _loc18_:Number = p.oldPos.x * _loc11_ + p.oldPos.y * _loc26_;
			var _loc9_:Number = _loc4_.x * _loc26_ - _loc4_.y * _loc11_;
			var _loc16_:Number = _loc4_.x * _loc11_ + _loc4_.y * _loc26_;
			var _loc24_:Number = p.collisionRadius;
			var _loc5_:Number = Math.min(_loc8_, _loc9_) - _loc24_;
			var _loc10_:Number = Math.max(_loc8_, _loc9_) + _loc24_;
			var _loc17_:Number = Math.min(_loc18_, _loc16_) - _loc24_;
			var _loc2_:Number = Math.max(_loc18_, _loc16_) + _loc24_;
			if (isEnemy)
			{
				_loc19_ = int(m.shipManager.players.length);
				_loc22_ = 0;
				while (_loc22_ < _loc19_)
				{
					_loc23_ = m.shipManager.players[_loc22_];
					if (!(!_loc23_.alive || _loc23_.invulnerable))
					{
						_loc15_ = _loc23_.pos.x;
						_loc20_ = _loc23_.pos.y;
						_loc6_ = _loc4_.x - _loc15_;
						_loc7_ = _loc4_.y - _loc20_;
						_loc12_ = _loc6_ * _loc6_ + _loc7_ * _loc7_;
						if (_loc13_ > _loc12_)
						{
							_loc13_ = _loc12_;
						}
						if (_loc12_ <= 2500)
						{
							_loc8_ = _loc15_ * _loc26_ - _loc20_ * _loc11_;
							_loc18_ = _loc15_ * _loc11_ + _loc20_ * _loc26_;
							_loc24_ = _loc23_.collisionRadius;
							if (_loc8_ <= _loc10_ + _loc24_ && _loc8_ > _loc5_ - _loc24_ && _loc18_ <= _loc2_ + _loc24_ && _loc18_ > _loc17_ - _loc24_)
							{
								if (p.numberOfHits <= 1)
								{
									_loc4_.y = (_loc17_ * _loc26_ / _loc11_ - _loc8_ + (_loc24_ - p.collisionRadius)) / (1 * _loc11_ + _loc26_ * _loc26_ / _loc11_);
									_loc4_.x = (_loc17_ - _loc4_.y * _loc26_) / _loc11_;
									p.destroy();
									return;
								}
								p.explode();
								if (p.numberOfHits >= 10)
								{
									p.numberOfHits--;
								}
							}
						}
					}
					_loc22_++;
				}
				nextLocalUpdate = m.time + Math.sqrt(_loc13_) * 1000 / (p.speedMax + 300) - 35;
				if (firstUpdate)
				{
					firstUpdate = false;
					p.unit.lastBulletLocal = nextLocalUpdate;
				}
			}
			else
			{
				if (nextGlobalUpdate < m.time)
				{
					_loc3_ = true;
					_loc25_ = m.unitManager.units;
					localTargetList.splice(0, localTargetList.length);
					nextGlobalUpdate = m.time + 1000;
				}
				else
				{
					_loc3_ = false;
					_loc25_ = localTargetList;
				}
				_loc19_ = int(_loc25_.length);
				_loc22_ = 0;
				while (_loc22_ < _loc19_)
				{
					_loc23_ = _loc25_[_loc22_];
					if (!(!_loc23_.canBeDamage(p.unit, p) || !(p.aiTargetSelf && p.unit == _loc23_)))
					{
						_loc15_ = _loc23_.pos.x;
						_loc20_ = _loc23_.pos.y;
						_loc6_ = _loc4_.x - _loc15_;
						_loc7_ = _loc4_.y - _loc20_;
						_loc12_ = _loc6_ * _loc6_ + _loc7_ * _loc7_;
						if (_loc3_ && _loc12_ < localRangeSQ)
						{
							localTargetList.push(_loc23_);
						}
						if (_loc13_ > _loc12_)
						{
							_loc13_ = _loc12_;
						}
						if (_loc12_ <= 2500)
						{
							_loc8_ = _loc15_ * _loc26_ - _loc20_ * _loc11_;
							_loc18_ = _loc15_ * _loc11_ + _loc20_ * _loc26_;
							_loc24_ = _loc23_.collisionRadius;
							if (_loc8_ <= _loc10_ + _loc24_ && _loc8_ > _loc5_ - _loc24_ && _loc18_ <= _loc2_ + _loc24_ && _loc18_ > _loc17_ - _loc24_)
							{
								if (p.numberOfHits <= 1)
								{
									_loc4_.y = (_loc17_ * _loc26_ / _loc11_ - _loc8_ + (_loc24_ - p.collisionRadius)) / (1 * _loc11_ + _loc26_ * _loc26_ / _loc11_);
									_loc4_.x = (_loc17_ - _loc4_.y * _loc26_) / _loc11_;
									p.destroy();
									return;
								}
								p.explode();
								if (p.numberOfHits >= 10)
								{
									p.numberOfHits--;
								}
							}
						}
					}
					_loc22_++;
				}
				nextLocalUpdate = m.time + Math.sqrt(_loc13_) * 1000 / (p.speedMax + 400) - 35;
				if (nextGlobalUpdate < nextLocalUpdate)
				{
					nextGlobalUpdate = nextLocalUpdate;
				}
				if (firstUpdate)
				{
					firstUpdate = false;
					p.unit.lastBulletGlobal = nextGlobalUpdate;
					p.unit.lastBulletLocal = nextLocalUpdate;
					p.unit.lastBulletTargetList = localTargetList;
				}
			}
		}
		
		public function aim(param1:Unit):void
		{
			var _loc6_:Number = 0;
			var _loc7_:Number = 0;
			var _loc2_:Number = param1.pos.x;
			var _loc4_:Number = param1.pos.y;
			var _loc5_:Number = p.course.pos.x;
			var _loc8_:Number = p.course.pos.y;
			_loc6_ = _loc2_ - _loc5_;
			_loc7_ = _loc4_ - _loc8_;
			var _loc10_:Number = Math.sqrt(_loc6_ * _loc6_ + _loc7_ * _loc7_);
			_loc6_ /= _loc10_;
			_loc7_ /= _loc10_;
			var _loc3_:Number = _loc10_ / (p.course.speed.length - Util.dotProduct(param1.speed.x, param1.speed.y, _loc6_, _loc7_));
			var _loc9_:Number = _loc2_ + param1.speed.x * _loc3_;
			var _loc11_:Number = _loc4_ + param1.speed.y * _loc3_;
			p.course.rotation = Math.atan2(_loc11_ - _loc8_, _loc9_ - _loc5_);
		}
		
		public function exit():void
		{
		}
		
		public function set stateMachine(param1:StateMachine):void
		{
			this.sm = param1;
		}
		
		public function get type():String
		{
			return "Bouncing";
		}
	}
}
