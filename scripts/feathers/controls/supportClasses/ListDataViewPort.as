package feathers.controls.supportClasses {
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	import feathers.core.IFeathersControl;
	import feathers.core.IValidating;
	import feathers.core.PropertyProxy;
	import feathers.data.ListCollection;
	import feathers.layout.ILayout;
	import feathers.layout.ITrimmedVirtualLayout;
	import feathers.layout.IVariableVirtualLayout;
	import feathers.layout.IVirtualLayout;
	import feathers.layout.LayoutBoundsResult;
	import feathers.layout.ViewPortBounds;
	import flash.errors.IllegalOperationError;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	public class ListDataViewPort extends FeathersControl implements IViewPort {
		private static const INVALIDATION_FLAG_ITEM_RENDERER_FACTORY:String = "itemRendererFactory";
		
		private static const HELPER_POINT:Point = new Point();
		
		private static const HELPER_VECTOR:Vector.<int> = new Vector.<int>(0);
		
		private var touchPointID:int = -1;
		
		private var _viewPortBounds:ViewPortBounds = new ViewPortBounds();
		
		private var _layoutResult:LayoutBoundsResult = new LayoutBoundsResult();
		
		private var _actualMinVisibleWidth:Number = 0;
		
		private var _explicitMinVisibleWidth:Number;
		
		private var _maxVisibleWidth:Number = Infinity;
		
		private var actualVisibleWidth:Number = 0;
		
		private var explicitVisibleWidth:Number = NaN;
		
		private var _actualMinVisibleHeight:Number = 0;
		
		private var _explicitMinVisibleHeight:Number;
		
		private var _maxVisibleHeight:Number = Infinity;
		
		private var actualVisibleHeight:Number = 0;
		
		private var explicitVisibleHeight:Number = NaN;
		
		protected var _contentX:Number = 0;
		
		protected var _contentY:Number = 0;
		
		private var _typicalItemIsInDataProvider:Boolean = false;
		
		private var _typicalItemRenderer:IListItemRenderer;
		
		private var _unrenderedData:Array = [];
		
		private var _layoutItems:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
		
		private var _defaultStorage:ItemRendererFactoryStorage = new ItemRendererFactoryStorage();
		
		private var _storageMap:Object;
		
		private var _rendererMap:Dictionary = new Dictionary(true);
		
		private var _minimumItemCount:int;
		
		private var _layoutIndexOffset:int = 0;
		
		private var _isScrolling:Boolean = false;
		
		private var _owner:List;
		
		private var _updateForDataReset:Boolean = false;
		
		private var _dataProvider:ListCollection;
		
		private var _itemRendererType:Class;
		
		private var _itemRendererFactory:Function;
		
		private var _itemRendererFactories:Object;
		
		private var _factoryIDFunction:Function;
		
		private var _customItemRendererStyleName:String;
		
		private var _typicalItem:Object = null;
		
		private var _itemRendererProperties:PropertyProxy;
		
		private var _ignoreLayoutChanges:Boolean = false;
		
		private var _ignoreRendererResizing:Boolean = false;
		
		private var _layout:ILayout;
		
		private var _horizontalScrollPosition:Number = 0;
		
		private var _verticalScrollPosition:Number = 0;
		
		private var _ignoreSelectionChanges:Boolean = false;
		
		private var _isSelectable:Boolean = true;
		
		private var _allowMultipleSelection:Boolean = false;
		
		private var _selectedIndices:ListCollection;
		
		public function ListDataViewPort() {
			super();
			this.addEventListener("removedFromStage",removedFromStageHandler);
			this.addEventListener("touch",touchHandler);
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
				if(this.explicitVisibleWidth !== this.explicitVisibleWidth && (this.actualVisibleWidth < value || this.actualVisibleWidth === _local3)) {
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
			if(this.explicitVisibleWidth !== this.explicitVisibleWidth && (this.actualVisibleWidth > value || this.actualVisibleWidth === _local2)) {
				this.invalidate("size");
			}
		}
		
		public function get visibleWidth() : Number {
			return this.actualVisibleWidth;
		}
		
		public function set visibleWidth(value:Number) : void {
			if(this.explicitVisibleWidth == value || value !== value && this.explicitVisibleWidth !== this.explicitVisibleWidth) {
				return;
			}
			this.explicitVisibleWidth = value;
			if(this.actualVisibleWidth !== value) {
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
				if(this.explicitVisibleHeight !== this.explicitVisibleHeight && (this.actualVisibleHeight < value || this.actualVisibleHeight === _local3)) {
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
			if(this.explicitVisibleHeight !== this.explicitVisibleHeight && (this.actualVisibleHeight > value || this.actualVisibleHeight === _local2)) {
				this.invalidate("size");
			}
		}
		
		public function get visibleHeight() : Number {
			return this.actualVisibleHeight;
		}
		
		public function set visibleHeight(value:Number) : void {
			if(this.explicitVisibleHeight == value || value !== value && this.explicitVisibleHeight !== this.explicitVisibleHeight) {
				return;
			}
			this.explicitVisibleHeight = value;
			if(this.actualVisibleHeight !== value) {
				this.invalidate("size");
			}
		}
		
		public function get contentX() : Number {
			return this._contentX;
		}
		
		public function get contentY() : Number {
			return this._contentY;
		}
		
		public function get owner() : List {
			return this._owner;
		}
		
		public function set owner(value:List) : void {
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
		
		public function get dataProvider() : ListCollection {
			return this._dataProvider;
		}
		
		public function set dataProvider(value:ListCollection) : void {
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
			if(value !== null) {
				this._storageMap = {};
			}
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
		
		public function get layout() : ILayout {
			return this._layout;
		}
		
		public function set layout(value:ILayout) : void {
			if(this._layout == value) {
				return;
			}
			if(this._layout) {
				EventDispatcher(this._layout).removeEventListener("change",layout_changeHandler);
			}
			this._layout = value;
			if(this._layout) {
				if(this._layout is IVariableVirtualLayout) {
					IVariableVirtualLayout(this._layout).resetVariableVirtualCache();
				}
				EventDispatcher(this._layout).addEventListener("change",layout_changeHandler);
			}
			this.invalidate("layout");
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
		
		public function get isSelectable() : Boolean {
			return this._isSelectable;
		}
		
		public function set isSelectable(value:Boolean) : void {
			if(this._isSelectable == value) {
				return;
			}
			this._isSelectable = value;
			if(!value) {
				this.selectedIndices = null;
			}
		}
		
		public function get allowMultipleSelection() : Boolean {
			return this._allowMultipleSelection;
		}
		
		public function set allowMultipleSelection(value:Boolean) : void {
			this._allowMultipleSelection = value;
		}
		
		public function get selectedIndices() : ListCollection {
			return this._selectedIndices;
		}
		
		public function set selectedIndices(value:ListCollection) : void {
			if(this._selectedIndices == value) {
				return;
			}
			if(this._selectedIndices) {
				this._selectedIndices.removeEventListener("change",selectedIndices_changeHandler);
			}
			this._selectedIndices = value;
			if(this._selectedIndices) {
				this._selectedIndices.addEventListener("change",selectedIndices_changeHandler);
			}
			this.invalidate("selected");
		}
		
		public function get requiresMeasurementOnScroll() : Boolean {
			return this._layout.requiresLayoutOnScroll && (this.explicitVisibleWidth !== this.explicitVisibleWidth || this.explicitVisibleHeight !== this.explicitVisibleHeight);
		}
		
		public function getScrollPositionForIndex(index:int, result:Point = null) : Point {
			if(!result) {
				result = new Point();
			}
			return this._layout.getScrollPositionForIndex(index,this._layoutItems,0,0,this.actualVisibleWidth,this.actualVisibleHeight,result);
		}
		
		public function getNearestScrollPositionForIndex(index:int, result:Point = null) : Point {
			if(!result) {
				result = new Point();
			}
			return this._layout.getNearestScrollPositionForIndex(index,this._horizontalScrollPosition,this._verticalScrollPosition,this._layoutItems,0,0,this.actualVisibleWidth,this.actualVisibleHeight,result);
		}
		
		public function itemToItemRenderer(item:Object) : IListItemRenderer {
			return IListItemRenderer(this._rendererMap[item]);
		}
		
		override public function dispose() : void {
			this.refreshInactiveRenderers(null,true);
			if(this._storageMap) {
				for(var _local1 in this._storageMap) {
					this.refreshInactiveRenderers(_local1,true);
				}
			}
			this.owner = null;
			this.layout = null;
			this.dataProvider = null;
			super.dispose();
		}
		
		override protected function draw() : void {
			var _local13:Boolean = false;
			var _local6:Boolean = this.isInvalid("data");
			var _local9:Boolean = this.isInvalid("scroll");
			var _local1:Boolean = this.isInvalid("size");
			var _local4:Boolean = this.isInvalid("selected");
			var _local11:Boolean = this.isInvalid("itemRendererFactory");
			var _local7:Boolean = this.isInvalid("styles");
			var _local2:Boolean = this.isInvalid("state");
			var _local12:Boolean = this.isInvalid("layout");
			if(!_local12 && _local9 && this._layout && this._layout.requiresLayoutOnScroll) {
				_local12 = true;
			}
			var _local5:Boolean = _local1 || _local6 || _local12 || _local11;
			var _local8:Boolean = this._ignoreRendererResizing;
			this._ignoreRendererResizing = true;
			var _local10:Boolean = this._ignoreLayoutChanges;
			this._ignoreLayoutChanges = true;
			if(_local9 || _local1) {
				this.refreshViewPortBounds();
			}
			if(_local5) {
				this.refreshInactiveRenderers(null,_local11);
				if(this._storageMap) {
					for(var _local3 in this._storageMap) {
						this.refreshInactiveRenderers(_local3,_local11);
					}
				}
			}
			if(_local6 || _local12 || _local11) {
				this.refreshLayoutTypicalItem();
			}
			if(_local5) {
				this.refreshRenderers();
			}
			if(_local7 || _local5) {
				this.refreshItemRendererStyles();
			}
			if(_local4 || _local5) {
				_local13 = this._ignoreSelectionChanges;
				this._ignoreSelectionChanges = true;
				this.refreshSelection();
				this._ignoreSelectionChanges = _local13;
			}
			if(_local2 || _local5) {
				this.refreshEnabled();
			}
			this._ignoreLayoutChanges = _local10;
			if(_local2 || _local4 || _local7 || _local5) {
				this._layout.layout(this._layoutItems,this._viewPortBounds,this._layoutResult);
			}
			this._ignoreRendererResizing = _local8;
			this._contentX = this._layoutResult.contentX;
			this._contentY = this._layoutResult.contentY;
			this.saveMeasurements(this._layoutResult.contentWidth,this._layoutResult.contentHeight,this._layoutResult.contentWidth,this._layoutResult.contentHeight);
			this.actualVisibleWidth = this._layoutResult.viewPortWidth;
			this.actualVisibleHeight = this._layoutResult.viewPortHeight;
			this._actualMinVisibleWidth = this._layoutResult.viewPortWidth;
			this._actualMinVisibleHeight = this._layoutResult.viewPortHeight;
			this.validateItemRenderers();
		}
		
		private function invalidateParent(flag:String = "all") : void {
			Scroller(this.parent).invalidate(flag);
		}
		
		private function validateItemRenderers() : void {
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
		
		private function refreshLayoutTypicalItem() : void {
			var _local6:IListItemRenderer = null;
			var _local7:* = false;
			var _local1:Boolean = false;
			var _local3:String = null;
			var _local8:IVirtualLayout = this._layout as IVirtualLayout;
			if(!_local8 || !_local8.useVirtualLayout) {
				if(!this._typicalItemIsInDataProvider && this._typicalItemRenderer) {
					this.destroyRenderer(this._typicalItemRenderer);
					this._typicalItemRenderer = null;
				}
				return;
			}
			var _local5:int = 0;
			var _local4:* = false;
			var _local2:Object = this._typicalItem;
			if(_local2 !== null) {
				if(this._dataProvider) {
					_local5 = this._dataProvider.getItemIndex(_local2);
					_local4 = _local5 >= 0;
				}
				if(_local5 < 0) {
					_local5 = 0;
				}
			} else {
				_local4 = true;
				if(this._dataProvider && this._dataProvider.length > 0) {
					_local2 = this._dataProvider.getItemAt(0);
				}
			}
			if(_local2 !== null) {
				_local6 = IListItemRenderer(this._rendererMap[_local2]);
				if(_local6) {
					_local6.index = _local5;
				}
				if(!_local6 && this._typicalItemRenderer) {
					_local7 = !this._typicalItemIsInDataProvider;
					_local1 = this._typicalItemIsInDataProvider && this._dataProvider && this._dataProvider.getItemIndex(this._typicalItemRenderer.data) < 0;
					if(!_local7 && _local1) {
						_local7 = true;
					}
					if(_local7) {
						_local3 = null;
						if(this._factoryIDFunction !== null) {
							_local3 = this.getFactoryID(_local2,_local5);
						}
						if(this._typicalItemRenderer.factoryID !== _local3) {
							_local7 = false;
						}
					}
					if(_local7) {
						if(this._typicalItemIsInDataProvider) {
							delete this._rendererMap[this._typicalItemRenderer.data];
						}
						_local6 = this._typicalItemRenderer;
						_local6.data = _local2;
						_local6.index = _local5;
						if(_local4) {
							this._rendererMap[_local2] = _local6;
						}
					}
				}
				if(!_local6) {
					_local6 = this.createRenderer(_local2,_local5,false,!_local4);
					if(!this._typicalItemIsInDataProvider && this._typicalItemRenderer) {
						this.destroyRenderer(this._typicalItemRenderer);
						this._typicalItemRenderer = null;
					}
				}
			}
			_local8.typicalItem = DisplayObject(_local6);
			this._typicalItemRenderer = _local6;
			this._typicalItemIsInDataProvider = _local4;
			if(this._typicalItemRenderer && !this._typicalItemIsInDataProvider) {
				this._typicalItemRenderer.addEventListener("resize",renderer_resizeHandler);
			}
		}
		
		private function refreshItemRendererStyles() : void {
			var _local1:IListItemRenderer = null;
			for each(var _local2 in this._layoutItems) {
				_local1 = _local2 as IListItemRenderer;
				if(_local1) {
					this.refreshOneItemRendererStyles(_local1);
				}
			}
		}
		
		private function refreshOneItemRendererStyles(renderer:IListItemRenderer) : void {
			var _local4:Object = null;
			var _local2:DisplayObject = DisplayObject(renderer);
			for(var _local3 in this._itemRendererProperties) {
				_local4 = this._itemRendererProperties[_local3];
				_local2[_local3] = _local4;
			}
		}
		
		private function refreshSelection() : void {
			var _local1:IListItemRenderer = null;
			for each(var _local2 in this._layoutItems) {
				_local1 = _local2 as IListItemRenderer;
				if(_local1) {
					_local1.isSelected = this._selectedIndices.getItemIndex(_local1.index) >= 0;
				}
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
		
		private function refreshViewPortBounds() : void {
			var _local1:* = this._explicitMinVisibleWidth !== this._explicitMinVisibleWidth;
			var _local2:* = this._explicitMinVisibleHeight !== this._explicitMinVisibleHeight;
			this._viewPortBounds.x = 0;
			this._viewPortBounds.y = 0;
			this._viewPortBounds.scrollX = this._horizontalScrollPosition;
			this._viewPortBounds.scrollY = this._verticalScrollPosition;
			this._viewPortBounds.explicitWidth = this.explicitVisibleWidth;
			this._viewPortBounds.explicitHeight = this.explicitVisibleHeight;
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
		
		private function refreshInactiveRenderers(factoryID:String, itemRendererTypeIsInvalid:Boolean) : void {
			var _local4:ItemRendererFactoryStorage = null;
			if(factoryID !== null) {
				_local4 = ItemRendererFactoryStorage(this._storageMap[factoryID]);
			} else {
				_local4 = this._defaultStorage;
			}
			var _local3:Vector.<IListItemRenderer> = _local4.inactiveItemRenderers;
			_local4.inactiveItemRenderers = _local4.activeItemRenderers;
			_local4.activeItemRenderers = _local3;
			if(_local4.activeItemRenderers.length > 0) {
				throw new IllegalOperationError("ListDataViewPort: active renderers should be empty.");
			}
			if(itemRendererTypeIsInvalid) {
				this.recoverInactiveRenderers(_local4);
				this.freeInactiveRenderers(_local4,0);
				if(this._typicalItemRenderer && this._typicalItemRenderer.factoryID === factoryID) {
					if(this._typicalItemIsInDataProvider) {
						delete this._rendererMap[this._typicalItemRenderer.data];
					}
					this.destroyRenderer(this._typicalItemRenderer);
					this._typicalItemRenderer = null;
					this._typicalItemIsInDataProvider = false;
				}
			}
			this._layoutItems.length = 0;
		}
		
		private function refreshRenderers() : void {
			var _local6:ItemRendererFactoryStorage = null;
			var _local2:* = undefined;
			var _local5:* = undefined;
			var _local4:int = 0;
			var _local1:int = 0;
			if(this._typicalItemRenderer) {
				if(this._typicalItemIsInDataProvider) {
					_local6 = this.factoryIDToStorage(this._typicalItemRenderer.factoryID);
					_local2 = _local6.inactiveItemRenderers;
					_local5 = _local6.activeItemRenderers;
					_local4 = int(_local2.indexOf(this._typicalItemRenderer));
					if(_local4 >= 0) {
						_local2[_local4] = null;
					}
					_local1 = int(_local5.length);
					if(_local1 === 0) {
						_local5[_local1] = this._typicalItemRenderer;
					}
				}
				this.refreshOneItemRendererStyles(this._typicalItemRenderer);
			}
			this.findUnrenderedData();
			this.recoverInactiveRenderers(this._defaultStorage);
			if(this._storageMap) {
				for(var _local3 in this._storageMap) {
					_local6 = ItemRendererFactoryStorage(this._storageMap[_local3]);
					this.recoverInactiveRenderers(_local6);
				}
			}
			this.renderUnrenderedData();
			this.freeInactiveRenderers(this._defaultStorage,this._minimumItemCount);
			if(this._storageMap) {
				for(_local3 in this._storageMap) {
					_local6 = ItemRendererFactoryStorage(this._storageMap[_local3]);
					this.freeInactiveRenderers(_local6,1);
				}
			}
			this._updateForDataReset = false;
		}
		
		private function findUnrenderedData() : void {
			var _local19:* = 0;
			var _local16:* = 0;
			var _local7:int = 0;
			var _local8:int = 0;
			var _local11:int = 0;
			var _local14:int = 0;
			var _local15:ITrimmedVirtualLayout = null;
			var _local3:Object = null;
			var _local1:IListItemRenderer = null;
			var _local10:ItemRendererFactoryStorage = null;
			var _local9:* = undefined;
			var _local17:* = undefined;
			var _local5:int = 0;
			var _local12:int = int(!!this._dataProvider ? this._dataProvider.length : 0);
			var _local13:IVirtualLayout = this._layout as IVirtualLayout;
			var _local18:Boolean = _local13 && _local13.useVirtualLayout;
			if(_local18) {
				_local13.measureViewPort(_local12,this._viewPortBounds,HELPER_POINT);
				_local13.getVisibleIndicesAtScrollPosition(this._horizontalScrollPosition,this._verticalScrollPosition,HELPER_POINT.x,HELPER_POINT.y,_local12,HELPER_VECTOR);
			}
			var _local6:int = int(_local18 ? HELPER_VECTOR.length : _local12);
			if(_local18 && this._typicalItemIsInDataProvider && this._typicalItemRenderer && HELPER_VECTOR.indexOf(this._typicalItemRenderer.index) >= 0) {
				this._minimumItemCount = _local6 + 1;
			} else {
				this._minimumItemCount = _local6;
			}
			var _local2:Boolean = this._layout is ITrimmedVirtualLayout && _local18 && (!(this._layout is IVariableVirtualLayout) || !IVariableVirtualLayout(this._layout).hasVariableItemDimensions) && _local6 > 0;
			if(_local2) {
				_local16 = _local19 = HELPER_VECTOR[0];
				_local7 = 1;
				while(_local7 < _local6) {
					_local8 = HELPER_VECTOR[_local7];
					if(_local8 < _local19) {
						_local19 = _local8;
					}
					if(_local8 > _local16) {
						_local16 = _local8;
					}
					_local7++;
				}
				_local11 = _local19 - 1;
				if(_local11 < 0) {
					_local11 = 0;
				}
				_local14 = _local12 - 1 - _local16;
				_local15 = ITrimmedVirtualLayout(this._layout);
				_local15.beforeVirtualizedItemCount = _local11;
				_local15.afterVirtualizedItemCount = _local14;
				this._layoutItems.length = _local12 - _local11 - _local14;
				this._layoutIndexOffset = -_local11;
			} else {
				this._layoutIndexOffset = 0;
				this._layoutItems.length = _local12;
			}
			var _local4:int = int(this._unrenderedData.length);
			_local7 = 0;
			while(_local7 < _local6) {
				_local8 = _local18 ? HELPER_VECTOR[_local7] : _local7;
				if(!(_local8 < 0 || _local8 >= _local12)) {
					_local3 = this._dataProvider.getItemAt(_local8);
					_local1 = IListItemRenderer(this._rendererMap[_local3]);
					if(_local1) {
						_local1.index = _local8;
						_local1.visible = true;
						if(this._updateForDataReset) {
							_local1.data = null;
							_local1.data = _local3;
						}
						if(this._typicalItemRenderer != _local1) {
							_local10 = this.factoryIDToStorage(_local1.factoryID);
							_local9 = _local10.activeItemRenderers;
							_local17 = _local10.inactiveItemRenderers;
							_local9[_local9.length] = _local1;
							_local5 = int(_local17.indexOf(_local1));
							if(_local5 < 0) {
								throw new IllegalOperationError("ListDataViewPort: renderer map contains bad data. This may be caused by duplicate items in the data provider, which is not allowed.");
							}
							_local17[_local5] = null;
						}
						this._layoutItems[_local8 + this._layoutIndexOffset] = DisplayObject(_local1);
					} else {
						this._unrenderedData[_local4] = _local3;
						_local4++;
					}
				}
				_local7++;
			}
			if(this._typicalItemRenderer) {
				if(_local18 && this._typicalItemIsInDataProvider) {
					_local8 = int(HELPER_VECTOR.indexOf(this._typicalItemRenderer.index));
					if(_local8 >= 0) {
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
		
		private function renderUnrenderedData() : void {
			var _local3:int = 0;
			var _local1:Object = null;
			var _local4:int = 0;
			var _local2:IListItemRenderer = null;
			var _local5:int = int(this._unrenderedData.length);
			_local3 = 0;
			while(_local3 < _local5) {
				_local1 = this._unrenderedData.shift();
				_local4 = this._dataProvider.getItemIndex(_local1);
				_local2 = this.createRenderer(_local1,_local4,true,false);
				_local2.visible = true;
				this._layoutItems[_local4 + this._layoutIndexOffset] = DisplayObject(_local2);
				_local3++;
			}
		}
		
		private function recoverInactiveRenderers(storage:ItemRendererFactoryStorage) : void {
			var _local4:int = 0;
			var _local2:IListItemRenderer = null;
			var _local3:Vector.<IListItemRenderer> = storage.inactiveItemRenderers;
			var _local5:int = int(_local3.length);
			_local4 = 0;
			while(_local4 < _local5) {
				_local2 = _local3[_local4];
				if(!(!_local2 || _local2.index < 0)) {
					this._owner.dispatchEventWith("rendererRemove",false,_local2);
					delete this._rendererMap[_local2.data];
				}
				_local4++;
			}
		}
		
		private function freeInactiveRenderers(storage:ItemRendererFactoryStorage, minimumItemCount:int) : void {
			var _local8:int = 0;
			var _local3:IListItemRenderer = null;
			var _local5:Vector.<IListItemRenderer> = storage.inactiveItemRenderers;
			var _local7:Vector.<IListItemRenderer> = storage.activeItemRenderers;
			var _local6:int = int(_local7.length);
			var _local9:int = int(_local5.length);
			var _local4:* = minimumItemCount - _local6;
			if(_local4 > _local9) {
				_local4 = _local9;
			}
			_local8 = 0;
			while(_local8 < _local4) {
				_local3 = _local5.shift();
				if(!_local3) {
					_local4++;
					if(_local9 < _local4) {
						_local4 = _local9;
					}
				} else {
					_local3.data = null;
					_local3.index = -1;
					_local3.visible = false;
					_local7[_local6] = _local3;
					_local6++;
				}
				_local8++;
			}
			_local9 -= _local4;
			_local8 = 0;
			while(_local8 < _local9) {
				_local3 = _local5.shift();
				if(_local3) {
					this.destroyRenderer(_local3);
				}
				_local8++;
			}
		}
		
		private function createRenderer(item:Object, index:int, useCache:Boolean, isTemporary:Boolean) : IListItemRenderer {
			var _local5:IListItemRenderer = null;
			var _local6:String = null;
			if(this._factoryIDFunction !== null) {
				_local6 = this.getFactoryID(item,index);
			}
			var _local9:Function = this.factoryIDToFactory(_local6);
			var _local10:ItemRendererFactoryStorage = this.factoryIDToStorage(_local6);
			var _local7:Vector.<IListItemRenderer> = _local10.inactiveItemRenderers;
			var _local8:Vector.<IListItemRenderer> = _local10.activeItemRenderers;
			do {
				if(!useCache || isTemporary || _local7.length === 0) {
					if(_local9 !== null) {
						_local5 = IListItemRenderer(_local9());
					} else {
						_local5 = IListItemRenderer(new this._itemRendererType());
					}
					if(this._customItemRendererStyleName && this._customItemRendererStyleName.length > 0) {
						_local5.styleNameList.add(this._customItemRendererStyleName);
					}
					this.addChild(DisplayObject(_local5));
				} else {
					_local5 = _local7.shift();
				}
			}
			while(!_local5);
			
			_local5.data = item;
			_local5.index = index;
			_local5.owner = this._owner;
			_local5.factoryID = _local6;
			if(!isTemporary) {
				this._rendererMap[item] = _local5;
				_local8[_local8.length] = _local5;
				_local5.addEventListener("triggered",renderer_triggeredHandler);
				_local5.addEventListener("change",renderer_changeHandler);
				_local5.addEventListener("resize",renderer_resizeHandler);
				this._owner.dispatchEventWith("rendererAdd",false,_local5);
			}
			return _local5;
		}
		
		private function destroyRenderer(renderer:IListItemRenderer) : void {
			renderer.removeEventListener("triggered",renderer_triggeredHandler);
			renderer.removeEventListener("change",renderer_changeHandler);
			renderer.removeEventListener("resize",renderer_resizeHandler);
			renderer.owner = null;
			renderer.data = null;
			renderer.factoryID = null;
			this.removeChild(DisplayObject(renderer),true);
		}
		
		private function getFactoryID(item:Object, index:int) : String {
			if(this._factoryIDFunction === null) {
				return null;
			}
			if(this._factoryIDFunction.length === 1) {
				return this._factoryIDFunction(item);
			}
			return this._factoryIDFunction(item,index);
		}
		
		private function factoryIDToFactory(id:String) : Function {
			if(id !== null) {
				if(id in this._itemRendererFactories) {
					return this._itemRendererFactories[id] as Function;
				}
				throw new ReferenceError("Cannot find item renderer factory for ID \"" + id + "\".");
			}
			return this._itemRendererFactory;
		}
		
		private function factoryIDToStorage(id:String) : ItemRendererFactoryStorage {
			var _local2:ItemRendererFactoryStorage = null;
			if(id !== null) {
				if(id in this._storageMap) {
					return ItemRendererFactoryStorage(this._storageMap[id]);
				}
				_local2 = new ItemRendererFactoryStorage();
				this._storageMap[id] = _local2;
				return _local2;
			}
			return this._defaultStorage;
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
		
		private function dataProvider_addItemHandler(event:Event, index:int) : void {
			var _local3:IVariableVirtualLayout = this._layout as IVariableVirtualLayout;
			if(!_local3 || !_local3.hasVariableItemDimensions) {
				return;
			}
			_local3.addToVariableVirtualCacheAtIndex(index);
		}
		
		private function dataProvider_removeItemHandler(event:Event, index:int) : void {
			var _local3:IVariableVirtualLayout = this._layout as IVariableVirtualLayout;
			if(!_local3 || !_local3.hasVariableItemDimensions) {
				return;
			}
			_local3.removeFromVariableVirtualCacheAtIndex(index);
		}
		
		private function dataProvider_replaceItemHandler(event:Event, index:int) : void {
			var _local3:IVariableVirtualLayout = this._layout as IVariableVirtualLayout;
			if(!_local3 || !_local3.hasVariableItemDimensions) {
				return;
			}
			_local3.resetVariableVirtualCacheAtIndex(index);
		}
		
		private function dataProvider_resetHandler(event:Event) : void {
			this._updateForDataReset = true;
			var _local2:IVariableVirtualLayout = this._layout as IVariableVirtualLayout;
			if(!_local2 || !_local2.hasVariableItemDimensions) {
				return;
			}
			_local2.resetVariableVirtualCache();
		}
		
		private function dataProvider_updateItemHandler(event:Event, index:int) : void {
			var _local3:Object = this._dataProvider.getItemAt(index);
			var _local4:IListItemRenderer = IListItemRenderer(this._rendererMap[_local3]);
			if(!_local4) {
				return;
			}
			_local4.data = null;
			_local4.data = _local3;
		}
		
		private function dataProvider_updateAllHandler(event:Event) : void {
			var _local3:IListItemRenderer = null;
			for(var _local2 in this._rendererMap) {
				_local3 = IListItemRenderer(this._rendererMap[_local2]);
				if(!_local3) {
					return;
				}
				_local3.data = null;
				_local3.data = _local2;
			}
		}
		
		private function layout_changeHandler(event:Event) : void {
			if(this._ignoreLayoutChanges) {
				return;
			}
			this.invalidate("layout");
			this.invalidateParent("layout");
		}
		
		private function renderer_resizeHandler(event:Event) : void {
			if(this._ignoreRendererResizing) {
				return;
			}
			this.invalidate("layout");
			this.invalidateParent("layout");
			if(event.currentTarget === this._typicalItemRenderer && !this._typicalItemIsInDataProvider) {
				return;
			}
			var _local2:IVariableVirtualLayout = this._layout as IVariableVirtualLayout;
			if(!_local2 || !_local2.hasVariableItemDimensions) {
				return;
			}
			var _local3:IListItemRenderer = IListItemRenderer(event.currentTarget);
			_local2.resetVariableVirtualCacheAtIndex(_local3.index,DisplayObject(_local3));
		}
		
		private function renderer_triggeredHandler(event:Event) : void {
			var _local2:IListItemRenderer = IListItemRenderer(event.currentTarget);
			this.parent.dispatchEventWith("triggered",false,_local2.data);
		}
		
		private function renderer_changeHandler(event:Event) : void {
			var _local4:int = 0;
			if(this._ignoreSelectionChanges) {
				return;
			}
			var _local2:IListItemRenderer = IListItemRenderer(event.currentTarget);
			if(!this._isSelectable || this._isScrolling) {
				_local2.isSelected = false;
				return;
			}
			var _local3:Boolean = Boolean(_local2.isSelected);
			var _local5:int = _local2.index;
			if(this._allowMultipleSelection) {
				_local4 = this._selectedIndices.getItemIndex(_local5);
				if(_local3 && _local4 < 0) {
					this._selectedIndices.addItem(_local5);
				} else if(!_local3 && _local4 >= 0) {
					this._selectedIndices.removeItemAt(_local4);
				}
			} else if(_local3) {
				this._selectedIndices.data = new <int>[_local5];
			} else {
				this._selectedIndices.removeAll();
			}
		}
		
		private function selectedIndices_changeHandler(event:Event) : void {
			this.invalidate("selected");
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

import feathers.controls.renderers.IListItemRenderer;

class ItemRendererFactoryStorage {
	public var activeItemRenderers:Vector.<IListItemRenderer> = new Vector.<IListItemRenderer>(0);
	
	public var inactiveItemRenderers:Vector.<IListItemRenderer> = new Vector.<IListItemRenderer>(0);
	
	public function ItemRendererFactoryStorage() {
		super();
	}
}
