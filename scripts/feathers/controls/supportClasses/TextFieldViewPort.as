package feathers.controls.supportClasses {
	import feathers.core.FeathersControl;
	import feathers.utils.geom.matrixToRotation;
	import feathers.utils.geom.matrixToScaleX;
	import feathers.utils.geom.matrixToScaleY;
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.rendering.Painter;
	import starling.utils.MatrixUtil;
	
	public class TextFieldViewPort extends FeathersControl implements IViewPort {
		private static const HELPER_MATRIX:Matrix = new Matrix();
		
		private static const HELPER_POINT:Point = new Point();
		
		private var _textFieldContainer:Sprite;
		
		private var _textField:TextField;
		
		private var _text:String = "";
		
		private var _isHTML:Boolean = false;
		
		private var _textFormat:TextFormat;
		
		private var _disabledTextFormat:TextFormat;
		
		protected var _styleSheet:StyleSheet;
		
		private var _embedFonts:Boolean = false;
		
		private var _antiAliasType:String = "advanced";
		
		private var _background:Boolean = false;
		
		private var _backgroundColor:uint = 16777215;
		
		private var _border:Boolean = false;
		
		private var _borderColor:uint = 0;
		
		private var _cacheAsBitmap:Boolean = true;
		
		private var _condenseWhite:Boolean = false;
		
		private var _displayAsPassword:Boolean = false;
		
		private var _gridFitType:String = "pixel";
		
		private var _sharpness:Number = 0;
		
		private var _thickness:Number = 0;
		
		private var _actualMinVisibleWidth:Number = 0;
		
		private var _explicitMinVisibleWidth:Number;
		
		private var _maxVisibleWidth:Number = Infinity;
		
		private var _actualVisibleWidth:Number = 0;
		
		private var _explicitVisibleWidth:Number = NaN;
		
		private var _actualMinVisibleHeight:Number = 0;
		
		private var _explicitMinVisibleHeight:Number;
		
		private var _maxVisibleHeight:Number = Infinity;
		
		private var _actualVisibleHeight:Number = 0;
		
		private var _explicitVisibleHeight:Number = NaN;
		
		private var _scrollStep:Number;
		
		private var _horizontalScrollPosition:Number = 0;
		
		private var _verticalScrollPosition:Number = 0;
		
		private var _paddingTop:Number = 0;
		
		private var _paddingRight:Number = 0;
		
		private var _paddingBottom:Number = 0;
		
		private var _paddingLeft:Number = 0;
		
		public function TextFieldViewPort() {
			super();
			this.addEventListener("addedToStage",addedToStageHandler);
			this.addEventListener("removedFromStage",removedFromStageHandler);
		}
		
		public function get text() : String {
			return this._text;
		}
		
		public function set text(value:String) : void {
			if(!value) {
				value = "";
			}
			if(this._text == value) {
				return;
			}
			this._text = value;
			this.invalidate("data");
		}
		
		public function get isHTML() : Boolean {
			return this._isHTML;
		}
		
		public function set isHTML(value:Boolean) : void {
			if(this._isHTML == value) {
				return;
			}
			this._isHTML = value;
			this.invalidate("data");
		}
		
		public function get textFormat() : TextFormat {
			return this._textFormat;
		}
		
		public function set textFormat(value:TextFormat) : void {
			if(this._textFormat == value) {
				return;
			}
			this._textFormat = value;
			this.invalidate("styles");
		}
		
		public function get disabledTextFormat() : TextFormat {
			return this._disabledTextFormat;
		}
		
		public function set disabledTextFormat(value:TextFormat) : void {
			if(this._disabledTextFormat == value) {
				return;
			}
			this._disabledTextFormat = value;
			this.invalidate("styles");
		}
		
		public function get styleSheet() : StyleSheet {
			return this._styleSheet;
		}
		
		public function set styleSheet(value:StyleSheet) : void {
			if(this._styleSheet == value) {
				return;
			}
			this._styleSheet = value;
			this.invalidate("styles");
		}
		
		public function get embedFonts() : Boolean {
			return this._embedFonts;
		}
		
		public function set embedFonts(value:Boolean) : void {
			if(this._embedFonts == value) {
				return;
			}
			this._embedFonts = value;
			this.invalidate("styles");
		}
		
		public function get antiAliasType() : String {
			return this._antiAliasType;
		}
		
		public function set antiAliasType(value:String) : void {
			if(this._antiAliasType == value) {
				return;
			}
			this._antiAliasType = value;
			this.invalidate("styles");
		}
		
		public function get background() : Boolean {
			return this._background;
		}
		
		public function set background(value:Boolean) : void {
			if(this._background == value) {
				return;
			}
			this._background = value;
			this.invalidate("styles");
		}
		
		public function get backgroundColor() : uint {
			return this._backgroundColor;
		}
		
		public function set backgroundColor(value:uint) : void {
			if(this._backgroundColor == value) {
				return;
			}
			this._backgroundColor = value;
			this.invalidate("styles");
		}
		
		public function get border() : Boolean {
			return this._border;
		}
		
		public function set border(value:Boolean) : void {
			if(this._border == value) {
				return;
			}
			this._border = value;
			this.invalidate("styles");
		}
		
		public function get borderColor() : uint {
			return this._borderColor;
		}
		
		public function set borderColor(value:uint) : void {
			if(this._borderColor == value) {
				return;
			}
			this._borderColor = value;
			this.invalidate("styles");
		}
		
		public function get cacheAsBitmap() : Boolean {
			return this._cacheAsBitmap;
		}
		
		public function set cacheAsBitmap(value:Boolean) : void {
			if(this._cacheAsBitmap == value) {
				return;
			}
			this._cacheAsBitmap = value;
			this.invalidate("styles");
		}
		
		public function get condenseWhite() : Boolean {
			return this._condenseWhite;
		}
		
		public function set condenseWhite(value:Boolean) : void {
			if(this._condenseWhite == value) {
				return;
			}
			this._condenseWhite = value;
			this.invalidate("styles");
		}
		
		public function get displayAsPassword() : Boolean {
			return this._displayAsPassword;
		}
		
		public function set displayAsPassword(value:Boolean) : void {
			if(this._displayAsPassword == value) {
				return;
			}
			this._displayAsPassword = value;
			this.invalidate("styles");
		}
		
		public function get gridFitType() : String {
			return this._gridFitType;
		}
		
		public function set gridFitType(value:String) : void {
			if(this._gridFitType == value) {
				return;
			}
			this._gridFitType = value;
			this.invalidate("styles");
		}
		
		public function get sharpness() : Number {
			return this._sharpness;
		}
		
		public function set sharpness(value:Number) : void {
			if(this._sharpness == value) {
				return;
			}
			this._sharpness = value;
			this.invalidate("data");
		}
		
		public function get thickness() : Number {
			return this._thickness;
		}
		
		public function set thickness(value:Number) : void {
			if(this._thickness == value) {
				return;
			}
			this._thickness = value;
			this.invalidate("data");
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
				if(this._explicitVisibleWidth !== this._explicitVisibleWidth && (this._actualVisibleWidth < value || this._actualVisibleWidth === _local3)) {
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
			if(this._explicitVisibleWidth !== this._explicitVisibleWidth && (this._actualVisibleWidth > value || this._actualVisibleWidth === _local2)) {
				this.invalidate("size");
			}
		}
		
		public function get visibleWidth() : Number {
			if(this._explicitVisibleWidth !== this._explicitVisibleWidth) {
				return this._actualVisibleWidth;
			}
			return this._explicitVisibleWidth;
		}
		
		public function set visibleWidth(value:Number) : void {
			if(this._explicitVisibleWidth == value || value !== value && this._explicitVisibleWidth !== this._explicitVisibleWidth) {
				return;
			}
			this._explicitVisibleWidth = value;
			if(this._actualVisibleWidth !== value) {
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
				if(this._explicitVisibleHeight !== this._explicitVisibleHeight && (this._actualVisibleHeight < value || this._actualVisibleHeight === _local3)) {
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
			if(this._explicitVisibleHeight !== this._explicitVisibleHeight && (this._actualVisibleHeight > value || this._actualVisibleHeight === _local2)) {
				this.invalidate("size");
			}
		}
		
		public function get visibleHeight() : Number {
			if(this._explicitVisibleHeight !== this._explicitVisibleHeight) {
				return this._actualVisibleHeight;
			}
			return this._explicitVisibleHeight;
		}
		
		public function set visibleHeight(value:Number) : void {
			if(this._explicitVisibleHeight == value || value !== value && this._explicitVisibleHeight !== this._explicitVisibleHeight) {
				return;
			}
			this._explicitVisibleHeight = value;
			if(this._actualVisibleHeight !== value) {
				this.invalidate("size");
			}
		}
		
		public function get contentX() : Number {
			return 0;
		}
		
		public function get contentY() : Number {
			return 0;
		}
		
		public function get horizontalScrollStep() : Number {
			return this._scrollStep;
		}
		
		public function get verticalScrollStep() : Number {
			return this._scrollStep;
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
		
		public function get requiresMeasurementOnScroll() : Boolean {
			return false;
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
		
		override public function render(painter:Painter) : void {
			painter.excludeFromCache(this);
			var _local2:Rectangle = Starling.current.viewPort;
			HELPER_POINT.x = HELPER_POINT.y = 0;
			this.parent.getTransformationMatrix(this.stage,HELPER_MATRIX);
			MatrixUtil.transformCoords(HELPER_MATRIX,0,0,HELPER_POINT);
			var _local4:Number = 1;
			if(Starling.current.supportHighResolutions) {
				_local4 = Starling.current.nativeStage.contentsScaleFactor;
			}
			var _local3:Number = Starling.contentScaleFactor / _local4;
			this._textFieldContainer.x = _local2.x + HELPER_POINT.x * _local3;
			this._textFieldContainer.y = _local2.y + HELPER_POINT.y * _local3;
			this._textFieldContainer.scaleX = matrixToScaleX(HELPER_MATRIX) * _local3;
			this._textFieldContainer.scaleY = matrixToScaleY(HELPER_MATRIX) * _local3;
			this._textFieldContainer.rotation = matrixToRotation(HELPER_MATRIX) * (3 * 60) / 3.141592653589793;
			this._textFieldContainer.alpha = painter.state.alpha;
			super.render(painter);
		}
		
		override protected function initialize() : void {
			this._textFieldContainer = new Sprite();
			this._textFieldContainer.visible = false;
			this._textField = new TextField();
			this._textField.autoSize = "left";
			this._textField.selectable = false;
			this._textField.mouseWheelEnabled = false;
			this._textField.wordWrap = true;
			this._textField.multiline = true;
			this._textField.addEventListener("link",textField_linkHandler);
			this._textFieldContainer.addChild(this._textField);
		}
		
		override protected function draw() : void {
			var _local4:Rectangle = null;
			var _local6:Boolean = this.isInvalid("data");
			var _local2:Boolean = this.isInvalid("size");
			var _local9:Boolean = this.isInvalid("scroll");
			var _local7:Boolean = this.isInvalid("styles");
			var _local5:Boolean = this.isInvalid("state");
			if(_local7) {
				this._textField.antiAliasType = this._antiAliasType;
				this._textField.background = this._background;
				this._textField.backgroundColor = this._backgroundColor;
				this._textField.border = this._border;
				this._textField.borderColor = this._borderColor;
				this._textField.condenseWhite = this._condenseWhite;
				this._textField.displayAsPassword = this._displayAsPassword;
				this._textField.embedFonts = this._embedFonts;
				this._textField.gridFitType = this._gridFitType;
				this._textField.sharpness = this._sharpness;
				this._textField.thickness = this._thickness;
				this._textField.cacheAsBitmap = this._cacheAsBitmap;
				this._textField.x = this._paddingLeft;
				this._textField.y = this._paddingTop;
			}
			if(_local6 || _local7 || _local5) {
				if(this._styleSheet) {
					this._textField.styleSheet = this._styleSheet;
				} else {
					this._textField.styleSheet = null;
					if(!this._isEnabled && this._disabledTextFormat) {
						this._textField.defaultTextFormat = this._disabledTextFormat;
					} else if(this._textFormat) {
						this._textField.defaultTextFormat = this._textFormat;
					}
				}
				if(this._isHTML) {
					this._textField.htmlText = this._text;
				} else {
					this._textField.text = this._text;
				}
				this._scrollStep = this._textField.getLineMetrics(0).height * Starling.contentScaleFactor;
			}
			var _local8:Number = this._explicitVisibleWidth;
			if(_local8 != _local8) {
				if(this.stage) {
					_local8 = this.stage.stageWidth;
				} else {
					_local8 = Starling.current.stage.stageWidth;
				}
				if(_local8 < this._explicitMinVisibleWidth) {
					_local8 = this._explicitMinVisibleWidth;
				} else if(_local8 > this._maxVisibleWidth) {
					_local8 = this._maxVisibleWidth;
				}
			}
			this._textField.width = _local8 - this._paddingLeft - this._paddingRight;
			var _local3:Number = this._textField.height + this._paddingTop + this._paddingBottom;
			var _local1:* = this._explicitVisibleHeight;
			if(_local1 != _local1) {
				_local1 = _local3;
				if(_local1 < this._explicitMinVisibleHeight) {
					_local1 = this._explicitMinVisibleHeight;
				} else if(_local1 > this._maxVisibleHeight) {
					_local1 = this._maxVisibleHeight;
				}
			}
			_local2 = this.saveMeasurements(_local8,_local3,_local8,_local3) || _local2;
			this._actualVisibleWidth = _local8;
			this._actualVisibleHeight = _local1;
			this._actualMinVisibleWidth = _local8;
			this._actualMinVisibleHeight = _local1;
			if(_local2 || _local9) {
				_local4 = this._textFieldContainer.scrollRect;
				if(!_local4) {
					_local4 = new Rectangle();
				}
				_local4.width = _local8;
				_local4.height = _local1;
				_local4.x = this._horizontalScrollPosition;
				_local4.y = this._verticalScrollPosition;
				this._textFieldContainer.scrollRect = _local4;
			}
		}
		
		private function addedToStageHandler(event:Event) : void {
			Starling.current.nativeStage.addChild(this._textFieldContainer);
			this.addEventListener("enterFrame",enterFrameHandler);
		}
		
		private function removedFromStageHandler(event:Event) : void {
			Starling.current.nativeStage.removeChild(this._textFieldContainer);
			this.removeEventListener("enterFrame",enterFrameHandler);
		}
		
		private function enterFrameHandler(event:Event) : void {
			var _local2:DisplayObject = this;
			while(_local2.visible) {
				_local2 = _local2.parent;
				if(!_local2) {
					this._textFieldContainer.visible = true;
					return;
				}
			}
			this._textFieldContainer.visible = false;
		}
		
		protected function textField_linkHandler(event:TextEvent) : void {
			this.dispatchEventWith("triggered",false,event.text);
		}
	}
}

