package feathers.controls {
	import feathers.controls.supportClasses.TextFieldViewPort;
	import feathers.skins.IStyleProvider;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;
	import starling.events.Event;
	
	public class ScrollText extends Scroller {
		public static const SCROLL_POLICY_AUTO:String = "auto";
		
		public static const SCROLL_POLICY_ON:String = "on";
		
		public static const SCROLL_POLICY_OFF:String = "off";
		
		public static const SCROLL_BAR_DISPLAY_MODE_FLOAT:String = "float";
		
		public static const SCROLL_BAR_DISPLAY_MODE_FIXED:String = "fixed";
		
		public static const SCROLL_BAR_DISPLAY_MODE_FIXED_FLOAT:String = "fixedFloat";
		
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
		
		public static var globalStyleProvider:IStyleProvider;
		
		protected var textViewPort:TextFieldViewPort;
		
		protected var _text:String = "";
		
		protected var _isHTML:Boolean = false;
		
		protected var _textFormat:TextFormat;
		
		protected var _disabledTextFormat:TextFormat;
		
		protected var _styleSheet:StyleSheet;
		
		protected var _embedFonts:Boolean = false;
		
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
		
		protected var _textPaddingTop:Number = 0;
		
		protected var _textPaddingRight:Number = 0;
		
		protected var _textPaddingBottom:Number = 0;
		
		protected var _textPaddingLeft:Number = 0;
		
		protected var _visible:Boolean = true;
		
		protected var _alpha:Number = 1;
		
		public function ScrollText() {
			super();
			this.textViewPort = new TextFieldViewPort();
			this.textViewPort.addEventListener("triggered",textViewPort_triggeredHandler);
			this.viewPort = this.textViewPort;
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return ScrollText.globalStyleProvider;
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
		
		override public function get padding() : Number {
			return this._textPaddingTop;
		}
		
		override public function get paddingTop() : Number {
			return this._textPaddingTop;
		}
		
		override public function set paddingTop(value:Number) : void {
			if(this._textPaddingTop == value) {
				return;
			}
			this._textPaddingTop = value;
			this.invalidate("styles");
		}
		
		override public function get paddingRight() : Number {
			return this._textPaddingRight;
		}
		
		override public function set paddingRight(value:Number) : void {
			if(this._textPaddingRight == value) {
				return;
			}
			this._textPaddingRight = value;
			this.invalidate("styles");
		}
		
		override public function get paddingBottom() : Number {
			return this._textPaddingBottom;
		}
		
		override public function set paddingBottom(value:Number) : void {
			if(this._textPaddingBottom == value) {
				return;
			}
			this._textPaddingBottom = value;
			this.invalidate("styles");
		}
		
		override public function get paddingLeft() : Number {
			return this._textPaddingLeft;
		}
		
		override public function set paddingLeft(value:Number) : void {
			if(this._textPaddingLeft == value) {
				return;
			}
			this._textPaddingLeft = value;
			this.invalidate("styles");
		}
		
		override public function get visible() : Boolean {
			return this._visible;
		}
		
		override public function set visible(value:Boolean) : void {
			if(this._visible == value) {
				return;
			}
			this._visible = value;
			this.invalidate("styles");
		}
		
		override public function get alpha() : Number {
			return this._alpha;
		}
		
		override public function set alpha(value:Number) : void {
			if(this._alpha == value) {
				return;
			}
			this._alpha = value;
			this.invalidate("styles");
		}
		
		override protected function draw() : void {
			var _local1:Boolean = this.isInvalid("size");
			var _local2:Boolean = this.isInvalid("data");
			var _local4:Boolean = this.isInvalid("scroll");
			var _local3:Boolean = this.isInvalid("styles");
			if(_local2) {
				this.textViewPort.text = this._text;
				this.textViewPort.isHTML = this._isHTML;
			}
			if(_local3) {
				this.textViewPort.antiAliasType = this._antiAliasType;
				this.textViewPort.background = this._background;
				this.textViewPort.backgroundColor = this._backgroundColor;
				this.textViewPort.border = this._border;
				this.textViewPort.borderColor = this._borderColor;
				this.textViewPort.cacheAsBitmap = this._cacheAsBitmap;
				this.textViewPort.condenseWhite = this._condenseWhite;
				this.textViewPort.displayAsPassword = this._displayAsPassword;
				this.textViewPort.gridFitType = this._gridFitType;
				this.textViewPort.sharpness = this._sharpness;
				this.textViewPort.thickness = this._thickness;
				this.textViewPort.textFormat = this._textFormat;
				this.textViewPort.disabledTextFormat = this._disabledTextFormat;
				this.textViewPort.styleSheet = this._styleSheet;
				this.textViewPort.embedFonts = this._embedFonts;
				this.textViewPort.paddingTop = this._textPaddingTop;
				this.textViewPort.paddingRight = this._textPaddingRight;
				this.textViewPort.paddingBottom = this._textPaddingBottom;
				this.textViewPort.paddingLeft = this._textPaddingLeft;
				this.textViewPort.visible = this._visible;
				this.textViewPort.alpha = this._alpha;
			}
			super.draw();
		}
		
		protected function textViewPort_triggeredHandler(event:Event, link:String) : void {
			this.dispatchEventWith("triggered",false,link);
		}
	}
}

