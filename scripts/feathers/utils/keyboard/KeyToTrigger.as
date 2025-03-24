package feathers.utils.keyboard {
	import feathers.core.IFocusDisplayObject;
	import starling.display.Stage;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	
	public class KeyToTrigger {
		protected var _target:IFocusDisplayObject;
		
		protected var _keyCode:uint = 32;
		
		protected var _cancelKeyCode:uint = 27;
		
		protected var _isEnabled:Boolean = true;
		
		public function KeyToTrigger(target:IFocusDisplayObject = null) {
			super();
			this.target = target;
		}
		
		public function get target() : IFocusDisplayObject {
			return this._target;
		}
		
		public function set target(value:IFocusDisplayObject) : void {
			if(this._target === value) {
				return;
			}
			if(this._target) {
				this._target.removeEventListener("focusIn",target_focusInHandler);
				this._target.removeEventListener("focusOut",target_focusOutHandler);
				this._target.removeEventListener("removedFromStage",target_removedFromStageHandler);
			}
			this._target = value;
			if(this._target) {
				this._target.addEventListener("focusIn",target_focusInHandler);
				this._target.addEventListener("focusOut",target_focusOutHandler);
				this._target.addEventListener("removedFromStage",target_removedFromStageHandler);
			}
		}
		
		public function get keyCode() : uint {
			return this._keyCode;
		}
		
		public function set keyCode(value:uint) : void {
			this._keyCode = value;
		}
		
		public function get cancelKeyCode() : uint {
			return this._cancelKeyCode;
		}
		
		public function set cancelKeyCode(value:uint) : void {
			this._cancelKeyCode = value;
		}
		
		public function get isEnabled() : Boolean {
			return this._isEnabled;
		}
		
		public function set isEnabled(value:Boolean) : void {
			this._isEnabled = value;
		}
		
		protected function target_focusInHandler(event:Event) : void {
			this._target.stage.addEventListener("keyDown",stage_keyDownHandler);
		}
		
		protected function target_focusOutHandler(event:Event) : void {
			this._target.stage.removeEventListener("keyDown",stage_keyDownHandler);
			this._target.stage.removeEventListener("keyUp",stage_keyUpHandler);
		}
		
		protected function target_removedFromStageHandler(event:Event) : void {
			this._target.stage.removeEventListener("keyDown",stage_keyDownHandler);
			this._target.stage.removeEventListener("keyUp",stage_keyUpHandler);
		}
		
		protected function stage_keyDownHandler(event:KeyboardEvent) : void {
			if(!this._isEnabled) {
				return;
			}
			if(event.keyCode === this._cancelKeyCode) {
				this._target.stage.removeEventListener("keyUp",stage_keyUpHandler);
			} else if(event.keyCode === this._keyCode) {
				this._target.stage.addEventListener("keyUp",stage_keyUpHandler);
			}
		}
		
		protected function stage_keyUpHandler(event:KeyboardEvent) : void {
			if(!this._isEnabled) {
				return;
			}
			if(event.keyCode !== this._keyCode) {
				return;
			}
			var _local2:Stage = Stage(event.currentTarget);
			_local2.removeEventListener("keyUp",stage_keyUpHandler);
			if(this._target.stage !== _local2) {
				return;
			}
			this._target.dispatchEventWith("triggered");
		}
	}
}

