package core.states.AIStates
{
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.ship.PlayerShip;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	import movement.Heading;

	public class AIKamikaze implements IState
	{
		private var g:Game;
		private var s:EnemyShip;
		private var sm:StateMachine;
		private var startTime:Number;
		private var startDelay:Number = 1000;
		public function AIKamikaze(param1:Game, param2:EnemyShip, param3:Unit, param4:Heading, param5:int)
		{
			super();
			param2.target = param3;
			param2.setConvergeTarget(param4);
			param2.nextTurnDir = param5;
			this.g = param1;
			this.s = param2;
			if (!(param2.target is PlayerShip) && param2.factions.length == 0)
			{
				param2.factions.push("tempFaction");
			}
		}

		public function enter():void
		{
			s.startKamikaze();
			startTime = g.time;
			s.setAngleTargetPos(null);
			s.accelerate = false;
			s.stopShooting();
		}

		public function execute():void
		{
			if (s.kamikazeHoming && s.target != null && s.target.alive)
			{
				s.setAngleTargetPos(s.target.pos);
				s.accelerate = true;
			}
			s.runConverger();
			s.regenerateShield();
			s.updateHealthBars();
			s.engine.update();
			s.updateWeapons();
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
			return "AIKamikaze";
		}
	}
}
