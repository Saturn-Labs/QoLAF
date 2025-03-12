package core.states.AIStates
{
	import core.GameObject;
	import core.particle.Emitter;
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	import generics.Util;
	
	public class Boomerang extends ProjectileBullet implements IState
	{
		private var g:Game;
		
		private var _p:Projectile;
		
		private var _sm:StateMachine;
		
		private var _isEnemy:Boolean;
		
		private var globalInterval:Number = 1000;
		private var localTargetList:Vector.<Unit>;
		
		private var nextGlobalUpdate:Number;
		
		private var nextLocalUpdate:Number;
		
		private var localRangeSQ:Number;
		
		private var firstUpdate:Boolean;
		
		private var engine:GameObject;
		
		private var elapsedTime:Number = 0;
		private var startTime:Number = 0;
		public function Boomerang(param1:Game, param2:Projectile)
		{
			this.g = param1;
			this._p = param2;
			param2.convergenceCounter = 0;
			param2.convergenceTime = 0;
			param2.error = null;
			engine = new GameObject();
			super(param1, param2);
		}
		
		override public function enter():void
		{
			super.enter();
		}
		
		override public function execute():void
		{
			var _loc7_:Number = NaN;
			var _loc5_:Number = NaN;
			var _loc6_:Number = NaN;
			var _loc4_:Number = NaN;
			for each (var _loc3_:* in _p.thrustEmitters)
			{
				_loc3_.target = engine;
			}
			var _loc1_:Number = 33;
			var _loc2_:int = (_p.convergenceTime - _p.convergenceCounter) / _p.convergenceTime;
			if (_loc2_ <= 0)
			{
				_p.error = null;
			}
			if (_p.error != null)
			{
				_p.course.pos.x += _p.error.x * _loc2_;
				_p.course.pos.y += _p.error.y * _loc2_;
			}
			if (elapsedTime > _p.boomerangReturnTime)
			{
				_p.boomerangReturning = true;
			}
			if (_p.boomerangReturning == true)
			{
				if (startTime == 0)
				{
					startTime = g.time;
				}
				_loc7_ = _p.unit.pos.y - _p.course.pos.y;
				_loc5_ = _p.unit.pos.x - _p.course.pos.x;
				if (startTime + 100 < g.time)
				{
					_loc6_ = Math.atan2(_loc7_, _loc5_);
					_loc4_ = Util.angleDifference(_p.course.rotation, _loc6_ + 3.141592653589793);
					if (_loc4_ > 0 && _loc4_ < 0.95 * 3.141592653589793)
					{
						_p.direction = 1;
					}
					else if (_loc4_ < 0 && _loc4_ > -0.95 * 3.141592653589793)
					{
						_p.direction = 2;
					}
					else
					{
						_p.direction = 3;
					}
				}
				if (_p.direction == 1)
				{
					_p.course.rotation += _p.rotationSpeedMax * _loc1_ / 1000;
					_p.course.rotation = Util.clampRadians(_p.course.rotation);
				}
				else if (_p.direction == 2)
				{
					_p.course.rotation -= _p.rotationSpeedMax * _loc1_ / 1000;
					_p.course.rotation = Util.clampRadians(_p.course.rotation);
				}
				if (_loc7_ * _loc7_ + _loc5_ * _loc5_ < 2500)
				{
					_p.destroy(false);
				}
			}
			super.execute();
			elapsedTime += _loc1_;
		}
		
		override public function exit():void
		{
		}
		
		override public function set stateMachine(param1:StateMachine):void
		{
			this._sm = param1;
		}
		
		override public function get type():String
		{
			return "Boomerang";
		}
	}
}
