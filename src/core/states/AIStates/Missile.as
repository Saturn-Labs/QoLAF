package core.states.AIStates
{
	import core.GameObject;
	import core.particle.Emitter;
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.states.IState;
	import core.states.StateMachine;
	import flash.geom.Point;
	import generics.Util;
	
	public class Missile implements IState
	{
		private var g:Game;
		
		private var p:Projectile;
		
		private var sm:StateMachine;
		
		private var isEnemy:Boolean;
		
		private var engine:GameObject;
		
		private var startTime:Number;
		
		public function Missile(param1:Game, param2:Projectile)
		{
			super();
			this.g = param1;
			this.p = param2;
			if (param2.isHeal || param2.unit.factions.length > 0)
			{
				this.isEnemy = false;
			}
			else
			{
				this.isEnemy = param2.unit.type == "enemyShip" || param2.unit.type == "turret";
			}
			param2.convergenceCounter = 0;
			engine = new GameObject();
		}
		
		public function enter():void
		{
			startTime = g.time;
		}
		
		public function execute():void
		{
			var _loc5_:Point = null;
			var _loc6_:Number = NaN;
			var _loc4_:Number = NaN;
			if (p.aiStuck)
			{
				sm.changeState(new MissileStuck(g, p));
				return;
			}
			for each (var _loc3_:* in p.thrustEmitters)
			{
				_loc3_.target = engine;
			}
			var _loc1_:Number = 33;
			var _loc2_:Number = (p.convergenceTime - p.convergenceCounter) / p.convergenceTime;
			if (_loc2_ <= 0)
			{
				p.error = null;
			}
			if (p.error != null)
			{
				p.course.pos.x += p.error.x * _loc2_;
				p.course.pos.y += p.error.y * _loc2_;
				p.course.rotation += p.errorRot * _loc2_;
			}
			if (p.target != null)
			{
				if (!p.target.alive)
				{
					p.target = null;
					return;
				}
				_loc5_ = p.target.pos;
			}
			else if (p.targetProjectile != null)
			{
				if (!p.targetProjectile.alive)
				{
					p.targetProjectile = null;
					return;
				}
				_loc5_ = p.targetProjectile.pos;
			}
			if (_loc5_ != null)
			{
				_loc6_ = Math.atan2(_loc5_.y - p.course.pos.y, _loc5_.x - p.course.pos.x);
				_loc4_ = Util.angleDifference(p.course.rotation, _loc6_ + 3.141592653589793);
				if (_loc4_ > 0 && _loc4_ < 3.141592653589793 - p.rotationSpeedMax * _loc1_ / 1000)
				{
					p.course.rotation += p.rotationSpeedMax * _loc1_ / 1000;
					p.course.rotation = Util.clampRadians(p.course.rotation);
				}
				else if (_loc4_ < 0 && _loc4_ > -3.141592653589793 + p.rotationSpeedMax * _loc1_ / 1000)
				{
					p.course.rotation -= p.rotationSpeedMax * _loc1_ / 1000;
					p.course.rotation = Util.clampRadians(p.course.rotation);
				}
				else
				{
					p.course.rotation = Util.clampRadians(_loc6_);
				}
			}
			if (g.time - startTime >= p.aiDelayedAccelerationTime)
			{
				p.updateHeading(p.course);
			}
			else
			{
				p.course.time += 33;
			}
			engine.x = p.pos.x - Math.cos(p.rotation) * p.radius;
			engine.y = p.pos.y - Math.sin(p.rotation) * p.radius;
			if (p.error != null)
			{
				p.convergenceCounter++;
				_loc2_ = (p.convergenceTime - p.convergenceCounter) / p.convergenceTime;
				p.course.pos.x -= p.error.x * _loc2_;
				p.course.pos.y -= p.error.y * _loc2_;
				p.course.rotation -= p.errorRot * _loc2_;
			}
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
			return "Missile";
		}
	}
}
