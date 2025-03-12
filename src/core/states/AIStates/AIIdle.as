package core.states.AIStates
{
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.states.IState;
	import core.states.StateMachine;
	import movement.Heading;
	
	public class AIIdle implements IState
	{
		private var g:Game;
		
		private var s:EnemyShip;
		
		private var sm:StateMachine;
		
		public function AIIdle(param1:Game, param2:EnemyShip, param3:Heading)
		{
			super();
			param2.initCourse(param3);
			param2.engine.speed = 0.2 * param2.engine.speed;
			if (param2.factions.length == 1 && param2.factions[0] == "tempFaction")
			{
				param2.factions.splice(0, 1);
			}
			this.g = param1;
			this.s = param2;
		}
		
		public function enter():void
		{
			s.target = null;
			s.setAngleTargetPos(null);
			s.stopShooting();
		}
		
		public function execute():void
		{
			s.convergerUpdateHeading(s.course);
			s.regenerateShield();
			s.updateHealthBars();
			s.accelerate = true;
			s.engine.update();
			s.updateWeapons();
		}
		
		public function exit():void
		{
			s.course.accelerate = false;
			s.engine.speed = 5 * s.engine.speed;
		}
		
		public function set stateMachine(param1:StateMachine):void
		{
			this.sm = param1;
		}
		
		public function get type():String
		{
			return "AIIdle";
		}
	}
}
