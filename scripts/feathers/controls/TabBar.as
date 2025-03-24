package feathers.controls {
	import feathers.core.FeathersControl;
	import feathers.core.IFocusDisplayObject;
	import feathers.core.PropertyProxy;
	import feathers.core.ToggleGroup;
	import feathers.data.ListCollection;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.LayoutBoundsResult;
	import feathers.layout.VerticalLayout;
	import feathers.layout.ViewPortBounds;
	import feathers.skins.IStyleProvider;
	import flash.utils.Dictionary;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	
	public class TabBar extends FeathersControl implements IFocusDisplayObject {
		protected static const INVALIDATION_FLAG_TAB_FACTORY:String = "tabFactory";
		
		protected static const LABEL_FIELD:String = "label";
		
		protected static const ENABLED_FIELD:String = "isEnabled";
		
		public static const DIRECTION_HORIZONTAL:String = "horizontal";
		
		public static const DIRECTION_VERTICAL:String = "vertical";
		
		public static const HORIZONTAL_ALIGN_LEFT:String = "left";
		
		public static const HORIZONTAL_ALIGN_CENTER:String = "center";
		
		public static const HORIZONTAL_ALIGN_RIGHT:String = "right";
		
		public static const HORIZONTAL_ALIGN_JUSTIFY:String = "justify";
		
		public static const VERTICAL_ALIGN_TOP:String = "top";
		
		public static const VERTICAL_ALIGN_MIDDLE:String = "middle";
		
		public static const VERTICAL_ALIGN_BOTTOM:String = "bottom";
		
		public static const VERTICAL_ALIGN_JUSTIFY:String = "justify";
		
		public static const DEFAULT_CHILD_STYLE_NAME_TAB:String = "feathers-tab-bar-tab";
		
		public static var globalStyleProvider:IStyleProvider;
		
		private static const DEFAULT_TAB_FIELDS:Vector.<String> = new <String>["defaultIcon","upIcon","downIcon","hoverIcon","disabledIcon","defaultSelectedIcon","selectedUpIcon","selectedDownIcon","selectedHoverIcon","selectedDisabledIcon","name"];
		
		protected var tabStyleName:String = "feathers-tab-bar-tab";
		
		protected var firstTabStyleName:String = "feathers-tab-bar-tab";
		
		protected var lastTabStyleName:String = "feathers-tab-bar-tab";
		
		protected var toggleGroup:ToggleGroup;
		
		protected var activeFirstTab:ToggleButton;
		
		protected var inactiveFirstTab:ToggleButton;
		
		protected var activeLastTab:ToggleButton;
		
		protected var inactiveLastTab:ToggleButton;
		
		protected var _layoutItems:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
		
		protected var activeTabs:Vector.<ToggleButton> = new Vector.<ToggleButton>(0);
		
		protected var inactiveTabs:Vector.<ToggleButton> = new Vector.<ToggleButton>(0);
		
		protected var _tabToItem:Dictionary = new Dictionary(true);
		
		protected var _dataProvider:ListCollection;
		
		protected var verticalLayout:VerticalLayout;
		
		protected var horizontalLayout:HorizontalLayout;
		
		protected var _viewPortBounds:ViewPortBounds = new ViewPortBounds();
		
		protected var _layoutResult:LayoutBoundsResult = new LayoutBoundsResult();
		
		protected var _direction:String = "horizontal";
		
		protected var _horizontalAlign:String = "justify";
		
		protected var _verticalAlign:String = "justify";
		
		protected var _distributeTabSizes:Boolean = true;
		
		protected var _gap:Number = 0;
		
		protected var _firstGap:Number = NaN;
		
		protected var _lastGap:Number = NaN;
		
		protected var _paddingTop:Number = 0;
		
		protected var _paddingRight:Number = 0;
		
		protected var _paddingBottom:Number = 0;
		
		protected var _paddingLeft:Number = 0;
		
		protected var _tabFactory:Function = defaultTabFactory;
		
		protected var _firstTabFactory:Function;
		
		protected var _lastTabFactory:Function;
		
		protected var _tabInitializer:Function;
		
		protected var _tabReleaser:Function;
		
		protected var _ignoreSelectionChanges:Boolean = false;
		
		protected var _selectedIndex:int = -1;
		
		protected var _customTabStyleName:String;
		
		protected var _customFirstTabStyleName:String;
		
		protected var _customLastTabStyleName:String;
		
		protected var _tabProperties:PropertyProxy;
		
		protected var _focusedTabIndex:int = -1;
		
		public function TabBar() {
			_tabInitializer = defaultTabInitializer;
			_tabReleaser = defaultTabReleaser;
			super();
		}
		
		protected static function defaultTabFactory() : ToggleButton {
			return new ToggleButton();
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return TabBar.globalStyleProvider;
		}
		
		public function get dataProvider() : ListCollection {
			return this._dataProvider;
		}
		
		public function set dataProvider(value:ListCollection) : void {
			if(this._dataProvider == value) {
				return;
			}
			var _local3:int = this.selectedIndex;
			var _local2:Object = this.selectedItem;
			if(this._dataProvider) {
				this._dataProvider.removeEventListener("addItem",dataProvider_addItemHandler);
				this._dataProvider.removeEventListener("removeItem",dataProvider_removeItemHandler);
				this._dataProvider.removeEventListener("replaceItem",dataProvider_replaceItemHandler);
				this._dataProvider.removeEventListener("updateItem",dataProvider_updateItemHandler);
				this._dataProvider.removeEventListener("updateAll",dataProvider_updateAllHandler);
				this._dataProvider.removeEventListener("reset",dataProvider_resetHandler);
			}
			this._dataProvider = value;
			if(this._dataProvider) {
				this._dataProvider.addEventListener("addItem",dataProvider_addItemHandler);
				this._dataProvider.addEventListener("removeItem",dataProvider_removeItemHandler);
				this._dataProvider.addEventListener("replaceItem",dataProvider_replaceItemHandler);
				this._dataProvider.addEventListener("updateItem",dataProvider_updateItemHandler);
				this._dataProvider.addEventListener("updateAll",dataProvider_updateAllHandler);
				this._dataProvider.addEventListener("reset",dataProvider_resetHandler);
			}
			if(!this._dataProvider || this._dataProvider.length == 0) {
				this.selectedIndex = -1;
			} else {
				this.selectedIndex = 0;
			}
			if(this.selectedIndex == _local3 && this.selectedItem != _local2) {
				this.dispatchEventWith("change");
			}
			this.invalidate("data");
		}
		
		public function get direction() : String {
			return this._direction;
		}
		
		public function set direction(value:String) : void {
			if(this._direction == value) {
				return;
			}
			this._direction = value;
			this.invalidate("styles");
		}
		
		public function get horizontalAlign() : String {
			return this._horizontalAlign;
		}
		
		public function set horizontalAlign(value:String) : void {
			if(this._horizontalAlign == value) {
				return;
			}
			this._horizontalAlign = value;
			this.invalidate("styles");
		}
		
		public function get verticalAlign() : String {
			return this._verticalAlign;
		}
		
		public function set verticalAlign(value:String) : void {
			if(this._verticalAlign == value) {
				return;
			}
			this._verticalAlign = value;
			this.invalidate("styles");
		}
		
		public function get distributeTabSizes() : Boolean {
			return this._distributeTabSizes;
		}
		
		public function set distributeTabSizes(value:Boolean) : void {
			if(this._distributeTabSizes == value) {
				return;
			}
			this._distributeTabSizes = value;
			this.invalidate("styles");
		}
		
		public function get gap() : Number {
			return this._gap;
		}
		
		public function set gap(value:Number) : void {
			if(this._gap == value) {
				return;
			}
			this._gap = value;
			this.invalidate("styles");
		}
		
		public function get firstGap() : Number {
			return this._firstGap;
		}
		
		public function set firstGap(value:Number) : void {
			if(this._firstGap == value) {
				return;
			}
			this._firstGap = value;
			this.invalidate("styles");
		}
		
		public function get lastGap() : Number {
			return this._lastGap;
		}
		
		public function set lastGap(value:Number) : void {
			if(this._lastGap == value) {
				return;
			}
			this._lastGap = value;
			this.invalidate("styles");
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
		
		public function get tabFactory() : Function {
			return this._tabFactory;
		}
		
		public function set tabFactory(value:Function) : void {
			if(this._tabFactory == value) {
				return;
			}
			this._tabFactory = value;
			this.invalidate("tabFactory");
		}
		
		public function get firstTabFactory() : Function {
			return this._firstTabFactory;
		}
		
		public function set firstTabFactory(value:Function) : void {
			if(this._firstTabFactory == value) {
				return;
			}
			this._firstTabFactory = value;
			this.invalidate("tabFactory");
		}
		
		public function get lastTabFactory() : Function {
			return this._lastTabFactory;
		}
		
		public function set lastTabFactory(value:Function) : void {
			if(this._lastTabFactory == value) {
				return;
			}
			this._lastTabFactory = value;
			this.invalidate("tabFactory");
		}
		
		public function get tabInitializer() : Function {
			return this._tabInitializer;
		}
		
		public function set tabInitializer(value:Function) : void {
			if(this._tabInitializer == value) {
				return;
			}
			this._tabInitializer = value;
			this.invalidate("data");
		}
		
		public function get tabReleaser() : Function {
			return this._tabReleaser;
		}
		
		public function set tabReleaser(value:Function) : void {
			if(this._tabReleaser == value) {
				return;
			}
			this._tabReleaser = value;
			this.invalidate("data");
		}
		
		public function get selectedIndex() : int {
			return this._selectedIndex;
		}
		
		public function set selectedIndex(value:int) : void {
			if(this._selectedIndex == value) {
				return;
			}
			this._selectedIndex = value;
			this.invalidate("selected");
			this.dispatchEventWith("change");
		}
		
		public function get selectedItem() : Object {
			var _local1:int = this.selectedIndex;
			if(!this._dataProvider || _local1 < 0 || _local1 >= this._dataProvider.length) {
				return null;
			}
			return this._dataProvider.getItemAt(_local1);
		}
		
		public function set selectedItem(value:Object) : void {
			if(!this._dataProvider) {
				this.selectedIndex = -1;
				return;
			}
			this.selectedIndex = this._dataProvider.getItemIndex(value);
		}
		
		public function get customTabStyleName() : String {
			return this._customTabStyleName;
		}
		
		public function set customTabStyleName(value:String) : void {
			if(this._customTabStyleName == value) {
				return;
			}
			this._customTabStyleName = value;
			this.invalidate("tabFactory");
		}
		
		public function get customFirstTabStyleName() : String {
			return this._customFirstTabStyleName;
		}
		
		public function set customFirstTabStyleName(value:String) : void {
			if(this._customFirstTabStyleName == value) {
				return;
			}
			this._customFirstTabStyleName = value;
			this.invalidate("tabFactory");
		}
		
		public function get customLastTabStyleName() : String {
			return this._customLastTabStyleName;
		}
		
		public function set customLastTabStyleName(value:String) : void {
			if(this._customLastTabStyleName == value) {
				return;
			}
			this._customLastTabStyleName = value;
			this.invalidate("tabFactory");
		}
		
		public function get tabProperties() : Object {
			if(!this._tabProperties) {
				this._tabProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._tabProperties;
		}
		
		public function set tabProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._tabProperties == value) {
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
			if(this._tabProperties) {
				this._tabProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._tabProperties = PropertyProxy(value);
			if(this._tabProperties) {
				this._tabProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get baseline() : Number {
			if(!this.activeTabs || this.activeTabs.length === 0) {
				return this.scaledActualHeight;
			}
			var _local1:ToggleButton = this.activeTabs[0];
			return this.scaleY * (_local1.y + _local1.baseline);
		}
		
		override public function dispose() : void {
			this._selectedIndex = -1;
			this.dataProvider = null;
			super.dispose();
		}
		
		override protected function initialize() : void {
			this.toggleGroup = new ToggleGroup();
			this.toggleGroup.isSelectionRequired = true;
			this.toggleGroup.addEventListener("change",toggleGroup_changeHandler);
		}
		
		override protected function draw() : void {
			var _local5:Boolean = this.isInvalid("data");
			var _local6:Boolean = this.isInvalid("styles");
			var _local3:Boolean = this.isInvalid("state");
			var _local4:Boolean = this.isInvalid("selected");
			var _local1:Boolean = this.isInvalid("tabFactory");
			var _local2:Boolean = this.isInvalid("size");
			if(_local5 || _local1 || _local3) {
				this.refreshTabs(_local1);
			}
			if(_local5 || _local1 || _local6) {
				this.refreshTabStyles();
			}
			if(_local5 || _local1 || _local4) {
				this.commitSelection();
			}
			if(_local5 || _local1 || _local3) {
				this.commitEnabled();
			}
			if(_local6) {
				this.refreshLayoutStyles();
			}
			this.layoutTabs();
		}
		
		protected function commitSelection() : void {
			this.toggleGroup.selectedIndex = this._selectedIndex;
		}
		
		protected function commitEnabled() : void {
			for each(var _local1 in this.activeTabs) {
				_local1.isEnabled &&= this._isEnabled;
			}
		}
		
		protected function refreshTabStyles() : void {
			var _local3:Object = null;
			for(var _local2 in this._tabProperties) {
				_local3 = this._tabProperties[_local2];
				for each(var _local1 in this.activeTabs) {
					_local1[_local2] = _local3;
				}
			}
		}
		
		protected function refreshLayoutStyles() : void {
			if(this._direction == "vertical") {
				if(this.horizontalLayout) {
					this.horizontalLayout = null;
				}
				if(!this.verticalLayout) {
					this.verticalLayout = new VerticalLayout();
					this.verticalLayout.useVirtualLayout = false;
				}
				this.verticalLayout.distributeHeights = this._distributeTabSizes;
				this.verticalLayout.horizontalAlign = this._horizontalAlign;
				this.verticalLayout.verticalAlign = this._verticalAlign == "justify" ? "top" : this._verticalAlign;
				this.verticalLayout.gap = this._gap;
				this.verticalLayout.firstGap = this._firstGap;
				this.verticalLayout.lastGap = this._lastGap;
				this.verticalLayout.paddingTop = this._paddingTop;
				this.verticalLayout.paddingRight = this._paddingRight;
				this.verticalLayout.paddingBottom = this._paddingBottom;
				this.verticalLayout.paddingLeft = this._paddingLeft;
			} else {
				if(this.verticalLayout) {
					this.verticalLayout = null;
				}
				if(!this.horizontalLayout) {
					this.horizontalLayout = new HorizontalLayout();
					this.horizontalLayout.useVirtualLayout = false;
				}
				this.horizontalLayout.distributeWidths = this._distributeTabSizes;
				this.horizontalLayout.horizontalAlign = this._horizontalAlign == "justify" ? "left" : this._horizontalAlign;
				this.horizontalLayout.verticalAlign = this._verticalAlign;
				this.horizontalLayout.gap = this._gap;
				this.horizontalLayout.firstGap = this._firstGap;
				this.horizontalLayout.lastGap = this._lastGap;
				this.horizontalLayout.paddingTop = this._paddingTop;
				this.horizontalLayout.paddingRight = this._paddingRight;
				this.horizontalLayout.paddingBottom = this._paddingBottom;
				this.horizontalLayout.paddingLeft = this._paddingLeft;
			}
		}
		
		protected function defaultTabInitializer(tab:ToggleButton, item:Object) : void {
			if(item is Object) {
				if(item.hasOwnProperty("label")) {
					tab.label = item.label;
				} else {
					tab.label = item.toString();
				}
				if(item.hasOwnProperty("isEnabled")) {
					tab.isEnabled = item.isEnabled as Boolean;
				} else {
					tab.isEnabled = this._isEnabled;
				}
				for each(var _local3 in DEFAULT_TAB_FIELDS) {
					if(item.hasOwnProperty(_local3)) {
						tab[_local3] = item[_local3];
					}
				}
			} else {
				tab.label = "";
				tab.isEnabled = this._isEnabled;
			}
		}
		
		protected function defaultTabReleaser(tab:ToggleButton, oldItem:Object) : void {
			tab.label = null;
			for each(var _local3 in DEFAULT_TAB_FIELDS) {
				if(oldItem.hasOwnProperty(_local3)) {
					tab[_local3] = null;
				}
			}
		}
		
		protected function refreshTabs(isFactoryInvalid:Boolean) : void {
			var _local5:int = 0;
			var _local3:Object = null;
			var _local4:* = null;
			var _local6:* = 0;
			var _local10:Boolean = this._ignoreSelectionChanges;
			this._ignoreSelectionChanges = true;
			var _local7:int = this.toggleGroup.selectedIndex;
			this.toggleGroup.removeAllItems();
			var _local2:Vector.<ToggleButton> = this.inactiveTabs;
			this.inactiveTabs = this.activeTabs;
			this.activeTabs = _local2;
			this.activeTabs.length = 0;
			this._layoutItems.length = 0;
			_local2 = null;
			if(isFactoryInvalid) {
				this.clearInactiveTabs();
			} else {
				if(this.activeFirstTab) {
					this.inactiveTabs.shift();
				}
				this.inactiveFirstTab = this.activeFirstTab;
				if(this.activeLastTab) {
					this.inactiveTabs.pop();
				}
				this.inactiveLastTab = this.activeLastTab;
			}
			this.activeFirstTab = null;
			this.activeLastTab = null;
			var _local9:int = 0;
			var _local11:int = int(!!this._dataProvider ? this._dataProvider.length : 0);
			var _local8:int = _local11 - 1;
			_local5 = 0;
			while(_local5 < _local11) {
				_local3 = this._dataProvider.getItemAt(_local5);
				if(_local5 == 0) {
					_local4 = this.activeFirstTab = this.createFirstTab(_local3);
				} else if(_local5 == _local8) {
					_local4 = this.activeLastTab = this.createLastTab(_local3);
				} else {
					_local4 = this.createTab(_local3);
				}
				this.toggleGroup.addItem(_local4);
				this.activeTabs[_local9] = _local4;
				this._layoutItems[_local9] = _local4;
				_local9++;
				_local5++;
			}
			this.clearInactiveTabs();
			this._ignoreSelectionChanges = _local10;
			if(_local7 >= 0) {
				_local6 = this.activeTabs.length - 1;
				if(_local7 < _local6) {
					_local6 = _local7;
				}
				this._ignoreSelectionChanges = _local7 == _local6;
				this.toggleGroup.selectedIndex = _local6;
				this._ignoreSelectionChanges = _local10;
			}
		}
		
		protected function clearInactiveTabs() : void {
			var _local2:int = 0;
			var _local1:ToggleButton = null;
			var _local3:int = int(this.inactiveTabs.length);
			_local2 = 0;
			while(_local2 < _local3) {
				_local1 = this.inactiveTabs.shift();
				this.destroyTab(_local1);
				_local2++;
			}
			if(this.inactiveFirstTab) {
				this.destroyTab(this.inactiveFirstTab);
				this.inactiveFirstTab = null;
			}
			if(this.inactiveLastTab) {
				this.destroyTab(this.inactiveLastTab);
				this.inactiveLastTab = null;
			}
		}
		
		protected function createFirstTab(item:Object) : ToggleButton {
			var _local3:ToggleButton = null;
			var _local2:Function = null;
			if(this.inactiveFirstTab !== null) {
				_local3 = this.inactiveFirstTab;
				this.releaseTab(_local3);
				this.inactiveFirstTab = null;
			} else {
				_local2 = this._firstTabFactory != null ? this._firstTabFactory : this._tabFactory;
				_local3 = ToggleButton(_local2());
				if(this._customFirstTabStyleName) {
					_local3.styleNameList.add(this._customFirstTabStyleName);
				} else if(this._customTabStyleName) {
					_local3.styleNameList.add(this._customTabStyleName);
				} else {
					_local3.styleNameList.add(this.firstTabStyleName);
				}
				_local3.isToggle = true;
				this.addChild(_local3);
			}
			this._tabInitializer(_local3,item);
			this._tabToItem[_local3] = item;
			return _local3;
		}
		
		protected function createLastTab(item:Object) : ToggleButton {
			var _local3:ToggleButton = null;
			var _local2:Function = null;
			if(this.inactiveLastTab !== null) {
				_local3 = this.inactiveLastTab;
				this.releaseTab(_local3);
				this.inactiveLastTab = null;
			} else {
				_local2 = this._lastTabFactory != null ? this._lastTabFactory : this._tabFactory;
				_local3 = ToggleButton(_local2());
				if(this._customLastTabStyleName) {
					_local3.styleNameList.add(this._customLastTabStyleName);
				} else if(this._customTabStyleName) {
					_local3.styleNameList.add(this._customTabStyleName);
				} else {
					_local3.styleNameList.add(this.lastTabStyleName);
				}
				_local3.isToggle = true;
				this.addChild(_local3);
			}
			this._tabInitializer(_local3,item);
			this._tabToItem[_local3] = item;
			return _local3;
		}
		
		protected function createTab(item:Object) : ToggleButton {
			var _local2:ToggleButton = null;
			if(this.inactiveTabs.length === 0) {
				_local2 = ToggleButton(this._tabFactory());
				if(this._customTabStyleName) {
					_local2.styleNameList.add(this._customTabStyleName);
				} else {
					_local2.styleNameList.add(this.tabStyleName);
				}
				_local2.isToggle = true;
				this.addChild(_local2);
			} else {
				_local2 = this.inactiveTabs.shift();
				this.releaseTab(_local2);
			}
			this._tabInitializer(_local2,item);
			this._tabToItem[_local2] = item;
			return _local2;
		}
		
		protected function releaseTab(tab:ToggleButton) : void {
			var _local2:Object = this._tabToItem[tab];
			delete this._tabToItem[tab];
			if(this._tabReleaser.length === 1) {
				this._tabReleaser(tab);
			} else {
				this._tabReleaser(tab,_local2);
			}
		}
		
		protected function destroyTab(tab:ToggleButton) : void {
			this.toggleGroup.removeItem(tab);
			this.releaseTab(tab);
			this.removeChild(tab,true);
		}
		
		protected function layoutTabs() : void {
			this._viewPortBounds.x = 0;
			this._viewPortBounds.y = 0;
			this._viewPortBounds.scrollX = 0;
			this._viewPortBounds.scrollY = 0;
			this._viewPortBounds.explicitWidth = this._explicitWidth;
			this._viewPortBounds.explicitHeight = this._explicitHeight;
			this._viewPortBounds.minWidth = this._explicitMinWidth;
			this._viewPortBounds.minHeight = this._explicitMinHeight;
			this._viewPortBounds.maxWidth = this._explicitMaxWidth;
			this._viewPortBounds.maxHeight = this._explicitMaxHeight;
			if(this.verticalLayout) {
				this.verticalLayout.layout(this._layoutItems,this._viewPortBounds,this._layoutResult);
			} else if(this.horizontalLayout) {
				this.horizontalLayout.layout(this._layoutItems,this._viewPortBounds,this._layoutResult);
			}
			var _local1:Number = this._layoutResult.contentWidth;
			var _local3:Number = this._layoutResult.contentHeight;
			this.saveMeasurements(_local1,_local3,_local1,_local3);
			for each(var _local2 in this.activeTabs) {
				_local2.validate();
			}
		}
		
		override public function showFocus() : void {
			if(!this._hasFocus) {
				return;
			}
			this._showFocus = true;
			this.showFocusedTab();
			this.invalidate("focus");
		}
		
		override public function hideFocus() : void {
			if(!this._hasFocus) {
				return;
			}
			this._showFocus = false;
			this.hideFocusedTab();
			this.invalidate("focus");
		}
		
		protected function hideFocusedTab() : void {
			if(this._focusedTabIndex < 0) {
				return;
			}
			var _local1:ToggleButton = this.activeTabs[this._focusedTabIndex];
			_local1.hideFocus();
		}
		
		protected function showFocusedTab() : void {
			if(!this._showFocus || this._focusedTabIndex < 0) {
				return;
			}
			var _local1:ToggleButton = this.activeTabs[this._focusedTabIndex];
			_local1.showFocus();
		}
		
		protected function focusedTabFocusIn() : void {
			if(this._focusedTabIndex < 0) {
				return;
			}
			var _local1:ToggleButton = this.activeTabs[this._focusedTabIndex];
			_local1.dispatchEventWith("focusIn");
		}
		
		protected function focusedTabFocusOut() : void {
			if(this._focusedTabIndex < 0) {
				return;
			}
			var _local1:ToggleButton = this.activeTabs[this._focusedTabIndex];
			_local1.dispatchEventWith("focusOut");
		}
		
		protected function childProperties_onChange(proxy:PropertyProxy, name:String) : void {
			this.invalidate("styles");
		}
		
		override protected function focusInHandler(event:Event) : void {
			super.focusInHandler(event);
			this._focusedTabIndex = this._selectedIndex;
			this.focusedTabFocusIn();
			this.stage.addEventListener("keyDown",stage_keyDownHandler);
		}
		
		override protected function focusOutHandler(event:Event) : void {
			super.focusOutHandler(event);
			this.hideFocusedTab();
			this.focusedTabFocusOut();
			this.stage.removeEventListener("keyDown",stage_keyDownHandler);
		}
		
		protected function stage_keyDownHandler(event:KeyboardEvent) : void {
			if(!this._isEnabled) {
				return;
			}
			if(!this._dataProvider || this._dataProvider.length === 0) {
				return;
			}
			var _local3:* = this._focusedTabIndex;
			var _local2:int = this._dataProvider.length - 1;
			if(event.keyCode == 36) {
				this.selectedIndex = _local3 = 0;
			} else if(event.keyCode == 35) {
				this.selectedIndex = _local3 = _local2;
			} else if(event.keyCode == 33) {
				_local3--;
				if(_local3 < 0) {
					_local3 = _local2;
				}
				this.selectedIndex = _local3;
			} else if(event.keyCode == 34) {
				_local3++;
				if(_local3 > _local2) {
					_local3 = 0;
				}
				this.selectedIndex = _local3;
			} else if(event.keyCode === 38 || event.keyCode === 37) {
				_local3--;
				if(_local3 < 0) {
					_local3 = _local2;
				}
			} else if(event.keyCode === 40 || event.keyCode === 39) {
				_local3++;
				if(_local3 > _local2) {
					_local3 = 0;
				}
			}
			if(_local3 >= 0 && _local3 !== this._focusedTabIndex) {
				this.hideFocusedTab();
				this.focusedTabFocusOut();
				this._focusedTabIndex = _local3;
				this.focusedTabFocusIn();
				this.showFocusedTab();
			}
		}
		
		protected function toggleGroup_changeHandler(event:Event) : void {
			if(this._ignoreSelectionChanges) {
				return;
			}
			this.selectedIndex = this.toggleGroup.selectedIndex;
		}
		
		protected function dataProvider_addItemHandler(event:Event, index:int) : void {
			if(this._selectedIndex >= index) {
				this.selectedIndex += 1;
				this.invalidate("selected");
			}
			this.invalidate("data");
		}
		
		protected function dataProvider_removeItemHandler(event:Event, index:int) : void {
			var _local4:int = 0;
			var _local5:* = 0;
			var _local3:int = 0;
			if(this._selectedIndex > index) {
				this.selectedIndex -= 1;
			} else if(this._selectedIndex == index) {
				_local5 = _local4 = this._selectedIndex;
				_local3 = this._dataProvider.length - 1;
				if(_local5 > _local3) {
					_local5 = _local3;
				}
				if(_local4 == _local5) {
					this.invalidate("selected");
					this.dispatchEventWith("change");
				} else {
					this.selectedIndex = _local5;
				}
			}
			this.invalidate("data");
		}
		
		protected function dataProvider_resetHandler(event:Event) : void {
			if(this._dataProvider.length > 0) {
				if(this._selectedIndex != 0) {
					this.selectedIndex = 0;
				} else {
					this.invalidate("selected");
					this.dispatchEventWith("change");
				}
			} else if(this._selectedIndex >= 0) {
				this.selectedIndex = -1;
			}
			this.invalidate("data");
		}
		
		protected function dataProvider_replaceItemHandler(event:Event, index:int) : void {
			if(this._selectedIndex == index) {
				this.invalidate("selected");
				this.dispatchEventWith("change");
			}
			this.invalidate("data");
		}
		
		protected function dataProvider_updateItemHandler(event:Event, index:int) : void {
			this.invalidate("data");
		}
		
		protected function dataProvider_updateAllHandler(event:Event) : void {
			this.invalidate("data");
		}
	}
}

