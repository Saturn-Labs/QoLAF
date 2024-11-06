package core.states.AIStates
{
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;

	public class Blastwave implements IState
	{
		private var m:Game;
		private var p:Projectile;
		private var sm:StateMachine;
		private var delay:int;
		private var follow:Boolean;
		private var blastStartTime:Number = 0;
		public function Blastwave(param1:Game, param2:Projectile, param3:int, param4:Boolean)
		{
			super();
			this.m = param1;
			this.p = param2;
			this.delay = param3;
			this.follow = param4;
		}

		public function enter():void
		{
			blastStartTime = m.time + delay;
		}

		public function execute():void
		{
			var _loc2_:Boolean = false;
			var _loc1_:Unit = null;
			p.updateHeading(p.course);
			if (blastStartTime < m.time)
			{
				_loc2_ = m.camera.isCircleOnScreen(p.pos.x, p.pos.y, p.dmgRadius);
				_loc1_ = null;
				if (follow)
				{
					_loc1_ = p.target;
				}
				p.explode(_loc2_, _loc1_);
				p.destroy(false);
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
			return "Blastwave";
		}
	}
}
