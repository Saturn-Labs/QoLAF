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

	public class ProjectileStuck implements IState
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
		public function ProjectileStuck(param1:Game, param2:Projectile, param3:Unit)
		{
			super();
			this.m = param1;
			this.p = param2;
			pos = param2.course.pos;
			stuckUnit = param3;
			param2.target = param3;
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
		}

		public function execute():void
		{
			var _loc1_:Number = NaN;
			if (!stuckUnit.alive)
			{
				p.destroy();
			}
			_loc1_ = Util.clampRadians(stuckUnit.rotation - stuckAngle);
			p.course.rotation = startAngle + _loc1_;
			pos.x = stuckUnit.pos.x + Math.cos(_loc1_) * stuckOffset.x - Math.sin(_loc1_) * stuckOffset.y;
			pos.y = stuckUnit.pos.y + Math.sin(_loc1_) * stuckOffset.x + Math.cos(_loc1_) * stuckOffset.y;
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
			return "ProjectileStuck";
		}
	}
}
