package feathers.controls {
	import feathers.controls.supportClasses.BaseScreenNavigator;
	import feathers.core.FeathersControl;
	import feathers.core.IFeathersControl;
	import feathers.core.IValidating;
	import feathers.events.ExclusiveTouch;
	import feathers.skins.IStyleProvider;
	import feathers.system.DeviceCapabilities;
	import feathers.utils.display.getDisplayObjectDepthFromStage;
	import feathers.utils.math.roundToNearest;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	import starling.display.Stage;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.events.ResizeEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	public class Drawers extends FeathersControl {
		public static var globalStyleProvider:IStyleProvider;
		
		public static const DOCK_MODE_PORTRAIT:String = "portrait";
		
		public static const DOCK_MODE_LANDSCAPE:String = "landscape";
		
		public static const DOCK_MODE_BOTH:String = "both";
		
		public static const DOCK_MODE_NONE:String = "none";
		
		public static const OPEN_MODE_ABOVE:String = "overlay";
		
		public static const OPEN_MODE_BELOW:String = "below";
		
		public static const AUTO_SIZE_MODE_STAGE:String = "stage";
		
		public static const AUTO_SIZE_MODE_CONTENT:String = "content";
		
		public static const OPEN_GESTURE_DRAG_CONTENT_EDGE:String = "dragContentEdge";
		
		public static const OPEN_GESTURE_DRAG_CONTENT:String = "dragContent";
		
		public static const OPEN_GESTURE_NONE:String = "none";
		
		protected static const SCREEN_NAVIGATOR_CONTENT_EVENT_DISPATCHER_FIELD:String = "activeScreen";
		
		private static const CURRENT_VELOCITY_WEIGHT:Number = 2.33;
		
		private static const MAXIMUM_SAVED_VELOCITY_COUNT:int = 4;
		
		private static const VELOCITY_WEIGHTS:Vector.<Number> = new <Number>[1,1.33,1.66,2];
		
		private static const HELPER_POINT:Point = new Point();
		
		protected var contentEventDispatcher:EventDispatcher;
		
		protected var _originalContentWidth:Number = NaN;
		
		protected var _originalContentHeight:Number = NaN;
		
		protected var _content:IFeathersControl;
		
		protected var _overlaySkinOriginalAlpha:Number = 1;
		
		protected var _overlaySkin:DisplayObject;
		
		protected var _originalTopDrawerWidth:Number = NaN;
		
		protected var _originalTopDrawerHeight:Number = NaN;
		
		protected var _topDrawer:IFeathersControl;
		
		protected var _topDrawerDivider:DisplayObject;
		
		protected var _topDrawerDockMode:String = "none";
		
		protected var _topDrawerToggleEventType:String;
		
		protected var _isTopDrawerOpen:Boolean = false;
		
		protected var _originalRightDrawerWidth:Number = NaN;
		
		protected var _originalRightDrawerHeight:Number = NaN;
		
		protected var _rightDrawer:IFeathersControl;
		
		protected var _rightDrawerDivider:DisplayObject;
		
		protected var _rightDrawerDockMode:String = "none";
		
		protected var _rightDrawerToggleEventType:String;
		
		protected var _isRightDrawerOpen:Boolean = false;
		
		protected var _originalBottomDrawerWidth:Number = NaN;
		
		protected var _originalBottomDrawerHeight:Number = NaN;
		
		protected var _bottomDrawer:IFeathersControl;
		
		protected var _bottomDrawerDivider:DisplayObject;
		
		protected var _bottomDrawerDockMode:String = "none";
		
		protected var _bottomDrawerToggleEventType:String;
		
		protected var _isBottomDrawerOpen:Boolean = false;
		
		protected var _originalLeftDrawerWidth:Number = NaN;
		
		protected var _originalLeftDrawerHeight:Number = NaN;
		
		protected var _leftDrawer:IFeathersControl;
		
		protected var _leftDrawerDivider:DisplayObject;
		
		protected var _leftDrawerDockMode:String = "none";
		
		protected var _leftDrawerToggleEventType:String;
		
		protected var _isLeftDrawerOpen:Boolean = false;
		
		protected var _autoSizeMode:String = "stage";
		
		protected var _clipDrawers:Boolean = true;
		
		protected var _openMode:String = "below";
		
		protected var _openGesture:String = "edge";
		
		protected var _minimumDragDistance:Number = 0.04;
		
		protected var _minimumDrawerThrowVelocity:Number = 5;
		
		protected var _openGestureEdgeSize:Number = 0.1;
		
		protected var _contentEventDispatcherChangeEventType:String;
		
		protected var _contentEventDispatcherField:String;
		
		protected var _contentEventDispatcherFunction:Function;
		
		protected var _openOrCloseTween:Tween;
		
		protected var _openOrCloseDuration:Number = 0.25;
		
		protected var _openOrCloseEase:Object = "easeOut";
		
		protected var isToggleTopDrawerPending:Boolean = false;
		
		protected var isToggleRightDrawerPending:Boolean = false;
		
		protected var isToggleBottomDrawerPending:Boolean = false;
		
		protected var isToggleLeftDrawerPending:Boolean = false;
		
		protected var pendingToggleDuration:Number;
		
		protected var touchPointID:int = -1;
		
		protected var _isDragging:Boolean = false;
		
		protected var _isDraggingTopDrawer:Boolean = false;
		
		protected var _isDraggingRightDrawer:Boolean = false;
		
		protected var _isDraggingBottomDrawer:Boolean = false;
		
		protected var _isDraggingLeftDrawer:Boolean = false;
		
		protected var _startTouchX:Number;
		
		protected var _startTouchY:Number;
		
		protected var _currentTouchX:Number;
		
		protected var _currentTouchY:Number;
		
		protected var _previousTouchTime:int;
		
		protected var _previousTouchX:Number;
		
		protected var _previousTouchY:Number;
		
		protected var _velocityX:Number = 0;
		
		protected var _velocityY:Number = 0;
		
		protected var _previousVelocityX:Vector.<Number> = new Vector.<Number>(0);
		
		protected var _previousVelocityY:Vector.<Number> = new Vector.<Number>(0);
		
		public function Drawers(content:IFeathersControl = null) {
			super();
			this.content = content;
			this.addEventListener("addedToStage",drawers_addedToStageHandler);
			this.addEventListener("removedFromStage",drawers_removedFromStageHandler);
			this.addEventListener("touch",drawers_touchHandler);
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return Drawers.globalStyleProvider;
		}
		
		public function get content() : IFeathersControl {
			return this._content;
		}
		
		public function set content(value:IFeathersControl) : void {
			if(this._content === value) {
				return;
			}
			if(this._content) {
				if(this._contentEventDispatcherChangeEventType) {
					this._content.removeEventListener(this._contentEventDispatcherChangeEventType,content_eventDispatcherChangeHandler);
				}
				this._content.removeEventListener("resize",content_resizeHandler);
				if(this._content.parent === this) {
					this.removeChild(DisplayObject(this._content),false);
				}
			}
			this._content = value;
			this._originalContentWidth = NaN;
			this._originalContentHeight = NaN;
			if(this._content) {
				if(this._content is BaseScreenNavigator) {
					this.contentEventDispatcherField = "activeScreen";
					this.contentEventDispatcherChangeEventType = "change";
				}
				if(this._contentEventDispatcherChangeEventType) {
					this._content.addEventListener(this._contentEventDispatcherChangeEventType,content_eventDispatcherChangeHandler);
				}
				if(this._autoSizeMode === "content" || !this.stage) {
					this._content.addEventListener("resize",content_resizeHandler);
				}
				if(this._openMode === "above") {
					this.addChildAt(DisplayObject(this._content),0);
				} else if(this._overlaySkin) {
					this.addChildAt(DisplayObject(this._content),this.getChildIndex(this._overlaySkin));
				} else {
					this.addChild(DisplayObject(this._content));
				}
			}
			this.invalidate("data");
		}
		
		public function get overlaySkin() : DisplayObject {
			return this._overlaySkin;
		}
		
		public function set overlaySkin(value:DisplayObject) : void {
			if(this._overlaySkin == value) {
				return;
			}
			if(this._overlaySkin && this._overlaySkin.parent == this) {
				this.removeChild(this._overlaySkin,false);
			}
			this._overlaySkin = value;
			if(this._overlaySkin) {
				this._overlaySkinOriginalAlpha = this._overlaySkin.alpha;
				this._overlaySkin.visible = this.isTopDrawerOpen || this.isRightDrawerOpen || this.isBottomDrawerOpen || this.isLeftDrawerOpen;
				this.addChild(this._overlaySkin);
			}
			this.invalidate("data");
		}
		
		public function get topDrawer() : IFeathersControl {
			return this._topDrawer;
		}
		
		public function set topDrawer(value:IFeathersControl) : void {
			if(this._topDrawer === value) {
				return;
			}
			if(this.isTopDrawerOpen && value === null) {
				this.isTopDrawerOpen = false;
			}
			if(this._topDrawer && this._topDrawer.parent === this) {
				this.removeChild(DisplayObject(this._topDrawer),false);
			}
			this._topDrawer = value;
			this._originalTopDrawerWidth = NaN;
			this._originalTopDrawerHeight = NaN;
			if(this._topDrawer) {
				this._topDrawer.visible = false;
				this._topDrawer.addEventListener("resize",drawer_resizeHandler);
				if(this._openMode === "above") {
					this.addChild(DisplayObject(this._topDrawer));
				} else {
					this.addChildAt(DisplayObject(this._topDrawer),0);
				}
			}
			this.invalidate("data");
		}
		
		public function get topDrawerDivider() : DisplayObject {
			return this._topDrawerDivider;
		}
		
		public function set topDrawerDivider(value:DisplayObject) : void {
			if(this._topDrawerDivider === value) {
				return;
			}
			if(this._topDrawerDivider && this._topDrawerDivider.parent == this) {
				this.removeChild(this._topDrawerDivider,false);
			}
			this._topDrawerDivider = value;
			if(this._topDrawerDivider) {
				this._topDrawerDivider.visible = false;
				this.addChild(this._topDrawerDivider);
			}
			this.invalidate("styles");
		}
		
		public function get topDrawerDockMode() : String {
			return this._topDrawerDockMode;
		}
		
		public function set topDrawerDockMode(value:String) : void {
			if(this._topDrawerDockMode == value) {
				return;
			}
			this._topDrawerDockMode = value;
			this.invalidate("layout");
		}
		
		public function get topDrawerToggleEventType() : String {
			return this._topDrawerToggleEventType;
		}
		
		public function set topDrawerToggleEventType(value:String) : void {
			if(this._topDrawerToggleEventType == value) {
				return;
			}
			if(this.contentEventDispatcher && this._topDrawerToggleEventType) {
				this.contentEventDispatcher.removeEventListener(this._topDrawerToggleEventType,content_topDrawerToggleEventTypeHandler);
			}
			this._topDrawerToggleEventType = value;
			if(this.contentEventDispatcher && this._topDrawerToggleEventType) {
				this.contentEventDispatcher.addEventListener(this._topDrawerToggleEventType,content_topDrawerToggleEventTypeHandler);
			}
		}
		
		public function get isTopDrawerOpen() : Boolean {
			return this._topDrawer && this._isTopDrawerOpen;
		}
		
		public function set isTopDrawerOpen(value:Boolean) : void {
			if(this.isTopDrawerDocked || this._isTopDrawerOpen == value) {
				return;
			}
			if(value) {
				this.isRightDrawerOpen = false;
				this.isBottomDrawerOpen = false;
				this.isLeftDrawerOpen = false;
			}
			this._isTopDrawerOpen = value;
			this.invalidate("selected");
		}
		
		public function get isTopDrawerDocked() : Boolean {
			if(!this._topDrawer) {
				return false;
			}
			if(this._topDrawerDockMode === "both") {
				return true;
			}
			if(this._topDrawerDockMode === "none") {
				return false;
			}
			var _local1:Stage = this.stage;
			if(!_local1) {
				_local1 = Starling.current.stage;
			}
			if(_local1.stageWidth > _local1.stageHeight) {
				return this._topDrawerDockMode === "landscape";
			}
			return this._topDrawerDockMode === "portrait";
		}
		
		public function get rightDrawer() : IFeathersControl {
			return this._rightDrawer;
		}
		
		public function set rightDrawer(value:IFeathersControl) : void {
			if(this._rightDrawer == value) {
				return;
			}
			if(this.isRightDrawerOpen && value === null) {
				this.isRightDrawerOpen = false;
			}
			if(this._rightDrawer && this._rightDrawer.parent == this) {
				this.removeChild(DisplayObject(this._rightDrawer),false);
			}
			this._rightDrawer = value;
			this._originalRightDrawerWidth = NaN;
			this._originalRightDrawerHeight = NaN;
			if(this._rightDrawer) {
				this._rightDrawer.visible = false;
				this._rightDrawer.addEventListener("resize",drawer_resizeHandler);
				if(this._openMode === "above") {
					this.addChild(DisplayObject(this._rightDrawer));
				} else {
					this.addChildAt(DisplayObject(this._rightDrawer),0);
				}
			}
			this.invalidate("data");
		}
		
		public function get rightDrawerDivider() : DisplayObject {
			return this._rightDrawerDivider;
		}
		
		public function set rightDrawerDivider(value:DisplayObject) : void {
			if(this._rightDrawerDivider === value) {
				return;
			}
			if(this._rightDrawerDivider && this._rightDrawerDivider.parent == this) {
				this.removeChild(this._rightDrawerDivider,false);
			}
			this._rightDrawerDivider = value;
			if(this._rightDrawerDivider) {
				this._rightDrawerDivider.visible = false;
				this.addChild(this._rightDrawerDivider);
			}
			this.invalidate("styles");
		}
		
		public function get rightDrawerDockMode() : String {
			return this._rightDrawerDockMode;
		}
		
		public function set rightDrawerDockMode(value:String) : void {
			if(this._rightDrawerDockMode == value) {
				return;
			}
			this._rightDrawerDockMode = value;
			this.invalidate("layout");
		}
		
		public function get rightDrawerToggleEventType() : String {
			return this._rightDrawerToggleEventType;
		}
		
		public function set rightDrawerToggleEventType(value:String) : void {
			if(this._rightDrawerToggleEventType == value) {
				return;
			}
			if(this.contentEventDispatcher && this._rightDrawerToggleEventType) {
				this.contentEventDispatcher.removeEventListener(this._rightDrawerToggleEventType,content_rightDrawerToggleEventTypeHandler);
			}
			this._rightDrawerToggleEventType = value;
			if(this.contentEventDispatcher && this._rightDrawerToggleEventType) {
				this.contentEventDispatcher.addEventListener(this._rightDrawerToggleEventType,content_rightDrawerToggleEventTypeHandler);
			}
		}
		
		public function get isRightDrawerOpen() : Boolean {
			return this._rightDrawer && this._isRightDrawerOpen;
		}
		
		public function set isRightDrawerOpen(value:Boolean) : void {
			if(this.isRightDrawerDocked || this._isRightDrawerOpen == value) {
				return;
			}
			if(value) {
				this.isTopDrawerOpen = false;
				this.isBottomDrawerOpen = false;
				this.isLeftDrawerOpen = false;
			}
			this._isRightDrawerOpen = value;
			this.invalidate("selected");
		}
		
		public function get isRightDrawerDocked() : Boolean {
			if(!this._rightDrawer) {
				return false;
			}
			if(this._rightDrawerDockMode === "both") {
				return true;
			}
			if(this._rightDrawerDockMode === "none") {
				return false;
			}
			var _local1:Stage = this.stage;
			if(!_local1) {
				_local1 = Starling.current.stage;
			}
			if(_local1.stageWidth > _local1.stageHeight) {
				return this._rightDrawerDockMode === "landscape";
			}
			return this._rightDrawerDockMode === "portrait";
		}
		
		public function get bottomDrawer() : IFeathersControl {
			return this._bottomDrawer;
		}
		
		public function set bottomDrawer(value:IFeathersControl) : void {
			if(this._bottomDrawer === value) {
				return;
			}
			if(this.isBottomDrawerOpen && value === null) {
				this.isBottomDrawerOpen = false;
			}
			if(this._bottomDrawer && this._bottomDrawer.parent === this) {
				this.removeChild(DisplayObject(this._bottomDrawer),false);
			}
			this._bottomDrawer = value;
			this._originalBottomDrawerWidth = NaN;
			this._originalBottomDrawerHeight = NaN;
			if(this._bottomDrawer) {
				this._bottomDrawer.visible = false;
				this._bottomDrawer.addEventListener("resize",drawer_resizeHandler);
				if(this._openMode === "above") {
					this.addChild(DisplayObject(this._bottomDrawer));
				} else {
					this.addChildAt(DisplayObject(this._bottomDrawer),0);
				}
			}
			this.invalidate("data");
		}
		
		public function get bottomDrawerDivider() : DisplayObject {
			return this._bottomDrawerDivider;
		}
		
		public function set bottomDrawerDivider(value:DisplayObject) : void {
			if(this._bottomDrawerDivider === value) {
				return;
			}
			if(this._bottomDrawerDivider && this._bottomDrawerDivider.parent == this) {
				this.removeChild(this._bottomDrawerDivider,false);
			}
			this._bottomDrawerDivider = value;
			if(this._bottomDrawerDivider) {
				this._bottomDrawerDivider.visible = false;
				this.addChild(this._bottomDrawerDivider);
			}
			this.invalidate("styles");
		}
		
		public function get bottomDrawerDockMode() : String {
			return this._bottomDrawerDockMode;
		}
		
		public function set bottomDrawerDockMode(value:String) : void {
			if(this._bottomDrawerDockMode == value) {
				return;
			}
			this._bottomDrawerDockMode = value;
			this.invalidate("layout");
		}
		
		public function get bottomDrawerToggleEventType() : String {
			return this._bottomDrawerToggleEventType;
		}
		
		public function set bottomDrawerToggleEventType(value:String) : void {
			if(this._bottomDrawerToggleEventType == value) {
				return;
			}
			if(this.contentEventDispatcher && this._bottomDrawerToggleEventType) {
				this.contentEventDispatcher.removeEventListener(this._bottomDrawerToggleEventType,content_bottomDrawerToggleEventTypeHandler);
			}
			this._bottomDrawerToggleEventType = value;
			if(this.contentEventDispatcher && this._bottomDrawerToggleEventType) {
				this.contentEventDispatcher.addEventListener(this._bottomDrawerToggleEventType,content_bottomDrawerToggleEventTypeHandler);
			}
		}
		
		public function get isBottomDrawerOpen() : Boolean {
			return this._bottomDrawer && this._isBottomDrawerOpen;
		}
		
		public function set isBottomDrawerOpen(value:Boolean) : void {
			if(this.isBottomDrawerDocked || this._isBottomDrawerOpen == value) {
				return;
			}
			if(value) {
				this.isTopDrawerOpen = false;
				this.isRightDrawerOpen = false;
				this.isLeftDrawerOpen = false;
			}
			this._isBottomDrawerOpen = value;
			this.invalidate("selected");
		}
		
		public function get isBottomDrawerDocked() : Boolean {
			if(!this._bottomDrawer) {
				return false;
			}
			if(this._bottomDrawerDockMode === "both") {
				return true;
			}
			if(this._bottomDrawerDockMode === "none") {
				return false;
			}
			var _local1:Stage = this.stage;
			if(!_local1) {
				_local1 = Starling.current.stage;
			}
			if(_local1.stageWidth > _local1.stageHeight) {
				return this._bottomDrawerDockMode === "landscape";
			}
			return this._bottomDrawerDockMode === "portrait";
		}
		
		public function get leftDrawer() : IFeathersControl {
			return this._leftDrawer;
		}
		
		public function set leftDrawer(value:IFeathersControl) : void {
			if(this._leftDrawer === value) {
				return;
			}
			if(this.isLeftDrawerOpen && value === null) {
				this.isLeftDrawerOpen = false;
			}
			if(this._leftDrawer && this._leftDrawer.parent === this) {
				this.removeChild(DisplayObject(this._leftDrawer),false);
			}
			this._leftDrawer = value;
			this._originalLeftDrawerWidth = NaN;
			this._originalLeftDrawerHeight = NaN;
			if(this._leftDrawer) {
				this._leftDrawer.visible = false;
				this._leftDrawer.addEventListener("resize",drawer_resizeHandler);
				if(this._openMode === "above") {
					this.addChild(DisplayObject(this._leftDrawer));
				} else {
					this.addChildAt(DisplayObject(this._leftDrawer),0);
				}
			}
			this.invalidate("data");
		}
		
		public function get leftDrawerDivider() : DisplayObject {
			return this._leftDrawerDivider;
		}
		
		public function set leftDrawerDivider(value:DisplayObject) : void {
			if(this._leftDrawerDivider === value) {
				return;
			}
			if(this._leftDrawerDivider && this._leftDrawerDivider.parent == this) {
				this.removeChild(this._leftDrawerDivider,false);
			}
			this._leftDrawerDivider = value;
			if(this._leftDrawerDivider) {
				this._leftDrawerDivider.visible = false;
				this.addChild(this._leftDrawerDivider);
			}
			this.invalidate("styles");
		}
		
		public function get leftDrawerDockMode() : String {
			return this._leftDrawerDockMode;
		}
		
		public function set leftDrawerDockMode(value:String) : void {
			if(this._leftDrawerDockMode == value) {
				return;
			}
			this._leftDrawerDockMode = value;
			this.invalidate("layout");
		}
		
		public function get leftDrawerToggleEventType() : String {
			return this._leftDrawerToggleEventType;
		}
		
		public function set leftDrawerToggleEventType(value:String) : void {
			if(this._leftDrawerToggleEventType == value) {
				return;
			}
			if(this.contentEventDispatcher && this._leftDrawerToggleEventType) {
				this.contentEventDispatcher.removeEventListener(this._leftDrawerToggleEventType,content_leftDrawerToggleEventTypeHandler);
			}
			this._leftDrawerToggleEventType = value;
			if(this.contentEventDispatcher && this._leftDrawerToggleEventType) {
				this.contentEventDispatcher.addEventListener(this._leftDrawerToggleEventType,content_leftDrawerToggleEventTypeHandler);
			}
		}
		
		public function get isLeftDrawerOpen() : Boolean {
			return this._leftDrawer && this._isLeftDrawerOpen;
		}
		
		public function set isLeftDrawerOpen(value:Boolean) : void {
			if(this.isLeftDrawerDocked || this._isLeftDrawerOpen == value) {
				return;
			}
			if(value) {
				this.isTopDrawerOpen = false;
				this.isRightDrawerOpen = false;
				this.isBottomDrawerOpen = false;
			}
			this._isLeftDrawerOpen = value;
			this.invalidate("selected");
		}
		
		public function get isLeftDrawerDocked() : Boolean {
			if(!this._leftDrawer) {
				return false;
			}
			if(this._leftDrawerDockMode === "both") {
				return true;
			}
			if(this._leftDrawerDockMode === "none") {
				return false;
			}
			var _local1:Stage = this.stage;
			if(!_local1) {
				_local1 = Starling.current.stage;
			}
			if(_local1.stageWidth > _local1.stageHeight) {
				return this._leftDrawerDockMode === "landscape";
			}
			return this._leftDrawerDockMode == "portrait";
		}
		
		public function get autoSizeMode() : String {
			return this._autoSizeMode;
		}
		
		public function set autoSizeMode(value:String) : void {
			if(this._autoSizeMode == value) {
				return;
			}
			this._autoSizeMode = value;
			if(this._content) {
				if(this._autoSizeMode == "content") {
					this._content.addEventListener("resize",content_resizeHandler);
				} else {
					this._content.removeEventListener("resize",content_resizeHandler);
				}
			}
			this.invalidate("size");
		}
		
		public function get clipDrawers() : Boolean {
			return this._clipDrawers;
		}
		
		public function set clipDrawers(value:Boolean) : void {
			if(this._clipDrawers == value) {
				return;
			}
			this._clipDrawers = value;
			this.invalidate("layout");
		}
		
		public function get openMode() : String {
			return this._openMode;
		}
		
		public function set openMode(value:String) : void {
			if(value === "overlay") {
				value = "above";
			}
			if(this._openMode == value) {
				return;
			}
			this._openMode = value;
			if(this._content) {
				if(this._openMode === "above") {
					this.setChildIndex(DisplayObject(this._content),0);
				} else if(this._overlaySkin) {
					this.setChildIndex(DisplayObject(this._content),this.numChildren - 1);
					this.setChildIndex(this._overlaySkin,this.numChildren - 1);
				} else {
					this.setChildIndex(DisplayObject(this._content),this.numChildren - 1);
				}
			}
			this.invalidate("layout");
		}
		
		public function get openGesture() : String {
			return this._openGesture;
		}
		
		public function set openGesture(value:String) : void {
			if(value === "dragContent") {
				value = "content";
			} else if(value === "dragContentEdge") {
				value = "edge";
			}
			this._openGesture = value;
		}
		
		public function get minimumDragDistance() : Number {
			return this._minimumDragDistance;
		}
		
		public function set minimumDragDistance(value:Number) : void {
			this._minimumDragDistance = value;
		}
		
		public function get minimumDrawerThrowVelocity() : Number {
			return this._minimumDrawerThrowVelocity;
		}
		
		public function set minimumDrawerThrowVelocity(value:Number) : void {
			this._minimumDrawerThrowVelocity = value;
		}
		
		public function get openGestureEdgeSize() : Number {
			return this._openGestureEdgeSize;
		}
		
		public function set openGestureEdgeSize(value:Number) : void {
			this._openGestureEdgeSize = value;
		}
		
		public function get contentEventDispatcherChangeEventType() : String {
			return this._contentEventDispatcherChangeEventType;
		}
		
		public function set contentEventDispatcherChangeEventType(value:String) : void {
			if(this._contentEventDispatcherChangeEventType == value) {
				return;
			}
			if(this._content && this._contentEventDispatcherChangeEventType) {
				this._content.removeEventListener(this._contentEventDispatcherChangeEventType,content_eventDispatcherChangeHandler);
			}
			this._contentEventDispatcherChangeEventType = value;
			if(this._content && this._contentEventDispatcherChangeEventType) {
				this._content.addEventListener(this._contentEventDispatcherChangeEventType,content_eventDispatcherChangeHandler);
			}
		}
		
		public function get contentEventDispatcherField() : String {
			return this._contentEventDispatcherField;
		}
		
		public function set contentEventDispatcherField(value:String) : void {
			if(this._contentEventDispatcherField == value) {
				return;
			}
			this._contentEventDispatcherField = value;
			this.invalidate("data");
		}
		
		public function get contentEventDispatcherFunction() : Function {
			return this._contentEventDispatcherFunction;
		}
		
		public function set contentEventDispatcherFunction(value:Function) : void {
			if(this._contentEventDispatcherFunction == value) {
				return;
			}
			this._contentEventDispatcherFunction = value;
			this.invalidate("data");
		}
		
		public function get openOrCloseDuration() : Number {
			return this._openOrCloseDuration;
		}
		
		public function set openOrCloseDuration(value:Number) : void {
			this._openOrCloseDuration = value;
		}
		
		public function get openOrCloseEase() : Object {
			return this._openOrCloseEase;
		}
		
		public function set openOrCloseEase(value:Object) : void {
			this._openOrCloseEase = value;
		}
		
		override public function hitTest(localPoint:Point) : DisplayObject {
			var _local2:DisplayObject = super.hitTest(localPoint);
			if(_local2) {
				if(this._isDragging) {
					return this;
				}
				if(this.isTopDrawerOpen && _local2 != this._topDrawer && !(this._topDrawer is DisplayObjectContainer && Boolean(DisplayObjectContainer(this._topDrawer).contains(_local2)))) {
					return this;
				}
				if(this.isRightDrawerOpen && _local2 != this._rightDrawer && !(this._rightDrawer is DisplayObjectContainer && Boolean(DisplayObjectContainer(this._rightDrawer).contains(_local2)))) {
					return this;
				}
				if(this.isBottomDrawerOpen && _local2 != this._bottomDrawer && !(this._bottomDrawer is DisplayObjectContainer && Boolean(DisplayObjectContainer(this._bottomDrawer).contains(_local2)))) {
					return this;
				}
				if(this.isLeftDrawerOpen && _local2 != this._leftDrawer && !(this._leftDrawer is DisplayObjectContainer && Boolean(DisplayObjectContainer(this._leftDrawer).contains(_local2)))) {
					return this;
				}
				return _local2;
			}
			if(!this.visible || !this.touchable) {
				return null;
			}
			return this._hitArea.contains(localPoint.x,localPoint.y) ? this : null;
		}
		
		public function toggleTopDrawer(duration:Number = NaN) : void {
			if(!this._topDrawer || this.isTopDrawerDocked) {
				return;
			}
			this.pendingToggleDuration = duration;
			if(this.isToggleTopDrawerPending) {
				return;
			}
			if(!this.isTopDrawerOpen) {
				this.isRightDrawerOpen = false;
				this.isBottomDrawerOpen = false;
				this.isLeftDrawerOpen = false;
			}
			this.isToggleTopDrawerPending = true;
			this.isToggleRightDrawerPending = false;
			this.isToggleBottomDrawerPending = false;
			this.isToggleLeftDrawerPending = false;
			this.invalidate("selected");
		}
		
		public function toggleRightDrawer(duration:Number = NaN) : void {
			if(!this._rightDrawer || this.isRightDrawerDocked) {
				return;
			}
			this.pendingToggleDuration = duration;
			if(this.isToggleRightDrawerPending) {
				return;
			}
			if(!this.isRightDrawerOpen) {
				this.isTopDrawerOpen = false;
				this.isBottomDrawerOpen = false;
				this.isLeftDrawerOpen = false;
			}
			this.isToggleTopDrawerPending = false;
			this.isToggleRightDrawerPending = true;
			this.isToggleBottomDrawerPending = false;
			this.isToggleLeftDrawerPending = false;
			this.invalidate("selected");
		}
		
		public function toggleBottomDrawer(duration:Number = NaN) : void {
			if(!this._bottomDrawer || this.isBottomDrawerDocked) {
				return;
			}
			this.pendingToggleDuration = duration;
			if(this.isToggleBottomDrawerPending) {
				return;
			}
			if(!this.isBottomDrawerOpen) {
				this.isTopDrawerOpen = false;
				this.isRightDrawerOpen = false;
				this.isLeftDrawerOpen = false;
			}
			this.isToggleTopDrawerPending = false;
			this.isToggleRightDrawerPending = false;
			this.isToggleBottomDrawerPending = true;
			this.isToggleLeftDrawerPending = false;
			this.invalidate("selected");
		}
		
		public function toggleLeftDrawer(duration:Number = NaN) : void {
			if(!this._leftDrawer || this.isLeftDrawerDocked) {
				return;
			}
			this.pendingToggleDuration = duration;
			if(this.isToggleLeftDrawerPending) {
				return;
			}
			if(!this.isLeftDrawerOpen) {
				this.isTopDrawerOpen = false;
				this.isRightDrawerOpen = false;
				this.isBottomDrawerOpen = false;
			}
			this.isToggleTopDrawerPending = false;
			this.isToggleRightDrawerPending = false;
			this.isToggleBottomDrawerPending = false;
			this.isToggleLeftDrawerPending = true;
			this.invalidate("selected");
		}
		
		override protected function draw() : void {
			var _local1:Boolean = this.isInvalid("size");
			var _local4:Boolean = this.isInvalid("data");
			var _local2:Boolean = this.isInvalid("layout");
			var _local3:Boolean = this.isInvalid("selected");
			if(_local4) {
				this.refreshCurrentEventTarget();
			}
			if(_local1 || _local2) {
				this.refreshDrawerStates();
			}
			if(_local1 || _local2 || _local3) {
				this.refreshOverlayState();
			}
			_local1 = this.autoSizeIfNeeded() || _local1;
			this.layoutChildren();
			this.handlePendingActions();
		}
		
		protected function autoSizeIfNeeded() : Boolean {
			var _local2:* = this._explicitWidth !== this._explicitWidth;
			var _local11:* = this._explicitHeight !== this._explicitHeight;
			var _local9:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local13:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local2 && !_local11 && !_local9 && !_local13) {
				return false;
			}
			var _local4:Boolean = this._autoSizeMode === "content" || !this.stage;
			var _local3:Boolean = this.isTopDrawerDocked;
			var _local7:Boolean = this.isRightDrawerDocked;
			var _local12:Boolean = this.isBottomDrawerDocked;
			var _local6:Boolean = this.isLeftDrawerDocked;
			if(_local4) {
				if(this._content) {
					this._content.validate();
					if(this._originalContentWidth !== this._originalContentWidth) {
						this._originalContentWidth = this._content.width;
					}
					if(this._originalContentHeight !== this._originalContentHeight) {
						this._originalContentHeight = this._content.height;
					}
				}
				if(_local3) {
					this._topDrawer.validate();
					if(this._originalTopDrawerWidth !== this._originalTopDrawerWidth) {
						this._originalTopDrawerWidth = this._topDrawer.width;
					}
					if(this._originalTopDrawerHeight !== this._originalTopDrawerHeight) {
						this._originalTopDrawerHeight = this._topDrawer.height;
					}
				}
				if(_local7) {
					this._rightDrawer.validate();
					if(this._originalRightDrawerWidth !== this._originalRightDrawerWidth) {
						this._originalRightDrawerWidth = this._rightDrawer.width;
					}
					if(this._originalRightDrawerHeight !== this._originalRightDrawerHeight) {
						this._originalRightDrawerHeight = this._rightDrawer.height;
					}
				}
				if(_local12) {
					this._bottomDrawer.validate();
					if(this._originalBottomDrawerWidth !== this._originalBottomDrawerWidth) {
						this._originalBottomDrawerWidth = this._bottomDrawer.width;
					}
					if(this._originalBottomDrawerHeight !== this._originalBottomDrawerHeight) {
						this._originalBottomDrawerHeight = this._bottomDrawer.height;
					}
				}
				if(_local6) {
					this._leftDrawer.validate();
					if(this._originalLeftDrawerWidth !== this._originalLeftDrawerWidth) {
						this._originalLeftDrawerWidth = this._leftDrawer.width;
					}
					if(this._originalLeftDrawerHeight !== this._originalLeftDrawerHeight) {
						this._originalLeftDrawerHeight = this._leftDrawer.height;
					}
				}
			}
			var _local1:Number = this._explicitWidth;
			if(_local2) {
				if(_local4) {
					if(this._content) {
						_local1 = this._originalContentWidth;
					} else {
						_local1 = 0;
					}
					if(_local6) {
						_local1 += this._originalLeftDrawerWidth;
					}
					if(_local7) {
						_local1 += this._originalRightDrawerWidth;
					}
					if(_local3 && this._originalTopDrawerWidth > _local1) {
						_local1 = this._originalTopDrawerWidth;
					}
					if(_local12 && this._originalBottomDrawerWidth > _local1) {
						_local1 = this._originalBottomDrawerWidth;
					}
				} else {
					_local1 = this.stage.stageWidth;
				}
			}
			var _local5:Number = this._explicitHeight;
			if(_local11) {
				if(_local4) {
					if(this._content) {
						_local5 = this._originalContentHeight;
					} else {
						_local5 = 0;
					}
					if(_local3) {
						_local5 += this._originalTopDrawerHeight;
					}
					if(_local12) {
						_local5 += this._originalBottomDrawerHeight;
					}
					if(_local6 && this._originalLeftDrawerHeight > _local5) {
						_local5 = this._originalLeftDrawerHeight;
					}
					if(_local7 && this._originalRightDrawerHeight > _local5) {
						_local5 = this._originalRightDrawerHeight;
					}
				} else {
					_local5 = this.stage.stageHeight;
				}
			}
			var _local8:Number = this._explicitMinWidth;
			if(_local9) {
				if(_local4) {
					_local8 = Number(this._content.minWidth);
					if(_local6) {
						_local8 += this._leftDrawer.minWidth;
					}
					if(_local7) {
						_local8 += this._rightDrawer.minWidth;
					}
					if(_local3 && this._topDrawer.minWidth > _local8) {
						_local8 = Number(this._topDrawer.minWidth);
					}
					if(_local12 && this._bottomDrawer.minWidth > _local8) {
						_local8 = Number(this._bottomDrawer.minWidth);
					}
				} else {
					_local8 = this.stage.stageWidth;
				}
			}
			var _local10:Number = this._explicitMinHeight;
			if(_local13) {
				if(_local4) {
					_local10 = Number(this._content.minHeight);
					if(_local3) {
						_local10 += this._topDrawer.minHeight;
					}
					if(_local12) {
						_local10 += this._bottomDrawer.minHeight;
					}
					if(_local6 && this._leftDrawer.minHeight > _local10) {
						_local10 = Number(this._leftDrawer.minHeight);
					}
					if(_local7 && this._rightDrawer.minHeight > _local10) {
						_local10 = Number(this._rightDrawer.minHeight);
					}
				} else {
					_local10 = this.stage.stageHeight;
				}
			}
			return this.saveMeasurements(_local1,_local5,_local8,_local10);
		}
		
		protected function layoutChildren() : void {
			var _local11:Number = NaN;
			var _local10:Number = NaN;
			var _local3:Number = NaN;
			var _local9:Number = NaN;
			var _local23:Number = NaN;
			var _local24:Number = NaN;
			var _local1:Number = NaN;
			var _local2:Number = NaN;
			var _local13:Boolean = this.isTopDrawerOpen;
			var _local4:Boolean = this.isRightDrawerOpen;
			var _local16:Boolean = this.isBottomDrawerOpen;
			var _local5:Boolean = this.isLeftDrawerOpen;
			var _local7:Boolean = this.isTopDrawerDocked;
			var _local18:Boolean = this.isRightDrawerDocked;
			var _local21:Boolean = this.isBottomDrawerDocked;
			var _local12:Boolean = this.isLeftDrawerDocked;
			var _local6:Number = 0;
			var _local22:Number = 0;
			if(this._topDrawer !== null) {
				this._topDrawer.width = this.actualWidth;
				this._topDrawer.validate();
				_local6 = Number(this._topDrawer.height);
				if(this._topDrawerDivider !== null) {
					this._topDrawerDivider.width = this._topDrawer.width;
					if(this._topDrawerDivider is IValidating) {
						IValidating(this._topDrawerDivider).validate();
					}
				}
			}
			if(this._bottomDrawer !== null) {
				this._bottomDrawer.width = this.actualWidth;
				this._bottomDrawer.validate();
				_local22 = Number(this._bottomDrawer.height);
				if(this._bottomDrawerDivider !== null) {
					this._bottomDrawerDivider.width = this._bottomDrawer.width;
					if(this._bottomDrawerDivider is IValidating) {
						IValidating(this._bottomDrawerDivider).validate();
					}
				}
			}
			var _local14:Number = this.actualHeight;
			if(_local7) {
				_local14 -= _local6;
				if(this._topDrawerDivider !== null) {
					_local14 -= this._topDrawerDivider.height;
				}
			}
			if(_local21) {
				_local14 -= _local22;
				if(this._bottomDrawerDivider !== null) {
					_local14 -= this._bottomDrawerDivider.height;
				}
			}
			if(_local14 < 0) {
				_local14 = 0;
			}
			var _local20:Number = 0;
			var _local8:Number = 0;
			if(this._rightDrawer !== null) {
				if(_local18) {
					this._rightDrawer.height = _local14;
				} else {
					this._rightDrawer.height = this.actualHeight;
				}
				this._rightDrawer.validate();
				_local20 = Number(this._rightDrawer.width);
				if(this._rightDrawerDivider !== null) {
					this._rightDrawerDivider.height = this._rightDrawer.height;
					if(this._rightDrawerDivider is IValidating) {
						IValidating(this._rightDrawerDivider).validate();
					}
				}
			}
			if(this._leftDrawer !== null) {
				if(_local12) {
					this._leftDrawer.height = _local14;
				} else {
					this._leftDrawer.height = this.actualHeight;
				}
				this._leftDrawer.validate();
				_local8 = Number(this._leftDrawer.width);
				if(this._leftDrawerDivider !== null) {
					this._leftDrawerDivider.height = this._leftDrawer.height;
					if(this._leftDrawerDivider is IValidating) {
						IValidating(this._leftDrawerDivider).validate();
					}
				}
			}
			var _local19:Number = this.actualWidth;
			if(_local12) {
				_local19 -= _local8;
				if(this._leftDrawerDivider !== null) {
					_local19 -= this._leftDrawerDivider.width;
				}
			}
			if(_local18) {
				_local19 -= _local20;
				if(this._rightDrawerDivider !== null) {
					_local19 -= this._rightDrawerDivider.width;
				}
			}
			if(_local19 < 0) {
				_local19 = 0;
			}
			var _local17:* = 0;
			if(_local4 && this._openMode === "below") {
				_local17 = -_local20;
				if(_local12) {
					_local17 += _local8;
					if(this._leftDrawerDivider) {
						_local17 += this._leftDrawerDivider.width;
					}
				}
			} else if(_local5 && this._openMode === "below" || _local12) {
				_local17 = _local8;
				if(this._leftDrawerDivider && _local12) {
					_local17 += this._leftDrawerDivider.width;
				}
			}
			this._content.x = _local17;
			var _local15:* = 0;
			if(_local16 && this._openMode === "below") {
				_local15 = -_local22;
				if(_local7) {
					_local15 += _local6;
					if(this._topDrawerDivider) {
						_local15 += this._topDrawerDivider.height;
					}
				}
			} else if(_local13 && this._openMode === "below" || _local7) {
				_local15 = _local6;
				if(this._topDrawerDivider && _local7) {
					_local15 += this._topDrawerDivider.height;
				}
			}
			this._content.y = _local15;
			if(this._autoSizeMode !== "content") {
				this._content.width = _local19;
				this._content.height = _local14;
				this._content.validate();
			}
			if(this._topDrawer !== null) {
				_local11 = 0;
				_local10 = 0;
				if(_local7) {
					if(_local16 && this._openMode === "below") {
						_local10 -= _local22;
					}
					if(!_local12) {
						_local11 = Number(this._content.x);
					}
				} else if(this._openMode === "above" && !this._isTopDrawerOpen) {
					_local10 -= _local6;
				}
				this._topDrawer.x = _local11;
				this._topDrawer.y = _local10;
				this._topDrawer.visible = _local13 || _local7 || this._isDraggingTopDrawer;
				if(this._topDrawerDivider !== null) {
					this._topDrawerDivider.visible = _local7;
					this._topDrawerDivider.x = _local11;
					this._topDrawerDivider.y = _local10 + _local6;
				}
				this._topDrawer.validate();
			}
			if(this._rightDrawer !== null) {
				_local3 = this.actualWidth - _local20;
				_local9 = 0;
				if(_local18) {
					_local3 = this._content.x + this._content.width;
					if(this._rightDrawerDivider) {
						_local3 += this._rightDrawerDivider.width;
					}
					_local9 = Number(this._content.y);
				} else if(this._openMode === "above" && !this._isRightDrawerOpen) {
					_local3 += _local20;
				}
				this._rightDrawer.x = _local3;
				this._rightDrawer.y = _local9;
				this._rightDrawer.visible = _local4 || _local18 || this._isDraggingRightDrawer;
				if(this._rightDrawerDivider !== null) {
					this._rightDrawerDivider.visible = _local18;
					this._rightDrawerDivider.x = _local3 - this._rightDrawerDivider.width;
					this._rightDrawerDivider.y = _local9;
				}
				this._rightDrawer.validate();
			}
			if(this._bottomDrawer !== null) {
				_local23 = 0;
				_local24 = this.actualHeight - _local22;
				if(_local21) {
					if(!_local12) {
						_local23 = Number(this._content.x);
					}
					_local24 = this._content.y + this._content.height;
					if(this._bottomDrawerDivider) {
						_local24 += this._bottomDrawerDivider.height;
					}
				} else if(this._openMode === "above" && !this._isBottomDrawerOpen) {
					_local24 += _local22;
				}
				this._bottomDrawer.x = _local23;
				this._bottomDrawer.y = _local24;
				this._bottomDrawer.visible = _local16 || _local21 || this._isDraggingBottomDrawer;
				if(this._bottomDrawerDivider !== null) {
					this._bottomDrawerDivider.visible = _local21;
					this._bottomDrawerDivider.x = _local23;
					this._bottomDrawerDivider.y = _local24 - this._bottomDrawerDivider.height;
				}
				this._bottomDrawer.validate();
			}
			if(this._leftDrawer !== null) {
				_local1 = 0;
				_local2 = 0;
				if(_local12) {
					if(_local4 && this._openMode === "below") {
						_local1 -= _local20;
					}
					_local2 = Number(this._content.y);
				} else if(this._openMode === "above" && !this._isLeftDrawerOpen) {
					_local1 -= _local8;
				}
				this._leftDrawer.x = _local1;
				this._leftDrawer.y = _local2;
				this._leftDrawer.visible = _local5 || _local12 || this._isDraggingLeftDrawer;
				if(this._leftDrawerDivider !== null) {
					this._leftDrawerDivider.visible = _local12;
					this._leftDrawerDivider.x = _local1 + _local8;
					this._leftDrawerDivider.y = _local2;
				}
				this._leftDrawer.validate();
			}
			if(this._overlaySkin !== null) {
				this.positionOverlaySkin();
				this._overlaySkin.width = this.actualWidth;
				this._overlaySkin.height = this.actualHeight;
				if(this._overlaySkin is IValidating) {
					IValidating(this._overlaySkin).validate();
				}
			}
		}
		
		protected function handlePendingActions() : void {
			if(this.isToggleTopDrawerPending) {
				this._isTopDrawerOpen = !this._isTopDrawerOpen;
				this.isToggleTopDrawerPending = false;
				this.openOrCloseTopDrawer();
			} else if(this.isToggleRightDrawerPending) {
				this._isRightDrawerOpen = !this._isRightDrawerOpen;
				this.isToggleRightDrawerPending = false;
				this.openOrCloseRightDrawer();
			} else if(this.isToggleBottomDrawerPending) {
				this._isBottomDrawerOpen = !this._isBottomDrawerOpen;
				this.isToggleBottomDrawerPending = false;
				this.openOrCloseBottomDrawer();
			} else if(this.isToggleLeftDrawerPending) {
				this._isLeftDrawerOpen = !this._isLeftDrawerOpen;
				this.isToggleLeftDrawerPending = false;
				this.openOrCloseLeftDrawer();
			}
		}
		
		protected function openOrCloseTopDrawer() : void {
			if(!this._topDrawer || this.isTopDrawerDocked) {
				return;
			}
			if(this._openOrCloseTween) {
				this._openOrCloseTween.advanceTime(this._openOrCloseTween.totalTime);
				Starling.juggler.remove(this._openOrCloseTween);
				this._openOrCloseTween = null;
			}
			this.prepareTopDrawer();
			if(this._overlaySkin) {
				this._overlaySkin.visible = true;
				if(this._isTopDrawerOpen) {
					this._overlaySkin.alpha = 0;
				} else {
					this._overlaySkin.alpha = this._overlaySkinOriginalAlpha;
				}
			}
			var _local2:Number = Number(this._isTopDrawerOpen ? this._topDrawer.height : 0);
			var _local1:Number = this.pendingToggleDuration;
			if(_local1 !== _local1) {
				_local1 = this._openOrCloseDuration;
			}
			this.pendingToggleDuration = NaN;
			if(this._openMode === "above") {
				_local2 = _local2 === 0 ? -this._topDrawer.height : 0;
				this._openOrCloseTween = new Tween(this._topDrawer,_local1,this._openOrCloseEase);
			} else {
				this._openOrCloseTween = new Tween(this._content,_local1,this._openOrCloseEase);
			}
			this._openOrCloseTween.animate("y",_local2);
			this._openOrCloseTween.onUpdate = topDrawerOpenOrCloseTween_onUpdate;
			this._openOrCloseTween.onComplete = topDrawerOpenOrCloseTween_onComplete;
			Starling.juggler.add(this._openOrCloseTween);
		}
		
		protected function openOrCloseRightDrawer() : void {
			if(!this._rightDrawer || this.isRightDrawerDocked) {
				return;
			}
			if(this._openOrCloseTween) {
				this._openOrCloseTween.advanceTime(this._openOrCloseTween.totalTime);
				Starling.juggler.remove(this._openOrCloseTween);
				this._openOrCloseTween = null;
			}
			this.prepareRightDrawer();
			if(this._overlaySkin) {
				this._overlaySkin.visible = true;
				if(this._isRightDrawerOpen) {
					this._overlaySkin.alpha = 0;
				} else {
					this._overlaySkin.alpha = this._overlaySkinOriginalAlpha;
				}
			}
			var _local2:Number = 0;
			if(this._isRightDrawerOpen) {
				_local2 = -this._rightDrawer.width;
			}
			if(this.isLeftDrawerDocked && this._openMode === "below") {
				_local2 += this._leftDrawer.width;
				if(this._leftDrawerDivider) {
					_local2 += this._leftDrawerDivider.width;
				}
			}
			var _local1:Number = this.pendingToggleDuration;
			if(_local1 !== _local1) {
				_local1 = this._openOrCloseDuration;
			}
			this.pendingToggleDuration = NaN;
			if(this._openMode === "above") {
				this._openOrCloseTween = new Tween(this._rightDrawer,_local1,this._openOrCloseEase);
				_local2 += this.actualWidth;
			} else {
				this._openOrCloseTween = new Tween(this._content,_local1,this._openOrCloseEase);
			}
			this._openOrCloseTween.animate("x",_local2);
			this._openOrCloseTween.onUpdate = rightDrawerOpenOrCloseTween_onUpdate;
			this._openOrCloseTween.onComplete = rightDrawerOpenOrCloseTween_onComplete;
			Starling.juggler.add(this._openOrCloseTween);
		}
		
		protected function openOrCloseBottomDrawer() : void {
			if(!this._bottomDrawer || this.isBottomDrawerDocked) {
				return;
			}
			if(this._openOrCloseTween) {
				this._openOrCloseTween.advanceTime(this._openOrCloseTween.totalTime);
				Starling.juggler.remove(this._openOrCloseTween);
				this._openOrCloseTween = null;
			}
			this.prepareBottomDrawer();
			if(this._overlaySkin) {
				this._overlaySkin.visible = true;
				if(this._isBottomDrawerOpen) {
					this._overlaySkin.alpha = 0;
				} else {
					this._overlaySkin.alpha = this._overlaySkinOriginalAlpha;
				}
			}
			var _local2:Number = 0;
			if(this._isBottomDrawerOpen) {
				_local2 = -this._bottomDrawer.height;
			}
			if(this.isTopDrawerDocked && this._openMode === "below") {
				_local2 += this._topDrawer.height;
				if(this._topDrawerDivider) {
					_local2 += this._topDrawerDivider.height;
				}
			}
			var _local1:Number = this.pendingToggleDuration;
			if(_local1 !== _local1) {
				_local1 = this._openOrCloseDuration;
			}
			this.pendingToggleDuration = NaN;
			if(this._openMode === "above") {
				_local2 += this.actualHeight;
				this._openOrCloseTween = new Tween(this._bottomDrawer,_local1,this._openOrCloseEase);
			} else {
				this._openOrCloseTween = new Tween(this._content,_local1,this._openOrCloseEase);
			}
			this._openOrCloseTween.animate("y",_local2);
			this._openOrCloseTween.onUpdate = bottomDrawerOpenOrCloseTween_onUpdate;
			this._openOrCloseTween.onComplete = bottomDrawerOpenOrCloseTween_onComplete;
			Starling.juggler.add(this._openOrCloseTween);
		}
		
		protected function openOrCloseLeftDrawer() : void {
			if(!this._leftDrawer || this.isLeftDrawerDocked) {
				return;
			}
			if(this._openOrCloseTween) {
				this._openOrCloseTween.advanceTime(this._openOrCloseTween.totalTime);
				Starling.juggler.remove(this._openOrCloseTween);
				this._openOrCloseTween = null;
			}
			this.prepareLeftDrawer();
			if(this._overlaySkin) {
				this._overlaySkin.visible = true;
				if(this._isLeftDrawerOpen) {
					this._overlaySkin.alpha = 0;
				} else {
					this._overlaySkin.alpha = this._overlaySkinOriginalAlpha;
				}
			}
			var _local2:Number = Number(this._isLeftDrawerOpen ? this._leftDrawer.width : 0);
			var _local1:Number = this.pendingToggleDuration;
			if(_local1 !== _local1) {
				_local1 = this._openOrCloseDuration;
			}
			this.pendingToggleDuration = NaN;
			if(this._openMode === "above") {
				_local2 = _local2 === 0 ? -this._leftDrawer.width : 0;
				this._openOrCloseTween = new Tween(this._leftDrawer,_local1,this._openOrCloseEase);
			} else {
				this._openOrCloseTween = new Tween(this._content,_local1,this._openOrCloseEase);
			}
			this._openOrCloseTween.animate("x",_local2);
			this._openOrCloseTween.onUpdate = leftDrawerOpenOrCloseTween_onUpdate;
			this._openOrCloseTween.onComplete = leftDrawerOpenOrCloseTween_onComplete;
			Starling.juggler.add(this._openOrCloseTween);
		}
		
		protected function prepareTopDrawer() : void {
			var _local1:Quad = null;
			this._topDrawer.visible = true;
			if(this._openMode === "above") {
				if(this._overlaySkin) {
					this.setChildIndex(this._overlaySkin,this.numChildren - 1);
				}
				this.setChildIndex(DisplayObject(this._topDrawer),this.numChildren - 1);
			}
			if(!this._clipDrawers || this._openMode !== "below") {
				return;
			}
			if(this._topDrawer.mask === null) {
				_local1 = new Quad(1,1,0xff00ff);
				_local1.width = this.actualWidth;
				_local1.height = this._content.y;
				this._topDrawer.mask = _local1;
			}
		}
		
		protected function prepareRightDrawer() : void {
			var _local1:Quad = null;
			this._rightDrawer.visible = true;
			if(this._openMode === "above") {
				if(this._overlaySkin) {
					this.setChildIndex(this._overlaySkin,this.numChildren - 1);
				}
				this.setChildIndex(DisplayObject(this._rightDrawer),this.numChildren - 1);
			}
			if(!this._clipDrawers || this._openMode !== "below") {
				return;
			}
			if(this._rightDrawer.mask === null) {
				_local1 = new Quad(1,1,0xff00ff);
				if(this.isLeftDrawerDocked) {
					_local1.width = -this._leftDrawer.x;
				} else {
					_local1.width = -this._content.x;
				}
				_local1.height = this.actualHeight;
				this._rightDrawer.mask = _local1;
			}
		}
		
		protected function prepareBottomDrawer() : void {
			var _local1:Quad = null;
			this._bottomDrawer.visible = true;
			if(this._openMode === "above") {
				if(this._overlaySkin) {
					this.setChildIndex(this._overlaySkin,this.numChildren - 1);
				}
				this.setChildIndex(DisplayObject(this._bottomDrawer),this.numChildren - 1);
			}
			if(!this._clipDrawers || this._openMode !== "below") {
				return;
			}
			if(this._bottomDrawer.mask === null) {
				_local1 = new Quad(1,1,0xff00ff);
				_local1.width = this.actualWidth;
				if(this.isTopDrawerDocked) {
					_local1.height = -this._topDrawer.y;
				} else {
					_local1.height = -this._content.y;
				}
				this._bottomDrawer.mask = _local1;
			}
		}
		
		protected function prepareLeftDrawer() : void {
			var _local1:Quad = null;
			this._leftDrawer.visible = true;
			if(this._openMode === "above") {
				if(this._overlaySkin) {
					this.setChildIndex(this._overlaySkin,this.numChildren - 1);
				}
				this.setChildIndex(DisplayObject(this._leftDrawer),this.numChildren - 1);
			}
			if(!this._clipDrawers || this._openMode !== "below") {
				return;
			}
			if(this._leftDrawer.mask === null) {
				_local1 = new Quad(1,1,0xff00ff);
				_local1.width = this._content.x;
				_local1.height = this.actualHeight;
				this._leftDrawer.mask = _local1;
			}
		}
		
		protected function contentToContentEventDispatcher() : EventDispatcher {
			if(this._contentEventDispatcherFunction !== null) {
				return this._contentEventDispatcherFunction(this._content) as EventDispatcher;
			}
			if(this._contentEventDispatcherField !== null && this._content && this._contentEventDispatcherField in this._content) {
				return this._content[this._contentEventDispatcherField] as EventDispatcher;
			}
			return this._content as EventDispatcher;
		}
		
		protected function refreshCurrentEventTarget() : void {
			if(this.contentEventDispatcher) {
				if(this._topDrawerToggleEventType) {
					this.contentEventDispatcher.removeEventListener(this._topDrawerToggleEventType,content_topDrawerToggleEventTypeHandler);
				}
				if(this._rightDrawerToggleEventType) {
					this.contentEventDispatcher.removeEventListener(this._rightDrawerToggleEventType,content_rightDrawerToggleEventTypeHandler);
				}
				if(this._bottomDrawerToggleEventType) {
					this.contentEventDispatcher.removeEventListener(this._bottomDrawerToggleEventType,content_bottomDrawerToggleEventTypeHandler);
				}
				if(this._leftDrawerToggleEventType) {
					this.contentEventDispatcher.removeEventListener(this._leftDrawerToggleEventType,content_leftDrawerToggleEventTypeHandler);
				}
			}
			this.contentEventDispatcher = this.contentToContentEventDispatcher();
			if(this.contentEventDispatcher) {
				if(this._topDrawerToggleEventType) {
					this.contentEventDispatcher.addEventListener(this._topDrawerToggleEventType,content_topDrawerToggleEventTypeHandler);
				}
				if(this._rightDrawerToggleEventType) {
					this.contentEventDispatcher.addEventListener(this._rightDrawerToggleEventType,content_rightDrawerToggleEventTypeHandler);
				}
				if(this._bottomDrawerToggleEventType) {
					this.contentEventDispatcher.addEventListener(this._bottomDrawerToggleEventType,content_bottomDrawerToggleEventTypeHandler);
				}
				if(this._leftDrawerToggleEventType) {
					this.contentEventDispatcher.addEventListener(this._leftDrawerToggleEventType,content_leftDrawerToggleEventTypeHandler);
				}
			}
		}
		
		protected function refreshDrawerStates() : void {
			if(this.isTopDrawerDocked && this._isTopDrawerOpen) {
				this._isTopDrawerOpen = false;
			}
			if(this.isRightDrawerDocked && this._isRightDrawerOpen) {
				this._isRightDrawerOpen = false;
			}
			if(this.isBottomDrawerDocked && this._isBottomDrawerOpen) {
				this._isBottomDrawerOpen = false;
			}
			if(this.isLeftDrawerDocked && this._isLeftDrawerOpen) {
				this._isLeftDrawerOpen = false;
			}
		}
		
		protected function refreshOverlayState() : void {
			if(!this._overlaySkin || this._isDragging) {
				return;
			}
			var _local1:Boolean = this._isTopDrawerOpen && !this.isTopDrawerDocked || this._isRightDrawerOpen && !this.isRightDrawerDocked || this._isBottomDrawerOpen && !this.isBottomDrawerDocked || this._isLeftDrawerOpen && !this.isLeftDrawerDocked;
			if(_local1 !== this._overlaySkin.visible) {
				this._overlaySkin.visible = _local1;
				this._overlaySkin.alpha = _local1 ? this._overlaySkinOriginalAlpha : 0;
			}
		}
		
		protected function handleTapToClose(touch:Touch) : void {
			touch.getLocation(this.stage,HELPER_POINT);
			if(this !== this.stage.hitTest(HELPER_POINT)) {
				return;
			}
			if(this.isTopDrawerOpen) {
				this._isTopDrawerOpen = false;
				this.openOrCloseTopDrawer();
			} else if(this.isRightDrawerOpen) {
				this._isRightDrawerOpen = false;
				this.openOrCloseRightDrawer();
			} else if(this.isBottomDrawerOpen) {
				this._isBottomDrawerOpen = false;
				this.openOrCloseBottomDrawer();
			} else if(this.isLeftDrawerOpen) {
				this._isLeftDrawerOpen = false;
				this.openOrCloseLeftDrawer();
			}
		}
		
		protected function handleTouchBegan(touch:Touch) : void {
			var _local7:Boolean = false;
			var _local2:Number = NaN;
			var _local8:Number = NaN;
			var _local9:Number = NaN;
			var _local6:Number = NaN;
			var _local3:ExclusiveTouch = ExclusiveTouch.forStage(this.stage);
			if(_local3.getClaim(touch.id)) {
				return;
			}
			touch.getLocation(this,HELPER_POINT);
			var _local5:Number = HELPER_POINT.x;
			var _local4:Number = HELPER_POINT.y;
			if(!this.isTopDrawerOpen && !this.isRightDrawerOpen && !this.isBottomDrawerOpen && !this.isLeftDrawerOpen) {
				if(this._openGesture === "none") {
					return;
				}
				if(this._openGesture === "edge") {
					_local7 = false;
					if(this._topDrawer && !this.isTopDrawerDocked) {
						_local2 = _local4 / (DeviceCapabilities.dpi / Starling.contentScaleFactor);
						if(_local2 >= 0 && _local2 <= this._openGestureEdgeSize) {
							_local7 = true;
						}
					}
					if(!_local7) {
						if(this._rightDrawer && !this.isRightDrawerDocked) {
							_local8 = (this.actualWidth - _local5) / (DeviceCapabilities.dpi / Starling.contentScaleFactor);
							if(_local8 >= 0 && _local8 <= this._openGestureEdgeSize) {
								_local7 = true;
							}
						}
						if(!_local7) {
							if(this._bottomDrawer && !this.isBottomDrawerDocked) {
								_local9 = (this.actualHeight - _local4) / (DeviceCapabilities.dpi / Starling.contentScaleFactor);
								if(_local9 >= 0 && _local9 <= this._openGestureEdgeSize) {
									_local7 = true;
								}
							}
							if(!_local7) {
								if(this._leftDrawer && !this.isLeftDrawerDocked) {
									_local6 = _local5 / (DeviceCapabilities.dpi / Starling.contentScaleFactor);
									if(_local6 >= 0 && _local6 <= this._openGestureEdgeSize) {
										_local7 = true;
									}
								}
							}
						}
					}
					if(!_local7) {
						return;
					}
				}
			} else if(this._openMode === "below" && touch.target !== this) {
				return;
			}
			this.touchPointID = touch.id;
			this._velocityX = 0;
			this._velocityY = 0;
			this._previousVelocityX.length = 0;
			this._previousVelocityY.length = 0;
			this._previousTouchTime = getTimer();
			this._previousTouchX = this._startTouchX = this._currentTouchX = _local5;
			this._previousTouchY = this._startTouchY = this._currentTouchY = _local4;
			this._isDragging = false;
			this._isDraggingTopDrawer = false;
			this._isDraggingRightDrawer = false;
			this._isDraggingBottomDrawer = false;
			this._isDraggingLeftDrawer = false;
			_local3.addEventListener("change",exclusiveTouch_changeHandler);
		}
		
		protected function handleTouchMoved(touch:Touch) : void {
			touch.getLocation(this,HELPER_POINT);
			this._currentTouchX = HELPER_POINT.x;
			this._currentTouchY = HELPER_POINT.y;
			var _local2:int = getTimer();
			var _local3:int = _local2 - this._previousTouchTime;
			if(_local3 > 0) {
				this._previousVelocityX[this._previousVelocityX.length] = this._velocityX;
				if(this._previousVelocityX.length > 4) {
					this._previousVelocityX.shift();
				}
				this._previousVelocityY[this._previousVelocityY.length] = this._velocityY;
				if(this._previousVelocityY.length > 4) {
					this._previousVelocityY.shift();
				}
				this._velocityX = (this._currentTouchX - this._previousTouchX) / _local3;
				this._velocityY = (this._currentTouchY - this._previousTouchY) / _local3;
				this._previousTouchTime = _local2;
				this._previousTouchX = this._currentTouchX;
				this._previousTouchY = this._currentTouchY;
			}
		}
		
		protected function handleDragEnd() : void {
			var _local5:int = 0;
			var _local6:Number = NaN;
			var _local2:Number = NaN;
			var _local7:Number = this._velocityX * 2.33;
			var _local1:int = int(this._previousVelocityX.length);
			var _local4:Number = 2.33;
			_local5 = 0;
			while(_local5 < _local1) {
				_local6 = VELOCITY_WEIGHTS[_local5];
				_local7 += this._previousVelocityX.shift() * _local6;
				_local4 += _local6;
				_local5++;
			}
			var _local3:Number = 1000 * (_local7 / _local4) / (DeviceCapabilities.dpi / Starling.contentScaleFactor);
			_local7 = this._velocityY * 2.33;
			_local1 = int(this._previousVelocityY.length);
			_local4 = 2.33;
			_local5 = 0;
			while(_local5 < _local1) {
				_local6 = VELOCITY_WEIGHTS[_local5];
				_local7 += this._previousVelocityY.shift() * _local6;
				_local4 += _local6;
				_local5++;
			}
			var _local8:Number = 1000 * (_local7 / _local4) / (DeviceCapabilities.dpi / Starling.contentScaleFactor);
			this._isDragging = false;
			if(this._isDraggingTopDrawer) {
				this._isDraggingTopDrawer = false;
				if(!this._isTopDrawerOpen && _local8 > this._minimumDrawerThrowVelocity) {
					this._isTopDrawerOpen = true;
				} else if(this._isTopDrawerOpen && _local8 < -this._minimumDrawerThrowVelocity) {
					this._isTopDrawerOpen = false;
				} else if(this._openMode === "above") {
					this._isTopDrawerOpen = roundToNearest(this._topDrawer.y,this._topDrawer.height) == 0;
				} else {
					this._isTopDrawerOpen = roundToNearest(this._content.y,this._topDrawer.height) != 0;
				}
				this.openOrCloseTopDrawer();
			} else if(this._isDraggingRightDrawer) {
				this._isDraggingRightDrawer = false;
				if(!this._isRightDrawerOpen && _local3 < -this._minimumDrawerThrowVelocity) {
					this._isRightDrawerOpen = true;
				} else if(this._isRightDrawerOpen && _local3 > this._minimumDrawerThrowVelocity) {
					this._isRightDrawerOpen = false;
				} else if(this._openMode === "above") {
					this._isRightDrawerOpen = roundToNearest(this.actualWidth - this._rightDrawer.x,this._rightDrawer.width) != 0;
				} else {
					_local2 = Number(this._content.x);
					if(this.isLeftDrawerDocked) {
						_local2 -= this._leftDrawer.width;
					}
					this._isRightDrawerOpen = roundToNearest(_local2,this._rightDrawer.width) != 0;
				}
				this.openOrCloseRightDrawer();
			} else if(this._isDraggingBottomDrawer) {
				this._isDraggingBottomDrawer = false;
				if(!this._isBottomDrawerOpen && _local8 < -this._minimumDrawerThrowVelocity) {
					this._isBottomDrawerOpen = true;
				} else if(this._isBottomDrawerOpen && _local8 > this._minimumDrawerThrowVelocity) {
					this._isBottomDrawerOpen = false;
				} else if(this._openMode === "above") {
					this._isBottomDrawerOpen = roundToNearest(this.actualHeight - this._bottomDrawer.y,this._bottomDrawer.height) != 0;
				} else {
					_local2 = Number(this._content.y);
					if(this.isTopDrawerDocked) {
						_local2 -= this._topDrawer.height;
					}
					this._isBottomDrawerOpen = roundToNearest(_local2,this._bottomDrawer.height) != 0;
				}
				this.openOrCloseBottomDrawer();
			} else if(this._isDraggingLeftDrawer) {
				this._isDraggingLeftDrawer = false;
				if(!this._isLeftDrawerOpen && _local3 > this._minimumDrawerThrowVelocity) {
					this._isLeftDrawerOpen = true;
				} else if(this._isLeftDrawerOpen && _local3 < -this._minimumDrawerThrowVelocity) {
					this._isLeftDrawerOpen = false;
				} else if(this._openMode === "above") {
					this._isLeftDrawerOpen = roundToNearest(this._leftDrawer.x,this._leftDrawer.width) == 0;
				} else {
					this._isLeftDrawerOpen = roundToNearest(this._content.x,this._leftDrawer.width) != 0;
				}
				this.openOrCloseLeftDrawer();
			}
		}
		
		protected function handleDragMove() : void {
			var _local3:Number = NaN;
			var _local4:Number = NaN;
			var _local2:Number = NaN;
			var _local5:Number = NaN;
			var _local1:* = 0;
			var _local6:* = 0;
			if(this.isLeftDrawerDocked) {
				_local1 = Number(this._leftDrawer.width);
				if(this._leftDrawerDivider !== null) {
					_local1 += this._leftDrawerDivider.width;
				}
			}
			if(this.isTopDrawerDocked) {
				_local6 = Number(this._topDrawer.height);
				if(this._topDrawerDivider !== null) {
					_local6 += this._topDrawerDivider.height;
				}
			}
			if(this._isDraggingLeftDrawer) {
				_local3 = Number(this._leftDrawer.width);
				if(this.isLeftDrawerOpen) {
					_local1 = _local3 + this._currentTouchX - this._startTouchX;
				} else {
					_local1 = this._currentTouchX - this._startTouchX;
				}
				if(_local1 < 0) {
					_local1 = 0;
				}
				if(_local1 > _local3) {
					_local1 = _local3;
				}
			} else if(this._isDraggingRightDrawer) {
				_local4 = Number(this._rightDrawer.width);
				if(this.isRightDrawerOpen) {
					_local1 = -_local4 + this._currentTouchX - this._startTouchX;
				} else {
					_local1 = this._currentTouchX - this._startTouchX;
				}
				if(_local1 < -_local4) {
					_local1 = -_local4;
				}
				if(_local1 > 0) {
					_local1 = 0;
				}
				if(this.isLeftDrawerDocked && this._openMode === "below") {
					_local1 += this._leftDrawer.width;
					if(this._leftDrawerDivider !== null) {
						_local1 += this._leftDrawerDivider.width;
					}
				}
			} else if(this._isDraggingTopDrawer) {
				_local2 = Number(this._topDrawer.height);
				if(this.isTopDrawerOpen) {
					_local6 = _local2 + this._currentTouchY - this._startTouchY;
				} else {
					_local6 = this._currentTouchY - this._startTouchY;
				}
				if(_local6 < 0) {
					_local6 = 0;
				}
				if(_local6 > _local2) {
					_local6 = _local2;
				}
			} else if(this._isDraggingBottomDrawer) {
				_local5 = Number(this._bottomDrawer.height);
				if(this.isBottomDrawerOpen) {
					_local6 = -_local5 + this._currentTouchY - this._startTouchY;
				} else {
					_local6 = this._currentTouchY - this._startTouchY;
				}
				if(_local6 < -_local5) {
					_local6 = -_local5;
				}
				if(_local6 > 0) {
					_local6 = 0;
				}
				if(this.isTopDrawerDocked && this._openMode === "below") {
					_local6 += this._topDrawer.height;
					if(this._topDrawerDivider !== null) {
						_local6 += this._topDrawerDivider.height;
					}
				}
			}
			if(this._openMode === "above") {
				if(this._isDraggingTopDrawer) {
					this._topDrawer.y = _local6 - this._topDrawer.height;
				} else if(this._isDraggingRightDrawer) {
					this._rightDrawer.x = this.actualWidth + _local1;
				} else if(this._isDraggingBottomDrawer) {
					this._bottomDrawer.y = this.actualHeight + _local6;
				} else if(this._isDraggingLeftDrawer) {
					this._leftDrawer.x = _local1 - this._leftDrawer.width;
				}
			} else {
				this._content.x = _local1;
				this._content.y = _local6;
			}
			if(this._isDraggingTopDrawer) {
				this.topDrawerOpenOrCloseTween_onUpdate();
			} else if(this._isDraggingRightDrawer) {
				this.rightDrawerOpenOrCloseTween_onUpdate();
			} else if(this._isDraggingBottomDrawer) {
				this.bottomDrawerOpenOrCloseTween_onUpdate();
			} else if(this._isDraggingLeftDrawer) {
				this.leftDrawerOpenOrCloseTween_onUpdate();
			}
		}
		
		protected function checkForDragToClose() : void {
			var _local1:ExclusiveTouch = null;
			var _local2:Number = (this._currentTouchX - this._startTouchX) / (DeviceCapabilities.dpi / Starling.contentScaleFactor);
			var _local3:Number = (this._currentTouchY - this._startTouchY) / (DeviceCapabilities.dpi / Starling.contentScaleFactor);
			if(this.isLeftDrawerOpen && _local2 <= -this._minimumDragDistance) {
				this._isDragging = true;
				this._isDraggingLeftDrawer = true;
				this.prepareLeftDrawer();
			} else if(this.isRightDrawerOpen && _local2 >= this._minimumDragDistance) {
				this._isDragging = true;
				this._isDraggingRightDrawer = true;
				this.prepareRightDrawer();
			} else if(this.isTopDrawerOpen && _local3 <= -this._minimumDragDistance) {
				this._isDragging = true;
				this._isDraggingTopDrawer = true;
				this.prepareTopDrawer();
			} else if(this.isBottomDrawerOpen && _local3 >= this._minimumDragDistance) {
				this._isDragging = true;
				this._isDraggingBottomDrawer = true;
				this.prepareBottomDrawer();
			}
			if(this._isDragging) {
				if(this._overlaySkin) {
					this._overlaySkin.visible = true;
					this._overlaySkin.alpha = this._overlaySkinOriginalAlpha;
				}
				this._startTouchX = this._currentTouchX;
				this._startTouchY = this._currentTouchY;
				_local1 = ExclusiveTouch.forStage(this.stage);
				_local1.removeEventListener("change",exclusiveTouch_changeHandler);
				_local1.claimTouch(this.touchPointID,this);
				this.dispatchEventWith("beginInteraction");
			}
		}
		
		protected function checkForDragToOpen() : void {
			var _local1:ExclusiveTouch = null;
			var _local2:Number = (this._currentTouchX - this._startTouchX) / (DeviceCapabilities.dpi / Starling.contentScaleFactor);
			var _local3:Number = (this._currentTouchY - this._startTouchY) / (DeviceCapabilities.dpi / Starling.contentScaleFactor);
			if(this._leftDrawer && !this.isLeftDrawerDocked && _local2 >= this._minimumDragDistance) {
				this._isDragging = true;
				this._isDraggingLeftDrawer = true;
				this.prepareLeftDrawer();
			} else if(this._rightDrawer && !this.isRightDrawerDocked && _local2 <= -this._minimumDragDistance) {
				this._isDragging = true;
				this._isDraggingRightDrawer = true;
				this.prepareRightDrawer();
			} else if(this._topDrawer && !this.isTopDrawerDocked && _local3 >= this._minimumDragDistance) {
				this._isDragging = true;
				this._isDraggingTopDrawer = true;
				this.prepareTopDrawer();
			} else if(this._bottomDrawer && !this.isBottomDrawerDocked && _local3 <= -this._minimumDragDistance) {
				this._isDragging = true;
				this._isDraggingBottomDrawer = true;
				this.prepareBottomDrawer();
			}
			if(this._isDragging) {
				if(this._overlaySkin) {
					this._overlaySkin.visible = true;
					this._overlaySkin.alpha = 0;
				}
				this._startTouchX = this._currentTouchX;
				this._startTouchY = this._currentTouchY;
				_local1 = ExclusiveTouch.forStage(this.stage);
				_local1.claimTouch(this.touchPointID,this);
				_local1.removeEventListener("change",exclusiveTouch_changeHandler);
				this.dispatchEventWith("beginInteraction");
			}
		}
		
		protected function positionOverlaySkin() : void {
			if(!this._overlaySkin) {
				return;
			}
			if(this.isLeftDrawerDocked) {
				this._overlaySkin.x = this._leftDrawer.x;
			} else if(this._openMode === "above" && this._leftDrawer) {
				this._overlaySkin.x = this._leftDrawer.x + this._leftDrawer.width;
			} else {
				this._overlaySkin.x = this._content.x;
			}
			if(this.isTopDrawerDocked) {
				this._overlaySkin.y = this._topDrawer.y;
			} else if(this._openMode === "above" && this._topDrawer) {
				this._overlaySkin.y = this._topDrawer.y + this._topDrawer.height;
			} else {
				this._overlaySkin.y = this._content.y;
			}
		}
		
		protected function topDrawerOpenOrCloseTween_onUpdate() : void {
			var _local1:Number = NaN;
			if(this._overlaySkin) {
				if(this._openMode === "above") {
					_local1 = 1 + this._topDrawer.y / this._topDrawer.height;
				} else {
					_local1 = this._content.y / this._topDrawer.height;
				}
				this._overlaySkin.alpha = this._overlaySkinOriginalAlpha * _local1;
			}
			this.openOrCloseTween_onUpdate();
		}
		
		protected function rightDrawerOpenOrCloseTween_onUpdate() : void {
			var _local1:Number = NaN;
			if(this._overlaySkin) {
				if(this._openMode === "above") {
					_local1 = -(this._rightDrawer.x - this.actualWidth) / this._rightDrawer.width;
				} else {
					_local1 = (this.actualWidth - this._content.x - this._content.width) / this._rightDrawer.width;
				}
				this._overlaySkin.alpha = this._overlaySkinOriginalAlpha * _local1;
			}
			this.openOrCloseTween_onUpdate();
		}
		
		protected function bottomDrawerOpenOrCloseTween_onUpdate() : void {
			var _local1:Number = NaN;
			if(this._overlaySkin) {
				if(this._openMode === "above") {
					_local1 = -(this._bottomDrawer.y - this.actualHeight) / this._bottomDrawer.height;
				} else {
					_local1 = (this.actualHeight - this._content.y - this._content.height) / this._bottomDrawer.height;
				}
				this._overlaySkin.alpha = this._overlaySkinOriginalAlpha * _local1;
			}
			this.openOrCloseTween_onUpdate();
		}
		
		protected function leftDrawerOpenOrCloseTween_onUpdate() : void {
			var _local1:Number = NaN;
			if(this._overlaySkin) {
				if(this._openMode === "above") {
					_local1 = 1 + this._leftDrawer.x / this._leftDrawer.width;
				} else {
					_local1 = this._content.x / this._leftDrawer.width;
				}
				this._overlaySkin.alpha = this._overlaySkinOriginalAlpha * _local1;
			}
			this.openOrCloseTween_onUpdate();
		}
		
		protected function openOrCloseTween_onUpdate() : void {
			var _local5:Boolean = false;
			var _local3:Boolean = false;
			var _local7:Boolean = false;
			var _local6:Boolean = false;
			var _local1:Number = NaN;
			var _local9:Number = NaN;
			var _local2:Number = NaN;
			var _local10:Quad = null;
			var _local4:Number = NaN;
			var _local8:Number = NaN;
			if(this._clipDrawers && this._openMode === "below") {
				_local5 = this.isTopDrawerDocked;
				_local3 = this.isRightDrawerDocked;
				_local7 = this.isBottomDrawerDocked;
				_local6 = this.isLeftDrawerDocked;
				_local1 = Number(this._content.x);
				_local9 = Number(this._content.y);
				if(_local5) {
					if(_local6) {
						_local2 = Number(this._leftDrawer.width);
						if(this._leftDrawerDivider !== null) {
							_local2 += this._leftDrawerDivider.width;
						}
						this._topDrawer.x = _local1 - _local2;
					} else {
						this._topDrawer.x = _local1;
					}
					if(this._topDrawerDivider !== null) {
						this._topDrawerDivider.x = this._topDrawer.x;
						this._topDrawerDivider.y = _local9 - this._topDrawerDivider.height;
						this._topDrawer.y = this._topDrawerDivider.y - this._topDrawer.height;
					} else {
						this._topDrawer.y = _local9 - this._topDrawer.height;
					}
				}
				if(_local3) {
					if(this._rightDrawerDivider !== null) {
						this._rightDrawerDivider.x = _local1 + this._content.width;
						this._rightDrawer.x = this._rightDrawerDivider.x + this._rightDrawerDivider.width;
						this._rightDrawerDivider.y = _local9;
					} else {
						this._rightDrawer.x = _local1 + this._content.width;
					}
					this._rightDrawer.y = _local9;
				}
				if(_local7) {
					if(_local6) {
						_local2 = Number(this._leftDrawer.width);
						if(this._leftDrawerDivider !== null) {
							_local2 += this._leftDrawerDivider.width;
						}
						this._bottomDrawer.x = _local1 - _local2;
					} else {
						this._bottomDrawer.x = _local1;
					}
					if(this._bottomDrawerDivider !== null) {
						this._bottomDrawerDivider.x = this._bottomDrawer.x;
						this._bottomDrawerDivider.y = _local9 + this._content.height;
						this._bottomDrawer.y = this._bottomDrawerDivider.y + this._bottomDrawerDivider.height;
					} else {
						this._bottomDrawer.y = _local9 + this._content.height;
					}
				}
				if(_local6) {
					if(this._leftDrawerDivider !== null) {
						this._leftDrawerDivider.x = _local1 - this._leftDrawerDivider.width;
						this._leftDrawer.x = this._leftDrawerDivider.x - this._leftDrawer.width;
						this._leftDrawerDivider.y = _local9;
					} else {
						this._leftDrawer.x = _local1 - this._leftDrawer.width;
					}
					this._leftDrawer.y = _local9;
				}
				if(this._topDrawer !== null) {
					_local10 = this._topDrawer.mask as Quad;
					if(_local10 !== null) {
						_local10.height = _local9;
					}
				}
				if(this._rightDrawer !== null) {
					_local10 = this._rightDrawer.mask as Quad;
					if(_local10 !== null) {
						_local4 = -_local1;
						if(_local6) {
							_local4 = -this._leftDrawer.x;
						}
						_local10.x = this._rightDrawer.width - _local4;
						_local10.width = _local4;
					}
				}
				if(this._bottomDrawer !== null) {
					_local10 = this._bottomDrawer.mask as Quad;
					if(_local10 !== null) {
						_local8 = -_local9;
						if(_local5) {
							_local8 = -this._topDrawer.y;
						}
						_local10.y = this._bottomDrawer.height - _local8;
						_local10.height = _local8;
					}
				}
				if(this._leftDrawer !== null) {
					_local10 = this._leftDrawer.mask as Quad;
					if(_local10 !== null) {
						_local10.width = _local1;
					}
				}
			}
			if(this._overlaySkin !== null) {
				this.positionOverlaySkin();
			}
		}
		
		protected function topDrawerOpenOrCloseTween_onComplete() : void {
			if(this._overlaySkin) {
				this._overlaySkin.alpha = this._overlaySkinOriginalAlpha;
			}
			this._openOrCloseTween = null;
			this._topDrawer.mask = null;
			var _local2:Boolean = this.isTopDrawerOpen;
			var _local1:Boolean = this.isTopDrawerDocked;
			this._topDrawer.visible = _local2 || _local1;
			if(this._overlaySkin) {
				this._overlaySkin.visible = _local2;
			}
			if(_local2) {
				this.dispatchEventWith("open",false,this._topDrawer);
			} else {
				this.dispatchEventWith("close",false,this._topDrawer);
			}
		}
		
		protected function rightDrawerOpenOrCloseTween_onComplete() : void {
			this._openOrCloseTween = null;
			this._rightDrawer.mask = null;
			var _local2:Boolean = this.isRightDrawerOpen;
			var _local1:Boolean = this.isRightDrawerDocked;
			this._rightDrawer.visible = _local2 || _local1;
			if(this._overlaySkin) {
				this._overlaySkin.visible = _local2;
			}
			if(_local2) {
				this.dispatchEventWith("open",false,this._rightDrawer);
			} else {
				this.dispatchEventWith("close",false,this._rightDrawer);
			}
		}
		
		protected function bottomDrawerOpenOrCloseTween_onComplete() : void {
			this._openOrCloseTween = null;
			this._bottomDrawer.mask = null;
			var _local1:Boolean = this.isBottomDrawerOpen;
			var _local2:Boolean = this.isBottomDrawerDocked;
			this._bottomDrawer.visible = _local1 || _local2;
			if(this._overlaySkin) {
				this._overlaySkin.visible = _local1;
			}
			if(_local1) {
				this.dispatchEventWith("open",false,this._bottomDrawer);
			} else {
				this.dispatchEventWith("close",false,this._bottomDrawer);
			}
		}
		
		protected function leftDrawerOpenOrCloseTween_onComplete() : void {
			this._openOrCloseTween = null;
			this._leftDrawer.mask = null;
			var _local1:Boolean = this.isLeftDrawerOpen;
			var _local2:Boolean = this.isLeftDrawerDocked;
			this._leftDrawer.visible = _local1 || _local2;
			if(this._overlaySkin) {
				this._overlaySkin.visible = _local1;
			}
			if(_local1) {
				this.dispatchEventWith("open",false,this._leftDrawer);
			} else {
				this.dispatchEventWith("close",false,this._leftDrawer);
			}
		}
		
		protected function content_eventDispatcherChangeHandler(event:Event) : void {
			this.refreshCurrentEventTarget();
		}
		
		protected function drawers_addedToStageHandler(event:Event) : void {
			this.stage.addEventListener("resize",stage_resizeHandler);
			var _local2:int = -getDisplayObjectDepthFromStage(this);
			Starling.current.nativeStage.addEventListener("keyDown",drawers_nativeStage_keyDownHandler,false,_local2,true);
		}
		
		protected function drawers_removedFromStageHandler(event:Event) : void {
			var _local2:ExclusiveTouch = null;
			if(this.touchPointID >= 0) {
				_local2 = ExclusiveTouch.forStage(this.stage);
				_local2.removeEventListener("change",exclusiveTouch_changeHandler);
			}
			this.touchPointID = -1;
			this._isDragging = false;
			this._isDraggingTopDrawer = false;
			this._isDraggingRightDrawer = false;
			this._isDraggingBottomDrawer = false;
			this._isDraggingLeftDrawer = false;
			this.stage.removeEventListener("resize",stage_resizeHandler);
			Starling.current.nativeStage.removeEventListener("keyDown",drawers_nativeStage_keyDownHandler);
		}
		
		protected function drawers_touchHandler(event:TouchEvent) : void {
			var _local2:Touch = null;
			if(!this._isEnabled || this._openOrCloseTween) {
				this.touchPointID = -1;
				return;
			}
			if(this.touchPointID >= 0) {
				_local2 = event.getTouch(this,null,this.touchPointID);
				if(!_local2) {
					return;
				}
				if(_local2.phase == "moved") {
					this.handleTouchMoved(_local2);
					if(!this._isDragging) {
						if(this.isTopDrawerOpen || this.isRightDrawerOpen || this.isBottomDrawerOpen || this.isLeftDrawerOpen) {
							this.checkForDragToClose();
						} else {
							this.checkForDragToOpen();
						}
					}
					if(this._isDragging) {
						this.handleDragMove();
					}
				} else if(_local2.phase == "ended") {
					this.touchPointID = -1;
					if(this._isDragging) {
						this.handleDragEnd();
						this.dispatchEventWith("endInteraction");
					} else {
						ExclusiveTouch.forStage(this.stage).removeEventListener("change",exclusiveTouch_changeHandler);
						if(this.isTopDrawerOpen || this.isRightDrawerOpen || this.isBottomDrawerOpen || this.isLeftDrawerOpen) {
							this.handleTapToClose(_local2);
						}
					}
				}
			} else {
				_local2 = event.getTouch(this,"began");
				if(!_local2) {
					return;
				}
				this.handleTouchBegan(_local2);
			}
		}
		
		protected function exclusiveTouch_changeHandler(event:Event, touchID:int) : void {
			if(this.touchPointID < 0 || this.touchPointID != touchID || this._isDragging) {
				return;
			}
			var _local3:ExclusiveTouch = ExclusiveTouch.forStage(this.stage);
			if(_local3.getClaim(touchID) == this) {
				return;
			}
			this.touchPointID = -1;
		}
		
		protected function stage_resizeHandler(event:ResizeEvent) : void {
			this.invalidate("size");
		}
		
		protected function drawers_nativeStage_keyDownHandler(event:KeyboardEvent) : void {
			var _local2:Boolean = false;
			if(event.isDefaultPrevented()) {
				return;
			}
			if(event.keyCode == 16777238) {
				_local2 = false;
				if(this.isTopDrawerOpen) {
					this.toggleTopDrawer();
					_local2 = true;
				} else if(this.isRightDrawerOpen) {
					this.toggleRightDrawer();
					_local2 = true;
				} else if(this.isBottomDrawerOpen) {
					this.toggleBottomDrawer();
					_local2 = true;
				} else if(this.isLeftDrawerOpen) {
					this.toggleLeftDrawer();
					_local2 = true;
				}
				if(_local2) {
					event.preventDefault();
				}
			}
		}
		
		protected function content_topDrawerToggleEventTypeHandler(event:Event) : void {
			if(!this._topDrawer || this.isTopDrawerDocked) {
				return;
			}
			this._isTopDrawerOpen = !this._isTopDrawerOpen;
			this.openOrCloseTopDrawer();
		}
		
		protected function content_rightDrawerToggleEventTypeHandler(event:Event) : void {
			if(!this._rightDrawer || this.isRightDrawerDocked) {
				return;
			}
			this._isRightDrawerOpen = !this._isRightDrawerOpen;
			this.openOrCloseRightDrawer();
		}
		
		protected function content_bottomDrawerToggleEventTypeHandler(event:Event) : void {
			if(!this._bottomDrawer || this.isBottomDrawerDocked) {
				return;
			}
			this._isBottomDrawerOpen = !this._isBottomDrawerOpen;
			this.openOrCloseBottomDrawer();
		}
		
		protected function content_leftDrawerToggleEventTypeHandler(event:Event) : void {
			if(!this._leftDrawer || this.isLeftDrawerDocked) {
				return;
			}
			this._isLeftDrawerOpen = !this._isLeftDrawerOpen;
			this.openOrCloseLeftDrawer();
		}
		
		protected function content_resizeHandler(event:Event) : void {
			if(this._isValidating || this._autoSizeMode != "content") {
				return;
			}
			this.invalidate("size");
		}
		
		protected function drawer_resizeHandler(event:Event) : void {
			if(this._isValidating) {
				return;
			}
			this.invalidate("size");
		}
	}
}

