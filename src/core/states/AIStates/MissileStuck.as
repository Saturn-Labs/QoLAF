package core.states.AIStates
{
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.ship.Ship;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	import flash.geom.Point;
	import generics.Util;
	
	public class MissileStuck implements IState
	{
		private var m:Game;
		
		private var p:Projectile;
		
		private var sm:StateMachine;
		
		private var isEnemy:Boolean;
		
		private var stuckShip:Ship = null;
		private var stuckUnit:Unit = null;
		private var stuckOffset:Point;
		
		private var stuckAngle:Number;
		
		private var startAngle:Number;
		
		private var pos:Point;
		
		public function MissileStuck(param1:Game, param2:Projectile)
		{
			var _loc3_:Number = NaN;
			super();
			this.m = param1;
			this.p = param2;
			pos = param2.course.pos;
			stuckUnit = param2.target;
			stuckAngle = stuckUnit.rotation;
			var _loc5_:Point = new Point(pos.x - stuckUnit.pos.x, pos.y - stuckUnit.pos.y);
			var _loc4_:Number = Number(_loc5_.length.valueOf());
			if (_loc4_ > stuckUnit.radius * 0.8)
			{
				stuckOffset = new Point(stuckUnit.radius * 0.8 * _loc5_.x / _loc4_, stuckUnit.radius * 0.8 * _loc5_.y / _loc4_);
			}
			else
			{
				stuckOffset = _loc5_;
			}
			startAngle = param2.course.rotation;
			param2.course.rotation = startAngle;
			param2.course.speed.x = 0;
			param2.course.speed.y = 0;
			param2.acceleration = 0;
			_loc5_ = pos.clone();
			_loc3_ = Util.clampRadians(stuckUnit.rotation - stuckAngle);
			param2.course.rotation = startAngle + _loc3_;
			pos.x = stuckUnit.pos.x + Math.cos(_loc3_) * stuckOffset.x - Math.sin(_loc3_) * stuckOffset.y;
			pos.y = stuckUnit.pos.y + Math.sin(_loc3_) * stuckOffset.x + Math.cos(_loc3_) * stuckOffset.y;
			param2.error = new Point(_loc5_.x - pos.x, _loc5_.y - pos.y);
			param2.convergenceCounter = 0;
			param2.convergenceTime = 1000 / 33;
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
			p.ttl = p.ttlMax + p.aiStuckDuration * 1000;
		}
		
		public function execute():void
		{
			var _loc3_:Number = NaN;
			var _loc1_:Number = NaN;
			var _loc2_:Number = NaN;
			if (!p.aiStuck)
			{
				p.target = null;
				p.ttl = p.ttlMax;
				p.numberOfHits = 1;
				p.acceleration = p.weapon.acceleration;
				sm.changeState(new Missile(m, p));
				return;
			}
			if (stuckUnit == null || !stuckUnit.alive)
			{
				return;
			}
			_loc3_ = Util.clampRadians(stuckUnit.rotation - stuckAngle);
			p.course.rotation = startAngle + _loc3_;
			pos.x = stuckUnit.pos.x + Math.cos(_loc3_) * stuckOffset.x - Math.sin(_loc3_) * stuckOffset.y;
			pos.y = stuckUnit.pos.y + Math.sin(_loc3_) * stuckOffset.x + Math.cos(_loc3_) * stuckOffset.y;
			_loc1_ = 33;
			_loc2_ = (p.convergenceTime - p.convergenceCounter) / p.convergenceTime;
			if (_loc2_ <= 0)
			{
				p.error = null;
			}
			if (p.error != null)
			{
				p.convergenceCounter++;
				_loc2_ = (p.convergenceTime - p.convergenceCounter) / p.convergenceTime;
				pos.x += p.error.x * _loc2_;
				pos.y += p.error.y * _loc2_;
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
			return "MissileStuck";
		}
	}
}
