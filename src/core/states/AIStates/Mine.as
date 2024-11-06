package core.states.AIStates
{
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.states.IState;
	import core.states.StateMachine;

	public class Mine implements IState
	{
		private var g:Game;
		private var p:Projectile;
		private var sm:StateMachine;
		private var activateTime:Number;
		private var delay:int;
		private var activated:Boolean = false;
		public function Mine(param1:Game, param2:Projectile, param3:int)
		{
			super();
			this.g = param1;
			this.p = param2;
			this.delay = param3;
		}

		public function enter():void
		{
			activateTime = g.time + delay;
			if (activateTime > g.time)
			{
				p.disable();
				activated = false;
			}
		}

		public function execute():void
		{
			p.updateHeading(p.course);
			if (!activated && activateTime < g.time)
			{
				p.activate();
				activated = true;
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
			return "Mine";
		}
	}
}
