package feathers.utils.touch {
	import flash.geom.Point;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Stage;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	public class TapToTrigger {
		private static const HELPER_POINT:Point = new Point();
		
		protected var _target:DisplayObject;
		
		protected var _touchPointID:int = -1;
		
		protected var _isEnabled:Boolean = true;
		
		public function TapToTrigger(target:DisplayObject = null) {
			super();
			this.target = target;
		}
		
		public function get target() : DisplayObject {
			return this._target;
		}
		
		public function set target(value:DisplayObject) : void {
			if(this._target == value) {
				return;
			}
			if(this._target) {
				this._target.removeEventListener("touch",target_touchHandler);
			}
			this._target = value;
			if(this._target) {
				this._touchPointID = -1;
				this._target.addEventListener("touch",target_touchHandler);
			}
		}
		
		public function get isEnabled() : Boolean {
			return this._isEnabled;
		}
		
		public function set isEnabled(value:Boolean) : void {
			if(this._isEnabled === value) {
				return;
			}
			this._isEnabled = value;
			if(!value) {
				this._touchPointID = -1;
			}
		}
		
		protected function target_touchHandler(event:TouchEvent) : void {
			var _local4:Touch = null;
			var _local2:Stage = null;
			var _local3:* = false;
			if(!this._isEnabled) {
				this._touchPointID = -1;
				return;
			}
			if(this._touchPointID >= 0) {
				_local4 = event.getTouch(this._target,null,this._touchPointID);
				if(!_local4) {
					return;
				}
				if(_local4.phase == "ended") {
					_local2 = this._target.stage;
					if(_local2 !== null) {
						_local4.getLocation(_local2,HELPER_POINT);
						if(this._target is DisplayObjectContainer) {
							_local3 = Boolean(DisplayObjectContainer(this._target).contains(_local2.hitTest(HELPER_POINT)));
						} else {
							_local3 = this._target === _local2.hitTest(HELPER_POINT);
						}
						if(_local3) {
							this._target.dispatchEventWith("triggered");
						}
					}
					this._touchPointID = -1;
				}
				return;
			}
			_local4 = event.getTouch(DisplayObject(this._target),"began");
			if(!_local4) {
				return;
			}
			this._touchPointID = _local4.id;
		}
	}
}

