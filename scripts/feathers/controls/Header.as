package feathers.controls {
	import feathers.core.FeathersControl;
	import feathers.core.IFeathersControl;
	import feathers.core.IMeasureDisplayObject;
	import feathers.core.ITextRenderer;
	import feathers.core.IValidating;
	import feathers.core.PropertyProxy;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.LayoutBoundsResult;
	import feathers.layout.ViewPortBounds;
	import feathers.skins.IStyleProvider;
	import feathers.system.DeviceCapabilities;
	import feathers.utils.skins.resetFluidChildDimensionsForMeasurement;
	import flash.display.Stage;
	import flash.events.FullScreenEvent;
	import flash.geom.Point;
	import flash.system.Capabilities;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.Event;
	
	public class Header extends FeathersControl {
		protected static const INVALIDATION_FLAG_LEFT_CONTENT:String = "leftContent";
		
		protected static const INVALIDATION_FLAG_RIGHT_CONTENT:String = "rightContent";
		
		protected static const INVALIDATION_FLAG_CENTER_CONTENT:String = "centerContent";
		
		protected static const IOS_STATUS_BAR_HEIGHT:Number = 20;
		
		protected static const IPAD_1X_DPI:Number = 132;
		
		protected static const IPHONE_1X_DPI:Number = 163;
		
		protected static const IOS_NAME_PREFIX:String = "iPhone OS ";
		
		protected static const STATUS_BAR_MIN_IOS_VERSION:int = 7;
		
		public static var globalStyleProvider:IStyleProvider;
		
		public static const TITLE_ALIGN_CENTER:String = "center";
		
		public static const TITLE_ALIGN_PREFER_LEFT:String = "preferLeft";
		
		public static const TITLE_ALIGN_PREFER_RIGHT:String = "preferRight";
		
		public static const VERTICAL_ALIGN_TOP:String = "top";
		
		public static const VERTICAL_ALIGN_MIDDLE:String = "middle";
		
		public static const VERTICAL_ALIGN_BOTTOM:String = "bottom";
		
		public static const DEFAULT_CHILD_STYLE_NAME_ITEM:String = "feathers-header-item";
		
		public static const DEFAULT_CHILD_STYLE_NAME_TITLE:String = "feathers-header-title";
		
		private static const HELPER_BOUNDS:ViewPortBounds = new ViewPortBounds();
		
		private static const HELPER_LAYOUT_RESULT:LayoutBoundsResult = new LayoutBoundsResult();
		
		private static const HELPER_POINT:Point = new Point();
		
		protected var titleTextRenderer:ITextRenderer;
		
		protected var titleStyleName:String = "feathers-header-title";
		
		protected var itemStyleName:String = "feathers-header-item";
		
		protected var leftItemsWidth:Number = 0;
		
		protected var rightItemsWidth:Number = 0;
		
		protected var _layout:HorizontalLayout;
		
		protected var _title:String = null;
		
		protected var _titleFactory:Function;
		
		protected var _disposeItems:Boolean = true;
		
		protected var _leftItems:Vector.<DisplayObject>;
		
		protected var _centerItems:Vector.<DisplayObject>;
		
		protected var _rightItems:Vector.<DisplayObject>;
		
		protected var _paddingTop:Number = 0;
		
		protected var _paddingRight:Number = 0;
		
		protected var _paddingBottom:Number = 0;
		
		protected var _paddingLeft:Number = 0;
		
		protected var _gap:Number = 0;
		
		protected var _titleGap:Number = NaN;
		
		protected var _useExtraPaddingForOSStatusBar:Boolean = false;
		
		protected var _verticalAlign:String = "middle";
		
		protected var currentBackgroundSkin:DisplayObject;
		
		protected var _explicitBackgroundWidth:Number;
		
		protected var _explicitBackgroundHeight:Number;
		
		protected var _explicitBackgroundMinWidth:Number;
		
		protected var _explicitBackgroundMinHeight:Number;
		
		protected var _explicitBackgroundMaxWidth:Number;
		
		protected var _explicitBackgroundMaxHeight:Number;
		
		protected var _backgroundSkin:DisplayObject;
		
		protected var _backgroundDisabledSkin:DisplayObject;
		
		protected var _customTitleStyleName:String;
		
		protected var _titleProperties:PropertyProxy;
		
		protected var _titleAlign:String = "center";
		
		public function Header() {
			super();
			this.addEventListener("addedToStage",header_addedToStageHandler);
			this.addEventListener("removedFromStage",header_removedFromStageHandler);
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return Header.globalStyleProvider;
		}
		
		public function get title() : String {
			return this._title;
		}
		
		public function set title(value:String) : void {
			if(this._title === value) {
				return;
			}
			this._title = value;
			this.invalidate("data");
		}
		
		public function get titleFactory() : Function {
			return this._titleFactory;
		}
		
		public function set titleFactory(value:Function) : void {
			if(this._titleFactory == value) {
				return;
			}
			this._titleFactory = value;
			this.invalidate("textRenderer");
		}
		
		public function get disposeItems() : Boolean {
			return this._disposeItems;
		}
		
		public function set disposeItems(value:Boolean) : void {
			this._disposeItems = value;
		}
		
		public function get leftItems() : Vector.<DisplayObject> {
			return this._leftItems;
		}
		
		public function set leftItems(value:Vector.<DisplayObject>) : void {
			if(this._leftItems == value) {
				return;
			}
			if(this._leftItems) {
				for each(var _local2 in this._leftItems) {
					if(_local2 is IFeathersControl) {
						IFeathersControl(_local2).styleNameList.remove(this.itemStyleName);
						_local2.removeEventListener("resize",item_resizeHandler);
					}
					_local2.removeFromParent();
				}
			}
			this._leftItems = value;
			if(this._leftItems) {
				for each(_local2 in this._leftItems) {
					if(_local2 is IFeathersControl) {
						_local2.addEventListener("resize",item_resizeHandler);
					}
				}
			}
			this.invalidate("leftContent");
		}
		
		public function get centerItems() : Vector.<DisplayObject> {
			return this._centerItems;
		}
		
		public function set centerItems(value:Vector.<DisplayObject>) : void {
			if(this._centerItems == value) {
				return;
			}
			if(this._centerItems) {
				for each(var _local2 in this._centerItems) {
					if(_local2 is IFeathersControl) {
						IFeathersControl(_local2).styleNameList.remove(this.itemStyleName);
						_local2.removeEventListener("resize",item_resizeHandler);
					}
					_local2.removeFromParent();
				}
			}
			this._centerItems = value;
			if(this._centerItems) {
				for each(_local2 in this._centerItems) {
					if(_local2 is IFeathersControl) {
						_local2.addEventListener("resize",item_resizeHandler);
					}
				}
			}
			this.invalidate("centerContent");
		}
		
		public function get rightItems() : Vector.<DisplayObject> {
			return this._rightItems;
		}
		
		public function set rightItems(value:Vector.<DisplayObject>) : void {
			if(this._rightItems == value) {
				return;
			}
			if(this._rightItems) {
				for each(var _local2 in this._rightItems) {
					if(_local2 is IFeathersControl) {
						IFeathersControl(_local2).styleNameList.remove(this.itemStyleName);
						_local2.removeEventListener("resize",item_resizeHandler);
					}
					_local2.removeFromParent();
				}
			}
			this._rightItems = value;
			if(this._rightItems) {
				for each(_local2 in this._rightItems) {
					if(_local2 is IFeathersControl) {
						_local2.addEventListener("resize",item_resizeHandler);
					}
				}
			}
			this.invalidate("rightContent");
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
		
		public function get gap() : Number {
			return _gap;
		}
		
		public function set gap(value:Number) : void {
			if(this._gap == value) {
				return;
			}
			this._gap = value;
			this.invalidate("styles");
		}
		
		public function get titleGap() : Number {
			return _titleGap;
		}
		
		public function set titleGap(value:Number) : void {
			if(this._titleGap == value) {
				return;
			}
			this._titleGap = value;
			this.invalidate("styles");
		}
		
		public function get useExtraPaddingForOSStatusBar() : Boolean {
			return this._useExtraPaddingForOSStatusBar;
		}
		
		public function set useExtraPaddingForOSStatusBar(value:Boolean) : void {
			if(this._useExtraPaddingForOSStatusBar == value) {
				return;
			}
			this._useExtraPaddingForOSStatusBar = value;
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
		
		public function get backgroundSkin() : DisplayObject {
			return this._backgroundSkin;
		}
		
		public function set backgroundSkin(value:DisplayObject) : void {
			if(this._backgroundSkin == value) {
				return;
			}
			if(this._backgroundSkin && this._backgroundSkin != this._backgroundDisabledSkin) {
				this.removeChild(this._backgroundSkin);
			}
			this._backgroundSkin = value;
			if(this._backgroundSkin && this._backgroundSkin.parent != this) {
				this._backgroundSkin.visible = false;
				this.addChildAt(this._backgroundSkin,0);
			}
			this.invalidate("styles");
		}
		
		public function get backgroundDisabledSkin() : DisplayObject {
			return this._backgroundDisabledSkin;
		}
		
		public function set backgroundDisabledSkin(value:DisplayObject) : void {
			if(this._backgroundDisabledSkin == value) {
				return;
			}
			if(this._backgroundDisabledSkin && this._backgroundDisabledSkin != this._backgroundSkin) {
				this.removeChild(this._backgroundDisabledSkin);
			}
			this._backgroundDisabledSkin = value;
			if(this._backgroundDisabledSkin && this._backgroundDisabledSkin.parent != this) {
				this._backgroundDisabledSkin.visible = false;
				this.addChildAt(this._backgroundDisabledSkin,0);
			}
			this.invalidate("styles");
		}
		
		public function get customTitleStyleName() : String {
			return this._customTitleStyleName;
		}
		
		public function set customTitleStyleName(value:String) : void {
			if(this._customTitleStyleName == value) {
				return;
			}
			this._customTitleStyleName = value;
			this.invalidate("textRenderer");
		}
		
		public function get titleProperties() : Object {
			if(!this._titleProperties) {
				this._titleProperties = new PropertyProxy(titleProperties_onChange);
			}
			return this._titleProperties;
		}
		
		public function set titleProperties(value:Object) : void {
			if(this._titleProperties == value) {
				return;
			}
			if(value && !(value is PropertyProxy)) {
				value = PropertyProxy.fromObject(value);
			}
			if(this._titleProperties) {
				this._titleProperties.removeOnChangeCallback(titleProperties_onChange);
			}
			this._titleProperties = PropertyProxy(value);
			if(this._titleProperties) {
				this._titleProperties.addOnChangeCallback(titleProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get titleAlign() : String {
			return this._titleAlign;
		}
		
		public function set titleAlign(value:String) : void {
			if(value === "preferLeft") {
				value = "left";
			} else if(value === "preferRight") {
				value = "right";
			}
			if(this._titleAlign == value) {
				return;
			}
			this._titleAlign = value;
			this.invalidate("styles");
		}
		
		override public function dispose() : void {
			if(this._disposeItems) {
				for each(var _local1 in this._leftItems) {
					_local1.dispose();
				}
				for each(_local1 in this._centerItems) {
					_local1.dispose();
				}
				for each(_local1 in this._rightItems) {
					_local1.dispose();
				}
			}
			this.leftItems = null;
			this.rightItems = null;
			this.centerItems = null;
			super.dispose();
		}
		
		override protected function initialize() : void {
			if(!this._layout) {
				this._layout = new HorizontalLayout();
				this._layout.useVirtualLayout = false;
				this._layout.verticalAlign = "middle";
			}
		}
		
		override protected function draw() : void {
			var _local1:Boolean = this.isInvalid("size");
			var _local7:Boolean = this.isInvalid("data");
			var _local8:Boolean = this.isInvalid("styles");
			var _local3:Boolean = this.isInvalid("state");
			var _local9:Boolean = this.isInvalid("leftContent");
			var _local4:Boolean = this.isInvalid("rightContent");
			var _local6:Boolean = this.isInvalid("centerContent");
			var _local5:Boolean = this.isInvalid("textRenderer");
			if(_local5) {
				this.createTitle();
			}
			if(_local5 || _local7) {
				this.titleTextRenderer.text = this._title;
			}
			if(_local3 || _local8) {
				this.refreshBackground();
			}
			if(_local5 || _local8 || _local1) {
				this.refreshLayout();
			}
			if(_local5 || _local8) {
				this.refreshTitleStyles();
			}
			if(_local9) {
				if(this._leftItems) {
					for each(var _local2 in this._leftItems) {
						if(_local2 is IFeathersControl) {
							IFeathersControl(_local2).styleNameList.add(this.itemStyleName);
						}
						this.addChild(_local2);
					}
				}
			}
			if(_local4) {
				if(this._rightItems) {
					for each(_local2 in this._rightItems) {
						if(_local2 is IFeathersControl) {
							IFeathersControl(_local2).styleNameList.add(this.itemStyleName);
						}
						this.addChild(_local2);
					}
				}
			}
			if(_local6) {
				if(this._centerItems) {
					for each(_local2 in this._centerItems) {
						if(_local2 is IFeathersControl) {
							IFeathersControl(_local2).styleNameList.add(this.itemStyleName);
						}
						this.addChild(_local2);
					}
				}
			}
			if(_local3 || _local5) {
				this.refreshEnabled();
			}
			_local1 = this.autoSizeIfNeeded() || _local1;
			this.layoutBackground();
			if(_local1 || _local9 || _local4 || _local6 || _local8) {
				this.leftItemsWidth = 0;
				this.rightItemsWidth = 0;
				if(this._leftItems) {
					this.layoutLeftItems();
				}
				if(this._rightItems) {
					this.layoutRightItems();
				}
				if(this._centerItems) {
					this.layoutCenterItems();
				}
			}
			if(_local5 || _local1 || _local8 || _local7 || _local9 || _local4 || _local6) {
				this.layoutTitle();
			}
		}
		
		protected function autoSizeIfNeeded() : Boolean {
			var _local12:int = 0;
			var _local9:int = 0;
			var _local1:DisplayObject = null;
			var _local21:Number = NaN;
			var _local7:Number = NaN;
			var _local2:Number = NaN;
			var _local8:Number = NaN;
			var _local16:Number = NaN;
			var _local3:Number = NaN;
			var _local5:* = this._explicitWidth !== this._explicitWidth;
			var _local20:* = this._explicitHeight !== this._explicitHeight;
			var _local15:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local24:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local5 && !_local20 && !_local15 && !_local24) {
				return false;
			}
			resetFluidChildDimensionsForMeasurement(this.currentBackgroundSkin,this._explicitWidth,this._explicitHeight,this._explicitMinWidth,this._explicitMinHeight,this._explicitMaxWidth,this._explicitMaxHeight,this._explicitBackgroundWidth,this._explicitBackgroundHeight,this._explicitBackgroundMinWidth,this._explicitBackgroundMinHeight,this._explicitBackgroundMaxWidth,this._explicitBackgroundMaxHeight);
			var _local22:IMeasureDisplayObject = this.currentBackgroundSkin as IMeasureDisplayObject;
			if(this.currentBackgroundSkin is IValidating) {
				IValidating(this.currentBackgroundSkin).validate();
			}
			var _local10:Number = this.calculateExtraOSStatusBarPadding();
			var _local11:Number = 0;
			var _local18:* = 0;
			var _local23:Boolean = this._leftItems !== null && this._leftItems.length > 0;
			var _local13:Boolean = this._rightItems !== null && this._rightItems.length > 0;
			var _local19:Boolean = this._centerItems !== null && this._centerItems.length > 0;
			if(_local23) {
				_local12 = int(this._leftItems.length);
				_local9 = 0;
				while(_local9 < _local12) {
					_local1 = this._leftItems[_local9];
					if(_local1 is IValidating) {
						IValidating(_local1).validate();
					}
					_local21 = _local1.width;
					if(_local21 === _local21) {
						_local11 += _local21;
						if(_local9 > 0) {
							_local11 += this._gap;
						}
					}
					_local7 = _local1.height;
					if(_local7 === _local7 && _local7 > _local18) {
						_local18 = _local7;
					}
					_local9++;
				}
			}
			if(_local19) {
				_local12 = int(this._centerItems.length);
				_local9 = 0;
				while(_local9 < _local12) {
					_local1 = this._centerItems[_local9];
					if(_local1 is IValidating) {
						IValidating(_local1).validate();
					}
					_local21 = _local1.width;
					if(_local21 === _local21) {
						_local11 += _local21;
						if(_local9 > 0) {
							_local11 += this._gap;
						}
					}
					_local7 = _local1.height;
					if(_local7 === _local7 && _local7 > _local18) {
						_local18 = _local7;
					}
					_local9++;
				}
			}
			if(_local13) {
				_local12 = int(this._rightItems.length);
				_local9 = 0;
				while(_local9 < _local12) {
					_local1 = this._rightItems[_local9];
					if(_local1 is IValidating) {
						IValidating(_local1).validate();
					}
					_local21 = _local1.width;
					if(_local21 === _local21) {
						_local11 += _local21;
						if(_local9 > 0) {
							_local11 += this._gap;
						}
					}
					_local7 = _local1.height;
					if(_local7 === _local7 && _local7 > _local18) {
						_local18 = _local7;
					}
					_local9++;
				}
			}
			if(this._titleAlign === "center" && _local19) {
				if(_local23) {
					_local11 += this._gap;
				}
				if(_local13) {
					_local11 += this._gap;
				}
			} else {
				switch(_local2) {
					default:
						_local2 = this._gap;
					case _local2:
						_local8 = this._explicitWidth;
						if(_local5) {
							_local8 = this._explicitMaxWidth;
						}
						_local8 -= _local11;
						if(_local23) {
							_local8 -= _local2;
						}
						if(_local19) {
							_local8 -= _local2;
						}
						if(_local13) {
							_local8 -= _local2;
						}
						if(_local8 < 0) {
							_local8 = 0;
						}
						this.titleTextRenderer.maxWidth = _local8;
						this.titleTextRenderer.measureText(HELPER_POINT);
						_local16 = HELPER_POINT.x;
						_local3 = HELPER_POINT.y;
						if(_local16 === _local16) {
							if(_local23) {
								_local16 += _local2;
							}
							if(_local13) {
								_local16 += _local2;
							}
						} else {
							_local16 = 0;
						}
						_local11 += _local16;
						if(_local3 === _local3 && _local3 > _local18) {
							_local18 = _local3;
						}
						break;
					case null:
				}
			}
			var _local4:Number = this._explicitWidth;
			if(_local5) {
				_local4 = _local11 + this._paddingLeft + this._paddingRight;
				if(this.currentBackgroundSkin !== null && this.currentBackgroundSkin.width > _local4) {
					_local4 = this.currentBackgroundSkin.width;
				}
			}
			var _local6:* = this._explicitHeight;
			if(_local20) {
				_local6 = _local18;
				_local6 = _local6 + (this._paddingTop + this._paddingBottom);
				if(_local10 > 0) {
					if(_local6 < this._explicitMinHeight) {
						_local6 = this._explicitMinHeight;
					}
					_local6 += _local10;
				}
				if(this.currentBackgroundSkin !== null && this.currentBackgroundSkin.height > _local6) {
					_local6 = this.currentBackgroundSkin.height;
				}
			}
			var _local14:Number = this._explicitMinWidth;
			if(_local15) {
				_local14 = _local11 + this._paddingLeft + this._paddingRight;
				switch(_local22) {
					default:
						if(_local22.minWidth > _local14) {
							_local14 = _local22.minWidth;
						}
						break;
					case null:
						if(this._explicitBackgroundMinWidth > _local14) {
							_local14 = this._explicitBackgroundMinWidth;
						}
						break;
					case null:
				}
			}
			var _local17:* = this._explicitMinHeight;
			if(_local24) {
				_local17 = _local18;
				_local17 = _local17 + (this._paddingTop + this._paddingBottom);
				if(_local10 > 0) {
					if(_local17 < this._explicitMinHeight) {
						_local17 = this._explicitMinHeight;
					}
					_local17 += _local10;
				}
				switch(_local22) {
					default:
						if(_local22.minHeight > _local17) {
							_local17 = _local22.minHeight;
						}
						break;
					case null:
						if(this._explicitBackgroundMinHeight > _local17) {
							_local17 = this._explicitBackgroundMinHeight;
						}
						break;
					case null:
				}
			}
			return this.saveMeasurements(_local4,_local6,_local14,_local17);
		}
		
		protected function createTitle() : void {
			if(this.titleTextRenderer) {
				this.removeChild(DisplayObject(this.titleTextRenderer),true);
				this.titleTextRenderer = null;
			}
			var _local1:Function = this._titleFactory != null ? this._titleFactory : FeathersControl.defaultTextRendererFactory;
			this.titleTextRenderer = ITextRenderer(_local1());
			var _local2:IFeathersControl = IFeathersControl(this.titleTextRenderer);
			var _local3:String = this._customTitleStyleName != null ? this._customTitleStyleName : this.titleStyleName;
			_local2.styleNameList.add(_local3);
			this.addChild(DisplayObject(_local2));
		}
		
		protected function refreshBackground() : void {
			var _local1:IMeasureDisplayObject = null;
			this.currentBackgroundSkin = this._backgroundSkin;
			if(!this._isEnabled && this._backgroundDisabledSkin) {
				if(this._backgroundSkin !== null) {
					this._backgroundSkin.visible = false;
				}
				this.currentBackgroundSkin = this._backgroundDisabledSkin;
			} else if(this._backgroundDisabledSkin !== null) {
				this._backgroundDisabledSkin.visible = false;
			}
			if(this.currentBackgroundSkin !== null) {
				this.currentBackgroundSkin.visible = true;
				if(this.currentBackgroundSkin is IFeathersControl) {
					IFeathersControl(this.currentBackgroundSkin).initializeNow();
				}
				if(this.currentBackgroundSkin is IMeasureDisplayObject) {
					_local1 = IMeasureDisplayObject(this.currentBackgroundSkin);
					this._explicitBackgroundWidth = _local1.explicitWidth;
					this._explicitBackgroundHeight = _local1.explicitHeight;
					this._explicitBackgroundMinWidth = _local1.explicitMinWidth;
					this._explicitBackgroundMinHeight = _local1.explicitMinHeight;
					this._explicitBackgroundMaxWidth = _local1.explicitMaxWidth;
					this._explicitBackgroundMaxHeight = _local1.explicitMaxHeight;
				} else {
					this._explicitBackgroundWidth = this.currentBackgroundSkin.width;
					this._explicitBackgroundHeight = this.currentBackgroundSkin.height;
					this._explicitBackgroundMinWidth = this._explicitBackgroundWidth;
					this._explicitBackgroundMinHeight = this._explicitBackgroundHeight;
					this._explicitBackgroundMaxWidth = this._explicitBackgroundWidth;
					this._explicitBackgroundMaxHeight = this._explicitBackgroundHeight;
				}
			}
		}
		
		protected function refreshLayout() : void {
			this._layout.gap = this._gap;
			this._layout.paddingTop = this._paddingTop + this.calculateExtraOSStatusBarPadding();
			this._layout.paddingBottom = this._paddingBottom;
			this._layout.verticalAlign = this._verticalAlign;
		}
		
		protected function refreshEnabled() : void {
			this.titleTextRenderer.isEnabled = this._isEnabled;
		}
		
		protected function refreshTitleStyles() : void {
			var _local2:Object = null;
			for(var _local1 in this._titleProperties) {
				_local2 = this._titleProperties[_local1];
				this.titleTextRenderer[_local1] = _local2;
			}
		}
		
		protected function calculateExtraOSStatusBarPadding() : Number {
			if(!this._useExtraPaddingForOSStatusBar) {
				return 0;
			}
			var _local2:String = Capabilities.os;
			if(_local2.indexOf("iPhone OS ") != 0 || parseInt(_local2.substr("iPhone OS ".length,1),10) < 7) {
				return 0;
			}
			var _local1:Stage = Starling.current.nativeStage;
			if(_local1.displayState != "normal") {
				return 0;
			}
			if(DeviceCapabilities.dpi % 132 === 0) {
				return 20 * Math.floor(DeviceCapabilities.dpi / 132) / Starling.current.contentScaleFactor;
			}
			return 20 * Math.floor(DeviceCapabilities.dpi / 163) / Starling.current.contentScaleFactor;
		}
		
		protected function layoutBackground() : void {
			if(!this.currentBackgroundSkin) {
				return;
			}
			this.currentBackgroundSkin.width = this.actualWidth;
			this.currentBackgroundSkin.height = this.actualHeight;
		}
		
		protected function layoutLeftItems() : void {
			for each(var _local1 in this._leftItems) {
				if(_local1 is IValidating) {
					IValidating(_local1).validate();
				}
			}
			HELPER_BOUNDS.x = HELPER_BOUNDS.y = 0;
			HELPER_BOUNDS.scrollX = HELPER_BOUNDS.scrollY = 0;
			HELPER_BOUNDS.explicitWidth = this.actualWidth;
			HELPER_BOUNDS.explicitHeight = this.actualHeight;
			this._layout.horizontalAlign = "left";
			this._layout.paddingRight = 0;
			this._layout.paddingLeft = this._paddingLeft;
			this._layout.layout(this._leftItems,HELPER_BOUNDS,HELPER_LAYOUT_RESULT);
			this.leftItemsWidth = HELPER_LAYOUT_RESULT.contentWidth;
			if(this.leftItemsWidth !== this.leftItemsWidth) {
				this.leftItemsWidth = 0;
			}
		}
		
		protected function layoutRightItems() : void {
			for each(var _local1 in this._rightItems) {
				if(_local1 is IValidating) {
					IValidating(_local1).validate();
				}
			}
			HELPER_BOUNDS.x = HELPER_BOUNDS.y = 0;
			HELPER_BOUNDS.scrollX = HELPER_BOUNDS.scrollY = 0;
			HELPER_BOUNDS.explicitWidth = this.actualWidth;
			HELPER_BOUNDS.explicitHeight = this.actualHeight;
			this._layout.horizontalAlign = "right";
			this._layout.paddingRight = this._paddingRight;
			this._layout.paddingLeft = 0;
			this._layout.layout(this._rightItems,HELPER_BOUNDS,HELPER_LAYOUT_RESULT);
			this.rightItemsWidth = HELPER_LAYOUT_RESULT.contentWidth;
			if(this.rightItemsWidth !== this.rightItemsWidth) {
				this.rightItemsWidth = 0;
			}
		}
		
		protected function layoutCenterItems() : void {
			for each(var _local1 in this._centerItems) {
				if(_local1 is IValidating) {
					IValidating(_local1).validate();
				}
			}
			HELPER_BOUNDS.x = HELPER_BOUNDS.y = 0;
			HELPER_BOUNDS.scrollX = HELPER_BOUNDS.scrollY = 0;
			HELPER_BOUNDS.explicitWidth = this.actualWidth;
			HELPER_BOUNDS.explicitHeight = this.actualHeight;
			this._layout.horizontalAlign = "center";
			this._layout.paddingRight = this._paddingRight;
			this._layout.paddingLeft = this._paddingLeft;
			this._layout.layout(this._centerItems,HELPER_BOUNDS,HELPER_LAYOUT_RESULT);
		}
		
		protected function layoutTitle() : void {
			var _local7:Number = NaN;
			var _local8:Number = NaN;
			var _local11:Number = NaN;
			var _local6:Number = NaN;
			var _local10:Boolean = this._leftItems !== null && this._leftItems.length > 0;
			var _local1:Boolean = this._rightItems !== null && this._rightItems.length > 0;
			var _local4:Boolean = this._centerItems !== null && this._centerItems.length > 0;
			if(this._titleAlign === "center" && _local4) {
				this.titleTextRenderer.visible = false;
				return;
			}
			if(this._titleAlign === "left" && _local10 && _local4) {
				this.titleTextRenderer.visible = false;
				return;
			}
			if(this._titleAlign === "right" && _local1 && _local4) {
				this.titleTextRenderer.visible = false;
				return;
			}
			this.titleTextRenderer.visible = true;
			var _local2:Number = this._titleGap;
			if(_local2 !== _local2) {
				_local2 = this._gap;
			}
			var _local5:Number = this._paddingLeft;
			if(_local10) {
				_local5 = this.leftItemsWidth + _local2;
			}
			var _local3:Number = this._paddingRight;
			if(_local1) {
				_local3 = this.rightItemsWidth + _local2;
			}
			if(this._titleAlign === "left") {
				_local7 = this.actualWidth - _local5 - _local3;
				if(_local7 < 0) {
					_local7 = 0;
				}
				this.titleTextRenderer.maxWidth = _local7;
				this.titleTextRenderer.validate();
				this.titleTextRenderer.x = _local5;
			} else if(this._titleAlign === "right") {
				_local7 = this.actualWidth - _local5 - _local3;
				if(_local7 < 0) {
					_local7 = 0;
				}
				this.titleTextRenderer.maxWidth = _local7;
				this.titleTextRenderer.validate();
				this.titleTextRenderer.x = this.actualWidth - this.titleTextRenderer.width - _local3;
			} else {
				_local8 = this.actualWidth - this._paddingLeft - this._paddingRight;
				if(_local8 < 0) {
					_local8 = 0;
				}
				_local11 = this.actualWidth - _local5 - _local3;
				if(_local11 < 0) {
					_local11 = 0;
				}
				this.titleTextRenderer.maxWidth = _local11;
				this.titleTextRenderer.validate();
				_local6 = this._paddingLeft + Math.round((_local8 - this.titleTextRenderer.width) / 2);
				if(_local5 > _local6 || _local6 + this.titleTextRenderer.width > this.actualWidth - _local3) {
					this.titleTextRenderer.x = _local5 + Math.round((_local11 - this.titleTextRenderer.width) / 2);
				} else {
					this.titleTextRenderer.x = _local6;
				}
			}
			var _local9:Number = this._paddingTop + this.calculateExtraOSStatusBarPadding();
			switch(this._verticalAlign) {
				case "top":
					this.titleTextRenderer.y = _local9;
					break;
				case "bottom":
					this.titleTextRenderer.y = this.actualHeight - this._paddingBottom - this.titleTextRenderer.height;
					break;
				default:
					this.titleTextRenderer.y = _local9 + Math.round((this.actualHeight - _local9 - this._paddingBottom - this.titleTextRenderer.height) / 2);
			}
		}
		
		protected function header_addedToStageHandler(event:Event) : void {
			Starling.current.nativeStage.addEventListener("fullScreen",nativeStage_fullScreenHandler);
		}
		
		protected function header_removedFromStageHandler(event:Event) : void {
			Starling.current.nativeStage.removeEventListener("fullScreen",nativeStage_fullScreenHandler);
		}
		
		protected function nativeStage_fullScreenHandler(event:FullScreenEvent) : void {
			this.invalidate("size");
		}
		
		protected function titleProperties_onChange(proxy:PropertyProxy, propertyName:String) : void {
			this.invalidate("styles");
		}
		
		protected function item_resizeHandler(event:Event) : void {
			this.invalidate("size");
		}
	}
}

