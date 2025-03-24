package core.states.ship {
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.states.IState;
	import core.states.StateMachine;
	import sound.ISound;
	import sound.SoundLocator;
	
	public class WarpJump implements IState {
		private var ship:PlayerShip;
		
		private var sm:StateMachine;
		
		private var g:Game;
		
		private var hyperDriveEngaged:Boolean = false;
		
		private var warpJumpEffect:Vector.<Emitter>;
		
		public function WarpJump(g:Game, ship:PlayerShip) {
			super();
			this.g = g;
			this.ship = ship;
		}
		
		public function enter() : void {
			var soundManager:ISound;
			ship.engine.speed = 500 * 60;
			ship.rotation = 0;
			ship.course.rotateLeft = false;
			ship.course.rotateRight = false;
			warpJumpEffect = EmitterFactory.create("XCQvBR1tSES8xZSb36V2wQ",g,ship.x,ship.y,ship,false);
			if(g.camera.isCircleOnScreen(ship.x,ship.y,5 * 60) || g.me.ship == ship) {
				soundManager = SoundLocator.getService();
				soundManager.play("-TW1TY5ePE-mLbzmtSwdKg",function():void {
					ship.accelerate = true;
				});
			} else {
				ship.accelerate = true;
			}
		}
		
		public function execute() : void {
			ship.rotation = 0;
			ship.course.rotateLeft = false;
			ship.course.rotateRight = false;
			ship.accelerate = true;
			if(ship.speed.length >= 700) {
				if(!hyperDriveEngaged) {
					for each(var _local1 in warpJumpEffect) {
						_local1.posX = ship.x;
						_local1.posY = ship.y;
						_local1.play();
					}
					hyperDriveEngaged = true;
				}
			}
			ship.updateHeading();
			ship.engine.update();
		}
		
		public function exit() : void {
			for each(var _local1 in warpJumpEffect) {
				_local1.killEmitter();
			}
		}
		
		public function get type() : String {
			return "WarpJump";
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
	}
}

