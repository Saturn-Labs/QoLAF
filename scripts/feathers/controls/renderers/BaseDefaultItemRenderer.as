package feathers.controls.renderers {
	import feathers.controls.ImageLoader;
	import feathers.controls.Scroller;
	import feathers.controls.ToggleButton;
	import feathers.core.FeathersControl;
	import feathers.core.IFeathersControl;
	import feathers.core.IFocusContainer;
	import feathers.core.IMeasureDisplayObject;
	import feathers.core.IStateObserver;
	import feathers.core.ITextRenderer;
	import feathers.core.IValidating;
	import feathers.core.PropertyProxy;
	import feathers.utils.skins.resetFluidChildDimensionsForMeasurement;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	public class BaseDefaultItemRenderer extends ToggleButton implements IFocusContainer {
		public static const ALTERNATE_STYLE_NAME_DRILL_DOWN:String = "feathers-drill-down-item-renderer";
		
		public static const ALTERNATE_STYLE_NAME_CHECK:String = "feathers-check-item-renderer";
		
		public static const DEFAULT_CHILD_STYLE_NAME_LABEL:String = "feathers-item-renderer-label";
		
		public static const DEFAULT_CHILD_STYLE_NAME_ICON_LABEL:String = "feathers-item-renderer-icon-label";
		
		public static const DEFAULT_CHILD_STYLE_NAME_ACCESSORY_LABEL:String = "feathers-item-renderer-accessory-label";
		
		public static const STATE_UP:String = "up";
		
		public static const STATE_DOWN:String = "down";
		
		public static const STATE_HOVER:String = "hover";
		
		public static const STATE_DISABLED:String = "disabled";
		
		public static const STATE_UP_AND_SELECTED:String = "upAndSelected";
		
		public static const STATE_DOWN_AND_SELECTED:String = "downAndSelected";
		
		public static const STATE_HOVER_AND_SELECTED:String = "hoverAndSelected";
		
		public static const STATE_DISABLED_AND_SELECTED:String = "disabledAndSelected";
		
		public static const ICON_POSITION_TOP:String = "top";
		
		public static const ICON_POSITION_RIGHT:String = "right";
		
		public static const ICON_POSITION_BOTTOM:String = "bottom";
		
		public static const ICON_POSITION_LEFT:String = "left";
		
		public static const ICON_POSITION_MANUAL:String = "manual";
		
		public static const ICON_POSITION_LEFT_BASELINE:String = "leftBaseline";
		
		public static const ICON_POSITION_RIGHT_BASELINE:String = "rightBaseline";
		
		public static const HORIZONTAL_ALIGN_LEFT:String = "left";
		
		public static const HORIZONTAL_ALIGN_CENTER:String = "center";
		
		public static const HORIZONTAL_ALIGN_RIGHT:String = "right";
		
		public static const VERTICAL_ALIGN_TOP:String = "top";
		
		public static const VERTICAL_ALIGN_MIDDLE:String = "middle";
		
		public static const VERTICAL_ALIGN_BOTTOM:String = "bottom";
		
		public static const ACCESSORY_POSITION_TOP:String = "top";
		
		public static const ACCESSORY_POSITION_RIGHT:String = "right";
		
		public static const ACCESSORY_POSITION_BOTTOM:String = "bottom";
		
		public static const ACCESSORY_POSITION_LEFT:String = "left";
		
		public static const ACCESSORY_POSITION_MANUAL:String = "manual";
		
		public static const LAYOUT_ORDER_LABEL_ACCESSORY_ICON:String = "labelAccessoryIcon";
		
		public static const LAYOUT_ORDER_LABEL_ICON_ACCESSORY:String = "labelIconAccessory";
		
		protected static var DOWN_STATE_DELAY_MS:int = 250;
		
		private static const HELPER_POINT:Point = new Point();
		
		protected var iconLabelStyleName:String = "feathers-item-renderer-icon-label";
		
		protected var accessoryLabelStyleName:String = "feathers-item-renderer-accessory-label";
		
		protected var _isChildFocusEnabled:Boolean = true;
		
		protected var skinLoader:ImageLoader;
		
		protected var iconLoader:ImageLoader;
		
		protected var iconLabel:ITextRenderer;
		
		protected var accessoryLoader:ImageLoader;
		
		protected var accessoryLabel:ITextRenderer;
		
		protected var currentAccessory:DisplayObject;
		
		protected var _skinIsFromItem:Boolean = false;
		
		protected var _iconIsFromItem:Boolean = false;
		
		protected var _accessoryIsFromItem:Boolean = false;
		
		protected var _data:Object;
		
		protected var _owner:Scroller;
		
		protected var _factoryID:String;
		
		protected var _delayedCurrentState:String;
		
		protected var _stateDelayTimer:Timer;
		
		protected var _useStateDelayTimer:Boolean = true;
		
		protected var isSelectableWithoutToggle:Boolean = true;
		
		protected var _itemHasLabel:Boolean = true;
		
		protected var _itemHasIcon:Boolean = true;
		
		protected var _itemHasAccessory:Boolean = true;
		
		protected var _itemHasSkin:Boolean = false;
		
		protected var _itemHasSelectable:Boolean = false;
		
		protected var _itemHasEnabled:Boolean = false;
		
		protected var _accessoryPosition:String = "right";
		
		protected var _layoutOrder:String = "labelIconAccessory";
		
		protected var _accessoryOffsetX:Number = 0;
		
		protected var _accessoryOffsetY:Number = 0;
		
		protected var _accessoryGap:Number = NaN;
		
		protected var _minAccessoryGap:Number = NaN;
		
		protected var _defaultAccessory:DisplayObject;
		
		protected var _stateToAccessory:Object = {};
		
		protected var _stateToAccessoryFunction:Function;
		
		protected var accessoryTouchPointID:int = -1;
		
		protected var _stopScrollingOnAccessoryTouch:Boolean = true;
		
		protected var _isSelectableOnAccessoryTouch:Boolean = false;
		
		protected var _delayTextureCreationOnScroll:Boolean = false;
		
		protected var _labelField:String = "label";
		
		protected var _labelFunction:Function;
		
		protected var _iconField:String = "icon";
		
		protected var _iconFunction:Function;
		
		protected var _iconSourceField:String = "iconSource";
		
		protected var _iconSourceFunction:Function;
		
		protected var _iconLabelField:String = "iconLabel";
		
		protected var _iconLabelFunction:Function;
		
		protected var _customIconLabelStyleName:String;
		
		protected var _accessoryField:String = "accessory";
		
		protected var _accessoryFunction:Function;
		
		protected var _accessorySourceField:String = "accessorySource";
		
		protected var _accessorySourceFunction:Function;
		
		protected var _accessoryLabelField:String = "accessoryLabel";
		
		protected var _accessoryLabelFunction:Function;
		
		protected var _customAccessoryLabelStyleName:String;
		
		protected var _skinField:String = "skin";
		
		protected var _skinFunction:Function;
		
		protected var _skinSourceField:String = "skinSource";
		
		protected var _skinSourceFunction:Function;
		
		protected var _selectableField:String = "selectable";
		
		protected var _selectableFunction:Function;
		
		protected var _enabledField:String = "enabled";
		
		protected var _enabledFunction:Function;
		
		protected var _explicitIsToggle:Boolean = false;
		
		protected var _explicitIsEnabled:Boolean;
		
		protected var _iconLoaderFactory:Function = defaultLoaderFactory;
		
		protected var _iconLabelFactory:Function;
		
		protected var _iconLabelProperties:PropertyProxy;
		
		protected var _accessoryLoaderFactory:Function = defaultLoaderFactory;
		
		protected var _accessoryLabelFactory:Function;
		
		protected var _accessoryLabelProperties:PropertyProxy;
		
		protected var _skinLoaderFactory:Function = defaultLoaderFactory;
		
		protected var _ignoreAccessoryResizes:Boolean = false;
		
		public function BaseDefaultItemRenderer() {
			super();
			this._explicitIsEnabled = this._isEnabled;
			this.labelStyleName = "feathers-item-renderer-label";
			this.isFocusEnabled = false;
			this.isQuickHitAreaEnabled = false;
			this.addEventListener("removedFromStage",itemRenderer_removedFromStageHandler);
		}
		
		protected static function defaultLoaderFactory() : ImageLoader {
			return new ImageLoader();
		}
		
		public function get isChildFocusEnabled() : Boolean {
			return this._isEnabled && this._isChildFocusEnabled;
		}
		
		public function set isChildFocusEnabled(value:Boolean) : void {
			this._isChildFocusEnabled = value;
		}
		
		override public function set defaultIcon(value:DisplayObject) : void {
			if(this._defaultIcon === value) {
				return;
			}
			this.replaceIcon(null);
			this._iconIsFromItem = false;
			super.defaultIcon = value;
		}
		
		override public function set defaultSkin(value:DisplayObject) : void {
			if(this._defaultSkin === value) {
				return;
			}
			this.replaceSkin(null);
			this._skinIsFromItem = false;
			super.defaultSkin = value;
		}
		
		public function get data() : Object {
			return this._data;
		}
		
		public function set data(value:Object) : void {
			if(this._data === value) {
				return;
			}
			this._data = value;
			this.invalidate("data");
		}
		
		public function get factoryID() : String {
			return this._factoryID;
		}
		
		public function set factoryID(value:String) : void {
			this._factoryID = value;
		}
		
		public function get useStateDelayTimer() : Boolean {
			return this._useStateDelayTimer;
		}
		
		public function set useStateDelayTimer(value:Boolean) : void {
			this._useStateDelayTimer = value;
		}
		
		public function get itemHasLabel() : Boolean {
			return this._itemHasLabel;
		}
		
		public function set itemHasLabel(value:Boolean) : void {
			if(this._itemHasLabel == value) {
				return;
			}
			this._itemHasLabel = value;
			this.invalidate("data");
		}
		
		public function get itemHasIcon() : Boolean {
			return this._itemHasIcon;
		}
		
		public function set itemHasIcon(value:Boolean) : void {
			if(this._itemHasIcon == value) {
				return;
			}
			this._itemHasIcon = value;
			this.invalidate("data");
		}
		
		public function get itemHasAccessory() : Boolean {
			return this._itemHasAccessory;
		}
		
		public function set itemHasAccessory(value:Boolean) : void {
			if(this._itemHasAccessory == value) {
				return;
			}
			this._itemHasAccessory = value;
			this.invalidate("data");
		}
		
		public function get itemHasSkin() : Boolean {
			return this._itemHasSkin;
		}
		
		public function set itemHasSkin(value:Boolean) : void {
			if(this._itemHasSkin == value) {
				return;
			}
			this._itemHasSkin = value;
			this.invalidate("data");
		}
		
		public function get itemHasSelectable() : Boolean {
			return this._itemHasSelectable;
		}
		
		public function set itemHasSelectable(value:Boolean) : void {
			if(this._itemHasSelectable == value) {
				return;
			}
			this._itemHasSelectable = value;
			this.invalidate("data");
		}
		
		public function get itemHasEnabled() : Boolean {
			return this._itemHasEnabled;
		}
		
		public function set itemHasEnabled(value:Boolean) : void {
			if(this._itemHasEnabled == value) {
				return;
			}
			this._itemHasEnabled = value;
			this.invalidate("data");
		}
		
		public function get accessoryPosition() : String {
			return this._accessoryPosition;
		}
		
		public function set accessoryPosition(value:String) : void {
			if(this._accessoryPosition == value) {
				return;
			}
			this._accessoryPosition = value;
			this.invalidate("styles");
		}
		
		public function get layoutOrder() : String {
			return this._layoutOrder;
		}
		
		public function set layoutOrder(value:String) : void {
			if(this._layoutOrder == value) {
				return;
			}
			this._layoutOrder = value;
			this.invalidate("styles");
		}
		
		public function get accessoryOffsetX() : Number {
			return this._accessoryOffsetX;
		}
		
		public function set accessoryOffsetX(value:Number) : void {
			if(this._accessoryOffsetX == value) {
				return;
			}
			this._accessoryOffsetX = value;
			this.invalidate("styles");
		}
		
		public function get accessoryOffsetY() : Number {
			return this._accessoryOffsetY;
		}
		
		public function set accessoryOffsetY(value:Number) : void {
			if(this._accessoryOffsetY == value) {
				return;
			}
			this._accessoryOffsetY = value;
			this.invalidate("styles");
		}
		
		public function get accessoryGap() : Number {
			return this._accessoryGap;
		}
		
		public function set accessoryGap(value:Number) : void {
			if(this._accessoryGap == value) {
				return;
			}
			this._accessoryGap = value;
			this.invalidate("styles");
		}
		
		public function get minAccessoryGap() : Number {
			return this._minAccessoryGap;
		}
		
		public function set minAccessoryGap(value:Number) : void {
			if(this._minAccessoryGap == value) {
				return;
			}
			this._minAccessoryGap = value;
			this.invalidate("styles");
		}
		
		public function get defaultAccessory() : DisplayObject {
			return this._defaultAccessory;
		}
		
		public function set defaultAccessory(value:DisplayObject) : void {
			if(this._defaultAccessory === value) {
				return;
			}
			this.replaceAccessory(null);
			this._accessoryIsFromItem = false;
			this._defaultAccessory = value;
			this.invalidate("styles");
		}
		
		public function get stateToAccessoryFunction() : Function {
			return this._stateToAccessoryFunction;
		}
		
		public function set stateToAccessoryFunction(value:Function) : void {
			if(this._stateToAccessoryFunction == value) {
				return;
			}
			this._stateToAccessoryFunction = value;
			this.invalidate("styles");
		}
		
		public function get stopScrollingOnAccessoryTouch() : Boolean {
			return this._stopScrollingOnAccessoryTouch;
		}
		
		public function set stopScrollingOnAccessoryTouch(value:Boolean) : void {
			this._stopScrollingOnAccessoryTouch = value;
		}
		
		public function get isSelectableOnAccessoryTouch() : Boolean {
			return this._isSelectableOnAccessoryTouch;
		}
		
		public function set isSelectableOnAccessoryTouch(value:Boolean) : void {
			this._isSelectableOnAccessoryTouch = value;
		}
		
		public function get delayTextureCreationOnScroll() : Boolean {
			return this._delayTextureCreationOnScroll;
		}
		
		public function set delayTextureCreationOnScroll(value:Boolean) : void {
			this._delayTextureCreationOnScroll = value;
		}
		
		public function get labelField() : String {
			return this._labelField;
		}
		
		public function set labelField(value:String) : void {
			if(this._labelField == value) {
				return;
			}
			this._labelField = value;
			this.invalidate("data");
		}
		
		public function get labelFunction() : Function {
			return this._labelFunction;
		}
		
		public function set labelFunction(value:Function) : void {
			if(this._labelFunction == value) {
				return;
			}
			this._labelFunction = value;
			this.invalidate("data");
		}
		
		public function get iconField() : String {
			return this._iconField;
		}
		
		public function set iconField(value:String) : void {
			if(this._iconField == value) {
				return;
			}
			this._iconField = value;
			this.invalidate("data");
		}
		
		public function get iconFunction() : Function {
			return this._iconFunction;
		}
		
		public function set iconFunction(value:Function) : void {
			if(this._iconFunction == value) {
				return;
			}
			this._iconFunction = value;
			this.invalidate("data");
		}
		
		public function get iconSourceField() : String {
			return this._iconSourceField;
		}
		
		public function set iconSourceField(value:String) : void {
			if(this._iconSourceField == value) {
				return;
			}
			this._iconSourceField = value;
			this.invalidate("data");
		}
		
		public function get iconSourceFunction() : Function {
			return this._iconSourceFunction;
		}
		
		public function set iconSourceFunction(value:Function) : void {
			if(this._iconSourceFunction == value) {
				return;
			}
			this._iconSourceFunction = value;
			this.invalidate("data");
		}
		
		public function get iconLabelField() : String {
			return this._iconLabelField;
		}
		
		public function set iconLabelField(value:String) : void {
			if(this._iconLabelField == value) {
				return;
			}
			this._iconLabelField = value;
			this.invalidate("data");
		}
		
		public function get iconLabelFunction() : Function {
			return this._iconLabelFunction;
		}
		
		public function set iconLabelFunction(value:Function) : void {
			if(this._iconLabelFunction == value) {
				return;
			}
			this._iconLabelFunction = value;
			this.invalidate("data");
		}
		
		public function get customIconLabelStyleName() : String {
			return this._customIconLabelStyleName;
		}
		
		public function set customIconLabelStyleName(value:String) : void {
			if(this._customIconLabelStyleName == value) {
				return;
			}
			this._customIconLabelStyleName = value;
			this.invalidate("textRenderer");
		}
		
		public function get accessoryField() : String {
			return this._accessoryField;
		}
		
		public function set accessoryField(value:String) : void {
			if(this._accessoryField == value) {
				return;
			}
			this._accessoryField = value;
			this.invalidate("data");
		}
		
		public function get accessoryFunction() : Function {
			return this._accessoryFunction;
		}
		
		public function set accessoryFunction(value:Function) : void {
			if(this._accessoryFunction == value) {
				return;
			}
			this._accessoryFunction = value;
			this.invalidate("data");
		}
		
		public function get accessorySourceField() : String {
			return this._accessorySourceField;
		}
		
		public function set accessorySourceField(value:String) : void {
			if(this._accessorySourceField == value) {
				return;
			}
			this._accessorySourceField = value;
			this.invalidate("data");
		}
		
		public function get accessorySourceFunction() : Function {
			return this._accessorySourceFunction;
		}
		
		public function set accessorySourceFunction(value:Function) : void {
			if(this._accessorySourceFunction == value) {
				return;
			}
			this._accessorySourceFunction = value;
			this.invalidate("data");
		}
		
		public function get accessoryLabelField() : String {
			return this._accessoryLabelField;
		}
		
		public function set accessoryLabelField(value:String) : void {
			if(this._accessoryLabelField == value) {
				return;
			}
			this._accessoryLabelField = value;
			this.invalidate("data");
		}
		
		public function get accessoryLabelFunction() : Function {
			return this._accessoryLabelFunction;
		}
		
		public function set accessoryLabelFunction(value:Function) : void {
			if(this._accessoryLabelFunction == value) {
				return;
			}
			this._accessoryLabelFunction = value;
			this.invalidate("data");
		}
		
		public function get customAccessoryLabelStyleName() : String {
			return this._customAccessoryLabelStyleName;
		}
		
		public function set customAccessoryLabelStyleName(value:String) : void {
			if(this._customAccessoryLabelStyleName == value) {
				return;
			}
			this._customAccessoryLabelStyleName = value;
			this.invalidate("textRenderer");
		}
		
		public function get skinField() : String {
			return this._skinField;
		}
		
		public function set skinField(value:String) : void {
			if(this._skinField == value) {
				return;
			}
			this._skinField = value;
			this.invalidate("data");
		}
		
		public function get skinFunction() : Function {
			return this._skinFunction;
		}
		
		public function set skinFunction(value:Function) : void {
			if(this._skinFunction == value) {
				return;
			}
			this._skinFunction = value;
			this.invalidate("data");
		}
		
		public function get skinSourceField() : String {
			return this._skinSourceField;
		}
		
		public function set skinSourceField(value:String) : void {
			if(this._iconSourceField == value) {
				return;
			}
			this._skinSourceField = value;
			this.invalidate("data");
		}
		
		public function get skinSourceFunction() : Function {
			return this._skinSourceFunction;
		}
		
		public function set skinSourceFunction(value:Function) : void {
			if(this._skinSourceFunction == value) {
				return;
			}
			this._skinSourceFunction = value;
			this.invalidate("data");
		}
		
		public function get selectableField() : String {
			return this._selectableField;
		}
		
		public function set selectableField(value:String) : void {
			if(this._selectableField == value) {
				return;
			}
			this._selectableField = value;
			this.invalidate("data");
		}
		
		public function get selectableFunction() : Function {
			return this._selectableFunction;
		}
		
		public function set selectableFunction(value:Function) : void {
			if(this._selectableFunction == value) {
				return;
			}
			this._selectableFunction = value;
			this.invalidate("data");
		}
		
		public function get enabledField() : String {
			return this._enabledField;
		}
		
		public function set enabledField(value:String) : void {
			if(this._enabledField == value) {
				return;
			}
			this._enabledField = value;
			this.invalidate("data");
		}
		
		public function get enabledFunction() : Function {
			return this._enabledFunction;
		}
		
		public function set enabledFunction(value:Function) : void {
			if(this._enabledFunction == value) {
				return;
			}
			this._enabledFunction = value;
			this.invalidate("data");
		}
		
		override public function set isToggle(value:Boolean) : void {
			if(this._explicitIsToggle == value) {
				return;
			}
			super.isToggle = value;
			this._explicitIsToggle = value;
			this.invalidate("data");
		}
		
		override public function set isEnabled(value:Boolean) : void {
			if(this._explicitIsEnabled == value) {
				return;
			}
			this._explicitIsEnabled = value;
			super.isEnabled = value;
			this.invalidate("data");
		}
		
		public function get iconLoaderFactory() : Function {
			return this._iconLoaderFactory;
		}
		
		public function set iconLoaderFactory(value:Function) : void {
			if(this._iconLoaderFactory == value) {
				return;
			}
			this._iconLoaderFactory = value;
			this._iconIsFromItem = false;
			this.replaceIcon(null);
			this.invalidate("data");
		}
		
		public function get iconLabelFactory() : Function {
			return this._iconLabelFactory;
		}
		
		public function set iconLabelFactory(value:Function) : void {
			if(this._iconLabelFactory == value) {
				return;
			}
			this._iconLabelFactory = value;
			this._iconIsFromItem = false;
			this.replaceIcon(null);
			this.invalidate("data");
		}
		
		public function get iconLabelProperties() : Object {
			if(!this._iconLabelProperties) {
				this._iconLabelProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._iconLabelProperties;
		}
		
		public function set iconLabelProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._iconLabelProperties == value) {
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
			if(this._iconLabelProperties) {
				this._iconLabelProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._iconLabelProperties = PropertyProxy(value);
			if(this._iconLabelProperties) {
				this._iconLabelProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get accessoryLoaderFactory() : Function {
			return this._accessoryLoaderFactory;
		}
		
		public function set accessoryLoaderFactory(value:Function) : void {
			if(this._accessoryLoaderFactory == value) {
				return;
			}
			this._accessoryLoaderFactory = value;
			this._accessoryIsFromItem = false;
			this.replaceAccessory(null);
			this.invalidate("data");
		}
		
		public function get accessoryLabelFactory() : Function {
			return this._accessoryLabelFactory;
		}
		
		public function set accessoryLabelFactory(value:Function) : void {
			if(this._accessoryLabelFactory == value) {
				return;
			}
			this._accessoryLabelFactory = value;
			this._accessoryIsFromItem = false;
			this.replaceAccessory(null);
			this.invalidate("data");
		}
		
		public function get accessoryLabelProperties() : Object {
			if(!this._accessoryLabelProperties) {
				this._accessoryLabelProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._accessoryLabelProperties;
		}
		
		public function set accessoryLabelProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._accessoryLabelProperties == value) {
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
			if(this._accessoryLabelProperties) {
				this._accessoryLabelProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._accessoryLabelProperties = PropertyProxy(value);
			if(this._accessoryLabelProperties) {
				this._accessoryLabelProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get skinLoaderFactory() : Function {
			return this._skinLoaderFactory;
		}
		
		public function set skinLoaderFactory(value:Function) : void {
			if(this._skinLoaderFactory == value) {
				return;
			}
			this._skinLoaderFactory = value;
			this._skinIsFromItem = false;
			this.replaceSkin(null);
			this.invalidate("data");
		}
		
		override public function dispose() : void {
			if(this._iconIsFromItem) {
				this.replaceIcon(null);
			}
			if(this._accessoryIsFromItem) {
				this.replaceAccessory(null);
			}
			if(this._skinIsFromItem) {
				this.replaceSkin(null);
			}
			if(this._stateDelayTimer) {
				if(this._stateDelayTimer.running) {
					this._stateDelayTimer.stop();
				}
				this._stateDelayTimer.removeEventListener("timerComplete",stateDelayTimer_timerCompleteHandler);
				this._stateDelayTimer = null;
			}
			super.dispose();
		}
		
		public function itemToLabel(item:Object) : String {
			var _local2:Object = null;
			if(this._labelFunction !== null) {
				_local2 = this._labelFunction(item);
				if(_local2 is String) {
					return _local2 as String;
				}
				if(_local2 !== null) {
					return _local2.toString();
				}
			} else if(this._labelField !== null && item !== null && Boolean(item.hasOwnProperty(this._labelField))) {
				_local2 = item[this._labelField];
				if(_local2 is String) {
					return _local2 as String;
				}
				if(_local2 !== null) {
					return _local2.toString();
				}
			} else {
				if(item is String) {
					return item as String;
				}
				if(item !== null) {
					return item.toString();
				}
			}
			return null;
		}
		
		protected function itemToIcon(item:Object) : DisplayObject {
			var _local2:Object = null;
			var _local3:Object = null;
			if(this._iconSourceFunction != null) {
				_local2 = this._iconSourceFunction(item);
				this.refreshIconSource(_local2);
				return this.iconLoader;
			}
			if(this._iconSourceField != null && item && item.hasOwnProperty(this._iconSourceField)) {
				_local2 = item[this._iconSourceField];
				this.refreshIconSource(_local2);
				return this.iconLoader;
			}
			if(this._iconLabelFunction != null) {
				_local3 = this._iconLabelFunction(item);
				if(_local3 is String) {
					this.refreshIconLabel(_local3 as String);
				} else {
					this.refreshIconLabel(_local3.toString());
				}
				return DisplayObject(this.iconLabel);
			}
			if(this._iconLabelField != null && item && item.hasOwnProperty(this._iconLabelField)) {
				_local3 = item[this._iconLabelField];
				if(_local3 is String) {
					this.refreshIconLabel(_local3 as String);
				} else {
					this.refreshIconLabel(_local3.toString());
				}
				return DisplayObject(this.iconLabel);
			}
			if(this._iconFunction != null) {
				return this._iconFunction(item) as DisplayObject;
			}
			if(this._iconField != null && item && item.hasOwnProperty(this._iconField)) {
				return item[this._iconField] as DisplayObject;
			}
			return null;
		}
		
		protected function itemToAccessory(item:Object) : DisplayObject {
			var _local2:Object = null;
			var _local3:Object = null;
			if(this._accessorySourceFunction != null) {
				_local2 = this._accessorySourceFunction(item);
				this.refreshAccessorySource(_local2);
				return this.accessoryLoader;
			}
			if(this._accessorySourceField != null && item && item.hasOwnProperty(this._accessorySourceField)) {
				_local2 = item[this._accessorySourceField];
				this.refreshAccessorySource(_local2);
				return this.accessoryLoader;
			}
			if(this._accessoryLabelFunction != null) {
				_local3 = this._accessoryLabelFunction(item);
				if(_local3 is String) {
					this.refreshAccessoryLabel(_local3 as String);
				} else {
					this.refreshAccessoryLabel(_local3.toString());
				}
				return DisplayObject(this.accessoryLabel);
			}
			if(this._accessoryLabelField != null && item && item.hasOwnProperty(this._accessoryLabelField)) {
				_local3 = item[this._accessoryLabelField];
				if(_local3 is String) {
					this.refreshAccessoryLabel(_local3 as String);
				} else {
					this.refreshAccessoryLabel(_local3.toString());
				}
				return DisplayObject(this.accessoryLabel);
			}
			if(this._accessoryFunction != null) {
				return this._accessoryFunction(item) as DisplayObject;
			}
			if(this._accessoryField != null && item && item.hasOwnProperty(this._accessoryField)) {
				return item[this._accessoryField] as DisplayObject;
			}
			return null;
		}
		
		protected function itemToSkin(item:Object) : DisplayObject {
			var _local2:Object = null;
			if(this._skinSourceFunction != null) {
				_local2 = this._skinSourceFunction(item);
				this.refreshSkinSource(_local2);
				return this.skinLoader;
			}
			if(this._skinSourceField != null && item && item.hasOwnProperty(this._skinSourceField)) {
				_local2 = item[this._skinSourceField];
				this.refreshSkinSource(_local2);
				return this.skinLoader;
			}
			if(this._skinFunction != null) {
				return this._skinFunction(item) as DisplayObject;
			}
			if(this._skinField != null && item && item.hasOwnProperty(this._skinField)) {
				return item[this._skinField] as DisplayObject;
			}
			return null;
		}
		
		protected function itemToSelectable(item:Object) : Boolean {
			if(this._selectableFunction != null) {
				return this._selectableFunction(item) as Boolean;
			}
			if(this._selectableField != null && item && item.hasOwnProperty(this._selectableField)) {
				return item[this._selectableField] as Boolean;
			}
			return true;
		}
		
		protected function itemToEnabled(item:Object) : Boolean {
			if(this._enabledFunction != null) {
				return this._enabledFunction(item) as Boolean;
			}
			if(this._enabledField != null && item && item.hasOwnProperty(this._enabledField)) {
				return item[this._enabledField] as Boolean;
			}
			return true;
		}
		
		public function getAccessoryForState(state:String) : DisplayObject {
			return this._stateToAccessory[state] as DisplayObject;
		}
		
		public function setAccessoryForState(state:String, accessory:DisplayObject) : void {
			if(accessory !== null) {
				this._stateToAccessory[state] = accessory;
			} else {
				delete this._stateToAccessory[state];
			}
			this.invalidate("styles");
		}
		
		override protected function draw() : void {
			var _local1:Boolean = this.isInvalid("state");
			var _local2:Boolean = this.isInvalid("data");
			var _local3:Boolean = this.isInvalid("styles");
			if(_local2) {
				this.commitData();
			}
			if(_local1 || _local2 || _local3) {
				this.refreshAccessory();
			}
			super.draw();
		}
		
		override protected function autoSizeIfNeeded() : Boolean {
			var _local4:* = this._explicitWidth !== this._explicitWidth;
			var _local9:* = this._explicitHeight !== this._explicitHeight;
			var _local5:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local11:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local4 && !_local9 && !_local5 && !_local11) {
				return false;
			}
			var _local8:Boolean = this._ignoreAccessoryResizes;
			this._ignoreAccessoryResizes = true;
			var _local1:ITextRenderer = null;
			if(this._label !== null && this.labelTextRenderer) {
				_local1 = this.labelTextRenderer;
				this.refreshMaxLabelSize(true);
				this.labelTextRenderer.measureText(HELPER_POINT);
			}
			resetFluidChildDimensionsForMeasurement(this.currentSkin,this._explicitWidth,this._explicitHeight,this._explicitMinWidth,this._explicitMinHeight,this._explicitMaxWidth,this._explicitMaxHeight,this._explicitSkinWidth,this._explicitSkinHeight,this._explicitSkinMinWidth,this._explicitSkinMinHeight,this._explicitSkinMaxWidth,this._explicitSkinMaxHeight);
			var _local10:IMeasureDisplayObject = this.currentSkin as IMeasureDisplayObject;
			var _local3:Number = this._explicitWidth;
			if(_local4) {
				if(_local1 !== null) {
					_local3 = HELPER_POINT.x;
				} else {
					_local3 = 0;
				}
				if(this._layoutOrder === "labelAccessoryIcon") {
					_local3 = this.addAccessoryWidth(_local3);
					_local3 = this.addIconWidth(_local3);
				} else {
					_local3 = this.addIconWidth(_local3);
					_local3 = this.addAccessoryWidth(_local3);
				}
				_local3 += this._paddingLeft + this._paddingRight;
				if(this.currentSkin !== null && this.currentSkin.width > _local3) {
					_local3 = this.currentSkin.width;
				}
			}
			var _local6:Number = this._explicitHeight;
			if(_local9) {
				if(_local1 !== null) {
					_local6 = HELPER_POINT.y;
				} else {
					_local6 = 0;
				}
				if(this._layoutOrder === "labelAccessoryIcon") {
					_local6 = this.addAccessoryHeight(_local6);
					_local6 = this.addIconHeight(_local6);
				} else {
					_local6 = this.addIconHeight(_local6);
					_local6 = this.addAccessoryHeight(_local6);
				}
				_local6 += this._paddingTop + this._paddingBottom;
				if(this.currentSkin !== null && this.currentSkin.height > _local6) {
					_local6 = this.currentSkin.height;
				}
			}
			var _local2:Number = this._explicitMinWidth;
			if(_local5) {
				if(_local1 !== null) {
					_local2 = HELPER_POINT.x;
				} else {
					_local2 = 0;
				}
				if(this._layoutOrder === "labelAccessoryIcon") {
					_local2 = this.addAccessoryWidth(_local2);
					_local2 = this.addIconWidth(_local2);
				} else {
					_local2 = this.addIconWidth(_local2);
					_local2 = this.addAccessoryWidth(_local2);
				}
				_local2 += this._paddingLeft + this._paddingRight;
				switch(_local10) {
					default:
						if(_local10.minWidth > _local2) {
							_local2 = _local10.minWidth;
						}
						break;
					case null:
						if(this._explicitSkinMinWidth > _local2) {
							_local2 = this._explicitSkinMinWidth;
						}
						break;
					case null:
				}
			}
			var _local7:Number = this._explicitMinHeight;
			if(_local11) {
				if(_local1 !== null) {
					_local7 = HELPER_POINT.y;
				} else {
					_local7 = 0;
				}
				if(this._layoutOrder === "labelAccessoryIcon") {
					_local7 = this.addAccessoryHeight(_local7);
					_local7 = this.addIconHeight(_local7);
				} else {
					_local7 = this.addIconHeight(_local7);
					_local7 = this.addAccessoryHeight(_local7);
				}
				_local7 += this._paddingTop + this._paddingBottom;
				switch(_local10) {
					default:
						if(_local10.minHeight > _local7) {
							_local7 = _local10.minHeight;
						}
						break;
					case null:
						if(this._explicitSkinMinHeight > _local7) {
							_local7 = this._explicitSkinMinHeight;
						}
						break;
					case null:
				}
			}
			this._ignoreAccessoryResizes = _local8;
			return this.saveMeasurements(_local3,_local6,_local2,_local7);
		}
		
		override protected function changeState(value:String) : void {
			if(this._isEnabled && !this._isToggle && (!this.isSelectableWithoutToggle || this._itemHasSelectable && !this.itemToSelectable(this._data))) {
				value = "up";
			}
			if(this._useStateDelayTimer) {
				if(this._stateDelayTimer && this._stateDelayTimer.running) {
					this._delayedCurrentState = value;
					return;
				}
				if(value == "down") {
					if(this._currentState === value) {
						return;
					}
					this._delayedCurrentState = value;
					if(this._stateDelayTimer) {
						this._stateDelayTimer.reset();
					} else {
						this._stateDelayTimer = new Timer(DOWN_STATE_DELAY_MS,1);
						this._stateDelayTimer.addEventListener("timerComplete",stateDelayTimer_timerCompleteHandler);
					}
					this._stateDelayTimer.start();
					return;
				}
			}
			super.changeState(value);
		}
		
		protected function addIconWidth(width:Number) : Number {
			var _local4:Number = NaN;
			if(!this.currentIcon) {
				return width;
			}
			var _local3:Number = this.currentIcon.width;
			if(_local3 !== _local3) {
				return width;
			}
			var _local2:* = width === width;
			if(!_local2) {
				width = 0;
			}
			if(this._iconPosition == "left" || this._iconPosition == "leftBaseline" || this._iconPosition == "right" || this._iconPosition == "rightBaseline") {
				if(_local2) {
					_local4 = this._gap;
					if(this._gap == Infinity) {
						_local4 = this._minGap;
					}
					width += _local4;
				}
				width += _local3;
			} else if(_local3 > width) {
				width = _local3;
			}
			return width;
		}
		
		protected function addAccessoryWidth(width:Number) : Number {
			var _local4:Number = NaN;
			if(!this.currentAccessory) {
				return width;
			}
			var _local3:Number = this.currentAccessory.width;
			if(_local3 !== _local3) {
				return width;
			}
			var _local2:* = width === width;
			if(!_local2) {
				width = 0;
			}
			if(this._accessoryPosition == "left" || this._accessoryPosition == "right") {
				if(_local2) {
					_local4 = this._accessoryGap;
					if(this._accessoryGap !== this._accessoryGap) {
						_local4 = this._gap;
					}
					if(_local4 == Infinity) {
						if(this._minAccessoryGap !== this._minAccessoryGap) {
							_local4 = this._minGap;
						} else {
							_local4 = this._minAccessoryGap;
						}
					}
					width += _local4;
				}
				width += _local3;
			} else if(_local3 > width) {
				width = _local3;
			}
			return width;
		}
		
		protected function addIconHeight(height:Number) : Number {
			var _local4:Number = NaN;
			if(this.currentIcon === null) {
				return height;
			}
			var _local3:Number = this.currentIcon.height;
			if(_local3 !== _local3) {
				return height;
			}
			var _local2:* = height === height;
			if(!_local2) {
				height = 0;
			}
			if(this._iconPosition === "top" || this._iconPosition === "bottom") {
				if(_local2) {
					_local4 = this._gap;
					if(this._gap === Infinity) {
						_local4 = this._minGap;
					}
					height += _local4;
				}
				height += _local3;
			} else if(_local3 > height) {
				height = _local3;
			}
			return height;
		}
		
		protected function addAccessoryHeight(height:Number) : Number {
			var _local3:Number = NaN;
			if(this.currentAccessory === null) {
				return height;
			}
			var _local4:Number = this.currentAccessory.height;
			if(_local4 !== _local4) {
				return height;
			}
			var _local2:* = height === height;
			if(!_local2) {
				height = 0;
			}
			if(this._accessoryPosition === "top" || this._accessoryPosition === "bottom") {
				if(_local2) {
					_local3 = this._accessoryGap;
					if(this._accessoryGap !== this._accessoryGap) {
						_local3 = this._gap;
					}
					if(_local3 === Infinity) {
						if(this._minAccessoryGap !== this._minAccessoryGap) {
							_local3 = this._minGap;
						} else {
							_local3 = this._minAccessoryGap;
						}
					}
					height += _local3;
				}
				height += _local4;
			} else if(_local4 > height) {
				height = _local4;
			}
			return height;
		}
		
		protected function commitData() : void {
			var _local1:DisplayObject = null;
			var _local3:DisplayObject = null;
			var _local2:DisplayObject = null;
			if(this._data !== null && this._owner) {
				if(this._itemHasLabel) {
					this._label = this.itemToLabel(this._data);
				}
				if(this._itemHasSkin) {
					_local1 = this.itemToSkin(this._data);
					this._skinIsFromItem = _local1 != null;
					this.replaceSkin(_local1);
				} else if(this._skinIsFromItem) {
					this._skinIsFromItem = false;
					this.replaceSkin(null);
				}
				if(this._itemHasIcon) {
					_local3 = this.itemToIcon(this._data);
					this._iconIsFromItem = _local3 != null;
					this.replaceIcon(_local3);
				} else if(this._iconIsFromItem) {
					this._iconIsFromItem = false;
					this.replaceIcon(null);
				}
				if(this._itemHasAccessory) {
					_local2 = this.itemToAccessory(this._data);
					this._accessoryIsFromItem = _local2 != null;
					this.replaceAccessory(_local2);
				} else if(this._accessoryIsFromItem) {
					this._accessoryIsFromItem = false;
					this.replaceAccessory(null);
				}
				if(this._itemHasSelectable) {
					this._isToggle = this._explicitIsToggle && this.itemToSelectable(this._data);
				} else {
					this._isToggle = this._explicitIsToggle;
				}
				if(this._itemHasEnabled) {
					this.refreshIsEnabled(this._explicitIsEnabled && this.itemToEnabled(this._data));
				} else {
					this.refreshIsEnabled(this._explicitIsEnabled);
				}
			} else {
				if(this._itemHasLabel) {
					this._label = "";
				}
				if(this._itemHasIcon || this._iconIsFromItem) {
					this._iconIsFromItem = false;
					this.replaceIcon(null);
				}
				if(this._itemHasSkin || this._skinIsFromItem) {
					this._skinIsFromItem = false;
					this.replaceSkin(null);
				}
				if(this._itemHasAccessory || this._accessoryIsFromItem) {
					this._accessoryIsFromItem = false;
					this.replaceAccessory(null);
				}
				if(this._itemHasSelectable) {
					this._isToggle = this._explicitIsToggle;
				}
				if(this._itemHasEnabled) {
					this.refreshIsEnabled(this._explicitIsEnabled);
				}
			}
		}
		
		protected function refreshIsEnabled(value:Boolean) : void {
			if(this._isEnabled == value) {
				return;
			}
			this._isEnabled = value;
			if(!this._isEnabled) {
				this.touchable = false;
				this._currentState = "disabled";
				this.touchPointID = -1;
			} else {
				if(this._currentState == "disabled") {
					this._currentState = "up";
				}
				this.touchable = true;
			}
			this.setInvalidationFlag("state");
			this.dispatchEventWith("stageChange");
		}
		
		protected function replaceIcon(newIcon:DisplayObject) : void {
			if(this.iconLoader && this.iconLoader != newIcon) {
				this.iconLoader.removeEventListener("complete",loader_completeOrErrorHandler);
				this.iconLoader.removeEventListener("error",loader_completeOrErrorHandler);
				this.iconLoader.dispose();
				this.iconLoader = null;
			}
			if(this.iconLabel && this.iconLabel != newIcon) {
				this.iconLabel.dispose();
				this.iconLabel = null;
			}
			if(this._itemHasIcon && this.currentIcon && this.currentIcon != newIcon && this.currentIcon.parent == this) {
				this.currentIcon.removeFromParent(false);
				this.currentIcon = null;
			}
			if(this._defaultIcon !== newIcon) {
				this._defaultIcon = newIcon;
				this._stateToIconFunction = null;
				this.setInvalidationFlag("styles");
			}
			if(this.iconLoader) {
				this.iconLoader.delayTextureCreation = this._delayTextureCreationOnScroll && this._owner.isScrolling;
			}
		}
		
		protected function replaceAccessory(newAccessory:DisplayObject) : void {
			if(this.accessoryLoader && this.accessoryLoader != newAccessory) {
				this.accessoryLoader.removeEventListener("complete",loader_completeOrErrorHandler);
				this.accessoryLoader.removeEventListener("error",loader_completeOrErrorHandler);
				this.accessoryLoader.dispose();
				this.accessoryLoader = null;
			}
			if(this.accessoryLabel && this.accessoryLabel != newAccessory) {
				this.accessoryLabel.dispose();
				this.accessoryLabel = null;
			}
			if(this._itemHasAccessory && this.currentAccessory && this.currentAccessory != newAccessory && this.currentAccessory.parent == this) {
				this.currentAccessory.removeFromParent(false);
				this.currentAccessory = null;
			}
			if(this._defaultAccessory !== newAccessory) {
				this._defaultAccessory = newAccessory;
				this._stateToAccessoryFunction = null;
				this.setInvalidationFlag("styles");
			}
			if(this.accessoryLoader) {
				this.accessoryLoader.delayTextureCreation = this._delayTextureCreationOnScroll && this._owner.isScrolling;
			}
		}
		
		protected function replaceSkin(newSkin:DisplayObject) : void {
			if(this.skinLoader && this.skinLoader != newSkin) {
				this.skinLoader.removeEventListener("complete",loader_completeOrErrorHandler);
				this.skinLoader.removeEventListener("error",loader_completeOrErrorHandler);
				this.skinLoader.dispose();
				this.skinLoader = null;
			}
			if(this._itemHasSkin && this.currentSkin && this.currentSkin != newSkin && this.currentSkin.parent == this) {
				this.currentSkin.removeFromParent(false);
				this.currentSkin = null;
			}
			if(this._defaultSkin !== newSkin) {
				this._defaultSkin = newSkin;
				this._stateToSkinFunction = null;
				this.setInvalidationFlag("styles");
			}
			if(this.skinLoader) {
				this.skinLoader.delayTextureCreation = this._delayTextureCreationOnScroll && this._owner.isScrolling;
			}
		}
		
		override protected function refreshIcon() : void {
			var _local1:DisplayObject = null;
			var _local3:Object = null;
			super.refreshIcon();
			if(this.iconLabel) {
				_local1 = DisplayObject(this.iconLabel);
				for(var _local2 in this._iconLabelProperties) {
					_local3 = this._iconLabelProperties[_local2];
					_local1[_local2] = _local3;
				}
			}
		}
		
		protected function refreshAccessory() : void {
			var _local1:DisplayObject = null;
			var _local4:Object = null;
			var _local3:DisplayObject = this.currentAccessory;
			this.currentAccessory = this.getCurrentAccessory();
			if(this.currentAccessory is IFeathersControl) {
				IFeathersControl(this.currentAccessory).isEnabled = this._isEnabled;
			}
			if(this.currentAccessory != _local3) {
				if(_local3) {
					if(_local3 is IStateObserver) {
						IStateObserver(_local3).stateContext = null;
					}
					if(_local3 is IFeathersControl) {
						IFeathersControl(_local3).removeEventListener("resize",accessory_resizeHandler);
						IFeathersControl(_local3).removeEventListener("touch",accessory_touchHandler);
					}
					this.removeChild(_local3,false);
				}
				if(this.currentAccessory) {
					if(this.currentAccessory is IStateObserver) {
						IStateObserver(this.currentAccessory).stateContext = this;
					}
					this.addChild(this.currentAccessory);
					if(this.currentAccessory is IFeathersControl) {
						IFeathersControl(this.currentAccessory).addEventListener("resize",accessory_resizeHandler);
						IFeathersControl(this.currentAccessory).addEventListener("touch",accessory_touchHandler);
					}
				}
			}
			if(this.accessoryLabel) {
				_local1 = DisplayObject(this.accessoryLabel);
				for(var _local2 in this._accessoryLabelProperties) {
					_local4 = this._accessoryLabelProperties[_local2];
					_local1[_local2] = _local4;
				}
			}
		}
		
		protected function getCurrentAccessory() : DisplayObject {
			if(this._stateToAccessoryFunction !== null) {
				return DisplayObject(this._stateToAccessoryFunction(this,this._currentState,this.currentAccessory));
			}
			var _local1:DisplayObject = this._stateToAccessory[this.currentState] as DisplayObject;
			if(_local1 !== null) {
				return _local1;
			}
			return this._defaultAccessory;
		}
		
		protected function refreshIconSource(source:Object) : void {
			if(!this.iconLoader) {
				this.iconLoader = this._iconLoaderFactory();
				this.iconLoader.addEventListener("complete",loader_completeOrErrorHandler);
				this.iconLoader.addEventListener("error",loader_completeOrErrorHandler);
			}
			this.iconLoader.source = source;
		}
		
		protected function refreshIconLabel(label:String) : void {
			var _local2:Function = null;
			var _local3:String = null;
			if(!this.iconLabel) {
				_local2 = this._iconLabelFactory != null ? this._iconLabelFactory : FeathersControl.defaultTextRendererFactory;
				this.iconLabel = ITextRenderer(_local2());
				if(this.iconLabel is IStateObserver) {
					IStateObserver(this.iconLabel).stateContext = this;
				}
				_local3 = this._customIconLabelStyleName != null ? this._customIconLabelStyleName : this.iconLabelStyleName;
				this.iconLabel.styleNameList.add(_local3);
			}
			this.iconLabel.text = label;
		}
		
		protected function refreshAccessorySource(source:Object) : void {
			if(!this.accessoryLoader) {
				this.accessoryLoader = this._accessoryLoaderFactory();
				this.accessoryLoader.addEventListener("complete",loader_completeOrErrorHandler);
				this.accessoryLoader.addEventListener("error",loader_completeOrErrorHandler);
			}
			this.accessoryLoader.source = source;
		}
		
		protected function refreshAccessoryLabel(label:String) : void {
			var _local2:Function = null;
			var _local3:String = null;
			if(!this.accessoryLabel) {
				_local2 = this._accessoryLabelFactory != null ? this._accessoryLabelFactory : FeathersControl.defaultTextRendererFactory;
				this.accessoryLabel = ITextRenderer(_local2());
				if(this.accessoryLabel is IStateObserver) {
					IStateObserver(this.accessoryLabel).stateContext = this;
				}
				_local3 = this._customAccessoryLabelStyleName != null ? this._customAccessoryLabelStyleName : this.accessoryLabelStyleName;
				this.accessoryLabel.styleNameList.add(_local3);
			}
			this.accessoryLabel.text = label;
		}
		
		protected function refreshSkinSource(source:Object) : void {
			if(!this.skinLoader) {
				this.skinLoader = this._skinLoaderFactory();
				this.skinLoader.addEventListener("complete",loader_completeOrErrorHandler);
				this.skinLoader.addEventListener("error",loader_completeOrErrorHandler);
			}
			this.skinLoader.source = source;
		}
		
		override protected function layoutContent() : void {
			var _local7:String = null;
			var _local5:Boolean = this._ignoreAccessoryResizes;
			this._ignoreAccessoryResizes = true;
			var _local6:Boolean = this._ignoreIconResizes;
			this._ignoreIconResizes = true;
			this.refreshMaxLabelSize(false);
			var _local1:DisplayObject = null;
			if(this._label !== null && this.labelTextRenderer) {
				this.labelTextRenderer.validate();
				_local1 = DisplayObject(this.labelTextRenderer);
			}
			var _local2:Boolean = this.currentIcon && this._iconPosition != "manual";
			var _local3:Boolean = this.currentAccessory && this._accessoryPosition != "manual";
			var _local4:Number = this._accessoryGap;
			if(_local4 !== _local4) {
				_local4 = this._gap;
			}
			if(_local1 && _local2 && _local3) {
				this.positionSingleChild(_local1);
				if(this._layoutOrder == "labelAccessoryIcon") {
					this.positionRelativeToOthers(this.currentAccessory,_local1,null,this._accessoryPosition,_local4,null,0);
					_local7 = this._iconPosition;
					if(_local7 == "leftBaseline") {
						_local7 = "left";
					} else if(_local7 == "rightBaseline") {
						_local7 = "right";
					}
					this.positionRelativeToOthers(this.currentIcon,_local1,this.currentAccessory,_local7,this._gap,this._accessoryPosition,_local4);
				} else {
					this.positionLabelAndIcon();
					this.positionRelativeToOthers(this.currentAccessory,_local1,this.currentIcon,this._accessoryPosition,_local4,this._iconPosition,this._gap);
				}
			} else if(_local1) {
				this.positionSingleChild(_local1);
				if(_local2) {
					this.positionLabelAndIcon();
				} else if(_local3) {
					this.positionRelativeToOthers(this.currentAccessory,_local1,null,this._accessoryPosition,_local4,null,0);
				}
			} else if(_local2) {
				this.positionSingleChild(this.currentIcon);
				if(_local3) {
					this.positionRelativeToOthers(this.currentAccessory,this.currentIcon,null,this._accessoryPosition,_local4,null,0);
				}
			} else if(_local3) {
				this.positionSingleChild(this.currentAccessory);
			}
			if(this.currentAccessory) {
				if(!_local3) {
					this.currentAccessory.x = this._paddingLeft;
					this.currentAccessory.y = this._paddingTop;
				}
				this.currentAccessory.x += this._accessoryOffsetX;
				this.currentAccessory.y += this._accessoryOffsetY;
			}
			if(this.currentIcon) {
				if(!_local2) {
					this.currentIcon.x = this._paddingLeft;
					this.currentIcon.y = this._paddingTop;
				}
				this.currentIcon.x += this._iconOffsetX;
				this.currentIcon.y += this._iconOffsetY;
			}
			if(_local1) {
				this.labelTextRenderer.x += this._labelOffsetX;
				this.labelTextRenderer.y += this._labelOffsetY;
			}
			this._ignoreIconResizes = _local6;
			this._ignoreAccessoryResizes = _local5;
		}
		
		override protected function refreshMaxLabelSize(forMeasurement:Boolean) : void {
			var _local2:Boolean = false;
			var _local11:Boolean = false;
			var _local3:Number = this.actualWidth;
			if(forMeasurement) {
				_local3 = this._explicitWidth;
				if(_local3 !== _local3) {
					_local3 = this._explicitMaxWidth;
				}
			}
			_local3 -= this._paddingLeft + this._paddingRight;
			var _local7:Number = this.actualHeight;
			if(forMeasurement) {
				_local7 = this._explicitHeight;
				if(_local7 !== _local7) {
					_local7 = this._explicitMaxHeight;
				}
			}
			_local7 -= this._paddingTop + this._paddingBottom;
			var _local8:Number = this._gap;
			if(_local8 == Infinity) {
				_local8 = this._minGap;
			}
			var _local6:Number = this._accessoryGap;
			if(_local6 !== _local6) {
				_local6 = this._gap;
			}
			if(_local6 == Infinity) {
				_local6 = this._minAccessoryGap;
				if(_local6 !== _local6) {
					_local6 = this._minGap;
				}
			}
			var _local9:Boolean = this.currentIcon && (this._iconPosition == "left" || this._iconPosition == "leftBaseline" || this._iconPosition == "right" || this._iconPosition == "rightBaseline");
			var _local5:Boolean = this.currentIcon && (this._iconPosition == "top" || this._iconPosition == "bottom");
			var _local10:Boolean = this.currentAccessory && (this._accessoryPosition == "left" || this._accessoryPosition == "right");
			var _local4:Boolean = this.currentAccessory && (this._accessoryPosition == "top" || this._accessoryPosition == "bottom");
			if(this.accessoryLabel) {
				_local2 = _local9 && (_local10 || this._layoutOrder === "labelAccessoryIcon");
				if(this.iconLabel) {
					this.iconLabel.maxWidth = _local3 - _local8;
					if(this.iconLabel.maxWidth < 0) {
						this.iconLabel.maxWidth = 0;
					}
				}
				if(this.currentIcon is IValidating) {
					IValidating(this.currentIcon).validate();
				}
				if(_local2) {
					_local3 -= this.currentIcon.width + _local8;
				}
				if(_local3 < 0) {
					_local3 = 0;
				}
				this.accessoryLabel.maxWidth = _local3;
				this.accessoryLabel.maxHeight = _local7;
				if(_local9 && this.currentIcon && !_local2) {
					_local3 -= this.currentIcon.width + _local8;
				}
				if(this.currentAccessory is IValidating) {
					IValidating(this.currentAccessory).validate();
				}
				if(_local10) {
					_local3 -= this.currentAccessory.width + _local6;
				}
				if(_local4) {
					_local7 -= this.currentAccessory.height + _local6;
				}
			} else if(this.iconLabel) {
				_local11 = _local10 && (_local9 || this._layoutOrder === "labelIconAccessory");
				if(this.currentAccessory is IValidating) {
					IValidating(this.currentAccessory).validate();
				}
				if(_local11) {
					_local3 -= _local6 + this.currentAccessory.width;
				}
				if(_local3 < 0) {
					_local3 = 0;
				}
				this.iconLabel.maxWidth = _local3;
				this.iconLabel.maxHeight = _local7;
				if(_local10 && this.currentAccessory && !_local11) {
					_local3 -= _local6 + this.currentAccessory.width;
				}
				if(this.currentIcon is IValidating) {
					IValidating(this.currentIcon).validate();
				}
				if(_local9) {
					_local3 -= this.currentIcon.width + _local8;
				}
				if(_local5) {
					_local7 -= this.currentIcon.height + _local8;
				}
			} else {
				if(this.currentIcon is IValidating) {
					IValidating(this.currentIcon).validate();
				}
				if(_local9) {
					_local3 -= _local8 + this.currentIcon.width;
				}
				if(_local5) {
					_local7 -= _local8 + this.currentIcon.height;
				}
				if(this.currentAccessory is IValidating) {
					IValidating(this.currentAccessory).validate();
				}
				if(_local10) {
					_local3 -= _local6 + this.currentAccessory.width;
				}
				if(_local4) {
					_local7 -= _local6 + this.currentAccessory.height;
				}
			}
			if(_local3 < 0) {
				_local3 = 0;
			}
			if(_local7 < 0) {
				_local7 = 0;
			}
			if(this.labelTextRenderer) {
				this.labelTextRenderer.maxWidth = _local3;
				this.labelTextRenderer.maxHeight = _local7;
			}
		}
		
		protected function positionRelativeToOthers(object:DisplayObject, relativeTo:DisplayObject, relativeTo2:DisplayObject, position:String, gap:Number, otherPosition:String, otherGap:Number) : void {
			var _local15:Number = !!relativeTo2 ? Math.min(relativeTo.x,relativeTo2.x) : relativeTo.x;
			var _local14:Number = !!relativeTo2 ? Math.min(relativeTo.y,relativeTo2.y) : relativeTo.y;
			var _local8:Number = !!relativeTo2 ? Math.max(relativeTo.x + relativeTo.width,relativeTo2.x + relativeTo2.width) - _local15 : relativeTo.width;
			var _local11:Number = !!relativeTo2 ? Math.max(relativeTo.y + relativeTo.height,relativeTo2.y + relativeTo2.height) - _local14 : relativeTo.height;
			var _local13:* = _local15;
			var _local12:* = _local14;
			if(position == "top") {
				if(gap == Infinity) {
					object.y = this._paddingTop;
					_local12 = this.actualHeight - this._paddingBottom - _local11;
				} else {
					if(this._verticalAlign == "top") {
						_local12 += object.height + gap;
					} else if(this._verticalAlign == "middle") {
						_local12 += Math.round((object.height + gap) / 2);
					}
					if(relativeTo2) {
						_local12 = Math.max(_local12,this._paddingTop + object.height + gap);
					}
					object.y = _local12 - object.height - gap;
				}
			} else if(position == "right") {
				if(gap == Infinity) {
					_local13 = this._paddingLeft;
					object.x = this.actualWidth - this._paddingRight - object.width;
				} else {
					if(this._horizontalAlign == "right") {
						_local13 -= object.width + gap;
					} else if(this._horizontalAlign == "center") {
						_local13 -= Math.round((object.width + gap) / 2);
					}
					if(relativeTo2) {
						_local13 = Math.min(_local13,this.actualWidth - this._paddingRight - object.width - _local8 - gap);
					}
					object.x = _local13 + _local8 + gap;
				}
			} else if(position == "bottom") {
				if(gap == Infinity) {
					_local12 = this._paddingTop;
					object.y = this.actualHeight - this._paddingBottom - object.height;
				} else {
					if(this._verticalAlign == "bottom") {
						_local12 -= object.height + gap;
					} else if(this._verticalAlign == "middle") {
						_local12 -= Math.round((object.height + gap) / 2);
					}
					if(relativeTo2) {
						_local12 = Math.min(_local12,this.actualHeight - this._paddingBottom - object.height - _local11 - gap);
					}
					object.y = _local12 + _local11 + gap;
				}
			} else if(position == "left") {
				if(gap == Infinity) {
					object.x = this._paddingLeft;
					_local13 = this.actualWidth - this._paddingRight - _local8;
				} else {
					if(this._horizontalAlign == "left") {
						_local13 += gap + object.width;
					} else if(this._horizontalAlign == "center") {
						_local13 += Math.round((gap + object.width) / 2);
					}
					if(relativeTo2) {
						_local13 = Math.max(_local13,this._paddingLeft + object.width + gap);
					}
					object.x = _local13 - gap - object.width;
				}
			}
			var _local9:Number = _local13 - _local15;
			var _local10:Number = _local12 - _local14;
			if(!relativeTo2 || otherGap != Infinity || !(position == "top" && otherPosition == "top" || position == "right" && otherPosition == "right" || position == "bottom" && otherPosition == "bottom" || position == "left" && otherPosition == "left")) {
				relativeTo.x += _local9;
				relativeTo.y += _local10;
			}
			if(relativeTo2) {
				if(otherGap != Infinity || !(position == "left" && otherPosition == "right" || position == "right" && otherPosition == "left" || position == "top" && otherPosition == "bottom" || position == "bottom" && otherPosition == "top")) {
					relativeTo2.x += _local9;
					relativeTo2.y += _local10;
				}
				if(gap == Infinity && otherGap == Infinity) {
					if(position == "right" && otherPosition == "left") {
						relativeTo.x = relativeTo2.x + Math.round((object.x - relativeTo2.x + relativeTo2.width - relativeTo.width) / 2);
					} else if(position == "left" && otherPosition == "right") {
						relativeTo.x = object.x + Math.round((relativeTo2.x - object.x + object.width - relativeTo.width) / 2);
					} else if(position == "right" && otherPosition == "right") {
						relativeTo2.x = relativeTo.x + Math.round((object.x - relativeTo.x + relativeTo.width - relativeTo2.width) / 2);
					} else if(position == "left" && otherPosition == "left") {
						relativeTo2.x = object.x + Math.round((relativeTo.x - object.x + object.width - relativeTo2.width) / 2);
					} else if(position == "bottom" && otherPosition == "top") {
						relativeTo.y = relativeTo2.y + Math.round((object.y - relativeTo2.y + relativeTo2.height - relativeTo.height) / 2);
					} else if(position == "top" && otherPosition == "bottom") {
						relativeTo.y = object.y + Math.round((relativeTo2.y - object.y + object.height - relativeTo.height) / 2);
					} else if(position == "bottom" && otherPosition == "bottom") {
						relativeTo2.y = relativeTo.y + Math.round((object.y - relativeTo.y + relativeTo.height - relativeTo2.height) / 2);
					} else if(position == "top" && otherPosition == "top") {
						relativeTo2.y = object.y + Math.round((relativeTo.y - object.y + object.height - relativeTo2.height) / 2);
					}
				}
			}
			if(position == "left" || position == "right") {
				if(this._verticalAlign == "top") {
					object.y = this._paddingTop;
				} else if(this._verticalAlign == "bottom") {
					object.y = this.actualHeight - this._paddingBottom - object.height;
				} else {
					object.y = this._paddingTop + Math.round((this.actualHeight - this._paddingTop - this._paddingBottom - object.height) / 2);
				}
			} else if(position == "top" || position == "bottom") {
				if(this._horizontalAlign == "left") {
					object.x = this._paddingLeft;
				} else if(this._horizontalAlign == "right") {
					object.x = this.actualWidth - this._paddingRight - object.width;
				} else {
					object.x = this._paddingLeft + Math.round((this.actualWidth - this._paddingLeft - this._paddingRight - object.width) / 2);
				}
			}
		}
		
		override protected function refreshSelectionEvents() : void {
			var _local1:* = this._isEnabled && (this._isToggle || this.isSelectableWithoutToggle);
			if(this._itemHasSelectable) {
				if(_local1) {
					_local1 = this.itemToSelectable(this._data);
				}
			}
			if(this.accessoryTouchPointID >= 0) {
				if(_local1) {
					_local1 = this._isSelectableOnAccessoryTouch;
				}
			}
			this.tapToSelect.isEnabled = _local1;
			this.tapToSelect.tapToDeselect = this._isToggle;
			this.keyToSelect.isEnabled = false;
		}
		
		protected function owner_scrollStartHandler(event:Event) : void {
			if(this._delayTextureCreationOnScroll) {
				if(this.accessoryLoader) {
					this.accessoryLoader.delayTextureCreation = true;
				}
				if(this.iconLoader) {
					this.iconLoader.delayTextureCreation = true;
				}
			}
			if(this.touchPointID < 0 && this.accessoryTouchPointID < 0) {
				return;
			}
			this.resetTouchState();
			if(this._stateDelayTimer && this._stateDelayTimer.running) {
				this._stateDelayTimer.stop();
			}
			this._delayedCurrentState = null;
			if(this.accessoryTouchPointID >= 0) {
				this._owner.stopScrolling();
			}
		}
		
		protected function owner_scrollCompleteHandler(event:Event) : void {
			if(this._delayTextureCreationOnScroll) {
				if(this.accessoryLoader) {
					this.accessoryLoader.delayTextureCreation = false;
				}
				if(this.iconLoader) {
					this.iconLoader.delayTextureCreation = false;
				}
			}
		}
		
		protected function itemRenderer_removedFromStageHandler(event:Event) : void {
			this.accessoryTouchPointID = -1;
		}
		
		protected function stateDelayTimer_timerCompleteHandler(event:TimerEvent) : void {
			super.changeState(this._delayedCurrentState);
			this._delayedCurrentState = null;
		}
		
		override protected function basicButton_touchHandler(event:TouchEvent) : void {
			var _local2:Touch = null;
			if(this.currentAccessory && !this._isSelectableOnAccessoryTouch && this.currentAccessory != this.accessoryLabel && this.currentAccessory != this.accessoryLoader && this.touchPointID < 0) {
				_local2 = event.getTouch(this.currentAccessory);
				if(_local2) {
					this.changeState("up");
					return;
				}
			}
			super.basicButton_touchHandler(event);
		}
		
		protected function accessory_touchHandler(event:TouchEvent) : void {
			var _local2:Touch = null;
			if(!this._isEnabled) {
				this.accessoryTouchPointID = -1;
				return;
			}
			if(!this._stopScrollingOnAccessoryTouch || this.currentAccessory === this.accessoryLabel || this.currentAccessory === this.accessoryLoader) {
				return;
			}
			if(this.accessoryTouchPointID >= 0) {
				_local2 = event.getTouch(this.currentAccessory,"ended",this.accessoryTouchPointID);
				if(!_local2) {
					return;
				}
				this.accessoryTouchPointID = -1;
				this.refreshSelectionEvents();
			} else {
				_local2 = event.getTouch(this.currentAccessory,"began");
				if(!_local2) {
					return;
				}
				this.accessoryTouchPointID = _local2.id;
				this.refreshSelectionEvents();
			}
		}
		
		protected function accessory_resizeHandler(event:Event) : void {
			if(this._ignoreAccessoryResizes) {
				return;
			}
			this.invalidate("size");
		}
		
		protected function loader_completeOrErrorHandler(event:Event) : void {
			this.invalidate("size");
		}
	}
}

