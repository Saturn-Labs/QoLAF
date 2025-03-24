package feathers.controls {
	import feathers.core.FeathersControl;
	import feathers.core.IFeathersControl;
	import feathers.core.IMeasureDisplayObject;
	import feathers.core.IValidating;
	import feathers.core.PopUpManager;
	import feathers.skins.IStyleProvider;
	import feathers.utils.display.getDisplayObjectDepthFromStage;
	import feathers.utils.skins.resetFluidChildDimensionsForMeasurement;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	public class Callout extends FeathersControl {
		public static var globalStyleProvider:IStyleProvider;
		
		public static const DIRECTION_ANY:String = "any";
		
		public static const DIRECTION_VERTICAL:String = "vertical";
		
		public static const DIRECTION_HORIZONTAL:String = "horizontal";
		
		public static const DIRECTION_UP:String = "up";
		
		public static const DIRECTION_DOWN:String = "down";
		
		public static const DIRECTION_LEFT:String = "left";
		
		public static const DIRECTION_RIGHT:String = "right";
		
		public static const ARROW_POSITION_TOP:String = "top";
		
		public static const ARROW_POSITION_RIGHT:String = "right";
		
		public static const ARROW_POSITION_BOTTOM:String = "bottom";
		
		public static const ARROW_POSITION_LEFT:String = "left";
		
		protected static const INVALIDATION_FLAG_ORIGIN:String = "origin";
		
		protected static const FUZZY_CONTENT_DIMENSIONS_PADDING:Number = 0.000001;
		
		public static var stagePaddingTop:Number = 0;
		
		public static var stagePaddingRight:Number = 0;
		
		public static var stagePaddingBottom:Number = 0;
		
		public static var stagePaddingLeft:Number = 0;
		
		public static const DEFAULT_POSITIONS:Vector.<String> = new <String>["bottom","top","right","left"];
		
		private static const HELPER_RECT:Rectangle = new Rectangle();
		
		public static var calloutFactory:Function = defaultCalloutFactory;
		
		public static var calloutOverlayFactory:Function = PopUpManager.defaultOverlayFactory;
		
		public var closeOnTouchBeganOutside:Boolean = false;
		
		public var closeOnTouchEndedOutside:Boolean = false;
		
		public var closeOnKeys:Vector.<uint>;
		
		public var disposeOnSelfClose:Boolean = true;
		
		public var disposeContent:Boolean = true;
		
		protected var _isReadyToClose:Boolean = false;
		
		protected var _explicitContentWidth:Number;
		
		protected var _explicitContentHeight:Number;
		
		protected var _explicitContentMinWidth:Number;
		
		protected var _explicitContentMinHeight:Number;
		
		protected var _explicitContentMaxWidth:Number;
		
		protected var _explicitContentMaxHeight:Number;
		
		protected var _explicitBackgroundSkinWidth:Number;
		
		protected var _explicitBackgroundSkinHeight:Number;
		
		protected var _explicitBackgroundSkinMinWidth:Number;
		
		protected var _explicitBackgroundSkinMinHeight:Number;
		
		protected var _explicitBackgroundSkinMaxWidth:Number;
		
		protected var _explicitBackgroundSkinMaxHeight:Number;
		
		protected var _content:DisplayObject;
		
		protected var _origin:DisplayObject;
		
		protected var _supportedDirections:String = null;
		
		protected var _supportedPositions:Vector.<String> = null;
		
		protected var _horizontalAlign:String = "center";
		
		protected var _verticalAlign:String = "middle";
		
		protected var _paddingTop:Number = 0;
		
		protected var _paddingRight:Number = 0;
		
		protected var _paddingBottom:Number = 0;
		
		protected var _paddingLeft:Number = 0;
		
		protected var _arrowPosition:String = "top";
		
		protected var _backgroundSkin:DisplayObject;
		
		protected var currentArrowSkin:DisplayObject;
		
		protected var _bottomArrowSkin:DisplayObject;
		
		protected var _topArrowSkin:DisplayObject;
		
		protected var _leftArrowSkin:DisplayObject;
		
		protected var _rightArrowSkin:DisplayObject;
		
		protected var _topArrowGap:Number = 0;
		
		protected var _bottomArrowGap:Number = 0;
		
		protected var _rightArrowGap:Number = 0;
		
		protected var _leftArrowGap:Number = 0;
		
		protected var _arrowOffset:Number = 0;
		
		protected var _lastGlobalBoundsOfOrigin:Rectangle;
		
		protected var _ignoreContentResize:Boolean = false;
		
		public function Callout() {
			super();
			this.addEventListener("addedToStage",callout_addedToStageHandler);
		}
		
		public static function get stagePadding() : Number {
			return Callout.stagePaddingTop;
		}
		
		public static function set stagePadding(value:Number) : void {
			Callout.stagePaddingTop = value;
			Callout.stagePaddingRight = value;
			Callout.stagePaddingBottom = value;
			Callout.stagePaddingLeft = value;
		}
		
		public static function show(content:DisplayObject, origin:DisplayObject, supportedPositions:Object = null, isModal:Boolean = true, customCalloutFactory:Function = null, customOverlayFactory:Function = null) : Callout {
			if(origin.stage === null) {
				throw new ArgumentError("Callout origin must be added to the stage.");
			}
			var _local7:* = customCalloutFactory;
			if(_local7 === null) {
				_local7 = calloutFactory;
				if(_local7 === null) {
					_local7 = defaultCalloutFactory;
				}
			}
			var _local8:Callout = Callout(_local7());
			_local8.content = content;
			if(supportedPositions is String) {
				_local8.supportedDirections = supportedPositions as String;
			} else {
				_local8.supportedPositions = supportedPositions as Vector.<String>;
			}
			_local8.origin = origin;
			_local7 = customOverlayFactory;
			if(_local7 === null) {
				_local7 = calloutOverlayFactory;
				if(_local7 === null) {
					_local7 = PopUpManager.defaultOverlayFactory;
				}
			}
			PopUpManager.addPopUp(_local8,isModal,false,_local7);
			return _local8;
		}
		
		public static function defaultCalloutFactory() : Callout {
			var _local1:Callout = new Callout();
			_local1.closeOnTouchBeganOutside = true;
			_local1.closeOnTouchEndedOutside = true;
			_local1.closeOnKeys = new <uint>[16777238,27];
			return _local1;
		}
		
		protected static function positionBelowOrigin(callout:Callout, globalOrigin:Rectangle) : void {
			var _local4:Number = NaN;
			callout.measureWithArrowPosition("top");
			var _local5:Number = globalOrigin.x;
			if(callout._horizontalAlign === "center") {
				_local5 += Math.round((globalOrigin.width - callout.width) / 2);
			} else if(callout._horizontalAlign === "right") {
				_local5 += globalOrigin.width - callout.width;
			}
			var _local3:* = _local5;
			if(stagePaddingLeft > _local3) {
				_local3 = stagePaddingLeft;
			} else {
				_local4 = Starling.current.stage.stageWidth - callout.width - stagePaddingRight;
				if(_local4 < _local3) {
					_local3 = _local4;
				}
			}
			callout.x = _local3;
			callout.y = globalOrigin.y + globalOrigin.height;
			if(callout._isValidating) {
				callout._arrowOffset = _local5 - _local3;
				callout._arrowPosition = "top";
			} else {
				callout.arrowOffset = _local5 - _local3;
				callout.arrowPosition = "top";
			}
		}
		
		protected static function positionAboveOrigin(callout:Callout, globalOrigin:Rectangle) : void {
			var _local4:Number = NaN;
			callout.measureWithArrowPosition("bottom");
			var _local5:Number = globalOrigin.x;
			if(callout._horizontalAlign === "center") {
				_local5 += Math.round((globalOrigin.width - callout.width) / 2);
			} else if(callout._horizontalAlign === "right") {
				_local5 += globalOrigin.width - callout.width;
			}
			var _local3:* = _local5;
			if(stagePaddingLeft > _local3) {
				_local3 = stagePaddingLeft;
			} else {
				_local4 = Starling.current.stage.stageWidth - callout.width - stagePaddingRight;
				if(_local4 < _local3) {
					_local3 = _local4;
				}
			}
			callout.x = _local3;
			callout.y = globalOrigin.y - callout.height;
			if(callout._isValidating) {
				callout._arrowOffset = _local5 - _local3;
				callout._arrowPosition = "bottom";
			} else {
				callout.arrowOffset = _local5 - _local3;
				callout.arrowPosition = "bottom";
			}
		}
		
		protected static function positionToRightOfOrigin(callout:Callout, globalOrigin:Rectangle) : void {
			var _local3:Number = NaN;
			callout.measureWithArrowPosition("left");
			callout.x = globalOrigin.x + globalOrigin.width;
			var _local5:Number = globalOrigin.y;
			if(callout._verticalAlign === "middle") {
				_local5 += Math.round((globalOrigin.height - callout.height) / 2);
			} else if(callout._verticalAlign === "bottom") {
				_local5 += globalOrigin.height - callout.height;
			}
			var _local4:* = _local5;
			if(stagePaddingTop > _local4) {
				_local4 = stagePaddingTop;
			} else {
				_local3 = Starling.current.stage.stageHeight - callout.height - stagePaddingBottom;
				if(_local3 < _local4) {
					_local4 = _local3;
				}
			}
			callout.y = _local4;
			if(callout._isValidating) {
				callout._arrowOffset = _local5 - _local4;
				callout._arrowPosition = "left";
			} else {
				callout.arrowOffset = _local5 - _local4;
				callout.arrowPosition = "left";
			}
		}
		
		protected static function positionToLeftOfOrigin(callout:Callout, globalOrigin:Rectangle) : void {
			var _local3:Number = NaN;
			callout.measureWithArrowPosition("right");
			callout.x = globalOrigin.x - callout.width;
			var _local5:Number = globalOrigin.y;
			if(callout._verticalAlign === "middle") {
				_local5 += Math.round((globalOrigin.height - callout.height) / 2);
			} else if(callout._verticalAlign === "bottom") {
				_local5 += globalOrigin.height - callout.height;
			}
			var _local4:* = _local5;
			if(stagePaddingTop > _local4) {
				_local4 = stagePaddingTop;
			} else {
				_local3 = Starling.current.stage.stageHeight - callout.height - stagePaddingBottom;
				if(_local3 < _local4) {
					_local4 = _local3;
				}
			}
			callout.y = _local4;
			if(callout._isValidating) {
				callout._arrowOffset = _local5 - _local4;
				callout._arrowPosition = "right";
			} else {
				callout.arrowOffset = _local5 - _local4;
				callout.arrowPosition = "right";
			}
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return Callout.globalStyleProvider;
		}
		
		public function get content() : DisplayObject {
			return this._content;
		}
		
		public function set content(value:DisplayObject) : void {
			var _local2:IMeasureDisplayObject = null;
			if(this._content == value) {
				return;
			}
			if(this._content !== null) {
				if(this._content is IFeathersControl) {
					IFeathersControl(this._content).removeEventListener("resize",content_resizeHandler);
				}
				if(this._content.parent === this) {
					this._content.removeFromParent(false);
				}
			}
			this._content = value;
			if(this._content !== null) {
				if(this._content is IFeathersControl) {
					IFeathersControl(this._content).addEventListener("resize",content_resizeHandler);
				}
				this.addChild(this._content);
				if(this._content is IFeathersControl) {
					IFeathersControl(this._content).initializeNow();
				}
				if(this._content is IMeasureDisplayObject) {
					_local2 = IMeasureDisplayObject(this._content);
					this._explicitContentWidth = _local2.explicitWidth;
					this._explicitContentHeight = _local2.explicitHeight;
					this._explicitContentMinWidth = _local2.explicitMinWidth;
					this._explicitContentMinHeight = _local2.explicitMinHeight;
					this._explicitContentMaxWidth = _local2.explicitMaxWidth;
					this._explicitContentMaxHeight = _local2.explicitMaxHeight;
				} else {
					this._explicitContentWidth = this._content.width;
					this._explicitContentHeight = this._content.height;
					this._explicitContentMinWidth = this._explicitContentWidth;
					this._explicitContentMinHeight = this._explicitContentHeight;
					this._explicitContentMaxWidth = this._explicitContentWidth;
					this._explicitContentMaxHeight = this._explicitContentHeight;
				}
			}
			this.invalidate("size");
			this.invalidate("data");
		}
		
		public function get origin() : DisplayObject {
			return this._origin;
		}
		
		public function set origin(value:DisplayObject) : void {
			if(this._origin == value) {
				return;
			}
			if(value && !value.stage) {
				throw new ArgumentError("Callout origin must have access to the stage.");
			}
			if(this._origin) {
				this.removeEventListener("enterFrame",callout_enterFrameHandler);
				this._origin.removeEventListener("removedFromStage",origin_removedFromStageHandler);
			}
			this._origin = value;
			this._lastGlobalBoundsOfOrigin = null;
			if(this._origin) {
				this._origin.addEventListener("removedFromStage",origin_removedFromStageHandler);
				this.addEventListener("enterFrame",callout_enterFrameHandler);
			}
			this.invalidate("origin");
		}
		
		public function get supportedDirections() : String {
			return this._supportedDirections;
		}
		
		public function set supportedDirections(value:String) : void {
			var _local2:Vector.<String> = null;
			if(value === "any") {
				_local2 = new <String>["bottom","top","right","left"];
			} else if(value === "horizontal") {
				_local2 = new <String>["right","left"];
			} else if(value === "vertical") {
				_local2 = new <String>["bottom","top"];
			} else if(value === "up") {
				_local2 = new <String>["top"];
			} else if(value === "down") {
				_local2 = new <String>["bottom"];
			} else if(value === "right") {
				_local2 = new <String>["right"];
			} else if(value === "left") {
				_local2 = new <String>["left"];
			}
			this._supportedDirections = value;
			this.supportedPositions = _local2;
		}
		
		public function get supportedPositions() : Vector.<String> {
			return this._supportedPositions;
		}
		
		public function set supportedPositions(value:Vector.<String>) : void {
			this._supportedPositions = value;
		}
		
		public function get horizontalAlign() : String {
			return this._horizontalAlign;
		}
		
		public function set horizontalAlign(value:String) : void {
			if(this._horizontalAlign === value) {
				return;
			}
			this._horizontalAlign = value;
			this._lastGlobalBoundsOfOrigin = null;
			this.invalidate("origin");
		}
		
		public function get verticalAlign() : String {
			return this._verticalAlign;
		}
		
		public function set verticalAlign(value:String) : void {
			if(this._verticalAlign === value) {
				return;
			}
			this._verticalAlign = value;
			this._lastGlobalBoundsOfOrigin = null;
			this.invalidate("origin");
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
		
		public function get arrowPosition() : String {
			return this._arrowPosition;
		}
		
		public function set arrowPosition(value:String) : void {
			if(this._arrowPosition == value) {
				return;
			}
			this._arrowPosition = value;
			this.invalidate("styles");
		}
		
		public function get backgroundSkin() : DisplayObject {
			return this._backgroundSkin;
		}
		
		public function set backgroundSkin(value:DisplayObject) : void {
			var _local2:IMeasureDisplayObject = null;
			if(this._backgroundSkin == value) {
				return;
			}
			if(this._backgroundSkin !== null && this._backgroundSkin.parent === this) {
				this._backgroundSkin.removeFromParent(false);
			}
			this._backgroundSkin = value;
			if(this._backgroundSkin !== null) {
				this.addChildAt(this._backgroundSkin,0);
				if(this._backgroundSkin is IFeathersControl) {
					IFeathersControl(this._backgroundSkin).initializeNow();
				}
				if(this._backgroundSkin is IMeasureDisplayObject) {
					_local2 = IMeasureDisplayObject(this._backgroundSkin);
					this._explicitBackgroundSkinWidth = _local2.explicitWidth;
					this._explicitBackgroundSkinHeight = _local2.explicitHeight;
					this._explicitBackgroundSkinMinWidth = _local2.explicitMinWidth;
					this._explicitBackgroundSkinMinHeight = _local2.explicitMinHeight;
					this._explicitBackgroundSkinMaxWidth = _local2.explicitMaxWidth;
					this._explicitBackgroundSkinMaxHeight = _local2.explicitMaxHeight;
				} else {
					this._explicitBackgroundSkinWidth = this._backgroundSkin.width;
					this._explicitBackgroundSkinHeight = this._backgroundSkin.height;
					this._explicitBackgroundSkinMinWidth = this._explicitBackgroundSkinWidth;
					this._explicitBackgroundSkinMinHeight = this._explicitBackgroundSkinHeight;
					this._explicitBackgroundSkinMaxWidth = this._explicitBackgroundSkinWidth;
					this._explicitBackgroundSkinMaxHeight = this._explicitBackgroundSkinHeight;
				}
			}
			this.invalidate("styles");
		}
		
		public function get bottomArrowSkin() : DisplayObject {
			return this._bottomArrowSkin;
		}
		
		public function set bottomArrowSkin(value:DisplayObject) : void {
			var _local2:int = 0;
			if(this._bottomArrowSkin == value) {
				return;
			}
			if(this._bottomArrowSkin !== null && this._bottomArrowSkin.parent === this) {
				this._bottomArrowSkin.removeFromParent(false);
			}
			this._bottomArrowSkin = value;
			if(this._bottomArrowSkin !== null) {
				this._bottomArrowSkin.visible = false;
				_local2 = this.getChildIndex(this._content);
				if(_local2 < 0) {
					this.addChild(this._bottomArrowSkin);
				} else {
					this.addChildAt(this._bottomArrowSkin,_local2);
				}
			}
			this.invalidate("styles");
		}
		
		public function get topArrowSkin() : DisplayObject {
			return this._topArrowSkin;
		}
		
		public function set topArrowSkin(value:DisplayObject) : void {
			var _local2:int = 0;
			if(this._topArrowSkin == value) {
				return;
			}
			if(this._topArrowSkin !== null && this._topArrowSkin.parent === this) {
				this._topArrowSkin.removeFromParent(false);
			}
			this._topArrowSkin = value;
			if(this._topArrowSkin !== null) {
				this._topArrowSkin.visible = false;
				_local2 = this.getChildIndex(this._content);
				if(_local2 < 0) {
					this.addChild(this._topArrowSkin);
				} else {
					this.addChildAt(this._topArrowSkin,_local2);
				}
			}
			this.invalidate("styles");
		}
		
		public function get leftArrowSkin() : DisplayObject {
			return this._leftArrowSkin;
		}
		
		public function set leftArrowSkin(value:DisplayObject) : void {
			var _local2:int = 0;
			if(this._leftArrowSkin == value) {
				return;
			}
			if(this._leftArrowSkin !== null && this._leftArrowSkin.parent === this) {
				this._leftArrowSkin.removeFromParent(false);
			}
			this._leftArrowSkin = value;
			if(this._leftArrowSkin !== null) {
				this._leftArrowSkin.visible = false;
				_local2 = this.getChildIndex(this._content);
				if(_local2 < 0) {
					this.addChild(this._leftArrowSkin);
				} else {
					this.addChildAt(this._leftArrowSkin,_local2);
				}
			}
			this.invalidate("styles");
		}
		
		public function get rightArrowSkin() : DisplayObject {
			return this._rightArrowSkin;
		}
		
		public function set rightArrowSkin(value:DisplayObject) : void {
			var _local2:int = 0;
			if(this._rightArrowSkin == value) {
				return;
			}
			if(this._rightArrowSkin !== null && this._rightArrowSkin.parent === this) {
				this._rightArrowSkin.removeFromParent(false);
			}
			this._rightArrowSkin = value;
			if(this._rightArrowSkin !== null) {
				this._rightArrowSkin.visible = false;
				_local2 = this.getChildIndex(this._content);
				if(_local2 < 0) {
					this.addChild(this._rightArrowSkin);
				} else {
					this.addChildAt(this._rightArrowSkin,_local2);
				}
			}
			this.invalidate("styles");
		}
		
		public function get topArrowGap() : Number {
			return this._topArrowGap;
		}
		
		public function set topArrowGap(value:Number) : void {
			if(this._topArrowGap == value) {
				return;
			}
			this._topArrowGap = value;
			this.invalidate("styles");
		}
		
		public function get bottomArrowGap() : Number {
			return this._bottomArrowGap;
		}
		
		public function set bottomArrowGap(value:Number) : void {
			if(this._bottomArrowGap == value) {
				return;
			}
			this._bottomArrowGap = value;
			this.invalidate("styles");
		}
		
		public function get rightArrowGap() : Number {
			return this._rightArrowGap;
		}
		
		public function set rightArrowGap(value:Number) : void {
			if(this._rightArrowGap == value) {
				return;
			}
			this._rightArrowGap = value;
			this.invalidate("styles");
		}
		
		public function get leftArrowGap() : Number {
			return this._leftArrowGap;
		}
		
		public function set leftArrowGap(value:Number) : void {
			if(this._leftArrowGap == value) {
				return;
			}
			this._leftArrowGap = value;
			this.invalidate("styles");
		}
		
		public function get arrowOffset() : Number {
			return this._arrowOffset;
		}
		
		public function set arrowOffset(value:Number) : void {
			if(this._arrowOffset == value) {
				return;
			}
			this._arrowOffset = value;
			this.invalidate("styles");
		}
		
		override public function dispose() : void {
			this.origin = null;
			var _local1:DisplayObject = this._content;
			this.content = null;
			if(_local1 !== null && this.disposeContent) {
				_local1.dispose();
			}
			super.dispose();
		}
		
		public function close(dispose:Boolean = false) : void {
			if(this.parent) {
				this.removeFromParent(false);
				this.dispatchEventWith("close");
			}
			if(dispose) {
				this.dispose();
			}
		}
		
		override protected function initialize() : void {
			this.addEventListener("removedFromStage",callout_removedFromStageHandler);
		}
		
		override protected function draw() : void {
			var _local4:Boolean = this.isInvalid("data");
			var _local1:Boolean = this.isInvalid("size");
			var _local3:Boolean = this.isInvalid("state");
			var _local5:Boolean = this.isInvalid("styles");
			var _local2:Boolean = this.isInvalid("origin");
			if(_local1) {
				this._lastGlobalBoundsOfOrigin = null;
				_local2 = true;
			}
			if(_local2) {
				this.positionRelativeToOrigin();
			}
			if(_local5 || _local3) {
				this.refreshArrowSkin();
			}
			if(_local3 || _local4) {
				this.refreshEnabled();
			}
			_local1 = this.autoSizeIfNeeded() || _local1;
			this.layoutChildren();
		}
		
		protected function autoSizeIfNeeded() : Boolean {
			return this.measureWithArrowPosition(this._arrowPosition);
		}
		
		protected function measureWithArrowPosition(arrowPosition:String) : Boolean {
			var _local8:Number = NaN;
			var _local28:Number = NaN;
			var _local5:Number = NaN;
			var _local31:Number = NaN;
			var _local16:Number = NaN;
			var _local22:Number = NaN;
			var _local6:* = NaN;
			var _local27:Number = NaN;
			var _local20:* = NaN;
			var _local25:Number = NaN;
			var _local10:* = NaN;
			var _local32:Number = NaN;
			var _local26:* = NaN;
			var _local19:Number = NaN;
			var _local15:* = this._explicitWidth !== this._explicitWidth;
			var _local9:* = this._explicitHeight !== this._explicitHeight;
			var _local24:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local12:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local15 && !_local9 && !_local24 && !_local12) {
				return false;
			}
			if(this._backgroundSkin !== null) {
				_local8 = this._backgroundSkin.width;
				_local28 = this._backgroundSkin.height;
			}
			var _local17:IMeasureDisplayObject = this._backgroundSkin as IMeasureDisplayObject;
			resetFluidChildDimensionsForMeasurement(this._backgroundSkin,this._explicitWidth,this._explicitHeight,this._explicitMinWidth,this._explicitMinHeight,this._explicitMaxWidth,this._explicitMaxHeight,this._explicitBackgroundSkinWidth,this._explicitBackgroundSkinHeight,this._explicitBackgroundSkinMinWidth,this._explicitBackgroundSkinMinHeight,this._explicitBackgroundSkinMaxWidth,this._explicitBackgroundSkinMaxHeight);
			if(this._backgroundSkin is IValidating) {
				IValidating(this._backgroundSkin).validate();
			}
			var _local4:Number = 0;
			var _local21:Number = 0;
			if(arrowPosition === "left" && this._leftArrowSkin !== null) {
				_local4 = this._leftArrowSkin.width + this._leftArrowGap;
				_local21 = this._leftArrowSkin.height;
			} else if(arrowPosition === "right" && this._rightArrowSkin !== null) {
				_local4 = this._rightArrowSkin.width + this._rightArrowGap;
				_local21 = this._rightArrowSkin.height;
			}
			var _local29:Number = 0;
			var _local11:Number = 0;
			if(arrowPosition === "top" && this._topArrowSkin !== null) {
				_local29 = this._topArrowSkin.width;
				_local11 = this._topArrowSkin.height + this._topArrowGap;
			} else if(arrowPosition === "bottom" && this._bottomArrowSkin !== null) {
				_local29 = this._bottomArrowSkin.width;
				_local11 = this._bottomArrowSkin.height + this._bottomArrowGap;
			}
			var _local18:Boolean = this._ignoreContentResize;
			this._ignoreContentResize = true;
			var _local2:IMeasureDisplayObject = this._content as IMeasureDisplayObject;
			resetFluidChildDimensionsForMeasurement(this._content,this._explicitWidth - _local4 - this._paddingLeft - this._paddingRight,this._explicitHeight - _local11 - this._paddingTop - this._paddingBottom,this._explicitMinWidth - _local4 - this._paddingLeft - this._paddingRight,this._explicitMinHeight - _local11 - this._paddingTop - this._paddingBottom,this._explicitMaxWidth - _local21 - this._paddingLeft - this._paddingRight,this._explicitMaxHeight - _local11 - this._paddingTop - this._paddingBottom,this._explicitContentWidth,this._explicitContentHeight,this._explicitContentMinWidth,this._explicitContentMinHeight,this._explicitContentMaxWidth,this._explicitContentMaxHeight);
			if(_local2 !== null) {
				_local5 = this._explicitMaxWidth - this._paddingLeft - this._paddingRight;
				if(_local5 < _local2.maxWidth) {
					_local2.maxWidth = _local5;
				}
				_local31 = this._explicitMaxHeight - this._paddingTop - this._paddingBottom;
				if(_local31 < _local2.maxHeight) {
					_local2.maxHeight = _local31;
				}
			}
			if(this._content is IValidating) {
				IValidating(this._content).validate();
			}
			this._ignoreContentResize = _local18;
			var _local13:* = this._explicitMaxWidth;
			var _local7:* = this._explicitMaxHeight;
			if(this.stage !== null) {
				_local16 = this.stage.stageWidth - stagePaddingLeft - stagePaddingRight;
				if(_local13 > _local16) {
					_local13 = _local16;
				}
				_local22 = this.stage.stageHeight - stagePaddingTop - stagePaddingBottom;
				if(_local7 > _local22) {
					_local7 = _local22;
				}
			}
			var _local14:* = this._explicitWidth;
			if(_local15) {
				_local6 = 0;
				if(this._content !== null) {
					_local6 = this._content.width;
				}
				if(_local29 > _local6) {
					_local6 = _local29;
				}
				_local14 = _local6 + this._paddingLeft + this._paddingRight;
				_local27 = 0;
				if(this._backgroundSkin !== null) {
					_local27 = this._backgroundSkin.width;
				}
				if(_local27 > _local14) {
					_local14 = _local27;
				}
				_local14 += _local4;
				if(_local14 > _local13) {
					_local14 = _local13;
				}
			}
			var _local3:* = this._explicitHeight;
			if(_local9) {
				_local20 = 0;
				if(this._content !== null) {
					_local20 = this._content.height;
				}
				if(_local21 > _local6) {
					_local20 = _local21;
				}
				_local3 = _local20 + this._paddingTop + this._paddingBottom;
				_local25 = 0;
				if(this._backgroundSkin !== null) {
					_local25 = this._backgroundSkin.height;
				}
				if(_local25 > _local3) {
					_local3 = _local25;
				}
				_local3 += _local11;
				if(_local3 > _local7) {
					_local3 = _local7;
				}
			}
			var _local23:* = this._explicitMinWidth;
			if(_local24) {
				_local10 = 0;
				if(_local2 !== null) {
					_local10 = _local2.minWidth;
				} else if(this._content !== null) {
					_local10 = this._content.width;
				}
				if(_local29 > _local10) {
					_local10 = _local29;
				}
				_local23 = _local10 + this._paddingLeft + this._paddingRight;
				_local32 = 0;
				if(_local17 !== null) {
					_local32 = _local17.minWidth;
				} else if(this._backgroundSkin !== null) {
					_local32 = this._explicitBackgroundSkinMinWidth;
				}
				if(_local32 > _local23) {
					_local23 = _local32;
				}
				_local23 += _local4;
				if(_local23 > _local13) {
					_local23 = _local13;
				}
			}
			var _local30:* = this._explicitHeight;
			if(_local12) {
				_local26 = 0;
				if(_local2 !== null) {
					_local26 = _local2.minHeight;
				} else if(this._content !== null) {
					_local26 = this._content.height;
				}
				if(_local21 > _local26) {
					_local26 = _local21;
				}
				_local30 = _local26 + this._paddingTop + this._paddingBottom;
				_local19 = 0;
				if(_local17 !== null) {
					_local19 = _local17.minHeight;
				} else if(this._backgroundSkin !== null) {
					_local19 = this._explicitBackgroundSkinMinHeight;
				}
				if(_local19 > _local30) {
					_local30 = _local19;
				}
				_local30 += _local11;
				if(_local30 > _local7) {
					_local30 = _local7;
				}
			}
			if(this._backgroundSkin !== null) {
				this._backgroundSkin.width = _local8;
				this._backgroundSkin.height = _local28;
			}
			return this.saveMeasurements(_local14,_local3,_local23,_local30);
		}
		
		protected function refreshArrowSkin() : void {
			this.currentArrowSkin = null;
			if(this._arrowPosition == "bottom") {
				this.currentArrowSkin = this._bottomArrowSkin;
			} else if(this._bottomArrowSkin) {
				this._bottomArrowSkin.visible = false;
			}
			if(this._arrowPosition == "top") {
				this.currentArrowSkin = this._topArrowSkin;
			} else if(this._topArrowSkin) {
				this._topArrowSkin.visible = false;
			}
			if(this._arrowPosition == "left") {
				this.currentArrowSkin = this._leftArrowSkin;
			} else if(this._leftArrowSkin) {
				this._leftArrowSkin.visible = false;
			}
			if(this._arrowPosition == "right") {
				this.currentArrowSkin = this._rightArrowSkin;
			} else if(this._rightArrowSkin) {
				this._rightArrowSkin.visible = false;
			}
			if(this.currentArrowSkin) {
				this.currentArrowSkin.visible = true;
			}
		}
		
		protected function refreshEnabled() : void {
			if(this._content is IFeathersControl) {
				IFeathersControl(this._content).isEnabled = this._isEnabled;
			}
		}
		
		protected function layoutChildren() : void {
			var _local17:Number = NaN;
			var _local13:Number = NaN;
			var _local4:* = NaN;
			var _local5:Number = NaN;
			var _local9:Number = NaN;
			var _local14:* = NaN;
			var _local21:Number = NaN;
			var _local2:Number = NaN;
			var _local15:* = NaN;
			var _local3:Number = NaN;
			var _local6:Number = NaN;
			var _local7:* = NaN;
			var _local16:Number = NaN;
			var _local20:Number = NaN;
			var _local11:Boolean = false;
			var _local1:Number = 0;
			if(this._leftArrowSkin !== null && this._arrowPosition === "left") {
				_local1 = this._leftArrowSkin.width + this._leftArrowGap;
			}
			var _local8:Number = 0;
			if(this._topArrowSkin !== null && this._arrowPosition === "top") {
				_local8 = this._topArrowSkin.height + this._topArrowGap;
			}
			var _local12:Number = 0;
			if(this._rightArrowSkin !== null && this._arrowPosition === "right") {
				_local12 = this._rightArrowSkin.width + this._rightArrowGap;
			}
			var _local10:Number = 0;
			if(this._bottomArrowSkin !== null && this._arrowPosition === "bottom") {
				_local10 = this._bottomArrowSkin.height + this._bottomArrowGap;
			}
			var _local19:Number = this.actualWidth - _local1 - _local12;
			var _local18:Number = this.actualHeight - _local8 - _local10;
			if(this._backgroundSkin !== null) {
				this._backgroundSkin.x = _local1;
				this._backgroundSkin.y = _local8;
				this._backgroundSkin.width = _local19;
				this._backgroundSkin.height = _local18;
			}
			if(this.currentArrowSkin !== null) {
				_local17 = _local19 - this._paddingLeft - this._paddingRight;
				_local13 = _local18 - this._paddingTop - this._paddingBottom;
				if(this._arrowPosition === "left") {
					this._leftArrowSkin.x = _local1 - this._leftArrowSkin.width - this._leftArrowGap;
					_local4 = this._arrowOffset + _local8 + this._paddingTop;
					if(this._verticalAlign === "middle") {
						_local4 += Math.round((_local13 - this._leftArrowSkin.height) / 2);
					} else if(this._verticalAlign === "bottom") {
						_local4 += _local13 - this._leftArrowSkin.height;
					}
					_local5 = _local8 + this._paddingTop;
					if(_local5 > _local4) {
						_local4 = _local5;
					} else {
						_local9 = _local8 + this._paddingTop + _local13 - this._leftArrowSkin.height;
						if(_local9 < _local4) {
							_local4 = _local9;
						}
					}
					this._leftArrowSkin.y = _local4;
				} else if(this._arrowPosition === "right") {
					this._rightArrowSkin.x = _local1 + _local19 + this._rightArrowGap;
					_local14 = this._arrowOffset + _local8 + this._paddingTop;
					if(this._verticalAlign === "middle") {
						_local14 += Math.round((_local13 - this._rightArrowSkin.height) / 2);
					} else if(this._verticalAlign === "bottom") {
						_local14 += _local13 - this._rightArrowSkin.height;
					}
					_local21 = _local8 + this._paddingTop;
					if(_local21 > _local14) {
						_local14 = _local21;
					} else {
						_local2 = _local8 + this._paddingTop + _local13 - this._rightArrowSkin.height;
						if(_local2 < _local14) {
							_local14 = _local2;
						}
					}
					this._rightArrowSkin.y = _local14;
				} else if(this._arrowPosition === "bottom") {
					_local15 = this._arrowOffset + _local1 + this._paddingLeft;
					if(this._horizontalAlign === "center") {
						_local15 += Math.round((_local17 - this._bottomArrowSkin.width) / 2);
					} else if(this._horizontalAlign === "right") {
						_local15 += _local17 - this._bottomArrowSkin.width;
					}
					_local3 = _local1 + this._paddingLeft;
					if(_local3 > _local15) {
						_local15 = _local3;
					} else {
						_local6 = _local1 + this._paddingLeft + _local17 - this._bottomArrowSkin.width;
						if(_local6 < _local15) {
							_local15 = _local6;
						}
					}
					this._bottomArrowSkin.x = _local15;
					this._bottomArrowSkin.y = _local8 + _local18 + this._bottomArrowGap;
				} else {
					_local7 = this._arrowOffset + _local1 + this._paddingLeft;
					if(this._horizontalAlign === "center") {
						_local7 += Math.round((_local17 - this._topArrowSkin.width) / 2);
					} else if(this._horizontalAlign === "right") {
						_local7 += _local17 - this._topArrowSkin.width;
					}
					_local16 = _local1 + this._paddingLeft;
					if(_local16 > _local7) {
						_local7 = _local16;
					} else {
						_local20 = _local1 + this._paddingLeft + _local17 - this._topArrowSkin.width;
						if(_local20 < _local7) {
							_local7 = _local20;
						}
					}
					this._topArrowSkin.x = _local7;
					this._topArrowSkin.y = _local8 - this._topArrowSkin.height - this._topArrowGap;
				}
			}
			if(this._content !== null) {
				this._content.x = _local1 + this._paddingLeft;
				this._content.y = _local8 + this._paddingTop;
				_local11 = this._ignoreContentResize;
				this._ignoreContentResize = true;
				this._content.width = _local19 - this._paddingLeft - this._paddingRight;
				this._content.height = _local18 - this._paddingTop - this._paddingBottom;
				if(this._content is IValidating) {
					IValidating(this._content).validate();
				}
				this._ignoreContentResize = _local11;
			}
		}
		
		protected function positionRelativeToOrigin() : void {
			var _local6:int = 0;
			var _local9:String = null;
			if(this._origin === null) {
				return;
			}
			this._origin.getBounds(Starling.current.stage,HELPER_RECT);
			var _local8:* = this._lastGlobalBoundsOfOrigin != null;
			if(_local8 && this._lastGlobalBoundsOfOrigin.equals(HELPER_RECT)) {
				return;
			}
			if(!_local8) {
				this._lastGlobalBoundsOfOrigin = new Rectangle();
			}
			this._lastGlobalBoundsOfOrigin.x = HELPER_RECT.x;
			this._lastGlobalBoundsOfOrigin.y = HELPER_RECT.y;
			this._lastGlobalBoundsOfOrigin.width = HELPER_RECT.width;
			this._lastGlobalBoundsOfOrigin.height = HELPER_RECT.height;
			var _local2:Vector.<String> = this._supportedPositions;
			if(_local2 === null) {
				_local2 = DEFAULT_POSITIONS;
			}
			var _local3:Number = -1;
			var _local1:Number = -1;
			var _local7:Number = -1;
			var _local4:Number = -1;
			var _local5:int = int(_local2.length);
			_local6 = 0;
			while(_local6 < _local5) {
				switch(_local9 = _local2[_local6]) {
					case "top":
						this.measureWithArrowPosition("bottom");
						_local3 = this._lastGlobalBoundsOfOrigin.y - this.actualHeight;
						if(_local3 >= stagePaddingTop) {
							positionAboveOrigin(this,this._lastGlobalBoundsOfOrigin);
							return;
						}
						if(_local3 < 0) {
							_local3 = 0;
						}
						break;
					case "right":
						this.measureWithArrowPosition("left");
						_local1 = Starling.current.stage.stageWidth - actualWidth - (this._lastGlobalBoundsOfOrigin.x + this._lastGlobalBoundsOfOrigin.width);
						if(_local1 >= stagePaddingRight) {
							positionToRightOfOrigin(this,this._lastGlobalBoundsOfOrigin);
							return;
						}
						if(_local1 < 0) {
							_local1 = 0;
						}
						break;
					case "left":
						this.measureWithArrowPosition("right");
						_local4 = this._lastGlobalBoundsOfOrigin.x - this.actualWidth;
						if(_local4 >= stagePaddingLeft) {
							positionToLeftOfOrigin(this,this._lastGlobalBoundsOfOrigin);
							return;
						}
						if(_local4 < 0) {
							_local4 = 0;
						}
						break;
					default:
						this.measureWithArrowPosition("top");
						_local7 = Starling.current.stage.stageHeight - this.actualHeight - (this._lastGlobalBoundsOfOrigin.y + this._lastGlobalBoundsOfOrigin.height);
						if(_local7 >= stagePaddingBottom) {
							positionBelowOrigin(this,this._lastGlobalBoundsOfOrigin);
							return;
						}
						if(_local7 < 0) {
							_local7 = 0;
						}
						break;
				}
				_local6++;
			}
			if(_local7 !== -1 && _local7 >= _local3 && _local7 >= _local1 && _local7 >= _local4) {
				positionBelowOrigin(this,this._lastGlobalBoundsOfOrigin);
			} else if(_local3 !== -1 && _local3 >= _local1 && _local3 >= _local4) {
				positionAboveOrigin(this,this._lastGlobalBoundsOfOrigin);
			} else if(_local1 !== -1 && _local1 >= _local4) {
				positionToRightOfOrigin(this,this._lastGlobalBoundsOfOrigin);
			} else {
				positionToLeftOfOrigin(this,this._lastGlobalBoundsOfOrigin);
			}
		}
		
		protected function callout_addedToStageHandler(event:Event) : void {
			var _local2:int = -getDisplayObjectDepthFromStage(this);
			Starling.current.nativeStage.addEventListener("keyDown",callout_nativeStage_keyDownHandler,false,_local2,true);
			this.stage.addEventListener("touch",stage_touchHandler);
			this._isReadyToClose = false;
			this.addEventListener("enterFrame",callout_oneEnterFrameHandler);
		}
		
		protected function callout_removedFromStageHandler(event:Event) : void {
			this.stage.removeEventListener("touch",stage_touchHandler);
			Starling.current.nativeStage.removeEventListener("keyDown",callout_nativeStage_keyDownHandler);
		}
		
		protected function callout_oneEnterFrameHandler(event:Event) : void {
			this.removeEventListener("enterFrame",callout_oneEnterFrameHandler);
			this._isReadyToClose = true;
		}
		
		protected function callout_enterFrameHandler(event:EnterFrameEvent) : void {
			this.positionRelativeToOrigin();
		}
		
		protected function stage_touchHandler(event:TouchEvent) : void {
			var _local2:Touch = null;
			var _local3:DisplayObject = DisplayObject(event.target);
			if(!this._isReadyToClose || !this.closeOnTouchEndedOutside && !this.closeOnTouchBeganOutside || this.contains(_local3) || PopUpManager.isPopUp(this) && !PopUpManager.isTopLevelPopUp(this)) {
				return;
			}
			if(this._origin == _local3 || this._origin is DisplayObjectContainer && Boolean(DisplayObjectContainer(this._origin).contains(_local3))) {
				return;
			}
			if(this.closeOnTouchBeganOutside) {
				_local2 = event.getTouch(this.stage,"began");
				if(_local2) {
					this.close(this.disposeOnSelfClose);
					return;
				}
			}
			if(this.closeOnTouchEndedOutside) {
				_local2 = event.getTouch(this.stage,"ended");
				if(_local2) {
					this.close(this.disposeOnSelfClose);
					return;
				}
			}
		}
		
		protected function callout_nativeStage_keyDownHandler(event:KeyboardEvent) : void {
			if(event.isDefaultPrevented()) {
				return;
			}
			if(!this.closeOnKeys || this.closeOnKeys.indexOf(event.keyCode) < 0) {
				return;
			}
			event.preventDefault();
			this.close(this.disposeOnSelfClose);
		}
		
		protected function origin_removedFromStageHandler(event:Event) : void {
			this.close(this.disposeOnSelfClose);
		}
		
		protected function content_resizeHandler(event:Event) : void {
			if(this._ignoreContentResize) {
				return;
			}
			this.invalidate("size");
		}
	}
}

