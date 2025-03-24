package feathers.controls {
	import feathers.controls.popups.CalloutPopUpContentManager;
	import feathers.controls.popups.DropDownPopUpContentManager;
	import feathers.controls.popups.IPersistentPopUpContentManager;
	import feathers.controls.popups.IPopUpContentManager;
	import feathers.controls.popups.IPopUpContentManagerWithPrompt;
	import feathers.controls.popups.VerticalCenteredPopUpContentManager;
	import feathers.core.FeathersControl;
	import feathers.core.IFocusDisplayObject;
	import feathers.core.IToggle;
	import feathers.core.PropertyProxy;
	import feathers.data.ListCollection;
	import feathers.skins.IStyleProvider;
	import feathers.system.DeviceCapabilities;
	import starling.core.Starling;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.utils.SystemUtil;
	
	public class PickerList extends FeathersControl implements IFocusDisplayObject {
		protected static const INVALIDATION_FLAG_BUTTON_FACTORY:String = "buttonFactory";
		
		protected static const INVALIDATION_FLAG_LIST_FACTORY:String = "listFactory";
		
		public static const DEFAULT_CHILD_STYLE_NAME_BUTTON:String = "feathers-picker-list-button";
		
		public static const DEFAULT_CHILD_STYLE_NAME_LIST:String = "feathers-picker-list-list";
		
		public static var globalStyleProvider:IStyleProvider;
		
		protected var buttonStyleName:String = "feathers-picker-list-button";
		
		protected var listStyleName:String = "feathers-picker-list-list";
		
		protected var button:Button;
		
		protected var list:List;
		
		protected var buttonExplicitWidth:Number;
		
		protected var buttonExplicitHeight:Number;
		
		protected var buttonExplicitMinWidth:Number;
		
		protected var buttonExplicitMinHeight:Number;
		
		protected var _dataProvider:ListCollection;
		
		protected var _ignoreSelectionChanges:Boolean = false;
		
		protected var _selectedIndex:int = -1;
		
		protected var _prompt:String;
		
		protected var _labelField:String = "label";
		
		protected var _labelFunction:Function;
		
		protected var _popUpContentManager:IPopUpContentManager;
		
		protected var _typicalItem:Object = null;
		
		protected var _buttonFactory:Function;
		
		protected var _customButtonStyleName:String;
		
		protected var _buttonProperties:PropertyProxy;
		
		protected var _listFactory:Function;
		
		protected var _customListStyleName:String;
		
		protected var _listProperties:PropertyProxy;
		
		protected var _toggleButtonOnOpenAndClose:Boolean = false;
		
		protected var _triggered:Boolean = false;
		
		protected var _isOpenListPending:Boolean = false;
		
		protected var _isCloseListPending:Boolean = false;
		
		protected var _buttonHasFocus:Boolean = false;
		
		protected var _buttonTouchPointID:int = -1;
		
		protected var _listIsOpenOnTouchBegan:Boolean = false;
		
		public function PickerList() {
			super();
		}
		
		protected static function defaultButtonFactory() : Button {
			return new Button();
		}
		
		protected static function defaultListFactory() : List {
			return new List();
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return PickerList.globalStyleProvider;
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
				this._dataProvider.removeEventListener("reset",dataProvider_multipleEventHandler);
				this._dataProvider.removeEventListener("addItem",dataProvider_multipleEventHandler);
				this._dataProvider.removeEventListener("removeItem",dataProvider_multipleEventHandler);
				this._dataProvider.removeEventListener("replaceItem",dataProvider_multipleEventHandler);
				this._dataProvider.removeEventListener("updateItem",dataProvider_updateItemHandler);
			}
			this._dataProvider = value;
			if(this._dataProvider) {
				this._dataProvider.addEventListener("reset",dataProvider_multipleEventHandler);
				this._dataProvider.addEventListener("addItem",dataProvider_multipleEventHandler);
				this._dataProvider.addEventListener("removeItem",dataProvider_multipleEventHandler);
				this._dataProvider.addEventListener("replaceItem",dataProvider_multipleEventHandler);
				this._dataProvider.addEventListener("updateItem",dataProvider_updateItemHandler);
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
		
		public function get prompt() : String {
			return this._prompt;
		}
		
		public function set prompt(value:String) : void {
			if(this._prompt == value) {
				return;
			}
			this._prompt = value;
			this.invalidate("selected");
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
			this._labelFunction = value;
			this.invalidate("data");
		}
		
		public function get popUpContentManager() : IPopUpContentManager {
			return this._popUpContentManager;
		}
		
		public function set popUpContentManager(value:IPopUpContentManager) : void {
			var _local2:EventDispatcher = null;
			if(this._popUpContentManager == value) {
				return;
			}
			if(this._popUpContentManager is EventDispatcher) {
				_local2 = EventDispatcher(this._popUpContentManager);
				_local2.removeEventListener("open",popUpContentManager_openHandler);
				_local2.removeEventListener("close",popUpContentManager_closeHandler);
			}
			this._popUpContentManager = value;
			if(this._popUpContentManager is EventDispatcher) {
				_local2 = EventDispatcher(this._popUpContentManager);
				_local2.addEventListener("open",popUpContentManager_openHandler);
				_local2.addEventListener("close",popUpContentManager_closeHandler);
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
			this.invalidate("styles");
		}
		
		public function get buttonFactory() : Function {
			return this._buttonFactory;
		}
		
		public function set buttonFactory(value:Function) : void {
			if(this._buttonFactory == value) {
				return;
			}
			this._buttonFactory = value;
			this.invalidate("buttonFactory");
		}
		
		public function get customButtonStyleName() : String {
			return this._customButtonStyleName;
		}
		
		public function set customButtonStyleName(value:String) : void {
			if(this._customButtonStyleName == value) {
				return;
			}
			this._customButtonStyleName = value;
			this.invalidate("buttonFactory");
		}
		
		public function get buttonProperties() : Object {
			if(!this._buttonProperties) {
				this._buttonProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._buttonProperties;
		}
		
		public function set buttonProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._buttonProperties == value) {
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
			if(this._buttonProperties) {
				this._buttonProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._buttonProperties = PropertyProxy(value);
			if(this._buttonProperties) {
				this._buttonProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get listFactory() : Function {
			return this._listFactory;
		}
		
		public function set listFactory(value:Function) : void {
			if(this._listFactory == value) {
				return;
			}
			this._listFactory = value;
			this.invalidate("listFactory");
		}
		
		public function get customListStyleName() : String {
			return this._customListStyleName;
		}
		
		public function set customListStyleName(value:String) : void {
			if(this._customListStyleName == value) {
				return;
			}
			this._customListStyleName = value;
			this.invalidate("listFactory");
		}
		
		public function get listProperties() : Object {
			if(!this._listProperties) {
				this._listProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._listProperties;
		}
		
		public function set listProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._listProperties == value) {
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
			if(this._listProperties) {
				this._listProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._listProperties = PropertyProxy(value);
			if(this._listProperties) {
				this._listProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get toggleButtonOnOpenAndClose() : Boolean {
			return this._toggleButtonOnOpenAndClose;
		}
		
		public function set toggleButtonOnOpenAndClose(value:Boolean) : void {
			if(this._toggleButtonOnOpenAndClose == value) {
				return;
			}
			this._toggleButtonOnOpenAndClose = value;
			if(this.button is IToggle) {
				if(this._toggleButtonOnOpenAndClose && this._popUpContentManager.isOpen) {
					IToggle(this.button).isSelected = true;
				} else {
					IToggle(this.button).isSelected = false;
				}
			}
		}
		
		public function get baseline() : Number {
			if(!this.button) {
				return this.scaledActualHeight;
			}
			return this.scaleY * (this.button.y + this.button.baseline);
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
		
		public function openList() : void {
			this._isCloseListPending = false;
			if(this._popUpContentManager.isOpen) {
				return;
			}
			if(!this._isValidating && this.isInvalid()) {
				this._isOpenListPending = true;
				return;
			}
			this._isOpenListPending = false;
			if(this._popUpContentManager is IPopUpContentManagerWithPrompt) {
				IPopUpContentManagerWithPrompt(this._popUpContentManager).prompt = this._prompt;
			}
			this._popUpContentManager.open(this.list,this);
			this.list.scrollToDisplayIndex(this._selectedIndex);
			this.list.validate();
			if(this._focusManager) {
				this._focusManager.focus = this.list;
				this.stage.addEventListener("keyUp",stage_keyUpHandler);
				this.list.addEventListener("focusOut",list_focusOutHandler);
			}
		}
		
		public function closeList() : void {
			this._isOpenListPending = false;
			if(!this._popUpContentManager.isOpen) {
				return;
			}
			if(!this._isValidating && this.isInvalid()) {
				this._isCloseListPending = true;
				return;
			}
			this._isCloseListPending = false;
			this.list.validate();
			this._popUpContentManager.close();
		}
		
		override public function dispose() : void {
			if(this.list) {
				this.closeList();
				this.list.dispose();
				this.list = null;
			}
			if(this._popUpContentManager) {
				this._popUpContentManager.dispose();
				this._popUpContentManager = null;
			}
			this._selectedIndex = -1;
			this.dataProvider = null;
			super.dispose();
		}
		
		override public function showFocus() : void {
			if(!this.button) {
				return;
			}
			this.button.showFocus();
		}
		
		override public function hideFocus() : void {
			if(!this.button) {
				return;
			}
			this.button.hideFocus();
		}
		
		override protected function initialize() : void {
			if(!this._popUpContentManager) {
				if(SystemUtil.isDesktop) {
					this.popUpContentManager = new DropDownPopUpContentManager();
				} else if(DeviceCapabilities.isTablet(Starling.current.nativeStage)) {
					this.popUpContentManager = new CalloutPopUpContentManager();
				} else {
					this.popUpContentManager = new VerticalCenteredPopUpContentManager();
				}
			}
		}
		
		override protected function draw() : void {
			var _local8:Boolean = false;
			var _local5:Boolean = this.isInvalid("data");
			var _local6:Boolean = this.isInvalid("styles");
			var _local2:Boolean = this.isInvalid("state");
			var _local3:Boolean = this.isInvalid("selected");
			var _local1:Boolean = this.isInvalid("size");
			var _local7:Boolean = this.isInvalid("buttonFactory");
			var _local4:Boolean = this.isInvalid("listFactory");
			if(_local7) {
				this.createButton();
			}
			if(_local4) {
				this.createList();
			}
			if(_local7 || _local6 || _local3) {
				if(this._explicitWidth !== this._explicitWidth) {
					this.button.width = NaN;
				}
				if(this._explicitHeight !== this._explicitHeight) {
					this.button.height = NaN;
				}
			}
			if(_local7 || _local6) {
				this.refreshButtonProperties();
			}
			if(_local4 || _local6) {
				this.refreshListProperties();
			}
			if(_local4 || _local5) {
				_local8 = this._ignoreSelectionChanges;
				this._ignoreSelectionChanges = true;
				this.list.dataProvider = this._dataProvider;
				this._ignoreSelectionChanges = _local8;
			}
			if(_local7 || _local4 || _local2) {
				this.button.isEnabled = this._isEnabled;
				this.list.isEnabled = this._isEnabled;
			}
			if(_local7 || _local5 || _local3) {
				this.refreshButtonLabel();
			}
			if(_local4 || _local5 || _local3) {
				_local8 = this._ignoreSelectionChanges;
				this._ignoreSelectionChanges = true;
				this.list.selectedIndex = this._selectedIndex;
				this._ignoreSelectionChanges = _local8;
			}
			this.autoSizeIfNeeded();
			this.layout();
			if(this.list.stage) {
				this.list.validate();
			}
			this.handlePendingActions();
		}
		
		protected function autoSizeIfNeeded() : Boolean {
			var _local4:* = this._explicitWidth !== this._explicitWidth;
			var _local9:* = this._explicitHeight !== this._explicitHeight;
			var _local5:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local11:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local4 && !_local9 && !_local5 && !_local11) {
				return false;
			}
			var _local12:Number = this._explicitWidth;
			if(_local12 !== _local12) {
				_local12 = this.buttonExplicitWidth;
			}
			var _local2:Number = this._explicitHeight;
			if(_local2 !== _local2) {
				_local2 = this.buttonExplicitHeight;
			}
			var _local7:Number = this._explicitMinWidth;
			if(_local7 !== _local7) {
				_local7 = this.buttonExplicitMinWidth;
			}
			var _local10:Number = this._explicitMinHeight;
			if(_local10 !== _local10) {
				_local10 = this.buttonExplicitMinHeight;
			}
			if(this._typicalItem !== null) {
				this.button.label = this.itemToLabel(this._typicalItem);
			}
			this.button.width = _local12;
			this.button.height = _local2;
			this.button.minWidth = _local7;
			this.button.minHeight = _local10;
			this.button.validate();
			if(this._typicalItem !== null) {
				this.refreshButtonLabel();
			}
			var _local3:Number = this._explicitWidth;
			var _local6:Number = this._explicitHeight;
			var _local1:Number = this._explicitMinWidth;
			var _local8:Number = this._explicitMinHeight;
			if(_local4) {
				_local3 = this.button.width;
			}
			if(_local9) {
				_local6 = this.button.height;
			}
			if(_local5) {
				_local1 = this.button.minWidth;
			}
			if(_local11) {
				_local8 = this.button.minHeight;
			}
			return this.saveMeasurements(_local3,_local6,_local1,_local8);
		}
		
		protected function createButton() : void {
			if(this.button) {
				this.button.removeFromParent(true);
				this.button = null;
			}
			var _local1:Function = this._buttonFactory != null ? this._buttonFactory : defaultButtonFactory;
			var _local2:String = this._customButtonStyleName != null ? this._customButtonStyleName : this.buttonStyleName;
			this.button = Button(_local1());
			if(this.button is ToggleButton) {
				ToggleButton(this.button).isToggle = false;
			}
			this.button.styleNameList.add(_local2);
			this.button.addEventListener("touch",button_touchHandler);
			this.button.addEventListener("triggered",button_triggeredHandler);
			this.addChild(this.button);
			this.button.initializeNow();
			this.buttonExplicitWidth = this.button.explicitWidth;
			this.buttonExplicitHeight = this.button.explicitHeight;
			this.buttonExplicitMinWidth = this.button.explicitMinWidth;
			this.buttonExplicitMinHeight = this.button.explicitMinHeight;
		}
		
		protected function createList() : void {
			if(this.list) {
				this.list.removeFromParent(false);
				this.list.dispose();
				this.list = null;
			}
			var _local1:Function = this._listFactory != null ? this._listFactory : defaultListFactory;
			var _local2:String = this._customListStyleName != null ? this._customListStyleName : this.listStyleName;
			this.list = List(_local1());
			this.list.focusOwner = this;
			this.list.styleNameList.add(_local2);
			this.list.addEventListener("change",list_changeHandler);
			this.list.addEventListener("triggered",list_triggeredHandler);
			this.list.addEventListener("touch",list_touchHandler);
			this.list.addEventListener("removedFromStage",list_removedFromStageHandler);
		}
		
		protected function refreshButtonLabel() : void {
			if(this._selectedIndex >= 0) {
				this.button.label = this.itemToLabel(this.selectedItem);
			} else {
				this.button.label = this._prompt;
			}
		}
		
		protected function refreshButtonProperties() : void {
			var _local2:Object = null;
			for(var _local1 in this._buttonProperties) {
				_local2 = this._buttonProperties[_local1];
				this.button[_local1] = _local2;
			}
		}
		
		protected function refreshListProperties() : void {
			var _local2:Object = null;
			for(var _local1 in this._listProperties) {
				_local2 = this._listProperties[_local1];
				this.list[_local1] = _local2;
			}
		}
		
		protected function layout() : void {
			this.button.width = this.actualWidth;
			this.button.height = this.actualHeight;
			this.button.validate();
		}
		
		protected function handlePendingActions() : void {
			if(this._isOpenListPending) {
				this.openList();
			}
			if(this._isCloseListPending) {
				this.closeList();
			}
		}
		
		override protected function focusInHandler(event:Event) : void {
			super.focusInHandler(event);
			this._buttonHasFocus = true;
			this.button.dispatchEventWith("focusIn");
		}
		
		override protected function focusOutHandler(event:Event) : void {
			if(this._buttonHasFocus) {
				this.button.dispatchEventWith("focusOut");
				this._buttonHasFocus = false;
			}
			super.focusOutHandler(event);
		}
		
		protected function childProperties_onChange(proxy:PropertyProxy, name:String) : void {
			this.invalidate("styles");
		}
		
		protected function button_touchHandler(event:TouchEvent) : void {
			var _local2:Touch = null;
			if(this._buttonTouchPointID >= 0) {
				_local2 = event.getTouch(this.button,"ended",this._buttonTouchPointID);
				if(!_local2) {
					return;
				}
				this._buttonTouchPointID = -1;
				this._listIsOpenOnTouchBegan = false;
			} else {
				_local2 = event.getTouch(this.button,"began");
				if(!_local2) {
					return;
				}
				this._buttonTouchPointID = _local2.id;
				this._listIsOpenOnTouchBegan = this._popUpContentManager.isOpen;
			}
		}
		
		protected function button_triggeredHandler(event:Event) : void {
			if(this._focusManager && this._listIsOpenOnTouchBegan) {
				return;
			}
			if(this._popUpContentManager.isOpen) {
				this.closeList();
				return;
			}
			this.openList();
		}
		
		protected function list_changeHandler(event:Event) : void {
			if(this._ignoreSelectionChanges || this._popUpContentManager is IPersistentPopUpContentManager) {
				return;
			}
			this.selectedIndex = this.list.selectedIndex;
		}
		
		protected function popUpContentManager_openHandler(event:Event) : void {
			if(this._toggleButtonOnOpenAndClose && this.button is IToggle) {
				IToggle(this.button).isSelected = true;
			}
			this.dispatchEventWith("open");
		}
		
		protected function popUpContentManager_closeHandler(event:Event) : void {
			if(this._popUpContentManager is IPersistentPopUpContentManager) {
				this.selectedIndex = this.list.selectedIndex;
			}
			if(this._toggleButtonOnOpenAndClose && this.button is IToggle) {
				IToggle(this.button).isSelected = false;
			}
			this.dispatchEventWith("close");
		}
		
		protected function list_removedFromStageHandler(event:Event) : void {
			if(this._focusManager) {
				this.list.stage.removeEventListener("keyUp",stage_keyUpHandler);
				this.list.removeEventListener("focusOut",list_focusOutHandler);
			}
		}
		
		protected function list_focusOutHandler(event:Event) : void {
			if(!this._popUpContentManager.isOpen) {
				return;
			}
			this.closeList();
		}
		
		protected function list_triggeredHandler(event:Event) : void {
			if(!this._isEnabled || this._popUpContentManager is IPersistentPopUpContentManager) {
				return;
			}
			this._triggered = true;
		}
		
		protected function list_touchHandler(event:TouchEvent) : void {
			var _local2:Touch = event.getTouch(this.list);
			if(_local2 === null) {
				return;
			}
			if(_local2.phase === "began") {
				this._triggered = false;
			}
			if(_local2.phase === "ended" && this._triggered) {
				this.closeList();
			}
		}
		
		protected function dataProvider_multipleEventHandler(event:Event) : void {
			this.validate();
		}
		
		protected function dataProvider_updateItemHandler(event:Event, index:int) : void {
			if(index === this._selectedIndex) {
				this.invalidate("selected");
			}
		}
		
		protected function stage_keyUpHandler(event:KeyboardEvent) : void {
			if(!this._popUpContentManager.isOpen) {
				return;
			}
			if(event.keyCode == 13) {
				this.closeList();
			}
		}
	}
}

