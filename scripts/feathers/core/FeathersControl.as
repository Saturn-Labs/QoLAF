package feathers.core {
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.controls.text.StageTextTextEditor;
	import feathers.layout.ILayoutData;
	import feathers.layout.ILayoutDisplayObject;
	import feathers.skins.IStyleProvider;
	import feathers.utils.display.getDisplayObjectDepthFromStage;
	import feathers.utils.display.stageToStarling;
	import flash.errors.IllegalOperationError;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.utils.MatrixUtil;
	
	public class FeathersControl extends Sprite implements IFeathersControl, ILayoutDisplayObject {
		public static const INVALIDATION_FLAG_ALL:String = "all";
		
		public static const INVALIDATION_FLAG_STATE:String = "state";
		
		public static const INVALIDATION_FLAG_SIZE:String = "size";
		
		public static const INVALIDATION_FLAG_STYLES:String = "styles";
		
		public static const INVALIDATION_FLAG_SKIN:String = "skin";
		
		public static const INVALIDATION_FLAG_LAYOUT:String = "layout";
		
		public static const INVALIDATION_FLAG_DATA:String = "data";
		
		public static const INVALIDATION_FLAG_SCROLL:String = "scroll";
		
		public static const INVALIDATION_FLAG_SELECTED:String = "selected";
		
		public static const INVALIDATION_FLAG_FOCUS:String = "focus";
		
		protected static const INVALIDATION_FLAG_TEXT_RENDERER:String = "textRenderer";
		
		protected static const INVALIDATION_FLAG_TEXT_EDITOR:String = "textEditor";
		
		protected static const ILLEGAL_WIDTH_ERROR:String = "A component\'s width cannot be NaN.";
		
		protected static const ILLEGAL_HEIGHT_ERROR:String = "A component\'s height cannot be NaN.";
		
		protected static const ABSTRACT_CLASS_ERROR:String = "FeathersControl is an abstract class. For a lightweight Feathers wrapper, use feathers.controls.LayoutGroup.";
		
		private static const HELPER_MATRIX:Matrix = new Matrix();
		
		private static const HELPER_POINT:Point = new Point();
		
		public static function defaultTextRendererFactory():ITextRenderer {
			return new BitmapFontTextRenderer();
		}
		public static function defaultTextEditorFactory():ITextEditor {
			return new StageTextTextEditor();
		}
		protected var _validationQueue:ValidationQueue;
		
		protected var _styleNameList:TokenList = new TokenList();
		
		protected var _styleProvider:IStyleProvider;
		
		protected var _isQuickHitAreaEnabled:Boolean = false;
		
		protected var _hitArea:Rectangle = new Rectangle();
		
		protected var _isInitializing:Boolean = false;
		
		protected var _isInitialized:Boolean = false;
		
		protected var _isAllInvalid:Boolean = false;
		
		protected var _invalidationFlags:Object = {};
		
		protected var _delayedInvalidationFlags:Object = {};
		
		protected var _isEnabled:Boolean = true;
		
		protected var _explicitWidth:Number = NaN;
		
		protected var actualWidth:Number = 0;
		
		protected var scaledActualWidth:Number = 0;
		
		protected var _explicitHeight:Number = NaN;
		
		protected var actualHeight:Number = 0;
		
		protected var scaledActualHeight:Number = 0;
		
		protected var _minTouchWidth:Number = 0;
		
		protected var _minTouchHeight:Number = 0;
		
		protected var _explicitMinWidth:Number = NaN;
		
		protected var actualMinWidth:Number = 0;
		
		protected var scaledActualMinWidth:Number = 0;
		
		protected var _explicitMinHeight:Number = NaN;
		
		protected var actualMinHeight:Number = 0;
		
		protected var scaledActualMinHeight:Number = 0;
		
		protected var _explicitMaxWidth:Number = Infinity;
		
		protected var _explicitMaxHeight:Number = Infinity;
		
		protected var _includeInLayout:Boolean = true;
		
		protected var _layoutData:ILayoutData;
		
		protected var _toolTip:String;
		
		protected var _focusManager:IFocusManager;
		
		protected var _focusOwner:IFocusDisplayObject;
		
		protected var _isFocusEnabled:Boolean = true;
		
		protected var _nextTabFocus:IFocusDisplayObject;
		
		protected var _previousTabFocus:IFocusDisplayObject;
		
		protected var _focusIndicatorSkin:DisplayObject;
		
		protected var _focusPaddingTop:Number = 0;
		
		protected var _focusPaddingRight:Number = 0;
		
		protected var _focusPaddingBottom:Number = 0;
		
		protected var _focusPaddingLeft:Number = 0;
		
		protected var _hasFocus:Boolean = false;
		
		protected var _showFocus:Boolean = false;
		
		protected var _isValidating:Boolean = false;
		
		protected var _hasValidated:Boolean = false;
		
		protected var _depth:int = -1;
		
		protected var _invalidateCount:int = 0;
		
		protected var _isDisposed:Boolean = false;
		
		public function FeathersControl() {
			super();
			if(Object(this).constructor == FeathersControl) {
				throw new Error("FeathersControl is an abstract class. For a lightweight Feathers wrapper, use feathers.controls.LayoutGroup.");
			}
			this._styleProvider = this.defaultStyleProvider;
			this.addEventListener("addedToStage",feathersControl_addedToStageHandler);
			this.addEventListener("removedFromStage",feathersControl_removedFromStageHandler);
		}
		
		public function get styleName() : String {
			return this._styleNameList.value;
		}
		
		public function set styleName(value:String) : void {
			this._styleNameList.value = value;
		}
		
		public function get styleNameList() : TokenList {
			return this._styleNameList;
		}
		
		public function get styleProvider() : IStyleProvider {
			return this._styleProvider;
		}
		
		public function set styleProvider(value:IStyleProvider) : void {
			this._styleProvider = value;
			if(this._styleProvider && this.isInitialized) {
				this._styleProvider.applyStyles(this);
			}
		}
		
		protected function get defaultStyleProvider() : IStyleProvider {
			return null;
		}
		
		public function get isQuickHitAreaEnabled() : Boolean {
			return this._isQuickHitAreaEnabled;
		}
		
		public function set isQuickHitAreaEnabled(value:Boolean) : void {
			this._isQuickHitAreaEnabled = value;
		}
		
		public function get isInitialized() : Boolean {
			return this._isInitialized;
		}
		
		public function get isEnabled() : Boolean {
			return _isEnabled;
		}
		
		public function set isEnabled(value:Boolean) : void {
			if(this._isEnabled == value) {
				return;
			}
			this._isEnabled = value;
			this.invalidate("state");
		}
		
		public function get explicitWidth() : Number {
			return this._explicitWidth;
		}
		
		override public function get width() : Number {
			return this.scaledActualWidth;
		}
		
		override public function set width(value:Number) : void {
			var _local2:Boolean = false;
			var _local3:* = value !== value;
			if(_local3 && this._explicitWidth !== this._explicitWidth) {
				return;
			}
			if(this.scaleX !== 1) {
				value /= this.scaleX;
			}
			if(this._explicitWidth == value) {
				return;
			}
			this._explicitWidth = value;
			if(_local3) {
				this.actualWidth = this.scaledActualWidth = 0;
				this.invalidate("size");
			} else {
				_local2 = this.saveMeasurements(value,this.actualHeight,this.actualMinWidth,this.actualMinHeight);
				if(_local2) {
					this.invalidate("size");
				}
			}
		}
		
		public function get explicitHeight() : Number {
			return this._explicitHeight;
		}
		
		override public function get height() : Number {
			return this.scaledActualHeight;
		}
		
		override public function set height(value:Number) : void {
			var _local2:Boolean = false;
			var _local3:* = value !== value;
			if(_local3 && this._explicitHeight !== this._explicitHeight) {
				return;
			}
			if(this.scaleY !== 1) {
				value /= this.scaleY;
			}
			if(this._explicitHeight == value) {
				return;
			}
			this._explicitHeight = value;
			if(_local3) {
				this.actualHeight = this.scaledActualHeight = 0;
				this.invalidate("size");
			} else {
				_local2 = this.saveMeasurements(this.actualWidth,value,this.actualMinWidth,this.actualMinHeight);
				if(_local2) {
					this.invalidate("size");
				}
			}
		}
		
		public function get minTouchWidth() : Number {
			return this._minTouchWidth;
		}
		
		public function set minTouchWidth(value:Number) : void {
			if(this._minTouchWidth == value) {
				return;
			}
			this._minTouchWidth = value;
			this.refreshHitAreaX();
		}
		
		public function get minTouchHeight() : Number {
			return this._minTouchHeight;
		}
		
		public function set minTouchHeight(value:Number) : void {
			if(this._minTouchHeight == value) {
				return;
			}
			this._minTouchHeight = value;
			this.refreshHitAreaY();
		}
		
		public function get explicitMinWidth() : Number {
			return this._explicitMinWidth;
		}
		
		public function get minWidth() : Number {
			return this.scaledActualMinWidth;
		}
		
		public function set minWidth(value:Number) : void {
			var _local2:* = value !== value;
			if(_local2 && this._explicitMinWidth !== this._explicitMinWidth) {
				return;
			}
			if(this.scaleX !== 1) {
				value /= this.scaleX;
			}
			if(this._explicitMinWidth == value) {
				return;
			}
			var _local3:Number = this._explicitMinWidth;
			this._explicitMinWidth = value;
			if(_local2) {
				this.actualMinWidth = this.scaledActualMinWidth = 0;
				this.invalidate("size");
			} else {
				this.saveMeasurements(this.actualWidth,this.actualHeight,value,this.actualMinHeight);
				if(this._explicitWidth !== this._explicitWidth && (this.actualWidth < value || this.actualWidth === _local3)) {
					this.invalidate("size");
				}
			}
		}
		
		public function get explicitMinHeight() : Number {
			return this._explicitMinHeight;
		}
		
		public function get minHeight() : Number {
			return this.scaledActualMinHeight;
		}
		
		public function set minHeight(value:Number) : void {
			var _local2:* = value !== value;
			if(_local2 && this._explicitMinHeight !== this._explicitMinHeight) {
				return;
			}
			if(this.scaleY !== 1) {
				value /= this.scaleY;
			}
			if(this._explicitMinHeight == value) {
				return;
			}
			var _local3:Number = this._explicitMinHeight;
			this._explicitMinHeight = value;
			if(_local2) {
				this.actualMinHeight = this.scaledActualMinHeight = 0;
				this.invalidate("size");
			} else {
				this.saveMeasurements(this.actualWidth,this.actualHeight,this.actualMinWidth,value);
				if(this._explicitHeight !== this._explicitHeight && (this.actualHeight < value || this.actualHeight === _local3)) {
					this.invalidate("size");
				}
			}
		}
		
		public function get explicitMaxWidth() : Number {
			return this._explicitMaxWidth;
		}
		
		public function get maxWidth() : Number {
			return this._explicitMaxWidth;
		}
		
		public function set maxWidth(value:Number) : void {
			if(value < 0) {
				value = 0;
			}
			if(this._explicitMaxWidth == value) {
				return;
			}
			if(value !== value) {
				throw new ArgumentError("maxWidth cannot be NaN");
			}
			var _local2:Number = this._explicitMaxWidth;
			this._explicitMaxWidth = value;
			if(this._explicitWidth !== this._explicitWidth && (this.actualWidth > value || this.actualWidth === _local2)) {
				this.invalidate("size");
			}
		}
		
		public function get explicitMaxHeight() : Number {
			return this._explicitMaxHeight;
		}
		
		public function get maxHeight() : Number {
			return this._explicitMaxHeight;
		}
		
		public function set maxHeight(value:Number) : void {
			if(value < 0) {
				value = 0;
			}
			if(this._explicitMaxHeight == value) {
				return;
			}
			if(value !== value) {
				throw new ArgumentError("maxHeight cannot be NaN");
			}
			var _local2:Number = this._explicitMaxHeight;
			this._explicitMaxHeight = value;
			if(this._explicitHeight !== this._explicitHeight && (this.actualHeight > value || this.actualHeight === _local2)) {
				this.invalidate("size");
			}
		}
		
		override public function set scaleX(value:Number) : void {
			super.scaleX = value;
			this.saveMeasurements(this.actualWidth,this.actualHeight,this.actualMinWidth,this.actualMinHeight);
		}
		
		override public function set scaleY(value:Number) : void {
			super.scaleY = value;
			this.saveMeasurements(this.actualWidth,this.actualHeight,this.actualMinWidth,this.actualMinHeight);
		}
		
		public function get includeInLayout() : Boolean {
			return this._includeInLayout;
		}
		
		public function set includeInLayout(value:Boolean) : void {
			if(this._includeInLayout == value) {
				return;
			}
			this._includeInLayout = value;
			this.dispatchEventWith("layoutDataChange");
		}
		
		public function get layoutData() : ILayoutData {
			return this._layoutData;
		}
		
		public function set layoutData(value:ILayoutData) : void {
			if(this._layoutData == value) {
				return;
			}
			if(this._layoutData) {
				this._layoutData.removeEventListener("change",layoutData_changeHandler);
			}
			this._layoutData = value;
			if(this._layoutData) {
				this._layoutData.addEventListener("change",layoutData_changeHandler);
			}
			this.dispatchEventWith("layoutDataChange");
		}
		
		public function get toolTip() : String {
			return this._toolTip;
		}
		
		public function set toolTip(value:String) : void {
			this._toolTip = value;
		}
		
		public function get focusManager() : IFocusManager {
			return this._focusManager;
		}
		
		public function set focusManager(value:IFocusManager) : void {
			if(!(this is IFocusDisplayObject)) {
				throw new IllegalOperationError("Cannot pass a focus manager to a component that does not implement feathers.core.IFocusDisplayObject");
			}
			if(this._focusManager == value) {
				return;
			}
			this._focusManager = value;
			if(this._focusManager) {
				this.addEventListener("focusIn",focusInHandler);
				this.addEventListener("focusOut",focusOutHandler);
			} else {
				this.removeEventListener("focusIn",focusInHandler);
				this.removeEventListener("focusOut",focusOutHandler);
			}
		}
		
		public function get focusOwner() : IFocusDisplayObject {
			return this._focusOwner;
		}
		
		public function set focusOwner(value:IFocusDisplayObject) : void {
			this._focusOwner = value;
		}
		
		public function get isFocusEnabled() : Boolean {
			return this._isEnabled && this._isFocusEnabled;
		}
		
		public function set isFocusEnabled(value:Boolean) : void {
			if(!(this is IFocusDisplayObject)) {
				throw new IllegalOperationError("Cannot enable focus on a component that does not implement feathers.core.IFocusDisplayObject");
			}
			if(this._isFocusEnabled == value) {
				return;
			}
			this._isFocusEnabled = value;
		}
		
		public function get nextTabFocus() : IFocusDisplayObject {
			return this._nextTabFocus;
		}
		
		public function set nextTabFocus(value:IFocusDisplayObject) : void {
			if(!(this is IFocusDisplayObject)) {
				throw new IllegalOperationError("Cannot set next tab focus on a component that does not implement feathers.core.IFocusDisplayObject");
			}
			this._nextTabFocus = value;
		}
		
		public function get previousTabFocus() : IFocusDisplayObject {
			return this._previousTabFocus;
		}
		
		public function set previousTabFocus(value:IFocusDisplayObject) : void {
			if(!(this is IFocusDisplayObject)) {
				throw new IllegalOperationError("Cannot set previous tab focus on a component that does not implement feathers.core.IFocusDisplayObject");
			}
			this._previousTabFocus = value;
		}
		
		public function get focusIndicatorSkin() : DisplayObject {
			return this._focusIndicatorSkin;
		}
		
		public function set focusIndicatorSkin(value:DisplayObject) : void {
			if(!(this is IFocusDisplayObject)) {
				throw new IllegalOperationError("Cannot set focus indicator skin on a component that does not implement feathers.core.IFocusDisplayObject");
			}
			if(this._focusIndicatorSkin == value) {
				return;
			}
			if(this._focusIndicatorSkin) {
				if(this._focusIndicatorSkin.parent == this) {
					this._focusIndicatorSkin.removeFromParent(false);
				}
				if(this._focusIndicatorSkin is IStateObserver && this is IStateContext) {
					IStateObserver(this._focusIndicatorSkin).stateContext = null;
				}
			}
			this._focusIndicatorSkin = value;
			if(this._focusIndicatorSkin) {
				this._focusIndicatorSkin.touchable = false;
			}
			if(this._focusIndicatorSkin is IStateObserver && this is IStateContext) {
				IStateObserver(this._focusIndicatorSkin).stateContext = IStateContext(this);
			}
			if(this._focusManager && this._focusManager.focus == this) {
				this.invalidate("styles");
			}
		}
		
		public function get focusPadding() : Number {
			return this._focusPaddingTop;
		}
		
		public function set focusPadding(value:Number) : void {
			this.focusPaddingTop = value;
			this.focusPaddingRight = value;
			this.focusPaddingBottom = value;
			this.focusPaddingLeft = value;
		}
		
		public function get focusPaddingTop() : Number {
			return this._focusPaddingTop;
		}
		
		public function set focusPaddingTop(value:Number) : void {
			if(this._focusPaddingTop == value) {
				return;
			}
			this._focusPaddingTop = value;
			this.invalidate("focus");
		}
		
		public function get focusPaddingRight() : Number {
			return this._focusPaddingRight;
		}
		
		public function set focusPaddingRight(value:Number) : void {
			if(this._focusPaddingRight == value) {
				return;
			}
			this._focusPaddingRight = value;
			this.invalidate("focus");
		}
		
		public function get focusPaddingBottom() : Number {
			return this._focusPaddingBottom;
		}
		
		public function set focusPaddingBottom(value:Number) : void {
			if(this._focusPaddingBottom == value) {
				return;
			}
			this._focusPaddingBottom = value;
			this.invalidate("focus");
		}
		
		public function get focusPaddingLeft() : Number {
			return this._focusPaddingLeft;
		}
		
		public function set focusPaddingLeft(value:Number) : void {
			if(this._focusPaddingLeft == value) {
				return;
			}
			this._focusPaddingLeft = value;
			this.invalidate("focus");
		}
		
		public function get isCreated() : Boolean {
			return this._hasValidated;
		}
		
		public function get depth() : int {
			return this._depth;
		}
		
		override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null) : Rectangle {
			if(!resultRect) {
				resultRect = new Rectangle();
			}
			var _local4:Number = 1.7976931348623157e+308;
			var _local6:Number = -1.7976931348623157e+308;
			var _local3:Number = 1.7976931348623157e+308;
			var _local5:Number = -1.7976931348623157e+308;
			if(targetSpace == this) {
				_local4 = 0;
				_local3 = 0;
				_local6 = this.actualWidth;
				_local5 = this.actualHeight;
			} else {
				this.getTransformationMatrix(targetSpace,HELPER_MATRIX);
				MatrixUtil.transformCoords(HELPER_MATRIX,0,0,HELPER_POINT);
				_local4 = _local4 < HELPER_POINT.x ? _local4 : HELPER_POINT.x;
				_local6 = _local6 > HELPER_POINT.x ? _local6 : HELPER_POINT.x;
				_local3 = _local3 < HELPER_POINT.y ? _local3 : HELPER_POINT.y;
				_local5 = _local5 > HELPER_POINT.y ? _local5 : HELPER_POINT.y;
				MatrixUtil.transformCoords(HELPER_MATRIX,0,this.actualHeight,HELPER_POINT);
				_local4 = _local4 < HELPER_POINT.x ? _local4 : HELPER_POINT.x;
				_local6 = _local6 > HELPER_POINT.x ? _local6 : HELPER_POINT.x;
				_local3 = _local3 < HELPER_POINT.y ? _local3 : HELPER_POINT.y;
				_local5 = _local5 > HELPER_POINT.y ? _local5 : HELPER_POINT.y;
				MatrixUtil.transformCoords(HELPER_MATRIX,this.actualWidth,0,HELPER_POINT);
				_local4 = _local4 < HELPER_POINT.x ? _local4 : HELPER_POINT.x;
				_local6 = _local6 > HELPER_POINT.x ? _local6 : HELPER_POINT.x;
				_local3 = _local3 < HELPER_POINT.y ? _local3 : HELPER_POINT.y;
				_local5 = _local5 > HELPER_POINT.y ? _local5 : HELPER_POINT.y;
				MatrixUtil.transformCoords(HELPER_MATRIX,this.actualWidth,this.actualHeight,HELPER_POINT);
				_local4 = _local4 < HELPER_POINT.x ? _local4 : HELPER_POINT.x;
				_local6 = _local6 > HELPER_POINT.x ? _local6 : HELPER_POINT.x;
				_local3 = _local3 < HELPER_POINT.y ? _local3 : HELPER_POINT.y;
				_local5 = _local5 > HELPER_POINT.y ? _local5 : HELPER_POINT.y;
			}
			resultRect.x = _local4;
			resultRect.y = _local3;
			resultRect.width = _local6 - _local4;
			resultRect.height = _local5 - _local3;
			return resultRect;
		}
		
		override public function hitTest(localPoint:Point) : DisplayObject {
			if(this._isQuickHitAreaEnabled) {
				if(!this.visible || !this.touchable) {
					return null;
				}
				if(this.mask && !this.hitTestMask(localPoint)) {
					return null;
				}
				return this._hitArea.containsPoint(localPoint) ? this : null;
			}
			return super.hitTest(localPoint);
		}
		
		override public function dispose() : void {
			this._isDisposed = true;
			this._validationQueue = null;
			super.dispose();
		}
		
		public function invalidate(flag:String = "all") : void {
			var _local4:Boolean = this.isInvalid();
			var _local3:Boolean = false;
			if(this._isValidating) {
				var _local6:int = 0;
				var _local5:* = this._delayedInvalidationFlags;
				for(var _local2 in _local5) {
					_local3 = true;
				}
			}
			if(!flag || flag == "all") {
				if(this._isValidating) {
					this._delayedInvalidationFlags["all"] = true;
				} else {
					this._isAllInvalid = true;
				}
			} else if(this._isValidating) {
				this._delayedInvalidationFlags[flag] = true;
			} else if(flag != "all" && !this._invalidationFlags.hasOwnProperty(flag)) {
				this._invalidationFlags[flag] = true;
			}
			if(!this._validationQueue || !this._isInitialized) {
				return;
			}
			if(this._isValidating) {
				if(_local3) {
					return;
				}
				this._invalidateCount++;
				this._validationQueue.addControl(this,this._invalidateCount >= 10);
				return;
			}
			if(_local4) {
				return;
			}
			this._invalidateCount = 0;
			this._validationQueue.addControl(this,false);
		}
		
		public function validate() : void {
			if(this._isDisposed) {
				return;
			}
			if(!this._isInitialized) {
				if(this._isInitializing) {
					return;
				}
				this.initializeNow();
			}
			if(!this.isInvalid()) {
				return;
			}
			if(this._isValidating) {
				if(this._validationQueue) {
					this._validationQueue.addControl(this,true);
				}
				return;
			}
			this._isValidating = true;
			this.draw();
			for(var _local1 in this._invalidationFlags) {
				delete this._invalidationFlags[_local1];
			}
			this._isAllInvalid = false;
			for(_local1 in this._delayedInvalidationFlags) {
				if(_local1 == "all") {
					this._isAllInvalid = true;
				} else {
					this._invalidationFlags[_local1] = true;
				}
				delete this._delayedInvalidationFlags[_local1];
			}
			this._isValidating = false;
			if(!this._hasValidated) {
				this._hasValidated = true;
				this.dispatchEventWith("creationComplete");
			}
		}
		
		public function isInvalid(flag:String = null) : Boolean {
			if(this._isAllInvalid) {
				return true;
			}
			if(!flag) {
				var _local3:int = 0;
				var _local2:* = this._invalidationFlags;
				for(flag in _local2) {
					return true;
				}
				return false;
			}
			return this._invalidationFlags[flag];
		}
		
		public function setSize(width:Number, height:Number) : void {
			var _local3:Boolean = false;
			this._explicitWidth = width;
			var _local4:* = width !== width;
			if(_local4) {
				this.actualWidth = this.scaledActualWidth = 0;
			}
			this._explicitHeight = height;
			var _local5:* = height !== height;
			if(_local5) {
				this.actualHeight = this.scaledActualHeight = 0;
			}
			if(_local4 || _local5) {
				this.invalidate("size");
			} else {
				_local3 = this.saveMeasurements(width,height,this.actualMinWidth,this.actualMinHeight);
				if(_local3) {
					this.invalidate("size");
				}
			}
		}
		
		public function move(x:Number, y:Number) : void {
			this.x = x;
			this.y = y;
		}
		
		public function resetStyleProvider() : void {
			this.styleProvider = this.defaultStyleProvider;
		}
		
		public function showFocus() : void {
			if(!this._hasFocus || !this._focusIndicatorSkin) {
				return;
			}
			this._showFocus = true;
			this.invalidate("focus");
		}
		
		public function hideFocus() : void {
			if(!this._hasFocus || !this._focusIndicatorSkin) {
				return;
			}
			this._showFocus = false;
			this.invalidate("focus");
		}
		
		public function initializeNow() : void {
			if(this._isInitialized || this._isInitializing) {
				return;
			}
			this._isInitializing = true;
			this.initialize();
			this.invalidate();
			this._isInitializing = false;
			this._isInitialized = true;
			this.dispatchEventWith("initialize");
			if(this._styleProvider) {
				this._styleProvider.applyStyles(this);
			}
			this._styleNameList.addEventListener("change",styleNameList_changeHandler);
		}
		
		protected function setSizeInternal(width:Number, height:Number, canInvalidate:Boolean) : Boolean {
			var _local4:Boolean = this.saveMeasurements(width,height,this.actualMinWidth,this.actualMinHeight);
			if(canInvalidate && _local4) {
				this.invalidate("size");
			}
			return _local4;
		}
		
		protected function saveMeasurements(width:Number, height:Number, minWidth:Number = 0, minHeight:Number = 0) : Boolean {
			if(this._explicitMinWidth === this._explicitMinWidth) {
				minWidth = this._explicitMinWidth;
			}
			if(this._explicitMinHeight === this._explicitMinHeight) {
				minHeight = this._explicitMinHeight;
			}
			if(this._explicitWidth === this._explicitWidth) {
				width = this._explicitWidth;
			} else if(width < minWidth) {
				width = minWidth;
			} else if(width > this._explicitMaxWidth) {
				width = this._explicitMaxWidth;
			}
			if(this._explicitHeight === this._explicitHeight) {
				height = this._explicitHeight;
			} else if(height < minHeight) {
				height = minHeight;
			} else if(height > this._explicitMaxHeight) {
				height = this._explicitMaxHeight;
			}
			if(width !== width) {
				throw new ArgumentError("A component\'s width cannot be NaN.");
			}
			if(height !== height) {
				throw new ArgumentError("A component\'s height cannot be NaN.");
			}
			var _local5:Number = this.scaleX;
			if(_local5 < 0) {
				_local5 = -_local5;
			}
			var _local6:Number = this.scaleY;
			if(_local6 < 0) {
				_local6 = -_local6;
			}
			var _local7:Boolean = false;
			if(this.actualWidth !== width) {
				this.actualWidth = width;
				this.refreshHitAreaX();
				_local7 = true;
			}
			if(this.actualHeight !== height) {
				this.actualHeight = height;
				this.refreshHitAreaY();
				_local7 = true;
			}
			if(this.actualMinWidth !== minWidth) {
				this.actualMinWidth = minWidth;
				_local7 = true;
			}
			if(this.actualMinHeight !== minHeight) {
				this.actualMinHeight = minHeight;
				_local7 = true;
			}
			width = this.scaledActualWidth;
			height = this.scaledActualHeight;
			this.scaledActualWidth = this.actualWidth * _local5;
			this.scaledActualHeight = this.actualHeight * _local6;
			this.scaledActualMinWidth = this.actualMinWidth * _local5;
			this.scaledActualMinHeight = this.actualMinHeight * _local6;
			if(width !== this.scaledActualWidth || height !== this.scaledActualHeight) {
				_local7 = true;
				this.dispatchEventWith("resize");
			}
			return _local7;
		}
		
		protected function initialize() : void {
		}
		
		protected function draw() : void {
		}
		
		protected function setInvalidationFlag(flag:String) : void {
			if(this._invalidationFlags.hasOwnProperty(flag)) {
				return;
			}
			this._invalidationFlags[flag] = true;
		}
		
		protected function clearInvalidationFlag(flag:String) : void {
			delete this._invalidationFlags[flag];
		}
		
		protected function refreshFocusIndicator() : void {
			if(this._focusIndicatorSkin) {
				if(this._hasFocus && this._showFocus) {
					if(this._focusIndicatorSkin.parent != this) {
						this.addChild(this._focusIndicatorSkin);
					} else {
						this.setChildIndex(this._focusIndicatorSkin,this.numChildren - 1);
					}
				} else if(this._focusIndicatorSkin.parent) {
					this._focusIndicatorSkin.removeFromParent(false);
				}
				this._focusIndicatorSkin.x = this._focusPaddingLeft;
				this._focusIndicatorSkin.y = this._focusPaddingTop;
				this._focusIndicatorSkin.width = this.actualWidth - this._focusPaddingLeft - this._focusPaddingRight;
				this._focusIndicatorSkin.height = this.actualHeight - this._focusPaddingTop - this._focusPaddingBottom;
			}
		}
		
		protected function refreshHitAreaX() : void {
			if(this.actualWidth < this._minTouchWidth) {
				this._hitArea.width = this._minTouchWidth;
			} else {
				this._hitArea.width = this.actualWidth;
			}
			var _local1:Number = (this.actualWidth - this._hitArea.width) / 2;
			if(_local1 !== _local1) {
				this._hitArea.x = 0;
			} else {
				this._hitArea.x = _local1;
			}
		}
		
		protected function refreshHitAreaY() : void {
			if(this.actualHeight < this._minTouchHeight) {
				this._hitArea.height = this._minTouchHeight;
			} else {
				this._hitArea.height = this.actualHeight;
			}
			var _local1:Number = (this.actualHeight - this._hitArea.height) / 2;
			if(_local1 !== _local1) {
				this._hitArea.y = 0;
			} else {
				this._hitArea.y = _local1;
			}
		}
		
		protected function focusInHandler(event:Event) : void {
			this._hasFocus = true;
			this.invalidate("focus");
		}
		
		protected function focusOutHandler(event:Event) : void {
			this._hasFocus = false;
			this._showFocus = false;
			this.invalidate("focus");
		}
		
		protected function feathersControl_addedToStageHandler(event:Event) : void {
			this._depth = getDisplayObjectDepthFromStage(this);
			var _local2:Starling = stageToStarling(this.stage);
			this._validationQueue = ValidationQueue.forStarling(_local2);
			if(!this._isInitialized) {
				this.initializeNow();
			}
			if(this.isInvalid()) {
				this._invalidateCount = 0;
				this._validationQueue.addControl(this,false);
			}
		}
		
		protected function feathersControl_removedFromStageHandler(event:Event) : void {
			this._depth = -1;
			this._validationQueue = null;
		}
		
		protected function layoutData_changeHandler(event:Event) : void {
			this.dispatchEventWith("layoutDataChange");
		}
		
		protected function styleNameList_changeHandler(event:Event) : void {
			if(!this._styleProvider) {
				return;
			}
			this._styleProvider.applyStyles(this);
		}
	}
}

