package feathers.controls {
	import feathers.controls.renderers.DefaultListItemRenderer;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.controls.supportClasses.ListDataViewPort;
	import feathers.core.IFocusContainer;
	import feathers.core.PropertyProxy;
	import feathers.data.ListCollection;
	import feathers.layout.ILayout;
	import feathers.layout.ISpinnerLayout;
	import feathers.layout.IVariableVirtualLayout;
	import feathers.layout.VerticalLayout;
	import feathers.skins.IStyleProvider;
	import flash.geom.Point;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	
	public class List extends Scroller implements IFocusContainer {
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
		
		public static var globalStyleProvider:IStyleProvider;
		
		private static const HELPER_POINT:Point = new Point();
		
		protected var dataViewPort:ListDataViewPort;
		
		protected var _isChildFocusEnabled:Boolean = true;
		
		protected var _layout:ILayout;
		
		protected var _dataProvider:ListCollection;
		
		protected var _isSelectable:Boolean = true;
		
		protected var _selectedIndex:int = -1;
		
		protected var _allowMultipleSelection:Boolean = false;
		
		protected var _selectedIndices:ListCollection = new ListCollection(new Vector.<int>(0));
		
		protected var _itemRendererType:Class = DefaultListItemRenderer;
		
		protected var _itemRendererFactories:Object;
		
		protected var _itemRendererFactory:Function;
		
		protected var _factoryIDFunction:Function;
		
		protected var _typicalItem:Object = null;
		
		protected var _customItemRendererStyleName:String;
		
		protected var _itemRendererProperties:PropertyProxy;
		
		protected var _keyScrollDuration:Number = 0.25;
		
		protected var pendingItemIndex:int = -1;
		
		public function List() {
			super();
			this._selectedIndices.addEventListener("change",selectedIndices_changeHandler);
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return List.globalStyleProvider;
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
			if(!(this is SpinnerList) && value is ISpinnerLayout) {
				throw new ArgumentError("Layouts that implement the ISpinnerLayout interface should be used with the SpinnerList component.");
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
		
		public function get dataProvider() : ListCollection {
			return this._dataProvider;
		}
		
		public function set dataProvider(value:ListCollection) : void {
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
			this.selectedIndex = -1;
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
				this.selectedIndex = -1;
			}
			this.invalidate("selected");
		}
		
		public function get selectedIndex() : int {
			return this._selectedIndex;
		}
		
		public function set selectedIndex(value:int) : void {
			if(this._selectedIndex == value) {
				return;
			}
			if(value >= 0) {
				this._selectedIndices.data = new <int>[value];
			} else {
				this._selectedIndices.removeAll();
			}
			this.invalidate("selected");
		}
		
		public function get selectedItem() : Object {
			if(!this._dataProvider || this._selectedIndex < 0 || this._selectedIndex >= this._dataProvider.length) {
				return null;
			}
			return this._dataProvider.getItemAt(this._selectedIndex);
		}
		
		public function set selectedItem(value:Object) : void {
			if(!this._dataProvider) {
				this.selectedIndex = -1;
				return;
			}
			this.selectedIndex = this._dataProvider.getItemIndex(value);
		}
		
		public function get allowMultipleSelection() : Boolean {
			return this._allowMultipleSelection;
		}
		
		public function set allowMultipleSelection(value:Boolean) : void {
			if(this._allowMultipleSelection == value) {
				return;
			}
			this._allowMultipleSelection = value;
			this.invalidate("selected");
		}
		
		public function get selectedIndices() : Vector.<int> {
			return this._selectedIndices.data as Vector.<int>;
		}
		
		public function set selectedIndices(value:Vector.<int>) : void {
			var _local2:Vector.<int> = this._selectedIndices.data as Vector.<int>;
			if(_local2 == value) {
				return;
			}
			if(!value) {
				if(this._selectedIndices.length == 0) {
					return;
				}
				this._selectedIndices.removeAll();
			} else {
				if(!this._allowMultipleSelection && value.length > 0) {
					value.length = 1;
				}
				this._selectedIndices.data = value;
			}
			this.invalidate("selected");
		}
		
		public function get selectedItems() : Vector.<Object> {
			return this.getSelectedItems(new Vector.<Object>(0));
		}
		
		public function set selectedItems(value:Vector.<Object>) : void {
			var _local4:int = 0;
			var _local3:Object = null;
			var _local5:int = 0;
			if(!value || !this._dataProvider) {
				this.selectedIndex = -1;
				return;
			}
			var _local2:Vector.<int> = new Vector.<int>(0);
			var _local6:int = int(value.length);
			_local4 = 0;
			while(_local4 < _local6) {
				_local3 = value[_local4];
				_local5 = this._dataProvider.getItemIndex(_local3);
				if(_local5 >= 0) {
					_local2.push(_local5);
				}
				_local4++;
			}
			this.selectedIndices = _local2;
		}
		
		public function getSelectedItems(result:Vector.<Object> = null) : Vector.<Object> {
			var _local4:int = 0;
			var _local5:int = 0;
			var _local2:Object = null;
			if(result) {
				result.length = 0;
			} else {
				result = new Vector.<Object>(0);
			}
			if(!this._dataProvider) {
				return result;
			}
			var _local3:int = this._selectedIndices.length;
			_local4 = 0;
			while(_local4 < _local3) {
				_local5 = this._selectedIndices.getItemAt(_local4) as int;
				_local2 = this._dataProvider.getItemAt(_local5);
				result[_local4] = _local2;
				_local4++;
			}
			return result;
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
		
		public function get keyScrollDuration() : Number {
			return this._keyScrollDuration;
		}
		
		public function set keyScrollDuration(value:Number) : void {
			this._keyScrollDuration = value;
		}
		
		override public function scrollToPosition(horizontalScrollPosition:Number, verticalScrollPosition:Number, animationDuration:Number = NaN) : void {
			this.pendingItemIndex = -1;
			super.scrollToPosition(horizontalScrollPosition,verticalScrollPosition,animationDuration);
		}
		
		override public function scrollToPageIndex(horizontalPageIndex:int, verticalPageIndex:int, animationDuration:Number = NaN) : void {
			this.pendingItemIndex = -1;
			super.scrollToPageIndex(horizontalPageIndex,verticalPageIndex,animationDuration);
		}
		
		public function scrollToDisplayIndex(index:int, animationDuration:Number = 0) : void {
			this.hasPendingHorizontalPageIndex = false;
			this.hasPendingVerticalPageIndex = false;
			this.pendingHorizontalScrollPosition = NaN;
			this.pendingVerticalScrollPosition = NaN;
			if(this.pendingItemIndex == index && this.pendingScrollDuration == animationDuration) {
				return;
			}
			this.pendingItemIndex = index;
			this.pendingScrollDuration = animationDuration;
			this.invalidate("pendingScroll");
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
		
		public function itemToItemRenderer(item:Object) : IListItemRenderer {
			return this.dataViewPort.itemToItemRenderer(item);
		}
		
		override public function dispose() : void {
			this._selectedIndices.removeEventListeners();
			this._selectedIndex = -1;
			this.dataProvider = null;
			this.layout = null;
			super.dispose();
		}
		
		override protected function initialize() : void {
			var _local1:VerticalLayout = null;
			var _local2:* = this._layout != null;
			super.initialize();
			if(!this.dataViewPort) {
				this.viewPort = this.dataViewPort = new ListDataViewPort();
				this.dataViewPort.owner = this;
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
				this.layout = _local1;
			}
		}
		
		override protected function draw() : void {
			this.refreshDataViewPortProperties();
			super.draw();
		}
		
		protected function refreshDataViewPortProperties() : void {
			this.dataViewPort.isSelectable = this._isSelectable;
			this.dataViewPort.allowMultipleSelection = this._allowMultipleSelection;
			this.dataViewPort.selectedIndices = this._selectedIndices;
			this.dataViewPort.dataProvider = this._dataProvider;
			this.dataViewPort.itemRendererType = this._itemRendererType;
			this.dataViewPort.itemRendererFactory = this._itemRendererFactory;
			this.dataViewPort.itemRendererFactories = this._itemRendererFactories;
			this.dataViewPort.factoryIDFunction = this._factoryIDFunction;
			this.dataViewPort.itemRendererProperties = this._itemRendererProperties;
			this.dataViewPort.customItemRendererStyleName = this._customItemRendererStyleName;
			this.dataViewPort.typicalItem = this._typicalItem;
			this.dataViewPort.layout = this._layout;
		}
		
		override protected function handlePendingScroll() : void {
			var _local1:Object = null;
			var _local2:Number = NaN;
			var _local3:Number = NaN;
			if(this.pendingItemIndex >= 0) {
				_local1 = this._dataProvider.getItemAt(this.pendingItemIndex);
				if(_local1 is Object) {
					this.dataViewPort.getScrollPositionForIndex(this.pendingItemIndex,HELPER_POINT);
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
			if(!this._dataProvider) {
				return;
			}
			var _local2:Boolean = false;
			if(event.keyCode == 36) {
				if(this._dataProvider.length > 0) {
					this.selectedIndex = 0;
					_local2 = true;
				}
			} else if(event.keyCode == 35) {
				this.selectedIndex = this._dataProvider.length - 1;
				_local2 = true;
			} else if(event.keyCode == 38) {
				this.selectedIndex = Math.max(0,this._selectedIndex - 1);
				_local2 = true;
			} else if(event.keyCode == 40) {
				this.selectedIndex = Math.min(this._dataProvider.length - 1,this._selectedIndex + 1);
				_local2 = true;
			}
			if(_local2) {
				this.dataViewPort.getNearestScrollPositionForIndex(this.selectedIndex,HELPER_POINT);
				this.scrollToPosition(HELPER_POINT.x,HELPER_POINT.y,this._keyScrollDuration);
			}
		}
		
		protected function dataProvider_changeHandler(event:Event) : void {
			this.invalidate("data");
		}
		
		protected function dataProvider_resetHandler(event:Event) : void {
			this.horizontalScrollPosition = 0;
			this.verticalScrollPosition = 0;
			this._selectedIndices.removeAll();
		}
		
		protected function dataProvider_addItemHandler(event:Event, index:int) : void {
			var _local5:int = 0;
			var _local6:int = 0;
			if(this._selectedIndex == -1) {
				return;
			}
			var _local3:Boolean = false;
			var _local7:Vector.<int> = new Vector.<int>(0);
			var _local4:int = this._selectedIndices.length;
			_local5 = 0;
			while(_local5 < _local4) {
				_local6 = this._selectedIndices.getItemAt(_local5) as int;
				if(_local6 >= index) {
					_local6++;
					_local3 = true;
				}
				_local7.push(_local6);
				_local5++;
			}
			if(_local3) {
				this._selectedIndices.data = _local7;
			}
		}
		
		protected function dataProvider_removeItemHandler(event:Event, index:int) : void {
			var _local5:int = 0;
			var _local6:int = 0;
			if(this._selectedIndex == -1) {
				return;
			}
			var _local3:Boolean = false;
			var _local7:Vector.<int> = new Vector.<int>(0);
			var _local4:int = this._selectedIndices.length;
			_local5 = 0;
			while(_local5 < _local4) {
				_local6 = this._selectedIndices.getItemAt(_local5) as int;
				if(_local6 == index) {
					_local3 = true;
				} else {
					if(_local6 > index) {
						_local6--;
						_local3 = true;
					}
					_local7.push(_local6);
				}
				_local5++;
			}
			if(_local3) {
				this._selectedIndices.data = _local7;
			}
		}
		
		protected function dataProvider_replaceItemHandler(event:Event, index:int) : void {
			if(this._selectedIndex == -1) {
				return;
			}
			var _local3:int = this._selectedIndices.getItemIndex(index);
			if(_local3 >= 0) {
				this._selectedIndices.removeItemAt(_local3);
			}
		}
		
		protected function selectedIndices_changeHandler(event:Event) : void {
			if(this._selectedIndices.length > 0) {
				this._selectedIndex = this._selectedIndices.getItemAt(0) as int;
			} else {
				if(this._selectedIndex < 0) {
					return;
				}
				this._selectedIndex = -1;
			}
			this.dispatchEventWith("change");
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

