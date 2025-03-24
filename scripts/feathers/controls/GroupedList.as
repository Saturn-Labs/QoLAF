package feathers.controls {
	import feathers.controls.renderers.DefaultGroupedListHeaderOrFooterRenderer;
	import feathers.controls.renderers.DefaultGroupedListItemRenderer;
	import feathers.controls.renderers.IGroupedListFooterRenderer;
	import feathers.controls.renderers.IGroupedListHeaderRenderer;
	import feathers.controls.renderers.IGroupedListItemRenderer;
	import feathers.controls.supportClasses.GroupedListDataViewPort;
	import feathers.core.IFocusContainer;
	import feathers.core.PropertyProxy;
	import feathers.data.HierarchicalCollection;
	import feathers.layout.ILayout;
	import feathers.layout.IVariableVirtualLayout;
	import feathers.layout.VerticalLayout;
	import feathers.skins.IStyleProvider;
	import flash.geom.Point;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	
	public class GroupedList extends Scroller implements IFocusContainer {
		public static var globalStyleProvider:IStyleProvider;
		
		public static const ALTERNATE_STYLE_NAME_INSET_GROUPED_LIST:String = "feathers-inset-grouped-list";
		
		public static const DEFAULT_CHILD_STYLE_NAME_HEADER_RENDERER:String = "feathers-grouped-list-header-renderer";
		
		public static const ALTERNATE_CHILD_STYLE_NAME_INSET_HEADER_RENDERER:String = "feathers-grouped-list-inset-header-renderer";
		
		public static const DEFAULT_CHILD_STYLE_NAME_FOOTER_RENDERER:String = "feathers-grouped-list-footer-renderer";
		
		public static const ALTERNATE_CHILD_STYLE_NAME_INSET_FOOTER_RENDERER:String = "feathers-grouped-list-inset-footer-renderer";
		
		public static const ALTERNATE_CHILD_STYLE_NAME_INSET_ITEM_RENDERER:String = "feathers-grouped-list-inset-item-renderer";
		
		public static const ALTERNATE_CHILD_STYLE_NAME_INSET_FIRST_ITEM_RENDERER:String = "feathers-grouped-list-inset-first-item-renderer";
		
		public static const ALTERNATE_CHILD_STYLE_NAME_INSET_LAST_ITEM_RENDERER:String = "feathers-grouped-list-inset-last-item-renderer";
		
		public static const ALTERNATE_CHILD_STYLE_NAME_INSET_SINGLE_ITEM_RENDERER:String = "feathers-grouped-list-inset-single-item-renderer";
		
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
		
		public static const DECELERATION_RATE_NORMAL:Number = 0.998;
		
		public static const DECELERATION_RATE_FAST:Number = 0.99;
		
		private static const HELPER_POINT:Point = new Point();
		
		protected var dataViewPort:GroupedListDataViewPort;
		
		protected var _isChildFocusEnabled:Boolean = true;
		
		protected var _layout:ILayout;
		
		protected var _dataProvider:HierarchicalCollection;
		
		protected var _isSelectable:Boolean = true;
		
		protected var _selectedGroupIndex:int = -1;
		
		protected var _selectedItemIndex:int = -1;
		
		protected var _itemRendererType:Class = DefaultGroupedListItemRenderer;
		
		protected var _itemRendererFactories:Object;
		
		protected var _itemRendererFactory:Function;
		
		protected var _factoryIDFunction:Function;
		
		protected var _typicalItem:Object = null;
		
		protected var _customItemRendererStyleName:String;
		
		protected var _itemRendererProperties:PropertyProxy;
		
		protected var _firstItemRendererType:Class;
		
		protected var _firstItemRendererFactory:Function;
		
		protected var _customFirstItemRendererStyleName:String;
		
		protected var _lastItemRendererType:Class;
		
		protected var _lastItemRendererFactory:Function;
		
		protected var _customLastItemRendererStyleName:String;
		
		protected var _singleItemRendererType:Class;
		
		protected var _singleItemRendererFactory:Function;
		
		protected var _customSingleItemRendererStyleName:String;
		
		protected var _headerRendererType:Class = DefaultGroupedListHeaderOrFooterRenderer;
		
		protected var _headerRendererFactories:Object;
		
		protected var _headerRendererFactory:Function;
		
		protected var _headerFactoryIDFunction:Function;
		
		protected var _customHeaderRendererStyleName:String = "feathers-grouped-list-header-renderer";
		
		protected var _headerRendererProperties:PropertyProxy;
		
		protected var _footerRendererType:Class = DefaultGroupedListHeaderOrFooterRenderer;
		
		protected var _footerRendererFactories:Object;
		
		protected var _footerRendererFactory:Function;
		
		protected var _footerFactoryIDFunction:Function;
		
		protected var _customFooterRendererStyleName:String = "feathers-grouped-list-footer-renderer";
		
		protected var _footerRendererProperties:PropertyProxy;
		
		protected var _headerField:String = "header";
		
		protected var _headerFunction:Function;
		
		protected var _footerField:String = "footer";
		
		protected var _footerFunction:Function;
		
		protected var _keyScrollDuration:Number = 0.25;
		
		protected var pendingGroupIndex:int = -1;
		
		protected var pendingItemIndex:int = -1;
		
		public function GroupedList() {
			super();
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return GroupedList.globalStyleProvider;
		}
		
		override public function get isFocusEnabled() : Boolean {
			return (this._isSelectable || this._minHorizontalScrollPosition != this._maxHorizontalScrollPosition || this._minVerticalScrollPosition != this._maxVerticalScrollPosition) && this._isEnabled && this._isFocusEnabled;
		}
		
		public function get isChildFocusEnabled() : Boolean {
			return this._isEnabled && this._isChildFocusEnabled;
		}
		
		public function set isChildFocusEnabled(value:Boolean) : void {
			this._isChildFocusEnabled = value;
		}
		
		public function get layout() : ILayout {
			return this._layout;
		}
		
		public function set layout(value:ILayout) : void {
			if(this._layout == value) {
				return;
			}
			if(this._layout) {
				this._layout.removeEventListener("scroll",layout_scrollHandler);
			}
			this._layout = value;
			if(this._layout is IVariableVirtualLayout) {
				this._layout.addEventListener("scroll",layout_scrollHandler);
			}
			this.invalidate("layout");
		}
		
		public function get dataProvider() : HierarchicalCollection {
			return this._dataProvider;
		}
		
		public function set dataProvider(value:HierarchicalCollection) : void {
			if(this._dataProvider == value) {
				return;
			}
			if(this._dataProvider) {
				this._dataProvider.removeEventListener("addItem",dataProvider_addItemHandler);
				this._dataProvider.removeEventListener("removeItem",dataProvider_removeItemHandler);
				this._dataProvider.removeEventListener("replaceItem",dataProvider_replaceItemHandler);
				this._dataProvider.removeEventListener("reset",dataProvider_resetHandler);
				this._dataProvider.removeEventListener("change",dataProvider_changeHandler);
			}
			this._dataProvider = value;
			if(this._dataProvider) {
				this._dataProvider.addEventListener("addItem",dataProvider_addItemHandler);
				this._dataProvider.addEventListener("removeItem",dataProvider_removeItemHandler);
				this._dataProvider.addEventListener("replaceItem",dataProvider_replaceItemHandler);
				this._dataProvider.addEventListener("reset",dataProvider_resetHandler);
				this._dataProvider.addEventListener("change",dataProvider_changeHandler);
			}
			this.horizontalScrollPosition = 0;
			this.verticalScrollPosition = 0;
			this.setSelectedLocation(-1,-1);
			this.invalidate("data");
		}
		
		public function get isSelectable() : Boolean {
			return this._isSelectable;
		}
		
		public function set isSelectable(value:Boolean) : void {
			if(this._isSelectable == value) {
				return;
			}
			this._isSelectable = value;
			if(!this._isSelectable) {
				this.setSelectedLocation(-1,-1);
			}
			this.invalidate("selected");
		}
		
		public function get selectedGroupIndex() : int {
			return this._selectedGroupIndex;
		}
		
		public function get selectedItemIndex() : int {
			return this._selectedItemIndex;
		}
		
		public function get selectedItem() : Object {
			if(!this._dataProvider || this._selectedGroupIndex < 0 || this._selectedItemIndex < 0) {
				return null;
			}
			return this._dataProvider.getItemAt(this._selectedGroupIndex,this._selectedItemIndex);
		}
		
		public function set selectedItem(value:Object) : void {
			if(!this._dataProvider) {
				this.setSelectedLocation(-1,-1);
				return;
			}
			var _local2:Vector.<int> = this._dataProvider.getItemLocation(value);
			if(_local2.length == 2) {
				this.setSelectedLocation(_local2[0],_local2[1]);
			} else {
				this.setSelectedLocation(-1,-1);
			}
		}
		
		public function get itemRendererType() : Class {
			return this._itemRendererType;
		}
		
		public function set itemRendererType(value:Class) : void {
			if(this._itemRendererType == value) {
				return;
			}
			this._itemRendererType = value;
			this.invalidate("styles");
		}
		
		public function get itemRendererFactory() : Function {
			return this._itemRendererFactory;
		}
		
		public function set itemRendererFactory(value:Function) : void {
			if(this._itemRendererFactory === value) {
				return;
			}
			this._itemRendererFactory = value;
			this.invalidate("styles");
		}
		
		public function get factoryIDFunction() : Function {
			return this._factoryIDFunction;
		}
		
		public function set factoryIDFunction(value:Function) : void {
			if(this._factoryIDFunction === value) {
				return;
			}
			this._factoryIDFunction = value;
			if(value !== null && this._itemRendererFactories === null) {
				this._itemRendererFactories = {};
			}
			this.invalidate("styles");
		}
		
		public function get typicalItem() : Object {
			return this._typicalItem;
		}
		
		public function set typicalItem(value:Object) : void {
			if(this._typicalItem == value) {
				return;
			}
			this._typicalItem = value;
			this.invalidate("data");
		}
		
		public function get customItemRendererStyleName() : String {
			return this._customItemRendererStyleName;
		}
		
		public function set customItemRendererStyleName(value:String) : void {
			if(this._customItemRendererStyleName == value) {
				return;
			}
			this._customItemRendererStyleName = value;
			this.invalidate("styles");
		}
		
		public function get itemRendererProperties() : Object {
			if(!this._itemRendererProperties) {
				this._itemRendererProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._itemRendererProperties;
		}
		
		public function set itemRendererProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._itemRendererProperties == value) {
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
			if(this._itemRendererProperties) {
				this._itemRendererProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._itemRendererProperties = PropertyProxy(value);
			if(this._itemRendererProperties) {
				this._itemRendererProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get firstItemRendererType() : Class {
			return this._firstItemRendererType;
		}
		
		public function set firstItemRendererType(value:Class) : void {
			if(this._firstItemRendererType == value) {
				return;
			}
			this._firstItemRendererType = value;
			this.invalidate("styles");
		}
		
		public function get firstItemRendererFactory() : Function {
			return this._firstItemRendererFactory;
		}
		
		public function set firstItemRendererFactory(value:Function) : void {
			if(this._firstItemRendererFactory === value) {
				return;
			}
			this._firstItemRendererFactory = value;
			this.invalidate("styles");
		}
		
		public function get customFirstItemRendererStyleName() : String {
			return this._customFirstItemRendererStyleName;
		}
		
		public function set customFirstItemRendererStyleName(value:String) : void {
			if(this._customFirstItemRendererStyleName == value) {
				return;
			}
			this._customFirstItemRendererStyleName = value;
			this.invalidate("styles");
		}
		
		public function get lastItemRendererType() : Class {
			return this._lastItemRendererType;
		}
		
		public function set lastItemRendererType(value:Class) : void {
			if(this._lastItemRendererType == value) {
				return;
			}
			this._lastItemRendererType = value;
			this.invalidate("styles");
		}
		
		public function get lastItemRendererFactory() : Function {
			return this._lastItemRendererFactory;
		}
		
		public function set lastItemRendererFactory(value:Function) : void {
			if(this._lastItemRendererFactory === value) {
				return;
			}
			this._lastItemRendererFactory = value;
			this.invalidate("styles");
		}
		
		public function get customLastItemRendererStyleName() : String {
			return this._customLastItemRendererStyleName;
		}
		
		public function set customLastItemRendererStyleName(value:String) : void {
			if(this._customLastItemRendererStyleName == value) {
				return;
			}
			this._customLastItemRendererStyleName = value;
			this.invalidate("styles");
		}
		
		public function get singleItemRendererType() : Class {
			return this._singleItemRendererType;
		}
		
		public function set singleItemRendererType(value:Class) : void {
			if(this._singleItemRendererType == value) {
				return;
			}
			this._singleItemRendererType = value;
			this.invalidate("styles");
		}
		
		public function get singleItemRendererFactory() : Function {
			return this._singleItemRendererFactory;
		}
		
		public function set singleItemRendererFactory(value:Function) : void {
			if(this._singleItemRendererFactory === value) {
				return;
			}
			this._singleItemRendererFactory = value;
			this.invalidate("styles");
		}
		
		public function get customSingleItemRendererStyleName() : String {
			return this._customSingleItemRendererStyleName;
		}
		
		public function set customSingleItemRendererStyleName(value:String) : void {
			if(this._customSingleItemRendererStyleName == value) {
				return;
			}
			this._customSingleItemRendererStyleName = value;
			this.invalidate("styles");
		}
		
		public function get headerRendererType() : Class {
			return this._headerRendererType;
		}
		
		public function set headerRendererType(value:Class) : void {
			if(this._headerRendererType == value) {
				return;
			}
			this._headerRendererType = value;
			this.invalidate("styles");
		}
		
		public function get headerRendererFactory() : Function {
			return this._headerRendererFactory;
		}
		
		public function set headerRendererFactory(value:Function) : void {
			if(this._headerRendererFactory === value) {
				return;
			}
			this._headerRendererFactory = value;
			this.invalidate("styles");
		}
		
		public function get headerFactoryIDFunction() : Function {
			return this._headerFactoryIDFunction;
		}
		
		public function set headerFactoryIDFunction(value:Function) : void {
			if(this._headerFactoryIDFunction === value) {
				return;
			}
			this._headerFactoryIDFunction = value;
			if(value !== null && this._headerRendererFactories === null) {
				this._headerRendererFactories = {};
			}
			this.invalidate("styles");
		}
		
		public function get customHeaderRendererStyleName() : String {
			return this._customHeaderRendererStyleName;
		}
		
		public function set customHeaderRendererStyleName(value:String) : void {
			if(this._customHeaderRendererStyleName == value) {
				return;
			}
			this._customHeaderRendererStyleName = value;
			this.invalidate("styles");
		}
		
		public function get headerRendererProperties() : Object {
			if(!this._headerRendererProperties) {
				this._headerRendererProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._headerRendererProperties;
		}
		
		public function set headerRendererProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._headerRendererProperties == value) {
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
			if(this._headerRendererProperties) {
				this._headerRendererProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._headerRendererProperties = PropertyProxy(value);
			if(this._headerRendererProperties) {
				this._headerRendererProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get footerRendererType() : Class {
			return this._footerRendererType;
		}
		
		public function set footerRendererType(value:Class) : void {
			if(this._footerRendererType == value) {
				return;
			}
			this._footerRendererType = value;
			this.invalidate("styles");
		}
		
		public function get footerRendererFactory() : Function {
			return this._footerRendererFactory;
		}
		
		public function set footerRendererFactory(value:Function) : void {
			if(this._footerRendererFactory === value) {
				return;
			}
			this._footerRendererFactory = value;
			this.invalidate("styles");
		}
		
		public function get footerFactoryIDFunction() : Function {
			return this._footerFactoryIDFunction;
		}
		
		public function set footerFactoryIDFunction(value:Function) : void {
			if(this._footerFactoryIDFunction === value) {
				return;
			}
			this._footerFactoryIDFunction = value;
			if(value !== null && this._footerRendererFactories === null) {
				this._footerRendererFactories = {};
			}
			this.invalidate("styles");
		}
		
		public function get customFooterRendererStyleName() : String {
			return this._customFooterRendererStyleName;
		}
		
		public function set customFooterRendererStyleName(value:String) : void {
			if(this._customFooterRendererStyleName == value) {
				return;
			}
			this._customFooterRendererStyleName = value;
			this.invalidate("styles");
		}
		
		public function get footerRendererProperties() : Object {
			if(!this._footerRendererProperties) {
				this._footerRendererProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._footerRendererProperties;
		}
		
		public function set footerRendererProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._footerRendererProperties == value) {
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
			if(this._footerRendererProperties) {
				this._footerRendererProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._footerRendererProperties = PropertyProxy(value);
			if(this._footerRendererProperties) {
				this._footerRendererProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get headerField() : String {
			return this._headerField;
		}
		
		public function set headerField(value:String) : void {
			if(this._headerField == value) {
				return;
			}
			this._headerField = value;
			this.invalidate("data");
		}
		
		public function get headerFunction() : Function {
			return this._headerFunction;
		}
		
		public function set headerFunction(value:Function) : void {
			if(this._headerFunction == value) {
				return;
			}
			this._headerFunction = value;
			this.invalidate("data");
		}
		
		public function get footerField() : String {
			return this._footerField;
		}
		
		public function set footerField(value:String) : void {
			if(this._footerField == value) {
				return;
			}
			this._footerField = value;
			this.invalidate("data");
		}
		
		public function get footerFunction() : Function {
			return this._footerFunction;
		}
		
		public function set footerFunction(value:Function) : void {
			if(this._footerFunction == value) {
				return;
			}
			this._footerFunction = value;
			this.invalidate("data");
		}
		
		public function get keyScrollDuration() : Number {
			return this._keyScrollDuration;
		}
		
		public function set keyScrollDuration(value:Number) : void {
			this._keyScrollDuration = value;
		}
		
		override public function dispose() : void {
			this._selectedGroupIndex = -1;
			this._selectedItemIndex = -1;
			this.dataProvider = null;
			this.layout = null;
			super.dispose();
		}
		
		override public function scrollToPosition(horizontalScrollPosition:Number, verticalScrollPosition:Number, animationDuration:Number = NaN) : void {
			this.pendingItemIndex = -1;
			super.scrollToPosition(horizontalScrollPosition,verticalScrollPosition,animationDuration);
		}
		
		override public function scrollToPageIndex(horizontalPageIndex:int, verticalPageIndex:int, animationDuration:Number = NaN) : void {
			this.pendingGroupIndex = -1;
			this.pendingItemIndex = -1;
			super.scrollToPageIndex(horizontalPageIndex,verticalPageIndex,animationDuration);
		}
		
		public function scrollToDisplayIndex(groupIndex:int, itemIndex:int = -1, animationDuration:Number = 0) : void {
			this.hasPendingHorizontalPageIndex = false;
			this.hasPendingVerticalPageIndex = false;
			this.pendingHorizontalScrollPosition = NaN;
			this.pendingVerticalScrollPosition = NaN;
			if(this.pendingGroupIndex == groupIndex && this.pendingItemIndex == itemIndex && this.pendingScrollDuration == animationDuration) {
				return;
			}
			this.pendingGroupIndex = groupIndex;
			this.pendingItemIndex = itemIndex;
			this.pendingScrollDuration = animationDuration;
			this.invalidate("pendingScroll");
		}
		
		public function setSelectedLocation(groupIndex:int, itemIndex:int) : void {
			if(this._selectedGroupIndex == groupIndex && this._selectedItemIndex == itemIndex) {
				return;
			}
			if(groupIndex < 0 && itemIndex >= 0 || groupIndex >= 0 && itemIndex < 0) {
				throw new ArgumentError("To deselect items, group index and item index must both be < 0.");
			}
			this._selectedGroupIndex = groupIndex;
			this._selectedItemIndex = itemIndex;
			this.invalidate("selected");
			this.dispatchEventWith("change");
		}
		
		public function getItemRendererFactoryWithID(id:String) : Function {
			if(this._itemRendererFactories && id in this._itemRendererFactories) {
				return this._itemRendererFactories[id] as Function;
			}
			return null;
		}
		
		public function setItemRendererFactoryWithID(id:String, factory:Function) : void {
			if(id === null) {
				this.itemRendererFactory = factory;
				return;
			}
			if(this._itemRendererFactories === null) {
				this._itemRendererFactories = {};
			}
			if(factory !== null) {
				this._itemRendererFactories[id] = factory;
			} else {
				delete this._itemRendererFactories[id];
			}
		}
		
		public function getHeaderRendererFactoryWithID(id:String) : Function {
			if(this._headerRendererFactories && id in this._headerRendererFactories) {
				return this._headerRendererFactories[id] as Function;
			}
			return null;
		}
		
		public function setHeaderRendererFactoryWithID(id:String, factory:Function) : void {
			if(id === null) {
				this.headerRendererFactory = factory;
				return;
			}
			if(this._headerRendererFactories === null) {
				this._headerRendererFactories = {};
			}
			if(factory !== null) {
				this._headerRendererFactories[id] = factory;
			} else {
				delete this._headerRendererFactories[id];
			}
		}
		
		public function getFooterRendererFactoryWithID(id:String) : Function {
			if(this._footerRendererFactories && id in this._footerRendererFactories) {
				return this._footerRendererFactories[id] as Function;
			}
			return null;
		}
		
		public function setFooterRendererFactoryWithID(id:String, factory:Function) : void {
			if(id === null) {
				this.footerRendererFactory = factory;
				return;
			}
			if(this._footerRendererFactories === null) {
				this._footerRendererFactories = {};
			}
			if(factory !== null) {
				this._footerRendererFactories[id] = factory;
			} else {
				delete this._footerRendererFactories[id];
			}
		}
		
		public function groupToHeaderData(group:Object) : Object {
			if(this._headerFunction != null) {
				return this._headerFunction(group);
			}
			if(this._headerField != null && group && group.hasOwnProperty(this._headerField)) {
				return group[this._headerField];
			}
			return null;
		}
		
		public function groupToFooterData(group:Object) : Object {
			if(this._footerFunction != null) {
				return this._footerFunction(group);
			}
			if(this._footerField != null && group && group.hasOwnProperty(this._footerField)) {
				return group[this._footerField];
			}
			return null;
		}
		
		public function itemToItemRenderer(item:Object) : IGroupedListItemRenderer {
			return this.dataViewPort.itemToItemRenderer(item);
		}
		
		public function headerDataToHeaderRenderer(headerData:Object) : IGroupedListHeaderRenderer {
			return this.dataViewPort.headerDataToHeaderRenderer(headerData);
		}
		
		public function footerDataToFooterRenderer(footerData:Object) : IGroupedListFooterRenderer {
			return this.dataViewPort.footerDataToFooterRenderer(footerData);
		}
		
		override protected function initialize() : void {
			var _local1:VerticalLayout = null;
			var _local2:* = this._layout != null;
			super.initialize();
			if(!this.dataViewPort) {
				this.viewPort = this.dataViewPort = new GroupedListDataViewPort();
				this.dataViewPort.owner = this;
				this.dataViewPort.addEventListener("change",dataViewPort_changeHandler);
				this.viewPort = this.dataViewPort;
			}
			if(!_local2) {
				if(this._hasElasticEdges && this._verticalScrollPolicy === "auto" && this._scrollBarDisplayMode !== "fixed") {
					this.verticalScrollPolicy = "on";
				}
				_local1 = new VerticalLayout();
				_local1.useVirtualLayout = true;
				_local1.padding = 0;
				_local1.gap = 0;
				_local1.horizontalAlign = "justify";
				_local1.verticalAlign = "top";
				_local1.stickyHeader = !this._styleNameList.contains("feathers-inset-grouped-list");
				this.layout = _local1;
			}
		}
		
		override protected function draw() : void {
			this.refreshDataViewPortProperties();
			super.draw();
		}
		
		protected function refreshDataViewPortProperties() : void {
			this.dataViewPort.isSelectable = this._isSelectable;
			this.dataViewPort.setSelectedLocation(this._selectedGroupIndex,this._selectedItemIndex);
			this.dataViewPort.dataProvider = this._dataProvider;
			this.dataViewPort.typicalItem = this._typicalItem;
			this.dataViewPort.itemRendererType = this._itemRendererType;
			this.dataViewPort.itemRendererFactory = this._itemRendererFactory;
			this.dataViewPort.itemRendererFactories = this._itemRendererFactories;
			this.dataViewPort.factoryIDFunction = this._factoryIDFunction;
			this.dataViewPort.itemRendererProperties = this._itemRendererProperties;
			this.dataViewPort.customItemRendererStyleName = this._customItemRendererStyleName;
			this.dataViewPort.firstItemRendererType = this._firstItemRendererType;
			this.dataViewPort.firstItemRendererFactory = this._firstItemRendererFactory;
			this.dataViewPort.customFirstItemRendererStyleName = this._customFirstItemRendererStyleName;
			this.dataViewPort.lastItemRendererType = this._lastItemRendererType;
			this.dataViewPort.lastItemRendererFactory = this._lastItemRendererFactory;
			this.dataViewPort.customLastItemRendererStyleName = this._customLastItemRendererStyleName;
			this.dataViewPort.singleItemRendererType = this._singleItemRendererType;
			this.dataViewPort.singleItemRendererFactory = this._singleItemRendererFactory;
			this.dataViewPort.customSingleItemRendererStyleName = this._customSingleItemRendererStyleName;
			this.dataViewPort.headerRendererType = this._headerRendererType;
			this.dataViewPort.headerRendererFactory = this._headerRendererFactory;
			this.dataViewPort.headerRendererFactories = this._headerRendererFactories;
			this.dataViewPort.headerFactoryIDFunction = this._headerFactoryIDFunction;
			this.dataViewPort.headerRendererProperties = this._headerRendererProperties;
			this.dataViewPort.customHeaderRendererStyleName = this._customHeaderRendererStyleName;
			this.dataViewPort.footerRendererType = this._footerRendererType;
			this.dataViewPort.footerRendererFactory = this._footerRendererFactory;
			this.dataViewPort.footerRendererFactories = this._footerRendererFactories;
			this.dataViewPort.footerFactoryIDFunction = this._footerFactoryIDFunction;
			this.dataViewPort.footerRendererProperties = this._footerRendererProperties;
			this.dataViewPort.customFooterRendererStyleName = this._customFooterRendererStyleName;
			this.dataViewPort.layout = this._layout;
		}
		
		override protected function handlePendingScroll() : void {
			var _local1:Object = null;
			var _local2:Number = NaN;
			var _local3:Number = NaN;
			if(this.pendingGroupIndex >= 0) {
				if(this.pendingItemIndex >= 0) {
					_local1 = this._dataProvider.getItemAt(this.pendingGroupIndex,this.pendingItemIndex);
				} else {
					_local1 = this._dataProvider.getItemAt(this.pendingGroupIndex);
				}
				if(_local1 is Object) {
					this.dataViewPort.getScrollPositionForIndex(this.pendingGroupIndex,this.pendingItemIndex,HELPER_POINT);
					this.pendingGroupIndex = -1;
					this.pendingItemIndex = -1;
					_local2 = HELPER_POINT.x;
					if(_local2 < this._minHorizontalScrollPosition) {
						_local2 = this._minHorizontalScrollPosition;
					} else if(_local2 > this._maxHorizontalScrollPosition) {
						_local2 = this._maxHorizontalScrollPosition;
					}
					_local3 = HELPER_POINT.y;
					if(_local3 < this._minVerticalScrollPosition) {
						_local3 = this._minVerticalScrollPosition;
					} else if(_local3 > this._maxVerticalScrollPosition) {
						_local3 = this._maxVerticalScrollPosition;
					}
					this.throwTo(_local2,_local3,this.pendingScrollDuration);
				}
			}
			super.handlePendingScroll();
		}
		
		override protected function stage_keyDownHandler(event:KeyboardEvent) : void {
			var _local5:int = 0;
			var _local4:int = 0;
			var _local2:int = 0;
			if(!this._dataProvider) {
				return;
			}
			var _local3:Boolean = false;
			if(event.keyCode == 36) {
				if(this._dataProvider.getLength() > 0 && this._dataProvider.getLength(0) > 0) {
					this.setSelectedLocation(0,0);
					_local3 = true;
				}
			}
			if(event.keyCode == 35) {
				_local5 = this._dataProvider.getLength();
				_local4 = -1;
				do {
					_local5--;
					if(_local5 >= 0) {
						_local4 = this._dataProvider.getLength(_local5) - 1;
					}
				}
				while(_local5 > 0 && _local4 < 0);
				
				if(_local5 >= 0 && _local4 >= 0) {
					this.setSelectedLocation(_local5,_local4);
					_local3 = true;
				}
			} else if(event.keyCode == 38) {
				_local5 = this._selectedGroupIndex;
				_local4 = this._selectedItemIndex - 1;
				if(_local4 < 0) {
					do {
						_local5--;
						if(_local5 >= 0) {
							_local4 = this._dataProvider.getLength(_local5) - 1;
						}
					}
					while(_local5 > 0 && _local4 < 0);
					
				}
				if(_local5 >= 0 && _local4 >= 0) {
					this.setSelectedLocation(_local5,_local4);
					_local3 = true;
				}
			} else if(event.keyCode == 40) {
				_local5 = this._selectedGroupIndex;
				if(_local5 < 0) {
					_local4 = -1;
				} else {
					_local4 = this._selectedItemIndex + 1;
				}
				if(_local5 < 0 || _local4 >= this._dataProvider.getLength(_local5)) {
					_local4 = -1;
					_local5++;
					_local2 = this._dataProvider.getLength();
					while(_local5 < _local2 && _local4 < 0) {
						if(this._dataProvider.getLength(_local5) > 0) {
							_local4 = 0;
						} else {
							_local5++;
						}
					}
				}
				if(_local5 >= 0 && _local4 >= 0) {
					this.setSelectedLocation(_local5,_local4);
					_local3 = true;
				}
			}
			if(_local3) {
				this.dataViewPort.getNearestScrollPositionForIndex(this._selectedGroupIndex,this.selectedItemIndex,HELPER_POINT);
				this.scrollToPosition(HELPER_POINT.x,HELPER_POINT.y,this._keyScrollDuration);
			}
		}
		
		protected function dataProvider_changeHandler(event:Event) : void {
			this.invalidate("data");
		}
		
		protected function dataProvider_resetHandler(event:Event) : void {
			this.horizontalScrollPosition = 0;
			this.verticalScrollPosition = 0;
			this.setSelectedLocation(-1,-1);
		}
		
		protected function dataProvider_addItemHandler(event:Event, indices:Array) : void {
			var _local3:int = 0;
			if(this._selectedGroupIndex == -1) {
				return;
			}
			var _local4:int = indices[0] as int;
			if(indices.length > 1) {
				_local3 = indices[1] as int;
				if(this._selectedGroupIndex == _local4 && this._selectedItemIndex >= _local3) {
					this.setSelectedLocation(this._selectedGroupIndex,this._selectedItemIndex + 1);
				}
			} else {
				this.setSelectedLocation(this._selectedGroupIndex + 1,this._selectedItemIndex);
			}
		}
		
		protected function dataProvider_removeItemHandler(event:Event, indices:Array) : void {
			var _local3:int = 0;
			if(this._selectedGroupIndex == -1) {
				return;
			}
			var _local4:int = indices[0] as int;
			if(indices.length > 1) {
				_local3 = indices[1] as int;
				if(this._selectedGroupIndex == _local4) {
					if(this._selectedItemIndex == _local3) {
						this.setSelectedLocation(-1,-1);
					} else if(this._selectedItemIndex > _local3) {
						this.setSelectedLocation(this._selectedGroupIndex,this._selectedItemIndex - 1);
					}
				}
			} else if(this._selectedGroupIndex == _local4) {
				this.setSelectedLocation(-1,-1);
			} else if(this._selectedGroupIndex > _local4) {
				this.setSelectedLocation(this._selectedGroupIndex - 1,this._selectedItemIndex);
			}
		}
		
		protected function dataProvider_replaceItemHandler(event:Event, indices:Array) : void {
			var _local3:int = 0;
			if(this._selectedGroupIndex == -1) {
				return;
			}
			var _local4:int = indices[0] as int;
			if(indices.length > 1) {
				_local3 = indices[1] as int;
				if(this._selectedGroupIndex == _local4 && this._selectedItemIndex == _local3) {
					this.setSelectedLocation(-1,-1);
				}
			} else if(this._selectedGroupIndex == _local4) {
				this.setSelectedLocation(-1,-1);
			}
		}
		
		protected function dataViewPort_changeHandler(event:Event) : void {
			this.setSelectedLocation(this.dataViewPort.selectedGroupIndex,this.dataViewPort.selectedItemIndex);
		}
		
		private function layout_scrollHandler(event:Event, scrollOffset:Point) : void {
			var _local3:IVariableVirtualLayout = IVariableVirtualLayout(this._layout);
			if(!this.isScrolling || !_local3.useVirtualLayout || !_local3.hasVariableItemDimensions) {
				return;
			}
			var _local4:Number = scrollOffset.x;
			this._startHorizontalScrollPosition += _local4;
			this._horizontalScrollPosition += _local4;
			if(this._horizontalAutoScrollTween) {
				this._targetHorizontalScrollPosition += _local4;
				this.throwTo(this._targetHorizontalScrollPosition,NaN,this._horizontalAutoScrollTween.totalTime - this._horizontalAutoScrollTween.currentTime);
			}
			var _local5:Number = scrollOffset.y;
			this._startVerticalScrollPosition += _local5;
			this._verticalScrollPosition += _local5;
			if(this._verticalAutoScrollTween) {
				this._targetVerticalScrollPosition += _local5;
				this.throwTo(NaN,this._targetVerticalScrollPosition,this._verticalAutoScrollTween.totalTime - this._verticalAutoScrollTween.currentTime);
			}
		}
	}
}

