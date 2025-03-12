package core.states.ship
{
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.states.IState;
	import core.states.StateMachine;
	
	public class Intro implements IState
	{
		private var ship:PlayerShip;
		
		private var sm:StateMachine;
		
		private var g:Game;
		
		private var hyperDriveEngaged:Boolean = true;
		private var warpJumpEffect:Vector.<Emitter>;
		
		private var startX:Number = 0;
		private var startY:Number = 0;
		public function Intro(param1:Game, param2:PlayerShip, param3:Number, param4:Number)
		{
			super();
			this.g = param1;
			this.ship = param2;
			this.startX = param3;
			this.startY = param4;
		}
		
		public function enter():void
		{
			warpJumpEffect = EmitterFactory.create("vtJpEIW2Z0aMfEtayo62GA", g, ship.x, ship.y, ship, true);
			for each (var _loc1_:* in warpJumpEffect)
			{
				_loc1_.fastForward(2000);
			}
		}
		
		public function execute():void
		{
			var _loc2_:Number = NaN;
			if (ship.x <= startX - 20)
			{
				if (ship.x >= -500)
				{
					_loc2_ = startX - ship.x;
					ship.x += _loc2_ / 33;
					if (hyperDriveEngaged)
					{
						for each (var _loc1_:* in warpJumpEffect)
						{
							_loc1_.stop();
						}
						hyperDriveEngaged = false;
					}
				}
				else
				{
					ship.x += 15.151515151515152;
				}
			}
			ship.engine.update();
		}
		
		public function exit():void
		{
			for each (var _loc1_:* in warpJumpEffect)
			{
				_loc1_.killEmitter();
			}
		}
		
		public function get type():String
		{
			return "WarpJump";
		}
		
		public function set stateMachine(param1:StateMachine):void
		{
			this.sm = param1;
		}
	}
}
