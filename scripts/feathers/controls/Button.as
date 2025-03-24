package feathers.controls {
	import feathers.core.FeathersControl;
	import feathers.core.IFeathersControl;
	import feathers.core.IFocusDisplayObject;
	import feathers.core.IMeasureDisplayObject;
	import feathers.core.IStateObserver;
	import feathers.core.ITextBaselineControl;
	import feathers.core.ITextRenderer;
	import feathers.core.IValidating;
	import feathers.core.PropertyProxy;
	import feathers.skins.IStyleProvider;
	import feathers.utils.keyboard.KeyToTrigger;
	import feathers.utils.skins.resetFluidChildDimensionsForMeasurement;
	import feathers.utils.touch.LongPress;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.rendering.Painter;
	
	public class Button extends BasicButton implements IFocusDisplayObject, ITextBaselineControl {
		public static const DEFAULT_CHILD_STYLE_NAME_LABEL:String = "feathers-button-label";
		
		public static const ALTERNATE_STYLE_NAME_CALL_TO_ACTION_BUTTON:String = "feathers-call-to-action-button";
		
		public static const ALTERNATE_STYLE_NAME_QUIET_BUTTON:String = "feathers-quiet-button";
		
		public static const ALTERNATE_STYLE_NAME_DANGER_BUTTON:String = "feathers-danger-button";
		
		public static const ALTERNATE_STYLE_NAME_BACK_BUTTON:String = "feathers-back-button";
		
		public static const ALTERNATE_STYLE_NAME_FORWARD_BUTTON:String = "feathers-forward-button";
		
		public static const STATE_UP:String = "up";
		
		public static const STATE_DOWN:String = "down";
		
		public static const STATE_HOVER:String = "hover";
		
		public static const STATE_DISABLED:String = "disabled";
		
		public static const ICON_POSITION_TOP:String = "top";
		
		public static const ICON_POSITION_RIGHT:String = "right";
		
		public static const ICON_POSITION_BOTTOM:String = "bottom";
		
		public static const ICON_POSITION_LEFT:String = "left";
		
		public static const ICON_POSITION_MANUAL:String = "manual";
		
		public static const ICON_POSITION_LEFT_BASELINE:String = "leftBaseline";
		
		public static const ICON_POSITION_RIGHT_BASELINE:String = "rightBaseline";
		
		public static const HORIZONTAL_ALIGN_LEFT:String = "left";
		
		public static const HORIZONTAL_ALIGN_CENTER:String = "center";
		
		public static const HORIZONTAL_ALIGN_RIGHT:String = "right";
		
		public static const VERTICAL_ALIGN_TOP:String = "top";
		
		public static const VERTICAL_ALIGN_MIDDLE:String = "middle";
		
		public static const VERTICAL_ALIGN_BOTTOM:String = "bottom";
		
		public static var globalStyleProvider:IStyleProvider;
		
		private static const HELPER_POINT:Point = new Point();
		
		protected var labelStyleName:String = "feathers-button-label";
		
		protected var labelTextRenderer:ITextRenderer;
		
		protected var currentIcon:DisplayObject;
		
		protected var keyToTrigger:KeyToTrigger;
		
		protected var longPress:LongPress;
		
		protected var _scaleMatrix:Matrix;
		
		protected var _label:String = null;
		
		protected var _hasLabelTextRenderer:Boolean = true;
		
		protected var _iconPosition:String = "left";
		
		protected var _gap:Number = 0;
		
		protected var _minGap:Number = 0;
		
		protected var _horizontalAlign:String = "center";
		
		protected var _verticalAlign:String = "middle";
		
		protected var _paddingTop:Number = 0;
		
		protected var _paddingRight:Number = 0;
		
		protected var _paddingBottom:Number = 0;
		
		protected var _paddingLeft:Number = 0;
		
		protected var _labelOffsetX:Number = 0;
		
		protected var _labelOffsetY:Number = 0;
		
		protected var _iconOffsetX:Number = 0;
		
		protected var _iconOffsetY:Number = 0;
		
		protected var _stateToIconFunction:Function;
		
		protected var _stateToLabelPropertiesFunction:Function;
		
		protected var _stateToSkinFunction:Function;
		
		protected var _labelFactory:Function;
		
		protected var _customLabelStyleName:String;
		
		protected var _defaultLabelProperties:PropertyProxy;
		
		protected var _stateToLabelProperties:Object = {};
		
		protected var _defaultIcon:DisplayObject;
		
		protected var _stateToIcon:Object = {};
		
		protected var _longPressDuration:Number = 0.5;
		
		protected var _isLongPressEnabled:Boolean = false;
		
		protected var _scaleWhenDown:Number = 1;
		
		protected var _scaleWhenHovering:Number = 1;
		
		protected var _ignoreIconResizes:Boolean = false;
		
		public function Button() {
			super();
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return Button.globalStyleProvider;
		}
		
		public function get label() : String {
			return this._label;
		}
		
		public function set label(value:String) : void {
			if(this._label == value) {
				return;
			}
			this._label = value;
			this.invalidate("data");
		}
		
		public function get hasLabelTextRenderer() : Boolean {
			return this._hasLabelTextRenderer;
		}
		
		public function set hasLabelTextRenderer(value:Boolean) : void {
			if(this._hasLabelTextRenderer == value) {
				return;
			}
			this._hasLabelTextRenderer = value;
			this.invalidate("textRenderer");
		}
		
		public function get iconPosition() : String {
			return this._iconPosition;
		}
		
		public function set iconPosition(value:String) : void {
			if(this._iconPosition == value) {
				return;
			}
			this._iconPosition = value;
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
		
		public function get minGap() : Number {
			return this._minGap;
		}
		
		public function set minGap(value:Number) : void {
			if(this._minGap == value) {
				return;
			}
			this._minGap = value;
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
		
		public function get labelOffsetX() : Number {
			return this._labelOffsetX;
		}
		
		public function set labelOffsetX(value:Number) : void {
			if(this._labelOffsetX == value) {
				return;
			}
			this._labelOffsetX = value;
			this.invalidate("styles");
		}
		
		public function get labelOffsetY() : Number {
			return this._labelOffsetY;
		}
		
		public function set labelOffsetY(value:Number) : void {
			if(this._labelOffsetY == value) {
				return;
			}
			this._labelOffsetY = value;
			this.invalidate("styles");
		}
		
		public function get iconOffsetX() : Number {
			return this._iconOffsetX;
		}
		
		public function set iconOffsetX(value:Number) : void {
			if(this._iconOffsetX == value) {
				return;
			}
			this._iconOffsetX = value;
			this.invalidate("styles");
		}
		
		public function get iconOffsetY() : Number {
			return this._iconOffsetY;
		}
		
		public function set iconOffsetY(value:Number) : void {
			if(this._iconOffsetY == value) {
				return;
			}
			this._iconOffsetY = value;
			this.invalidate("styles");
		}
		
		public function get stateToIconFunction() : Function {
			return this._stateToIconFunction;
		}
		
		public function set stateToIconFunction(value:Function) : void {
			if(this._stateToIconFunction == value) {
				return;
			}
			this._stateToIconFunction = value;
			this.invalidate("styles");
		}
		
		public function get stateToLabelPropertiesFunction() : Function {
			return this._stateToLabelPropertiesFunction;
		}
		
		public function set stateToLabelPropertiesFunction(value:Function) : void {
			if(this._stateToLabelPropertiesFunction == value) {
				return;
			}
			this._stateToLabelPropertiesFunction = value;
			this.invalidate("styles");
		}
		
		public function get upSkin() : DisplayObject {
			return this.getSkinForState("up");
		}
		
		public function set upSkin(value:DisplayObject) : void {
			this.setSkinForState("up",value);
		}
		
		public function get downSkin() : DisplayObject {
			return this.getSkinForState("down");
		}
		
		public function set downSkin(value:DisplayObject) : void {
			this.setSkinForState("down",value);
		}
		
		public function get hoverSkin() : DisplayObject {
			return this.getSkinForState("hover");
		}
		
		public function set hoverSkin(value:DisplayObject) : void {
			this.setSkinForState("hover",value);
		}
		
		public function get disabledSkin() : DisplayObject {
			return this.getSkinForState("disabled");
		}
		
		public function set disabledSkin(value:DisplayObject) : void {
			this.setSkinForState("disabled",value);
		}
		
		public function get stateToSkinFunction() : Function {
			return this._stateToSkinFunction;
		}
		
		public function set stateToSkinFunction(value:Function) : void {
			if(this._stateToSkinFunction == value) {
				return;
			}
			this._stateToSkinFunction = value;
			this.invalidate("styles");
		}
		
		public function get labelFactory() : Function {
			return this._labelFactory;
		}
		
		public function set labelFactory(value:Function) : void {
			if(this._labelFactory == value) {
				return;
			}
			this._labelFactory = value;
			this.invalidate("textRenderer");
		}
		
		public function get customLabelStyleName() : String {
			return this._customLabelStyleName;
		}
		
		public function set customLabelStyleName(value:String) : void {
			if(this._customLabelStyleName == value) {
				return;
			}
			this._customLabelStyleName = value;
			this.invalidate("textRenderer");
		}
		
		public function get defaultLabelProperties() : Object {
			if(this._defaultLabelProperties === null) {
				this._defaultLabelProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._defaultLabelProperties;
		}
		
		public function set defaultLabelProperties(value:Object) : void {
			if(!(value is PropertyProxy)) {
				value = PropertyProxy.fromObject(value);
			}
			if(this._defaultLabelProperties !== null) {
				this._defaultLabelProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._defaultLabelProperties = PropertyProxy(value);
			if(this._defaultLabelProperties !== null) {
				this._defaultLabelProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get upLabelProperties() : Object {
			var _local1:PropertyProxy = PropertyProxy(this._stateToLabelProperties["up"]);
			if(!_local1) {
				_local1 = new PropertyProxy(childProperties_onChange);
				this._stateToLabelProperties["up"] = _local1;
			}
			return _local1;
		}
		
		public function set upLabelProperties(value:Object) : void {
			if(!(value is PropertyProxy)) {
				value = PropertyProxy.fromObject(value);
			}
			var _local2:PropertyProxy = PropertyProxy(this._stateToLabelProperties["up"]);
			if(_local2) {
				_local2.removeOnChangeCallback(childProperties_onChange);
			}
			this._stateToLabelProperties["up"] = value;
			if(value) {
				PropertyProxy(value).addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get downLabelProperties() : Object {
			var _local1:PropertyProxy = PropertyProxy(this._stateToLabelProperties["down"]);
			if(!_local1) {
				_local1 = new PropertyProxy(childProperties_onChange);
				this._stateToLabelProperties["down"] = _local1;
			}
			return _local1;
		}
		
		public function set downLabelProperties(value:Object) : void {
			if(!(value is PropertyProxy)) {
				value = PropertyProxy.fromObject(value);
			}
			var _local2:PropertyProxy = PropertyProxy(this._stateToLabelProperties["down"]);
			if(_local2) {
				_local2.removeOnChangeCallback(childProperties_onChange);
			}
			this._stateToLabelProperties["down"] = value;
			if(value) {
				PropertyProxy(value).addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get hoverLabelProperties() : Object {
			var _local1:PropertyProxy = PropertyProxy(this._stateToLabelProperties["hover"]);
			if(!_local1) {
				_local1 = new PropertyProxy(childProperties_onChange);
				this._stateToLabelProperties["hover"] = _local1;
			}
			return _local1;
		}
		
		public function set hoverLabelProperties(value:Object) : void {
			if(!(value is PropertyProxy)) {
				value = PropertyProxy.fromObject(value);
			}
			var _local2:PropertyProxy = PropertyProxy(this._stateToLabelProperties["hover"]);
			if(_local2) {
				_local2.removeOnChangeCallback(childProperties_onChange);
			}
			this._stateToLabelProperties["hover"] = value;
			if(value) {
				PropertyProxy(value).addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get disabledLabelProperties() : Object {
			var _local1:PropertyProxy = PropertyProxy(this._stateToLabelProperties["disabled"]);
			if(!_local1) {
				_local1 = new PropertyProxy(childProperties_onChange);
				this._stateToLabelProperties["disabled"] = _local1;
			}
			return _local1;
		}
		
		public function set disabledLabelProperties(value:Object) : void {
			if(!(value is PropertyProxy)) {
				value = PropertyProxy.fromObject(value);
			}
			var _local2:PropertyProxy = PropertyProxy(this._stateToLabelProperties["disabled"]);
			if(_local2) {
				_local2.removeOnChangeCallback(childProperties_onChange);
			}
			this._stateToLabelProperties["disabled"] = value;
			if(value) {
				PropertyProxy(value).addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get defaultIcon() : DisplayObject {
			return this._defaultIcon;
		}
		
		public function set defaultIcon(value:DisplayObject) : void {
			if(this._defaultIcon === value) {
				return;
			}
			if(this._defaultIcon !== null && this.currentIcon === this._defaultIcon) {
				this.removeCurrentIcon(this._defaultIcon);
				this.currentIcon = null;
			}
			this._defaultIcon = value;
			this.invalidate("styles");
		}
		
		public function get upIcon() : DisplayObject {
			return this.getIconForState("up");
		}
		
		public function set upIcon(value:DisplayObject) : void {
			return this.setIconForState("up",value);
		}
		
		public function get downIcon() : DisplayObject {
			return this.getIconForState("down");
		}
		
		public function set downIcon(value:DisplayObject) : void {
			return this.setIconForState("down",value);
		}
		
		public function get hoverIcon() : DisplayObject {
			return this.getIconForState("hover");
		}
		
		public function set hoverIcon(value:DisplayObject) : void {
			return this.setIconForState("hover",value);
		}
		
		public function get disabledIcon() : DisplayObject {
			return this.getIconForState("disabled");
		}
		
		public function set disabledIcon(value:DisplayObject) : void {
			return this.setIconForState("disabled",value);
		}
		
		public function get longPressDuration() : Number {
			return this._longPressDuration;
		}
		
		public function set longPressDuration(value:Number) : void {
			if(this._longPressDuration === value) {
				return;
			}
			this._longPressDuration = value;
			this.invalidate("styles");
		}
		
		public function get isLongPressEnabled() : Boolean {
			return this._isLongPressEnabled;
		}
		
		public function set isLongPressEnabled(value:Boolean) : void {
			if(this._isLongPressEnabled === value) {
				return;
			}
			this._isLongPressEnabled = value;
			this.invalidate("styles");
		}
		
		public function get scaleWhenDown() : Number {
			return this._scaleWhenDown;
		}
		
		public function set scaleWhenDown(value:Number) : void {
			this._scaleWhenDown = value;
		}
		
		public function get scaleWhenHovering() : Number {
			return this._scaleWhenHovering;
		}
		
		public function set scaleWhenHovering(value:Number) : void {
			this._scaleWhenHovering = value;
		}
		
		public function get baseline() : Number {
			if(!this.labelTextRenderer) {
				return this.scaledActualHeight;
			}
			return this.scaleY * (this.labelTextRenderer.y + this.labelTextRenderer.baseline);
		}
		
		override public function render(painter:Painter) : void {
			var _local2:Number = 1;
			if(this._currentState === "down") {
				_local2 = this._scaleWhenDown;
			} else if(this._currentState === "hover") {
				_local2 = this._scaleWhenHovering;
			}
			if(_local2 !== 1) {
				if(this._scaleMatrix === null) {
					this._scaleMatrix = new Matrix();
				} else {
					this._scaleMatrix.identity();
				}
				this._scaleMatrix.translate(Math.round((1 - _local2) / 2 * this.actualWidth),Math.round((1 - _local2) / 2 * this.actualHeight));
				this._scaleMatrix.scale(_local2,_local2);
				painter.state.transformModelviewMatrix(this._scaleMatrix);
			}
			super.render(painter);
		}
		
		override public function dispose() : void {
			var _local1:DisplayObject = null;
			if(this._defaultIcon !== null && this._defaultIcon.parent !== this) {
				this._defaultIcon.dispose();
			}
			for(var _local2 in this._stateToIcon) {
				_local1 = this._stateToIcon[_local2] as DisplayObject;
				if(_local1 !== null && _local1.parent !== this) {
					_local1.dispose();
				}
			}
			super.dispose();
		}
		
		public function getIconForState(state:String) : DisplayObject {
			return this._stateToIcon[state] as DisplayObject;
		}
		
		public function setIconForState(state:String, icon:DisplayObject) : void {
			var _local3:DisplayObject = this._stateToIcon[state] as DisplayObject;
			if(_local3 !== null && this.currentIcon === _local3) {
				this.removeCurrentIcon(_local3);
				this.currentIcon = null;
			}
			if(icon !== null) {
				this._stateToIcon[state] = icon;
			} else {
				delete this._stateToIcon[state];
			}
			this.invalidate("styles");
		}
		
		override protected function initialize() : void {
			super.initialize();
			if(!this.keyToTrigger) {
				this.keyToTrigger = new KeyToTrigger(this);
			}
			if(!this.longPress) {
				this.longPress = new LongPress(this);
				this.longPress.tapToTrigger = this.tapToTrigger;
			}
		}
		
		override protected function draw() : void {
			var _local5:Boolean = this.isInvalid("data");
			var _local6:Boolean = this.isInvalid("styles");
			var _local1:Boolean = this.isInvalid("size");
			var _local3:Boolean = this.isInvalid("state");
			var _local4:Boolean = this.isInvalid("textRenderer");
			var _local2:Boolean = this.isInvalid("focus");
			if(_local4) {
				this.createLabel();
			}
			if(_local4 || _local3 || _local5) {
				this.refreshLabel();
			}
			if(_local6 || _local3) {
				this.refreshLongPressEvents();
				this.refreshIcon();
			}
			if(_local4 || _local6 || _local3) {
				this.refreshLabelStyles();
			}
			super.draw();
			if(_local4 || _local6 || _local3 || _local5 || _local1) {
				this.layoutContent();
			}
			if(_local1 || _local2) {
				this.refreshFocusIndicator();
			}
		}
		
		override protected function autoSizeIfNeeded() : Boolean {
			var _local6:Number = NaN;
			var _local2:Number = NaN;
			var _local4:* = this._explicitWidth !== this._explicitWidth;
			var _local10:* = this._explicitHeight !== this._explicitHeight;
			var _local8:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local13:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local4 && !_local10 && !_local8 && !_local13) {
				return false;
			}
			var _local1:ITextRenderer = null;
			if(this._label !== null && this.labelTextRenderer) {
				_local1 = this.labelTextRenderer;
				this.refreshMaxLabelSize(true);
				this.labelTextRenderer.measureText(HELPER_POINT);
			}
			var _local11:Number = this._gap;
			if(_local11 === Infinity) {
				_local11 = this._minGap;
			}
			resetFluidChildDimensionsForMeasurement(this.currentSkin,this._explicitWidth,this._explicitHeight,this._explicitMinWidth,this._explicitMinHeight,this._explicitMaxWidth,this._explicitMaxHeight,this._explicitSkinWidth,this._explicitSkinHeight,this._explicitSkinMinWidth,this._explicitSkinMinHeight,this._explicitSkinMaxWidth,this._explicitSkinMaxHeight);
			var _local12:IMeasureDisplayObject = this.currentSkin as IMeasureDisplayObject;
			if(this.currentIcon is IValidating) {
				IValidating(this.currentIcon).validate();
			}
			if(this.currentSkin is IValidating) {
				IValidating(this.currentSkin).validate();
			}
			var _local7:* = this._explicitMinWidth;
			if(_local8) {
				if(_local1 !== null) {
					_local7 = HELPER_POINT.x;
				} else {
					_local7 = 0;
				}
				switch(_local1) {
					default:
						if(this._iconPosition !== "top" && this._iconPosition !== "bottom" && this._iconPosition !== "manual") {
							_local7 += _local11;
							if(this.currentIcon is IFeathersControl) {
								_local7 += IFeathersControl(this.currentIcon).minWidth;
							} else {
								_local7 += this.currentIcon.width;
							}
						} else if(this.currentIcon is IFeathersControl) {
							_local6 = Number(IFeathersControl(this.currentIcon).minWidth);
							if(_local6 > _local7) {
								_local7 = _local6;
							}
						} else if(this.currentIcon.width > _local7) {
							_local7 = this.currentIcon.width;
						}
						break;
					case null:
						if(this.currentIcon is IFeathersControl) {
							_local7 = Number(IFeathersControl(this.currentIcon).minWidth);
							break;
						}
						_local7 = this.currentIcon.width;
						break;
					case null:
				}
				_local7 += this._paddingLeft + this._paddingRight;
				switch(_local12) {
					default:
						if(_local12.minWidth > _local7) {
							_local7 = _local12.minWidth;
						}
						break;
					case null:
						if(this._explicitSkinMinWidth > _local7) {
							_local7 = this._explicitSkinMinWidth;
						}
						break;
					case null:
				}
			}
			var _local9:* = this._explicitMinHeight;
			if(_local13) {
				if(_local1 !== null) {
					_local9 = HELPER_POINT.y;
				} else {
					_local9 = 0;
				}
				switch(_local1) {
					default:
						if(this._iconPosition === "top" || this._iconPosition === "bottom") {
							_local9 += _local11;
							if(this.currentIcon is IFeathersControl) {
								_local9 += IFeathersControl(this.currentIcon).minHeight;
							} else {
								_local9 += this.currentIcon.height;
							}
						} else if(this.currentIcon is IFeathersControl) {
							_local2 = Number(IFeathersControl(this.currentIcon).minHeight);
							if(_local2 > _local9) {
								_local9 = _local2;
							}
						} else if(this.currentIcon.height > _local9) {
							_local9 = this.currentIcon.height;
						}
						break;
					case null:
						if(this.currentIcon is IFeathersControl) {
							_local9 = Number(IFeathersControl(this.currentIcon).minHeight);
							break;
						}
						_local9 = this.currentIcon.height;
						break;
					case null:
				}
				_local9 += this._paddingTop + this._paddingBottom;
				switch(_local12) {
					default:
						if(_local12.minHeight > _local9) {
							_local9 = _local12.minHeight;
						}
						break;
					case null:
						if(this._explicitSkinMinHeight > _local9) {
							_local9 = this._explicitSkinMinHeight;
						}
						break;
					case null:
				}
			}
			var _local3:Number = this._explicitWidth;
			if(_local4) {
				if(_local1 !== null) {
					_local3 = HELPER_POINT.x;
				} else {
					_local3 = 0;
				}
				switch(_local1) {
					default:
						if(this._iconPosition !== "top" && this._iconPosition !== "bottom" && this._iconPosition !== "manual") {
							_local3 += _local11 + this.currentIcon.width;
						} else if(this.currentIcon.width > _local3) {
							_local3 = this.currentIcon.width;
						}
						break;
					case null:
						_local3 = this.currentIcon.width;
						break;
					case null:
				}
				_local3 += this._paddingLeft + this._paddingRight;
				if(this.currentSkin !== null && this.currentSkin.width > _local3) {
					_local3 = this.currentSkin.width;
				}
			}
			var _local5:Number = this._explicitHeight;
			if(_local10) {
				if(_local1 !== null) {
					_local5 = HELPER_POINT.y;
				} else {
					_local5 = 0;
				}
				switch(_local1) {
					default:
						if(this._iconPosition === "top" || this._iconPosition === "bottom") {
							_local5 += _local11 + this.currentIcon.height;
						} else if(this.currentIcon.height > _local5) {
							_local5 = this.currentIcon.height;
						}
						break;
					case null:
						_local5 = this.currentIcon.height;
						break;
					case null:
				}
				_local5 += this._paddingTop + this._paddingBottom;
				if(this.currentSkin !== null && this.currentSkin.height > _local5) {
					_local5 = this.currentSkin.height;
				}
			}
			return this.saveMeasurements(_local3,_local5,_local7,_local9);
		}
		
		override protected function changeState(state:String) : void {
			var _local2:String = this._currentState;
			if(_local2 === state) {
				return;
			}
			super.changeState(state);
			if(this._scaleWhenHovering !== 1 && (state === "hover" || _local2 === "hover")) {
				this.setRequiresRedraw();
			} else if(this._scaleWhenDown !== 1 && (state === "down" || _local2 === "down")) {
				this.setRequiresRedraw();
			}
		}
		
		protected function createLabel() : void {
			var _local1:Function = null;
			var _local2:String = null;
			if(this.labelTextRenderer) {
				this.removeChild(DisplayObject(this.labelTextRenderer),true);
				this.labelTextRenderer = null;
			}
			if(this._hasLabelTextRenderer) {
				_local1 = this._labelFactory != null ? this._labelFactory : FeathersControl.defaultTextRendererFactory;
				this.labelTextRenderer = ITextRenderer(_local1());
				_local2 = this._customLabelStyleName != null ? this._customLabelStyleName : this.labelStyleName;
				this.labelTextRenderer.styleNameList.add(_local2);
				if(this.labelTextRenderer is IStateObserver) {
					IStateObserver(this.labelTextRenderer).stateContext = this;
				}
				this.addChild(DisplayObject(this.labelTextRenderer));
			}
		}
		
		protected function refreshLabel() : void {
			if(!this.labelTextRenderer) {
				return;
			}
			this.labelTextRenderer.text = this._label;
			this.labelTextRenderer.visible = this._label !== null && this._label.length > 0;
			this.labelTextRenderer.isEnabled = this._isEnabled;
		}
		
		protected function refreshIcon() : void {
			var _local2:int = 0;
			var _local1:DisplayObject = this.currentIcon;
			this.currentIcon = this.getCurrentIcon();
			if(this.currentIcon is IFeathersControl) {
				IFeathersControl(this.currentIcon).isEnabled = this._isEnabled;
			}
			switch(_local1) {
				default:
					this.removeCurrentIcon(_local1);
				case null:
					if(this.currentIcon !== null) {
						if(this.currentIcon is IStateObserver) {
							IStateObserver(this.currentIcon).stateContext = this;
						}
						_local2 = this.numChildren;
						if(this.labelTextRenderer) {
							_local2 = this.getChildIndex(DisplayObject(this.labelTextRenderer));
						}
						this.addChildAt(this.currentIcon,_local2);
						if(this.currentIcon is IFeathersControl) {
							IFeathersControl(this.currentIcon).addEventListener("resize",currentIcon_resizeHandler);
						}
					}
					break;
				case _local1:
			}
		}
		
		protected function removeCurrentIcon(icon:DisplayObject) : void {
			if(icon === null) {
				return;
			}
			if(icon is IFeathersControl) {
				IFeathersControl(icon).removeEventListener("resize",currentIcon_resizeHandler);
			}
			if(icon is IStateObserver) {
				IStateObserver(icon).stateContext = null;
			}
			if(icon.parent === this) {
				this.removeChild(icon,false);
			}
		}
		
		override protected function getCurrentSkin() : DisplayObject {
			if(this._stateToSkinFunction !== null) {
				return DisplayObject(this._stateToSkinFunction(this,this._currentState,this.currentSkin));
			}
			return super.getCurrentSkin();
		}
		
		protected function getCurrentIcon() : DisplayObject {
			if(this._stateToIconFunction !== null) {
				return DisplayObject(this._stateToIconFunction(this,this._currentState,this.currentIcon));
			}
			var _local1:DisplayObject = this._stateToIcon[this._currentState] as DisplayObject;
			if(_local1 !== null) {
				return _local1;
			}
			return this._defaultIcon;
		}
		
		protected function refreshLabelStyles() : void {
			var _local2:Object = null;
			if(!this.labelTextRenderer) {
				return;
			}
			var _local3:Object = this.getCurrentLabelProperties();
			for(var _local1 in _local3) {
				_local2 = _local3[_local1];
				this.labelTextRenderer[_local1] = _local2;
			}
		}
		
		protected function getCurrentLabelProperties() : Object {
			if(this._stateToLabelPropertiesFunction !== null) {
				return this._stateToLabelPropertiesFunction(this,this._currentState);
			}
			var _local1:Object = this._stateToLabelProperties[this._currentState];
			if(_local1 !== null) {
				return _local1;
			}
			return this._defaultLabelProperties;
		}
		
		override protected function refreshTriggeredEvents() : void {
			super.refreshTriggeredEvents();
			this.keyToTrigger.isEnabled = this._isEnabled;
		}
		
		protected function refreshLongPressEvents() : void {
			this.longPress.isEnabled = this._isEnabled && this._isLongPressEnabled;
			this.longPress.longPressDuration = this._longPressDuration;
		}
		
		protected function layoutContent() : void {
			var _local3:Boolean = this._ignoreIconResizes;
			this._ignoreIconResizes = true;
			this.refreshMaxLabelSize(false);
			var _local1:DisplayObject = null;
			if(this._label !== null && this.labelTextRenderer) {
				this.labelTextRenderer.validate();
				_local1 = DisplayObject(this.labelTextRenderer);
			}
			var _local2:Boolean = this.currentIcon && this._iconPosition != "manual";
			if(_local1 && _local2) {
				this.positionSingleChild(_local1);
				this.positionLabelAndIcon();
			} else if(_local1) {
				this.positionSingleChild(_local1);
			} else if(_local2) {
				this.positionSingleChild(this.currentIcon);
			}
			if(this.currentIcon) {
				if(this._iconPosition == "manual") {
					this.currentIcon.x = this._paddingLeft;
					this.currentIcon.y = this._paddingTop;
				}
				this.currentIcon.x += this._iconOffsetX;
				this.currentIcon.y += this._iconOffsetY;
			}
			if(_local1) {
				this.labelTextRenderer.x += this._labelOffsetX;
				this.labelTextRenderer.y += this._labelOffsetY;
			}
			this._ignoreIconResizes = _local3;
		}
		
		protected function refreshMaxLabelSize(forMeasurement:Boolean) : void {
			var _local4:Number = NaN;
			if(this.currentIcon is IValidating) {
				IValidating(this.currentIcon).validate();
			}
			var _local2:Number = this.actualWidth;
			var _local3:Number = this.actualHeight;
			if(forMeasurement) {
				_local2 = this._explicitWidth;
				if(_local2 !== _local2) {
					_local2 = this._explicitMaxWidth;
				}
				_local3 = this._explicitHeight;
				if(_local3 !== _local3) {
					_local3 = this._explicitMaxHeight;
				}
			}
			if(this._label != null && this.labelTextRenderer) {
				this.labelTextRenderer.maxWidth = _local2 - this._paddingLeft - this._paddingRight;
				this.labelTextRenderer.maxHeight = _local3 - this._paddingTop - this._paddingBottom;
				if(this.currentIcon) {
					_local4 = this._gap;
					if(_local4 == Infinity) {
						_local4 = this._minGap;
					}
					if(this._iconPosition == "left" || this._iconPosition == "leftBaseline" || this._iconPosition == "right" || this._iconPosition == "rightBaseline") {
						this.labelTextRenderer.maxWidth -= this.currentIcon.width + _local4;
					}
					if(this._iconPosition == "top" || this._iconPosition == "bottom") {
						this.labelTextRenderer.maxHeight -= this.currentIcon.height + _local4;
					}
				}
			}
		}
		
		protected function positionSingleChild(displayObject:DisplayObject) : void {
			if(this._horizontalAlign == "left") {
				displayObject.x = this._paddingLeft;
			} else if(this._horizontalAlign == "right") {
				displayObject.x = this.actualWidth - this._paddingRight - displayObject.width;
			} else {
				displayObject.x = this._paddingLeft + Math.round((this.actualWidth - this._paddingLeft - this._paddingRight - displayObject.width) / 2);
			}
			if(this._verticalAlign == "top") {
				displayObject.y = this._paddingTop;
			} else if(this._verticalAlign == "bottom") {
				displayObject.y = this.actualHeight - this._paddingBottom - displayObject.height;
			} else {
				displayObject.y = this._paddingTop + Math.round((this.actualHeight - this._paddingTop - this._paddingBottom - displayObject.height) / 2);
			}
		}
		
		protected function positionLabelAndIcon() : void {
			if(this._iconPosition == "top") {
				if(this._gap == Infinity) {
					this.currentIcon.y = this._paddingTop;
					this.labelTextRenderer.y = this.actualHeight - this._paddingBottom - this.labelTextRenderer.height;
				} else {
					if(this._verticalAlign == "top") {
						this.labelTextRenderer.y += this.currentIcon.height + this._gap;
					} else if(this._verticalAlign == "middle") {
						this.labelTextRenderer.y += Math.round((this.currentIcon.height + this._gap) / 2);
					}
					this.currentIcon.y = this.labelTextRenderer.y - this.currentIcon.height - this._gap;
				}
			} else if(this._iconPosition == "right" || this._iconPosition == "rightBaseline") {
				if(this._gap == Infinity) {
					this.labelTextRenderer.x = this._paddingLeft;
					this.currentIcon.x = this.actualWidth - this._paddingRight - this.currentIcon.width;
				} else {
					if(this._horizontalAlign == "right") {
						this.labelTextRenderer.x -= this.currentIcon.width + this._gap;
					} else if(this._horizontalAlign == "center") {
						this.labelTextRenderer.x -= Math.round((this.currentIcon.width + this._gap) / 2);
					}
					this.currentIcon.x = this.labelTextRenderer.x + this.labelTextRenderer.width + this._gap;
				}
			} else if(this._iconPosition == "bottom") {
				if(this._gap == Infinity) {
					this.labelTextRenderer.y = this._paddingTop;
					this.currentIcon.y = this.actualHeight - this._paddingBottom - this.currentIcon.height;
				} else {
					if(this._verticalAlign == "bottom") {
						this.labelTextRenderer.y -= this.currentIcon.height + this._gap;
					} else if(this._verticalAlign == "middle") {
						this.labelTextRenderer.y -= Math.round((this.currentIcon.height + this._gap) / 2);
					}
					this.currentIcon.y = this.labelTextRenderer.y + this.labelTextRenderer.height + this._gap;
				}
			} else if(this._iconPosition == "left" || this._iconPosition == "leftBaseline") {
				if(this._gap == Infinity) {
					this.currentIcon.x = this._paddingLeft;
					this.labelTextRenderer.x = this.actualWidth - this._paddingRight - this.labelTextRenderer.width;
				} else {
					if(this._horizontalAlign == "left") {
						this.labelTextRenderer.x += this._gap + this.currentIcon.width;
					} else if(this._horizontalAlign == "center") {
						this.labelTextRenderer.x += Math.round((this._gap + this.currentIcon.width) / 2);
					}
					this.currentIcon.x = this.labelTextRenderer.x - this._gap - this.currentIcon.width;
				}
			}
			if(this._iconPosition == "left" || this._iconPosition == "right") {
				if(this._verticalAlign == "top") {
					this.currentIcon.y = this._paddingTop;
				} else if(this._verticalAlign == "bottom") {
					this.currentIcon.y = this.actualHeight - this._paddingBottom - this.currentIcon.height;
				} else {
					this.currentIcon.y = this._paddingTop + Math.round((this.actualHeight - this._paddingTop - this._paddingBottom - this.currentIcon.height) / 2);
				}
			} else if(this._iconPosition == "leftBaseline" || this._iconPosition == "rightBaseline") {
				this.currentIcon.y = this.labelTextRenderer.y + this.labelTextRenderer.baseline - this.currentIcon.height;
			} else if(this._horizontalAlign == "left") {
				this.currentIcon.x = this._paddingLeft;
			} else if(this._horizontalAlign == "right") {
				this.currentIcon.x = this.actualWidth - this._paddingRight - this.currentIcon.width;
			} else {
				this.currentIcon.x = this._paddingLeft + Math.round((this.actualWidth - this._paddingLeft - this._paddingRight - this.currentIcon.width) / 2);
			}
		}
		
		protected function childProperties_onChange(proxy:PropertyProxy, name:Object) : void {
			this.invalidate("styles");
		}
		
		override protected function focusInHandler(event:Event) : void {
			super.focusInHandler(event);
			this.stage.addEventListener("keyDown",stage_keyDownHandler);
			this.stage.addEventListener("keyUp",stage_keyUpHandler);
		}
		
		override protected function focusOutHandler(event:Event) : void {
			super.focusOutHandler(event);
			this.stage.removeEventListener("keyDown",stage_keyDownHandler);
			this.stage.removeEventListener("keyUp",stage_keyUpHandler);
			if(this.touchPointID >= 0) {
				this.touchPointID = -1;
				if(this._isEnabled) {
					this.changeState("up");
				} else {
					this.changeState("disabled");
				}
			}
		}
		
		protected function stage_keyDownHandler(event:KeyboardEvent) : void {
			if(event.keyCode === 27) {
				this.touchPointID = -1;
				this.changeState("up");
			}
			if(this.touchPointID >= 0 || event.keyCode !== 32) {
				return;
			}
			this.touchPointID = 0x7fffffff;
			this.changeState("down");
		}
		
		protected function stage_keyUpHandler(event:KeyboardEvent) : void {
			if(this.touchPointID !== 0x7fffffff || event.keyCode !== 32) {
				return;
			}
			this.resetTouchState();
		}
		
		protected function currentIcon_resizeHandler() : void {
			if(this._ignoreIconResizes) {
				return;
			}
			this.invalidate("size");
		}
	}
}

