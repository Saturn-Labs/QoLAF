package feathers.controls {
	import feathers.core.FeathersControl;
	import feathers.core.IFeathersControl;
	import feathers.core.IMeasureDisplayObject;
	import feathers.core.IStateContext;
	import feathers.core.IStateObserver;
	import feathers.core.IValidating;
	import feathers.skins.IStyleProvider;
	import feathers.utils.skins.resetFluidChildDimensionsForMeasurement;
	import feathers.utils.touch.TapToTrigger;
	import flash.geom.Point;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	public class BasicButton extends FeathersControl implements IStateContext {
		public static var globalStyleProvider:IStyleProvider;
		
		private static const HELPER_POINT:Point = new Point();
		
		protected var tapToTrigger:TapToTrigger;
		
		protected var touchPointID:int = -1;
		
		protected var _currentState:String = "up";
		
		protected var currentSkin:DisplayObject;
		
		protected var _keepDownStateOnRollOut:Boolean = false;
		
		protected var _defaultSkin:DisplayObject;
		
		protected var _stateToSkin:Object = {};
		
		protected var _explicitSkinWidth:Number;
		
		protected var _explicitSkinHeight:Number;
		
		protected var _explicitSkinMinWidth:Number;
		
		protected var _explicitSkinMinHeight:Number;
		
		protected var _explicitSkinMaxWidth:Number;
		
		protected var _explicitSkinMaxHeight:Number;
		
		public function BasicButton() {
			super();
			this.isQuickHitAreaEnabled = true;
			this.addEventListener("removedFromStage",basicButton_removedFromStageHandler);
			this.addEventListener("touch",basicButton_touchHandler);
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return BasicButton.globalStyleProvider;
		}
		
		public function get currentState() : String {
			return this._currentState;
		}
		
		override public function set isEnabled(value:Boolean) : void {
			if(this._isEnabled === value) {
				return;
			}
			super.isEnabled = value;
			if(this._isEnabled) {
				if(this._currentState === "disabled") {
					this.changeState("up");
				}
			} else {
				this.resetTouchState();
			}
		}
		
		public function get keepDownStateOnRollOut() : Boolean {
			return this._keepDownStateOnRollOut;
		}
		
		public function set keepDownStateOnRollOut(value:Boolean) : void {
			this._keepDownStateOnRollOut = value;
		}
		
		public function get defaultSkin() : DisplayObject {
			return this._defaultSkin;
		}
		
		public function set defaultSkin(value:DisplayObject) : void {
			if(this._defaultSkin === value) {
				return;
			}
			if(this._defaultSkin !== null && this.currentSkin === this._defaultSkin) {
				this.removeCurrentSkin(this._defaultSkin);
				this.currentSkin = null;
			}
			this._defaultSkin = value;
			this.invalidate("styles");
		}
		
		public function getSkinForState(state:String) : DisplayObject {
			return this._stateToSkin[state] as DisplayObject;
		}
		
		public function setSkinForState(state:String, skin:DisplayObject) : void {
			var _local3:DisplayObject = this._stateToSkin[state] as DisplayObject;
			if(_local3 !== null && this.currentSkin === _local3) {
				this.removeCurrentSkin(_local3);
				this.currentSkin = null;
			}
			if(skin !== null) {
				this._stateToSkin[state] = skin;
			} else {
				delete this._stateToSkin[state];
			}
			this.invalidate("styles");
		}
		
		override public function dispose() : void {
			var _local1:DisplayObject = null;
			if(this._defaultSkin !== null && this._defaultSkin.parent !== this) {
				this._defaultSkin.dispose();
			}
			for(var _local2 in this._stateToSkin) {
				_local1 = this._stateToSkin[_local2] as DisplayObject;
				if(_local1 !== null && _local1.parent !== this) {
					_local1.dispose();
				}
			}
			super.dispose();
		}
		
		override protected function initialize() : void {
			super.initialize();
			if(!this.tapToTrigger) {
				this.tapToTrigger = new TapToTrigger(this);
			}
		}
		
		override protected function draw() : void {
			var _local3:Boolean = this.isInvalid("styles");
			var _local2:Boolean = this.isInvalid("state");
			var _local1:Boolean = this.isInvalid("size");
			if(_local3 || _local2) {
				this.refreshTriggeredEvents();
				this.refreshSkin();
			}
			this.autoSizeIfNeeded();
			this.scaleSkin();
		}
		
		protected function autoSizeIfNeeded() : Boolean {
			var _local3:* = this._explicitWidth !== this._explicitWidth;
			var _local7:* = this._explicitHeight !== this._explicitHeight;
			var _local4:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local9:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local3 && !_local7 && !_local4 && !_local9) {
				return false;
			}
			resetFluidChildDimensionsForMeasurement(this.currentSkin,this._explicitWidth,this._explicitHeight,this._explicitMinWidth,this._explicitMinHeight,this._explicitMaxWidth,this._explicitMaxHeight,this._explicitSkinWidth,this._explicitSkinHeight,this._explicitSkinMinWidth,this._explicitSkinMinHeight,this._explicitSkinMaxWidth,this._explicitSkinMaxHeight);
			var _local8:IMeasureDisplayObject = this.currentSkin as IMeasureDisplayObject;
			if(this.currentSkin is IValidating) {
				IValidating(this.currentSkin).validate();
			}
			var _local1:Number = this._explicitMinWidth;
			if(_local4) {
				if(_local8 !== null) {
					_local1 = _local8.minWidth;
				} else if(this.currentSkin !== null) {
					_local1 = this._explicitSkinMinWidth;
				} else {
					_local1 = 0;
				}
			}
			var _local6:Number = this._explicitMinHeight;
			if(_local9) {
				if(_local8 !== null) {
					_local6 = _local8.minHeight;
				} else if(this.currentSkin !== null) {
					_local6 = this._explicitSkinMinHeight;
				} else {
					_local6 = 0;
				}
			}
			var _local2:Number = this._explicitWidth;
			if(_local3) {
				if(this.currentSkin !== null) {
					_local2 = this.currentSkin.width;
				} else {
					_local2 = 0;
				}
			}
			var _local5:Number = this._explicitHeight;
			if(_local7) {
				if(this.currentSkin !== null) {
					_local5 = this.currentSkin.height;
				} else {
					_local5 = 0;
				}
			}
			return this.saveMeasurements(_local2,_local5,_local1,_local6);
		}
		
		protected function refreshSkin() : void {
			var _local2:IMeasureDisplayObject = null;
			var _local1:DisplayObject = this.currentSkin;
			this.currentSkin = this.getCurrentSkin();
			switch(_local1) {
				default:
					if(this.currentSkin is IFeathersControl) {
						IFeathersControl(this.currentSkin).initializeNow();
					}
					if(this.currentSkin is IMeasureDisplayObject) {
						_local2 = IMeasureDisplayObject(this.currentSkin);
						this._explicitSkinWidth = _local2.explicitWidth;
						this._explicitSkinHeight = _local2.explicitHeight;
						this._explicitSkinMinWidth = _local2.explicitMinWidth;
						this._explicitSkinMinHeight = _local2.explicitMinHeight;
						this._explicitSkinMaxWidth = _local2.explicitMaxWidth;
						this._explicitSkinMaxHeight = _local2.explicitMaxHeight;
					} else {
						this._explicitSkinWidth = this.currentSkin.width;
						this._explicitSkinHeight = this.currentSkin.height;
						this._explicitSkinMinWidth = this._explicitSkinWidth;
						this._explicitSkinMinHeight = this._explicitSkinHeight;
						this._explicitSkinMaxWidth = this._explicitSkinWidth;
						this._explicitSkinMaxHeight = this._explicitSkinHeight;
					}
					if(this.currentSkin is IStateObserver) {
						IStateObserver(this.currentSkin).stateContext = this;
					}
					this.addChildAt(this.currentSkin,0);
					break;
				case this.currentSkin:
				case this.currentSkin:
			}
		}
		
		protected function getCurrentSkin() : DisplayObject {
			var _local1:DisplayObject = this._stateToSkin[this._currentState] as DisplayObject;
			if(_local1 !== null) {
				return _local1;
			}
			return this._defaultSkin;
		}
		
		protected function scaleSkin() : void {
			if(!this.currentSkin) {
				return;
			}
			this.currentSkin.x = 0;
			this.currentSkin.y = 0;
			if(this.currentSkin.width !== this.actualWidth) {
				this.currentSkin.width = this.actualWidth;
			}
			if(this.currentSkin.height !== this.actualHeight) {
				this.currentSkin.height = this.actualHeight;
			}
			if(this.currentSkin is IValidating) {
				IValidating(this.currentSkin).validate();
			}
		}
		
		protected function removeCurrentSkin(skin:DisplayObject) : void {
			if(skin === null) {
				return;
			}
			if(skin is IStateObserver) {
				IStateObserver(skin).stateContext = null;
			}
			if(skin.parent === this) {
				this.removeChild(skin,false);
			}
		}
		
		protected function refreshTriggeredEvents() : void {
			this.tapToTrigger.isEnabled = this._isEnabled;
		}
		
		protected function changeState(state:String) : void {
			if(this._currentState === state) {
				return;
			}
			this._currentState = state;
			this.invalidate("state");
			this.dispatchEventWith("stageChange");
		}
		
		protected function resetTouchState(touch:Touch = null) : void {
			this.touchPointID = -1;
			if(this._isEnabled) {
				this.changeState("up");
			} else {
				this.changeState("disabled");
			}
		}
		
		protected function basicButton_removedFromStageHandler(event:Event) : void {
			this.resetTouchState();
		}
		
		protected function basicButton_touchHandler(event:TouchEvent) : void {
			var _local3:Touch = null;
			var _local2:Boolean = false;
			if(!this._isEnabled) {
				this.touchPointID = -1;
				return;
			}
			if(this.touchPointID >= 0) {
				_local3 = event.getTouch(this,null,this.touchPointID);
				if(!_local3) {
					return;
				}
				_local3.getLocation(this.stage,HELPER_POINT);
				_local2 = this.contains(this.stage.hitTest(HELPER_POINT));
				if(_local3.phase === "moved") {
					if(_local2 || this._keepDownStateOnRollOut) {
						this.changeState("down");
					} else {
						this.changeState("up");
					}
				} else if(_local3.phase === "ended") {
					this.resetTouchState(_local3);
				}
				return;
			}
			_local3 = event.getTouch(this,"began");
			if(_local3) {
				this.changeState("down");
				this.touchPointID = _local3.id;
				return;
			}
			_local3 = event.getTouch(this,"hover");
			if(_local3) {
				this.changeState("hover");
				return;
			}
			this.changeState("up");
		}
	}
}

