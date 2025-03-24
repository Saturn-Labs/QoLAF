package feathers.controls {
	import feathers.core.FeathersControl;
	import feathers.core.IFeathersControl;
	import feathers.core.IFocusDisplayObject;
	import feathers.core.IMeasureDisplayObject;
	import feathers.core.IValidating;
	import feathers.core.PropertyProxy;
	import feathers.events.ExclusiveTouch;
	import feathers.skins.IStyleProvider;
	import feathers.utils.math.clamp;
	import feathers.utils.math.roundToNearest;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	public class Slider extends FeathersControl implements IDirectionalScrollBar, IFocusDisplayObject {
		protected static const INVALIDATION_FLAG_THUMB_FACTORY:String = "thumbFactory";
		
		protected static const INVALIDATION_FLAG_MINIMUM_TRACK_FACTORY:String = "minimumTrackFactory";
		
		protected static const INVALIDATION_FLAG_MAXIMUM_TRACK_FACTORY:String = "maximumTrackFactory";
		
		public static const DIRECTION_HORIZONTAL:String = "horizontal";
		
		public static const DIRECTION_VERTICAL:String = "vertical";
		
		public static const TRACK_LAYOUT_MODE_SINGLE:String = "single";
		
		public static const TRACK_LAYOUT_MODE_MIN_MAX:String = "minMax";
		
		public static const TRACK_SCALE_MODE_EXACT_FIT:String = "exactFit";
		
		public static const TRACK_SCALE_MODE_DIRECTIONAL:String = "directional";
		
		public static const TRACK_INTERACTION_MODE_TO_VALUE:String = "toValue";
		
		public static const TRACK_INTERACTION_MODE_BY_PAGE:String = "byPage";
		
		public static const DEFAULT_CHILD_STYLE_NAME_MINIMUM_TRACK:String = "feathers-slider-minimum-track";
		
		public static const DEFAULT_CHILD_STYLE_NAME_MAXIMUM_TRACK:String = "feathers-slider-maximum-track";
		
		public static const DEFAULT_CHILD_STYLE_NAME_THUMB:String = "feathers-slider-thumb";
		
		public static var globalStyleProvider:IStyleProvider;
		
		private static const HELPER_POINT:Point = new Point();
		
		protected var minimumTrackStyleName:String = "feathers-slider-minimum-track";
		
		protected var maximumTrackStyleName:String = "feathers-slider-maximum-track";
		
		protected var thumbStyleName:String = "feathers-slider-thumb";
		
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
		
		protected var _page:Number = NaN;
		
		protected var isDragging:Boolean = false;
		
		public var liveDragging:Boolean = true;
		
		protected var _showThumb:Boolean = true;
		
		protected var _thumbOffset:Number = 0;
		
		protected var _minimumPadding:Number = 0;
		
		protected var _maximumPadding:Number = 0;
		
		protected var _trackLayoutMode:String = "single";
		
		protected var _trackScaleMode:String = "directional";
		
		protected var _trackInteractionMode:String = "toValue";
		
		protected var currentRepeatAction:Function;
		
		protected var _repeatTimer:Timer;
		
		protected var _repeatDelay:Number = 0.05;
		
		protected var _minimumTrackFactory:Function;
		
		protected var _customMinimumTrackStyleName:String;
		
		protected var _minimumTrackProperties:PropertyProxy;
		
		protected var _maximumTrackFactory:Function;
		
		protected var _customMaximumTrackStyleName:String;
		
		protected var _maximumTrackProperties:PropertyProxy;
		
		protected var _thumbFactory:Function;
		
		protected var _customThumbStyleName:String;
		
		protected var _thumbProperties:PropertyProxy;
		
		protected var _touchPointID:int = -1;
		
		protected var _touchStartX:Number = NaN;
		
		protected var _touchStartY:Number = NaN;
		
		protected var _thumbStartX:Number = NaN;
		
		protected var _thumbStartY:Number = NaN;
		
		protected var _touchValue:Number;
		
		public function Slider() {
			super();
			this.addEventListener("removedFromStage",slider_removedFromStageHandler);
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
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return Slider.globalStyleProvider;
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
			this.invalidate("minimumTrackFactory");
			this.invalidate("maximumTrackFactory");
			this.invalidate("thumbFactory");
		}
		
		public function get value() : Number {
			return this._value;
		}
		
		public function set value(newValue:Number) : void {
			if(this._step != 0 && newValue != this._maximum && newValue != this._minimum) {
				newValue = roundToNearest(newValue - this._minimum,this._step) + this._minimum;
			}
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
			if(this._step == value) {
				return;
			}
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
		}
		
		public function get showThumb() : Boolean {
			return this._showThumb;
		}
		
		public function set showThumb(value:Boolean) : void {
			if(this._showThumb == value) {
				return;
			}
			this._showThumb = value;
			this.invalidate("styles");
		}
		
		public function get thumbOffset() : Number {
			return this._thumbOffset;
		}
		
		public function set thumbOffset(value:Number) : void {
			if(this._thumbOffset == value) {
				return;
			}
			this._thumbOffset = value;
			this.invalidate("styles");
		}
		
		public function get minimumPadding() : Number {
			return this._minimumPadding;
		}
		
		public function set minimumPadding(value:Number) : void {
			if(this._minimumPadding == value) {
				return;
			}
			this._minimumPadding = value;
			this.invalidate("styles");
		}
		
		public function get maximumPadding() : Number {
			return this._maximumPadding;
		}
		
		public function set maximumPadding(value:Number) : void {
			if(this._maximumPadding == value) {
				return;
			}
			this._maximumPadding = value;
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
			this.invalidate("styles");
		}
		
		public function get trackScaleMode() : String {
			return this._trackScaleMode;
		}
		
		public function set trackScaleMode(value:String) : void {
			if(this._trackScaleMode == value) {
				return;
			}
			this._trackScaleMode = value;
			this.invalidate("styles");
		}
		
		public function get trackInteractionMode() : String {
			return this._trackInteractionMode;
		}
		
		public function set trackInteractionMode(value:String) : void {
			this._trackInteractionMode = value;
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
				this._minimumTrackProperties = new PropertyProxy(childProperties_onChange);
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
				this._minimumTrackProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._minimumTrackProperties = PropertyProxy(value);
			if(this._minimumTrackProperties) {
				this._minimumTrackProperties.addOnChangeCallback(childProperties_onChange);
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
				this._maximumTrackProperties = new PropertyProxy(childProperties_onChange);
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
				this._maximumTrackProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._maximumTrackProperties = PropertyProxy(value);
			if(this._maximumTrackProperties) {
				this._maximumTrackProperties.addOnChangeCallback(childProperties_onChange);
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
				this._thumbProperties = new PropertyProxy(childProperties_onChange);
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
				this._thumbProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._thumbProperties = PropertyProxy(value);
			if(this._thumbProperties) {
				this._thumbProperties.addOnChangeCallback(childProperties_onChange);
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
			var _local8:Boolean = this.isInvalid("styles");
			var _local1:Boolean = this.isInvalid("size");
			var _local5:Boolean = this.isInvalid("state");
			var _local2:Boolean = this.isInvalid("focus");
			var _local4:Boolean = this.isInvalid("layout");
			var _local7:Boolean = this.isInvalid("thumbFactory");
			var _local6:Boolean = this.isInvalid("minimumTrackFactory");
			var _local3:Boolean = this.isInvalid("maximumTrackFactory");
			if(_local7) {
				this.createThumb();
			}
			if(_local6) {
				this.createMinimumTrack();
			}
			if(_local3 || _local4) {
				this.createMaximumTrack();
			}
			if(_local7 || _local8) {
				this.refreshThumbStyles();
			}
			if(_local6 || _local8) {
				this.refreshMinimumTrackStyles();
			}
			if((_local3 || _local4 || _local8) && this.maximumTrack) {
				this.refreshMaximumTrackStyles();
			}
			if(_local5 || _local7 || _local6 || _local3) {
				this.refreshEnabled();
			}
			_local1 = this.autoSizeIfNeeded() || _local1;
			this.layoutChildren();
			if(_local1 || _local2) {
				this.refreshFocusIndicator();
			}
		}
		
		protected function autoSizeIfNeeded() : Boolean {
			if(this._direction === "vertical") {
				return this.measureVertical();
			}
			return this.measureHorizontal();
		}
		
		protected function measureVertical() : Boolean {
			var _local11:IMeasureDisplayObject = null;
			var _local12:Number = NaN;
			var _local4:IMeasureDisplayObject = null;
			var _local5:IMeasureDisplayObject = null;
			var _local2:* = this._explicitWidth !== this._explicitWidth;
			var _local10:* = this._explicitHeight !== this._explicitHeight;
			var _local7:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local13:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local2 && !_local10 && !_local7 && !_local13) {
				return false;
			}
			var _local8:* = this._trackLayoutMode === "single";
			if(_local10) {
				this.minimumTrack.height = this._minimumTrackSkinExplicitHeight;
			} else if(_local8) {
				this.minimumTrack.height = this._explicitHeight;
			}
			if(this.minimumTrack is IMeasureDisplayObject) {
				_local11 = IMeasureDisplayObject(this.minimumTrack);
				if(_local13) {
					_local11.minHeight = this._minimumTrackSkinExplicitMinHeight;
				} else if(_local8) {
					_local12 = this._explicitMinHeight;
					if(this._minimumTrackSkinExplicitMinHeight > _local12) {
						_local12 = this._minimumTrackSkinExplicitMinHeight;
					}
					_local11.minHeight = _local12;
				}
			}
			if(!_local8) {
				if(_local10) {
					this.maximumTrack.height = this._maximumTrackSkinExplicitHeight;
				}
				if(this.maximumTrack is IMeasureDisplayObject) {
					_local4 = IMeasureDisplayObject(this.maximumTrack);
					if(_local13) {
						_local4.minHeight = this._maximumTrackSkinExplicitMinHeight;
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
			var _local1:Number = this._explicitWidth;
			var _local3:Number = this._explicitHeight;
			var _local6:Number = this._explicitMinWidth;
			var _local9:Number = this._explicitMinHeight;
			if(_local2) {
				_local1 = this.minimumTrack.width;
				if(!_local8 && this.maximumTrack.width > _local1) {
					_local1 = this.maximumTrack.width;
				}
				if(this.thumb.width > _local1) {
					_local1 = this.thumb.width;
				}
			}
			if(_local10) {
				_local3 = this.minimumTrack.height;
				if(!_local8) {
					if(this.maximumTrack.height > _local3) {
						_local3 = this.maximumTrack.height;
					}
					_local3 += this.thumb.height / 2;
				}
			}
			if(_local7) {
				if(_local11 !== null) {
					_local6 = _local11.minWidth;
				} else {
					_local6 = this.minimumTrack.width;
				}
				if(!_local8) {
					if(_local4 !== null) {
						if(_local4.minWidth > _local6) {
							_local6 = _local4.minWidth;
						}
					} else if(this.maximumTrack.width > _local6) {
						_local6 = this.maximumTrack.width;
					}
				}
				if(this.thumb is IMeasureDisplayObject) {
					_local5 = IMeasureDisplayObject(this.thumb);
					if(_local5.minWidth > _local6) {
						_local6 = _local5.minWidth;
					}
				} else if(this.thumb.width > _local6) {
					_local6 = this.thumb.width;
				}
			}
			if(_local13) {
				if(_local11 !== null) {
					_local9 = _local11.minHeight;
				} else {
					_local9 = this.minimumTrack.height;
				}
				if(!_local8) {
					if(_local4 !== null) {
						if(_local4.minHeight > _local9) {
							_local9 = _local4.minHeight;
						}
					} else {
						_local9 = this.maximumTrack.height;
					}
					if(this.thumb is IMeasureDisplayObject) {
						_local9 += IMeasureDisplayObject(this.thumb).minHeight / 2;
					} else {
						_local9 += this.thumb.height / 2;
					}
				}
			}
			return this.saveMeasurements(_local1,_local3,_local6,_local9);
		}
		
		protected function measureHorizontal() : Boolean {
			var _local12:IMeasureDisplayObject = null;
			var _local4:Number = NaN;
			var _local5:IMeasureDisplayObject = null;
			var _local6:IMeasureDisplayObject = null;
			var _local2:* = this._explicitWidth !== this._explicitWidth;
			var _local11:* = this._explicitHeight !== this._explicitHeight;
			var _local8:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local13:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local2 && !_local11 && !_local8 && !_local13) {
				return false;
			}
			var _local9:* = this._trackLayoutMode === "single";
			if(_local2) {
				this.minimumTrack.width = this._minimumTrackSkinExplicitWidth;
			} else if(_local9) {
				this.minimumTrack.width = this._explicitWidth;
			}
			if(this.minimumTrack is IMeasureDisplayObject) {
				_local12 = IMeasureDisplayObject(this.minimumTrack);
				if(_local8) {
					_local12.minWidth = this._minimumTrackSkinExplicitMinWidth;
				} else if(_local9) {
					_local4 = this._explicitMinWidth;
					if(this._minimumTrackSkinExplicitMinWidth > _local4) {
						_local4 = this._minimumTrackSkinExplicitMinWidth;
					}
					_local12.minWidth = _local4;
				}
			}
			if(!_local9) {
				if(_local2) {
					this.maximumTrack.width = this._maximumTrackSkinExplicitWidth;
				}
				if(this.maximumTrack is IMeasureDisplayObject) {
					_local5 = IMeasureDisplayObject(this.maximumTrack);
					if(_local8) {
						_local5.minWidth = this._maximumTrackSkinExplicitMinWidth;
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
			var _local1:Number = this._explicitWidth;
			var _local3:Number = this._explicitHeight;
			var _local7:Number = this._explicitMinWidth;
			var _local10:Number = this._explicitMinHeight;
			if(_local2) {
				_local1 = this.minimumTrack.width;
				if(!_local9) {
					if(this.maximumTrack.width > _local1) {
						_local1 = this.maximumTrack.width;
					}
					_local1 += this.thumb.width / 2;
				}
			}
			if(_local11) {
				_local3 = this.minimumTrack.height;
				if(!_local9 && this.maximumTrack.height > _local3) {
					_local3 = this.maximumTrack.height;
				}
				if(this.thumb.height > _local3) {
					_local3 = this.thumb.height;
				}
			}
			if(_local8) {
				if(_local12 !== null) {
					_local7 = _local12.minWidth;
				} else {
					_local7 = this.minimumTrack.width;
				}
				if(!_local9) {
					if(_local5 !== null) {
						if(_local5.minWidth > _local7) {
							_local7 = _local5.minWidth;
						}
					} else if(this.maximumTrack.width > _local7) {
						_local7 = this.maximumTrack.width;
					}
					if(this.thumb is IMeasureDisplayObject) {
						_local7 += IMeasureDisplayObject(this.thumb).minWidth / 2;
					} else {
						_local7 += this.thumb.width / 2;
					}
				}
			}
			if(_local13) {
				if(_local12 !== null) {
					_local10 = _local12.minHeight;
				} else {
					_local10 = this.minimumTrack.height;
				}
				if(!_local9) {
					if(_local5 !== null) {
						if(_local5.minHeight > _local10) {
							_local10 = _local5.minHeight;
						}
					} else if(this.maximumTrack.height > _local10) {
						_local10 = this.maximumTrack.height;
					}
				}
				if(this.thumb is IMeasureDisplayObject) {
					_local6 = IMeasureDisplayObject(this.thumb);
					if(_local6.minHeight > _local10) {
						_local10 = _local6.minHeight;
					}
				} else if(this.thumb.height > _local10) {
					_local10 = this.thumb.height;
				}
			}
			return this.saveMeasurements(_local1,_local3,_local7,_local10);
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
			if(this.maximumTrack !== null) {
				this.maximumTrack.removeFromParent(true);
				this.maximumTrack = null;
			}
			if(this._trackLayoutMode === "single") {
				return;
			}
			var _local1:Function = this._maximumTrackFactory != null ? this._maximumTrackFactory : defaultMaximumTrackFactory;
			var _local3:String = this._customMaximumTrackStyleName != null ? this._customMaximumTrackStyleName : this.maximumTrackStyleName;
			var _local2:BasicButton = BasicButton(_local1());
			_local2.styleNameList.add(_local3);
			_local2.keepDownStateOnRollOut = true;
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
		
		protected function refreshThumbStyles() : void {
			var _local2:Object = null;
			for(var _local1 in this._thumbProperties) {
				_local2 = this._thumbProperties[_local1];
				this.thumb[_local1] = _local2;
			}
			this.thumb.visible = this._showThumb;
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
		
		protected function refreshEnabled() : void {
			if(this.thumb is IFeathersControl) {
				IFeathersControl(this.thumb).isEnabled = this._isEnabled;
			}
			if(this.minimumTrack is IFeathersControl) {
				IFeathersControl(this.minimumTrack).isEnabled = this._isEnabled;
			}
			if(this.maximumTrack is IFeathersControl) {
				IFeathersControl(this.maximumTrack).isEnabled = this._isEnabled;
			}
		}
		
		protected function layoutChildren() : void {
			this.layoutThumb();
			if(this._trackLayoutMode == "split") {
				this.layoutTrackWithMinMax();
			} else {
				this.layoutTrackWithSingle();
			}
		}
		
		protected function layoutThumb() : void {
			var _local1:Number = NaN;
			var _local2:Number = NaN;
			var _local3:Number = NaN;
			if(this.thumb is IValidating) {
				IValidating(this.thumb).validate();
			}
			if(this._minimum === this._maximum) {
				_local1 = 1;
			} else {
				_local1 = (this._value - this._minimum) / (this._maximum - this._minimum);
				if(_local1 < 0) {
					_local1 = 0;
				} else if(_local1 > 1) {
					_local1 = 1;
				}
			}
			if(this._direction == "vertical") {
				_local2 = this.actualHeight - this.thumb.height - this._minimumPadding - this._maximumPadding;
				this.thumb.x = Math.round((this.actualWidth - this.thumb.width) / 2) + this._thumbOffset;
				this.thumb.y = Math.round(this._maximumPadding + _local2 * (1 - _local1));
			} else {
				_local3 = this.actualWidth - this.thumb.width - this._minimumPadding - this._maximumPadding;
				this.thumb.x = Math.round(this._minimumPadding + _local3 * _local1);
				this.thumb.y = Math.round((this.actualHeight - this.thumb.height) / 2) + this._thumbOffset;
			}
		}
		
		protected function layoutTrackWithMinMax() : void {
			var _local1:Number = NaN;
			var _local2:Number = NaN;
			if(this._direction === "vertical") {
				_local1 = Math.round(this.thumb.y + this.thumb.height / 2);
				this.maximumTrack.y = 0;
				this.maximumTrack.height = _local1;
				this.minimumTrack.y = _local1;
				this.minimumTrack.height = this.actualHeight - _local1;
				if(this._trackScaleMode === "exactFit") {
					this.maximumTrack.x = 0;
					this.maximumTrack.width = this.actualWidth;
					this.minimumTrack.x = 0;
					this.minimumTrack.width = this.actualWidth;
				} else {
					this.maximumTrack.width = this._maximumTrackSkinExplicitWidth;
					this.minimumTrack.width = this._minimumTrackSkinExplicitWidth;
				}
				if(this.minimumTrack is IValidating) {
					IValidating(this.minimumTrack).validate();
				}
				if(this.maximumTrack is IValidating) {
					IValidating(this.maximumTrack).validate();
				}
				if(this._trackScaleMode === "directional") {
					this.maximumTrack.x = Math.round((this.actualWidth - this.maximumTrack.width) / 2);
					this.minimumTrack.x = Math.round((this.actualWidth - this.minimumTrack.width) / 2);
				}
			} else {
				_local2 = Math.round(this.thumb.x + this.thumb.width / 2);
				this.minimumTrack.x = 0;
				this.minimumTrack.width = _local2;
				this.maximumTrack.x = _local2;
				this.maximumTrack.width = this.actualWidth - _local2;
				if(this._trackScaleMode === "exactFit") {
					this.minimumTrack.y = 0;
					this.minimumTrack.height = this.actualHeight;
					this.maximumTrack.y = 0;
					this.maximumTrack.height = this.actualHeight;
				} else {
					this.minimumTrack.height = this._minimumTrackSkinExplicitHeight;
					this.maximumTrack.height = this._maximumTrackSkinExplicitHeight;
				}
				if(this.minimumTrack is IValidating) {
					IValidating(this.minimumTrack).validate();
				}
				if(this.maximumTrack is IValidating) {
					IValidating(this.maximumTrack).validate();
				}
				if(this._trackScaleMode === "directional") {
					this.minimumTrack.y = Math.round((this.actualHeight - this.minimumTrack.height) / 2);
					this.maximumTrack.y = Math.round((this.actualHeight - this.maximumTrack.height) / 2);
				}
			}
		}
		
		protected function layoutTrackWithSingle() : void {
			if(this._direction === "vertical") {
				this.minimumTrack.y = 0;
				this.minimumTrack.height = this.actualHeight;
				if(this._trackScaleMode === "exactFit") {
					this.minimumTrack.x = 0;
					this.minimumTrack.width = this.actualWidth;
				} else {
					this.minimumTrack.width = this._minimumTrackSkinExplicitWidth;
				}
				if(this.minimumTrack is IValidating) {
					IValidating(this.minimumTrack).validate();
				}
				if(this._trackScaleMode === "directional") {
					this.minimumTrack.x = Math.round((this.actualWidth - this.minimumTrack.width) / 2);
				}
			} else {
				this.minimumTrack.x = 0;
				this.minimumTrack.width = this.actualWidth;
				if(this._trackScaleMode === "exactFit") {
					this.minimumTrack.y = 0;
					this.minimumTrack.height = this.actualHeight;
				} else {
					this.minimumTrack.height = this._minimumTrackSkinExplicitHeight;
				}
				if(this.minimumTrack is IValidating) {
					IValidating(this.minimumTrack).validate();
				}
				if(this._trackScaleMode === "directional") {
					this.minimumTrack.y = Math.round((this.actualHeight - this.minimumTrack.height) / 2);
				}
			}
		}
		
		protected function locationToValue(location:Point) : Number {
			var _local5:Number = NaN;
			var _local7:Number = NaN;
			var _local3:Number = NaN;
			var _local6:Number = NaN;
			var _local8:Number = NaN;
			var _local4:Number = NaN;
			var _local2:Number = NaN;
			if(this._direction == "vertical") {
				_local7 = this.actualHeight - this.thumb.height - this._minimumPadding - this._maximumPadding;
				_local3 = location.y - this._touchStartY - this._maximumPadding;
				_local6 = Math.min(Math.max(0,this._thumbStartY + _local3),_local7);
				_local5 = 1 - _local6 / _local7;
			} else {
				_local8 = this.actualWidth - this.thumb.width - this._minimumPadding - this._maximumPadding;
				_local4 = location.x - this._touchStartX - this._minimumPadding;
				_local2 = Math.min(Math.max(0,this._thumbStartX + _local4),_local8);
				_local5 = _local2 / _local8;
			}
			return this._minimum + _local5 * (this._maximum - this._minimum);
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
		
		protected function adjustPage() : void {
			var _local1:Number = this._page;
			if(_local1 !== _local1) {
				_local1 = this._step;
			}
			if(this._touchValue < this._value) {
				this.value = Math.max(this._touchValue,this._value - _local1);
			} else if(this._touchValue > this._value) {
				this.value = Math.min(this._touchValue,this._value + _local1);
			}
		}
		
		protected function childProperties_onChange(proxy:PropertyProxy, name:Object) : void {
			this.invalidate("styles");
		}
		
		protected function slider_removedFromStageHandler(event:Event) : void {
			this._touchPointID = -1;
			var _local2:Boolean = this.isDragging;
			this.isDragging = false;
			if(_local2 && !this.liveDragging) {
				this.dispatchEventWith("change");
			}
		}
		
		override protected function focusInHandler(event:Event) : void {
			super.focusInHandler(event);
			this.stage.addEventListener("keyDown",stage_keyDownHandler);
		}
		
		override protected function focusOutHandler(event:Event) : void {
			super.focusOutHandler(event);
			this.stage.removeEventListener("keyDown",stage_keyDownHandler);
		}
		
		protected function track_touchHandler(event:TouchEvent) : void {
			var _local2:Touch = null;
			if(!this._isEnabled) {
				this._touchPointID = -1;
				return;
			}
			var _local3:DisplayObject = DisplayObject(event.currentTarget);
			if(this._touchPointID >= 0) {
				_local2 = event.getTouch(_local3,null,this._touchPointID);
				if(!_local2) {
					return;
				}
				if(_local2.phase === "moved") {
					_local2.getLocation(this,HELPER_POINT);
					this.value = this.locationToValue(HELPER_POINT);
				} else if(_local2.phase === "ended") {
					if(this._repeatTimer) {
						this._repeatTimer.stop();
					}
					this._touchPointID = -1;
					this.isDragging = false;
					if(!this.liveDragging) {
						this.dispatchEventWith("change");
					}
					this.dispatchEventWith("endInteraction");
				}
			} else {
				_local2 = event.getTouch(_local3,"began");
				if(!_local2) {
					return;
				}
				_local2.getLocation(this,HELPER_POINT);
				this._touchPointID = _local2.id;
				if(this._direction == "vertical") {
					this._thumbStartX = HELPER_POINT.x;
					this._thumbStartY = Math.min(this.actualHeight - this.thumb.height,Math.max(0,HELPER_POINT.y - this.thumb.height / 2));
				} else {
					this._thumbStartX = Math.min(this.actualWidth - this.thumb.width,Math.max(0,HELPER_POINT.x - this.thumb.width / 2));
					this._thumbStartY = HELPER_POINT.y;
				}
				this._touchStartX = HELPER_POINT.x;
				this._touchStartY = HELPER_POINT.y;
				this._touchValue = this.locationToValue(HELPER_POINT);
				this.isDragging = true;
				this.dispatchEventWith("beginInteraction");
				if(this._showThumb && this._trackInteractionMode === "byPage") {
					this.adjustPage();
					this.startRepeatTimer(this.adjustPage);
				} else {
					this.value = this._touchValue;
				}
			}
		}
		
		protected function thumb_touchHandler(event:TouchEvent) : void {
			var _local3:Touch = null;
			var _local2:ExclusiveTouch = null;
			var _local4:DisplayObject = null;
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
					_local2 = ExclusiveTouch.forStage(this.stage);
					_local4 = _local2.getClaim(this._touchPointID);
					if(_local4 != this) {
						if(_local4) {
							return;
						}
						_local2.claimTouch(this._touchPointID,this);
					}
					_local3.getLocation(this,HELPER_POINT);
					this.value = this.locationToValue(HELPER_POINT);
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
		
		protected function stage_keyDownHandler(event:KeyboardEvent) : void {
			if(event.keyCode == 36) {
				this.value = this._minimum;
				return;
			}
			if(event.keyCode == 35) {
				this.value = this._maximum;
				return;
			}
			var _local2:Number = this._page;
			if(_local2 !== _local2) {
				_local2 = this._step;
			}
			if(this._direction == "vertical") {
				if(event.keyCode == 38) {
					if(event.shiftKey) {
						this.value += _local2;
					} else {
						this.value += this._step;
					}
				} else if(event.keyCode == 40) {
					if(event.shiftKey) {
						this.value -= _local2;
					} else {
						this.value -= this._step;
					}
				}
			} else if(event.keyCode == 37) {
				if(event.shiftKey) {
					this.value -= _local2;
				} else {
					this.value -= this._step;
				}
			} else if(event.keyCode == 39) {
				if(event.shiftKey) {
					this.value += _local2;
				} else {
					this.value += this._step;
				}
			}
		}
		
		protected function repeatTimer_timerHandler(event:TimerEvent) : void {
			var _local2:ExclusiveTouch = ExclusiveTouch.forStage(this.stage);
			var _local3:DisplayObject = _local2.getClaim(this._touchPointID);
			if(_local3 && _local3 != this) {
				return;
			}
			if(this._repeatTimer.currentCount < 5) {
				return;
			}
			this.currentRepeatAction();
		}
	}
}

