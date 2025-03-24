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
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	public class ScrollBar extends FeathersControl implements IDirectionalScrollBar {
		protected static const INVALIDATION_FLAG_THUMB_FACTORY:String = "thumbFactory";
		
		protected static const INVALIDATION_FLAG_MINIMUM_TRACK_FACTORY:String = "minimumTrackFactory";
		
		protected static const INVALIDATION_FLAG_MAXIMUM_TRACK_FACTORY:String = "maximumTrackFactory";
		
		protected static const INVALIDATION_FLAG_DECREMENT_BUTTON_FACTORY:String = "decrementButtonFactory";
		
		protected static const INVALIDATION_FLAG_INCREMENT_BUTTON_FACTORY:String = "incrementButtonFactory";
		
		public static const DIRECTION_HORIZONTAL:String = "horizontal";
		
		public static const DIRECTION_VERTICAL:String = "vertical";
		
		public static const TRACK_LAYOUT_MODE_SINGLE:String = "single";
		
		public static const TRACK_LAYOUT_MODE_MIN_MAX:String = "minMax";
		
		public static const DEFAULT_CHILD_STYLE_NAME_MINIMUM_TRACK:String = "feathers-scroll-bar-minimum-track";
		
		public static const DEFAULT_CHILD_STYLE_NAME_MAXIMUM_TRACK:String = "feathers-scroll-bar-maximum-track";
		
		public static const DEFAULT_CHILD_STYLE_NAME_THUMB:String = "feathers-scroll-bar-thumb";
		
		public static const DEFAULT_CHILD_STYLE_NAME_DECREMENT_BUTTON:String = "feathers-scroll-bar-decrement-button";
		
		public static const DEFAULT_CHILD_STYLE_NAME_INCREMENT_BUTTON:String = "feathers-scroll-bar-increment-button";
		
		public static var globalStyleProvider:IStyleProvider;
		
		private static const HELPER_POINT:Point = new Point();
		
		protected var minimumTrackStyleName:String = "feathers-scroll-bar-minimum-track";
		
		protected var maximumTrackStyleName:String = "feathers-scroll-bar-maximum-track";
		
		protected var thumbStyleName:String = "feathers-scroll-bar-thumb";
		
		protected var decrementButtonStyleName:String = "feathers-scroll-bar-decrement-button";
		
		protected var incrementButtonStyleName:String = "feathers-scroll-bar-increment-button";
		
		protected var thumbOriginalWidth:Number = NaN;
		
		protected var thumbOriginalHeight:Number = NaN;
		
		protected var minimumTrackOriginalWidth:Number = NaN;
		
		protected var minimumTrackOriginalHeight:Number = NaN;
		
		protected var maximumTrackOriginalWidth:Number = NaN;
		
		protected var maximumTrackOriginalHeight:Number = NaN;
		
		protected var decrementButton:BasicButton;
		
		protected var incrementButton:BasicButton;
		
		protected var thumb:DisplayObject;
		
		protected var minimumTrack:DisplayObject;
		
		protected var maximumTrack:DisplayObject;
		
		protected var _minimumTrackSkinExplicitWidth:Number;
		
		protected var _minimumTrackSkinExplicitHeight:Number;
		
		protected var _minimumTrackSkinExplicitMinWidth:Number;
		
		protected var _minimumTrackSkinExplicitMinHeight:Number;
		
		protected var _maximumTrackSkinExplicitWidth:Number;
		
		protected var _maximumTrackSkinExplicitHeight:Number;
		
		protected var _maximumTrackSkinExplicitMinWidth:Number;
		
		protected var _maximumTrackSkinExplicitMinHeight:Number;
		
		protected var _direction:String = "horizontal";
		
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
		
		protected var _trackLayoutMode:String = "single";
		
		protected var _minimumTrackFactory:Function;
		
		protected var _customMinimumTrackStyleName:String;
		
		protected var _minimumTrackProperties:PropertyProxy;
		
		protected var _maximumTrackFactory:Function;
		
		protected var _customMaximumTrackStyleName:String;
		
		protected var _maximumTrackProperties:PropertyProxy;
		
		protected var _thumbFactory:Function;
		
		protected var _customThumbStyleName:String;
		
		protected var _thumbProperties:PropertyProxy;
		
		protected var _decrementButtonFactory:Function;
		
		protected var _customDecrementButtonStyleName:String;
		
		protected var _decrementButtonProperties:PropertyProxy;
		
		protected var _incrementButtonFactory:Function;
		
		protected var _customIncrementButtonStyleName:String;
		
		protected var _incrementButtonProperties:PropertyProxy;
		
		protected var _touchPointID:int = -1;
		
		protected var _touchStartX:Number = NaN;
		
		protected var _touchStartY:Number = NaN;
		
		protected var _thumbStartX:Number = NaN;
		
		protected var _thumbStartY:Number = NaN;
		
		protected var _touchValue:Number;
		
		public function ScrollBar() {
			super();
			this.addEventListener("removedFromStage",removedFromStageHandler);
		}
		
		protected static function defaultThumbFactory() : BasicButton {
			return new Button();
		}
		
		protected static function defaultMinimumTrackFactory() : BasicButton {
			return new Button();
		}
		
		protected static function defaultMaximumTrackFactory() : BasicButton {
			return new Button();
		}
		
		protected static function defaultDecrementButtonFactory() : BasicButton {
			return new Button();
		}
		
		protected static function defaultIncrementButtonFactory() : BasicButton {
			return new Button();
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return ScrollBar.globalStyleProvider;
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
			this.invalidate("decrementButtonFactory");
			this.invalidate("incrementButtonFactory");
			this.invalidate("minimumTrackFactory");
			this.invalidate("maximumTrackFactory");
			this.invalidate("thumbFactory");
		}
		
		public function get value() : Number {
			return this._value;
		}
		
		public function set value(newValue:Number) : void {
			newValue = clamp(newValue,this._minimum,this._maximum);
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
		
		public function get trackLayoutMode() : String {
			return this._trackLayoutMode;
		}
		
		public function set trackLayoutMode(value:String) : void {
			if(value === "minMax") {
				value = "split";
			}
			if(this._trackLayoutMode == value) {
				return;
			}
			this._trackLayoutMode = value;
			this.invalidate("layout");
		}
		
		public function get minimumTrackFactory() : Function {
			return this._minimumTrackFactory;
		}
		
		public function set minimumTrackFactory(value:Function) : void {
			if(this._minimumTrackFactory == value) {
				return;
			}
			this._minimumTrackFactory = value;
			this.invalidate("minimumTrackFactory");
		}
		
		public function get customMinimumTrackStyleName() : String {
			return this._customMinimumTrackStyleName;
		}
		
		public function set customMinimumTrackStyleName(value:String) : void {
			if(this._customMinimumTrackStyleName == value) {
				return;
			}
			this._customMinimumTrackStyleName = value;
			this.invalidate("minimumTrackFactory");
		}
		
		public function get minimumTrackProperties() : Object {
			if(!this._minimumTrackProperties) {
				this._minimumTrackProperties = new PropertyProxy(minimumTrackProperties_onChange);
			}
			return this._minimumTrackProperties;
		}
		
		public function set minimumTrackProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._minimumTrackProperties == value) {
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
			if(this._minimumTrackProperties) {
				this._minimumTrackProperties.removeOnChangeCallback(minimumTrackProperties_onChange);
			}
			this._minimumTrackProperties = PropertyProxy(value);
			if(this._minimumTrackProperties) {
				this._minimumTrackProperties.addOnChangeCallback(minimumTrackProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get maximumTrackFactory() : Function {
			return this._maximumTrackFactory;
		}
		
		public function set maximumTrackFactory(value:Function) : void {
			if(this._maximumTrackFactory == value) {
				return;
			}
			this._maximumTrackFactory = value;
			this.invalidate("maximumTrackFactory");
		}
		
		public function get customMaximumTrackStyleName() : String {
			return this._customMaximumTrackStyleName;
		}
		
		public function set customMaximumTrackStyleName(value:String) : void {
			if(this._customMaximumTrackStyleName == value) {
				return;
			}
			this._customMaximumTrackStyleName = value;
			this.invalidate("maximumTrackFactory");
		}
		
		public function get maximumTrackProperties() : Object {
			if(!this._maximumTrackProperties) {
				this._maximumTrackProperties = new PropertyProxy(maximumTrackProperties_onChange);
			}
			return this._maximumTrackProperties;
		}
		
		public function set maximumTrackProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._maximumTrackProperties == value) {
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
			if(this._maximumTrackProperties) {
				this._maximumTrackProperties.removeOnChangeCallback(maximumTrackProperties_onChange);
			}
			this._maximumTrackProperties = PropertyProxy(value);
			if(this._maximumTrackProperties) {
				this._maximumTrackProperties.addOnChangeCallback(maximumTrackProperties_onChange);
			}
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
		
		public function get decrementButtonFactory() : Function {
			return this._decrementButtonFactory;
		}
		
		public function set decrementButtonFactory(value:Function) : void {
			if(this._decrementButtonFactory == value) {
				return;
			}
			this._decrementButtonFactory = value;
			this.invalidate("decrementButtonFactory");
		}
		
		public function get customDecrementButtonStyleName() : String {
			return this._customDecrementButtonStyleName;
		}
		
		public function set customDecrementButtonStyleName(value:String) : void {
			if(this._customDecrementButtonStyleName == value) {
				return;
			}
			this._customDecrementButtonStyleName = value;
			this.invalidate("decrementButtonFactory");
		}
		
		public function get decrementButtonProperties() : Object {
			if(!this._decrementButtonProperties) {
				this._decrementButtonProperties = new PropertyProxy(decrementButtonProperties_onChange);
			}
			return this._decrementButtonProperties;
		}
		
		public function set decrementButtonProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._decrementButtonProperties == value) {
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
			if(this._decrementButtonProperties) {
				this._decrementButtonProperties.removeOnChangeCallback(decrementButtonProperties_onChange);
			}
			this._decrementButtonProperties = PropertyProxy(value);
			if(this._decrementButtonProperties) {
				this._decrementButtonProperties.addOnChangeCallback(decrementButtonProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get incrementButtonFactory() : Function {
			return this._incrementButtonFactory;
		}
		
		public function set incrementButtonFactory(value:Function) : void {
			if(this._incrementButtonFactory == value) {
				return;
			}
			this._incrementButtonFactory = value;
			this.invalidate("incrementButtonFactory");
		}
		
		public function get customIncrementButtonStyleName() : String {
			return this._customIncrementButtonStyleName;
		}
		
		public function set customIncrementButtonStyleName(value:String) : void {
			if(this._customIncrementButtonStyleName == value) {
				return;
			}
			this._customIncrementButtonStyleName = value;
			this.invalidate("incrementButtonFactory");
		}
		
		public function get incrementButtonProperties() : Object {
			if(!this._incrementButtonProperties) {
				this._incrementButtonProperties = new PropertyProxy(incrementButtonProperties_onChange);
			}
			return this._incrementButtonProperties;
		}
		
		public function set incrementButtonProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._incrementButtonProperties == value) {
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
			if(this._incrementButtonProperties) {
				this._incrementButtonProperties.removeOnChangeCallback(incrementButtonProperties_onChange);
			}
			this._incrementButtonProperties = PropertyProxy(value);
			if(this._incrementButtonProperties) {
				this._incrementButtonProperties.addOnChangeCallback(incrementButtonProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		override protected function initialize() : void {
			if(this._value < this._minimum) {
				this.value = this._minimum;
			} else if(this._value > this._maximum) {
				this.value = this._maximum;
			}
		}
		
		override protected function draw() : void {
			var _local9:Boolean = this.isInvalid("data");
			var _local10:Boolean = this.isInvalid("styles");
			var _local2:Boolean = this.isInvalid("size");
			var _local5:Boolean = this.isInvalid("state");
			var _local4:Boolean = this.isInvalid("layout");
			var _local8:Boolean = this.isInvalid("thumbFactory");
			var _local6:Boolean = this.isInvalid("minimumTrackFactory");
			var _local3:Boolean = this.isInvalid("maximumTrackFactory");
			var _local1:Boolean = this.isInvalid("incrementButtonFactory");
			var _local7:Boolean = this.isInvalid("decrementButtonFactory");
			if(_local8) {
				this.createThumb();
			}
			if(_local6) {
				this.createMinimumTrack();
			}
			if(_local3 || _local4) {
				this.createMaximumTrack();
			}
			if(_local7) {
				this.createDecrementButton();
			}
			if(_local1) {
				this.createIncrementButton();
			}
			if(_local8 || _local10) {
				this.refreshThumbStyles();
			}
			if(_local6 || _local10) {
				this.refreshMinimumTrackStyles();
			}
			if((_local3 || _local10 || _local4) && this.maximumTrack) {
				this.refreshMaximumTrackStyles();
			}
			if(_local7 || _local10) {
				this.refreshDecrementButtonStyles();
			}
			if(_local1 || _local10) {
				this.refreshIncrementButtonStyles();
			}
			if(_local9 || _local5 || _local8 || _local6 || _local3 || _local7 || _local1) {
				this.refreshEnabled();
			}
			_local2 = this.autoSizeIfNeeded() || _local2;
			this.layout();
		}
		
		protected function autoSizeIfNeeded() : Boolean {
			if(this._direction === "vertical") {
				return this.measureVertical();
			}
			return this.measureHorizontal();
		}
		
		protected function measureHorizontal() : Boolean {
			var _local14:IMeasureDisplayObject = null;
			var _local6:Number = NaN;
			var _local7:IMeasureDisplayObject = null;
			var _local8:IMeasureDisplayObject = null;
			var _local5:IMeasureDisplayObject = null;
			var _local1:IMeasureDisplayObject = null;
			var _local3:* = this._explicitWidth !== this._explicitWidth;
			var _local13:* = this._explicitHeight !== this._explicitHeight;
			var _local10:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local15:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local3 && !_local13 && !_local10 && !_local15) {
				return false;
			}
			var _local11:* = this._trackLayoutMode === "single";
			if(_local3) {
				this.minimumTrack.width = this._minimumTrackSkinExplicitWidth;
			} else if(_local11) {
				this.minimumTrack.width = this._explicitWidth;
			}
			if(this.minimumTrack is IMeasureDisplayObject) {
				_local14 = IMeasureDisplayObject(this.minimumTrack);
				if(_local10) {
					_local14.minWidth = this._minimumTrackSkinExplicitMinWidth;
				} else if(_local11) {
					_local6 = this._explicitMinWidth;
					if(this._minimumTrackSkinExplicitMinWidth > _local6) {
						_local6 = this._minimumTrackSkinExplicitMinWidth;
					}
					_local14.minWidth = _local6;
				}
			}
			if(!_local11) {
				if(_local3) {
					this.maximumTrack.width = this._maximumTrackSkinExplicitWidth;
				}
				if(this.maximumTrack is IMeasureDisplayObject) {
					_local7 = IMeasureDisplayObject(this.maximumTrack);
					if(_local10) {
						_local7.minWidth = this._maximumTrackSkinExplicitMinWidth;
					}
				}
			}
			if(this.minimumTrack is IValidating) {
				IValidating(this.minimumTrack).validate();
			}
			if(this.maximumTrack is IValidating) {
				IValidating(this.maximumTrack).validate();
			}
			if(this.thumb is IValidating) {
				IValidating(this.thumb).validate();
			}
			if(this.decrementButton is IValidating) {
				IValidating(this.decrementButton).validate();
			}
			if(this.incrementButton is IValidating) {
				IValidating(this.incrementButton).validate();
			}
			var _local2:Number = this._explicitWidth;
			var _local4:Number = this._explicitHeight;
			var _local9:Number = this._explicitMinWidth;
			var _local12:Number = this._explicitMinHeight;
			if(_local3) {
				_local2 = this.minimumTrack.width;
				if(!_local11) {
					_local2 += this.maximumTrack.width;
				}
				_local2 += this.decrementButton.width + this.incrementButton.width;
			}
			if(_local13) {
				_local4 = this.minimumTrack.height;
				if(!_local11 && this.maximumTrack.height > _local4) {
					_local4 = this.maximumTrack.height;
				}
				if(this.thumb.height > _local4) {
					_local4 = this.thumb.height;
				}
				if(this.decrementButton.height > _local4) {
					_local4 = this.decrementButton.height;
				}
				if(this.incrementButton.height > _local4) {
					_local4 = this.incrementButton.height;
				}
			}
			if(_local10) {
				if(_local14 !== null) {
					_local9 = _local14.minWidth;
				} else {
					_local9 = this.minimumTrack.width;
				}
				if(!_local11) {
					if(_local7 !== null) {
						_local9 += _local7.minWidth;
					} else if(this.maximumTrack.width > _local9) {
						_local9 += this.maximumTrack.width;
					}
				}
				if(this.decrementButton is IMeasureDisplayObject) {
					_local9 += IMeasureDisplayObject(this.decrementButton).minWidth;
				} else {
					_local9 += this.decrementButton.width;
				}
				if(this.incrementButton is IMeasureDisplayObject) {
					_local9 += IMeasureDisplayObject(this.incrementButton).minWidth;
				} else {
					_local9 += this.incrementButton.width;
				}
			}
			if(_local15) {
				if(_local14 !== null) {
					_local12 = _local14.minHeight;
				} else {
					_local12 = this.minimumTrack.height;
				}
				if(!_local11) {
					if(_local7 !== null) {
						if(_local7.minHeight > _local12) {
							_local12 = _local7.minHeight;
						}
					} else if(this.maximumTrack.height > _local12) {
						_local12 = this.maximumTrack.height;
					}
				}
				if(this.thumb is IMeasureDisplayObject) {
					_local8 = IMeasureDisplayObject(this.thumb);
					if(_local8.minHeight > _local12) {
						_local12 = _local8.minHeight;
					}
				} else if(this.thumb.height > _local12) {
					_local12 = this.thumb.height;
				}
				if(this.decrementButton is IMeasureDisplayObject) {
					_local5 = IMeasureDisplayObject(this.decrementButton);
					if(_local5.minHeight > _local12) {
						_local12 = _local5.minHeight;
					}
				} else if(this.decrementButton.height > _local12) {
					_local12 = this.decrementButton.height;
				}
				if(this.incrementButton is IMeasureDisplayObject) {
					_local1 = IMeasureDisplayObject(this.incrementButton);
					if(_local1.minHeight > _local12) {
						_local12 = _local1.minHeight;
					}
				} else if(this.incrementButton.height > _local12) {
					_local12 = this.incrementButton.height;
				}
			}
			return this.saveMeasurements(_local2,_local4,_local9,_local12);
		}
		
		protected function measureVertical() : Boolean {
			var _local13:IMeasureDisplayObject = null;
			var _local14:Number = NaN;
			var _local6:IMeasureDisplayObject = null;
			var _local7:IMeasureDisplayObject = null;
			var _local5:IMeasureDisplayObject = null;
			var _local1:IMeasureDisplayObject = null;
			var _local3:* = this._explicitWidth !== this._explicitWidth;
			var _local12:* = this._explicitHeight !== this._explicitHeight;
			var _local9:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local15:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local3 && !_local12 && !_local9 && !_local15) {
				return false;
			}
			var _local10:* = this._trackLayoutMode === "single";
			if(_local12) {
				this.minimumTrack.height = this._minimumTrackSkinExplicitHeight;
			} else if(_local10) {
				this.minimumTrack.height = this._explicitHeight;
			}
			if(this.minimumTrack is IMeasureDisplayObject) {
				_local13 = IMeasureDisplayObject(this.minimumTrack);
				if(_local15) {
					_local13.minHeight = this._minimumTrackSkinExplicitMinHeight;
				} else if(_local10) {
					_local14 = this._explicitMinHeight;
					if(this._minimumTrackSkinExplicitMinHeight > _local14) {
						_local14 = this._minimumTrackSkinExplicitMinHeight;
					}
					_local13.minHeight = _local14;
				}
			}
			if(!_local10) {
				if(_local12) {
					this.maximumTrack.height = this._maximumTrackSkinExplicitHeight;
				}
				if(this.maximumTrack is IMeasureDisplayObject) {
					_local6 = IMeasureDisplayObject(this.maximumTrack);
					if(_local15) {
						_local6.minHeight = this._maximumTrackSkinExplicitMinHeight;
					}
				}
			}
			if(this.minimumTrack is IValidating) {
				IValidating(this.minimumTrack).validate();
			}
			if(this.maximumTrack is IValidating) {
				IValidating(this.maximumTrack).validate();
			}
			if(this.thumb is IValidating) {
				IValidating(this.thumb).validate();
			}
			if(this.decrementButton is IValidating) {
				IValidating(this.decrementButton).validate();
			}
			if(this.incrementButton is IValidating) {
				IValidating(this.incrementButton).validate();
			}
			var _local2:Number = this._explicitWidth;
			var _local4:Number = this._explicitHeight;
			var _local8:Number = this._explicitMinWidth;
			var _local11:Number = this._explicitMinHeight;
			if(_local3) {
				_local2 = this.minimumTrack.width;
				if(!_local10 && this.maximumTrack.width > _local2) {
					_local2 = this.maximumTrack.width;
				}
				if(this.thumb.width > _local2) {
					_local2 = this.thumb.width;
				}
				if(this.decrementButton.width > _local2) {
					_local2 = this.decrementButton.width;
				}
				if(this.incrementButton.width > _local2) {
					_local2 = this.incrementButton.width;
				}
			}
			if(_local12) {
				_local4 = this.minimumTrack.height;
				if(!_local10) {
					_local4 += this.maximumTrack.height;
				}
				_local4 += this.decrementButton.height + this.incrementButton.height;
			}
			if(_local9) {
				if(_local13 !== null) {
					_local8 = _local13.minWidth;
				} else {
					_local8 = this.minimumTrack.width;
				}
				if(!_local10) {
					if(_local6 !== null) {
						if(_local6.minWidth > _local8) {
							_local8 = _local6.minWidth;
						}
					} else if(this.maximumTrack.width > _local8) {
						_local8 = this.maximumTrack.width;
					}
				}
				if(this.thumb is IMeasureDisplayObject) {
					_local7 = IMeasureDisplayObject(this.thumb);
					if(_local7.minWidth > _local8) {
						_local8 = _local7.minWidth;
					}
				} else if(this.thumb.width > _local8) {
					_local8 = this.thumb.width;
				}
				if(this.decrementButton is IMeasureDisplayObject) {
					_local5 = IMeasureDisplayObject(this.decrementButton);
					if(_local5.minWidth > _local8) {
						_local8 = _local5.minWidth;
					}
				} else if(this.decrementButton.width > _local8) {
					_local8 = this.decrementButton.width;
				}
				if(this.incrementButton is IMeasureDisplayObject) {
					_local1 = IMeasureDisplayObject(this.incrementButton);
					if(_local1.minWidth > _local8) {
						_local8 = _local1.minWidth;
					}
				} else if(this.incrementButton.width > _local8) {
					_local8 = this.incrementButton.width;
				}
			}
			if(_local15) {
				if(_local13 !== null) {
					_local11 = _local13.minHeight;
				} else {
					_local11 = this.minimumTrack.height;
				}
				if(!_local10) {
					if(_local6 !== null) {
						_local11 += _local6.minHeight;
					} else {
						_local11 += this.maximumTrack.height;
					}
				}
				if(this.decrementButton is IMeasureDisplayObject) {
					_local11 += IMeasureDisplayObject(this.decrementButton).minHeight;
				} else {
					_local11 += this.decrementButton.height;
				}
				if(this.incrementButton is IMeasureDisplayObject) {
					_local11 += IMeasureDisplayObject(this.incrementButton).minHeight;
				} else {
					_local11 += this.incrementButton.height;
				}
			}
			return this.saveMeasurements(_local2,_local4,_local8,_local11);
		}
		
		protected function createThumb() : void {
			if(this.thumb) {
				this.thumb.removeFromParent(true);
				this.thumb = null;
			}
			var _local1:Function = this._thumbFactory != null ? this._thumbFactory : defaultThumbFactory;
			var _local3:String = this._customThumbStyleName != null ? this._customThumbStyleName : this.thumbStyleName;
			var _local2:BasicButton = BasicButton(_local1());
			_local2.styleNameList.add(_local3);
			_local2.keepDownStateOnRollOut = true;
			if(_local2 is IFocusDisplayObject) {
				_local2.isFocusEnabled = false;
			}
			_local2.addEventListener("touch",thumb_touchHandler);
			this.addChild(_local2);
			this.thumb = _local2;
		}
		
		protected function createMinimumTrack() : void {
			var _local3:IMeasureDisplayObject = null;
			if(this.minimumTrack) {
				this.minimumTrack.removeFromParent(true);
				this.minimumTrack = null;
			}
			var _local1:Function = this._minimumTrackFactory != null ? this._minimumTrackFactory : defaultMinimumTrackFactory;
			var _local4:String = this._customMinimumTrackStyleName != null ? this._customMinimumTrackStyleName : this.minimumTrackStyleName;
			var _local2:BasicButton = BasicButton(_local1());
			_local2.styleNameList.add(_local4);
			_local2.keepDownStateOnRollOut = true;
			if(_local2 is IFocusDisplayObject) {
				_local2.isFocusEnabled = false;
			}
			_local2.addEventListener("touch",track_touchHandler);
			this.addChildAt(_local2,0);
			this.minimumTrack = _local2;
			if(this.minimumTrack is IFeathersControl) {
				IFeathersControl(this.minimumTrack).initializeNow();
			}
			if(this.minimumTrack is IMeasureDisplayObject) {
				_local3 = IMeasureDisplayObject(this.minimumTrack);
				this._minimumTrackSkinExplicitWidth = _local3.explicitWidth;
				this._minimumTrackSkinExplicitHeight = _local3.explicitHeight;
				this._minimumTrackSkinExplicitMinWidth = _local3.explicitMinWidth;
				this._minimumTrackSkinExplicitMinHeight = _local3.explicitMinHeight;
			} else {
				this._minimumTrackSkinExplicitWidth = this.minimumTrack.width;
				this._minimumTrackSkinExplicitHeight = this.minimumTrack.height;
				this._minimumTrackSkinExplicitMinWidth = this._minimumTrackSkinExplicitWidth;
				this._minimumTrackSkinExplicitMinHeight = this._minimumTrackSkinExplicitHeight;
			}
		}
		
		protected function createMaximumTrack() : void {
			var _local4:IMeasureDisplayObject = null;
			if(this.maximumTrack) {
				this.maximumTrack.removeFromParent(true);
				this.maximumTrack = null;
			}
			if(this._trackLayoutMode !== "split") {
				return;
			}
			var _local1:Function = this._maximumTrackFactory != null ? this._maximumTrackFactory : defaultMaximumTrackFactory;
			var _local3:String = this._customMaximumTrackStyleName != null ? this._customMaximumTrackStyleName : this.maximumTrackStyleName;
			var _local2:BasicButton = BasicButton(_local1());
			_local2.styleNameList.add(_local3);
			_local2.keepDownStateOnRollOut = true;
			if(_local2 is IFocusDisplayObject) {
				_local2.isFocusEnabled = false;
			}
			_local2.addEventListener("touch",track_touchHandler);
			this.addChildAt(_local2,1);
			this.maximumTrack = _local2;
			if(this.maximumTrack is IFeathersControl) {
				IFeathersControl(this.maximumTrack).initializeNow();
			}
			if(this.maximumTrack is IMeasureDisplayObject) {
				_local4 = IMeasureDisplayObject(this.maximumTrack);
				this._maximumTrackSkinExplicitWidth = _local4.explicitWidth;
				this._maximumTrackSkinExplicitHeight = _local4.explicitHeight;
				this._maximumTrackSkinExplicitMinWidth = _local4.explicitMinWidth;
				this._maximumTrackSkinExplicitMinHeight = _local4.explicitMinHeight;
			} else {
				this._maximumTrackSkinExplicitWidth = this.maximumTrack.width;
				this._maximumTrackSkinExplicitHeight = this.maximumTrack.height;
				this._maximumTrackSkinExplicitMinWidth = this._maximumTrackSkinExplicitWidth;
				this._maximumTrackSkinExplicitMinHeight = this._maximumTrackSkinExplicitHeight;
			}
		}
		
		protected function createDecrementButton() : void {
			if(this.decrementButton) {
				this.decrementButton.removeFromParent(true);
				this.decrementButton = null;
			}
			var _local1:Function = this._decrementButtonFactory != null ? this._decrementButtonFactory : defaultDecrementButtonFactory;
			var _local2:String = this._customDecrementButtonStyleName != null ? this._customDecrementButtonStyleName : this.decrementButtonStyleName;
			this.decrementButton = BasicButton(_local1());
			this.decrementButton.styleNameList.add(_local2);
			this.decrementButton.keepDownStateOnRollOut = true;
			if(this.decrementButton is IFocusDisplayObject) {
				this.decrementButton.isFocusEnabled = false;
			}
			this.decrementButton.addEventListener("touch",decrementButton_touchHandler);
			this.addChild(this.decrementButton);
		}
		
		protected function createIncrementButton() : void {
			if(this.incrementButton) {
				this.incrementButton.removeFromParent(true);
				this.incrementButton = null;
			}
			var _local1:Function = this._incrementButtonFactory != null ? this._incrementButtonFactory : defaultIncrementButtonFactory;
			var _local2:String = this._customIncrementButtonStyleName != null ? this._customIncrementButtonStyleName : this.incrementButtonStyleName;
			this.incrementButton = BasicButton(_local1());
			this.incrementButton.styleNameList.add(_local2);
			this.incrementButton.keepDownStateOnRollOut = true;
			if(this.incrementButton is IFocusDisplayObject) {
				this.incrementButton.isFocusEnabled = false;
			}
			this.incrementButton.addEventListener("touch",incrementButton_touchHandler);
			this.addChild(this.incrementButton);
		}
		
		protected function refreshThumbStyles() : void {
			var _local2:Object = null;
			for(var _local1 in this._thumbProperties) {
				_local2 = this._thumbProperties[_local1];
				this.thumb[_local1] = _local2;
			}
		}
		
		protected function refreshMinimumTrackStyles() : void {
			var _local2:Object = null;
			for(var _local1 in this._minimumTrackProperties) {
				_local2 = this._minimumTrackProperties[_local1];
				this.minimumTrack[_local1] = _local2;
			}
		}
		
		protected function refreshMaximumTrackStyles() : void {
			var _local2:Object = null;
			if(!this.maximumTrack) {
				return;
			}
			for(var _local1 in this._maximumTrackProperties) {
				_local2 = this._maximumTrackProperties[_local1];
				this.maximumTrack[_local1] = _local2;
			}
		}
		
		protected function refreshDecrementButtonStyles() : void {
			var _local2:Object = null;
			for(var _local1 in this._decrementButtonProperties) {
				_local2 = this._decrementButtonProperties[_local1];
				this.decrementButton[_local1] = _local2;
			}
		}
		
		protected function refreshIncrementButtonStyles() : void {
			var _local2:Object = null;
			for(var _local1 in this._incrementButtonProperties) {
				_local2 = this._incrementButtonProperties[_local1];
				this.incrementButton[_local1] = _local2;
			}
		}
		
		protected function refreshEnabled() : void {
			var _local1:Boolean = this._isEnabled && this._maximum > this._minimum;
			if(this.thumb is IFeathersControl) {
				IFeathersControl(this.thumb).isEnabled = _local1;
			}
			if(this.minimumTrack is IFeathersControl) {
				IFeathersControl(this.minimumTrack).isEnabled = _local1;
			}
			if(this.maximumTrack is IFeathersControl) {
				IFeathersControl(this.maximumTrack).isEnabled = _local1;
			}
			this.decrementButton.isEnabled = _local1;
			this.incrementButton.isEnabled = _local1;
		}
		
		protected function layout() : void {
			this.layoutStepButtons();
			this.layoutThumb();
			if(this._trackLayoutMode == "split") {
				this.layoutTrackWithMinMax();
			} else {
				this.layoutTrackWithSingle();
			}
		}
		
		protected function layoutStepButtons() : void {
			if(this._direction == "vertical") {
				this.decrementButton.x = (this.actualWidth - this.decrementButton.width) / 2;
				this.decrementButton.y = 0;
				this.incrementButton.x = (this.actualWidth - this.incrementButton.width) / 2;
				this.incrementButton.y = this.actualHeight - this.incrementButton.height;
			} else {
				this.decrementButton.x = 0;
				this.decrementButton.y = (this.actualHeight - this.decrementButton.height) / 2;
				this.incrementButton.x = this.actualWidth - this.incrementButton.width;
				this.incrementButton.y = (this.actualHeight - this.incrementButton.height) / 2;
			}
			var _local1:* = this._maximum != this._minimum;
			this.decrementButton.visible = _local1;
			this.incrementButton.visible = _local1;
		}
		
		protected function layoutThumb() : void {
			var _local1:Number = NaN;
			var _local6:Number = NaN;
			var _local5:Number = NaN;
			var _local7:Number = NaN;
			var _local4:Number = this._maximum - this._minimum;
			this.thumb.visible = _local4 > 0 && _local4 < Infinity && this._isEnabled;
			if(!this.thumb.visible) {
				return;
			}
			if(this.thumb is IValidating) {
				IValidating(this.thumb).validate();
			}
			var _local3:Number = this.actualWidth - this._paddingLeft - this._paddingRight;
			var _local8:Number = this.actualHeight - this._paddingTop - this._paddingBottom;
			var _local2:* = this._page;
			if(this._page == 0) {
				_local2 = this._step;
			}
			if(_local2 > _local4) {
				_local2 = _local4;
			}
			if(this._direction == "vertical") {
				_local8 -= this.decrementButton.height + this.incrementButton.height;
				_local1 = this.thumbOriginalHeight;
				if(this.thumb is IMeasureDisplayObject) {
					_local1 = Number(IMeasureDisplayObject(this.thumb).minHeight);
				}
				this.thumb.width = this.thumbOriginalWidth;
				this.thumb.height = Math.max(_local1,_local8 * _local2 / _local4);
				_local6 = _local8 - this.thumb.height;
				this.thumb.x = this._paddingLeft + (this.actualWidth - this._paddingLeft - this._paddingRight - this.thumb.width) / 2;
				this.thumb.y = this.decrementButton.height + this._paddingTop + Math.max(0,Math.min(_local6,_local6 * (this._value - this._minimum) / _local4));
			} else {
				_local3 -= this.decrementButton.width + this.decrementButton.width;
				_local5 = this.thumbOriginalWidth;
				if(this.thumb is IMeasureDisplayObject) {
					_local5 = Number(IMeasureDisplayObject(this.thumb).minWidth);
				}
				this.thumb.width = Math.max(_local5,_local3 * _local2 / _local4);
				this.thumb.height = this.thumbOriginalHeight;
				_local7 = _local3 - this.thumb.width;
				this.thumb.x = this.decrementButton.width + this._paddingLeft + Math.max(0,Math.min(_local7,_local7 * (this._value - this._minimum) / _local4));
				this.thumb.y = this._paddingTop + (this.actualHeight - this._paddingTop - this._paddingBottom - this.thumb.height) / 2;
			}
		}
		
		protected function layoutTrackWithMinMax() : void {
			var _local2:Number = this._maximum - this._minimum;
			this.minimumTrack.touchable = _local2 > 0 && _local2 < Infinity;
			if(this.maximumTrack) {
				this.maximumTrack.touchable = _local2 > 0 && _local2 < Infinity;
			}
			var _local1:* = this._maximum !== this._minimum;
			if(this._direction === "vertical") {
				this.minimumTrack.x = 0;
				if(_local1) {
					this.minimumTrack.y = this.decrementButton.height;
				} else {
					this.minimumTrack.y = 0;
				}
				this.minimumTrack.width = this.actualWidth;
				this.minimumTrack.height = this.thumb.y + this.thumb.height / 2 - this.minimumTrack.y;
				this.maximumTrack.x = 0;
				this.maximumTrack.y = this.minimumTrack.y + this.minimumTrack.height;
				this.maximumTrack.width = this.actualWidth;
				if(_local1) {
					this.maximumTrack.height = this.actualHeight - this.incrementButton.height - this.maximumTrack.y;
				} else {
					this.maximumTrack.height = this.actualHeight - this.maximumTrack.y;
				}
			} else {
				if(_local1) {
					this.minimumTrack.x = this.decrementButton.width;
				} else {
					this.minimumTrack.x = 0;
				}
				this.minimumTrack.y = 0;
				this.minimumTrack.width = this.thumb.x + this.thumb.width / 2 - this.minimumTrack.x;
				this.minimumTrack.height = this.actualHeight;
				this.maximumTrack.x = this.minimumTrack.x + this.minimumTrack.width;
				this.maximumTrack.y = 0;
				if(_local1) {
					this.maximumTrack.width = this.actualWidth - this.incrementButton.width - this.maximumTrack.x;
				} else {
					this.maximumTrack.width = this.actualWidth - this.maximumTrack.x;
				}
				this.maximumTrack.height = this.actualHeight;
			}
			if(this.minimumTrack is IValidating) {
				IValidating(this.minimumTrack).validate();
			}
			if(this.maximumTrack is IValidating) {
				IValidating(this.maximumTrack).validate();
			}
		}
		
		protected function layoutTrackWithSingle() : void {
			var _local2:Number = this._maximum - this._minimum;
			this.minimumTrack.touchable = _local2 > 0 && _local2 < Infinity;
			var _local1:* = this._maximum !== this._minimum;
			if(this._direction === "vertical") {
				this.minimumTrack.x = 0;
				if(_local1) {
					this.minimumTrack.y = this.decrementButton.height;
				} else {
					this.minimumTrack.y = 0;
				}
				this.minimumTrack.width = this.actualWidth;
				if(_local1) {
					this.minimumTrack.height = this.actualHeight - this.minimumTrack.y - this.incrementButton.height;
				} else {
					this.minimumTrack.height = this.actualHeight - this.minimumTrack.y;
				}
			} else {
				if(_local1) {
					this.minimumTrack.x = this.decrementButton.width;
				} else {
					this.minimumTrack.x = 0;
				}
				this.minimumTrack.y = 0;
				if(_local1) {
					this.minimumTrack.width = this.actualWidth - this.minimumTrack.x - this.incrementButton.width;
				} else {
					this.minimumTrack.width = this.actualWidth - this.minimumTrack.x;
				}
				this.minimumTrack.height = this.actualHeight;
			}
			if(this.minimumTrack is IValidating) {
				IValidating(this.minimumTrack).validate();
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
				_local7 = this.actualHeight - this.thumb.height - this.decrementButton.height - this.incrementButton.height - this._paddingTop - this._paddingBottom;
				if(_local7 > 0) {
					_local3 = location.y - this._touchStartY - this._paddingTop;
					_local6 = Math.min(Math.max(0,this._thumbStartY + _local3 - this.decrementButton.height),_local7);
					_local5 = _local6 / _local7;
				}
			} else {
				_local8 = this.actualWidth - this.thumb.width - this.decrementButton.width - this.incrementButton.width - this._paddingLeft - this._paddingRight;
				if(_local8 > 0) {
					_local4 = location.x - this._touchStartX - this._paddingLeft;
					_local2 = Math.min(Math.max(0,this._thumbStartX + _local4 - this.decrementButton.width),_local8);
					_local5 = _local2 / _local8;
				}
			}
			return this._minimum + _local5 * (this._maximum - this._minimum);
		}
		
		protected function decrement() : void {
			this.value -= this._step;
		}
		
		protected function increment() : void {
			this.value += this._step;
		}
		
		protected function adjustPage() : void {
			var _local1:Number = NaN;
			var _local3:Number = this._maximum - this._minimum;
			var _local2:* = this._page;
			if(this._page == 0) {
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
		
		protected function minimumTrackProperties_onChange(proxy:PropertyProxy, name:Object) : void {
			this.invalidate("styles");
		}
		
		protected function maximumTrackProperties_onChange(proxy:PropertyProxy, name:Object) : void {
			this.invalidate("styles");
		}
		
		protected function decrementButtonProperties_onChange(proxy:PropertyProxy, name:Object) : void {
			this.invalidate("styles");
		}
		
		protected function incrementButtonProperties_onChange(proxy:PropertyProxy, name:Object) : void {
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
			var _local3:DisplayObject = DisplayObject(event.currentTarget);
			if(this._touchPointID >= 0) {
				_local2 = event.getTouch(_local3,"ended",this._touchPointID);
				if(!_local2) {
					return;
				}
				this._touchPointID = -1;
				this._repeatTimer.stop();
				this.dispatchEventWith("endInteraction");
			} else {
				_local2 = event.getTouch(_local3,"began");
				if(!_local2) {
					return;
				}
				this._touchPointID = _local2.id;
				this.dispatchEventWith("beginInteraction");
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
				this._touchPointID = -1;
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
		
		protected function decrementButton_touchHandler(event:TouchEvent) : void {
			var _local2:Touch = null;
			if(!this._isEnabled) {
				this._touchPointID = -1;
				return;
			}
			if(this._touchPointID >= 0) {
				_local2 = event.getTouch(this.decrementButton,"ended",this._touchPointID);
				if(!_local2) {
					return;
				}
				this._touchPointID = -1;
				this._repeatTimer.stop();
				this.dispatchEventWith("endInteraction");
			} else {
				_local2 = event.getTouch(this.decrementButton,"began");
				if(!_local2) {
					return;
				}
				this._touchPointID = _local2.id;
				this.dispatchEventWith("beginInteraction");
				this.decrement();
				this.startRepeatTimer(this.decrement);
			}
		}
		
		protected function incrementButton_touchHandler(event:TouchEvent) : void {
			var _local2:Touch = null;
			if(!this._isEnabled) {
				this._touchPointID = -1;
				return;
			}
			if(this._touchPointID >= 0) {
				_local2 = event.getTouch(this.incrementButton,"ended",this._touchPointID);
				if(!_local2) {
					return;
				}
				this._touchPointID = -1;
				this._repeatTimer.stop();
				this.dispatchEventWith("endInteraction");
			} else {
				_local2 = event.getTouch(this.incrementButton,"began");
				if(!_local2) {
					return;
				}
				this._touchPointID = _local2.id;
				this.dispatchEventWith("beginInteraction");
				this.increment();
				this.startRepeatTimer(this.increment);
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

