package core.states.ship
{
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.states.IState;
	import core.states.StateMachine;
	import sound.ISound;
	import sound.SoundLocator;
	
	public class WarpJump implements IState
	{
		private var ship:PlayerShip;
		
		private var sm:StateMachine;
		
		private var g:Game;
		
		private var hyperDriveEngaged:Boolean = false;
		private var warpJumpEffect:Vector.<Emitter>;
		
		public function WarpJump(param1:Game, param2:PlayerShip)
		{
			super();
			this.g = param1;
			this.ship = param2;
		}
		
		public function enter():void
		{
			var soundManager:ISound;
			ship.engine.speed = 30000;
			ship.rotation = 0;
			ship.course.rotateLeft = false;
			ship.course.rotateRight = false;
			warpJumpEffect = EmitterFactory.create("XCQvBR1tSES8xZSb36V2wQ", g, ship.x, ship.y, ship, false);
			if (g.camera.isCircleOnScreen(ship.x, ship.y, 300) || g.me.ship == ship)
			{
				soundManager = SoundLocator.getService();
				soundManager.play("-TW1TY5ePE-mLbzmtSwdKg", function():void
				{
					ship.accelerate = true;
				});
			}
			else
			{
				ship.accelerate = true;
			}
		}
		
		public function execute():void
		{
			ship.rotation = 0;
			ship.course.rotateLeft = false;
			ship.course.rotateRight = false;
			ship.accelerate = true;
			if (ship.speed.length >= 700)
			{
				if (!hyperDriveEngaged)
				{
					for each (var _loc1_:* in warpJumpEffect)
					{
						_loc1_.posX = ship.x;
						_loc1_.posY = ship.y;
						_loc1_.play();
					}
					hyperDriveEngaged = true;
				}
			}
			ship.updateHeading();
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
