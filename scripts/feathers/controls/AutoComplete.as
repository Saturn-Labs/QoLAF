package feathers.controls {
	import feathers.controls.popups.DropDownPopUpContentManager;
	import feathers.controls.popups.IPopUpContentManager;
	import feathers.core.PropertyProxy;
	import feathers.data.IAutoCompleteSource;
	import feathers.data.ListCollection;
	import feathers.skins.IStyleProvider;
	import feathers.utils.display.stageToStarling;
	import flash.events.KeyboardEvent;
	import flash.utils.getTimer;
	import starling.core.Starling;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	public class AutoComplete extends TextInput {
		protected static const INVALIDATION_FLAG_LIST_FACTORY:String = "listFactory";
		
		public static const DEFAULT_CHILD_STYLE_NAME_LIST:String = "feathers-auto-complete-list";
		
		public static var globalStyleProvider:IStyleProvider;
		
		protected var listStyleName:String = "feathers-auto-complete-list";
		
		protected var list:List;
		
		protected var _listCollection:ListCollection;
		
		protected var _originalText:String;
		
		protected var _source:IAutoCompleteSource;
		
		protected var _autoCompleteDelay:Number = 0.5;
		
		protected var _minimumAutoCompleteLength:int = 2;
		
		protected var _popUpContentManager:IPopUpContentManager;
		
		protected var _listFactory:Function;
		
		protected var _customListStyleName:String;
		
		protected var _listProperties:PropertyProxy;
		
		protected var _ignoreAutoCompleteChanges:Boolean = false;
		
		protected var _lastChangeTime:int = 0;
		
		protected var _listHasFocus:Boolean = false;
		
		protected var _triggered:Boolean = false;
		
		protected var _isOpenListPending:Boolean = false;
		
		protected var _isCloseListPending:Boolean = false;
		
		public function AutoComplete() {
			super();
			this.addEventListener("change",autoComplete_changeHandler);
		}
		
		protected static function defaultListFactory() : List {
			return new List();
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			if(AutoComplete.globalStyleProvider) {
				return AutoComplete.globalStyleProvider;
			}
			return TextInput.globalStyleProvider;
		}
		
		public function get source() : IAutoCompleteSource {
			return this._source;
		}
		
		public function set source(value:IAutoCompleteSource) : void {
			if(this._source == value) {
				return;
			}
			if(this._source) {
				this._source.removeEventListener("complete",dataProvider_completeHandler);
			}
			this._source = value;
			if(this._source) {
				this._source.addEventListener("complete",dataProvider_completeHandler);
			}
		}
		
		public function get autoCompleteDelay() : Number {
			return this._autoCompleteDelay;
		}
		
		public function set autoCompleteDelay(value:Number) : void {
			this._autoCompleteDelay = value;
		}
		
		public function get minimumAutoCompleteLength() : Number {
			return this._minimumAutoCompleteLength;
		}
		
		public function set minimumAutoCompleteLength(value:Number) : void {
			this._minimumAutoCompleteLength = value;
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
			this._popUpContentManager.open(this.list,this);
			this.list.validate();
			if(this._focusManager) {
				this.stage.addEventListener("keyUp",stage_keyUpHandler);
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
			if(this._listHasFocus) {
				this.list.dispatchEventWith("focusOut");
			}
			this._isCloseListPending = false;
			this.list.validate();
			this._popUpContentManager.close();
		}
		
		override public function dispose() : void {
			this.source = null;
			if(this.list) {
				this.closeList();
				this.list.dispose();
				this.list = null;
			}
			if(this._popUpContentManager) {
				this._popUpContentManager.dispose();
				this._popUpContentManager = null;
			}
			super.dispose();
		}
		
		override protected function initialize() : void {
			super.initialize();
			this._listCollection = new ListCollection();
			if(!this._popUpContentManager) {
				this.popUpContentManager = new DropDownPopUpContentManager();
			}
		}
		
		override protected function draw() : void {
			var _local2:Boolean = this.isInvalid("styles");
			var _local1:Boolean = this.isInvalid("listFactory");
			super.draw();
			if(_local1) {
				this.createList();
			}
			if(_local1 || _local2) {
				this.refreshListProperties();
			}
			this.handlePendingActions();
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
			this.list.isFocusEnabled = false;
			this.list.isChildFocusEnabled = false;
			this.list.styleNameList.add(_local2);
			this.list.addEventListener("change",list_changeHandler);
			this.list.addEventListener("triggered",list_triggeredHandler);
			this.list.addEventListener("touch",list_touchHandler);
			this.list.addEventListener("removedFromStage",list_removedFromStageHandler);
		}
		
		protected function refreshListProperties() : void {
			var _local2:Object = null;
			for(var _local1 in this._listProperties) {
				_local2 = this._listProperties[_local1];
				this.list[_local1] = _local2;
			}
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
			var _local2:Starling = stageToStarling(this.stage);
			_local2.nativeStage.addEventListener("keyDown",nativeStage_keyDownHandler,false,1,true);
			super.focusInHandler(event);
		}
		
		override protected function focusOutHandler(event:Event) : void {
			var _local2:Starling = stageToStarling(this.stage);
			_local2.nativeStage.removeEventListener("keyDown",nativeStage_keyDownHandler);
			super.focusOutHandler(event);
		}
		
		protected function nativeStage_keyDownHandler(event:flash.events.KeyboardEvent) : void {
			var _local3:Boolean = false;
			if(!this._popUpContentManager.isOpen) {
				return;
			}
			var _local6:* = event.keyCode == 40;
			var _local2:* = event.keyCode == 38;
			if(!_local6 && !_local2) {
				return;
			}
			var _local4:int = this.list.selectedIndex;
			var _local5:int = this.list.dataProvider.length - 1;
			if(_local4 < 0) {
				event.stopImmediatePropagation();
				this._originalText = this._text;
				if(_local6) {
					this.list.selectedIndex = 0;
				} else {
					this.list.selectedIndex = _local5;
				}
				this.list.scrollToDisplayIndex(this.list.selectedIndex,this.list.keyScrollDuration);
				this._listHasFocus = true;
				this.list.dispatchEventWith("focusIn");
			} else if(_local6 && _local4 == _local5 || _local2 && _local4 == 0) {
				event.stopImmediatePropagation();
				_local3 = this._ignoreAutoCompleteChanges;
				this._ignoreAutoCompleteChanges = true;
				this.text = this._originalText;
				this._ignoreAutoCompleteChanges = _local3;
				this.list.selectedIndex = -1;
				this.selectRange(this.text.length,this.text.length);
				this._listHasFocus = false;
				this.list.dispatchEventWith("focusOut");
			}
		}
		
		protected function autoComplete_changeHandler(event:Event) : void {
			if(this._ignoreAutoCompleteChanges || !this._source || !this.hasFocus) {
				return;
			}
			if(this.text.length < this._minimumAutoCompleteLength) {
				this.removeEventListener("enterFrame",autoComplete_enterFrameHandler);
				this.closeList();
				return;
			}
			if(this._autoCompleteDelay == 0) {
				this.removeEventListener("enterFrame",autoComplete_enterFrameHandler);
				this._source.load(this.text,this._listCollection);
			} else {
				this._lastChangeTime = getTimer();
				this.addEventListener("enterFrame",autoComplete_enterFrameHandler);
			}
		}
		
		protected function autoComplete_enterFrameHandler() : void {
			var _local1:int = getTimer();
			var _local2:Number = (_local1 - this._lastChangeTime) / 1000;
			if(_local2 < this._autoCompleteDelay) {
				return;
			}
			this.removeEventListener("enterFrame",autoComplete_enterFrameHandler);
			this._source.load(this.text,this._listCollection);
		}
		
		protected function dataProvider_completeHandler(event:Event, data:ListCollection) : void {
			this.list.dataProvider = data;
			if(data.length == 0) {
				if(this._popUpContentManager.isOpen) {
					this.closeList();
				}
				return;
			}
			this.openList();
		}
		
		protected function list_changeHandler(event:Event) : void {
			if(!this.list.selectedItem) {
				return;
			}
			var _local2:Boolean = this._ignoreAutoCompleteChanges;
			this._ignoreAutoCompleteChanges = true;
			this.text = this.list.selectedItem.toString();
			this.selectRange(this.text.length,this.text.length);
			this._ignoreAutoCompleteChanges = _local2;
		}
		
		protected function popUpContentManager_openHandler(event:Event) : void {
			this.dispatchEventWith("open");
		}
		
		protected function popUpContentManager_closeHandler(event:Event) : void {
			this.dispatchEventWith("close");
		}
		
		protected function list_removedFromStageHandler(event:Event) : void {
			if(this._focusManager) {
				this.list.stage.removeEventListener("keyUp",stage_keyUpHandler);
			}
		}
		
		protected function list_triggeredHandler(event:Event) : void {
			if(!this._isEnabled) {
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
				this.selectRange(this.text.length,this.text.length);
			}
		}
		
		protected function stage_keyUpHandler(event:starling.events.KeyboardEvent) : void {
			if(!this._popUpContentManager.isOpen) {
				return;
			}
			if(event.keyCode == 13) {
				this.closeList();
				this.selectRange(this.text.length,this.text.length);
			}
		}
	}
}

