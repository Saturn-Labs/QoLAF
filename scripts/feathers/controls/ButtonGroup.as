package feathers.controls {
	import feathers.core.FeathersControl;
	import feathers.core.PropertyProxy;
	import feathers.data.ListCollection;
	import feathers.layout.FlowLayout;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.ILayout;
	import feathers.layout.IVirtualLayout;
	import feathers.layout.LayoutBoundsResult;
	import feathers.layout.VerticalLayout;
	import feathers.layout.ViewPortBounds;
	import feathers.skins.IStyleProvider;
	import flash.utils.Dictionary;
	import starling.display.DisplayObject;
	import starling.events.Event;
	
	public class ButtonGroup extends FeathersControl {
		public static var globalStyleProvider:IStyleProvider;
		
		protected static const INVALIDATION_FLAG_BUTTON_FACTORY:String = "buttonFactory";
		
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
		
		public static const DEFAULT_CHILD_STYLE_NAME_BUTTON:String = "feathers-button-group-button";
		
		private static const DEFAULT_BUTTON_FIELDS:Vector.<String> = new <String>["defaultIcon","upIcon","downIcon","hoverIcon","disabledIcon","defaultSelectedIcon","selectedUpIcon","selectedDownIcon","selectedHoverIcon","selectedDisabledIcon","isSelected","isToggle","isLongPressEnabled","name"];
		
		private static const DEFAULT_BUTTON_EVENTS:Vector.<String> = new <String>["triggered","change","longPress"];
		
		protected var buttonStyleName:String = "feathers-button-group-button";
		
		protected var firstButtonStyleName:String = "feathers-button-group-button";
		
		protected var lastButtonStyleName:String = "feathers-button-group-button";
		
		protected var activeFirstButton:Button;
		
		protected var inactiveFirstButton:Button;
		
		protected var activeLastButton:Button;
		
		protected var inactiveLastButton:Button;
		
		protected var _layoutItems:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
		
		protected var activeButtons:Vector.<Button> = new Vector.<Button>(0);
		
		protected var inactiveButtons:Vector.<Button> = new Vector.<Button>(0);
		
		protected var _buttonToItem:Dictionary = new Dictionary(true);
		
		protected var _dataProvider:ListCollection;
		
		protected var layout:ILayout;
		
		protected var _viewPortBounds:ViewPortBounds = new ViewPortBounds();
		
		protected var _layoutResult:LayoutBoundsResult = new LayoutBoundsResult();
		
		protected var _direction:String = "vertical";
		
		protected var _horizontalAlign:String = "justify";
		
		protected var _verticalAlign:String = "justify";
		
		protected var _distributeButtonSizes:Boolean = true;
		
		protected var _gap:Number = 0;
		
		protected var _firstGap:Number = NaN;
		
		protected var _lastGap:Number = NaN;
		
		protected var _paddingTop:Number = 0;
		
		protected var _paddingRight:Number = 0;
		
		protected var _paddingBottom:Number = 0;
		
		protected var _paddingLeft:Number = 0;
		
		protected var _buttonFactory:Function = defaultButtonFactory;
		
		protected var _firstButtonFactory:Function;
		
		protected var _lastButtonFactory:Function;
		
		protected var _buttonInitializer:Function;
		
		protected var _buttonReleaser:Function;
		
		protected var _customButtonStyleName:String;
		
		protected var _customFirstButtonStyleName:String;
		
		protected var _customLastButtonStyleName:String;
		
		protected var _buttonProperties:PropertyProxy;
		
		public function ButtonGroup() {
			_buttonInitializer = defaultButtonInitializer;
			_buttonReleaser = defaultButtonReleaser;
			super();
		}
		
		protected static function defaultButtonFactory() : Button {
			return new Button();
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return ButtonGroup.globalStyleProvider;
		}
		
		public function get dataProvider() : ListCollection {
			return this._dataProvider;
		}
		
		public function set dataProvider(value:ListCollection) : void {
			if(this._dataProvider == value) {
				return;
			}
			if(this._dataProvider) {
				this._dataProvider.removeEventListener("updateAll",dataProvider_updateAllHandler);
				this._dataProvider.removeEventListener("updateItem",dataProvider_updateItemHandler);
				this._dataProvider.removeEventListener("change",dataProvider_changeHandler);
			}
			this._dataProvider = value;
			if(this._dataProvider) {
				this._dataProvider.addEventListener("updateAll",dataProvider_updateAllHandler);
				this._dataProvider.addEventListener("updateItem",dataProvider_updateItemHandler);
				this._dataProvider.addEventListener("change",dataProvider_changeHandler);
			}
			this.invalidate("data");
		}
		
		public function get direction() : String {
			return _direction;
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
			return _verticalAlign;
		}
		
		public function set verticalAlign(value:String) : void {
			if(this._verticalAlign == value) {
				return;
			}
			this._verticalAlign = value;
			this.invalidate("styles");
		}
		
		public function get distributeButtonSizes() : Boolean {
			return this._distributeButtonSizes;
		}
		
		public function set distributeButtonSizes(value:Boolean) : void {
			if(this._distributeButtonSizes == value) {
				return;
			}
			this._distributeButtonSizes = value;
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
		
		public function get firstButtonFactory() : Function {
			return this._firstButtonFactory;
		}
		
		public function set firstButtonFactory(value:Function) : void {
			if(this._firstButtonFactory == value) {
				return;
			}
			this._firstButtonFactory = value;
			this.invalidate("buttonFactory");
		}
		
		public function get lastButtonFactory() : Function {
			return this._lastButtonFactory;
		}
		
		public function set lastButtonFactory(value:Function) : void {
			if(this._lastButtonFactory == value) {
				return;
			}
			this._lastButtonFactory = value;
			this.invalidate("buttonFactory");
		}
		
		public function get buttonInitializer() : Function {
			return this._buttonInitializer;
		}
		
		public function set buttonInitializer(value:Function) : void {
			if(this._buttonInitializer == value) {
				return;
			}
			this._buttonInitializer = value;
			this.invalidate("buttonFactory");
		}
		
		public function get buttonReleaser() : Function {
			return this._buttonReleaser;
		}
		
		public function set buttonReleaser(value:Function) : void {
			if(this._buttonReleaser == value) {
				return;
			}
			this._buttonReleaser = value;
			this.invalidate("data");
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
		
		public function get customFirstButtonStyleName() : String {
			return this._customFirstButtonStyleName;
		}
		
		public function set customFirstButtonStyleName(value:String) : void {
			if(this._customFirstButtonStyleName == value) {
				return;
			}
			this._customFirstButtonStyleName = value;
			this.invalidate("buttonFactory");
		}
		
		public function get customLastButtonStyleName() : String {
			return this._customLastButtonStyleName;
		}
		
		public function set customLastButtonStyleName(value:String) : void {
			if(this._customLastButtonStyleName == value) {
				return;
			}
			this._customLastButtonStyleName = value;
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
		
		public function get baseline() : Number {
			if(!this.activeButtons || this.activeButtons.length === 0) {
				return this.scaledActualHeight;
			}
			var _local1:Button = this.activeButtons[0];
			return this.scaleY * (_local1.y + _local1.baseline);
		}
		
		override public function dispose() : void {
			this.dataProvider = null;
			super.dispose();
		}
		
		override protected function draw() : void {
			var _local3:Boolean = this.isInvalid("data");
			var _local4:Boolean = this.isInvalid("styles");
			var _local2:Boolean = this.isInvalid("state");
			var _local5:Boolean = this.isInvalid("buttonFactory");
			var _local1:Boolean = this.isInvalid("size");
			if(_local3 || _local2 || _local5) {
				this.refreshButtons(_local5);
			}
			if(_local3 || _local5 || _local4) {
				this.refreshButtonStyles();
			}
			if(_local3 || _local2 || _local5) {
				this.commitEnabled();
			}
			if(_local4) {
				this.refreshLayoutStyles();
			}
			this.layoutButtons();
		}
		
		protected function commitEnabled() : void {
			var _local3:int = 0;
			var _local1:Button = null;
			var _local2:int = int(this.activeButtons.length);
			_local3 = 0;
			while(_local3 < _local2) {
				_local1 = this.activeButtons[_local3];
				_local1.isEnabled &&= this._isEnabled;
				_local3++;
			}
		}
		
		protected function refreshButtonStyles() : void {
			var _local3:Object = null;
			for(var _local2 in this._buttonProperties) {
				_local3 = this._buttonProperties[_local2];
				for each(var _local1 in this.activeButtons) {
					_local1[_local2] = _local3;
				}
			}
		}
		
		protected function refreshLayoutStyles() : void {
			var _local2:VerticalLayout = null;
			var _local3:HorizontalLayout = null;
			var _local1:FlowLayout = null;
			if(this._direction == "vertical") {
				_local2 = this.layout as VerticalLayout;
				if(!_local2) {
					this.layout = _local2 = new VerticalLayout();
				}
				_local2.distributeHeights = this._distributeButtonSizes;
				_local2.horizontalAlign = this._horizontalAlign;
				_local2.verticalAlign = this._verticalAlign == "justify" ? "top" : this._verticalAlign;
				_local2.gap = this._gap;
				_local2.firstGap = this._firstGap;
				_local2.lastGap = this._lastGap;
				_local2.paddingTop = this._paddingTop;
				_local2.paddingRight = this._paddingRight;
				_local2.paddingBottom = this._paddingBottom;
				_local2.paddingLeft = this._paddingLeft;
			} else if(this._distributeButtonSizes) {
				_local3 = this.layout as HorizontalLayout;
				if(!_local3) {
					this.layout = _local3 = new HorizontalLayout();
				}
				_local3.distributeWidths = true;
				_local3.horizontalAlign = this._horizontalAlign == "justify" ? "left" : this._horizontalAlign;
				_local3.verticalAlign = this._verticalAlign;
				_local3.gap = this._gap;
				_local3.firstGap = this._firstGap;
				_local3.lastGap = this._lastGap;
				_local3.paddingTop = this._paddingTop;
				_local3.paddingRight = this._paddingRight;
				_local3.paddingBottom = this._paddingBottom;
				_local3.paddingLeft = this._paddingLeft;
			} else {
				_local1 = this.layout as FlowLayout;
				if(!_local1) {
					this.layout = _local1 = new FlowLayout();
				}
				_local1.horizontalAlign = this._horizontalAlign == "justify" ? "left" : this._horizontalAlign;
				_local1.verticalAlign = this._verticalAlign;
				_local1.gap = this._gap;
				_local1.firstHorizontalGap = this._firstGap;
				_local1.lastHorizontalGap = this._lastGap;
				_local1.paddingTop = this._paddingTop;
				_local1.paddingRight = this._paddingRight;
				_local1.paddingBottom = this._paddingBottom;
				_local1.paddingLeft = this._paddingLeft;
			}
			if(layout is IVirtualLayout) {
				IVirtualLayout(layout).useVirtualLayout = false;
			}
		}
		
		protected function defaultButtonInitializer(button:Button, item:Object) : void {
			var _local5:Boolean = false;
			var _local4:Function = null;
			if(item is Object) {
				if(item.hasOwnProperty("label")) {
					button.label = item.label as String;
				} else {
					button.label = item.toString();
				}
				if(item.hasOwnProperty("isEnabled")) {
					button.isEnabled = item.isEnabled as Boolean;
				} else {
					button.isEnabled = this._isEnabled;
				}
				for each(var _local3 in DEFAULT_BUTTON_FIELDS) {
					if(item.hasOwnProperty(_local3)) {
						button[_local3] = item[_local3];
					}
				}
				for each(_local3 in DEFAULT_BUTTON_EVENTS) {
					_local5 = true;
					if(item.hasOwnProperty(_local3)) {
						_local4 = item[_local3] as Function;
						if(_local4 === null) {
							continue;
						}
						_local5 = false;
						button.addEventListener(_local3,defaultButtonEventsListener);
					}
					if(_local5) {
						button.removeEventListener(_local3,defaultButtonEventsListener);
					}
				}
			} else {
				button.label = "";
				button.isEnabled = this._isEnabled;
			}
		}
		
		protected function defaultButtonReleaser(button:Button, oldItem:Object) : void {
			var _local5:Boolean = false;
			var _local4:Function = null;
			button.label = null;
			for each(var _local3 in DEFAULT_BUTTON_FIELDS) {
				if(oldItem.hasOwnProperty(_local3)) {
					button[_local3] = null;
				}
			}
			for each(_local3 in DEFAULT_BUTTON_EVENTS) {
				_local5 = true;
				if(oldItem.hasOwnProperty(_local3)) {
					_local4 = oldItem[_local3] as Function;
					if(_local4 !== null) {
						button.removeEventListener(_local3,defaultButtonEventsListener);
					}
				}
			}
		}
		
		protected function refreshButtons(isFactoryInvalid:Boolean) : void {
			var _local5:int = 0;
			var _local4:Object = null;
			var _local2:* = null;
			var _local3:Vector.<Button> = this.inactiveButtons;
			this.inactiveButtons = this.activeButtons;
			this.activeButtons = _local3;
			this.activeButtons.length = 0;
			this._layoutItems.length = 0;
			_local3 = null;
			if(isFactoryInvalid) {
				this.clearInactiveButtons();
			} else {
				if(this.activeFirstButton) {
					this.inactiveButtons.shift();
				}
				this.inactiveFirstButton = this.activeFirstButton;
				if(this.activeLastButton) {
					this.inactiveButtons.pop();
				}
				this.inactiveLastButton = this.activeLastButton;
			}
			this.activeFirstButton = null;
			this.activeLastButton = null;
			var _local7:int = 0;
			var _local8:int = int(!!this._dataProvider ? this._dataProvider.length : 0);
			var _local6:int = _local8 - 1;
			_local5 = 0;
			while(_local5 < _local8) {
				_local4 = this._dataProvider.getItemAt(_local5);
				if(_local5 == 0) {
					_local2 = this.activeFirstButton = this.createFirstButton(_local4);
				} else if(_local5 == _local6) {
					_local2 = this.activeLastButton = this.createLastButton(_local4);
				} else {
					_local2 = this.createButton(_local4);
				}
				this.activeButtons[_local7] = _local2;
				this._layoutItems[_local7] = _local2;
				_local7++;
				_local5++;
			}
			this.clearInactiveButtons();
		}
		
		protected function clearInactiveButtons() : void {
			var _local2:int = 0;
			var _local1:Button = null;
			var _local3:int = int(this.inactiveButtons.length);
			_local2 = 0;
			while(_local2 < _local3) {
				_local1 = this.inactiveButtons.shift();
				this.destroyButton(_local1);
				_local2++;
			}
			if(this.inactiveFirstButton) {
				this.destroyButton(this.inactiveFirstButton);
				this.inactiveFirstButton = null;
			}
			if(this.inactiveLastButton) {
				this.destroyButton(this.inactiveLastButton);
				this.inactiveLastButton = null;
			}
		}
		
		protected function createFirstButton(item:Object) : Button {
			var _local2:Button = null;
			var _local3:Function = null;
			var _local4:Boolean = false;
			if(this.inactiveFirstButton !== null) {
				_local2 = this.inactiveFirstButton;
				this.releaseButton(_local2);
				this.inactiveFirstButton = null;
			} else {
				_local4 = true;
				_local3 = this._firstButtonFactory != null ? this._firstButtonFactory : this._buttonFactory;
				_local2 = Button(_local3());
				if(this._customFirstButtonStyleName) {
					_local2.styleNameList.add(this._customFirstButtonStyleName);
				} else if(this._customButtonStyleName) {
					_local2.styleNameList.add(this._customButtonStyleName);
				} else {
					_local2.styleNameList.add(this.firstButtonStyleName);
				}
				this.addChild(_local2);
			}
			this._buttonInitializer(_local2,item);
			this._buttonToItem[_local2] = item;
			if(_local4) {
				_local2.addEventListener("triggered",button_triggeredHandler);
			}
			return _local2;
		}
		
		protected function createLastButton(item:Object) : Button {
			var _local2:Button = null;
			var _local3:Function = null;
			var _local4:Boolean = false;
			if(this.inactiveLastButton !== null) {
				_local2 = this.inactiveLastButton;
				this.releaseButton(_local2);
				this.inactiveLastButton = null;
			} else {
				_local4 = true;
				_local3 = this._lastButtonFactory != null ? this._lastButtonFactory : this._buttonFactory;
				_local2 = Button(_local3());
				if(this._customLastButtonStyleName) {
					_local2.styleNameList.add(this._customLastButtonStyleName);
				} else if(this._customButtonStyleName) {
					_local2.styleNameList.add(this._customButtonStyleName);
				} else {
					_local2.styleNameList.add(this.lastButtonStyleName);
				}
				this.addChild(_local2);
			}
			this._buttonInitializer(_local2,item);
			this._buttonToItem[_local2] = item;
			if(_local4) {
				_local2.addEventListener("triggered",button_triggeredHandler);
			}
			return _local2;
		}
		
		protected function createButton(item:Object) : Button {
			var _local2:Button = null;
			var _local3:Boolean = false;
			if(this.inactiveButtons.length === 0) {
				_local3 = true;
				_local2 = this._buttonFactory();
				if(this._customButtonStyleName) {
					_local2.styleNameList.add(this._customButtonStyleName);
				} else {
					_local2.styleNameList.add(this.buttonStyleName);
				}
				this.addChild(_local2);
			} else {
				_local2 = this.inactiveButtons.shift();
				this.releaseButton(_local2);
			}
			this._buttonInitializer(_local2,item);
			this._buttonToItem[_local2] = item;
			if(_local3) {
				_local2.addEventListener("triggered",button_triggeredHandler);
			}
			return _local2;
		}
		
		protected function releaseButton(button:Button) : void {
			var _local2:Object = this._buttonToItem[button];
			delete this._buttonToItem[button];
			if(this._buttonReleaser.length === 1) {
				this._buttonReleaser(button);
			} else {
				this._buttonReleaser(button,_local2);
			}
		}
		
		protected function destroyButton(button:Button) : void {
			button.removeEventListener("triggered",button_triggeredHandler);
			this.releaseButton(button);
			this.removeChild(button,true);
		}
		
		protected function layoutButtons() : void {
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
			this.layout.layout(this._layoutItems,this._viewPortBounds,this._layoutResult);
			var _local2:Number = this._layoutResult.contentWidth;
			var _local3:Number = this._layoutResult.contentHeight;
			this.saveMeasurements(_local2,_local3,_local2,_local3);
			for each(var _local1 in this.activeButtons) {
				_local1.validate();
			}
		}
		
		protected function childProperties_onChange(proxy:PropertyProxy, name:String) : void {
			this.invalidate("styles");
		}
		
		protected function dataProvider_changeHandler(event:Event) : void {
			this.invalidate("data");
		}
		
		protected function dataProvider_updateAllHandler(event:Event) : void {
			this.invalidate("data");
		}
		
		protected function dataProvider_updateItemHandler(event:Event, index:int) : void {
			this.invalidate("data");
		}
		
		protected function button_triggeredHandler(event:Event) : void {
			if(!this._dataProvider || !this.activeButtons) {
				return;
			}
			var _local2:Button = Button(event.currentTarget);
			var _local4:int = int(this.activeButtons.indexOf(_local2));
			var _local3:Object = this._dataProvider.getItemAt(_local4);
			this.dispatchEventWith("triggered",false,_local3);
		}
		
		protected function defaultButtonEventsListener(event:Event) : void {
			var _local6:Function = null;
			var _local5:int = 0;
			var _local2:Button = Button(event.currentTarget);
			var _local7:int = int(this.activeButtons.indexOf(_local2));
			var _local3:Object = this._dataProvider.getItemAt(_local7);
			var _local4:String = event.type;
			if(_local3.hasOwnProperty(_local4)) {
				_local6 = _local3[_local4] as Function;
				if(_local6 == null) {
					return;
				}
				switch((_local5 = _local6.length) - 1) {
					case 0:
						_local6(event);
						break;
					case 1:
						_local6(event,event.data);
						break;
					case 2:
						_local6(event,event.data,_local3);
						break;
					default:
						_local6();
				}
			}
		}
	}
}

