package core.states.ship {
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.states.IState;
	import core.states.StateMachine;
	
	public class Intro implements IState {
		private var ship:PlayerShip;
		
		private var sm:StateMachine;
		
		private var g:Game;
		
		private var hyperDriveEngaged:Boolean = true;
		
		private var warpJumpEffect:Vector.<Emitter>;
		
		private var startX:Number = 0;
		
		private var startY:Number = 0;
		
		public function Intro(g:Game, ship:PlayerShip, startX:Number, startY:Number) {
			super();
			this.g = g;
			this.ship = ship;
			this.startX = startX;
			this.startY = startY;
		}
		
		public function enter() : void {
			warpJumpEffect = EmitterFactory.create("vtJpEIW2Z0aMfEtayo62GA",g,ship.x,ship.y,ship,true);
			for each(var _local1 in warpJumpEffect) {
				_local1.fastForward(2000);
			}
		}
		
		public function execute() : void {
			var _local1:Number = NaN;
			if(ship.x <= startX - 20) {
				if(ship.x >= -500) {
					_local1 = startX - ship.x;
					ship.x += _local1 / 33;
					if(hyperDriveEngaged) {
						for each(var _local2 in warpJumpEffect) {
							_local2.stop();
						}
						hyperDriveEngaged = false;
					}
				} else {
					ship.x += 15.151515151515152;
				}
			}
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

