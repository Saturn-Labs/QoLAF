package feathers.controls {
	import feathers.controls.supportClasses.IViewPort;
	import feathers.core.FeathersControl;
	import feathers.core.IFeathersControl;
	import feathers.core.IFocusDisplayObject;
	import feathers.core.IMeasureDisplayObject;
	import feathers.core.IValidating;
	import feathers.core.PropertyProxy;
	import feathers.events.ExclusiveTouch;
	import feathers.system.DeviceCapabilities;
	import feathers.utils.display.stageToStarling;
	import feathers.utils.math.roundDownToNearest;
	import feathers.utils.math.roundToNearest;
	import feathers.utils.math.roundUpToNearest;
	import feathers.utils.skins.resetFluidChildDimensionsForMeasurement;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.utils.MathUtil;
	
	public class Scroller extends FeathersControl implements IFocusDisplayObject {
		protected static const INVALIDATION_FLAG_SCROLL_BAR_RENDERER:String = "scrollBarRenderer";
		
		protected static const INVALIDATION_FLAG_PENDING_SCROLL:String = "pendingScroll";
		
		protected static const INVALIDATION_FLAG_PENDING_REVEAL_SCROLL_BARS:String = "pendingRevealScrollBars";
		
		public static const SCROLL_POLICY_AUTO:String = "auto";
		
		public static const SCROLL_POLICY_ON:String = "on";
		
		public static const SCROLL_POLICY_OFF:String = "off";
		
		public static const SCROLL_BAR_DISPLAY_MODE_FLOAT:String = "float";
		
		public static const SCROLL_BAR_DISPLAY_MODE_FIXED:String = "fixed";
		
		public static const SCROLL_BAR_DISPLAY_MODE_FIXED_FLOAT:String = "fixedFloat";
		
		public static const SCROLL_BAR_DISPLAY_MODE_NONE:String = "none";
		
		public static const VERTICAL_SCROLL_BAR_POSITION_RIGHT:String = "right";
		
		public static const VERTICAL_SCROLL_BAR_POSITION_LEFT:String = "left";
		
		public static const INTERACTION_MODE_TOUCH:String = "touch";
		
		public static const INTERACTION_MODE_MOUSE:String = "mouse";
		
		public static const INTERACTION_MODE_TOUCH_AND_SCROLL_BARS:String = "touchAndScrollBars";
		
		public static const MOUSE_WHEEL_SCROLL_DIRECTION_VERTICAL:String = "vertical";
		
		public static const MOUSE_WHEEL_SCROLL_DIRECTION_HORIZONTAL:String = "horizontal";
		
		protected static const INVALIDATION_FLAG_CLIPPING:String = "clipping";
		
		private static const MINIMUM_VELOCITY:Number = 0.02;
		
		private static const CURRENT_VELOCITY_WEIGHT:Number = 2.33;
		
		private static const MAXIMUM_SAVED_VELOCITY_COUNT:int = 4;
		
		public static const DECELERATION_RATE_NORMAL:Number = 0.998;
		
		public static const DECELERATION_RATE_FAST:Number = 0.99;
		
		public static const DEFAULT_CHILD_STYLE_NAME_HORIZONTAL_SCROLL_BAR:String = "feathers-scroller-horizontal-scroll-bar";
		
		public static const DEFAULT_CHILD_STYLE_NAME_VERTICAL_SCROLL_BAR:String = "feathers-scroller-vertical-scroll-bar";
		
		protected static const FUZZY_PAGE_SIZE_PADDING:Number = 0.000001;
		
		protected static const PAGE_INDEX_EPSILON:Number = 0.01;
		
		private static const HELPER_POINT:Point = new Point();
		
		private static const VELOCITY_WEIGHTS:Vector.<Number> = new <Number>[1,1.33,1.66,2];
		
		protected var horizontalScrollBarStyleName:String = "feathers-scroller-horizontal-scroll-bar";
		
		protected var verticalScrollBarStyleName:String = "feathers-scroller-vertical-scroll-bar";
		
		protected var horizontalScrollBar:IScrollBar;
		
		protected var verticalScrollBar:IScrollBar;
		
		protected var _topViewPortOffset:Number;
		
		protected var _rightViewPortOffset:Number;
		
		protected var _bottomViewPortOffset:Number;
		
		protected var _leftViewPortOffset:Number;
		
		protected var _hasHorizontalScrollBar:Boolean = false;
		
		protected var _hasVerticalScrollBar:Boolean = false;
		
		protected var _horizontalScrollBarTouchPointID:int = -1;
		
		protected var _verticalScrollBarTouchPointID:int = -1;
		
		protected var _touchPointID:int = -1;
		
		protected var _startTouchX:Number;
		
		protected var _startTouchY:Number;
		
		protected var _startHorizontalScrollPosition:Number;
		
		protected var _startVerticalScrollPosition:Number;
		
		protected var _currentTouchX:Number;
		
		protected var _currentTouchY:Number;
		
		protected var _previousTouchTime:int;
		
		protected var _previousTouchX:Number;
		
		protected var _previousTouchY:Number;
		
		protected var _velocityX:Number = 0;
		
		protected var _velocityY:Number = 0;
		
		protected var _previousVelocityX:Vector.<Number> = new Vector.<Number>(0);
		
		protected var _previousVelocityY:Vector.<Number> = new Vector.<Number>(0);
		
		protected var _lastViewPortWidth:Number = 0;
		
		protected var _lastViewPortHeight:Number = 0;
		
		protected var _hasViewPortBoundsChanged:Boolean = false;
		
		protected var _horizontalAutoScrollTween:Tween;
		
		protected var _verticalAutoScrollTween:Tween;
		
		protected var _isDraggingHorizontally:Boolean = false;
		
		protected var _isDraggingVertically:Boolean = false;
		
		protected var ignoreViewPortResizing:Boolean = false;
		
		protected var _touchBlocker:Quad;
		
		protected var _viewPort:IViewPort;
		
		protected var _explicitViewPortWidth:Number;
		
		protected var _explicitViewPortHeight:Number;
		
		protected var _explicitViewPortMinWidth:Number;
		
		protected var _explicitViewPortMinHeight:Number;
		
		protected var _measureViewPort:Boolean = true;
		
		protected var _snapToPages:Boolean = false;
		
		protected var _snapOnComplete:Boolean = false;
		
		protected var _horizontalScrollBarFactory:Function = defaultScrollBarFactory;
		
		protected var _customHorizontalScrollBarStyleName:String;
		
		protected var _horizontalScrollBarProperties:PropertyProxy;
		
		protected var _verticalScrollBarPosition:String = "right";
		
		protected var _verticalScrollBarFactory:Function = defaultScrollBarFactory;
		
		protected var _customVerticalScrollBarStyleName:String;
		
		protected var _verticalScrollBarProperties:PropertyProxy;
		
		protected var actualHorizontalScrollStep:Number = 1;
		
		protected var explicitHorizontalScrollStep:Number = NaN;
		
		protected var _targetHorizontalScrollPosition:Number;
		
		protected var _horizontalScrollPosition:Number = 0;
		
		protected var _minHorizontalScrollPosition:Number = 0;
		
		protected var _maxHorizontalScrollPosition:Number = 0;
		
		protected var _horizontalPageIndex:int = 0;
		
		protected var _minHorizontalPageIndex:int = 0;
		
		protected var _maxHorizontalPageIndex:int = 0;
		
		protected var _horizontalScrollPolicy:String = "auto";
		
		protected var actualVerticalScrollStep:Number = 1;
		
		protected var explicitVerticalScrollStep:Number = NaN;
		
		protected var _verticalMouseWheelScrollStep:Number = NaN;
		
		protected var _targetVerticalScrollPosition:Number;
		
		protected var _verticalScrollPosition:Number = 0;
		
		protected var _minVerticalScrollPosition:Number = 0;
		
		protected var _maxVerticalScrollPosition:Number = 0;
		
		protected var _verticalPageIndex:int = 0;
		
		protected var _minVerticalPageIndex:int = 0;
		
		protected var _maxVerticalPageIndex:int = 0;
		
		protected var _verticalScrollPolicy:String = "auto";
		
		protected var _clipContent:Boolean = true;
		
		protected var actualPageWidth:Number = 0;
		
		protected var explicitPageWidth:Number = NaN;
		
		protected var actualPageHeight:Number = 0;
		
		protected var explicitPageHeight:Number = NaN;
		
		protected var _hasElasticEdges:Boolean = true;
		
		protected var _elasticity:Number = 0.33;
		
		protected var _throwElasticity:Number = 0.05;
		
		protected var _scrollBarDisplayMode:String = "float";
		
		protected var _interactionMode:String = "touch";
		
		protected var _explicitBackgroundWidth:Number;
		
		protected var _explicitBackgroundHeight:Number;
		
		protected var _explicitBackgroundMinWidth:Number;
		
		protected var _explicitBackgroundMinHeight:Number;
		
		protected var _explicitBackgroundMaxWidth:Number;
		
		protected var _explicitBackgroundMaxHeight:Number;
		
		protected var currentBackgroundSkin:DisplayObject;
		
		protected var _backgroundSkin:DisplayObject;
		
		protected var _backgroundDisabledSkin:DisplayObject;
		
		protected var _autoHideBackground:Boolean = false;
		
		protected var _minimumDragDistance:Number = 0.04;
		
		protected var _minimumPageThrowVelocity:Number = 5;
		
		protected var _paddingTop:Number = 0;
		
		protected var _paddingRight:Number = 0;
		
		protected var _paddingBottom:Number = 0;
		
		protected var _paddingLeft:Number = 0;
		
		protected var _horizontalScrollBarHideTween:Tween;
		
		protected var _verticalScrollBarHideTween:Tween;
		
		protected var _hideScrollBarAnimationDuration:Number = 0.2;
		
		protected var _hideScrollBarAnimationEase:Object = "easeOut";
		
		protected var _elasticSnapDuration:Number = 0.5;
		
		protected var _logDecelerationRate:Number = -0.0020020026706730793;
		
		protected var _decelerationRate:Number = 0.998;
		
		protected var _fixedThrowDuration:Number = 2.996998998998728;
		
		protected var _useFixedThrowDuration:Boolean = true;
		
		protected var _pageThrowDuration:Number = 0.5;
		
		protected var _mouseWheelScrollDuration:Number = 0.35;
		
		protected var _verticalMouseWheelScrollDirection:String = "vertical";
		
		protected var _throwEase:Object = defaultThrowEase;
		
		protected var _snapScrollPositionsToPixels:Boolean = true;
		
		protected var _horizontalScrollBarIsScrolling:Boolean = false;
		
		protected var _verticalScrollBarIsScrolling:Boolean = false;
		
		protected var _isScrolling:Boolean = false;
		
		protected var _isScrollingStopped:Boolean = false;
		
		protected var pendingHorizontalScrollPosition:Number = NaN;
		
		protected var pendingVerticalScrollPosition:Number = NaN;
		
		protected var hasPendingHorizontalPageIndex:Boolean = false;
		
		protected var hasPendingVerticalPageIndex:Boolean = false;
		
		protected var pendingHorizontalPageIndex:int;
		
		protected var pendingVerticalPageIndex:int;
		
		protected var pendingScrollDuration:Number;
		
		protected var isScrollBarRevealPending:Boolean = false;
		
		protected var _revealScrollBarsDuration:Number = 1;
		
		protected var _horizontalAutoScrollTweenEndRatio:Number = 1;
		
		protected var _verticalAutoScrollTweenEndRatio:Number = 1;
		
		public function Scroller() {
			super();
			this.addEventListener("addedToStage",scroller_addedToStageHandler);
			this.addEventListener("removedFromStage",scroller_removedFromStageHandler);
		}
		
		protected static function defaultScrollBarFactory() : IScrollBar {
			return new SimpleScrollBar();
		}
		
		protected static function defaultThrowEase(ratio:Number) : Number {
			ratio -= 1;
			return 1 - ratio * ratio * ratio * ratio;
		}
		
		override public function get isFocusEnabled() : Boolean {
			return (this._maxVerticalScrollPosition != this._minVerticalScrollPosition || this._maxHorizontalScrollPosition != this._minHorizontalScrollPosition) && super.isFocusEnabled;
		}
		
		public function get viewPort() : IViewPort {
			return this._viewPort;
		}
		
		public function set viewPort(value:IViewPort) : void {
			if(this._viewPort == value) {
				return;
			}
			if(this._viewPort !== null) {
				this._viewPort.removeEventListener("resize",viewPort_resizeHandler);
				this.removeRawChildInternal(DisplayObject(this._viewPort));
			}
			this._viewPort = value;
			if(this._viewPort !== null) {
				this._viewPort.addEventListener("resize",viewPort_resizeHandler);
				this.addRawChildAtInternal(DisplayObject(this._viewPort),0);
				if(this._viewPort is IFeathersControl) {
					IFeathersControl(this._viewPort).initializeNow();
				}
				this._explicitViewPortWidth = this._viewPort.explicitWidth;
				this._explicitViewPortHeight = this._viewPort.explicitHeight;
				this._explicitViewPortMinWidth = this._viewPort.explicitMinWidth;
				this._explicitViewPortMinHeight = this._viewPort.explicitMinHeight;
			}
			this.invalidate("size");
		}
		
		public function get measureViewPort() : Boolean {
			return this._measureViewPort;
		}
		
		public function set measureViewPort(value:Boolean) : void {
			if(this._measureViewPort == value) {
				return;
			}
			this._measureViewPort = value;
			this.invalidate("size");
		}
		
		public function get snapToPages() : Boolean {
			return this._snapToPages;
		}
		
		public function set snapToPages(value:Boolean) : void {
			if(this._snapToPages == value) {
				return;
			}
			this._snapToPages = value;
			this.invalidate("scroll");
		}
		
		public function get horizontalScrollBarFactory() : Function {
			return this._horizontalScrollBarFactory;
		}
		
		public function set horizontalScrollBarFactory(value:Function) : void {
			if(this._horizontalScrollBarFactory == value) {
				return;
			}
			this._horizontalScrollBarFactory = value;
			this.invalidate("scrollBarRenderer");
		}
		
		public function get customHorizontalScrollBarStyleName() : String {
			return this._customHorizontalScrollBarStyleName;
		}
		
		public function set customHorizontalScrollBarStyleName(value:String) : void {
			if(this._customHorizontalScrollBarStyleName == value) {
				return;
			}
			this._customHorizontalScrollBarStyleName = value;
			this.invalidate("scrollBarRenderer");
		}
		
		public function get horizontalScrollBarProperties() : Object {
			if(!this._horizontalScrollBarProperties) {
				this._horizontalScrollBarProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._horizontalScrollBarProperties;
		}
		
		public function set horizontalScrollBarProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._horizontalScrollBarProperties == value) {
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
			if(this._horizontalScrollBarProperties) {
				this._horizontalScrollBarProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._horizontalScrollBarProperties = PropertyProxy(value);
			if(this._horizontalScrollBarProperties) {
				this._horizontalScrollBarProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get verticalScrollBarPosition() : String {
			return this._verticalScrollBarPosition;
		}
		
		public function set verticalScrollBarPosition(value:String) : void {
			if(this._verticalScrollBarPosition == value) {
				return;
			}
			this._verticalScrollBarPosition = value;
			this.invalidate("styles");
		}
		
		public function get verticalScrollBarFactory() : Function {
			return this._verticalScrollBarFactory;
		}
		
		public function set verticalScrollBarFactory(value:Function) : void {
			if(this._verticalScrollBarFactory == value) {
				return;
			}
			this._verticalScrollBarFactory = value;
			this.invalidate("scrollBarRenderer");
		}
		
		public function get customVerticalScrollBarStyleName() : String {
			return this._customVerticalScrollBarStyleName;
		}
		
		public function set customVerticalScrollBarStyleName(value:String) : void {
			if(this._customVerticalScrollBarStyleName == value) {
				return;
			}
			this._customVerticalScrollBarStyleName = value;
			this.invalidate("scrollBarRenderer");
		}
		
		public function get verticalScrollBarProperties() : Object {
			if(!this._verticalScrollBarProperties) {
				this._verticalScrollBarProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._verticalScrollBarProperties;
		}
		
		public function set verticalScrollBarProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._horizontalScrollBarProperties == value) {
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
			if(this._verticalScrollBarProperties) {
				this._verticalScrollBarProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._verticalScrollBarProperties = PropertyProxy(value);
			if(this._verticalScrollBarProperties) {
				this._verticalScrollBarProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get horizontalScrollStep() : Number {
			return this.actualHorizontalScrollStep;
		}
		
		public function set horizontalScrollStep(value:Number) : void {
			if(this.explicitHorizontalScrollStep == value) {
				return;
			}
			this.explicitHorizontalScrollStep = value;
			this.invalidate("scroll");
		}
		
		public function get horizontalScrollPosition() : Number {
			return this._horizontalScrollPosition;
		}
		
		public function set horizontalScrollPosition(value:Number) : void {
			if(this._horizontalScrollPosition == value) {
				return;
			}
			if(value !== value) {
				throw new ArgumentError("horizontalScrollPosition cannot be NaN.");
			}
			this._horizontalScrollPosition = value;
			this.invalidate("scroll");
		}
		
		public function get minHorizontalScrollPosition() : Number {
			return this._minHorizontalScrollPosition;
		}
		
		public function get maxHorizontalScrollPosition() : Number {
			return this._maxHorizontalScrollPosition;
		}
		
		public function get horizontalPageIndex() : int {
			if(this.hasPendingHorizontalPageIndex) {
				return this.pendingHorizontalPageIndex;
			}
			return this._horizontalPageIndex;
		}
		
		public function get minHorizontalPageIndex() : int {
			return this._minHorizontalPageIndex;
		}
		
		public function get maxHorizontalPageIndex() : int {
			return this._maxHorizontalPageIndex;
		}
		
		public function get horizontalPageCount() : int {
			if(this._maxHorizontalPageIndex == 0x7fffffff || this._minHorizontalPageIndex == -2147483648) {
				return 0x7fffffff;
			}
			return this._maxHorizontalPageIndex - this._minHorizontalPageIndex + 1;
		}
		
		public function get horizontalScrollPolicy() : String {
			return this._horizontalScrollPolicy;
		}
		
		public function set horizontalScrollPolicy(value:String) : void {
			if(this._horizontalScrollPolicy == value) {
				return;
			}
			this._horizontalScrollPolicy = value;
			this.invalidate("scroll");
			this.invalidate("scrollBarRenderer");
		}
		
		public function get verticalScrollStep() : Number {
			return this.actualVerticalScrollStep;
		}
		
		public function set verticalScrollStep(value:Number) : void {
			if(this.explicitVerticalScrollStep == value) {
				return;
			}
			this.explicitVerticalScrollStep = value;
			this.invalidate("scroll");
		}
		
		public function get verticalMouseWheelScrollStep() : Number {
			return this._verticalMouseWheelScrollStep;
		}
		
		public function set verticalMouseWheelScrollStep(value:Number) : void {
			if(this._verticalMouseWheelScrollStep == value) {
				return;
			}
			this._verticalMouseWheelScrollStep = value;
			this.invalidate("scroll");
		}
		
		public function get verticalScrollPosition() : Number {
			return this._verticalScrollPosition;
		}
		
		public function set verticalScrollPosition(value:Number) : void {
			if(this._verticalScrollPosition == value) {
				return;
			}
			if(value !== value) {
				throw new ArgumentError("verticalScrollPosition cannot be NaN.");
			}
			this._verticalScrollPosition = value;
			this.invalidate("scroll");
		}
		
		public function get minVerticalScrollPosition() : Number {
			return this._minVerticalScrollPosition;
		}
		
		public function get maxVerticalScrollPosition() : Number {
			return this._maxVerticalScrollPosition;
		}
		
		public function get verticalPageIndex() : int {
			if(this.hasPendingVerticalPageIndex) {
				return this.pendingVerticalPageIndex;
			}
			return this._verticalPageIndex;
		}
		
		public function get minVerticalPageIndex() : int {
			return this._minVerticalPageIndex;
		}
		
		public function get maxVerticalPageIndex() : int {
			return this._maxVerticalPageIndex;
		}
		
		public function get verticalPageCount() : int {
			if(this._maxVerticalPageIndex == 0x7fffffff || this._minVerticalPageIndex == -2147483648) {
				return 0x7fffffff;
			}
			return this._maxVerticalPageIndex - this._minVerticalPageIndex + 1;
		}
		
		public function get verticalScrollPolicy() : String {
			return this._verticalScrollPolicy;
		}
		
		public function set verticalScrollPolicy(value:String) : void {
			if(this._verticalScrollPolicy == value) {
				return;
			}
			this._verticalScrollPolicy = value;
			this.invalidate("scroll");
			this.invalidate("scrollBarRenderer");
		}
		
		public function get clipContent() : Boolean {
			return this._clipContent;
		}
		
		public function set clipContent(value:Boolean) : void {
			if(this._clipContent == value) {
				return;
			}
			this._clipContent = value;
			if(!value && this._viewPort) {
				this._viewPort.mask = null;
			}
			this.invalidate("clipping");
		}
		
		public function get pageWidth() : Number {
			return this.actualPageWidth;
		}
		
		public function set pageWidth(value:Number) : void {
			if(this.explicitPageWidth == value) {
				return;
			}
			var _local2:* = value !== value;
			if(_local2 && this.explicitPageWidth !== this.explicitPageWidth) {
				return;
			}
			this.explicitPageWidth = value;
			if(_local2) {
				this.actualPageWidth = 0;
			} else {
				this.actualPageWidth = this.explicitPageWidth;
			}
		}
		
		public function get pageHeight() : Number {
			return this.actualPageHeight;
		}
		
		public function set pageHeight(value:Number) : void {
			if(this.explicitPageHeight == value) {
				return;
			}
			var _local2:* = value !== value;
			if(_local2 && this.explicitPageHeight !== this.explicitPageHeight) {
				return;
			}
			this.explicitPageHeight = value;
			if(_local2) {
				this.actualPageHeight = 0;
			} else {
				this.actualPageHeight = this.explicitPageHeight;
			}
		}
		
		public function get hasElasticEdges() : Boolean {
			return this._hasElasticEdges;
		}
		
		public function set hasElasticEdges(value:Boolean) : void {
			this._hasElasticEdges = value;
		}
		
		public function get elasticity() : Number {
			return this._elasticity;
		}
		
		public function set elasticity(value:Number) : void {
			this._elasticity = value;
		}
		
		public function get throwElasticity() : Number {
			return this._throwElasticity;
		}
		
		public function set throwElasticity(value:Number) : void {
			this._throwElasticity = value;
		}
		
		public function get scrollBarDisplayMode() : String {
			return this._scrollBarDisplayMode;
		}
		
		public function set scrollBarDisplayMode(value:String) : void {
			if(this._scrollBarDisplayMode == value) {
				return;
			}
			this._scrollBarDisplayMode = value;
			this.invalidate("styles");
		}
		
		public function get interactionMode() : String {
			return this._interactionMode;
		}
		
		public function set interactionMode(value:String) : void {
			if(this._interactionMode == value) {
				return;
			}
			this._interactionMode = value;
			this.invalidate("styles");
		}
		
		public function get backgroundSkin() : DisplayObject {
			return this._backgroundSkin;
		}
		
		public function set backgroundSkin(value:DisplayObject) : void {
			if(this._backgroundSkin == value) {
				return;
			}
			if(this._backgroundSkin && this.currentBackgroundSkin == this._backgroundSkin) {
				this.removeRawChildInternal(this._backgroundSkin);
				this.currentBackgroundSkin = null;
			}
			this._backgroundSkin = value;
			this.invalidate("styles");
		}
		
		public function get backgroundDisabledSkin() : DisplayObject {
			return this._backgroundDisabledSkin;
		}
		
		public function set backgroundDisabledSkin(value:DisplayObject) : void {
			if(this._backgroundDisabledSkin == value) {
				return;
			}
			if(this._backgroundDisabledSkin && this.currentBackgroundSkin == this._backgroundDisabledSkin) {
				this.removeRawChildInternal(this._backgroundDisabledSkin);
				this.currentBackgroundSkin = null;
			}
			this._backgroundDisabledSkin = value;
			this.invalidate("styles");
		}
		
		public function get autoHideBackground() : Boolean {
			return this._autoHideBackground;
		}
		
		public function set autoHideBackground(value:Boolean) : void {
			if(this._autoHideBackground == value) {
				return;
			}
			this._autoHideBackground = value;
			this.invalidate("styles");
		}
		
		public function get minimumDragDistance() : Number {
			return this._minimumDragDistance;
		}
		
		public function set minimumDragDistance(value:Number) : void {
			this._minimumDragDistance = value;
		}
		
		public function get minimumPageThrowVelocity() : Number {
			return this._minimumPageThrowVelocity;
		}
		
		public function set minimumPageThrowVelocity(value:Number) : void {
			this._minimumPageThrowVelocity = value;
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
		
		public function get hideScrollBarAnimationDuration() : Number {
			return this._hideScrollBarAnimationDuration;
		}
		
		public function set hideScrollBarAnimationDuration(value:Number) : void {
			this._hideScrollBarAnimationDuration = value;
		}
		
		public function get hideScrollBarAnimationEase() : Object {
			return this._hideScrollBarAnimationEase;
		}
		
		public function set hideScrollBarAnimationEase(value:Object) : void {
			this._hideScrollBarAnimationEase = value;
		}
		
		public function get elasticSnapDuration() : Number {
			return this._elasticSnapDuration;
		}
		
		public function set elasticSnapDuration(value:Number) : void {
			this._elasticSnapDuration = value;
		}
		
		public function get decelerationRate() : Number {
			return this._decelerationRate;
		}
		
		public function set decelerationRate(value:Number) : void {
			if(this._decelerationRate == value) {
				return;
			}
			this._decelerationRate = value;
			this._logDecelerationRate = Math.log(this._decelerationRate);
			this._fixedThrowDuration = -0.1 / Math.log(Math.pow(this._decelerationRate,16.666666666666668));
		}
		
		public function get useFixedThrowDuration() : Boolean {
			return this._useFixedThrowDuration;
		}
		
		public function set useFixedThrowDuration(value:Boolean) : void {
			this._useFixedThrowDuration = value;
		}
		
		public function get pageThrowDuration() : Number {
			return this._pageThrowDuration;
		}
		
		public function set pageThrowDuration(value:Number) : void {
			this._pageThrowDuration = value;
		}
		
		public function get mouseWheelScrollDuration() : Number {
			return this._mouseWheelScrollDuration;
		}
		
		public function set mouseWheelScrollDuration(value:Number) : void {
			this._mouseWheelScrollDuration = value;
		}
		
		public function get verticalMouseWheelScrollDirection() : String {
			return this._verticalMouseWheelScrollDirection;
		}
		
		public function set verticalMouseWheelScrollDirection(value:String) : void {
			this._verticalMouseWheelScrollDirection = value;
		}
		
		public function get throwEase() : Object {
			return this._throwEase;
		}
		
		public function set throwEase(value:Object) : void {
			if(value == null) {
				value = defaultThrowEase;
			}
			this._throwEase = value;
		}
		
		public function get snapScrollPositionsToPixels() : Boolean {
			return this._snapScrollPositionsToPixels;
		}
		
		public function set snapScrollPositionsToPixels(value:Boolean) : void {
			if(this._snapScrollPositionsToPixels == value) {
				return;
			}
			this._snapScrollPositionsToPixels = value;
			this.invalidate("scroll");
		}
		
		public function get isScrolling() : Boolean {
			return this._isScrolling;
		}
		
		public function get revealScrollBarsDuration() : Number {
			return this._revealScrollBarsDuration;
		}
		
		public function set revealScrollBarsDuration(value:Number) : void {
			this._revealScrollBarsDuration = value;
		}
		
		override public function dispose() : void {
			Starling.current.nativeStage.removeEventListener("mouseWheel",nativeStage_mouseWheelHandler);
			Starling.current.nativeStage.removeEventListener("orientationChange",nativeStage_orientationChangeHandler);
			if(this._backgroundSkin && this._backgroundSkin.parent !== this) {
				this._backgroundSkin.dispose();
			}
			if(this._backgroundDisabledSkin && this._backgroundDisabledSkin.parent !== this) {
				this._backgroundDisabledSkin.dispose();
			}
			super.dispose();
		}
		
		public function stopScrolling() : void {
			if(this._horizontalAutoScrollTween) {
				Starling.juggler.remove(this._horizontalAutoScrollTween);
				this._horizontalAutoScrollTween = null;
			}
			if(this._verticalAutoScrollTween) {
				Starling.juggler.remove(this._verticalAutoScrollTween);
				this._verticalAutoScrollTween = null;
			}
			this._isScrollingStopped = true;
			this._velocityX = 0;
			this._velocityY = 0;
			this._previousVelocityX.length = 0;
			this._previousVelocityY.length = 0;
			this.hideHorizontalScrollBar();
			this.hideVerticalScrollBar();
		}
		
		public function scrollToPosition(horizontalScrollPosition:Number, verticalScrollPosition:Number, animationDuration:Number = NaN) : void {
			if(animationDuration !== animationDuration) {
				if(this._useFixedThrowDuration) {
					animationDuration = this._fixedThrowDuration;
				} else {
					HELPER_POINT.setTo(horizontalScrollPosition - this._horizontalScrollPosition,verticalScrollPosition - this._verticalScrollPosition);
					animationDuration = this.calculateDynamicThrowDuration(HELPER_POINT.length * this._logDecelerationRate + 0.02);
				}
			}
			this.hasPendingHorizontalPageIndex = false;
			this.hasPendingVerticalPageIndex = false;
			if(this.pendingHorizontalScrollPosition == horizontalScrollPosition && this.pendingVerticalScrollPosition == verticalScrollPosition && this.pendingScrollDuration == animationDuration) {
				return;
			}
			this.pendingHorizontalScrollPosition = horizontalScrollPosition;
			this.pendingVerticalScrollPosition = verticalScrollPosition;
			this.pendingScrollDuration = animationDuration;
			this.invalidate("pendingScroll");
		}
		
		public function scrollToPageIndex(horizontalPageIndex:int, verticalPageIndex:int, animationDuration:Number = NaN) : void {
			if(animationDuration !== animationDuration) {
				animationDuration = this._pageThrowDuration;
			}
			this.pendingHorizontalScrollPosition = NaN;
			this.pendingVerticalScrollPosition = NaN;
			this.hasPendingHorizontalPageIndex = this._horizontalPageIndex !== horizontalPageIndex;
			this.hasPendingVerticalPageIndex = this._verticalPageIndex !== verticalPageIndex;
			if(!this.hasPendingHorizontalPageIndex && !this.hasPendingVerticalPageIndex) {
				return;
			}
			this.pendingHorizontalPageIndex = horizontalPageIndex;
			this.pendingVerticalPageIndex = verticalPageIndex;
			this.pendingScrollDuration = animationDuration;
			this.invalidate("pendingScroll");
		}
		
		public function revealScrollBars() : void {
			this.isScrollBarRevealPending = true;
			this.invalidate("pendingRevealScrollBars");
		}
		
		override public function hitTest(localPoint:Point) : DisplayObject {
			var _local4:Number = localPoint.x;
			var _local3:Number = localPoint.y;
			var _local2:DisplayObject = super.hitTest(localPoint);
			if(!_local2) {
				if(!this.visible || !this.touchable) {
					return null;
				}
				return this._hitArea.contains(_local4,_local3) ? this : null;
			}
			return _local2;
		}
		
		override protected function draw() : void {
			var _local1:Boolean = this.isInvalid("size");
			var _local7:Boolean = this.isInvalid("data");
			var _local11:Boolean = this.isInvalid("scroll");
			var _local10:Boolean = this.isInvalid("clipping");
			var _local8:Boolean = this.isInvalid("styles");
			var _local3:Boolean = this.isInvalid("state");
			var _local9:Boolean = this.isInvalid("scrollBarRenderer");
			var _local12:Boolean = this.isInvalid("pendingScroll");
			var _local2:Boolean = this.isInvalid("pendingRevealScrollBars");
			if(_local9) {
				this.createScrollBars();
			}
			if(_local1 || _local8 || _local3) {
				this.refreshBackgroundSkin();
			}
			if(_local9 || _local8) {
				this.refreshScrollBarStyles();
				this.refreshInteractionModeEvents();
			}
			if(_local9 || _local3) {
				this.refreshEnabled();
			}
			if(this.horizontalScrollBar) {
				this.horizontalScrollBar.validate();
			}
			if(this.verticalScrollBar) {
				this.verticalScrollBar.validate();
			}
			var _local4:Number = this._maxHorizontalScrollPosition;
			var _local6:Number = this._maxVerticalScrollPosition;
			var _local5:Boolean = _local11 && this._viewPort.requiresMeasurementOnScroll || _local7 || _local1 || _local8 || _local9;
			this.refreshViewPort(_local5);
			if(_local4 != this._maxHorizontalScrollPosition) {
				this.refreshHorizontalAutoScrollTweenEndRatio();
				_local11 = true;
			}
			if(_local6 != this._maxVerticalScrollPosition) {
				this.refreshVerticalAutoScrollTweenEndRatio();
				_local11 = true;
			}
			if(_local11) {
				this.dispatchEventWith("scroll");
			}
			this.showOrHideChildren();
			this.layoutChildren();
			if(_local11 || _local1 || _local8 || _local9) {
				this.refreshScrollBarValues();
			}
			if(_local5 || _local11 || _local10) {
				this.refreshMask();
			}
			this.refreshFocusIndicator();
			if(_local12) {
				this.handlePendingScroll();
			}
			if(_local2) {
				this.handlePendingRevealScrollBars();
			}
		}
		
		protected function refreshViewPort(measure:Boolean) : void {
			this._viewPort.horizontalScrollPosition = this._horizontalScrollPosition;
			this._viewPort.verticalScrollPosition = this._verticalScrollPosition;
			if(!measure) {
				this._viewPort.validate();
				this.refreshScrollValues();
				return;
			}
			var _local2:int = 0;
			do {
				this._hasViewPortBoundsChanged = false;
				if(this._measureViewPort) {
					this.calculateViewPortOffsets(true,false);
					this.refreshViewPortBoundsForMeasurement();
				}
				this.calculateViewPortOffsets(false,false);
				this.autoSizeIfNeeded();
				this.calculateViewPortOffsets(false,true);
				this.refreshViewPortBoundsForLayout();
				this.refreshScrollValues();
				_local2++;
				if(_local2 >= 10) {
					break;
				}
			}
			while(this._hasViewPortBoundsChanged);
			
			this._lastViewPortWidth = this._viewPort.width;
			this._lastViewPortHeight = this._viewPort.height;
		}
		
		protected function autoSizeIfNeeded() : Boolean {
			var _local3:* = this._explicitWidth !== this._explicitWidth;
			var _local7:* = this._explicitHeight !== this._explicitHeight;
			var _local4:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local9:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local3 && !_local7 && !_local4 && !_local9) {
				return false;
			}
			resetFluidChildDimensionsForMeasurement(this.currentBackgroundSkin,this._explicitWidth,this._explicitHeight,this._explicitMinWidth,this._explicitMinHeight,this._explicitMaxWidth,this._explicitMaxHeight,this._explicitBackgroundWidth,this._explicitBackgroundHeight,this._explicitBackgroundMinWidth,this._explicitBackgroundMinHeight,this._explicitBackgroundMaxWidth,this._explicitBackgroundMaxHeight);
			var _local8:IMeasureDisplayObject = this.currentBackgroundSkin as IMeasureDisplayObject;
			if(this.currentBackgroundSkin is IValidating) {
				IValidating(this.currentBackgroundSkin).validate();
			}
			var _local2:Number = this._explicitWidth;
			var _local5:Number = this._explicitHeight;
			var _local1:Number = this._explicitMinWidth;
			var _local6:Number = this._explicitMinHeight;
			if(_local3) {
				if(this._measureViewPort) {
					_local2 = this._viewPort.visibleWidth;
				} else {
					_local2 = 0;
				}
				_local2 += this._rightViewPortOffset + this._leftViewPortOffset;
				if(this.currentBackgroundSkin !== null && this.currentBackgroundSkin.width > _local2) {
					_local2 = this.currentBackgroundSkin.width;
				}
			}
			if(_local7) {
				if(this._measureViewPort) {
					_local5 = this._viewPort.visibleHeight;
				} else {
					_local5 = 0;
				}
				_local5 += this._bottomViewPortOffset + this._topViewPortOffset;
				if(this.currentBackgroundSkin !== null && this.currentBackgroundSkin.height > _local5) {
					_local5 = this.currentBackgroundSkin.height;
				}
			}
			if(_local4) {
				if(this._measureViewPort) {
					_local1 = this._viewPort.minVisibleWidth;
				} else {
					_local1 = 0;
				}
				_local1 += this._rightViewPortOffset + this._leftViewPortOffset;
				switch(_local8) {
					default:
						if(_local8.minWidth > _local1) {
							_local1 = _local8.minWidth;
						}
						break;
					case null:
						if(this._explicitBackgroundMinWidth > _local1) {
							_local1 = this._explicitBackgroundMinWidth;
						}
						break;
					case null:
				}
			}
			if(_local9) {
				if(this._measureViewPort) {
					_local6 = this._viewPort.minVisibleHeight;
				} else {
					_local6 = 0;
				}
				_local6 += this._bottomViewPortOffset + this._topViewPortOffset;
				switch(_local8) {
					default:
						if(_local8.minHeight > _local6) {
							_local6 = _local8.minHeight;
						}
						break;
					case null:
						if(this._explicitBackgroundMinHeight > _local6) {
							_local6 = this._explicitBackgroundMinHeight;
						}
						break;
					case null:
				}
			}
			return this.saveMeasurements(_local2,_local5,_local1,_local6);
		}
		
		protected function createScrollBars() : void {
			var _local1:String = null;
			var _local2:String = null;
			if(this.horizontalScrollBar) {
				this.horizontalScrollBar.removeEventListener("beginInteraction",horizontalScrollBar_beginInteractionHandler);
				this.horizontalScrollBar.removeEventListener("endInteraction",horizontalScrollBar_endInteractionHandler);
				this.horizontalScrollBar.removeEventListener("change",horizontalScrollBar_changeHandler);
				this.removeRawChildInternal(DisplayObject(this.horizontalScrollBar),true);
				this.horizontalScrollBar = null;
			}
			if(this.verticalScrollBar) {
				this.verticalScrollBar.removeEventListener("beginInteraction",verticalScrollBar_beginInteractionHandler);
				this.verticalScrollBar.removeEventListener("endInteraction",verticalScrollBar_endInteractionHandler);
				this.verticalScrollBar.removeEventListener("change",verticalScrollBar_changeHandler);
				this.removeRawChildInternal(DisplayObject(this.verticalScrollBar),true);
				this.verticalScrollBar = null;
			}
			if(this._scrollBarDisplayMode != "none" && this._horizontalScrollPolicy != "off" && this._horizontalScrollBarFactory != null) {
				this.horizontalScrollBar = IScrollBar(this._horizontalScrollBarFactory());
				if(this.horizontalScrollBar is IDirectionalScrollBar) {
					IDirectionalScrollBar(this.horizontalScrollBar).direction = "horizontal";
				}
				_local1 = this._customHorizontalScrollBarStyleName != null ? this._customHorizontalScrollBarStyleName : this.horizontalScrollBarStyleName;
				this.horizontalScrollBar.styleNameList.add(_local1);
				this.horizontalScrollBar.addEventListener("change",horizontalScrollBar_changeHandler);
				this.horizontalScrollBar.addEventListener("beginInteraction",horizontalScrollBar_beginInteractionHandler);
				this.horizontalScrollBar.addEventListener("endInteraction",horizontalScrollBar_endInteractionHandler);
				this.addRawChildInternal(DisplayObject(this.horizontalScrollBar));
			}
			if(this._scrollBarDisplayMode != "none" && this._verticalScrollPolicy != "off" && this._verticalScrollBarFactory != null) {
				this.verticalScrollBar = IScrollBar(this._verticalScrollBarFactory());
				if(this.verticalScrollBar is IDirectionalScrollBar) {
					IDirectionalScrollBar(this.verticalScrollBar).direction = "vertical";
				}
				_local2 = this._customVerticalScrollBarStyleName != null ? this._customVerticalScrollBarStyleName : this.verticalScrollBarStyleName;
				this.verticalScrollBar.styleNameList.add(_local2);
				this.verticalScrollBar.addEventListener("change",verticalScrollBar_changeHandler);
				this.verticalScrollBar.addEventListener("beginInteraction",verticalScrollBar_beginInteractionHandler);
				this.verticalScrollBar.addEventListener("endInteraction",verticalScrollBar_endInteractionHandler);
				this.addRawChildInternal(DisplayObject(this.verticalScrollBar));
			}
		}
		
		protected function refreshBackgroundSkin() : void {
			var _local2:IMeasureDisplayObject = null;
			var _local1:DisplayObject = this._backgroundSkin;
			if(!this._isEnabled && this._backgroundDisabledSkin) {
				_local1 = this._backgroundDisabledSkin;
			}
			if(this.currentBackgroundSkin != _local1) {
				if(this.currentBackgroundSkin) {
					this.removeRawChildInternal(this.currentBackgroundSkin);
				}
				this.currentBackgroundSkin = _local1;
				if(this.currentBackgroundSkin !== null) {
					this.addRawChildAtInternal(this.currentBackgroundSkin,0);
					if(this.currentBackgroundSkin is IFeathersControl) {
						IFeathersControl(this.currentBackgroundSkin).initializeNow();
					}
					if(this.currentBackgroundSkin is IMeasureDisplayObject) {
						_local2 = IMeasureDisplayObject(this.currentBackgroundSkin);
						this._explicitBackgroundWidth = _local2.explicitWidth;
						this._explicitBackgroundHeight = _local2.explicitHeight;
						this._explicitBackgroundMinWidth = _local2.explicitMinWidth;
						this._explicitBackgroundMinHeight = _local2.explicitMinHeight;
						this._explicitBackgroundMaxWidth = _local2.explicitMaxWidth;
						this._explicitBackgroundMaxHeight = _local2.explicitMaxHeight;
					} else {
						this._explicitBackgroundWidth = this.currentBackgroundSkin.width;
						this._explicitBackgroundHeight = this.currentBackgroundSkin.height;
						this._explicitBackgroundMinWidth = this._explicitBackgroundWidth;
						this._explicitBackgroundMinHeight = this._explicitBackgroundHeight;
						this._explicitBackgroundMaxWidth = this._explicitBackgroundWidth;
						this._explicitBackgroundMaxHeight = this._explicitBackgroundHeight;
					}
				}
			}
			if(this.currentBackgroundSkin !== null) {
				this.setRawChildIndexInternal(this.currentBackgroundSkin,0);
			}
		}
		
		protected function refreshScrollBarStyles() : void {
			var _local2:Object = null;
			if(this.horizontalScrollBar) {
				for(var _local1 in this._horizontalScrollBarProperties) {
					_local2 = this._horizontalScrollBarProperties[_local1];
					this.horizontalScrollBar[_local1] = _local2;
				}
				if(this._horizontalScrollBarHideTween) {
					Starling.juggler.remove(this._horizontalScrollBarHideTween);
					this._horizontalScrollBarHideTween = null;
				}
				this.horizontalScrollBar.alpha = this._scrollBarDisplayMode == "float" ? 0 : 1;
			}
			if(this.verticalScrollBar) {
				for(_local1 in this._verticalScrollBarProperties) {
					_local2 = this._verticalScrollBarProperties[_local1];
					this.verticalScrollBar[_local1] = _local2;
				}
				if(this._verticalScrollBarHideTween) {
					Starling.juggler.remove(this._verticalScrollBarHideTween);
					this._verticalScrollBarHideTween = null;
				}
				this.verticalScrollBar.alpha = this._scrollBarDisplayMode == "float" ? 0 : 1;
			}
		}
		
		protected function refreshEnabled() : void {
			if(this._viewPort) {
				this._viewPort.isEnabled = this._isEnabled;
			}
			if(this.horizontalScrollBar) {
				this.horizontalScrollBar.isEnabled = this._isEnabled;
			}
			if(this.verticalScrollBar) {
				this.verticalScrollBar.isEnabled = this._isEnabled;
			}
		}
		
		override protected function refreshFocusIndicator() : void {
			if(this._focusIndicatorSkin) {
				if(this._hasFocus && this._showFocus) {
					if(this._focusIndicatorSkin.parent != this) {
						this.addRawChildInternal(this._focusIndicatorSkin);
					} else {
						this.setRawChildIndexInternal(this._focusIndicatorSkin,this.numRawChildrenInternal - 1);
					}
				} else if(this._focusIndicatorSkin.parent == this) {
					this.removeRawChildInternal(this._focusIndicatorSkin,false);
				}
				this._focusIndicatorSkin.x = this._focusPaddingLeft;
				this._focusIndicatorSkin.y = this._focusPaddingTop;
				this._focusIndicatorSkin.width = this.actualWidth - this._focusPaddingLeft - this._focusPaddingRight;
				this._focusIndicatorSkin.height = this.actualHeight - this._focusPaddingTop - this._focusPaddingBottom;
			}
		}
		
		protected function refreshViewPortBoundsForMeasurement() : void {
			var _local4:Number = NaN;
			var _local8:Number = NaN;
			var _local2:Number = this._leftViewPortOffset + this._rightViewPortOffset;
			var _local1:Number = this._topViewPortOffset + this._bottomViewPortOffset;
			resetFluidChildDimensionsForMeasurement(this.currentBackgroundSkin,this._explicitWidth,this._explicitHeight,this._explicitMinWidth,this._explicitMinHeight,this._explicitMaxWidth,this._explicitMaxHeight,this._explicitBackgroundWidth,this._explicitBackgroundHeight,this._explicitBackgroundMinWidth,this._explicitBackgroundMinHeight,this._explicitBackgroundMaxWidth,this._explicitBackgroundMaxHeight);
			var _local5:IMeasureDisplayObject = this.currentBackgroundSkin as IMeasureDisplayObject;
			if(this.currentBackgroundSkin is IValidating) {
				IValidating(this.currentBackgroundSkin).validate();
			}
			var _local3:* = this._explicitMinWidth;
			if(_local3 !== _local3 || this._explicitViewPortMinWidth > _local3) {
				_local3 = this._explicitViewPortMinWidth;
			}
			if(_local3 !== _local3 || this._explicitWidth > _local3) {
				_local3 = this._explicitWidth;
			}
			switch(_local5) {
				default:
					_local4 = _local5.minWidth;
				case null:
					if(_local3 !== _local3 || _local4 > _local3) {
						_local3 = _local4;
					}
					break;
				case null:
			}
			_local3 -= _local2;
			var _local7:* = this._explicitMinHeight;
			if(_local7 !== _local7 || this._explicitViewPortMinHeight > _local7) {
				_local7 = this._explicitViewPortMinHeight;
			}
			if(_local7 !== _local7 || this._explicitHeight > _local7) {
				_local7 = this._explicitHeight;
			}
			switch(_local5) {
				default:
					_local8 = _local5.minHeight;
				case null:
					if(_local7 !== _local7 || _local8 > _local7) {
						_local7 = _local8;
					}
					break;
				case null:
			}
			_local7 -= _local1;
			var _local6:Boolean = this.ignoreViewPortResizing;
			this.ignoreViewPortResizing = true;
			this._viewPort.visibleWidth = this._explicitWidth - _local2;
			this._viewPort.minVisibleWidth = this._explicitMinWidth - _local2;
			this._viewPort.maxVisibleWidth = this._explicitMaxWidth - _local2;
			this._viewPort.minWidth = _local3;
			this._viewPort.visibleHeight = this._explicitHeight - _local1;
			this._viewPort.minVisibleHeight = this._explicitMinHeight - _local1;
			this._viewPort.maxVisibleHeight = this._explicitMaxHeight - _local1;
			this._viewPort.minHeight = _local7;
			this._viewPort.validate();
			this.ignoreViewPortResizing = _local6;
		}
		
		protected function refreshViewPortBoundsForLayout() : void {
			var _local2:Number = this._leftViewPortOffset + this._rightViewPortOffset;
			var _local1:Number = this._topViewPortOffset + this._bottomViewPortOffset;
			var _local5:Boolean = this.ignoreViewPortResizing;
			this.ignoreViewPortResizing = true;
			var _local3:Number = this.actualWidth - _local2;
			if(this._viewPort.visibleWidth !== _local3) {
				this._viewPort.visibleWidth = _local3;
			}
			this._viewPort.minVisibleWidth = this.actualWidth - _local2;
			this._viewPort.maxVisibleWidth = this._explicitMaxWidth - _local2;
			this._viewPort.minWidth = _local3;
			var _local4:Number = this.actualHeight - _local1;
			if(this._viewPort.visibleHeight !== _local4) {
				this._viewPort.visibleHeight = _local4;
			}
			this._viewPort.minVisibleHeight = this.actualMinHeight - _local1;
			this._viewPort.maxVisibleHeight = this._explicitMaxHeight - _local1;
			this._viewPort.minHeight = _local4;
			this.ignoreViewPortResizing = _local5;
			this._viewPort.validate();
		}
		
		protected function refreshScrollValues() : void {
			this.refreshScrollSteps();
			var _local2:Number = this._maxHorizontalScrollPosition;
			var _local3:Number = this._maxVerticalScrollPosition;
			this.refreshMinAndMaxScrollPositions();
			var _local1:Boolean = this._maxHorizontalScrollPosition != _local2 || this._maxVerticalScrollPosition != _local3;
			if(_local1 && this._touchPointID < 0) {
				this.clampScrollPositions();
			}
			this.refreshPageCount();
			this.refreshPageIndices();
		}
		
		protected function clampScrollPositions() : void {
			var _local1:Number = NaN;
			var _local2:Number = NaN;
			if(!this._horizontalAutoScrollTween) {
				if(this._snapToPages) {
					this._horizontalScrollPosition = roundToNearest(this._horizontalScrollPosition,this.actualPageWidth);
				}
				_local1 = this._horizontalScrollPosition;
				if(_local1 < this._minHorizontalScrollPosition) {
					_local1 = this._minHorizontalScrollPosition;
				} else if(_local1 > this._maxHorizontalScrollPosition) {
					_local1 = this._maxHorizontalScrollPosition;
				}
				this.horizontalScrollPosition = _local1;
			}
			if(!this._verticalAutoScrollTween) {
				if(this._snapToPages) {
					this._verticalScrollPosition = roundToNearest(this._verticalScrollPosition,this.actualPageHeight);
				}
				_local2 = this._verticalScrollPosition;
				if(_local2 < this._minVerticalScrollPosition) {
					_local2 = this._minVerticalScrollPosition;
				} else if(_local2 > this._maxVerticalScrollPosition) {
					_local2 = this._maxVerticalScrollPosition;
				}
				this.verticalScrollPosition = _local2;
			}
		}
		
		protected function refreshScrollSteps() : void {
			if(this.explicitHorizontalScrollStep !== this.explicitHorizontalScrollStep) {
				if(this._viewPort) {
					this.actualHorizontalScrollStep = this._viewPort.horizontalScrollStep;
				} else {
					this.actualHorizontalScrollStep = 1;
				}
			} else {
				this.actualHorizontalScrollStep = this.explicitHorizontalScrollStep;
			}
			if(this.explicitVerticalScrollStep !== this.explicitVerticalScrollStep) {
				if(this._viewPort) {
					this.actualVerticalScrollStep = this._viewPort.verticalScrollStep;
				} else {
					this.actualVerticalScrollStep = 1;
				}
			} else {
				this.actualVerticalScrollStep = this.explicitVerticalScrollStep;
			}
		}
		
		protected function refreshMinAndMaxScrollPositions() : void {
			var _local1:Number = this.actualWidth - (this._leftViewPortOffset + this._rightViewPortOffset);
			var _local2:Number = this.actualHeight - (this._topViewPortOffset + this._bottomViewPortOffset);
			if(this.explicitPageWidth !== this.explicitPageWidth) {
				this.actualPageWidth = _local1;
			}
			if(this.explicitPageHeight !== this.explicitPageHeight) {
				this.actualPageHeight = _local2;
			}
			if(this._viewPort) {
				this._minHorizontalScrollPosition = this._viewPort.contentX;
				if(this._viewPort.width == Infinity) {
					this._maxHorizontalScrollPosition = Infinity;
				} else {
					this._maxHorizontalScrollPosition = this._minHorizontalScrollPosition + this._viewPort.width - _local1;
				}
				if(this._maxHorizontalScrollPosition < this._minHorizontalScrollPosition) {
					this._maxHorizontalScrollPosition = this._minHorizontalScrollPosition;
				}
				this._minVerticalScrollPosition = this._viewPort.contentY;
				if(this._viewPort.height == Infinity) {
					this._maxVerticalScrollPosition = Infinity;
				} else {
					this._maxVerticalScrollPosition = this._minVerticalScrollPosition + this._viewPort.height - _local2;
				}
				if(this._maxVerticalScrollPosition < this._minVerticalScrollPosition) {
					this._maxVerticalScrollPosition = this._minVerticalScrollPosition;
				}
			} else {
				this._minHorizontalScrollPosition = 0;
				this._minVerticalScrollPosition = 0;
				this._maxHorizontalScrollPosition = 0;
				this._maxVerticalScrollPosition = 0;
			}
		}
		
		protected function refreshPageCount() : void {
			var _local1:* = NaN;
			var _local2:Number = NaN;
			var _local3:* = NaN;
			if(this._snapToPages) {
				_local1 = this._maxHorizontalScrollPosition - this._minHorizontalScrollPosition;
				if(_local1 == Infinity) {
					if(this._minHorizontalScrollPosition == -Infinity) {
						this._minHorizontalPageIndex = -2147483648;
					} else {
						this._minHorizontalPageIndex = 0;
					}
					this._maxHorizontalPageIndex = 0x7fffffff;
				} else {
					this._minHorizontalPageIndex = 0;
					_local2 = roundDownToNearest(_local1,this.actualPageWidth);
					if(_local1 - _local2 < 0.000001) {
						_local1 = _local2;
					}
					this._maxHorizontalPageIndex = Math.ceil(_local1 / this.actualPageWidth);
				}
				_local3 = this._maxVerticalScrollPosition - this._minVerticalScrollPosition;
				if(_local3 == Infinity) {
					if(this._minVerticalScrollPosition == -Infinity) {
						this._minVerticalPageIndex = -2147483648;
					} else {
						this._minVerticalPageIndex = 0;
					}
					this._maxVerticalPageIndex = 0x7fffffff;
				} else {
					this._minVerticalPageIndex = 0;
					_local2 = roundDownToNearest(_local3,this.actualPageHeight);
					if(_local3 - _local2 < 0.000001) {
						_local3 = _local2;
					}
					this._maxVerticalPageIndex = Math.ceil(_local3 / this.actualPageHeight);
				}
			} else {
				this._maxHorizontalPageIndex = 0;
				this._maxHorizontalPageIndex = 0;
				this._minVerticalPageIndex = 0;
				this._maxVerticalPageIndex = 0;
			}
		}
		
		protected function refreshPageIndices() : void {
			var _local3:Number = NaN;
			var _local2:Number = NaN;
			var _local1:int = 0;
			var _local4:Number = NaN;
			if(!this._horizontalAutoScrollTween && !this.hasPendingHorizontalPageIndex) {
				if(this._snapToPages) {
					if(this._horizontalScrollPosition == this._maxHorizontalScrollPosition) {
						this._horizontalPageIndex = this._maxHorizontalPageIndex;
					} else if(this._horizontalScrollPosition == this._minHorizontalScrollPosition) {
						this._horizontalPageIndex = this._minHorizontalPageIndex;
					} else {
						if(this._minHorizontalScrollPosition == -Infinity && this._horizontalScrollPosition < 0) {
							_local3 = this._horizontalScrollPosition / this.actualPageWidth;
						} else if(this._maxHorizontalScrollPosition == Infinity && this._horizontalScrollPosition >= 0) {
							_local3 = this._horizontalScrollPosition / this.actualPageWidth;
						} else {
							_local2 = this._horizontalScrollPosition - this._minHorizontalScrollPosition;
							_local3 = _local2 / this.actualPageWidth;
						}
						_local1 = Math.round(_local3);
						if(_local3 !== _local1 && MathUtil.isEquivalent(_local3,_local1,0.01)) {
							this._horizontalPageIndex = _local1;
						} else {
							this._horizontalPageIndex = Math.floor(_local3);
						}
					}
				} else {
					this._horizontalPageIndex = this._minHorizontalPageIndex;
				}
				if(this._horizontalPageIndex < this._minHorizontalPageIndex) {
					this._horizontalPageIndex = this._minHorizontalPageIndex;
				}
				if(this._horizontalPageIndex > this._maxHorizontalPageIndex) {
					this._horizontalPageIndex = this._maxHorizontalPageIndex;
				}
			}
			if(!this._verticalAutoScrollTween && !this.hasPendingVerticalPageIndex) {
				if(this._snapToPages) {
					if(this._verticalScrollPosition == this._maxVerticalScrollPosition) {
						this._verticalPageIndex = this._maxVerticalPageIndex;
					} else if(this._verticalScrollPosition == this._minVerticalScrollPosition) {
						this._verticalPageIndex = this._minVerticalPageIndex;
					} else {
						if(this._minVerticalScrollPosition == -Infinity && this._verticalScrollPosition < 0) {
							_local3 = this._verticalScrollPosition / this.actualPageHeight;
						} else if(this._maxVerticalScrollPosition == Infinity && this._verticalScrollPosition >= 0) {
							_local3 = this._verticalScrollPosition / this.actualPageHeight;
						} else {
							_local4 = this._verticalScrollPosition - this._minVerticalScrollPosition;
							_local3 = _local4 / this.actualPageHeight;
						}
						_local1 = Math.round(_local3);
						if(_local3 !== _local1 && MathUtil.isEquivalent(_local3,_local1,0.01)) {
							this._verticalPageIndex = _local1;
						} else {
							this._verticalPageIndex = Math.floor(_local3);
						}
					}
				} else {
					this._verticalPageIndex = this._minVerticalScrollPosition;
				}
				if(this._verticalPageIndex < this._minVerticalScrollPosition) {
					this._verticalPageIndex = this._minVerticalScrollPosition;
				}
				if(this._verticalPageIndex > this._maxVerticalPageIndex) {
					this._verticalPageIndex = this._maxVerticalPageIndex;
				}
			}
		}
		
		protected function refreshScrollBarValues() : void {
			if(this.horizontalScrollBar) {
				this.horizontalScrollBar.minimum = this._minHorizontalScrollPosition;
				this.horizontalScrollBar.maximum = this._maxHorizontalScrollPosition;
				this.horizontalScrollBar.value = this._horizontalScrollPosition;
				this.horizontalScrollBar.page = (this._maxHorizontalScrollPosition - this._minHorizontalScrollPosition) * this.actualPageWidth / this._viewPort.width;
				this.horizontalScrollBar.step = this.actualHorizontalScrollStep;
			}
			if(this.verticalScrollBar) {
				this.verticalScrollBar.minimum = this._minVerticalScrollPosition;
				this.verticalScrollBar.maximum = this._maxVerticalScrollPosition;
				this.verticalScrollBar.value = this._verticalScrollPosition;
				this.verticalScrollBar.page = (this._maxVerticalScrollPosition - this._minVerticalScrollPosition) * this.actualPageHeight / this._viewPort.height;
				this.verticalScrollBar.step = this.actualVerticalScrollStep;
			}
		}
		
		protected function showOrHideChildren() : void {
			var _local1:int = this.numRawChildrenInternal;
			if(this._touchBlocker !== null && this._touchBlocker.parent !== null) {
				_local1--;
			}
			if(this.verticalScrollBar) {
				this.verticalScrollBar.visible = this._hasVerticalScrollBar;
				this.verticalScrollBar.touchable = this._hasVerticalScrollBar && this._interactionMode != "touch";
				this.setRawChildIndexInternal(DisplayObject(this.verticalScrollBar),_local1 - 1);
			}
			if(this.horizontalScrollBar) {
				this.horizontalScrollBar.visible = this._hasHorizontalScrollBar;
				this.horizontalScrollBar.touchable = this._hasHorizontalScrollBar && this._interactionMode != "touch";
				if(this.verticalScrollBar) {
					this.setRawChildIndexInternal(DisplayObject(this.horizontalScrollBar),_local1 - 2);
				} else {
					this.setRawChildIndexInternal(DisplayObject(this.horizontalScrollBar),_local1 - 1);
				}
			}
			if(this.currentBackgroundSkin) {
				if(this._autoHideBackground) {
					this.currentBackgroundSkin.visible = this._viewPort.width <= this.actualWidth || this._viewPort.height <= this.actualHeight || this._horizontalScrollPosition < 0 || this._horizontalScrollPosition > this._maxHorizontalScrollPosition || this._verticalScrollPosition < 0 || this._verticalScrollPosition > this._maxVerticalScrollPosition;
				} else {
					this.currentBackgroundSkin.visible = true;
				}
			}
		}
		
		protected function calculateViewPortOffsetsForFixedHorizontalScrollBar(forceScrollBars:Boolean = false, useActualBounds:Boolean = false) : void {
			var _local3:Number = NaN;
			var _local4:Number = NaN;
			if(this.horizontalScrollBar && (this._measureViewPort || useActualBounds)) {
				_local3 = useActualBounds ? this.actualWidth : this._explicitWidth;
				_local4 = this._viewPort.width + this._leftViewPortOffset + this._rightViewPortOffset;
				if(forceScrollBars || this._horizontalScrollPolicy == "on" || (_local4 > _local3 || _local4 > this._explicitMaxWidth) && this._horizontalScrollPolicy != "off") {
					this._hasHorizontalScrollBar = true;
					if(this._scrollBarDisplayMode == "fixed") {
						this._bottomViewPortOffset += this.horizontalScrollBar.height;
					}
				} else {
					this._hasHorizontalScrollBar = false;
				}
			} else {
				this._hasHorizontalScrollBar = false;
			}
		}
		
		protected function calculateViewPortOffsetsForFixedVerticalScrollBar(forceScrollBars:Boolean = false, useActualBounds:Boolean = false) : void {
			var _local4:Number = NaN;
			var _local3:Number = NaN;
			if(this.verticalScrollBar && (this._measureViewPort || useActualBounds)) {
				_local4 = useActualBounds ? this.actualHeight : this._explicitHeight;
				_local3 = this._viewPort.height + this._topViewPortOffset + this._bottomViewPortOffset;
				if(forceScrollBars || this._verticalScrollPolicy == "on" || (_local3 > _local4 || _local3 > this._explicitMaxHeight) && this._verticalScrollPolicy != "off") {
					this._hasVerticalScrollBar = true;
					if(this._scrollBarDisplayMode == "fixed") {
						if(this._verticalScrollBarPosition == "left") {
							this._leftViewPortOffset += this.verticalScrollBar.width;
						} else {
							this._rightViewPortOffset += this.verticalScrollBar.width;
						}
					}
				} else {
					this._hasVerticalScrollBar = false;
				}
			} else {
				this._hasVerticalScrollBar = false;
			}
		}
		
		protected function calculateViewPortOffsets(forceScrollBars:Boolean = false, useActualBounds:Boolean = false) : void {
			this._topViewPortOffset = this._paddingTop;
			this._rightViewPortOffset = this._paddingRight;
			this._bottomViewPortOffset = this._paddingBottom;
			this._leftViewPortOffset = this._paddingLeft;
			this.calculateViewPortOffsetsForFixedHorizontalScrollBar(forceScrollBars,useActualBounds);
			this.calculateViewPortOffsetsForFixedVerticalScrollBar(forceScrollBars,useActualBounds);
			if(this._scrollBarDisplayMode == "fixed" && this._hasVerticalScrollBar && !this._hasHorizontalScrollBar) {
				this.calculateViewPortOffsetsForFixedHorizontalScrollBar(forceScrollBars,useActualBounds);
			}
		}
		
		protected function refreshInteractionModeEvents() : void {
			if(this._interactionMode == "touch" || this._interactionMode == "touchAndScrollBars") {
				this.addEventListener("touch",scroller_touchHandler);
				if(!this._touchBlocker) {
					this._touchBlocker = new Quad(100,100,0xff00ff);
					this._touchBlocker.alpha = 0;
				}
			} else {
				this.removeEventListener("touch",scroller_touchHandler);
				if(this._touchBlocker) {
					this.removeRawChildInternal(this._touchBlocker,true);
					this._touchBlocker = null;
				}
			}
			if((this._interactionMode == "mouse" || this._interactionMode == "touchAndScrollBars") && this._scrollBarDisplayMode == "float") {
				if(this.horizontalScrollBar) {
					this.horizontalScrollBar.addEventListener("touch",horizontalScrollBar_touchHandler);
				}
				if(this.verticalScrollBar) {
					this.verticalScrollBar.addEventListener("touch",verticalScrollBar_touchHandler);
				}
			} else {
				if(this.horizontalScrollBar) {
					this.horizontalScrollBar.removeEventListener("touch",horizontalScrollBar_touchHandler);
				}
				if(this.verticalScrollBar) {
					this.verticalScrollBar.removeEventListener("touch",verticalScrollBar_touchHandler);
				}
			}
		}
		
		protected function layoutChildren() : void {
			var _local1:Starling = null;
			var _local4:Number = NaN;
			var _local2:Number = this.actualWidth - this._leftViewPortOffset - this._rightViewPortOffset;
			var _local3:Number = this.actualHeight - this._topViewPortOffset - this._bottomViewPortOffset;
			if(this.currentBackgroundSkin !== null) {
				this.currentBackgroundSkin.width = this.actualWidth;
				this.currentBackgroundSkin.height = this.actualHeight;
			}
			if(this.horizontalScrollBar !== null) {
				this.horizontalScrollBar.validate();
			}
			if(this.verticalScrollBar !== null) {
				this.verticalScrollBar.validate();
			}
			if(this._touchBlocker !== null) {
				this._touchBlocker.x = this._leftViewPortOffset;
				this._touchBlocker.y = this._topViewPortOffset;
				this._touchBlocker.width = _local2;
				this._touchBlocker.height = _local3;
			}
			if(this._snapScrollPositionsToPixels) {
				_local1 = stageToStarling(this.stage);
				if(_local1 === null) {
					_local1 = Starling.current;
				}
				_local4 = 1 / _local1.contentScaleFactor;
				this._viewPort.x = Math.round((this._leftViewPortOffset - this._horizontalScrollPosition) / _local4) * _local4;
				this._viewPort.y = Math.round((this._topViewPortOffset - this._verticalScrollPosition) / _local4) * _local4;
			} else {
				this._viewPort.x = this._leftViewPortOffset - this._horizontalScrollPosition;
				this._viewPort.y = this._topViewPortOffset - this._verticalScrollPosition;
			}
			if(this.horizontalScrollBar !== null) {
				this.horizontalScrollBar.x = this._leftViewPortOffset;
				this.horizontalScrollBar.y = this._topViewPortOffset + _local3;
				if(this._scrollBarDisplayMode !== "fixed") {
					this.horizontalScrollBar.y -= this.horizontalScrollBar.height;
					if((this._hasVerticalScrollBar || this._verticalScrollBarHideTween) && this.verticalScrollBar) {
						this.horizontalScrollBar.width = _local2 - this.verticalScrollBar.width;
					} else {
						this.horizontalScrollBar.width = _local2;
					}
				} else {
					this.horizontalScrollBar.width = _local2;
				}
			}
			if(this.verticalScrollBar !== null) {
				if(this._verticalScrollBarPosition === "left") {
					this.verticalScrollBar.x = this._paddingLeft;
				} else {
					this.verticalScrollBar.x = this._leftViewPortOffset + _local2;
				}
				this.verticalScrollBar.y = this._topViewPortOffset;
				if(this._scrollBarDisplayMode !== "fixed") {
					this.verticalScrollBar.x -= this.verticalScrollBar.width;
					if((this._hasHorizontalScrollBar || this._horizontalScrollBarHideTween) && this.horizontalScrollBar) {
						this.verticalScrollBar.height = _local3 - this.horizontalScrollBar.height;
					} else {
						this.verticalScrollBar.height = _local3;
					}
				} else {
					this.verticalScrollBar.height = _local3;
				}
			}
		}
		
		protected function refreshMask() : void {
			if(!this._clipContent) {
				return;
			}
			var _local1:Number = this.actualWidth - this._leftViewPortOffset - this._rightViewPortOffset;
			if(_local1 < 0) {
				_local1 = 0;
			}
			var _local2:Number = this.actualHeight - this._topViewPortOffset - this._bottomViewPortOffset;
			if(_local2 < 0) {
				_local2 = 0;
			}
			var _local3:Quad = this._viewPort.mask as Quad;
			if(!_local3) {
				_local3 = new Quad(1,1,0xff0ff);
				this._viewPort.mask = _local3;
			}
			_local3.x = this._horizontalScrollPosition;
			_local3.y = this._verticalScrollPosition;
			_local3.width = _local1;
			_local3.height = _local2;
		}
		
		protected function get numRawChildrenInternal() : int {
			if(this is IScrollContainer) {
				return IScrollContainer(this).numRawChildren;
			}
			return this.numChildren;
		}
		
		protected function addRawChildInternal(child:DisplayObject) : DisplayObject {
			if(this is IScrollContainer) {
				return IScrollContainer(this).addRawChild(child);
			}
			return this.addChild(child);
		}
		
		protected function addRawChildAtInternal(child:DisplayObject, index:int) : DisplayObject {
			if(this is IScrollContainer) {
				return IScrollContainer(this).addRawChildAt(child,index);
			}
			return this.addChildAt(child,index);
		}
		
		protected function removeRawChildInternal(child:DisplayObject, dispose:Boolean = false) : DisplayObject {
			if(this is IScrollContainer) {
				return IScrollContainer(this).removeRawChild(child,dispose);
			}
			return this.removeChild(child,dispose);
		}
		
		protected function removeRawChildAtInternal(index:int, dispose:Boolean = false) : DisplayObject {
			if(this is IScrollContainer) {
				return IScrollContainer(this).removeRawChildAt(index,dispose);
			}
			return this.removeChildAt(index,dispose);
		}
		
		protected function setRawChildIndexInternal(child:DisplayObject, index:int) : void {
			if(this is IScrollContainer) {
				IScrollContainer(this).setRawChildIndex(child,index);
				return;
			}
			this.setChildIndex(child,index);
		}
		
		protected function updateHorizontalScrollFromTouchPosition(touchX:Number) : void {
			var _local2:Number = this._startTouchX - touchX;
			var _local3:Number = this._startHorizontalScrollPosition + _local2;
			if(_local3 < this._minHorizontalScrollPosition) {
				if(this._hasElasticEdges) {
					_local3 -= (_local3 - this._minHorizontalScrollPosition) * (1 - this._elasticity);
				} else {
					_local3 = this._minHorizontalScrollPosition;
				}
			} else if(_local3 > this._maxHorizontalScrollPosition) {
				if(this._hasElasticEdges) {
					_local3 -= (_local3 - this._maxHorizontalScrollPosition) * (1 - this._elasticity);
				} else {
					_local3 = this._maxHorizontalScrollPosition;
				}
			}
			this.horizontalScrollPosition = _local3;
		}
		
		protected function updateVerticalScrollFromTouchPosition(touchY:Number) : void {
			var _local2:Number = this._startTouchY - touchY;
			var _local3:Number = this._startVerticalScrollPosition + _local2;
			if(_local3 < this._minVerticalScrollPosition) {
				if(this._hasElasticEdges) {
					_local3 -= (_local3 - this._minVerticalScrollPosition) * (1 - this._elasticity);
				} else {
					_local3 = this._minVerticalScrollPosition;
				}
			} else if(_local3 > this._maxVerticalScrollPosition) {
				if(this._hasElasticEdges) {
					_local3 -= (_local3 - this._maxVerticalScrollPosition) * (1 - this._elasticity);
				} else {
					_local3 = this._maxVerticalScrollPosition;
				}
			}
			this.verticalScrollPosition = _local3;
		}
		
		protected function throwTo(targetHorizontalScrollPosition:Number = NaN, targetVerticalScrollPosition:Number = NaN, duration:Number = 0.5) : void {
			var _local4:Boolean = false;
			if(targetHorizontalScrollPosition === targetHorizontalScrollPosition) {
				if(this._snapToPages && targetHorizontalScrollPosition > this._minHorizontalScrollPosition && targetHorizontalScrollPosition < this._maxHorizontalScrollPosition) {
					targetHorizontalScrollPosition = roundToNearest(targetHorizontalScrollPosition,this.actualPageWidth);
				}
				if(this._horizontalAutoScrollTween) {
					Starling.juggler.remove(this._horizontalAutoScrollTween);
					this._horizontalAutoScrollTween = null;
				}
				if(this._horizontalScrollPosition != targetHorizontalScrollPosition) {
					_local4 = true;
					this.revealHorizontalScrollBar();
					this.startScroll();
					if(duration == 0) {
						this.horizontalScrollPosition = targetHorizontalScrollPosition;
					} else {
						this._startHorizontalScrollPosition = this._horizontalScrollPosition;
						this._targetHorizontalScrollPosition = targetHorizontalScrollPosition;
						this._horizontalAutoScrollTween = new Tween(this,duration,this._throwEase);
						this._horizontalAutoScrollTween.animate("horizontalScrollPosition",targetHorizontalScrollPosition);
						this._horizontalAutoScrollTween.onComplete = horizontalAutoScrollTween_onComplete;
						Starling.juggler.add(this._horizontalAutoScrollTween);
						this.refreshHorizontalAutoScrollTweenEndRatio();
					}
				} else {
					this.finishScrollingHorizontally();
				}
			}
			if(targetVerticalScrollPosition === targetVerticalScrollPosition) {
				if(this._snapToPages && targetVerticalScrollPosition > this._minVerticalScrollPosition && targetVerticalScrollPosition < this._maxVerticalScrollPosition) {
					targetVerticalScrollPosition = roundToNearest(targetVerticalScrollPosition,this.actualPageHeight);
				}
				if(this._verticalAutoScrollTween) {
					Starling.juggler.remove(this._verticalAutoScrollTween);
					this._verticalAutoScrollTween = null;
				}
				if(this._verticalScrollPosition != targetVerticalScrollPosition) {
					_local4 = true;
					this.revealVerticalScrollBar();
					this.startScroll();
					if(duration == 0) {
						this.verticalScrollPosition = targetVerticalScrollPosition;
					} else {
						this._startVerticalScrollPosition = this._verticalScrollPosition;
						this._targetVerticalScrollPosition = targetVerticalScrollPosition;
						this._verticalAutoScrollTween = new Tween(this,duration,this._throwEase);
						this._verticalAutoScrollTween.animate("verticalScrollPosition",targetVerticalScrollPosition);
						this._verticalAutoScrollTween.onComplete = verticalAutoScrollTween_onComplete;
						Starling.juggler.add(this._verticalAutoScrollTween);
						this.refreshVerticalAutoScrollTweenEndRatio();
					}
				} else {
					this.finishScrollingVertically();
				}
			}
			if(_local4 && duration == 0) {
				this.completeScroll();
			}
		}
		
		protected function throwToPage(targetHorizontalPageIndex:int, targetVerticalPageIndex:int, duration:Number = 0.5) : void {
			var _local4:Number = this._horizontalScrollPosition;
			if(targetHorizontalPageIndex >= this._minHorizontalPageIndex) {
				_local4 = this.actualPageWidth * targetHorizontalPageIndex;
			}
			if(_local4 < this._minHorizontalScrollPosition) {
				_local4 = this._minHorizontalScrollPosition;
			}
			if(_local4 > this._maxHorizontalScrollPosition) {
				_local4 = this._maxHorizontalScrollPosition;
			}
			var _local5:Number = this._verticalScrollPosition;
			if(targetVerticalPageIndex >= this._minVerticalPageIndex) {
				_local5 = this.actualPageHeight * targetVerticalPageIndex;
			}
			if(_local5 < this._minVerticalScrollPosition) {
				_local5 = this._minVerticalScrollPosition;
			}
			if(_local5 > this._maxVerticalScrollPosition) {
				_local5 = this._maxVerticalScrollPosition;
			}
			if(duration > 0) {
				this.throwTo(_local4,_local5,duration);
			} else {
				this.horizontalScrollPosition = _local4;
				this.verticalScrollPosition = _local5;
			}
			if(targetHorizontalPageIndex >= this._minHorizontalPageIndex) {
				this._horizontalPageIndex = targetHorizontalPageIndex;
			}
			if(targetVerticalPageIndex >= this._minVerticalPageIndex) {
				this._verticalPageIndex = targetVerticalPageIndex;
			}
		}
		
		protected function calculateDynamicThrowDuration(pixelsPerMS:Number) : Number {
			return Math.log(0.02 / Math.abs(pixelsPerMS)) / this._logDecelerationRate / 1000;
		}
		
		protected function calculateThrowDistance(pixelsPerMS:Number) : Number {
			return (pixelsPerMS - 0.02) / this._logDecelerationRate;
		}
		
		protected function finishScrollingHorizontally() : void {
			var _local1:Number = NaN;
			if(this._horizontalScrollPosition < this._minHorizontalScrollPosition) {
				_local1 = this._minHorizontalScrollPosition;
			} else if(this._horizontalScrollPosition > this._maxHorizontalScrollPosition) {
				_local1 = this._maxHorizontalScrollPosition;
			}
			this._isDraggingHorizontally = false;
			if(_local1 !== _local1) {
				this.completeScroll();
			} else if(Math.abs(_local1 - this._horizontalScrollPosition) < 1) {
				this.horizontalScrollPosition = _local1;
				this.completeScroll();
			} else {
				this.throwTo(_local1,NaN,this._elasticSnapDuration);
			}
		}
		
		protected function finishScrollingVertically() : void {
			var _local1:Number = NaN;
			if(this._verticalScrollPosition < this._minVerticalScrollPosition) {
				_local1 = this._minVerticalScrollPosition;
			} else if(this._verticalScrollPosition > this._maxVerticalScrollPosition) {
				_local1 = this._maxVerticalScrollPosition;
			}
			this._isDraggingVertically = false;
			if(_local1 !== _local1) {
				this.completeScroll();
			} else if(Math.abs(_local1 - this._verticalScrollPosition) < 1) {
				this.verticalScrollPosition = _local1;
				this.completeScroll();
			} else {
				this.throwTo(NaN,_local1,this._elasticSnapDuration);
			}
		}
		
		protected function throwHorizontally(pixelsPerMS:Number) : void {
			var _local4:Number = NaN;
			var _local5:Number = NaN;
			var _local6:Number = NaN;
			var _local7:Number = NaN;
			var _local9:Number = NaN;
			var _local8:int = 0;
			if(this._snapToPages && !this._snapOnComplete) {
				_local4 = 1000 * pixelsPerMS / (DeviceCapabilities.dpi / Starling.contentScaleFactor);
				if(_local4 > this._minimumPageThrowVelocity) {
					_local5 = roundDownToNearest(this._horizontalScrollPosition,this.actualPageWidth);
				} else if(_local4 < -this._minimumPageThrowVelocity) {
					_local5 = roundUpToNearest(this._horizontalScrollPosition,this.actualPageWidth);
				} else {
					_local6 = this._maxHorizontalScrollPosition % this.actualPageWidth;
					_local7 = this._maxHorizontalScrollPosition - _local6;
					if(_local6 < this.actualPageWidth && this._horizontalScrollPosition >= _local7) {
						_local9 = this._horizontalScrollPosition - _local7;
						if(_local4 > this._minimumPageThrowVelocity) {
							_local5 = _local7 + roundDownToNearest(_local9,_local6);
						} else if(_local4 < -this._minimumPageThrowVelocity) {
							_local5 = _local7 + roundUpToNearest(_local9,_local6);
						} else {
							_local5 = _local7 + roundToNearest(_local9,_local6);
						}
					} else {
						_local5 = roundToNearest(this._horizontalScrollPosition,this.actualPageWidth);
					}
				}
				if(_local5 < this._minHorizontalScrollPosition) {
					_local5 = this._minHorizontalScrollPosition;
				} else if(_local5 > this._maxHorizontalScrollPosition) {
					_local5 = this._maxHorizontalScrollPosition;
				}
				if(_local5 == this._maxHorizontalScrollPosition) {
					_local8 = this._maxHorizontalPageIndex;
				} else if(this._minHorizontalScrollPosition == -Infinity) {
					_local8 = Math.round(_local5 / this.actualPageWidth);
				} else {
					_local8 = Math.round((_local5 - this._minHorizontalScrollPosition) / this.actualPageWidth);
				}
				this.throwToPage(_local8,-1,this._pageThrowDuration);
				return;
			}
			var _local3:Number = Math.abs(pixelsPerMS);
			if(!this._snapToPages && _local3 <= 0.02) {
				this.finishScrollingHorizontally();
				return;
			}
			var _local2:Number = this._fixedThrowDuration;
			if(!this._useFixedThrowDuration) {
				_local2 = this.calculateDynamicThrowDuration(pixelsPerMS);
			}
			this.throwTo(this._horizontalScrollPosition + this.calculateThrowDistance(pixelsPerMS),NaN,_local2);
		}
		
		protected function throwVertically(pixelsPerMS:Number) : void {
			var _local4:Number = NaN;
			var _local6:Number = NaN;
			var _local9:Number = NaN;
			var _local5:Number = NaN;
			var _local7:Number = NaN;
			var _local8:int = 0;
			if(this._snapToPages && !this._snapOnComplete) {
				_local4 = 1000 * pixelsPerMS / (DeviceCapabilities.dpi / Starling.contentScaleFactor);
				if(_local4 > this._minimumPageThrowVelocity) {
					_local6 = roundDownToNearest(this._verticalScrollPosition,this.actualPageHeight);
				} else if(_local4 < -this._minimumPageThrowVelocity) {
					_local6 = roundUpToNearest(this._verticalScrollPosition,this.actualPageHeight);
				} else {
					_local9 = this._maxVerticalScrollPosition % this.actualPageHeight;
					_local5 = this._maxVerticalScrollPosition - _local9;
					if(_local9 < this.actualPageHeight && this._verticalScrollPosition >= _local5) {
						_local7 = this._verticalScrollPosition - _local5;
						if(_local4 > this._minimumPageThrowVelocity) {
							_local6 = _local5 + roundDownToNearest(_local7,_local9);
						} else if(_local4 < -this._minimumPageThrowVelocity) {
							_local6 = _local5 + roundUpToNearest(_local7,_local9);
						} else {
							_local6 = _local5 + roundToNearest(_local7,_local9);
						}
					} else {
						_local6 = roundToNearest(this._verticalScrollPosition,this.actualPageHeight);
					}
				}
				if(_local6 < this._minVerticalScrollPosition) {
					_local6 = this._minVerticalScrollPosition;
				} else if(_local6 > this._maxVerticalScrollPosition) {
					_local6 = this._maxVerticalScrollPosition;
				}
				if(_local6 == this._maxVerticalScrollPosition) {
					_local8 = this._maxVerticalPageIndex;
				} else if(this._minVerticalScrollPosition == -Infinity) {
					_local8 = Math.round(_local6 / this.actualPageHeight);
				} else {
					_local8 = Math.round((_local6 - this._minVerticalScrollPosition) / this.actualPageHeight);
				}
				this.throwToPage(-1,_local8,this._pageThrowDuration);
				return;
			}
			var _local3:Number = Math.abs(pixelsPerMS);
			if(!this._snapToPages && _local3 <= 0.02) {
				this.finishScrollingVertically();
				return;
			}
			var _local2:Number = this._fixedThrowDuration;
			if(!this._useFixedThrowDuration) {
				_local2 = this.calculateDynamicThrowDuration(pixelsPerMS);
			}
			this.throwTo(NaN,this._verticalScrollPosition + this.calculateThrowDistance(pixelsPerMS),_local2);
		}
		
		protected function onHorizontalAutoScrollTweenUpdate() : void {
			var _local1:Number = this._horizontalAutoScrollTween.transitionFunc(this._horizontalAutoScrollTween.currentTime / this._horizontalAutoScrollTween.totalTime);
			if(_local1 >= this._horizontalAutoScrollTweenEndRatio) {
				if(!this._hasElasticEdges) {
					if(this._horizontalScrollPosition < this._minHorizontalScrollPosition) {
						this._horizontalScrollPosition = this._minHorizontalScrollPosition;
					} else if(this._horizontalScrollPosition > this._maxHorizontalScrollPosition) {
						this._horizontalScrollPosition = this._maxHorizontalScrollPosition;
					}
				}
				Starling.juggler.remove(this._horizontalAutoScrollTween);
				this._horizontalAutoScrollTween = null;
				this.finishScrollingHorizontally();
			}
		}
		
		protected function onVerticalAutoScrollTweenUpdate() : void {
			var _local1:Number = this._verticalAutoScrollTween.transitionFunc(this._verticalAutoScrollTween.currentTime / this._verticalAutoScrollTween.totalTime);
			if(_local1 >= this._verticalAutoScrollTweenEndRatio) {
				if(!this._hasElasticEdges) {
					if(this._verticalScrollPosition < this._minVerticalScrollPosition) {
						this._verticalScrollPosition = this._minVerticalScrollPosition;
					} else if(this._verticalScrollPosition > this._maxVerticalScrollPosition) {
						this._verticalScrollPosition = this._maxVerticalScrollPosition;
					}
				}
				Starling.juggler.remove(this._verticalAutoScrollTween);
				this._verticalAutoScrollTween = null;
				this.finishScrollingVertically();
			}
		}
		
		protected function refreshHorizontalAutoScrollTweenEndRatio() : void {
			var _local2:Number = Math.abs(this._targetHorizontalScrollPosition - this._startHorizontalScrollPosition);
			var _local1:Number = 0;
			if(this._targetHorizontalScrollPosition > this._maxHorizontalScrollPosition) {
				_local1 = (this._targetHorizontalScrollPosition - this._maxHorizontalScrollPosition) / _local2;
			} else if(this._targetHorizontalScrollPosition < this._minHorizontalScrollPosition) {
				_local1 = (this._minHorizontalScrollPosition - this._targetHorizontalScrollPosition) / _local2;
			}
			if(_local1 > 0) {
				if(this._hasElasticEdges) {
					this._horizontalAutoScrollTweenEndRatio = 1 - _local1 + _local1 * this._throwElasticity;
				} else {
					this._horizontalAutoScrollTweenEndRatio = 1 - _local1;
				}
			} else {
				this._horizontalAutoScrollTweenEndRatio = 1;
			}
			if(this._horizontalAutoScrollTween) {
				if(this._horizontalAutoScrollTweenEndRatio < 1) {
					this._horizontalAutoScrollTween.onUpdate = onHorizontalAutoScrollTweenUpdate;
				} else {
					this._horizontalAutoScrollTween.onUpdate = null;
				}
			}
		}
		
		protected function refreshVerticalAutoScrollTweenEndRatio() : void {
			var _local2:Number = Math.abs(this._targetVerticalScrollPosition - this._startVerticalScrollPosition);
			var _local1:Number = 0;
			if(this._targetVerticalScrollPosition > this._maxVerticalScrollPosition) {
				_local1 = (this._targetVerticalScrollPosition - this._maxVerticalScrollPosition) / _local2;
			} else if(this._targetVerticalScrollPosition < this._minVerticalScrollPosition) {
				_local1 = (this._minVerticalScrollPosition - this._targetVerticalScrollPosition) / _local2;
			}
			if(_local1 > 0) {
				if(this._hasElasticEdges) {
					this._verticalAutoScrollTweenEndRatio = 1 - _local1 + _local1 * this._throwElasticity;
				} else {
					this._verticalAutoScrollTweenEndRatio = 1 - _local1;
				}
			} else {
				this._verticalAutoScrollTweenEndRatio = 1;
			}
			if(this._verticalAutoScrollTween) {
				if(this._verticalAutoScrollTweenEndRatio < 1) {
					this._verticalAutoScrollTween.onUpdate = onVerticalAutoScrollTweenUpdate;
				} else {
					this._verticalAutoScrollTween.onUpdate = null;
				}
			}
		}
		
		protected function hideHorizontalScrollBar(delay:Number = 0) : void {
			if(!this.horizontalScrollBar || this._scrollBarDisplayMode != "float" || this._horizontalScrollBarHideTween) {
				return;
			}
			if(this.horizontalScrollBar.alpha == 0) {
				return;
			}
			if(this._hideScrollBarAnimationDuration == 0 && delay == 0) {
				this.horizontalScrollBar.alpha = 0;
			} else {
				this._horizontalScrollBarHideTween = new Tween(this.horizontalScrollBar,this._hideScrollBarAnimationDuration,this._hideScrollBarAnimationEase);
				this._horizontalScrollBarHideTween.fadeTo(0);
				this._horizontalScrollBarHideTween.delay = delay;
				this._horizontalScrollBarHideTween.onComplete = horizontalScrollBarHideTween_onComplete;
				Starling.juggler.add(this._horizontalScrollBarHideTween);
			}
		}
		
		protected function hideVerticalScrollBar(delay:Number = 0) : void {
			if(!this.verticalScrollBar || this._scrollBarDisplayMode != "float" || this._verticalScrollBarHideTween) {
				return;
			}
			if(this.verticalScrollBar.alpha == 0) {
				return;
			}
			if(this._hideScrollBarAnimationDuration == 0 && delay == 0) {
				this.verticalScrollBar.alpha = 0;
			} else {
				this._verticalScrollBarHideTween = new Tween(this.verticalScrollBar,this._hideScrollBarAnimationDuration,this._hideScrollBarAnimationEase);
				this._verticalScrollBarHideTween.fadeTo(0);
				this._verticalScrollBarHideTween.delay = delay;
				this._verticalScrollBarHideTween.onComplete = verticalScrollBarHideTween_onComplete;
				Starling.juggler.add(this._verticalScrollBarHideTween);
			}
		}
		
		protected function revealHorizontalScrollBar() : void {
			if(!this.horizontalScrollBar || this._scrollBarDisplayMode != "float") {
				return;
			}
			if(this._horizontalScrollBarHideTween) {
				Starling.juggler.remove(this._horizontalScrollBarHideTween);
				this._horizontalScrollBarHideTween = null;
			}
			this.horizontalScrollBar.alpha = 1;
		}
		
		protected function revealVerticalScrollBar() : void {
			if(!this.verticalScrollBar || this._scrollBarDisplayMode != "float") {
				return;
			}
			if(this._verticalScrollBarHideTween) {
				Starling.juggler.remove(this._verticalScrollBarHideTween);
				this._verticalScrollBarHideTween = null;
			}
			this.verticalScrollBar.alpha = 1;
		}
		
		protected function startScroll() : void {
			if(this._isScrolling) {
				return;
			}
			this._isScrolling = true;
			if(this._touchBlocker) {
				this.addRawChildInternal(this._touchBlocker);
			}
			this.dispatchEventWith("scrollStart");
		}
		
		protected function completeScroll() : void {
			if(!this._isScrolling || this._verticalAutoScrollTween || this._horizontalAutoScrollTween || this._isDraggingHorizontally || this._isDraggingVertically || this._horizontalScrollBarIsScrolling || this._verticalScrollBarIsScrolling) {
				return;
			}
			this._isScrolling = false;
			if(this._touchBlocker) {
				this.removeRawChildInternal(this._touchBlocker,false);
			}
			this.hideHorizontalScrollBar();
			this.hideVerticalScrollBar();
			this.validate();
			this.dispatchEventWith("scrollComplete");
		}
		
		protected function handlePendingScroll() : void {
			if(this.pendingHorizontalScrollPosition === this.pendingHorizontalScrollPosition || this.pendingVerticalScrollPosition === this.pendingVerticalScrollPosition) {
				this.throwTo(this.pendingHorizontalScrollPosition,this.pendingVerticalScrollPosition,this.pendingScrollDuration);
				this.pendingHorizontalScrollPosition = NaN;
				this.pendingVerticalScrollPosition = NaN;
			}
			if(this.hasPendingHorizontalPageIndex && this.hasPendingVerticalPageIndex) {
				this.throwToPage(this.pendingHorizontalPageIndex,this.pendingVerticalPageIndex,this.pendingScrollDuration);
			} else if(this.hasPendingHorizontalPageIndex) {
				this.throwToPage(this.pendingHorizontalPageIndex,this._verticalPageIndex,this.pendingScrollDuration);
			} else if(this.hasPendingVerticalPageIndex) {
				this.throwToPage(this._horizontalPageIndex,this.pendingVerticalPageIndex,this.pendingScrollDuration);
			}
			this.hasPendingHorizontalPageIndex = false;
			this.hasPendingVerticalPageIndex = false;
		}
		
		protected function handlePendingRevealScrollBars() : void {
			if(!this.isScrollBarRevealPending) {
				return;
			}
			this.isScrollBarRevealPending = false;
			if(this._scrollBarDisplayMode != "float") {
				return;
			}
			this.revealHorizontalScrollBar();
			this.revealVerticalScrollBar();
			this.hideHorizontalScrollBar(this._revealScrollBarsDuration);
			this.hideVerticalScrollBar(this._revealScrollBarsDuration);
		}
		
		protected function viewPort_resizeHandler(event:starling.events.Event) : void {
			if(this.ignoreViewPortResizing || this._viewPort.width === this._lastViewPortWidth && this._viewPort.height === this._lastViewPortHeight) {
				return;
			}
			this._lastViewPortWidth = this._viewPort.width;
			this._lastViewPortHeight = this._viewPort.height;
			if(this._isValidating) {
				this._hasViewPortBoundsChanged = true;
			} else {
				this.invalidate("size");
			}
		}
		
		protected function childProperties_onChange(proxy:PropertyProxy, name:String) : void {
			this.invalidate("styles");
		}
		
		protected function verticalScrollBar_changeHandler(event:starling.events.Event) : void {
			this.verticalScrollPosition = this.verticalScrollBar.value;
		}
		
		protected function horizontalScrollBar_changeHandler(event:starling.events.Event) : void {
			this.horizontalScrollPosition = this.horizontalScrollBar.value;
		}
		
		protected function horizontalScrollBar_beginInteractionHandler(event:starling.events.Event) : void {
			if(this._horizontalAutoScrollTween) {
				Starling.juggler.remove(this._horizontalAutoScrollTween);
				this._horizontalAutoScrollTween = null;
			}
			this._isDraggingHorizontally = false;
			this._horizontalScrollBarIsScrolling = true;
			this.dispatchEventWith("beginInteraction");
			if(!this._isScrolling) {
				this.startScroll();
			}
		}
		
		protected function horizontalScrollBar_endInteractionHandler(event:starling.events.Event) : void {
			this._horizontalScrollBarIsScrolling = false;
			this.dispatchEventWith("endInteraction");
			this.completeScroll();
		}
		
		protected function verticalScrollBar_beginInteractionHandler(event:starling.events.Event) : void {
			if(this._verticalAutoScrollTween) {
				Starling.juggler.remove(this._verticalAutoScrollTween);
				this._verticalAutoScrollTween = null;
			}
			this._isDraggingVertically = false;
			this._verticalScrollBarIsScrolling = true;
			this.dispatchEventWith("beginInteraction");
			if(!this._isScrolling) {
				this.startScroll();
			}
		}
		
		protected function verticalScrollBar_endInteractionHandler(event:starling.events.Event) : void {
			this._verticalScrollBarIsScrolling = false;
			this.dispatchEventWith("endInteraction");
			this.completeScroll();
		}
		
		protected function horizontalAutoScrollTween_onComplete() : void {
			this._horizontalAutoScrollTween = null;
			this.invalidate("scroll");
			this.finishScrollingHorizontally();
		}
		
		protected function verticalAutoScrollTween_onComplete() : void {
			this._verticalAutoScrollTween = null;
			this.invalidate("scroll");
			this.finishScrollingVertically();
		}
		
		protected function horizontalScrollBarHideTween_onComplete() : void {
			this._horizontalScrollBarHideTween = null;
		}
		
		protected function verticalScrollBarHideTween_onComplete() : void {
			this._verticalScrollBarHideTween = null;
		}
		
		protected function scroller_touchHandler(event:TouchEvent) : void {
			if(!this._isEnabled) {
				this._touchPointID = -1;
				return;
			}
			if(this._touchPointID >= 0) {
				return;
			}
			var _local3:Touch = event.getTouch(this,"began");
			if(!_local3) {
				return;
			}
			if(this._interactionMode == "touchAndScrollBars" && (event.interactsWith(DisplayObject(this.horizontalScrollBar)) || event.interactsWith(DisplayObject(this.verticalScrollBar)))) {
				return;
			}
			_local3.getLocation(this,HELPER_POINT);
			var _local4:Number = HELPER_POINT.x;
			var _local5:Number = HELPER_POINT.y;
			if(_local4 < this._leftViewPortOffset || _local5 < this._topViewPortOffset || _local4 >= this.actualWidth - this._rightViewPortOffset || _local5 >= this.actualHeight - this._bottomViewPortOffset) {
				return;
			}
			var _local2:ExclusiveTouch = ExclusiveTouch.forStage(this.stage);
			if(_local2.getClaim(_local3.id)) {
				return;
			}
			if(this._horizontalAutoScrollTween && this._horizontalScrollPolicy != "off") {
				Starling.juggler.remove(this._horizontalAutoScrollTween);
				this._horizontalAutoScrollTween = null;
				if(this._isScrolling) {
					this._isDraggingHorizontally = true;
				}
			}
			if(this._verticalAutoScrollTween && this._verticalScrollPolicy != "off") {
				Starling.juggler.remove(this._verticalAutoScrollTween);
				this._verticalAutoScrollTween = null;
				if(this._isScrolling) {
					this._isDraggingVertically = true;
				}
			}
			this._touchPointID = _local3.id;
			this._velocityX = 0;
			this._velocityY = 0;
			this._previousVelocityX.length = 0;
			this._previousVelocityY.length = 0;
			this._previousTouchTime = getTimer();
			this._previousTouchX = this._startTouchX = this._currentTouchX = _local4;
			this._previousTouchY = this._startTouchY = this._currentTouchY = _local5;
			this._startHorizontalScrollPosition = this._horizontalScrollPosition;
			this._startVerticalScrollPosition = this._verticalScrollPosition;
			this._isScrollingStopped = false;
			this.addEventListener("enterFrame",scroller_enterFrameHandler);
			this.stage.addEventListener("touch",stage_touchHandler);
			if(this._isScrolling && (this._isDraggingHorizontally || this._isDraggingVertically)) {
				_local2.claimTouch(this._touchPointID,this);
			} else {
				_local2.addEventListener("change",exclusiveTouch_changeHandler);
			}
		}
		
		protected function scroller_enterFrameHandler(event:starling.events.Event) : void {
			var _local2:ExclusiveTouch = null;
			if(this._isScrollingStopped) {
				return;
			}
			var _local3:int = getTimer();
			var _local5:int = _local3 - this._previousTouchTime;
			if(_local5 > 0) {
				this._previousVelocityX[this._previousVelocityX.length] = this._velocityX;
				if(this._previousVelocityX.length > 4) {
					this._previousVelocityX.shift();
				}
				this._previousVelocityY[this._previousVelocityY.length] = this._velocityY;
				if(this._previousVelocityY.length > 4) {
					this._previousVelocityY.shift();
				}
				this._velocityX = (this._currentTouchX - this._previousTouchX) / _local5;
				this._velocityY = (this._currentTouchY - this._previousTouchY) / _local5;
				this._previousTouchTime = _local3;
				this._previousTouchX = this._currentTouchX;
				this._previousTouchY = this._currentTouchY;
			}
			var _local4:Number = Math.abs(this._currentTouchX - this._startTouchX) / (DeviceCapabilities.dpi / Starling.contentScaleFactor);
			var _local6:Number = Math.abs(this._currentTouchY - this._startTouchY) / (DeviceCapabilities.dpi / Starling.contentScaleFactor);
			if((this._horizontalScrollPolicy == "on" || this._horizontalScrollPolicy == "auto" && this._minHorizontalScrollPosition != this._maxHorizontalScrollPosition) && !this._isDraggingHorizontally && _local4 >= this._minimumDragDistance) {
				if(this.horizontalScrollBar) {
					this.revealHorizontalScrollBar();
				}
				this._startTouchX = this._currentTouchX;
				this._startHorizontalScrollPosition = this._horizontalScrollPosition;
				this._isDraggingHorizontally = true;
				if(!this._isDraggingVertically) {
					this.dispatchEventWith("beginInteraction");
					_local2 = ExclusiveTouch.forStage(this.stage);
					_local2.removeEventListener("change",exclusiveTouch_changeHandler);
					_local2.claimTouch(this._touchPointID,this);
					this.startScroll();
				}
			}
			if((this._verticalScrollPolicy == "on" || this._verticalScrollPolicy == "auto" && this._minVerticalScrollPosition != this._maxVerticalScrollPosition) && !this._isDraggingVertically && _local6 >= this._minimumDragDistance) {
				if(this.verticalScrollBar) {
					this.revealVerticalScrollBar();
				}
				this._startTouchY = this._currentTouchY;
				this._startVerticalScrollPosition = this._verticalScrollPosition;
				this._isDraggingVertically = true;
				if(!this._isDraggingHorizontally) {
					_local2 = ExclusiveTouch.forStage(this.stage);
					_local2.removeEventListener("change",exclusiveTouch_changeHandler);
					_local2.claimTouch(this._touchPointID,this);
					this.dispatchEventWith("beginInteraction");
					this.startScroll();
				}
			}
			if(this._isDraggingHorizontally && !this._horizontalAutoScrollTween) {
				this.updateHorizontalScrollFromTouchPosition(this._currentTouchX);
			}
			if(this._isDraggingVertically && !this._verticalAutoScrollTween) {
				this.updateVerticalScrollFromTouchPosition(this._currentTouchY);
			}
		}
		
		protected function stage_touchHandler(event:TouchEvent) : void {
			var _local8:Boolean = false;
			var _local5:Boolean = false;
			var _local9:Number = NaN;
			var _local2:int = 0;
			var _local3:Number = NaN;
			var _local6:int = 0;
			var _local7:Number = NaN;
			var _local4:Touch = event.getTouch(this.stage,null,this._touchPointID);
			if(!_local4) {
				return;
			}
			if(_local4.phase == "moved") {
				_local4.getLocation(this,HELPER_POINT);
				this._currentTouchX = HELPER_POINT.x;
				this._currentTouchY = HELPER_POINT.y;
			} else if(_local4.phase == "ended") {
				if(!this._isDraggingHorizontally && !this._isDraggingVertically) {
					ExclusiveTouch.forStage(this.stage).removeEventListener("change",exclusiveTouch_changeHandler);
				}
				this.removeEventListener("enterFrame",scroller_enterFrameHandler);
				this.stage.removeEventListener("touch",stage_touchHandler);
				this._touchPointID = -1;
				this.dispatchEventWith("endInteraction");
				_local8 = false;
				_local5 = false;
				if(this._horizontalScrollPosition < this._minHorizontalScrollPosition || this._horizontalScrollPosition > this._maxHorizontalScrollPosition) {
					_local8 = true;
					this.finishScrollingHorizontally();
				}
				if(this._verticalScrollPosition < this._minVerticalScrollPosition || this._verticalScrollPosition > this._maxVerticalScrollPosition) {
					_local5 = true;
					this.finishScrollingVertically();
				}
				if(_local8 && _local5) {
					return;
				}
				if(!_local8 && this._isDraggingHorizontally) {
					_local9 = this._velocityX * 2.33;
					_local2 = int(this._previousVelocityX.length);
					_local3 = 2.33;
					_local6 = 0;
					while(_local6 < _local2) {
						_local7 = VELOCITY_WEIGHTS[_local6];
						_local9 += this._previousVelocityX.shift() * _local7;
						_local3 += _local7;
						_local6++;
					}
					this.throwHorizontally(_local9 / _local3);
				} else {
					this.hideHorizontalScrollBar();
				}
				if(!_local5 && this._isDraggingVertically) {
					_local9 = this._velocityY * 2.33;
					_local2 = int(this._previousVelocityY.length);
					_local3 = 2.33;
					_local6 = 0;
					while(_local6 < _local2) {
						_local7 = VELOCITY_WEIGHTS[_local6];
						_local9 += this._previousVelocityY.shift() * _local7;
						_local3 += _local7;
						_local6++;
					}
					this.throwVertically(_local9 / _local3);
				} else {
					this.hideVerticalScrollBar();
				}
			}
		}
		
		protected function exclusiveTouch_changeHandler(event:starling.events.Event, touchID:int) : void {
			if(this._touchPointID < 0 || this._touchPointID != touchID || this._isDraggingHorizontally || this._isDraggingVertically) {
				return;
			}
			var _local3:ExclusiveTouch = ExclusiveTouch.forStage(this.stage);
			if(_local3.getClaim(touchID) == this) {
				return;
			}
			this._touchPointID = -1;
			this.removeEventListener("enterFrame",scroller_enterFrameHandler);
			this.stage.removeEventListener("touch",stage_touchHandler);
			_local3.removeEventListener("change",exclusiveTouch_changeHandler);
			this.dispatchEventWith("endInteraction");
		}
		
		protected function nativeStage_mouseWheelHandler(event:MouseEvent) : void {
			var _local8:Number = NaN;
			var _local4:Number = NaN;
			var _local5:Number = NaN;
			var _local9:Number = NaN;
			var _local6:Number = NaN;
			if(!this._isEnabled) {
				this._touchPointID = -1;
				return;
			}
			if(this._verticalMouseWheelScrollDirection == "vertical" && (this._maxVerticalScrollPosition == this._minVerticalScrollPosition || this._verticalScrollPolicy == "off") || this._verticalMouseWheelScrollDirection == "horizontal" && (this._maxHorizontalScrollPosition == this._minHorizontalScrollPosition || this._horizontalScrollPolicy == "off")) {
				return;
			}
			var _local7:Number = 1;
			if(Starling.current.supportHighResolutions) {
				_local7 = Starling.current.nativeStage.contentsScaleFactor;
			}
			var _local2:Rectangle = Starling.current.viewPort;
			var _local3:Number = _local7 / Starling.contentScaleFactor;
			HELPER_POINT.x = (event.stageX - _local2.x) * _local3;
			HELPER_POINT.y = (event.stageY - _local2.y) * _local3;
			if(this.contains(this.stage.hitTest(HELPER_POINT))) {
				this.globalToLocal(HELPER_POINT,HELPER_POINT);
				_local8 = HELPER_POINT.x;
				_local4 = HELPER_POINT.y;
				if(_local8 < this._leftViewPortOffset || _local4 < this._topViewPortOffset || _local8 >= this.actualWidth - this._rightViewPortOffset || _local4 >= this.actualHeight - this._bottomViewPortOffset) {
					return;
				}
				_local5 = this._horizontalScrollPosition;
				_local9 = this._verticalScrollPosition;
				_local6 = this._verticalMouseWheelScrollStep;
				if(this._verticalMouseWheelScrollDirection == "horizontal") {
					if(_local6 !== _local6) {
						_local6 = this.actualHorizontalScrollStep;
					}
					_local5 -= event.delta * _local6;
					if(_local5 < this._minHorizontalScrollPosition) {
						_local5 = this._minHorizontalScrollPosition;
					} else if(_local5 > this._maxHorizontalScrollPosition) {
						_local5 = this._maxHorizontalScrollPosition;
					}
				} else {
					if(_local6 !== _local6) {
						_local6 = this.actualVerticalScrollStep;
					}
					_local9 -= event.delta * _local6;
					if(_local9 < this._minVerticalScrollPosition) {
						_local9 = this._minVerticalScrollPosition;
					} else if(_local9 > this._maxVerticalScrollPosition) {
						_local9 = this._maxVerticalScrollPosition;
					}
				}
				this.throwTo(_local5,_local9,this._mouseWheelScrollDuration);
			}
		}
		
		protected function nativeStage_orientationChangeHandler(event:flash.events.Event) : void {
			if(this._touchPointID < 0) {
				return;
			}
			this._startTouchX = this._previousTouchX = this._currentTouchX;
			this._startTouchY = this._previousTouchY = this._currentTouchY;
			this._startHorizontalScrollPosition = this._horizontalScrollPosition;
			this._startVerticalScrollPosition = this._verticalScrollPosition;
		}
		
		protected function horizontalScrollBar_touchHandler(event:TouchEvent) : void {
			var _local4:Touch = null;
			var _local3:* = false;
			if(!this._isEnabled) {
				this._horizontalScrollBarTouchPointID = -1;
				return;
			}
			var _local2:DisplayObject = DisplayObject(event.currentTarget);
			if(this._horizontalScrollBarTouchPointID >= 0) {
				_local4 = event.getTouch(_local2,"ended",this._horizontalScrollBarTouchPointID);
				if(!_local4) {
					return;
				}
				this._horizontalScrollBarTouchPointID = -1;
				_local4.getLocation(_local2,HELPER_POINT);
				_local3 = this.horizontalScrollBar.hitTest(HELPER_POINT) !== null;
				if(!_local3) {
					this.hideHorizontalScrollBar();
				}
			} else {
				_local4 = event.getTouch(_local2,"began");
				if(_local4) {
					this._horizontalScrollBarTouchPointID = _local4.id;
					return;
				}
				if(this._isScrolling) {
					return;
				}
				_local4 = event.getTouch(_local2,"hover");
				if(_local4) {
					this.revealHorizontalScrollBar();
					return;
				}
				this.hideHorizontalScrollBar();
			}
		}
		
		protected function verticalScrollBar_touchHandler(event:TouchEvent) : void {
			var _local4:Touch = null;
			var _local3:* = false;
			if(!this._isEnabled) {
				this._verticalScrollBarTouchPointID = -1;
				return;
			}
			var _local2:DisplayObject = DisplayObject(event.currentTarget);
			if(this._verticalScrollBarTouchPointID >= 0) {
				_local4 = event.getTouch(_local2,"ended",this._verticalScrollBarTouchPointID);
				if(!_local4) {
					return;
				}
				this._verticalScrollBarTouchPointID = -1;
				_local4.getLocation(_local2,HELPER_POINT);
				_local3 = this.verticalScrollBar.hitTest(HELPER_POINT) !== null;
				if(!_local3) {
					this.hideVerticalScrollBar();
				}
			} else {
				_local4 = event.getTouch(_local2,"began");
				if(_local4) {
					this._verticalScrollBarTouchPointID = _local4.id;
					return;
				}
				if(this._isScrolling) {
					return;
				}
				_local4 = event.getTouch(_local2,"hover");
				if(_local4) {
					this.revealVerticalScrollBar();
					return;
				}
				this.hideVerticalScrollBar();
			}
		}
		
		protected function scroller_addedToStageHandler(event:starling.events.Event) : void {
			Starling.current.nativeStage.addEventListener("mouseWheel",nativeStage_mouseWheelHandler,false,0,true);
			Starling.current.nativeStage.addEventListener("orientationChange",nativeStage_orientationChangeHandler,false,0,true);
		}
		
		protected function scroller_removedFromStageHandler(event:starling.events.Event) : void {
			var _local2:ExclusiveTouch = null;
			Starling.current.nativeStage.removeEventListener("mouseWheel",nativeStage_mouseWheelHandler);
			Starling.current.nativeStage.removeEventListener("orientationChange",nativeStage_orientationChangeHandler);
			if(this._touchPointID >= 0) {
				_local2 = ExclusiveTouch.forStage(this.stage);
				_local2.removeEventListener("change",exclusiveTouch_changeHandler);
			}
			this._touchPointID = -1;
			this._horizontalScrollBarTouchPointID = -1;
			this._verticalScrollBarTouchPointID = -1;
			this._isDraggingHorizontally = false;
			this._isDraggingVertically = false;
			this._velocityX = 0;
			this._velocityY = 0;
			this._previousVelocityX.length = 0;
			this._previousVelocityY.length = 0;
			this._horizontalScrollBarIsScrolling = false;
			this._verticalScrollBarIsScrolling = false;
			this.removeEventListener("enterFrame",scroller_enterFrameHandler);
			this.stage.removeEventListener("touch",stage_touchHandler);
			if(this._verticalAutoScrollTween) {
				Starling.juggler.remove(this._verticalAutoScrollTween);
				this._verticalAutoScrollTween = null;
			}
			if(this._horizontalAutoScrollTween) {
				Starling.juggler.remove(this._horizontalAutoScrollTween);
				this._horizontalAutoScrollTween = null;
			}
			var _local4:Number = this._horizontalScrollPosition;
			var _local3:Number = this._verticalScrollPosition;
			if(this._horizontalScrollPosition < this._minHorizontalScrollPosition) {
				this._horizontalScrollPosition = this._minHorizontalScrollPosition;
			} else if(this._horizontalScrollPosition > this._maxHorizontalScrollPosition) {
				this._horizontalScrollPosition = this._maxHorizontalScrollPosition;
			}
			if(this._verticalScrollPosition < this._minVerticalScrollPosition) {
				this._verticalScrollPosition = this._minVerticalScrollPosition;
			} else if(this._verticalScrollPosition > this._maxVerticalScrollPosition) {
				this._verticalScrollPosition = this._maxVerticalScrollPosition;
			}
			if(_local4 != this._horizontalScrollPosition || _local3 != this._verticalScrollPosition) {
				this.dispatchEventWith("scroll");
			}
			this.completeScroll();
		}
		
		override protected function focusInHandler(event:starling.events.Event) : void {
			super.focusInHandler(event);
			this.stage.addEventListener("keyDown",stage_keyDownHandler);
		}
		
		override protected function focusOutHandler(event:starling.events.Event) : void {
			super.focusOutHandler(event);
			this.stage.removeEventListener("keyDown",stage_keyDownHandler);
		}
		
		protected function stage_keyDownHandler(event:KeyboardEvent) : void {
			if(event.keyCode == 36) {
				this.verticalScrollPosition = this._minVerticalScrollPosition;
			} else if(event.keyCode == 35) {
				this.verticalScrollPosition = this._maxVerticalScrollPosition;
			} else if(event.keyCode == 33) {
				this.verticalScrollPosition = Math.max(this._minVerticalScrollPosition,this._verticalScrollPosition - this.viewPort.visibleHeight);
			} else if(event.keyCode == 34) {
				this.verticalScrollPosition = Math.min(this._maxVerticalScrollPosition,this._verticalScrollPosition + this.viewPort.visibleHeight);
			} else if(event.keyCode == 38) {
				this.verticalScrollPosition = Math.max(this._minVerticalScrollPosition,this._verticalScrollPosition - this.verticalScrollStep);
			} else if(event.keyCode == 40) {
				this.verticalScrollPosition = Math.min(this._maxVerticalScrollPosition,this._verticalScrollPosition + this.verticalScrollStep);
			} else if(event.keyCode == 37) {
				this.horizontalScrollPosition = Math.max(this._maxHorizontalScrollPosition,this._horizontalScrollPosition - this.horizontalScrollStep);
			} else if(event.keyCode == 39) {
				this.horizontalScrollPosition = Math.min(this._maxHorizontalScrollPosition,this._horizontalScrollPosition + this.horizontalScrollStep);
			}
		}
	}
}

