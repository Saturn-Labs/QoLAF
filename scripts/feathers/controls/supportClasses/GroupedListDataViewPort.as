package feathers.controls.supportClasses {
	import feathers.controls.GroupedList;
	import feathers.controls.Scroller;
	import feathers.controls.renderers.IGroupedListFooterRenderer;
	import feathers.controls.renderers.IGroupedListHeaderRenderer;
	import feathers.controls.renderers.IGroupedListItemRenderer;
	import feathers.core.FeathersControl;
	import feathers.core.IFeathersControl;
	import feathers.core.IValidating;
	import feathers.core.PropertyProxy;
	import feathers.data.HierarchicalCollection;
	import feathers.layout.IGroupedLayout;
	import feathers.layout.ILayout;
	import feathers.layout.IVariableVirtualLayout;
	import feathers.layout.IVirtualLayout;
	import feathers.layout.LayoutBoundsResult;
	import feathers.layout.ViewPortBounds;
	import flash.errors.IllegalOperationError;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	public class GroupedListDataViewPort extends FeathersControl implements IViewPort {
		private static const INVALIDATION_FLAG_ITEM_RENDERER_FACTORY:String = "itemRendererFactory";
		
		private static const FIRST_ITEM_RENDERER_FACTORY_ID:String = "GroupedListDataViewPort-first";
		
		private static const SINGLE_ITEM_RENDERER_FACTORY_ID:String = "GroupedListDataViewPort-single";
		
		private static const LAST_ITEM_RENDERER_FACTORY_ID:String = "GroupedListDataViewPort-last";
		
		private static const HELPER_POINT:Point = new Point();
		
		private static const HELPER_VECTOR:Vector.<int> = new Vector.<int>(0);
		
		private var touchPointID:int = -1;
		
		private var _viewPortBounds:ViewPortBounds = new ViewPortBounds();
		
		private var _layoutResult:LayoutBoundsResult = new LayoutBoundsResult();
		
		private var _actualMinVisibleWidth:Number = 0;
		
		private var _explicitMinVisibleWidth:Number;
		
		private var _maxVisibleWidth:Number = Infinity;
		
		private var _actualVisibleWidth:Number = NaN;
		
		private var _explicitVisibleWidth:Number = NaN;
		
		private var _actualMinVisibleHeight:Number = 0;
		
		private var _explicitMinVisibleHeight:Number;
		
		private var _maxVisibleHeight:Number = Infinity;
		
		private var _actualVisibleHeight:Number;
		
		private var _explicitVisibleHeight:Number = NaN;
		
		protected var _contentX:Number = 0;
		
		protected var _contentY:Number = 0;
		
		private var _layoutItems:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
		
		private var _typicalItemIsInDataProvider:Boolean = false;
		
		private var _typicalItemRenderer:IGroupedListItemRenderer;
		
		private var _unrenderedItems:Vector.<int> = new Vector.<int>(0);
		
		private var _defaultItemRendererStorage:ItemRendererFactoryStorage = new ItemRendererFactoryStorage();
		
		private var _itemStorageMap:Object = {};
		
		private var _itemRendererMap:Dictionary = new Dictionary(true);
		
		private var _unrenderedHeaders:Vector.<int> = new Vector.<int>(0);
		
		private var _defaultHeaderRendererStorage:HeaderRendererFactoryStorage = new HeaderRendererFactoryStorage();
		
		private var _headerStorageMap:Object;
		
		private var _headerRendererMap:Dictionary = new Dictionary(true);
		
		private var _unrenderedFooters:Vector.<int> = new Vector.<int>(0);
		
		private var _defaultFooterRendererStorage:FooterRendererFactoryStorage = new FooterRendererFactoryStorage();
		
		private var _footerStorageMap:Object;
		
		private var _footerRendererMap:Dictionary = new Dictionary(true);
		
		private var _headerIndices:Vector.<int> = new Vector.<int>(0);
		
		private var _footerIndices:Vector.<int> = new Vector.<int>(0);
		
		private var _isScrolling:Boolean = false;
		
		private var _owner:GroupedList;
		
		private var _updateForDataReset:Boolean = false;
		
		private var _dataProvider:HierarchicalCollection;
		
		private var _isSelectable:Boolean = true;
		
		private var _selectedGroupIndex:int = -1;
		
		private var _selectedItemIndex:int = -1;
		
		private var _itemRendererType:Class;
		
		private var _itemRendererFactory:Function;
		
		private var _itemRendererFactories:Object;
		
		private var _factoryIDFunction:Function;
		
		private var _customItemRendererStyleName:String;
		
		private var _typicalItem:Object = null;
		
		private var _itemRendererProperties:PropertyProxy;
		
		private var _firstItemRendererType:Class;
		
		private var _firstItemRendererFactory:Function;
		
		private var _customFirstItemRendererStyleName:String;
		
		private var _lastItemRendererType:Class;
		
		private var _lastItemRendererFactory:Function;
		
		private var _customLastItemRendererStyleName:String;
		
		private var _singleItemRendererType:Class;
		
		private var _singleItemRendererFactory:Function;
		
		private var _customSingleItemRendererStyleName:String;
		
		private var _headerRendererType:Class;
		
		private var _headerRendererFactory:Function;
		
		private var _headerRendererFactories:Object;
		
		private var _headerFactoryIDFunction:Function;
		
		private var _customHeaderRendererStyleName:String;
		
		private var _headerRendererProperties:PropertyProxy;
		
		private var _footerRendererType:Class;
		
		private var _footerRendererFactory:Function;
		
		private var _footerRendererFactories:Object;
		
		private var _footerFactoryIDFunction:Function;
		
		private var _customFooterRendererStyleName:String;
		
		private var _footerRendererProperties:PropertyProxy;
		
		private var _ignoreLayoutChanges:Boolean = false;
		
		private var _ignoreRendererResizing:Boolean = false;
		
		private var _layout:ILayout;
		
		private var _horizontalScrollPosition:Number = 0;
		
		private var _verticalScrollPosition:Number = 0;
		
		private var _minimumItemCount:int;
		
		private var _minimumHeaderCount:int;
		
		private var _minimumFooterCount:int;
		
		private var _minimumFirstAndLastItemCount:int;
		
		private var _minimumSingleItemCount:int;
		
		private var _ignoreSelectionChanges:Boolean = false;
		
		public function GroupedListDataViewPort() {
			super();
			this.addEventListener("touch",touchHandler);
			this.addEventListener("removedFromStage",removedFromStageHandler);
		}
		
		public function get minVisibleWidth() : Number {
			if(this._explicitMinVisibleWidth !== this._explicitMinVisibleWidth) {
				return this._actualMinVisibleWidth;
			}
			return this._explicitMinVisibleWidth;
		}
		
		public function set minVisibleWidth(value:Number) : void {
			if(this._explicitMinVisibleWidth == value) {
				return;
			}
			var _local2:* = value !== value;
			if(_local2 && this._explicitMinVisibleWidth !== this._explicitMinVisibleWidth) {
				return;
			}
			var _local3:Number = this._explicitMinVisibleWidth;
			this._explicitMinVisibleWidth = value;
			if(_local2) {
				this._actualMinVisibleWidth = 0;
				this.invalidate("size");
			} else {
				this._actualMinVisibleWidth = value;
				if(this._explicitVisibleWidth !== this._explicitVisibleWidth && (this._actualVisibleWidth < value || this._actualVisibleWidth === _local3)) {
					this.invalidate("size");
				}
			}
		}
		
		public function get maxVisibleWidth() : Number {
			return this._maxVisibleWidth;
		}
		
		public function set maxVisibleWidth(value:Number) : void {
			if(this._maxVisibleWidth == value) {
				return;
			}
			if(value !== value) {
				throw new ArgumentError("maxVisibleWidth cannot be NaN");
			}
			var _local2:Number = this._maxVisibleWidth;
			this._maxVisibleWidth = value;
			if(this._explicitVisibleWidth !== this._explicitVisibleWidth && (this._actualVisibleWidth > value || this._actualVisibleWidth === _local2)) {
				this.invalidate("size");
			}
		}
		
		public function get visibleWidth() : Number {
			return this._actualVisibleWidth;
		}
		
		public function set visibleWidth(value:Number) : void {
			if(this._explicitVisibleWidth == value || value !== value && this._explicitVisibleWidth !== this._explicitVisibleWidth) {
				return;
			}
			this._explicitVisibleWidth = value;
			if(this._actualVisibleWidth !== value) {
				this.invalidate("size");
			}
		}
		
		public function get minVisibleHeight() : Number {
			if(this._explicitMinVisibleHeight !== this._explicitMinVisibleHeight) {
				return this._actualMinVisibleHeight;
			}
			return this._explicitMinVisibleHeight;
		}
		
		public function set minVisibleHeight(value:Number) : void {
			if(this._explicitMinVisibleHeight == value) {
				return;
			}
			var _local2:* = value !== value;
			if(_local2 && this._explicitMinVisibleHeight !== this._explicitMinVisibleHeight) {
				return;
			}
			var _local3:Number = this._explicitMinVisibleHeight;
			this._explicitMinVisibleHeight = value;
			if(_local2) {
				this._actualMinVisibleHeight = 0;
				this.invalidate("size");
			} else {
				this._actualMinVisibleHeight = value;
				if(this._explicitVisibleHeight !== this._explicitVisibleHeight && (this._actualVisibleHeight < value || this._actualVisibleHeight === _local3)) {
					this.invalidate("size");
				}
			}
		}
		
		public function get maxVisibleHeight() : Number {
			return this._maxVisibleHeight;
		}
		
		public function set maxVisibleHeight(value:Number) : void {
			if(this._maxVisibleHeight == value) {
				return;
			}
			if(value !== value) {
				throw new ArgumentError("maxVisibleHeight cannot be NaN");
			}
			var _local2:Number = this._maxVisibleHeight;
			this._maxVisibleHeight = value;
			if(this._explicitVisibleHeight !== this._explicitVisibleHeight && (this._actualVisibleHeight > value || this._actualVisibleHeight === _local2)) {
				this.invalidate("size");
			}
		}
		
		public function get visibleHeight() : Number {
			return this._actualVisibleHeight;
		}
		
		public function set visibleHeight(value:Number) : void {
			if(this._explicitVisibleHeight == value || value !== value && this._explicitVisibleHeight !== this._explicitVisibleHeight) {
				return;
			}
			this._explicitVisibleHeight = value;
			if(this._actualVisibleHeight !== value) {
				this.invalidate("size");
			}
		}
		
		public function get contentX() : Number {
			return this._contentX;
		}
		
		public function get contentY() : Number {
			return this._contentY;
		}
		
		public function get horizontalScrollStep() : Number {
			if(this._typicalItemRenderer === null) {
				return 0;
			}
			var _local1:Number = Number(this._typicalItemRenderer.width);
			var _local2:Number = Number(this._typicalItemRenderer.height);
			if(_local1 < _local2) {
				return _local1;
			}
			return _local2;
		}
		
		public function get verticalScrollStep() : Number {
			if(this._typicalItemRenderer === null) {
				return 0;
			}
			var _local1:Number = Number(this._typicalItemRenderer.width);
			var _local2:Number = Number(this._typicalItemRenderer.height);
			if(_local1 < _local2) {
				return _local1;
			}
			return _local2;
		}
		
		public function get owner() : GroupedList {
			return this._owner;
		}
		
		public function set owner(value:GroupedList) : void {
			if(this._owner == value) {
				return;
			}
			if(this._owner) {
				this._owner.removeEventListener("scrollStart",owner_scrollStartHandler);
			}
			this._owner = value;
			if(this._owner) {
				this._owner.addEventListener("scrollStart",owner_scrollStartHandler);
			}
		}
		
		public function get dataProvider() : HierarchicalCollection {
			return this._dataProvider;
		}
		
		public function set dataProvider(value:HierarchicalCollection) : void {
			if(this._dataProvider == value) {
				return;
			}
			if(this._dataProvider) {
				this._dataProvider.removeEventListener("change",dataProvider_changeHandler);
				this._dataProvider.removeEventListener("reset",dataProvider_resetHandler);
				this._dataProvider.removeEventListener("addItem",dataProvider_addItemHandler);
				this._dataProvider.removeEventListener("removeItem",dataProvider_removeItemHandler);
				this._dataProvider.removeEventListener("replaceItem",dataProvider_replaceItemHandler);
				this._dataProvider.removeEventListener("updateItem",dataProvider_updateItemHandler);
				this._dataProvider.removeEventListener("updateAll",dataProvider_updateAllHandler);
			}
			this._dataProvider = value;
			if(this._dataProvider) {
				this._dataProvider.addEventListener("change",dataProvider_changeHandler);
				this._dataProvider.addEventListener("reset",dataProvider_resetHandler);
				this._dataProvider.addEventListener("addItem",dataProvider_addItemHandler);
				this._dataProvider.addEventListener("removeItem",dataProvider_removeItemHandler);
				this._dataProvider.addEventListener("replaceItem",dataProvider_replaceItemHandler);
				this._dataProvider.addEventListener("updateItem",dataProvider_updateItemHandler);
				this._dataProvider.addEventListener("updateAll",dataProvider_updateAllHandler);
			}
			if(this._layout is IVariableVirtualLayout) {
				IVariableVirtualLayout(this._layout).resetVariableVirtualCache();
			}
			this._updateForDataReset = true;
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
		
		public function get itemRendererType() : Class {
			return this._itemRendererType;
		}
		
		public function set itemRendererType(value:Class) : void {
			if(this._itemRendererType == value) {
				return;
			}
			this._itemRendererType = value;
			this.invalidate("itemRendererFactory");
		}
		
		public function get itemRendererFactory() : Function {
			return this._itemRendererFactory;
		}
		
		public function set itemRendererFactory(value:Function) : void {
			if(this._itemRendererFactory === value) {
				return;
			}
			this._itemRendererFactory = value;
			this.invalidate("itemRendererFactory");
		}
		
		public function get itemRendererFactories() : Object {
			return this._itemRendererFactories;
		}
		
		public function set itemRendererFactories(value:Object) : void {
			if(this._itemRendererFactories === value) {
				return;
			}
			this._itemRendererFactories = value;
			this.invalidate("itemRendererFactory");
		}
		
		public function get factoryIDFunction() : Function {
			return this._factoryIDFunction;
		}
		
		public function set factoryIDFunction(value:Function) : void {
			if(this._factoryIDFunction === value) {
				return;
			}
			this._factoryIDFunction = value;
			this.invalidate("itemRendererFactory");
		}
		
		public function get customItemRendererStyleName() : String {
			return this._customItemRendererStyleName;
		}
		
		public function set customItemRendererStyleName(value:String) : void {
			if(this._customItemRendererStyleName == value) {
				return;
			}
			this._customItemRendererStyleName = value;
			this.invalidate("itemRendererFactory");
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
		
		public function get itemRendererProperties() : PropertyProxy {
			return this._itemRendererProperties;
		}
		
		public function set itemRendererProperties(value:PropertyProxy) : void {
			if(this._itemRendererProperties == value) {
				return;
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
			this.invalidate("itemRendererFactory");
		}
		
		public function get firstItemRendererFactory() : Function {
			return this._firstItemRendererFactory;
		}
		
		public function set firstItemRendererFactory(value:Function) : void {
			if(this._firstItemRendererFactory === value) {
				return;
			}
			this._firstItemRendererFactory = value;
			this.invalidate("itemRendererFactory");
		}
		
		public function get customFirstItemRendererStyleName() : String {
			return this._customFirstItemRendererStyleName;
		}
		
		public function set customFirstItemRendererStyleName(value:String) : void {
			if(this._customFirstItemRendererStyleName == value) {
				return;
			}
			this._customFirstItemRendererStyleName = value;
			this.invalidate("itemRendererFactory");
		}
		
		public function get lastItemRendererType() : Class {
			return this._lastItemRendererType;
		}
		
		public function set lastItemRendererType(value:Class) : void {
			if(this._lastItemRendererType == value) {
				return;
			}
			this._lastItemRendererType = value;
			this.invalidate("itemRendererFactory");
		}
		
		public function get lastItemRendererFactory() : Function {
			return this._lastItemRendererFactory;
		}
		
		public function set lastItemRendererFactory(value:Function) : void {
			if(this._lastItemRendererFactory === value) {
				return;
			}
			this._lastItemRendererFactory = value;
			this.invalidate("itemRendererFactory");
		}
		
		public function get customLastItemRendererStyleName() : String {
			return this._customLastItemRendererStyleName;
		}
		
		public function set customLastItemRendererStyleName(value:String) : void {
			if(this._customLastItemRendererStyleName == value) {
				return;
			}
			this._customLastItemRendererStyleName = value;
			this.invalidate("itemRendererFactory");
		}
		
		public function get singleItemRendererType() : Class {
			return this._singleItemRendererType;
		}
		
		public function set singleItemRendererType(value:Class) : void {
			if(this._singleItemRendererType == value) {
				return;
			}
			this._singleItemRendererType = value;
			this.invalidate("itemRendererFactory");
		}
		
		public function get singleItemRendererFactory() : Function {
			return this._singleItemRendererFactory;
		}
		
		public function set singleItemRendererFactory(value:Function) : void {
			if(this._singleItemRendererFactory === value) {
				return;
			}
			this._singleItemRendererFactory = value;
			this.invalidate("itemRendererFactory");
		}
		
		public function get customSingleItemRendererStyleName() : String {
			return this._customSingleItemRendererStyleName;
		}
		
		public function set customSingleItemRendererStyleName(value:String) : void {
			if(this._customSingleItemRendererStyleName == value) {
				return;
			}
			this._customSingleItemRendererStyleName = value;
			this.invalidate("itemRendererFactory");
		}
		
		public function get headerRendererType() : Class {
			return this._headerRendererType;
		}
		
		public function set headerRendererType(value:Class) : void {
			if(this._headerRendererType == value) {
				return;
			}
			this._headerRendererType = value;
			this.invalidate("itemRendererFactory");
		}
		
		public function get headerRendererFactory() : Function {
			return this._headerRendererFactory;
		}
		
		public function set headerRendererFactory(value:Function) : void {
			if(this._headerRendererFactory === value) {
				return;
			}
			this._headerRendererFactory = value;
			this.invalidate("itemRendererFactory");
		}
		
		public function get headerRendererFactories() : Object {
			return this._headerRendererFactories;
		}
		
		public function set headerRendererFactories(value:Object) : void {
			if(this._headerRendererFactories === value) {
				return;
			}
			this._headerRendererFactories = value;
			if(value !== null) {
				this._headerStorageMap = {};
			}
			this.invalidate("itemRendererFactory");
		}
		
		public function get headerFactoryIDFunction() : Function {
			return this._headerFactoryIDFunction;
		}
		
		public function set headerFactoryIDFunction(value:Function) : void {
			if(this._headerFactoryIDFunction === value) {
				return;
			}
			this._headerFactoryIDFunction = value;
			this.invalidate("itemRendererFactory");
		}
		
		public function get customHeaderRendererStyleName() : String {
			return this._customHeaderRendererStyleName;
		}
		
		public function set customHeaderRendererStyleName(value:String) : void {
			if(this._customHeaderRendererStyleName == value) {
				return;
			}
			this._customHeaderRendererStyleName = value;
			this.invalidate("itemRendererFactory");
		}
		
		public function get headerRendererProperties() : PropertyProxy {
			return this._headerRendererProperties;
		}
		
		public function set headerRendererProperties(value:PropertyProxy) : void {
			if(this._headerRendererProperties == value) {
				return;
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
			this.invalidate("itemRendererFactory");
		}
		
		public function get footerRendererFactory() : Function {
			return this._footerRendererFactory;
		}
		
		public function set footerRendererFactory(value:Function) : void {
			if(this._footerRendererFactory === value) {
				return;
			}
			this._footerRendererFactory = value;
			this.invalidate("itemRendererFactory");
		}
		
		public function get footerRendererFactories() : Object {
			return this._footerRendererFactories;
		}
		
		public function set footerRendererFactories(value:Object) : void {
			if(this._footerRendererFactories === value) {
				return;
			}
			this._footerRendererFactories = value;
			if(value !== null) {
				this._footerStorageMap = {};
			}
			this.invalidate("itemRendererFactory");
		}
		
		public function get footerFactoryIDFunction() : Function {
			return this._footerFactoryIDFunction;
		}
		
		public function set footerFactoryIDFunction(value:Function) : void {
			if(this._footerFactoryIDFunction === value) {
				return;
			}
			this._footerFactoryIDFunction = value;
			this.invalidate("itemRendererFactory");
		}
		
		public function get customFooterRendererStyleName() : String {
			return this._customFooterRendererStyleName;
		}
		
		public function set customFooterRendererStyleName(value:String) : void {
			if(this._customFooterRendererStyleName == value) {
				return;
			}
			this._customFooterRendererStyleName = value;
			this.invalidate("itemRendererFactory");
		}
		
		public function get footerRendererProperties() : PropertyProxy {
			return this._footerRendererProperties;
		}
		
		public function set footerRendererProperties(value:PropertyProxy) : void {
			if(this._footerRendererProperties == value) {
				return;
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
		
		public function get layout() : ILayout {
			return this._layout;
		}
		
		public function set layout(value:ILayout) : void {
			var _local2:IVariableVirtualLayout = null;
			if(this._layout == value) {
				return;
			}
			if(this._layout) {
				this._layout.removeEventListener("change",layout_changeHandler);
			}
			this._layout = value;
			if(this._layout) {
				if(this._layout is IVariableVirtualLayout) {
					_local2 = IVariableVirtualLayout(this._layout);
					_local2.hasVariableItemDimensions = true;
					_local2.resetVariableVirtualCache();
				}
				this._layout.addEventListener("change",layout_changeHandler);
			}
			this.invalidate("layout");
		}
		
		public function get horizontalScrollPosition() : Number {
			return this._horizontalScrollPosition;
		}
		
		public function set horizontalScrollPosition(value:Number) : void {
			if(this._horizontalScrollPosition == value) {
				return;
			}
			this._horizontalScrollPosition = value;
			this.invalidate("scroll");
		}
		
		public function get verticalScrollPosition() : Number {
			return this._verticalScrollPosition;
		}
		
		public function set verticalScrollPosition(value:Number) : void {
			if(this._verticalScrollPosition == value) {
				return;
			}
			this._verticalScrollPosition = value;
			this.invalidate("scroll");
		}
		
		public function get requiresMeasurementOnScroll() : Boolean {
			return this._layout.requiresLayoutOnScroll && (this._explicitVisibleWidth !== this._explicitVisibleWidth || this._explicitVisibleHeight !== this._explicitVisibleHeight);
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
		
		public function getScrollPositionForIndex(groupIndex:int, itemIndex:int, result:Point = null) : Point {
			if(!result) {
				result = new Point();
			}
			var _local4:int = this.locationToDisplayIndex(groupIndex,itemIndex);
			return this._layout.getScrollPositionForIndex(_local4,this._layoutItems,0,0,this._actualVisibleWidth,this._actualVisibleHeight,result);
		}
		
		public function getNearestScrollPositionForIndex(groupIndex:int, itemIndex:int, result:Point = null) : Point {
			if(!result) {
				result = new Point();
			}
			var _local4:int = this.locationToDisplayIndex(groupIndex,itemIndex);
			return this._layout.getNearestScrollPositionForIndex(_local4,this._horizontalScrollPosition,this._verticalScrollPosition,this._layoutItems,0,0,this._actualVisibleWidth,this._actualVisibleHeight,result);
		}
		
		public function itemToItemRenderer(item:Object) : IGroupedListItemRenderer {
			return IGroupedListItemRenderer(this._itemRendererMap[item]);
		}
		
		public function headerDataToHeaderRenderer(headerData:Object) : IGroupedListHeaderRenderer {
			return IGroupedListHeaderRenderer(this._headerRendererMap[headerData]);
		}
		
		public function footerDataToFooterRenderer(footerData:Object) : IGroupedListFooterRenderer {
			return IGroupedListFooterRenderer(this._footerRendererMap[footerData]);
		}
		
		override public function dispose() : void {
			this.refreshInactiveRenderers(true);
			this.owner = null;
			this.dataProvider = null;
			this.layout = null;
			super.dispose();
		}
		
		override protected function draw() : void {
			var _local12:Boolean = false;
			var _local7:Boolean = this.isInvalid("data");
			var _local10:Boolean = this.isInvalid("scroll");
			var _local1:Boolean = this.isInvalid("size");
			var _local5:Boolean = this.isInvalid("selected");
			var _local2:Boolean = this.isInvalid("itemRendererFactory");
			var _local8:Boolean = this.isInvalid("styles");
			var _local4:Boolean = this.isInvalid("state");
			var _local3:Boolean = this.isInvalid("layout");
			if(!_local3 && _local10 && this._layout && this._layout.requiresLayoutOnScroll) {
				_local3 = true;
			}
			var _local6:Boolean = _local1 || _local7 || _local3 || _local2;
			var _local9:Boolean = this._ignoreRendererResizing;
			this._ignoreRendererResizing = true;
			var _local11:Boolean = this._ignoreLayoutChanges;
			this._ignoreLayoutChanges = true;
			if(_local10 || _local1) {
				this.refreshViewPortBounds();
			}
			if(_local6) {
				this.refreshInactiveRenderers(_local2);
			}
			if(_local7 || _local3 || _local2) {
				this.refreshLayoutTypicalItem();
			}
			if(_local6) {
				this.refreshRenderers();
			}
			if(_local8 || _local6) {
				this.refreshHeaderRendererStyles();
				this.refreshFooterRendererStyles();
				this.refreshItemRendererStyles();
			}
			if(_local5 || _local6) {
				_local12 = this._ignoreSelectionChanges;
				this._ignoreSelectionChanges = true;
				this.refreshSelection();
				this._ignoreSelectionChanges = _local12;
			}
			if(_local4 || _local6) {
				this.refreshEnabled();
			}
			this._ignoreLayoutChanges = _local11;
			if(_local4 || _local5 || _local8 || _local6) {
				this._layout.layout(this._layoutItems,this._viewPortBounds,this._layoutResult);
			}
			this._ignoreRendererResizing = _local9;
			this._contentX = this._layoutResult.contentX;
			this._contentY = this._layoutResult.contentY;
			this.saveMeasurements(this._layoutResult.contentWidth,this._layoutResult.contentHeight,this._layoutResult.contentWidth,this._layoutResult.contentHeight);
			this._actualVisibleWidth = this._layoutResult.viewPortWidth;
			this._actualVisibleHeight = this._layoutResult.viewPortHeight;
			this._actualMinVisibleWidth = this._layoutResult.viewPortWidth;
			this._actualMinVisibleHeight = this._layoutResult.viewPortHeight;
			this.validateRenderers();
		}
		
		private function validateRenderers() : void {
			var _local2:int = 0;
			var _local1:IValidating = null;
			var _local3:int = int(this._layoutItems.length);
			_local2 = 0;
			while(_local2 < _local3) {
				_local1 = this._layoutItems[_local2] as IValidating;
				if(_local1) {
					_local1.validate();
				}
				_local2++;
			}
		}
		
		private function refreshEnabled() : void {
			var _local2:IFeathersControl = null;
			for each(var _local1 in this._layoutItems) {
				_local2 = _local1 as IFeathersControl;
				if(_local2) {
					_local2.isEnabled = this._isEnabled;
				}
			}
		}
		
		private function invalidateParent(flag:String = "all") : void {
			Scroller(this.parent).invalidate(flag);
		}
		
		private function refreshLayoutTypicalItem() : void {
			var _local8:int = 0;
			var _local11:IGroupedListItemRenderer = null;
			var _local9:* = false;
			var _local6:String = null;
			var _local10:IVirtualLayout = this._layout as IVirtualLayout;
			if(!_local10 || !_local10.useVirtualLayout) {
				if(!this._typicalItemIsInDataProvider && this._typicalItemRenderer) {
					this.destroyItemRenderer(this._typicalItemRenderer);
					this._typicalItemRenderer = null;
				}
				return;
			}
			var _local7:Boolean = false;
			var _local3:Object = this._typicalItem;
			var _local4:int = 0;
			var _local1:int = 0;
			var _local5:* = 0;
			var _local2:int = 0;
			if(this._dataProvider) {
				if(_local3 !== null) {
					this._dataProvider.getItemLocation(_local3,HELPER_VECTOR);
					if(HELPER_VECTOR.length > 1) {
						_local7 = true;
						_local5 = HELPER_VECTOR[0];
						_local2 = HELPER_VECTOR[1];
					}
				} else {
					_local4 = this._dataProvider.getLength();
					if(_local4 > 0) {
						_local8 = 0;
						while(_local8 < _local4) {
							_local1 = this._dataProvider.getLength(_local8);
							if(_local1 > 0) {
								_local7 = true;
								_local5 = _local8;
								_local3 = this._dataProvider.getItemAt(_local8,0);
								break;
							}
							_local8++;
						}
					}
				}
			}
			if(_local3 !== null) {
				_local11 = IGroupedListItemRenderer(this._itemRendererMap[_local3]);
				if(_local11) {
					_local11.groupIndex = _local5;
					_local11.itemIndex = _local2;
				}
				if(!_local11 && this._typicalItemRenderer) {
					_local9 = !this._typicalItemIsInDataProvider;
					if(_local9) {
						_local6 = this.getFactoryID(_local3,_local5,_local2);
						if(this._typicalItemRenderer.factoryID !== _local6) {
							_local9 = false;
						}
					}
					if(_local9) {
						_local11 = this._typicalItemRenderer;
						_local11.data = _local3;
						_local11.groupIndex = _local5;
						_local11.itemIndex = _local2;
					}
				}
				if(!_local11) {
					_local11 = this.createItemRenderer(_local3,0,0,0,false,!_local7);
					if(!this._typicalItemIsInDataProvider && this._typicalItemRenderer) {
						this.destroyItemRenderer(this._typicalItemRenderer);
						this._typicalItemRenderer = null;
					}
				}
			}
			_local10.typicalItem = DisplayObject(_local11);
			this._typicalItemRenderer = _local11;
			this._typicalItemIsInDataProvider = _local7;
			if(this._typicalItemRenderer && !this._typicalItemIsInDataProvider) {
				this._typicalItemRenderer.addEventListener("resize",itemRenderer_resizeHandler);
			}
		}
		
		private function refreshItemRendererStyles() : void {
			var _local1:IGroupedListItemRenderer = null;
			for each(var _local2 in this._layoutItems) {
				_local1 = _local2 as IGroupedListItemRenderer;
				if(_local1) {
					this.refreshOneItemRendererStyles(_local1);
				}
			}
		}
		
		private function refreshHeaderRendererStyles() : void {
			var _local2:IGroupedListHeaderRenderer = null;
			for each(var _local1 in this._layoutItems) {
				_local2 = _local1 as IGroupedListHeaderRenderer;
				if(_local2) {
					this.refreshOneHeaderRendererStyles(_local2);
				}
			}
		}
		
		private function refreshFooterRendererStyles() : void {
			var _local2:IGroupedListFooterRenderer = null;
			for each(var _local1 in this._layoutItems) {
				_local2 = _local1 as IGroupedListFooterRenderer;
				if(_local2) {
					this.refreshOneFooterRendererStyles(_local2);
				}
			}
		}
		
		private function refreshOneItemRendererStyles(renderer:IGroupedListItemRenderer) : void {
			var _local4:Object = null;
			var _local2:DisplayObject = DisplayObject(renderer);
			for(var _local3 in this._itemRendererProperties) {
				_local4 = this._itemRendererProperties[_local3];
				_local2[_local3] = _local4;
			}
		}
		
		private function refreshOneHeaderRendererStyles(renderer:IGroupedListHeaderRenderer) : void {
			var _local4:Object = null;
			var _local2:DisplayObject = DisplayObject(renderer);
			for(var _local3 in this._headerRendererProperties) {
				_local4 = this._headerRendererProperties[_local3];
				_local2[_local3] = _local4;
			}
		}
		
		private function refreshOneFooterRendererStyles(renderer:IGroupedListFooterRenderer) : void {
			var _local4:Object = null;
			var _local2:DisplayObject = DisplayObject(renderer);
			for(var _local3 in this._footerRendererProperties) {
				_local4 = this._footerRendererProperties[_local3];
				_local2[_local3] = _local4;
			}
		}
		
		private function refreshSelection() : void {
			var _local1:IGroupedListItemRenderer = null;
			for each(var _local2 in this._layoutItems) {
				_local1 = _local2 as IGroupedListItemRenderer;
				if(_local1) {
					_local1.isSelected = _local1.groupIndex == this._selectedGroupIndex && _local1.itemIndex == this._selectedItemIndex;
				}
			}
		}
		
		private function refreshViewPortBounds() : void {
			var _local1:* = this._explicitMinVisibleWidth !== this._explicitMinVisibleWidth;
			var _local2:* = this._explicitMinVisibleHeight !== this._explicitMinVisibleHeight;
			this._viewPortBounds.x = 0;
			this._viewPortBounds.y = 0;
			this._viewPortBounds.scrollX = this._horizontalScrollPosition;
			this._viewPortBounds.scrollY = this._verticalScrollPosition;
			this._viewPortBounds.explicitWidth = this._explicitVisibleWidth;
			this._viewPortBounds.explicitHeight = this._explicitVisibleHeight;
			if(_local1) {
				this._viewPortBounds.minWidth = 0;
			} else {
				this._viewPortBounds.minWidth = this._explicitMinVisibleWidth;
			}
			if(_local2) {
				this._viewPortBounds.minHeight = 0;
			} else {
				this._viewPortBounds.minHeight = this._explicitMinVisibleHeight;
			}
			this._viewPortBounds.maxWidth = this._maxVisibleWidth;
			this._viewPortBounds.maxHeight = this._maxVisibleHeight;
		}
		
		private function refreshInactiveRenderers(itemRendererTypeIsInvalid:Boolean) : void {
			var _local2:ItemRendererFactoryStorage = null;
			var _local4:HeaderRendererFactoryStorage = null;
			var _local5:FooterRendererFactoryStorage = null;
			this.refreshInactiveItemRenderers(this._defaultItemRendererStorage,itemRendererTypeIsInvalid);
			for(var _local3 in this._itemStorageMap) {
				_local2 = ItemRendererFactoryStorage(this._itemStorageMap[_local3]);
				this.refreshInactiveItemRenderers(_local2,itemRendererTypeIsInvalid);
			}
			this.refreshInactiveHeaderRenderers(this._defaultHeaderRendererStorage,itemRendererTypeIsInvalid);
			for(_local3 in this._headerStorageMap) {
				_local4 = HeaderRendererFactoryStorage(this._headerStorageMap[_local3]);
				this.refreshInactiveHeaderRenderers(_local4,itemRendererTypeIsInvalid);
			}
			this.refreshInactiveFooterRenderers(this._defaultFooterRendererStorage,itemRendererTypeIsInvalid);
			for(_local3 in this._footerStorageMap) {
				_local5 = FooterRendererFactoryStorage(this._footerStorageMap[_local3]);
				this.refreshInactiveFooterRenderers(_local5,itemRendererTypeIsInvalid);
			}
			if(itemRendererTypeIsInvalid && this._typicalItemRenderer) {
				if(this._typicalItemIsInDataProvider) {
					delete this._itemRendererMap[this._typicalItemRenderer.data];
				}
				this.destroyItemRenderer(this._typicalItemRenderer);
				this._typicalItemRenderer = null;
				this._typicalItemIsInDataProvider = false;
			}
			this._headerIndices.length = 0;
			this._footerIndices.length = 0;
		}
		
		private function refreshInactiveItemRenderers(storage:ItemRendererFactoryStorage, itemRendererTypeIsInvalid:Boolean) : void {
			var _local3:Vector.<IGroupedListItemRenderer> = storage.inactiveItemRenderers;
			storage.inactiveItemRenderers = storage.activeItemRenderers;
			storage.activeItemRenderers = _local3;
			if(storage.activeItemRenderers.length > 0) {
				throw new IllegalOperationError("GroupedListDataViewPort: active item renderers should be empty.");
			}
			if(itemRendererTypeIsInvalid) {
				this.recoverInactiveItemRenderers(storage);
				this.freeInactiveItemRenderers(storage,0);
			}
		}
		
		private function refreshInactiveHeaderRenderers(storage:HeaderRendererFactoryStorage, itemRendererTypeIsInvalid:Boolean) : void {
			var _local3:Vector.<IGroupedListHeaderRenderer> = storage.inactiveHeaderRenderers;
			storage.inactiveHeaderRenderers = storage.activeHeaderRenderers;
			storage.activeHeaderRenderers = _local3;
			if(storage.activeHeaderRenderers.length > 0) {
				throw new IllegalOperationError("GroupedListDataViewPort: active header renderers should be empty.");
			}
			if(itemRendererTypeIsInvalid) {
				this.recoverInactiveHeaderRenderers(storage);
				this.freeInactiveHeaderRenderers(storage,0);
			}
		}
		
		private function refreshInactiveFooterRenderers(storage:FooterRendererFactoryStorage, itemRendererTypeIsInvalid:Boolean) : void {
			var _local3:Vector.<IGroupedListFooterRenderer> = storage.inactiveFooterRenderers;
			storage.inactiveFooterRenderers = storage.activeFooterRenderers;
			storage.activeFooterRenderers = _local3;
			if(storage.activeFooterRenderers.length > 0) {
				throw new IllegalOperationError("GroupedListDataViewPort: active footer renderers should be empty.");
			}
			if(itemRendererTypeIsInvalid) {
				this.recoverInactiveFooterRenderers(storage);
				this.freeInactiveFooterRenderers(storage,0);
			}
		}
		
		private function refreshRenderers() : void {
			var _local1:ItemRendererFactoryStorage = null;
			var _local2:* = undefined;
			var _local6:* = undefined;
			var _local5:int = 0;
			var _local4:int = 0;
			var _local7:HeaderRendererFactoryStorage = null;
			var _local8:FooterRendererFactoryStorage = null;
			if(this._typicalItemRenderer) {
				if(this._typicalItemIsInDataProvider) {
					_local1 = this.factoryIDToStorage(this._typicalItemRenderer.factoryID,this._typicalItemRenderer.groupIndex,this._typicalItemRenderer.itemIndex);
					_local2 = _local1.inactiveItemRenderers;
					_local6 = _local1.activeItemRenderers;
					_local5 = int(_local2.indexOf(this._typicalItemRenderer));
					if(_local5 >= 0) {
						_local2.removeAt(_local5);
					}
					_local4 = int(_local6.length);
					if(_local4 == 0) {
						_local6[_local4] = this._typicalItemRenderer;
					}
				}
				this.refreshOneItemRendererStyles(this._typicalItemRenderer);
			}
			this.findUnrenderedData();
			this.recoverInactiveItemRenderers(this._defaultItemRendererStorage);
			if(this._itemStorageMap) {
				for(var _local3 in this._itemStorageMap) {
					_local1 = ItemRendererFactoryStorage(this._itemStorageMap[_local3]);
					this.recoverInactiveItemRenderers(_local1);
				}
			}
			this.recoverInactiveHeaderRenderers(this._defaultHeaderRendererStorage);
			if(this._headerStorageMap) {
				for(_local3 in this._headerStorageMap) {
					_local7 = HeaderRendererFactoryStorage(this._headerStorageMap[_local3]);
					this.recoverInactiveHeaderRenderers(_local7);
				}
			}
			this.recoverInactiveFooterRenderers(this._defaultFooterRendererStorage);
			if(this._footerStorageMap) {
				for(_local3 in this._footerStorageMap) {
					_local8 = FooterRendererFactoryStorage(this._footerStorageMap[_local3]);
					this.recoverInactiveFooterRenderers(_local8);
				}
			}
			this.renderUnrenderedData();
			this.freeInactiveItemRenderers(this._defaultItemRendererStorage,this._minimumItemCount);
			if(this._itemStorageMap) {
				for(_local3 in this._itemStorageMap) {
					_local1 = ItemRendererFactoryStorage(this._itemStorageMap[_local3]);
					this.freeInactiveItemRenderers(_local1,1);
				}
			}
			this.freeInactiveHeaderRenderers(this._defaultHeaderRendererStorage,this._minimumHeaderCount);
			if(this._headerStorageMap) {
				for(_local3 in this._headerStorageMap) {
					_local7 = HeaderRendererFactoryStorage(this._headerStorageMap[_local3]);
					this.freeInactiveHeaderRenderers(_local7,1);
				}
			}
			this.freeInactiveFooterRenderers(this._defaultFooterRendererStorage,this._minimumFooterCount);
			if(this._footerStorageMap) {
				for(_local3 in this._footerStorageMap) {
					_local8 = FooterRendererFactoryStorage(this._footerStorageMap[_local3]);
					this.freeInactiveFooterRenderers(_local8,1);
				}
			}
			this._updateForDataReset = false;
		}
		
		private function findUnrenderedData() : void {
			var _local4:int = 0;
			var _local21:Object = null;
			var _local13:int = 0;
			var _local14:Number = NaN;
			var _local20:Number = NaN;
			var _local8:Number = NaN;
			var _local15:* = NaN;
			var _local17:Object = null;
			var _local6:int = 0;
			var _local1:Object = null;
			var _local3:Object = null;
			var _local5:int = 0;
			var _local11:int = int(!!this._dataProvider ? this._dataProvider.getLength() : 0);
			var _local12:int = 0;
			var _local19:int = 0;
			var _local16:int = 0;
			var _local2:int = 0;
			var _local7:int = 0;
			_local4 = 0;
			while(_local4 < _local11) {
				_local21 = this._dataProvider.getItemAt(_local4);
				if(this._owner.groupToHeaderData(_local21) !== null) {
					this._headerIndices[_local19] = _local12;
					_local12++;
					_local19++;
				}
				_local13 = this._dataProvider.getLength(_local4);
				_local12 += _local13;
				_local7 += _local13;
				if(_local13 == 0) {
					_local2++;
				}
				if(this._owner.groupToFooterData(_local21) !== null) {
					this._footerIndices[_local16] = _local12;
					_local12++;
					_local16++;
				}
				_local4++;
			}
			this._layoutItems.length = _local12;
			if(this._layout is IGroupedLayout) {
				IGroupedLayout(this._layout).headerIndices = this._headerIndices;
			}
			var _local10:IVirtualLayout = this._layout as IVirtualLayout;
			var _local18:Boolean = _local10 && _local10.useVirtualLayout;
			if(_local18) {
				_local10.measureViewPort(_local12,this._viewPortBounds,HELPER_POINT);
				_local14 = HELPER_POINT.x;
				_local20 = HELPER_POINT.y;
				_local10.getVisibleIndicesAtScrollPosition(this._horizontalScrollPosition,this._verticalScrollPosition,_local14,_local20,_local12,HELPER_VECTOR);
				_local7 /= _local11;
				if(this._typicalItemRenderer) {
					_local8 = Number(this._typicalItemRenderer.height);
					if(this._typicalItemRenderer.width < _local8) {
						_local8 = Number(this._typicalItemRenderer.width);
					}
					_local15 = _local14;
					if(_local20 > _local14) {
						_local15 = _local20;
					}
					this._minimumFirstAndLastItemCount = this._minimumSingleItemCount = this._minimumHeaderCount = this._minimumFooterCount = Math.ceil(_local15 / (_local8 * _local7));
					this._minimumHeaderCount = Math.min(this._minimumHeaderCount,_local19);
					this._minimumFooterCount = Math.min(this._minimumFooterCount,_local16);
					this._minimumSingleItemCount = Math.min(this._minimumSingleItemCount,_local2);
					this._minimumItemCount = Math.ceil(_local15 / _local8) + 1;
				} else {
					this._minimumFirstAndLastItemCount = 1;
					this._minimumHeaderCount = 1;
					this._minimumFooterCount = 1;
					this._minimumSingleItemCount = 1;
					this._minimumItemCount = 1;
				}
			}
			var _local9:int = 0;
			_local4 = 0;
			while(_local4 < _local11) {
				_local21 = this._dataProvider.getItemAt(_local4);
				_local17 = this._owner.groupToHeaderData(_local21);
				if(_local17 !== null) {
					if(_local18 && HELPER_VECTOR.indexOf(_local9) < 0) {
						this._layoutItems[_local9] = null;
					} else {
						this.findRendererForHeader(_local17,_local4,_local9);
					}
					_local9++;
				}
				_local13 = this._dataProvider.getLength(_local4);
				_local6 = 0;
				while(_local6 < _local13) {
					if(_local18 && HELPER_VECTOR.indexOf(_local9) < 0) {
						if(this._typicalItemRenderer && this._typicalItemIsInDataProvider && this._typicalItemRenderer.groupIndex === _local4 && this._typicalItemRenderer.itemIndex === _local6) {
							this._typicalItemRenderer.layoutIndex = _local9;
						}
						this._layoutItems[_local9] = null;
					} else {
						_local1 = this._dataProvider.getItemAt(_local4,_local6);
						this.findRendererForItem(_local1,_local4,_local6,_local9);
					}
					_local9++;
					_local6++;
				}
				_local3 = this._owner.groupToFooterData(_local21);
				if(_local3 !== null) {
					if(_local18 && HELPER_VECTOR.indexOf(_local9) < 0) {
						this._layoutItems[_local9] = null;
					} else {
						this.findRendererForFooter(_local3,_local4,_local9);
					}
					_local9++;
				}
				_local4++;
			}
			if(this._typicalItemRenderer) {
				if(_local18 && this._typicalItemIsInDataProvider) {
					_local5 = int(HELPER_VECTOR.indexOf(this._typicalItemRenderer.layoutIndex));
					if(_local5 >= 0) {
						this._typicalItemRenderer.visible = true;
					} else {
						this._typicalItemRenderer.visible = false;
					}
				} else {
					this._typicalItemRenderer.visible = this._typicalItemIsInDataProvider;
				}
			}
			HELPER_VECTOR.length = 0;
		}
		
		private function findRendererForItem(item:Object, groupIndex:int, itemIndex:int, layoutIndex:int) : void {
			var _local9:ItemRendererFactoryStorage = null;
			var _local8:* = undefined;
			var _local6:* = undefined;
			var _local7:int = 0;
			var _local10:int = 0;
			var _local5:IGroupedListItemRenderer = IGroupedListItemRenderer(this._itemRendererMap[item]);
			if(_local5) {
				_local5.groupIndex = groupIndex;
				_local5.itemIndex = itemIndex;
				_local5.layoutIndex = layoutIndex;
				if(this._updateForDataReset) {
					_local5.data = null;
					_local5.data = item;
				}
				if(this._typicalItemRenderer != _local5) {
					_local9 = this.factoryIDToStorage(_local5.factoryID,_local5.groupIndex,_local5.itemIndex);
					_local8 = _local9.activeItemRenderers;
					_local6 = _local9.inactiveItemRenderers;
					_local8[_local8.length] = _local5;
					_local7 = int(_local6.indexOf(_local5));
					if(_local7 < 0) {
						throw new IllegalOperationError("GroupedListDataViewPort: renderer map contains bad data. This may be caused by duplicate items in the data provider, which is not allowed.");
					}
					_local6.removeAt(_local7);
				}
				_local5.visible = true;
				this._layoutItems[layoutIndex] = DisplayObject(_local5);
			} else {
				_local10 = int(this._unrenderedItems.length);
				this._unrenderedItems[_local10] = groupIndex;
				_local10++;
				this._unrenderedItems[_local10] = itemIndex;
				_local10++;
				this._unrenderedItems[_local10] = layoutIndex;
			}
		}
		
		private function findRendererForHeader(header:Object, groupIndex:int, layoutIndex:int) : void {
			var _local4:HeaderRendererFactoryStorage = null;
			var _local5:* = undefined;
			var _local6:* = undefined;
			var _local7:int = 0;
			var _local8:IGroupedListHeaderRenderer = IGroupedListHeaderRenderer(this._headerRendererMap[header]);
			if(_local8) {
				_local8.groupIndex = groupIndex;
				_local8.layoutIndex = layoutIndex;
				if(this._updateForDataReset) {
					_local8.data = null;
					_local8.data = header;
				}
				_local4 = this.headerFactoryIDToStorage(_local8.factoryID);
				_local5 = _local4.activeHeaderRenderers;
				_local6 = _local4.inactiveHeaderRenderers;
				_local5[_local5.length] = _local8;
				_local6.removeAt(_local6.indexOf(_local8));
				_local8.visible = true;
				this._layoutItems[layoutIndex] = DisplayObject(_local8);
			} else {
				_local7 = int(this._unrenderedHeaders.length);
				this._unrenderedHeaders[_local7] = groupIndex;
				_local7++;
				this._unrenderedHeaders[_local7] = layoutIndex;
			}
		}
		
		private function findRendererForFooter(footer:Object, groupIndex:int, layoutIndex:int) : void {
			var _local7:FooterRendererFactoryStorage = null;
			var _local5:* = undefined;
			var _local4:* = undefined;
			var _local8:int = 0;
			var _local6:IGroupedListFooterRenderer = IGroupedListFooterRenderer(this._footerRendererMap[footer]);
			if(_local6) {
				_local6.groupIndex = groupIndex;
				_local6.layoutIndex = layoutIndex;
				if(this._updateForDataReset) {
					_local6.data = null;
					_local6.data = footer;
				}
				_local7 = this.footerFactoryIDToStorage(_local6.factoryID);
				_local5 = _local7.activeFooterRenderers;
				_local4 = _local7.inactiveFooterRenderers;
				_local5[_local5.length] = _local6;
				_local4.removeAt(_local4.indexOf(_local6));
				_local6.visible = true;
				this._layoutItems[layoutIndex] = DisplayObject(_local6);
			} else {
				_local8 = int(this._unrenderedFooters.length);
				this._unrenderedFooters[_local8] = groupIndex;
				_local8++;
				this._unrenderedFooters[_local8] = layoutIndex;
			}
		}
		
		private function renderUnrenderedData() : void {
			var _local6:int = 0;
			var _local8:int = 0;
			var _local5:int = 0;
			var _local4:int = 0;
			var _local3:Object = null;
			var _local2:IGroupedListItemRenderer = null;
			var _local9:IGroupedListHeaderRenderer = null;
			var _local7:IGroupedListFooterRenderer = null;
			var _local1:int = int(this._unrenderedItems.length);
			_local6 = 0;
			while(_local6 < _local1) {
				_local8 = int(this._unrenderedItems.shift());
				_local5 = int(this._unrenderedItems.shift());
				_local4 = int(this._unrenderedItems.shift());
				_local3 = this._dataProvider.getItemAt(_local8,_local5);
				_local2 = this.createItemRenderer(_local3,_local8,_local5,_local4,true,false);
				this._layoutItems[_local4] = DisplayObject(_local2);
				_local6 += 3;
			}
			_local1 = int(this._unrenderedHeaders.length);
			_local6 = 0;
			while(_local6 < _local1) {
				_local8 = int(this._unrenderedHeaders.shift());
				_local4 = int(this._unrenderedHeaders.shift());
				_local3 = this._dataProvider.getItemAt(_local8);
				_local3 = this._owner.groupToHeaderData(_local3);
				_local9 = this.createHeaderRenderer(_local3,_local8,_local4,false);
				this._layoutItems[_local4] = DisplayObject(_local9);
				_local6 += 2;
			}
			_local1 = int(this._unrenderedFooters.length);
			_local6 = 0;
			while(_local6 < _local1) {
				_local8 = int(this._unrenderedFooters.shift());
				_local4 = int(this._unrenderedFooters.shift());
				_local3 = this._dataProvider.getItemAt(_local8);
				_local3 = this._owner.groupToFooterData(_local3);
				_local7 = this.createFooterRenderer(_local3,_local8,_local4,false);
				this._layoutItems[_local4] = DisplayObject(_local7);
				_local6 += 2;
			}
		}
		
		private function recoverInactiveItemRenderers(storage:ItemRendererFactoryStorage) : void {
			var _local5:int = 0;
			var _local3:IGroupedListItemRenderer = null;
			var _local4:Vector.<IGroupedListItemRenderer> = storage.inactiveItemRenderers;
			var _local2:int = int(_local4.length);
			_local5 = 0;
			while(_local5 < _local2) {
				_local3 = _local4[_local5];
				if(!(!_local3 || _local3.groupIndex < 0)) {
					this._owner.dispatchEventWith("rendererRemove",false,_local3);
					delete this._itemRendererMap[_local3.data];
				}
				_local5++;
			}
		}
		
		private function recoverInactiveHeaderRenderers(storage:HeaderRendererFactoryStorage) : void {
			var _local3:int = 0;
			var _local5:IGroupedListHeaderRenderer = null;
			var _local4:Vector.<IGroupedListHeaderRenderer> = storage.inactiveHeaderRenderers;
			var _local2:int = int(_local4.length);
			_local3 = 0;
			while(_local3 < _local2) {
				_local5 = _local4[_local3];
				if(_local5) {
					this._owner.dispatchEventWith("rendererRemove",false,_local5);
					delete this._headerRendererMap[_local5.data];
				}
				_local3++;
			}
		}
		
		private function recoverInactiveFooterRenderers(storage:FooterRendererFactoryStorage) : void {
			var _local4:int = 0;
			var _local5:IGroupedListFooterRenderer = null;
			var _local2:Vector.<IGroupedListFooterRenderer> = storage.inactiveFooterRenderers;
			var _local3:int = int(_local2.length);
			_local4 = 0;
			while(_local4 < _local3) {
				_local5 = _local2[_local4];
				if(_local5) {
					this._owner.dispatchEventWith("rendererRemove",false,_local5);
					delete this._footerRendererMap[_local5.data];
				}
				_local4++;
			}
		}
		
		private function freeInactiveItemRenderers(storage:ItemRendererFactoryStorage, minimumItemCount:int) : void {
			var _local9:int = 0;
			var _local3:IGroupedListItemRenderer = null;
			var _local6:Vector.<IGroupedListItemRenderer> = storage.inactiveItemRenderers;
			var _local8:Vector.<IGroupedListItemRenderer> = storage.activeItemRenderers;
			var _local7:int = int(_local8.length);
			var _local5:int = minimumItemCount - _local7;
			if(_local5 > _local6.length) {
				_local5 = int(_local6.length);
			}
			_local9 = 0;
			while(_local9 < _local5) {
				_local3 = _local6.shift();
				_local3.data = null;
				_local3.groupIndex = -1;
				_local3.itemIndex = -1;
				_local3.layoutIndex = -1;
				_local3.visible = false;
				_local8[_local7] = _local3;
				_local7++;
				_local9++;
			}
			var _local4:int = int(_local6.length);
			_local9 = 0;
			while(_local9 < _local4) {
				_local3 = _local6.shift();
				if(_local3) {
					this.destroyItemRenderer(_local3);
				}
				_local9++;
			}
		}
		
		private function freeInactiveHeaderRenderers(storage:HeaderRendererFactoryStorage, minimumHeaderCount:int) : void {
			var _local4:int = 0;
			var _local9:IGroupedListHeaderRenderer = null;
			var _local7:Vector.<IGroupedListHeaderRenderer> = storage.inactiveHeaderRenderers;
			var _local6:Vector.<IGroupedListHeaderRenderer> = storage.activeHeaderRenderers;
			var _local5:int = int(_local6.length);
			var _local3:int = minimumHeaderCount - _local5;
			if(_local3 > _local7.length) {
				_local3 = int(_local7.length);
			}
			_local4 = 0;
			while(_local4 < _local3) {
				_local9 = _local7.shift();
				_local9.visible = false;
				_local9.data = null;
				_local9.groupIndex = -1;
				_local9.layoutIndex = -1;
				_local6[_local5] = _local9;
				_local5++;
				_local4++;
			}
			var _local8:int = int(_local7.length);
			_local4 = 0;
			while(_local4 < _local8) {
				_local9 = _local7.shift();
				if(_local9) {
					this.destroyHeaderRenderer(_local9);
				}
				_local4++;
			}
		}
		
		private function freeInactiveFooterRenderers(storage:FooterRendererFactoryStorage, minimumFooterCount:int) : void {
			var _local8:int = 0;
			var _local9:IGroupedListFooterRenderer = null;
			var _local3:Vector.<IGroupedListFooterRenderer> = storage.inactiveFooterRenderers;
			var _local4:Vector.<IGroupedListFooterRenderer> = storage.activeFooterRenderers;
			var _local6:int = int(_local4.length);
			var _local5:int = minimumFooterCount - _local6;
			if(_local5 > _local3.length) {
				_local5 = int(_local3.length);
			}
			_local8 = 0;
			while(_local8 < _local5) {
				_local9 = _local3.shift();
				_local9.visible = false;
				_local9.data = null;
				_local9.groupIndex = -1;
				_local9.layoutIndex = -1;
				_local4[_local6] = _local9;
				_local6++;
				_local8++;
			}
			var _local7:int = int(_local3.length);
			_local8 = 0;
			while(_local8 < _local7) {
				_local9 = _local3.shift();
				if(_local9) {
					this.destroyFooterRenderer(_local9);
				}
				_local8++;
			}
		}
		
		private function createItemRenderer(item:Object, groupIndex:int, itemIndex:int, layoutIndex:int, useCache:Boolean, isTemporary:Boolean) : IGroupedListItemRenderer {
			var _local7:IGroupedListItemRenderer = null;
			var _local13:Class = null;
			var _local11:IFeathersControl = null;
			var _local9:String = this.getFactoryID(item,groupIndex,itemIndex);
			var _local15:Function = this.factoryIDToFactory(_local9,groupIndex,itemIndex);
			var _local12:ItemRendererFactoryStorage = this.factoryIDToStorage(_local9,groupIndex,itemIndex);
			var _local8:String = this.indexToCustomStyleName(groupIndex,itemIndex);
			var _local14:Vector.<IGroupedListItemRenderer> = _local12.inactiveItemRenderers;
			var _local10:Vector.<IGroupedListItemRenderer> = _local12.activeItemRenderers;
			if(!useCache || isTemporary || _local14.length === 0) {
				if(_local15 !== null) {
					_local7 = IGroupedListItemRenderer(_local15());
				} else {
					_local13 = this.indexToItemRendererType(groupIndex,itemIndex);
					_local7 = IGroupedListItemRenderer(new _local13());
				}
				_local11 = IFeathersControl(_local7);
				if(_local8 && _local8.length > 0) {
					_local11.styleNameList.add(_local8);
				}
				this.addChild(DisplayObject(_local7));
			} else {
				_local7 = _local14.shift();
			}
			_local7.data = item;
			_local7.groupIndex = groupIndex;
			_local7.itemIndex = itemIndex;
			_local7.layoutIndex = layoutIndex;
			_local7.owner = this._owner;
			_local7.factoryID = _local9;
			_local7.visible = true;
			if(!isTemporary) {
				this._itemRendererMap[item] = _local7;
				_local10.push(_local7);
				_local7.addEventListener("triggered",renderer_triggeredHandler);
				_local7.addEventListener("change",renderer_changeHandler);
				_local7.addEventListener("resize",itemRenderer_resizeHandler);
				this._owner.dispatchEventWith("rendererAdd",false,_local7);
			}
			return _local7;
		}
		
		private function createHeaderRenderer(header:Object, groupIndex:int, layoutIndex:int, isTemporary:Boolean = false) : IGroupedListHeaderRenderer {
			var _local11:IGroupedListHeaderRenderer = null;
			var _local6:IFeathersControl = null;
			var _local5:String = null;
			if(this._headerFactoryIDFunction !== null) {
				if(this._headerFactoryIDFunction.length === 1) {
					_local5 = this._headerFactoryIDFunction(header);
				} else {
					_local5 = this._headerFactoryIDFunction(header,groupIndex);
				}
			}
			var _local10:Function = this.headerFactoryIDToFactory(_local5);
			var _local7:HeaderRendererFactoryStorage = this.headerFactoryIDToStorage(_local5);
			var _local9:Vector.<IGroupedListHeaderRenderer> = _local7.inactiveHeaderRenderers;
			var _local8:Vector.<IGroupedListHeaderRenderer> = _local7.activeHeaderRenderers;
			if(isTemporary || _local9.length === 0) {
				if(_local10 !== null) {
					_local11 = IGroupedListHeaderRenderer(_local10());
				} else {
					_local11 = IGroupedListHeaderRenderer(new this._headerRendererType());
				}
				_local6 = IFeathersControl(_local11);
				if(this._customHeaderRendererStyleName && this._customHeaderRendererStyleName.length > 0) {
					_local6.styleNameList.add(this._customHeaderRendererStyleName);
				}
				this.addChild(DisplayObject(_local11));
			} else {
				_local11 = _local9.shift();
			}
			_local11.data = header;
			_local11.groupIndex = groupIndex;
			_local11.layoutIndex = layoutIndex;
			_local11.owner = this._owner;
			_local11.factoryID = _local5;
			_local11.visible = true;
			if(!isTemporary) {
				this._headerRendererMap[header] = _local11;
				_local8.push(_local11);
				_local11.addEventListener("resize",headerRenderer_resizeHandler);
				this._owner.dispatchEventWith("rendererAdd",false,_local11);
			}
			return _local11;
		}
		
		private function createFooterRenderer(footer:Object, groupIndex:int, layoutIndex:int, isTemporary:Boolean = false) : IGroupedListFooterRenderer {
			var _local9:IGroupedListFooterRenderer = null;
			var _local10:IFeathersControl = null;
			var _local7:String = null;
			if(this._footerFactoryIDFunction !== null) {
				if(this._footerFactoryIDFunction.length === 1) {
					_local7 = this._footerFactoryIDFunction(footer);
				} else {
					_local7 = this._footerFactoryIDFunction(footer,groupIndex);
				}
			}
			var _local8:Function = this.footerFactoryIDToFactory(_local7);
			var _local11:FooterRendererFactoryStorage = this.footerFactoryIDToStorage(_local7);
			var _local5:Vector.<IGroupedListFooterRenderer> = _local11.inactiveFooterRenderers;
			var _local6:Vector.<IGroupedListFooterRenderer> = _local11.activeFooterRenderers;
			if(isTemporary || _local5.length === 0) {
				if(_local8 !== null) {
					_local9 = IGroupedListFooterRenderer(_local8());
				} else {
					_local9 = IGroupedListFooterRenderer(new this._footerRendererType());
				}
				_local10 = IFeathersControl(_local9);
				if(this._customFooterRendererStyleName && this._customFooterRendererStyleName.length > 0) {
					_local10.styleNameList.add(this._customFooterRendererStyleName);
				}
				this.addChild(DisplayObject(_local9));
			} else {
				_local9 = _local5.shift();
			}
			_local9.data = footer;
			_local9.groupIndex = groupIndex;
			_local9.layoutIndex = layoutIndex;
			_local9.owner = this._owner;
			_local9.factoryID = _local7;
			_local9.visible = true;
			if(!isTemporary) {
				this._footerRendererMap[footer] = _local9;
				_local6[_local6.length] = _local9;
				_local9.addEventListener("resize",footerRenderer_resizeHandler);
				this._owner.dispatchEventWith("rendererAdd",false,_local9);
			}
			return _local9;
		}
		
		private function destroyItemRenderer(renderer:IGroupedListItemRenderer) : void {
			renderer.removeEventListener("triggered",renderer_triggeredHandler);
			renderer.removeEventListener("change",renderer_changeHandler);
			renderer.removeEventListener("resize",itemRenderer_resizeHandler);
			renderer.owner = null;
			renderer.data = null;
			this.removeChild(DisplayObject(renderer),true);
		}
		
		private function destroyHeaderRenderer(renderer:IGroupedListHeaderRenderer) : void {
			renderer.removeEventListener("resize",headerRenderer_resizeHandler);
			renderer.owner = null;
			renderer.data = null;
			this.removeChild(DisplayObject(renderer),true);
		}
		
		private function destroyFooterRenderer(renderer:IGroupedListFooterRenderer) : void {
			renderer.removeEventListener("resize",footerRenderer_resizeHandler);
			renderer.owner = null;
			renderer.data = null;
			this.removeChild(DisplayObject(renderer),true);
		}
		
		private function groupToHeaderDisplayIndex(groupIndex:int) : int {
			var _local5:int = 0;
			var _local8:int = 0;
			var _local6:int = 0;
			var _local3:Object = null;
			var _local9:Object = this._dataProvider.getItemAt(groupIndex);
			var _local4:Object = this._owner.groupToHeaderData(_local9);
			if(!_local4) {
				return -1;
			}
			var _local7:int = 0;
			var _local2:int = this._dataProvider.getLength();
			_local5 = 0;
			while(_local5 < _local2) {
				_local9 = this._dataProvider.getItemAt(_local5);
				_local4 = this._owner.groupToHeaderData(_local9);
				if(_local4) {
					if(groupIndex == _local5) {
						return _local7;
					}
					_local7++;
				}
				_local8 = this._dataProvider.getLength(_local5);
				_local6 = 0;
				while(_local6 < _local8) {
					_local7++;
					_local6++;
				}
				_local3 = this._owner.groupToFooterData(_local9);
				if(_local3) {
					_local7++;
				}
				_local5++;
			}
			return -1;
		}
		
		private function groupToFooterDisplayIndex(groupIndex:int) : int {
			var _local4:int = 0;
			var _local5:Object = null;
			var _local8:int = 0;
			var _local6:int = 0;
			var _local9:Object = this._dataProvider.getItemAt(groupIndex);
			var _local3:Object = this._owner.groupToFooterData(_local9);
			if(!_local3) {
				return -1;
			}
			var _local7:int = 0;
			var _local2:int = this._dataProvider.getLength();
			_local4 = 0;
			while(_local4 < _local2) {
				_local9 = this._dataProvider.getItemAt(_local4);
				_local5 = this._owner.groupToHeaderData(_local9);
				if(_local5) {
					_local7++;
				}
				_local8 = this._dataProvider.getLength(_local4);
				_local6 = 0;
				while(_local6 < _local8) {
					_local7++;
					_local6++;
				}
				_local3 = this._owner.groupToFooterData(_local9);
				if(_local3) {
					if(groupIndex == _local4) {
						return _local7;
					}
					_local7++;
				}
				_local4++;
			}
			return -1;
		}
		
		private function locationToDisplayIndex(groupIndex:int, itemIndex:int) : int {
			var _local5:int = 0;
			var _local10:Object = null;
			var _local6:Object = null;
			var _local9:int = 0;
			var _local7:int = 0;
			var _local4:Object = null;
			var _local8:int = 0;
			var _local3:int = this._dataProvider.getLength();
			_local5 = 0;
			while(_local5 < _local3) {
				if(itemIndex < 0 && groupIndex == _local5) {
					return _local8;
				}
				_local10 = this._dataProvider.getItemAt(_local5);
				_local6 = this._owner.groupToHeaderData(_local10);
				if(_local6) {
					_local8++;
				}
				_local9 = this._dataProvider.getLength(_local5);
				_local7 = 0;
				while(_local7 < _local9) {
					if(groupIndex == _local5 && itemIndex == _local7) {
						return _local8;
					}
					_local8++;
					_local7++;
				}
				_local4 = this._owner.groupToFooterData(_local10);
				if(_local4) {
					_local8++;
				}
				_local5++;
			}
			return -1;
		}
		
		private function indexToItemRendererType(groupIndex:int, itemIndex:int) : Class {
			var _local3:int = 0;
			if(this._dataProvider !== null && this._dataProvider.getLength() > 0) {
				_local3 = this._dataProvider.getLength(groupIndex);
			}
			if(itemIndex === 0) {
				if(this._singleItemRendererType !== null && _local3 === 1) {
					return this._singleItemRendererType;
				}
				if(this._firstItemRendererType !== null) {
					return this._firstItemRendererType;
				}
			}
			if(this._lastItemRendererType !== null && itemIndex === _local3 - 1) {
				return this._lastItemRendererType;
			}
			return this._itemRendererType;
		}
		
		private function indexToCustomStyleName(groupIndex:int, itemIndex:int) : String {
			var _local3:int = 0;
			if(this._dataProvider !== null && this._dataProvider.getLength() > 0) {
				_local3 = this._dataProvider.getLength(groupIndex);
			}
			if(itemIndex === 0) {
				if(this._customSingleItemRendererStyleName !== null && _local3 === 1) {
					return this._customSingleItemRendererStyleName;
				}
				if(this._customFirstItemRendererStyleName !== null) {
					return this._customFirstItemRendererStyleName;
				}
			}
			if(this._customLastItemRendererStyleName !== null && itemIndex === _local3 - 1) {
				return this._customLastItemRendererStyleName;
			}
			return this._customItemRendererStyleName;
		}
		
		private function getFactoryID(item:Object, groupIndex:int, itemIndex:int) : String {
			var _local4:int = 0;
			if(this._factoryIDFunction === null) {
				_local4 = 0;
				if(this._dataProvider !== null && this._dataProvider.getLength() > 0) {
					_local4 = this._dataProvider.getLength(groupIndex);
				}
				if(itemIndex === 0) {
					if((this._singleItemRendererType !== null || this._singleItemRendererFactory !== null || this._customSingleItemRendererStyleName !== null) && _local4 === 1) {
						return "GroupedListDataViewPort-single";
					}
					if(this._firstItemRendererType !== null || this._firstItemRendererFactory !== null || this._customFirstItemRendererStyleName !== null) {
						return "GroupedListDataViewPort-first";
					}
				}
				if((this._lastItemRendererType !== null || this._lastItemRendererFactory !== null || this._customLastItemRendererStyleName !== null) && itemIndex === _local4 - 1) {
					return "GroupedListDataViewPort-last";
				}
				return null;
			}
			if(this._factoryIDFunction.length === 1) {
				return this._factoryIDFunction(item);
			}
			return this._factoryIDFunction(item,groupIndex,itemIndex);
		}
		
		private function factoryIDToFactory(id:String, groupIndex:int, itemIndex:int) : Function {
			if(id !== null) {
				if(id === "GroupedListDataViewPort-first") {
					if(this._firstItemRendererFactory !== null) {
						return this._firstItemRendererFactory;
					}
					return this._itemRendererFactory;
				}
				if(id === "GroupedListDataViewPort-last") {
					if(this._lastItemRendererFactory !== null) {
						return this._lastItemRendererFactory;
					}
					return this._itemRendererFactory;
				}
				if(id === "GroupedListDataViewPort-single") {
					if(this._singleItemRendererFactory !== null) {
						return this._singleItemRendererFactory;
					}
					return this._itemRendererFactory;
				}
				if(id in this._itemRendererFactories) {
					return this._itemRendererFactories[id] as Function;
				}
				throw new ReferenceError("Cannot find item renderer factory for ID \"" + id + "\".");
			}
			return this._itemRendererFactory;
		}
		
		private function factoryIDToStorage(id:String, groupIndex:int, itemIndex:int) : ItemRendererFactoryStorage {
			var _local4:ItemRendererFactoryStorage = null;
			if(id !== null) {
				if(id in this._itemStorageMap) {
					return ItemRendererFactoryStorage(this._itemStorageMap[id]);
				}
				_local4 = new ItemRendererFactoryStorage();
				this._itemStorageMap[id] = _local4;
				return _local4;
			}
			return this._defaultItemRendererStorage;
		}
		
		private function headerFactoryIDToFactory(id:String) : Function {
			if(id !== null) {
				if(id in this._headerRendererFactories) {
					return this._headerRendererFactories[id] as Function;
				}
				throw new ReferenceError("Cannot find header renderer factory for ID \"" + id + "\".");
			}
			return this._headerRendererFactory;
		}
		
		private function headerFactoryIDToStorage(id:String) : HeaderRendererFactoryStorage {
			var _local2:HeaderRendererFactoryStorage = null;
			if(id !== null) {
				if(id in this._headerStorageMap) {
					return HeaderRendererFactoryStorage(this._headerStorageMap[id]);
				}
				_local2 = new HeaderRendererFactoryStorage();
				this._headerStorageMap[id] = _local2;
				return _local2;
			}
			return this._defaultHeaderRendererStorage;
		}
		
		private function footerFactoryIDToFactory(id:String) : Function {
			if(id !== null) {
				if(id in this._footerRendererFactories) {
					return this._footerRendererFactories[id] as Function;
				}
				throw new ReferenceError("Cannot find footer renderer factory for ID \"" + id + "\".");
			}
			return this._footerRendererFactory;
		}
		
		private function footerFactoryIDToStorage(id:String) : FooterRendererFactoryStorage {
			var _local2:FooterRendererFactoryStorage = null;
			if(id !== null) {
				if(id in this._footerStorageMap) {
					return FooterRendererFactoryStorage(this._footerStorageMap[id]);
				}
				_local2 = new FooterRendererFactoryStorage();
				this._footerStorageMap[id] = _local2;
				return _local2;
			}
			return this._defaultFooterRendererStorage;
		}
		
		private function childProperties_onChange(proxy:PropertyProxy, name:String) : void {
			this.invalidate("styles");
		}
		
		private function owner_scrollStartHandler(event:Event) : void {
			this._isScrolling = true;
		}
		
		private function dataProvider_changeHandler(event:Event) : void {
			this.invalidate("data");
		}
		
		private function dataProvider_addItemHandler(event:Event, indices:Array) : void {
			var _local5:int = 0;
			var _local4:int = 0;
			var _local8:int = 0;
			var _local9:int = 0;
			var _local10:* = 0;
			var _local6:* = 0;
			var _local11:int = 0;
			var _local3:IVariableVirtualLayout = this._layout as IVariableVirtualLayout;
			if(!_local3 || !_local3.hasVariableItemDimensions) {
				return;
			}
			var _local7:int = indices[0] as int;
			if(indices.length > 1) {
				_local5 = indices[1] as int;
				_local4 = this.locationToDisplayIndex(_local7,_local5);
				_local3.addToVariableVirtualCacheAtIndex(_local4);
			} else {
				_local8 = this.groupToHeaderDisplayIndex(_local7);
				if(_local8 >= 0) {
					_local3.addToVariableVirtualCacheAtIndex(_local8);
				}
				_local9 = this._dataProvider.getLength(_local7);
				if(_local9 > 0) {
					_local10 = _local8;
					if(_local10 < 0) {
						_local10 = this.locationToDisplayIndex(_local7,0);
					}
					_local9 += _local10;
					_local6 = _local10;
					while(_local6 < _local9) {
						_local3.addToVariableVirtualCacheAtIndex(_local10);
						_local6++;
					}
				}
				_local11 = this.groupToFooterDisplayIndex(_local7);
				if(_local11 >= 0) {
					_local3.addToVariableVirtualCacheAtIndex(_local11);
				}
			}
		}
		
		private function dataProvider_removeItemHandler(event:Event, indices:Array) : void {
			var _local4:int = 0;
			var _local6:int = 0;
			var _local3:IVariableVirtualLayout = this._layout as IVariableVirtualLayout;
			if(!_local3 || !_local3.hasVariableItemDimensions) {
				return;
			}
			var _local5:int = indices[0] as int;
			if(indices.length > 1) {
				_local4 = indices[1] as int;
				_local6 = this.locationToDisplayIndex(_local5,_local4);
				_local3.removeFromVariableVirtualCacheAtIndex(_local6);
			} else {
				_local3.resetVariableVirtualCache();
			}
		}
		
		private function dataProvider_replaceItemHandler(event:Event, indices:Array) : void {
			var _local4:int = 0;
			var _local6:int = 0;
			var _local3:IVariableVirtualLayout = this._layout as IVariableVirtualLayout;
			if(!_local3 || !_local3.hasVariableItemDimensions) {
				return;
			}
			var _local5:int = indices[0] as int;
			if(indices.length > 1) {
				_local4 = indices[1] as int;
				_local6 = this.locationToDisplayIndex(_local5,_local4);
				_local3.resetVariableVirtualCacheAtIndex(_local6);
			} else {
				_local3.resetVariableVirtualCache();
			}
		}
		
		private function dataProvider_resetHandler(event:Event) : void {
			this._updateForDataReset = true;
			var _local2:IVariableVirtualLayout = this._layout as IVariableVirtualLayout;
			if(!_local2 || !_local2.hasVariableItemDimensions) {
				return;
			}
			_local2.resetVariableVirtualCache();
		}
		
		private function dataProvider_updateItemHandler(event:Event, indices:Array) : void {
			var _local6:int = 0;
			var _local5:Object = null;
			var _local3:IGroupedListItemRenderer = null;
			var _local10:int = 0;
			var _local7:int = 0;
			var _local11:Object = null;
			var _local12:IGroupedListHeaderRenderer = null;
			var _local8:IGroupedListFooterRenderer = null;
			var _local4:IVariableVirtualLayout = null;
			var _local9:int = indices[0] as int;
			if(indices.length > 1) {
				_local6 = indices[1] as int;
				_local5 = this._dataProvider.getItemAt(_local9,_local6);
				_local3 = IGroupedListItemRenderer(this._itemRendererMap[_local5]);
				if(_local3) {
					_local3.data = null;
					_local3.data = _local5;
				}
			} else {
				_local10 = this._dataProvider.getLength(_local9);
				_local7 = 0;
				while(_local7 < _local10) {
					_local5 = this._dataProvider.getItemAt(_local9,_local7);
					if(_local5) {
						_local3 = IGroupedListItemRenderer(this._itemRendererMap[_local5]);
						if(_local3) {
							_local3.data = null;
							_local3.data = _local5;
						}
					}
					_local7++;
				}
				_local11 = this._dataProvider.getItemAt(_local9);
				_local5 = this._owner.groupToHeaderData(_local11);
				if(_local5) {
					_local12 = IGroupedListHeaderRenderer(this._headerRendererMap[_local5]);
					if(_local12) {
						_local12.data = null;
						_local12.data = _local5;
					}
				}
				_local5 = this._owner.groupToFooterData(_local11);
				if(_local5) {
					_local8 = IGroupedListFooterRenderer(this._footerRendererMap[_local5]);
					if(_local8) {
						_local8.data = null;
						_local8.data = _local5;
					}
				}
				this.invalidate("data");
				_local4 = this._layout as IVariableVirtualLayout;
				if(!_local4 || !_local4.hasVariableItemDimensions) {
					return;
				}
				_local4.resetVariableVirtualCache();
			}
		}
		
		private function dataProvider_updateAllHandler(event:Event) : void {
			var _local2:IGroupedListItemRenderer = null;
			var _local7:IGroupedListHeaderRenderer = null;
			var _local6:IGroupedListFooterRenderer = null;
			for(var _local3 in this._itemRendererMap) {
				_local2 = IGroupedListItemRenderer(this._itemRendererMap[_local3]);
				if(!_local2) {
					return;
				}
				_local2.data = null;
				_local2.data = _local3;
			}
			for(var _local5 in this._headerRendererMap) {
				_local7 = IGroupedListHeaderRenderer(this._headerRendererMap[_local5]);
				if(!_local7) {
					return;
				}
				_local7.data = null;
				_local7.data = _local5;
			}
			for(var _local4 in this._footerRendererMap) {
				_local6 = IGroupedListFooterRenderer(this._footerRendererMap[_local4]);
				if(!_local6) {
					return;
				}
				_local6.data = null;
				_local6.data = _local4;
			}
		}
		
		private function layout_changeHandler(event:Event) : void {
			if(this._ignoreLayoutChanges) {
				return;
			}
			this.invalidate("layout");
			this.invalidateParent("layout");
		}
		
		private function itemRenderer_resizeHandler(event:Event) : void {
			if(this._ignoreRendererResizing) {
				return;
			}
			if(event.currentTarget === this._typicalItemRenderer && !this._typicalItemIsInDataProvider) {
				return;
			}
			var _local3:IGroupedListItemRenderer = IGroupedListItemRenderer(event.currentTarget);
			if(_local3.layoutIndex < 0) {
				return;
			}
			this.invalidate("layout");
			this.invalidateParent("layout");
			var _local2:IVariableVirtualLayout = this._layout as IVariableVirtualLayout;
			if(!_local2 || !_local2.hasVariableItemDimensions) {
				return;
			}
			_local2.resetVariableVirtualCacheAtIndex(_local3.layoutIndex,DisplayObject(_local3));
		}
		
		private function headerRenderer_resizeHandler(event:Event) : void {
			if(this._ignoreRendererResizing) {
				return;
			}
			var _local3:IGroupedListHeaderRenderer = IGroupedListHeaderRenderer(event.currentTarget);
			if(_local3.layoutIndex < 0) {
				return;
			}
			this.invalidate("layout");
			this.invalidateParent("layout");
			var _local2:IVariableVirtualLayout = this._layout as IVariableVirtualLayout;
			if(!_local2 || !_local2.hasVariableItemDimensions) {
				return;
			}
			_local2.resetVariableVirtualCacheAtIndex(_local3.layoutIndex,DisplayObject(_local3));
		}
		
		private function footerRenderer_resizeHandler(event:Event) : void {
			if(this._ignoreRendererResizing) {
				return;
			}
			var _local3:IGroupedListFooterRenderer = IGroupedListFooterRenderer(event.currentTarget);
			if(_local3.layoutIndex < 0) {
				return;
			}
			this.invalidate("layout");
			this.invalidateParent("layout");
			var _local2:IVariableVirtualLayout = this._layout as IVariableVirtualLayout;
			if(!_local2 || !_local2.hasVariableItemDimensions) {
				return;
			}
			_local2.resetVariableVirtualCacheAtIndex(_local3.layoutIndex,DisplayObject(_local3));
		}
		
		private function renderer_triggeredHandler(event:Event) : void {
			var _local2:IGroupedListItemRenderer = IGroupedListItemRenderer(event.currentTarget);
			this.parent.dispatchEventWith("triggered",false,_local2.data);
		}
		
		private function renderer_changeHandler(event:Event) : void {
			if(this._ignoreSelectionChanges) {
				return;
			}
			var _local2:IGroupedListItemRenderer = IGroupedListItemRenderer(event.currentTarget);
			if(!this._isSelectable || this._isScrolling) {
				_local2.isSelected = false;
				return;
			}
			if(_local2.isSelected) {
				this.setSelectedLocation(_local2.groupIndex,_local2.itemIndex);
			} else {
				this.setSelectedLocation(-1,-1);
			}
		}
		
		private function removedFromStageHandler(event:Event) : void {
			this.touchPointID = -1;
		}
		
		private function touchHandler(event:TouchEvent) : void {
			var _local2:Touch = null;
			if(!this._isEnabled) {
				this.touchPointID = -1;
				return;
			}
			if(this.touchPointID >= 0) {
				_local2 = event.getTouch(this,"ended",this.touchPointID);
				if(!_local2) {
					return;
				}
				this.touchPointID = -1;
			} else {
				_local2 = event.getTouch(this,"began");
				if(!_local2) {
					return;
				}
				this.touchPointID = _local2.id;
				this._isScrolling = false;
			}
		}
	}
}

import feathers.controls.renderers.IGroupedListFooterRenderer;
import feathers.controls.renderers.IGroupedListHeaderRenderer;
import feathers.controls.renderers.IGroupedListItemRenderer;

class ItemRendererFactoryStorage {
	public var activeItemRenderers:Vector.<IGroupedListItemRenderer> = new Vector.<IGroupedListItemRenderer>(0);
	
	public var inactiveItemRenderers:Vector.<IGroupedListItemRenderer> = new Vector.<IGroupedListItemRenderer>(0);
	
	public function ItemRendererFactoryStorage() {
		super();
	}
}

class HeaderRendererFactoryStorage {
	public var activeHeaderRenderers:Vector.<IGroupedListHeaderRenderer> = new Vector.<IGroupedListHeaderRenderer>(0);
	
	public var inactiveHeaderRenderers:Vector.<IGroupedListHeaderRenderer> = new Vector.<IGroupedListHeaderRenderer>(0);
	
	public function HeaderRendererFactoryStorage() {
		super();
	}
}

class FooterRendererFactoryStorage {
	public var activeFooterRenderers:Vector.<IGroupedListFooterRenderer> = new Vector.<IGroupedListFooterRenderer>(0);
	
	public var inactiveFooterRenderers:Vector.<IGroupedListFooterRenderer> = new Vector.<IGroupedListFooterRenderer>(0);
	
	public function FooterRendererFactoryStorage() {
		super();
	}
}
