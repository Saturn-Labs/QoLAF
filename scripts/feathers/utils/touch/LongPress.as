package feathers.utils.touch {
	import flash.geom.Point;
	import flash.utils.getTimer;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Stage;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	public class LongPress {
		protected var _target:DisplayObject;
		
		protected var _longPressDuration:Number = 0.5;
		
		protected var _touchPointID:int = -1;
		
		protected var _touchLastGlobalPosition:Point = new Point();
		
		protected var _touchBeginTime:int;
		
		protected var _isEnabled:Boolean = true;
		
		protected var _tapToTrigger:TapToTrigger;
		
		protected var _tapToSelect:TapToSelect;
		
		public function LongPress(target:DisplayObject = null) {
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
		
		public function get longPressDuration() : Number {
			return this._longPressDuration;
		}
		
		public function set longPressDuration(value:Number) : void {
			this._longPressDuration = value;
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
		
		public function get tapToTrigger() : TapToTrigger {
			return this._tapToTrigger;
		}
		
		public function set tapToTrigger(value:TapToTrigger) : void {
			this._tapToTrigger = value;
		}
		
		public function get tapToSelect() : TapToSelect {
			return this._tapToSelect;
		}
		
		public function set tapToSelect(value:TapToSelect) : void {
			this._tapToSelect = value;
		}
		
		protected function target_touchHandler(event:TouchEvent) : void {
			var _local2:Touch = null;
			if(!this._isEnabled) {
				this._touchPointID = -1;
				return;
			}
			if(this._touchPointID >= 0) {
				_local2 = event.getTouch(this._target,null,this._touchPointID);
				if(!_local2) {
					return;
				}
				if(_local2.phase == "moved") {
					this._touchLastGlobalPosition.x = _local2.globalX;
					this._touchLastGlobalPosition.y = _local2.globalY;
				} else if(_local2.phase == "ended") {
					this._target.removeEventListener("enterFrame",target_enterFrameHandler);
					if(this._tapToTrigger) {
						this._tapToTrigger.isEnabled = true;
					}
					if(this._tapToSelect) {
						this._tapToSelect.isEnabled = true;
					}
					this._touchPointID = -1;
				}
				return;
			}
			_local2 = event.getTouch(DisplayObject(this._target),"began");
			if(!_local2) {
				return;
			}
			this._touchPointID = _local2.id;
			this._touchLastGlobalPosition.x = _local2.globalX;
			this._touchLastGlobalPosition.y = _local2.globalY;
			this._touchBeginTime = getTimer();
			this._target.addEventListener("enterFrame",target_enterFrameHandler);
		}
		
		protected function target_enterFrameHandler(event:Event) : void {
			var _local3:Stage = null;
			var _local4:* = false;
			var _local2:Number = (getTimer() - this._touchBeginTime) / 1000;
			if(_local2 >= this._longPressDuration) {
				this._target.removeEventListener("enterFrame",target_enterFrameHandler);
				_local3 = this._target.stage;
				if(this._target is DisplayObjectContainer) {
					_local4 = Boolean(DisplayObjectContainer(this._target).contains(_local3.hitTest(this._touchLastGlobalPosition)));
				} else {
					_local4 = this._target === _local3.hitTest(this._touchLastGlobalPosition);
				}
				if(_local4) {
					if(this._tapToTrigger) {
						this._tapToTrigger.isEnabled = false;
					}
					if(this._tapToSelect) {
						this._tapToSelect.isEnabled = false;
					}
					this._target.dispatchEventWith("longPress");
				}
			}
		}
	}
}

