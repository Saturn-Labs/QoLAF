package feathers.core {
	import feathers.controls.Label;
	import flash.utils.getTimer;
	import starling.animation.DelayedCall;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	public class DefaultToolTipManager implements IToolTipManager {
		protected var _touchPointID:int = -1;
		
		protected var _delayedCall:DelayedCall;
		
		protected var _toolTipX:Number = 0;
		
		protected var _toolTipY:Number = 0;
		
		protected var _hideTime:int = 0;
		
		protected var _root:DisplayObjectContainer;
		
		protected var _target:IFeathersControl;
		
		protected var _toolTip:IToolTip;
		
		protected var _toolTipFactory:Function;
		
		protected var _showDelay:Number = 0.5;
		
		protected var _resetDelay:Number = 0.1;
		
		protected var _offsetX:Number = 0;
		
		protected var _offsetY:Number = 0;
		
		public function DefaultToolTipManager(root:DisplayObjectContainer) {
			super();
			this._root = root;
			this._root.addEventListener("touch",root_touchHandler);
		}
		
		public static function defaultToolTipFactory() : IToolTip {
			var _local1:Label = new Label();
			_local1.styleNameList.add("feathers-tool-tip");
			return _local1;
		}
		
		public function get toolTipFactory() : Function {
			return this._toolTipFactory;
		}
		
		public function set toolTipFactory(value:Function) : void {
			if(this._toolTipFactory === value) {
				return;
			}
			this._toolTipFactory = value;
			if(this._toolTip) {
				this._toolTip.removeFromParent(true);
				this._toolTip = null;
			}
		}
		
		public function get showDelay() : Number {
			return this._showDelay;
		}
		
		public function set showDelay(value:Number) : void {
			this._showDelay = value;
		}
		
		public function get resetDelay() : Number {
			return this._resetDelay;
		}
		
		public function set resetDelay(value:Number) : void {
			this._resetDelay = value;
		}
		
		public function get offsetX() : Number {
			return this._offsetX;
		}
		
		public function set offsetX(value:Number) : void {
			this._offsetX = value;
		}
		
		public function get offsetY() : Number {
			return this._offsetY;
		}
		
		public function set offsetY(value:Number) : void {
			this._offsetY = value;
		}
		
		public function dispose() : void {
			this._root.removeEventListener("touch",root_touchHandler);
			this._root = null;
			if(Starling.juggler.contains(this._delayedCall)) {
				Starling.juggler.remove(this._delayedCall);
				this._delayedCall = null;
			}
			if(this._toolTip) {
				this._toolTip.removeFromParent(true);
				this._toolTip = null;
			}
		}
		
		protected function getTarget(touch:Touch) : IFeathersControl {
			var _local2:IFeathersControl = null;
			var _local3:DisplayObject = touch.target;
			while(_local3 !== null) {
				if(_local3 is IFeathersControl) {
					_local2 = IFeathersControl(_local3);
					if(_local2.toolTip) {
						return _local2;
					}
				}
				_local3 = _local3.parent;
			}
			return null;
		}
		
		protected function hoverDelayCallback() : void {
			var _local1:Function = null;
			var _local2:Label = null;
			if(!this._toolTip) {
				_local1 = this._toolTipFactory !== null ? this._toolTipFactory : defaultToolTipFactory;
				_local2 = _local1();
				_local2.touchable = false;
				this._toolTip = _local2;
			}
			this._toolTip.text = this._target.toolTip;
			this._toolTip.validate();
			var _local4:Number = this._toolTipX + this._offsetX;
			if(_local4 < 0) {
				_local4 = 0;
			} else if(_local4 + this._toolTip.width > this._target.stage.stageWidth) {
				_local4 = this._target.stage.stageWidth - this._toolTip.width;
			}
			var _local3:Number = this._toolTipY - this._toolTip.height + this._offsetY;
			if(_local3 < 0) {
				_local3 = 0;
			} else if(_local3 + this._toolTip.height > this._target.stage.stageHeight) {
				_local3 = this._target.stage.stageHeight - this._toolTip.height;
			}
			this._toolTip.x = _local4;
			this._toolTip.y = _local3;
			PopUpManager.addPopUp(DisplayObject(this._toolTip),false,false);
		}
		
		protected function root_touchHandler(event:TouchEvent) : void {
			var _local3:Touch = null;
			var _local2:Number = NaN;
			if(this._toolTip !== null && this._toolTip.parent !== null) {
				_local3 = event.getTouch(DisplayObject(this._target),null,this._touchPointID);
				if(!_local3 || _local3.phase !== "hover") {
					PopUpManager.removePopUp(DisplayObject(this._toolTip),false);
					this._touchPointID = -1;
					this._target = null;
					this._hideTime = getTimer();
				}
				return;
			}
			if(this._target !== null) {
				_local3 = event.getTouch(DisplayObject(this._target),null,this._touchPointID);
				if(!_local3 || _local3.phase !== "hover") {
					Starling.juggler.remove(this._delayedCall);
					this._touchPointID = -1;
					this._target = null;
					return;
				}
				this._toolTipX = _local3.globalX;
				this._toolTipY = _local3.globalY;
				this._delayedCall.reset(hoverDelayCallback,this._showDelay);
			} else {
				_local3 = event.getTouch(this._root,"hover");
				if(!_local3) {
					return;
				}
				this._target = this.getTarget(_local3);
				if(!this._target) {
					return;
				}
				this._touchPointID = _local3.id;
				this._toolTipX = _local3.globalX;
				this._toolTipY = _local3.globalY;
				_local2 = (getTimer() - this._hideTime) / 1000;
				if(_local2 < this._resetDelay) {
					this.hoverDelayCallback();
					return;
				}
				if(this._delayedCall) {
					this._delayedCall.reset(hoverDelayCallback,this._showDelay);
				} else {
					this._delayedCall = new DelayedCall(hoverDelayCallback,this._showDelay);
				}
				Starling.juggler.add(this._delayedCall);
			}
		}
	}
}

