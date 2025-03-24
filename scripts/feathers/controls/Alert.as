package feathers.controls {
	import feathers.core.FeathersControl;
	import feathers.core.IFeathersControl;
	import feathers.core.IMeasureDisplayObject;
	import feathers.core.ITextRenderer;
	import feathers.core.IValidating;
	import feathers.core.PopUpManager;
	import feathers.core.PropertyProxy;
	import feathers.data.ListCollection;
	import feathers.layout.VerticalLayout;
	import feathers.skins.IStyleProvider;
	import feathers.utils.skins.resetFluidChildDimensionsForMeasurement;
	import starling.display.DisplayObject;
	import starling.events.Event;
	
	public class Alert extends Panel {
		public static const DEFAULT_CHILD_STYLE_NAME_HEADER:String = "feathers-alert-header";
		
		public static const DEFAULT_CHILD_STYLE_NAME_BUTTON_GROUP:String = "feathers-alert-button-group";
		
		public static const DEFAULT_CHILD_STYLE_NAME_MESSAGE:String = "feathers-alert-message";
		
		public static var overlayFactory:Function;
		
		public static var globalStyleProvider:IStyleProvider;
		
		public static var alertFactory:Function = defaultAlertFactory;
		
		protected var messageStyleName:String = "feathers-alert-message";
		
		protected var headerHeader:Header;
		
		protected var buttonGroupFooter:ButtonGroup;
		
		protected var messageTextRenderer:ITextRenderer;
		
		protected var _message:String = null;
		
		protected var _icon:DisplayObject;
		
		protected var _gap:Number = 0;
		
		protected var _buttonsDataProvider:ListCollection;
		
		protected var _messageFactory:Function;
		
		protected var _messageProperties:PropertyProxy;
		
		protected var _customMessageStyleName:String;
		
		public function Alert() {
			super();
			this.headerStyleName = "feathers-alert-header";
			this.footerStyleName = "feathers-alert-button-group";
			this.buttonGroupFactory = defaultButtonGroupFactory;
		}
		
		public static function defaultAlertFactory() : Alert {
			return new Alert();
		}
		
		public static function show(message:String, title:String = null, buttons:ListCollection = null, icon:DisplayObject = null, isModal:Boolean = true, isCentered:Boolean = true, customAlertFactory:Function = null, customOverlayFactory:Function = null) : Alert {
			var _local9:* = customAlertFactory;
			if(_local9 == null) {
				_local9 = alertFactory != null ? alertFactory : defaultAlertFactory;
			}
			var _local10:Alert = Alert(_local9());
			_local10.title = title;
			_local10.message = message;
			_local10.buttonsDataProvider = buttons;
			_local10.icon = icon;
			_local9 = customOverlayFactory;
			if(_local9 == null) {
				_local9 = overlayFactory;
			}
			PopUpManager.addPopUp(_local10,isModal,isCentered,_local9);
			return _local10;
		}
		
		protected static function defaultButtonGroupFactory() : ButtonGroup {
			return new ButtonGroup();
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return Alert.globalStyleProvider;
		}
		
		public function get message() : String {
			return this._message;
		}
		
		public function set message(value:String) : void {
			if(this._message == value) {
				return;
			}
			this._message = value;
			this.invalidate("data");
		}
		
		public function get icon() : DisplayObject {
			return this._icon;
		}
		
		public function set icon(value:DisplayObject) : void {
			if(this._icon == value) {
				return;
			}
			var _local2:Boolean = this.displayListBypassEnabled;
			this.displayListBypassEnabled = false;
			if(this._icon) {
				this._icon.removeEventListener("resize",icon_resizeHandler);
				this.removeChild(this._icon);
			}
			this._icon = value;
			if(this._icon) {
				this._icon.addEventListener("resize",icon_resizeHandler);
				this.addChild(this._icon);
			}
			this.displayListBypassEnabled = _local2;
			this.invalidate("data");
		}
		
		public function get gap() : Number {
			return this._gap;
		}
		
		public function set gap(value:Number) : void {
			if(this._gap == value) {
				return;
			}
			this._gap = value;
			this.invalidate("layout");
		}
		
		public function get buttonsDataProvider() : ListCollection {
			return this._buttonsDataProvider;
		}
		
		public function set buttonsDataProvider(value:ListCollection) : void {
			if(this._buttonsDataProvider == value) {
				return;
			}
			this._buttonsDataProvider = value;
			this.invalidate("styles");
		}
		
		public function get messageFactory() : Function {
			return this._messageFactory;
		}
		
		public function set messageFactory(value:Function) : void {
			if(this._messageFactory == value) {
				return;
			}
			this._messageFactory = value;
			this.invalidate("textRenderer");
		}
		
		public function get messageProperties() : Object {
			if(!this._messageProperties) {
				this._messageProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._messageProperties;
		}
		
		public function set messageProperties(value:Object) : void {
			if(this._messageProperties == value) {
				return;
			}
			if(value && !(value is PropertyProxy)) {
				value = PropertyProxy.fromObject(value);
			}
			if(this._messageProperties) {
				this._messageProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._messageProperties = PropertyProxy(value);
			if(this._messageProperties) {
				this._messageProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get customMessageStyleName() : String {
			return this._customMessageStyleName;
		}
		
		public function set customMessageStyleName(value:String) : void {
			if(this._customMessageStyleName == value) {
				return;
			}
			this._customMessageStyleName = value;
			this.invalidate("textRenderer");
		}
		
		public function get buttonGroupFactory() : Function {
			return super.footerFactory;
		}
		
		public function set buttonGroupFactory(value:Function) : void {
			super.footerFactory = value;
		}
		
		public function get customButtonGroupStyleName() : String {
			return super.customFooterStyleName;
		}
		
		public function set customButtonGroupStyleName(value:String) : void {
			super.customFooterStyleName = value;
		}
		
		public function get buttonGroupProperties() : Object {
			return super.footerProperties;
		}
		
		public function set buttonGroupProperties(value:Object) : void {
			super.footerProperties = value;
		}
		
		override protected function initialize() : void {
			var _local1:VerticalLayout = null;
			if(!this.layout) {
				_local1 = new VerticalLayout();
				_local1.horizontalAlign = "justify";
				this.layout = _local1;
			}
			super.initialize();
		}
		
		override protected function draw() : void {
			var _local2:Boolean = this.isInvalid("data");
			var _local3:Boolean = this.isInvalid("styles");
			var _local1:Boolean = this.isInvalid("textRenderer");
			if(_local1) {
				this.createMessage();
			}
			if(_local1 || _local2) {
				this.messageTextRenderer.text = this._message;
			}
			if(_local1 || _local3) {
				this.refreshMessageStyles();
			}
			super.draw();
			if(this._icon) {
				if(this._icon is IValidating) {
					IValidating(this._icon).validate();
				}
				this._icon.x = this._paddingLeft;
				this._icon.y = this._topViewPortOffset + (this._viewPort.visibleHeight - this._icon.height) / 2;
			}
		}
		
		override protected function autoSizeIfNeeded() : Boolean {
			var _local5:Number = NaN;
			var _local8:Number = NaN;
			var _local1:Number = NaN;
			var _local13:Number = NaN;
			var _local7:Number = NaN;
			if(this._autoSizeMode === "stage") {
				return super.autoSizeIfNeeded();
			}
			var _local3:* = this._explicitWidth !== this._explicitWidth;
			var _local12:* = this._explicitHeight !== this._explicitHeight;
			var _local10:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local14:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local3 && !_local12 && !_local10 && !_local14) {
				return false;
			}
			resetFluidChildDimensionsForMeasurement(this.currentBackgroundSkin,this._explicitWidth,this._explicitHeight,this._explicitMinWidth,this._explicitMinHeight,this._explicitMaxWidth,this._explicitMaxHeight,this._explicitBackgroundWidth,this._explicitBackgroundHeight,this._explicitBackgroundMinWidth,this._explicitBackgroundMinHeight,this._explicitBackgroundMaxWidth,this._explicitBackgroundMaxHeight);
			var _local6:IMeasureDisplayObject = this.currentBackgroundSkin as IMeasureDisplayObject;
			if(this.currentBackgroundSkin is IValidating) {
				IValidating(this.currentBackgroundSkin).validate();
			}
			if(this._icon is IValidating) {
				IValidating(this._icon).validate();
			}
			var _local2:* = this._explicitWidth;
			var _local4:* = this._explicitHeight;
			var _local9:* = this._explicitMinWidth;
			var _local11:* = this._explicitMinHeight;
			if(_local3) {
				if(this._measureViewPort) {
					_local2 = this._viewPort.visibleWidth;
				} else {
					_local2 = 0;
				}
				_local2 += this._rightViewPortOffset + this._leftViewPortOffset;
				_local5 = this.header.width + this._outerPaddingLeft + this._outerPaddingRight;
				if(_local5 > _local2) {
					_local2 = _local5;
				}
				if(this.footer !== null) {
					_local8 = this.footer.width + this._outerPaddingLeft + this._outerPaddingRight;
					if(_local8 > _local2) {
						_local2 = _local8;
					}
				}
				if(this.currentBackgroundSkin !== null && this.currentBackgroundSkin.width > _local2) {
					_local2 = this.currentBackgroundSkin.width;
				}
			}
			if(_local12) {
				if(this._measureViewPort) {
					_local4 = this._viewPort.visibleHeight;
				} else {
					_local4 = 0;
				}
				if(this._icon !== null) {
					_local1 = this._icon.height;
					if(_local1 === _local1 && _local1 > _local4) {
						_local4 = _local1;
					}
				}
				_local4 += this._bottomViewPortOffset + this._topViewPortOffset;
				if(this.currentBackgroundSkin !== null && this.currentBackgroundSkin.height > _local4) {
					_local4 = this.currentBackgroundSkin.height;
				}
			}
			if(_local10) {
				if(this._measureViewPort) {
					_local9 = this._viewPort.minVisibleWidth;
				} else {
					_local9 = 0;
				}
				_local9 += this._rightViewPortOffset + this._leftViewPortOffset;
				_local13 = this.header.minWidth + this._outerPaddingLeft + this._outerPaddingRight;
				if(_local13 > _local9) {
					_local9 = _local13;
				}
				if(this.footer !== null) {
					_local7 = this.footer.minWidth + this._outerPaddingLeft + this._outerPaddingRight;
					if(_local7 > _local9) {
						_local9 = _local7;
					}
				}
				switch(_local6) {
					default:
						if(_local6.minWidth > _local9) {
							_local9 = _local6.minWidth;
						}
						break;
					case null:
						if(this._explicitBackgroundMinWidth > _local9) {
							_local9 = this._explicitBackgroundMinWidth;
						}
						break;
					case null:
				}
			}
			if(_local14) {
				if(this._measureViewPort) {
					_local11 = this._viewPort.minVisibleHeight;
				} else {
					_local11 = 0;
				}
				if(this._icon !== null) {
					_local1 = this._icon.height;
					if(_local1 === _local1 && _local1 > _local11) {
						_local11 = _local1;
					}
				}
				_local11 += this._bottomViewPortOffset + this._topViewPortOffset;
				switch(_local6) {
					default:
						if(_local6.minHeight > _local11) {
							_local11 = _local6.minHeight;
						}
						break;
					case null:
						if(this._explicitBackgroundMinHeight > _local11) {
							_local11 = this._explicitBackgroundMinHeight;
						}
						break;
					case null:
				}
			}
			return this.saveMeasurements(_local2,_local4,_local9,_local11);
		}
		
		override protected function createHeader() : void {
			super.createHeader();
			this.headerHeader = Header(this.header);
		}
		
		protected function createButtonGroup() : void {
			if(this.buttonGroupFooter) {
				this.buttonGroupFooter.removeEventListener("triggered",buttonsFooter_triggeredHandler);
			}
			super.createFooter();
			this.buttonGroupFooter = ButtonGroup(this.footer);
			this.buttonGroupFooter.addEventListener("triggered",buttonsFooter_triggeredHandler);
		}
		
		override protected function createFooter() : void {
			this.createButtonGroup();
		}
		
		protected function createMessage() : void {
			if(this.messageTextRenderer) {
				this.removeChild(DisplayObject(this.messageTextRenderer),true);
				this.messageTextRenderer = null;
			}
			var _local1:Function = this._messageFactory != null ? this._messageFactory : FeathersControl.defaultTextRendererFactory;
			this.messageTextRenderer = ITextRenderer(_local1());
			var _local2:String = this._customMessageStyleName != null ? this._customMessageStyleName : this.messageStyleName;
			var _local3:IFeathersControl = IFeathersControl(this.messageTextRenderer);
			_local3.styleNameList.add(_local2);
			_local3.touchable = false;
			this.addChild(DisplayObject(this.messageTextRenderer));
		}
		
		override protected function refreshFooterStyles() : void {
			super.refreshFooterStyles();
			this.buttonGroupFooter.dataProvider = this._buttonsDataProvider;
		}
		
		protected function refreshMessageStyles() : void {
			var _local2:Object = null;
			for(var _local1 in this._messageProperties) {
				_local2 = this._messageProperties[_local1];
				this.messageTextRenderer[_local1] = _local2;
			}
		}
		
		override protected function calculateViewPortOffsets(forceScrollBars:Boolean = false, useActualBounds:Boolean = false) : void {
			var _local3:Number = NaN;
			super.calculateViewPortOffsets(forceScrollBars,useActualBounds);
			if(this._icon !== null) {
				if(this._icon is IValidating) {
					IValidating(this._icon).validate();
				}
				_local3 = this._icon.width;
				if(_local3 === _local3) {
					this._leftViewPortOffset += _local3 + this._gap;
				}
			}
		}
		
		protected function buttonsFooter_triggeredHandler(event:Event, data:Object) : void {
			this.removeFromParent();
			this.dispatchEventWith("close",false,data);
			this.dispose();
		}
		
		protected function icon_resizeHandler(event:Event) : void {
			this.invalidate("layout");
		}
	}
}

