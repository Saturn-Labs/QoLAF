package qolaf.modifiers {
	import core.scene.Game;
	import core.weapon.Debuff;
	
	/**
	 * @author rydev
	 */
	public class Modifier {
		private var _id:int = -1;
		private var _duration:int = 0;
		private var _startTime:int = 0;
		private var _stacks:uint = 1;
		
		public function Modifier(id:int, duration:int) {
			this._id = id;
			this._duration = duration;
			this._startTime = Game.instance.time;
			this._stacks = 1;
		}
		
		public function stackAndReset():void {
			if (Debuff.canStack(_id))
				_stacks++;
			if (!Debuff.stacksDontResetTime(_id))
				this._startTime = Game.instance.time;
		}
		
		public function get id():int {
			return _id;
		}
		
		public function get duration():int {
			return _duration;
		}
		
		public function get startTime():int {
			return _startTime;
		}
		
		public function get endTime():int {
			return startTime + duration;
		}
		
		public function get stacks():uint {
			return _stacks;
		}
		
		public function get currentDuration():int {
			return endTime - Game.instance.time;
		}
		
		public function get hasEnded():Boolean {
			return currentDuration <= 0;
		}
	}
}