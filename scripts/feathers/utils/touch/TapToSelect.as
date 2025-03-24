package feathers.utils.touch {
	import feathers.core.IToggle;
	import flash.geom.Point;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Stage;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	public class TapToSelect {
		private static const HELPER_POINT:Point = new Point();
		
		protected var _target:IToggle;
		
		protected var _touchPointID:int = -1;
		
		protected var _isEnabled:Boolean = true;
		
		protected var _tapToDeselect:Boolean = false;
		
		public function TapToSelect(target:IToggle = null) {
			super();
			this.target = target;
		}
		
		public function get target() : IToggle {
			return this._target;
		}
		
		public function set target(value:IToggle) : void {
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
		
		public function get tapToDeselect() : Boolean {
			return this._tapToDeselect;
		}
		
		public function set tapToDeselect(value:Boolean) : void {
			this._tapToDeselect = value;
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
				_local4 = event.getTouch(DisplayObject(this._target),null,this._touchPointID);
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
							if(this._tapToDeselect) {
								this._target.isSelected = !this._target.isSelected;
							} else {
								this._target.isSelected = true;
							}
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

