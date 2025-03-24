package feathers.controls {
	import feathers.core.IFeathersControl;
	import feathers.core.IFocusExtras;
	import feathers.core.IMeasureDisplayObject;
	import feathers.core.IValidating;
	import feathers.core.PropertyProxy;
	import feathers.skins.IStyleProvider;
	import feathers.utils.skins.resetFluidChildDimensionsForMeasurement;
	import starling.display.DisplayObject;
	import starling.events.Event;
	
	public class Panel extends ScrollContainer implements IFocusExtras {
		public static const DEFAULT_CHILD_STYLE_NAME_HEADER:String = "feathers-panel-header";
		
		public static const DEFAULT_CHILD_STYLE_NAME_FOOTER:String = "feathers-panel-footer";
		
		public static const SCROLL_POLICY_AUTO:String = "auto";
		
		public static const SCROLL_POLICY_ON:String = "on";
		
		public static const SCROLL_POLICY_OFF:String = "off";
		
		public static const SCROLL_BAR_DISPLAY_MODE_FLOAT:String = "float";
		
		public static const SCROLL_BAR_DISPLAY_MODE_FIXED:String = "fixed";
		
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
		
		public static const AUTO_SIZE_MODE_STAGE:String = "stage";
		
		public static const AUTO_SIZE_MODE_CONTENT:String = "content";
		
		public static var globalStyleProvider:IStyleProvider;
		
		protected static const INVALIDATION_FLAG_HEADER_FACTORY:String = "headerFactory";
		
		protected static const INVALIDATION_FLAG_FOOTER_FACTORY:String = "footerFactory";
		
		protected var header:IFeathersControl;
		
		protected var footer:IFeathersControl;
		
		protected var headerStyleName:String = "feathers-panel-header";
		
		protected var footerStyleName:String = "feathers-panel-footer";
		
		protected var _explicitHeaderWidth:Number;
		
		protected var _explicitHeaderHeight:Number;
		
		protected var _explicitHeaderMinWidth:Number;
		
		protected var _explicitHeaderMinHeight:Number;
		
		protected var _explicitFooterWidth:Number;
		
		protected var _explicitFooterHeight:Number;
		
		protected var _explicitFooterMinWidth:Number;
		
		protected var _explicitFooterMinHeight:Number;
		
		protected var _title:String = null;
		
		protected var _headerTitleField:String = "title";
		
		protected var _headerFactory:Function;
		
		protected var _customHeaderStyleName:String;
		
		protected var _headerProperties:PropertyProxy;
		
		protected var _footerFactory:Function;
		
		protected var _customFooterStyleName:String;
		
		protected var _footerProperties:PropertyProxy;
		
		private var _focusExtrasBefore:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
		
		private var _focusExtrasAfter:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
		
		protected var _outerPaddingTop:Number = 0;
		
		protected var _outerPaddingRight:Number = 0;
		
		protected var _outerPaddingBottom:Number = 0;
		
		protected var _outerPaddingLeft:Number = 0;
		
		protected var _ignoreHeaderResizing:Boolean = false;
		
		protected var _ignoreFooterResizing:Boolean = false;
		
		public function Panel() {
			super();
		}
		
		protected static function defaultHeaderFactory() : IFeathersControl {
			return new Header();
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return Panel.globalStyleProvider;
		}
		
		public function get title() : String {
			return this._title;
		}
		
		public function set title(value:String) : void {
			if(this._title == value) {
				return;
			}
			this._title = value;
			this.invalidate("styles");
		}
		
		public function get headerTitleField() : String {
			return this._headerTitleField;
		}
		
		public function set headerTitleField(value:String) : void {
			if(this._headerTitleField == value) {
				return;
			}
			this._headerTitleField = value;
			this.invalidate("styles");
		}
		
		public function get headerFactory() : Function {
			return this._headerFactory;
		}
		
		public function set headerFactory(value:Function) : void {
			if(this._headerFactory == value) {
				return;
			}
			this._headerFactory = value;
			this.invalidate("headerFactory");
			this.invalidate("size");
		}
		
		public function get customHeaderStyleName() : String {
			return this._customHeaderStyleName;
		}
		
		public function set customHeaderStyleName(value:String) : void {
			if(this._customHeaderStyleName == value) {
				return;
			}
			this._customHeaderStyleName = value;
			this.invalidate("headerFactory");
			this.invalidate("size");
		}
		
		public function get headerProperties() : Object {
			if(!this._headerProperties) {
				this._headerProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._headerProperties;
		}
		
		public function set headerProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._headerProperties == value) {
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
			if(this._headerProperties) {
				this._headerProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._headerProperties = PropertyProxy(value);
			if(this._headerProperties) {
				this._headerProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get footerFactory() : Function {
			return this._footerFactory;
		}
		
		public function set footerFactory(value:Function) : void {
			if(this._footerFactory == value) {
				return;
			}
			this._footerFactory = value;
			this.invalidate("footerFactory");
			this.invalidate("size");
		}
		
		public function get customFooterStyleName() : String {
			return this._customFooterStyleName;
		}
		
		public function set customFooterStyleName(value:String) : void {
			if(this._customFooterStyleName == value) {
				return;
			}
			this._customFooterStyleName = value;
			this.invalidate("footerFactory");
			this.invalidate("size");
		}
		
		public function get footerProperties() : Object {
			if(!this._footerProperties) {
				this._footerProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._footerProperties;
		}
		
		public function set footerProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._footerProperties == value) {
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
			if(this._footerProperties) {
				this._footerProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._footerProperties = PropertyProxy(value);
			if(this._footerProperties) {
				this._footerProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get focusExtrasBefore() : Vector.<DisplayObject> {
			return this._focusExtrasBefore;
		}
		
		public function get focusExtrasAfter() : Vector.<DisplayObject> {
			return this._focusExtrasAfter;
		}
		
		public function get outerPadding() : Number {
			return this._outerPaddingTop;
		}
		
		public function set outerPadding(value:Number) : void {
			this.outerPaddingTop = value;
			this.outerPaddingRight = value;
			this.outerPaddingBottom = value;
			this.outerPaddingLeft = value;
		}
		
		public function get outerPaddingTop() : Number {
			return this._outerPaddingTop;
		}
		
		public function set outerPaddingTop(value:Number) : void {
			if(this._outerPaddingTop == value) {
				return;
			}
			this._outerPaddingTop = value;
			this.invalidate("styles");
		}
		
		public function get outerPaddingRight() : Number {
			return this._outerPaddingRight;
		}
		
		public function set outerPaddingRight(value:Number) : void {
			if(this._outerPaddingRight == value) {
				return;
			}
			this._outerPaddingRight = value;
			this.invalidate("styles");
		}
		
		public function get outerPaddingBottom() : Number {
			return this._outerPaddingBottom;
		}
		
		public function set outerPaddingBottom(value:Number) : void {
			if(this._outerPaddingBottom == value) {
				return;
			}
			this._outerPaddingBottom = value;
			this.invalidate("styles");
		}
		
		public function get outerPaddingLeft() : Number {
			return this._outerPaddingLeft;
		}
		
		public function set outerPaddingLeft(value:Number) : void {
			if(this._outerPaddingLeft == value) {
				return;
			}
			this._outerPaddingLeft = value;
			this.invalidate("styles");
		}
		
		override protected function draw() : void {
			var _local2:Boolean = this.isInvalid("headerFactory");
			var _local1:Boolean = this.isInvalid("footerFactory");
			var _local3:Boolean = this.isInvalid("styles");
			if(_local2) {
				this.createHeader();
			}
			if(_local1) {
				this.createFooter();
			}
			if(_local2 || _local3) {
				this.refreshHeaderStyles();
			}
			if(_local1 || _local3) {
				this.refreshFooterStyles();
			}
			super.draw();
		}
		
		override protected function autoSizeIfNeeded() : Boolean {
			var _local4:Number = NaN;
			var _local7:Number = NaN;
			var _local12:Number = NaN;
			var _local6:Number = NaN;
			if(this._autoSizeMode === "stage") {
				return super.autoSizeIfNeeded();
			}
			var _local2:* = this._explicitWidth !== this._explicitWidth;
			var _local11:* = this._explicitHeight !== this._explicitHeight;
			var _local9:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local13:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local2 && !_local11 && !_local9 && !_local13) {
				return false;
			}
			resetFluidChildDimensionsForMeasurement(this.currentBackgroundSkin,this._explicitWidth,this._explicitHeight,this._explicitMinWidth,this._explicitMinHeight,this._explicitMaxWidth,this._explicitMaxHeight,this._explicitBackgroundWidth,this._explicitBackgroundHeight,this._explicitBackgroundMinWidth,this._explicitBackgroundMinHeight,this._explicitBackgroundMaxWidth,this._explicitBackgroundMaxHeight);
			var _local5:IMeasureDisplayObject = this.currentBackgroundSkin as IMeasureDisplayObject;
			if(this.currentBackgroundSkin is IValidating) {
				IValidating(this.currentBackgroundSkin).validate();
			}
			var _local1:* = this._explicitWidth;
			var _local3:Number = this._explicitHeight;
			var _local8:* = this._explicitMinWidth;
			var _local10:Number = this._explicitMinHeight;
			if(_local2) {
				if(this._measureViewPort) {
					_local1 = this._viewPort.visibleWidth;
				} else {
					_local1 = 0;
				}
				_local1 += this._rightViewPortOffset + this._leftViewPortOffset;
				_local4 = this.header.width + this._outerPaddingLeft + this._outerPaddingRight;
				if(_local4 > _local1) {
					_local1 = _local4;
				}
				if(this.footer !== null) {
					_local7 = this.footer.width + this._outerPaddingLeft + this._outerPaddingRight;
					if(_local7 > _local1) {
						_local1 = _local7;
					}
				}
				if(this.currentBackgroundSkin !== null && this.currentBackgroundSkin.width > _local1) {
					_local1 = this.currentBackgroundSkin.width;
				}
			}
			if(_local11) {
				if(this._measureViewPort) {
					_local3 = this._viewPort.visibleHeight;
				} else {
					_local3 = 0;
				}
				_local3 += this._bottomViewPortOffset + this._topViewPortOffset;
				if(this.currentBackgroundSkin !== null && this.currentBackgroundSkin.height > _local3) {
					_local3 = this.currentBackgroundSkin.height;
				}
			}
			if(_local9) {
				if(this._measureViewPort) {
					_local8 = this._viewPort.minVisibleWidth;
				} else {
					_local8 = 0;
				}
				_local8 += this._rightViewPortOffset + this._leftViewPortOffset;
				_local12 = this.header.minWidth + this._outerPaddingLeft + this._outerPaddingRight;
				if(_local12 > _local8) {
					_local8 = _local12;
				}
				if(this.footer !== null) {
					_local6 = this.footer.minWidth + this._outerPaddingLeft + this._outerPaddingRight;
					if(_local6 > _local8) {
						_local8 = _local6;
					}
				}
				switch(_local5) {
					default:
						if(_local5.minWidth > _local8) {
							_local8 = _local5.minWidth;
						}
						break;
					case null:
						if(this._explicitBackgroundMinWidth > _local8) {
							_local8 = this._explicitBackgroundMinWidth;
						}
						break;
					case null:
				}
			}
			if(_local13) {
				if(this._measureViewPort) {
					_local10 = this._viewPort.minVisibleHeight;
				} else {
					_local10 = 0;
				}
				_local10 += this._bottomViewPortOffset + this._topViewPortOffset;
				switch(_local5) {
					default:
						if(_local5.minHeight > _local10) {
							_local10 = _local5.minHeight;
						}
						break;
					case null:
						if(this._explicitBackgroundMinHeight > _local10) {
							_local10 = this._explicitBackgroundMinHeight;
						}
						break;
					case null:
				}
			}
			return this.saveMeasurements(_local1,_local3,_local8,_local10);
		}
		
		protected function createHeader() : void {
			var _local3:DisplayObject = null;
			if(this.header !== null) {
				this.header.removeEventListener("resize",header_resizeHandler);
				_local3 = DisplayObject(this.header);
				this._focusExtrasBefore.splice(this._focusExtrasBefore.indexOf(_local3),1);
				this.removeRawChild(_local3,true);
				this.header = null;
			}
			var _local1:Function = this._headerFactory != null ? this._headerFactory : defaultHeaderFactory;
			var _local2:String = this._customHeaderStyleName != null ? this._customHeaderStyleName : this.headerStyleName;
			this.header = IFeathersControl(_local1());
			this.header.styleNameList.add(_local2);
			this.header.addEventListener("resize",header_resizeHandler);
			_local3 = DisplayObject(this.header);
			this.addRawChild(_local3);
			this._focusExtrasBefore.push(_local3);
			this.header.initializeNow();
			this._explicitHeaderWidth = this.header.explicitWidth;
			this._explicitHeaderHeight = this.header.explicitHeight;
			this._explicitHeaderMinWidth = this.header.explicitMinWidth;
			this._explicitHeaderMinHeight = this.header.explicitMinHeight;
		}
		
		protected function createFooter() : void {
			var _local1:DisplayObject = null;
			if(this.footer !== null) {
				this.footer.removeEventListener("resize",footer_resizeHandler);
				_local1 = DisplayObject(this.footer);
				this._focusExtrasAfter.splice(this._focusExtrasAfter.indexOf(_local1),1);
				this.removeRawChild(_local1,true);
				this.footer = null;
			}
			if(this._footerFactory === null) {
				return;
			}
			var _local2:String = this._customFooterStyleName != null ? this._customFooterStyleName : this.footerStyleName;
			this.footer = IFeathersControl(this._footerFactory());
			this.footer.styleNameList.add(_local2);
			this.footer.addEventListener("resize",footer_resizeHandler);
			_local1 = DisplayObject(this.footer);
			this.addRawChild(_local1);
			this._focusExtrasAfter.push(_local1);
			this.footer.initializeNow();
			this._explicitFooterWidth = this.footer.explicitWidth;
			this._explicitFooterHeight = this.footer.explicitHeight;
			this._explicitFooterMinWidth = this.footer.explicitMinWidth;
			this._explicitFooterMinHeight = this.footer.explicitMinHeight;
		}
		
		protected function refreshHeaderStyles() : void {
			var _local2:Object = null;
			if(Object(this.header).hasOwnProperty(this._headerTitleField)) {
				this.header[this._headerTitleField] = this._title;
			}
			for(var _local1 in this._headerProperties) {
				_local2 = this._headerProperties[_local1];
				this.header[_local1] = _local2;
			}
		}
		
		protected function refreshFooterStyles() : void {
			var _local2:Object = null;
			for(var _local1 in this._footerProperties) {
				_local2 = this._footerProperties[_local1];
				this.footer[_local1] = _local2;
			}
		}
		
		override protected function calculateViewPortOffsets(forceScrollBars:Boolean = false, useActualBounds:Boolean = false) : void {
			var _local3:Boolean = false;
			super.calculateViewPortOffsets(forceScrollBars);
			this._leftViewPortOffset += this._outerPaddingLeft;
			this._rightViewPortOffset += this._outerPaddingRight;
			var _local4:Boolean = this._ignoreHeaderResizing;
			this._ignoreHeaderResizing = true;
			if(useActualBounds) {
				this.header.width = this.actualWidth - this._outerPaddingLeft - this._outerPaddingRight;
				this.header.minWidth = this.actualMinWidth - this._outerPaddingLeft - this._outerPaddingRight;
			} else {
				this.header.width = this._explicitWidth - this._outerPaddingLeft - this._outerPaddingRight;
				this.header.minWidth = this._explicitMinWidth - this._outerPaddingLeft - this._outerPaddingRight;
			}
			this.header.maxWidth = this._explicitMaxWidth - this._outerPaddingLeft - this._outerPaddingRight;
			this.header.height = this._explicitHeaderHeight;
			this.header.minHeight = this._explicitHeaderMinHeight;
			this.header.validate();
			this._topViewPortOffset += this.header.height + this._outerPaddingTop;
			this._ignoreHeaderResizing = _local4;
			if(this.footer !== null) {
				_local3 = this._ignoreFooterResizing;
				this._ignoreFooterResizing = true;
				if(useActualBounds) {
					this.footer.width = this.actualWidth - this._outerPaddingLeft - this._outerPaddingRight;
					this.footer.minWidth = this.actualMinWidth - this._outerPaddingLeft - this._outerPaddingRight;
				} else {
					this.footer.width = this._explicitWidth - this._outerPaddingLeft - this._outerPaddingRight;
					this.footer.minWidth = this._explicitMinWidth - this._outerPaddingLeft - this._outerPaddingRight;
				}
				this.footer.maxWidth = this._explicitMaxWidth - this._outerPaddingLeft - this._outerPaddingRight;
				this.footer.height = this._explicitFooterHeight;
				this.footer.minHeight = this._explicitFooterMinHeight;
				this.footer.validate();
				this._bottomViewPortOffset += this.footer.height + this._outerPaddingBottom;
				this._ignoreFooterResizing = _local3;
			} else {
				this._bottomViewPortOffset += this._outerPaddingBottom;
			}
		}
		
		override protected function layoutChildren() : void {
			var _local1:Boolean = false;
			super.layoutChildren();
			var _local2:Boolean = this._ignoreHeaderResizing;
			this._ignoreHeaderResizing = true;
			this.header.x = this._outerPaddingLeft;
			this.header.y = this._outerPaddingTop;
			this.header.width = this.actualWidth - this._outerPaddingLeft - this._outerPaddingRight;
			this.header.height = this._explicitHeaderHeight;
			this.header.validate();
			this._ignoreHeaderResizing = _local2;
			if(this.footer !== null) {
				_local1 = this._ignoreFooterResizing;
				this._ignoreFooterResizing = true;
				this.footer.x = this._outerPaddingLeft;
				this.footer.width = this.actualWidth - this._outerPaddingLeft - this._outerPaddingRight;
				this.footer.height = this._explicitFooterHeight;
				this.footer.validate();
				this.footer.y = this.actualHeight - this.footer.height - this._outerPaddingBottom;
				this._ignoreFooterResizing = _local1;
			}
		}
		
		protected function header_resizeHandler(event:Event) : void {
			if(this._ignoreHeaderResizing) {
				return;
			}
			this.invalidate("size");
		}
		
		protected function footer_resizeHandler(event:Event) : void {
			if(this._ignoreFooterResizing) {
				return;
			}
			this.invalidate("size");
		}
	}
}

