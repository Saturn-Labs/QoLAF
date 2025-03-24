package feathers.controls {
	import feathers.core.FeathersControl;
	import feathers.core.IFeathersControl;
	import feathers.core.IFocusDisplayObject;
	import feathers.core.IMeasureDisplayObject;
	import feathers.core.IValidating;
	import feathers.core.PropertyProxy;
	import feathers.skins.IStyleProvider;
	import feathers.utils.math.clamp;
	import feathers.utils.math.roundToNearest;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	public class SimpleScrollBar extends FeathersControl implements IDirectionalScrollBar {
		protected static const INVALIDATION_FLAG_THUMB_FACTORY:String = "thumbFactory";
		
		public static const DIRECTION_HORIZONTAL:String = "horizontal";
		
		public static const DIRECTION_VERTICAL:String = "vertical";
		
		public static const DEFAULT_CHILD_STYLE_NAME_THUMB:String = "feathers-simple-scroll-bar-thumb";
		
		public static var globalStyleProvider:IStyleProvider;
		
		private static const HELPER_POINT:Point = new Point();
		
		protected var thumbStyleName:String = "feathers-simple-scroll-bar-thumb";
		
		protected var _thumbExplicitWidth:Number;
		
		protected var _thumbExplicitHeight:Number;
		
		protected var _thumbExplicitMinWidth:Number;
		
		protected var _thumbExplicitMinHeight:Number;
		
		protected var thumb:DisplayObject;
		
		protected var track:Quad;
		
		protected var _direction:String = "horizontal";
		
		public var clampToRange:Boolean = false;
		
		protected var _value:Number = 0;
		
		protected var _minimum:Number = 0;
		
		protected var _maximum:Number = 0;
		
		protected var _step:Number = 0;
		
		protected var _page:Number = 0;
		
		protected var _paddingTop:Number = 0;
		
		protected var _paddingRight:Number = 0;
		
		protected var _paddingBottom:Number = 0;
		
		protected var _paddingLeft:Number = 0;
		
		protected var currentRepeatAction:Function;
		
		protected var _repeatTimer:Timer;
		
		protected var _repeatDelay:Number = 0.05;
		
		protected var isDragging:Boolean = false;
		
		public var liveDragging:Boolean = true;
		
		protected var _thumbFactory:Function;
		
		protected var _customThumbStyleName:String;
		
		protected var _thumbProperties:PropertyProxy;
		
		protected var _touchPointID:int = -1;
		
		protected var _touchStartX:Number = NaN;
		
		protected var _touchStartY:Number = NaN;
		
		protected var _thumbStartX:Number = NaN;
		
		protected var _thumbStartY:Number = NaN;
		
		protected var _touchValue:Number;
		
		public function SimpleScrollBar() {
			super();
			this.addEventListener("removedFromStage",removedFromStageHandler);
		}
		
		protected static function defaultThumbFactory() : BasicButton {
			return new Button();
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return SimpleScrollBar.globalStyleProvider;
		}
		
		public function get direction() : String {
			return this._direction;
		}
		
		public function set direction(value:String) : void {
			if(this._direction == value) {
				return;
			}
			this._direction = value;
			this.invalidate("data");
			this.invalidate("thumbFactory");
		}
		
		public function get value() : Number {
			return this._value;
		}
		
		public function set value(newValue:Number) : void {
			if(this.clampToRange) {
				newValue = clamp(newValue,this._minimum,this._maximum);
			}
			if(this._value == newValue) {
				return;
			}
			this._value = newValue;
			this.invalidate("data");
			if(this.liveDragging || !this.isDragging) {
				this.dispatchEventWith("change");
			}
		}
		
		public function get minimum() : Number {
			return this._minimum;
		}
		
		public function set minimum(value:Number) : void {
			if(this._minimum == value) {
				return;
			}
			this._minimum = value;
			this.invalidate("data");
		}
		
		public function get maximum() : Number {
			return this._maximum;
		}
		
		public function set maximum(value:Number) : void {
			if(this._maximum == value) {
				return;
			}
			this._maximum = value;
			this.invalidate("data");
		}
		
		public function get step() : Number {
			return this._step;
		}
		
		public function set step(value:Number) : void {
			this._step = value;
		}
		
		public function get page() : Number {
			return this._page;
		}
		
		public function set page(value:Number) : void {
			if(this._page == value) {
				return;
			}
			this._page = value;
			this.invalidate("data");
		}
		
		public function get padding() : Number {
			return this._paddingTop;
		}
		
		public function set padding(value:Number) : void {
			this.paddingTop = value;
			this.paddingRight = value;
			this.paddingBottom = value;
			this.paddingLeft = value;
		}
		
		public function get paddingTop() : Number {
			return this._paddingTop;
		}
		
		public function set paddingTop(value:Number) : void {
			if(this._paddingTop == value) {
				return;
			}
			this._paddingTop = value;
			this.invalidate("styles");
		}
		
		public function get paddingRight() : Number {
			return this._paddingRight;
		}
		
		public function set paddingRight(value:Number) : void {
			if(this._paddingRight == value) {
				return;
			}
			this._paddingRight = value;
			this.invalidate("styles");
		}
		
		public function get paddingBottom() : Number {
			return this._paddingBottom;
		}
		
		public function set paddingBottom(value:Number) : void {
			if(this._paddingBottom == value) {
				return;
			}
			this._paddingBottom = value;
			this.invalidate("styles");
		}
		
		public function get paddingLeft() : Number {
			return this._paddingLeft;
		}
		
		public function set paddingLeft(value:Number) : void {
			if(this._paddingLeft == value) {
				return;
			}
			this._paddingLeft = value;
			this.invalidate("styles");
		}
		
		public function get repeatDelay() : Number {
			return this._repeatDelay;
		}
		
		public function set repeatDelay(value:Number) : void {
			if(this._repeatDelay == value) {
				return;
			}
			this._repeatDelay = value;
			this.invalidate("styles");
		}
		
		public function get thumbFactory() : Function {
			return this._thumbFactory;
		}
		
		public function set thumbFactory(value:Function) : void {
			if(this._thumbFactory == value) {
				return;
			}
			this._thumbFactory = value;
			this.invalidate("thumbFactory");
		}
		
		public function get customThumbStyleName() : String {
			return this._customThumbStyleName;
		}
		
		public function set customThumbStyleName(value:String) : void {
			if(this._customThumbStyleName == value) {
				return;
			}
			this._customThumbStyleName = value;
			this.invalidate("thumbFactory");
		}
		
		public function get thumbProperties() : Object {
			if(!this._thumbProperties) {
				this._thumbProperties = new PropertyProxy(thumbProperties_onChange);
			}
			return this._thumbProperties;
		}
		
		public function set thumbProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._thumbProperties == value) {
				return;
			}
			if(!value) {
				value = new PropertyProxy();
			}
			if(!(value is PropertyProxy)) {
				_local2 = new PropertyProxy();
				for(var _local3 in value) {
					_local2[_local3] = value[_local3];
				}
				value = _local2;
			}
			if(this._thumbProperties) {
				this._thumbProperties.removeOnChangeCallback(thumbProperties_onChange);
			}
			this._thumbProperties = PropertyProxy(value);
			if(this._thumbProperties) {
				this._thumbProperties.addOnChangeCallback(thumbProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		override protected function initialize() : void {
			if(!this.track) {
				this.track = new Quad(10,10,0xff00ff);
				this.track.alpha = 0;
				this.track.addEventListener("touch",track_touchHandler);
				this.addChild(this.track);
			}
			if(this._value < this._minimum) {
				this.value = this._minimum;
			} else if(this._value > this._maximum) {
				this.value = this._maximum;
			}
		}
		
		override protected function draw() : void {
			var _local4:Boolean = this.isInvalid("data");
			var _local5:Boolean = this.isInvalid("styles");
			var _local1:Boolean = this.isInvalid("size");
			var _local2:Boolean = this.isInvalid("state");
			var _local3:Boolean = this.isInvalid("thumbFactory");
			if(_local3) {
				this.createThumb();
			}
			if(_local3 || _local5) {
				this.refreshThumbStyles();
			}
			if(_local4 || _local3 || _local2) {
				this.refreshEnabled();
			}
			_local1 = this.autoSizeIfNeeded() || _local1;
			this.layout();
		}
		
		protected function autoSizeIfNeeded() : Boolean {
			var _local1:IMeasureDisplayObject = null;
			var _local5:* = this._explicitWidth !== this._explicitWidth;
			var _local9:* = this._explicitHeight !== this._explicitHeight;
			var _local6:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local11:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local5 && !_local9 && !_local6 && !_local11) {
				return false;
			}
			this.thumb.width = this._thumbExplicitWidth;
			this.thumb.height = this._thumbExplicitHeight;
			if(this.thumb is IMeasureDisplayObject) {
				_local1 = IMeasureDisplayObject(this.thumb);
				_local1.minWidth = this._thumbExplicitMinWidth;
				_local1.minHeight = this._thumbExplicitMinHeight;
			}
			if(this.thumb is IValidating) {
				IValidating(this.thumb).validate();
			}
			var _local10:Number = this._maximum - this._minimum;
			var _local2:* = this._page;
			if(_local2 === 0) {
				_local2 = this._step;
			}
			if(_local2 > _local10) {
				_local2 = _local10;
			}
			var _local4:Number = this._explicitWidth;
			var _local7:Number = this._explicitHeight;
			var _local3:Number = this._explicitMinWidth;
			var _local8:Number = this._explicitMinHeight;
			if(_local5) {
				_local4 = this.thumb.width;
				if(this._direction !== "vertical" && _local2 !== 0) {
					_local4 *= _local10 / _local2;
				}
				_local4 += this._paddingLeft + this._paddingRight;
			}
			if(_local9) {
				_local7 = this.thumb.height;
				if(this._direction === "vertical" && _local2 !== 0) {
					_local7 *= _local10 / _local2;
				}
				_local7 += this._paddingTop + this._paddingBottom;
			}
			if(_local6) {
				if(_local1 !== null) {
					_local3 = _local1.minWidth;
				} else {
					_local3 = this.thumb.width;
				}
				if(this._direction !== "vertical" && _local2 !== 0) {
					_local3 *= _local10 / _local2;
				}
				_local3 += this._paddingLeft + this._paddingRight;
			}
			if(_local11) {
				if(_local1 !== null) {
					_local8 = _local1.minHeight;
				} else {
					_local8 = this.thumb.height;
				}
				if(this._direction === "vertical" && _local2 !== 0) {
					_local8 *= _local10 / _local2;
				}
				_local8 += this._paddingTop + this._paddingBottom;
			}
			return this.saveMeasurements(_local4,_local7,_local3,_local8);
		}
		
		protected function createThumb() : void {
			var _local2:IMeasureDisplayObject = null;
			if(this.thumb) {
				this.thumb.removeFromParent(true);
				this.thumb = null;
			}
			var _local1:Function = this._thumbFactory != null ? this._thumbFactory : defaultThumbFactory;
			var _local4:String = this._customThumbStyleName != null ? this._customThumbStyleName : this.thumbStyleName;
			var _local3:BasicButton = BasicButton(_local1());
			_local3.styleNameList.add(_local4);
			if(_local3 is IFocusDisplayObject) {
				_local3.isFocusEnabled = false;
			}
			_local3.keepDownStateOnRollOut = true;
			_local3.addEventListener("touch",thumb_touchHandler);
			this.addChild(_local3);
			this.thumb = _local3;
			if(this.thumb is IFeathersControl) {
				IFeathersControl(this.thumb).initializeNow();
			}
			if(this.thumb is IMeasureDisplayObject) {
				_local2 = IMeasureDisplayObject(this.thumb);
				this._thumbExplicitWidth = _local2.explicitWidth;
				this._thumbExplicitHeight = _local2.explicitHeight;
				this._thumbExplicitMinWidth = _local2.explicitMinWidth;
				this._thumbExplicitMinHeight = _local2.explicitMinHeight;
			} else {
				this._thumbExplicitWidth = this.thumb.width;
				this._thumbExplicitHeight = this.thumb.height;
				this._thumbExplicitMinWidth = this._thumbExplicitWidth;
				this._thumbExplicitMinHeight = this._thumbExplicitHeight;
			}
		}
		
		protected function refreshThumbStyles() : void {
			var _local2:Object = null;
			for(var _local1 in this._thumbProperties) {
				_local2 = this._thumbProperties[_local1];
				this.thumb[_local1] = _local2;
			}
		}
		
		protected function refreshEnabled() : void {
			if(this.thumb is IFeathersControl) {
				IFeathersControl(this.thumb).isEnabled = this._isEnabled && this._maximum > this._minimum;
			}
		}
		
		protected function layout() : void {
			var _local1:Number = NaN;
			var _local2:* = NaN;
			var _local8:* = NaN;
			var _local9:Number = NaN;
			var _local4:* = NaN;
			var _local6:Number = NaN;
			var _local7:* = NaN;
			var _local12:* = NaN;
			var _local10:Number = NaN;
			var _local3:* = NaN;
			this.track.width = this.actualWidth;
			this.track.height = this.actualHeight;
			var _local5:Number = this._maximum - this._minimum;
			this.thumb.visible = _local5 > 0;
			if(!this.thumb.visible) {
				return;
			}
			if(this.thumb is IValidating) {
				IValidating(this.thumb).validate();
			}
			var _local14:Number = this.actualWidth - this._paddingLeft - this._paddingRight;
			var _local11:Number = this.actualHeight - this._paddingTop - this._paddingBottom;
			var _local13:* = this._page;
			if(this._page == 0) {
				_local13 = this._step;
			} else if(_local13 > _local5) {
				_local13 = _local5;
			}
			var _local15:Number = 0;
			if(this._value < this._minimum) {
				_local15 = this._minimum - this._value;
			}
			if(this._value > this._maximum) {
				_local15 = this._value - this._maximum;
			}
			if(this._direction == "vertical") {
				this.thumb.width = _local14;
				_local1 = this._thumbExplicitMinHeight;
				if(this.thumb is IMeasureDisplayObject) {
					_local1 = Number(IMeasureDisplayObject(this.thumb).minHeight);
				}
				_local2 = _local11 * _local13 / _local5;
				_local8 = _local11 - _local2;
				if(_local8 > _local2) {
					_local8 = _local2;
				}
				_local8 *= _local15 / (_local5 * _local2 / _local11);
				_local2 -= _local8;
				if(_local2 < _local1) {
					_local2 = _local1;
				}
				this.thumb.height = _local2;
				this.thumb.x = this._paddingLeft + (this.actualWidth - this._paddingLeft - this._paddingRight - this.thumb.width) / 2;
				_local9 = _local11 - this.thumb.height;
				_local4 = _local9 * (this._value - this._minimum) / _local5;
				if(_local4 > _local9) {
					_local4 = _local9;
				} else if(_local4 < 0) {
					_local4 = 0;
				}
				this.thumb.y = this._paddingTop + _local4;
			} else {
				_local6 = this._thumbExplicitMinWidth;
				if(this.thumb is IMeasureDisplayObject) {
					_local6 = Number(IMeasureDisplayObject(this.thumb).minWidth);
				}
				_local7 = _local14 * _local13 / _local5;
				_local12 = _local14 - _local7;
				if(_local12 > _local7) {
					_local12 = _local7;
				}
				_local12 *= _local15 / (_local5 * _local7 / _local14);
				_local7 -= _local12;
				if(_local7 < _local6) {
					_local7 = _local6;
				}
				this.thumb.width = _local7;
				this.thumb.height = _local11;
				_local10 = _local14 - this.thumb.width;
				_local3 = _local10 * (this._value - this._minimum) / _local5;
				if(_local3 > _local10) {
					_local3 = _local10;
				} else if(_local3 < 0) {
					_local3 = 0;
				}
				this.thumb.x = this._paddingLeft + _local3;
				this.thumb.y = this._paddingTop + (this.actualHeight - this._paddingTop - this._paddingBottom - this.thumb.height) / 2;
			}
			if(this.thumb is IValidating) {
				IValidating(this.thumb).validate();
			}
		}
		
		protected function locationToValue(location:Point) : Number {
			var _local7:Number = NaN;
			var _local3:Number = NaN;
			var _local6:Number = NaN;
			var _local8:Number = NaN;
			var _local4:Number = NaN;
			var _local2:Number = NaN;
			var _local5:Number = 0;
			if(this._direction == "vertical") {
				_local7 = this.actualHeight - this.thumb.height - this._paddingTop - this._paddingBottom;
				if(_local7 > 0) {
					_local3 = location.y - this._touchStartY - this._paddingTop;
					_local6 = Math.min(Math.max(0,this._thumbStartY + _local3),_local7);
					_local5 = _local6 / _local7;
				}
			} else {
				_local8 = this.actualWidth - this.thumb.width - this._paddingLeft - this._paddingRight;
				if(_local8 > 0) {
					_local4 = location.x - this._touchStartX - this._paddingLeft;
					_local2 = Math.min(Math.max(0,this._thumbStartX + _local4),_local8);
					_local5 = _local2 / _local8;
				}
			}
			return this._minimum + _local5 * (this._maximum - this._minimum);
		}
		
		protected function adjustPage() : void {
			var _local1:Number = NaN;
			var _local3:Number = this._maximum - this._minimum;
			var _local2:* = this._page;
			if(_local2 === 0) {
				_local2 = this._step;
			}
			if(_local2 > _local3) {
				_local2 = _local3;
			}
			if(this._touchValue < this._value) {
				_local1 = Math.max(this._touchValue,this._value - _local2);
				if(this._step != 0 && _local1 != this._maximum && _local1 != this._minimum) {
					_local1 = roundToNearest(_local1,this._step);
				}
				this.value = _local1;
			} else if(this._touchValue > this._value) {
				_local1 = Math.min(this._touchValue,this._value + _local2);
				if(this._step != 0 && _local1 != this._maximum && _local1 != this._minimum) {
					_local1 = roundToNearest(_local1,this._step);
				}
				this.value = _local1;
			}
		}
		
		protected function startRepeatTimer(action:Function) : void {
			this.currentRepeatAction = action;
			if(this._repeatDelay > 0) {
				if(!this._repeatTimer) {
					this._repeatTimer = new Timer(this._repeatDelay * 1000);
					this._repeatTimer.addEventListener("timer",repeatTimer_timerHandler);
				} else {
					this._repeatTimer.reset();
					this._repeatTimer.delay = this._repeatDelay * 1000;
				}
				this._repeatTimer.start();
			}
		}
		
		protected function thumbProperties_onChange(proxy:PropertyProxy, name:Object) : void {
			this.invalidate("styles");
		}
		
		protected function removedFromStageHandler(event:Event) : void {
			this._touchPointID = -1;
			if(this._repeatTimer) {
				this._repeatTimer.stop();
			}
		}
		
		protected function track_touchHandler(event:TouchEvent) : void {
			var _local2:Touch = null;
			if(!this._isEnabled) {
				this._touchPointID = -1;
				return;
			}
			if(this._touchPointID >= 0) {
				_local2 = event.getTouch(this.track,"ended",this._touchPointID);
				if(!_local2) {
					return;
				}
				this._touchPointID = -1;
				this._repeatTimer.stop();
			} else {
				_local2 = event.getTouch(this.track,"began");
				if(!_local2) {
					return;
				}
				this._touchPointID = _local2.id;
				_local2.getLocation(this,HELPER_POINT);
				this._touchStartX = HELPER_POINT.x;
				this._touchStartY = HELPER_POINT.y;
				this._thumbStartX = HELPER_POINT.x;
				this._thumbStartY = HELPER_POINT.y;
				this._touchValue = this.locationToValue(HELPER_POINT);
				this.adjustPage();
				this.startRepeatTimer(this.adjustPage);
			}
		}
		
		protected function thumb_touchHandler(event:TouchEvent) : void {
			var _local3:Touch = null;
			var _local2:Number = NaN;
			if(!this._isEnabled) {
				return;
			}
			if(this._touchPointID >= 0) {
				_local3 = event.getTouch(this.thumb,null,this._touchPointID);
				if(!_local3) {
					return;
				}
				if(_local3.phase == "moved") {
					_local3.getLocation(this,HELPER_POINT);
					_local2 = this.locationToValue(HELPER_POINT);
					if(this._step != 0 && _local2 != this._maximum && _local2 != this._minimum) {
						_local2 = roundToNearest(_local2,this._step);
					}
					this.value = _local2;
				} else if(_local3.phase == "ended") {
					this._touchPointID = -1;
					this.isDragging = false;
					if(!this.liveDragging) {
						this.dispatchEventWith("change");
					}
					this.dispatchEventWith("endInteraction");
				}
			} else {
				_local3 = event.getTouch(this.thumb,"began");
				if(!_local3) {
					return;
				}
				_local3.getLocation(this,HELPER_POINT);
				this._touchPointID = _local3.id;
				this._thumbStartX = this.thumb.x;
				this._thumbStartY = this.thumb.y;
				this._touchStartX = HELPER_POINT.x;
				this._touchStartY = HELPER_POINT.y;
				this.isDragging = true;
				this.dispatchEventWith("beginInteraction");
			}
		}
		
		protected function repeatTimer_timerHandler(event:TimerEvent) : void {
			if(this._repeatTimer.currentCount < 5) {
				return;
			}
			this.currentRepeatAction();
		}
	}
}

