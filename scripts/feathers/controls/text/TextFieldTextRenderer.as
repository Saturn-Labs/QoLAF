package feathers.controls.text {
	import feathers.core.FeathersControl;
	import feathers.core.IStateContext;
	import feathers.core.IStateObserver;
	import feathers.core.ITextRenderer;
	import feathers.core.IToggle;
	import feathers.skins.IStyleProvider;
	import feathers.utils.geom.matrixToScaleX;
	import feathers.utils.geom.matrixToScaleY;
	import feathers.utils.math.roundUpToNearest;
	import flash.display.BitmapData;
	import flash.filters.BitmapFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;
	import starling.rendering.Painter;
	import starling.textures.ConcreteTexture;
	import starling.textures.Texture;
	import starling.utils.MathUtil;
	
	public class TextFieldTextRenderer extends FeathersControl implements ITextRenderer, IStateObserver {
		public static var globalStyleProvider:IStyleProvider;
		
		private static const HELPER_POINT:Point = new Point();
		
		private static const HELPER_MATRIX:Matrix = new Matrix();
		
		private static const HELPER_RECTANGLE:Rectangle = new Rectangle();
		
		protected var textField:TextField;
		
		protected var textSnapshot:Image;
		
		protected var textSnapshots:Vector.<Image>;
		
		protected var _textSnapshotOffsetX:Number = 0;
		
		protected var _textSnapshotOffsetY:Number = 0;
		
		protected var _previousActualWidth:Number = NaN;
		
		protected var _previousActualHeight:Number = NaN;
		
		protected var _snapshotWidth:int = 0;
		
		protected var _snapshotHeight:int = 0;
		
		protected var _snapshotVisibleWidth:int = 0;
		
		protected var _snapshotVisibleHeight:int = 0;
		
		protected var _needsNewTexture:Boolean = false;
		
		protected var _hasMeasured:Boolean = false;
		
		protected var _text:String = "";
		
		protected var _isHTML:Boolean = false;
		
		protected var currentTextFormat:TextFormat;
		
		protected var _textFormatForState:Object;
		
		protected var _textFormat:TextFormat;
		
		protected var _disabledTextFormat:TextFormat;
		
		protected var _selectedTextFormat:TextFormat;
		
		protected var _styleSheet:StyleSheet;
		
		protected var _embedFonts:Boolean = false;
		
		protected var _wordWrap:Boolean = false;
		
		protected var _pixelSnapping:Boolean = true;
		
		private var _antiAliasType:String = "advanced";
		
		private var _background:Boolean = false;
		
		private var _backgroundColor:uint = 16777215;
		
		private var _border:Boolean = false;
		
		private var _borderColor:uint = 0;
		
		private var _condenseWhite:Boolean = false;
		
		private var _displayAsPassword:Boolean = false;
		
		private var _gridFitType:String = "pixel";
		
		private var _sharpness:Number = 0;
		
		private var _thickness:Number = 0;
		
		protected var _maxTextureDimensions:int = 2048;
		
		protected var _nativeFilters:Array;
		
		protected var _useGutter:Boolean = false;
		
		protected var _stateContext:IStateContext;
		
		protected var _lastGlobalScaleX:Number = 0;
		
		protected var _lastGlobalScaleY:Number = 0;
		
		protected var _lastContentScaleFactor:Number = 0;
		
		protected var _updateSnapshotOnScaleChange:Boolean = false;
		
		protected var _useSnapshotDelayWorkaround:Boolean = false;
		
		public function TextFieldTextRenderer() {
			super();
			this.isQuickHitAreaEnabled = true;
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return TextFieldTextRenderer.globalStyleProvider;
		}
		
		public function get text() : String {
			return this._text;
		}
		
		public function set text(value:String) : void {
			if(this._text == value) {
				return;
			}
			if(value === null) {
				value = "";
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
		
		public function get selectedTextFormat() : TextFormat {
			return this._selectedTextFormat;
		}
		
		public function set selectedTextFormat(value:TextFormat) : void {
			if(this._selectedTextFormat == value) {
				return;
			}
			this._selectedTextFormat = value;
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
		
		public function get baseline() : Number {
			if(!this.textField) {
				return 0;
			}
			var _local1:Number = 0;
			if(this._useGutter) {
				_local1 = 2;
			}
			return _local1 + this.textField.getLineMetrics(0).ascent;
		}
		
		public function get wordWrap() : Boolean {
			return this._wordWrap;
		}
		
		public function set wordWrap(value:Boolean) : void {
			if(this._wordWrap == value) {
				return;
			}
			this._wordWrap = value;
			this.invalidate("styles");
		}
		
		public function get pixelSnapping() : Boolean {
			return this._pixelSnapping;
		}
		
		public function set pixelSnapping(value:Boolean) : void {
			if(this._pixelSnapping === value) {
				return;
			}
			this._pixelSnapping = value;
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
		
		public function get maxTextureDimensions() : int {
			return this._maxTextureDimensions;
		}
		
		public function set maxTextureDimensions(value:int) : void {
			if(Starling.current.profile == "baselineConstrained") {
				value = MathUtil.getNextPowerOfTwo(value);
			}
			if(this._maxTextureDimensions == value) {
				return;
			}
			this._maxTextureDimensions = value;
			this._needsNewTexture = true;
			this.invalidate("size");
		}
		
		public function get nativeFilters() : Array {
			return this._nativeFilters;
		}
		
		public function set nativeFilters(value:Array) : void {
			if(this._nativeFilters == value) {
				return;
			}
			this._nativeFilters = value;
			this.invalidate("styles");
		}
		
		public function get useGutter() : Boolean {
			return this._useGutter;
		}
		
		public function set useGutter(value:Boolean) : void {
			if(this._useGutter == value) {
				return;
			}
			this._useGutter = value;
			this.invalidate("styles");
		}
		
		public function get stateContext() : IStateContext {
			return this._stateContext;
		}
		
		public function set stateContext(value:IStateContext) : void {
			if(this._stateContext === value) {
				return;
			}
			if(this._stateContext) {
				this._stateContext.removeEventListener("stageChange",stateContext_stateChangeHandler);
			}
			this._stateContext = value;
			if(this._stateContext) {
				this._stateContext.addEventListener("stageChange",stateContext_stateChangeHandler);
			}
			this.invalidate("state");
		}
		
		public function get updateSnapshotOnScaleChange() : Boolean {
			return this._updateSnapshotOnScaleChange;
		}
		
		public function set updateSnapshotOnScaleChange(value:Boolean) : void {
			if(this._updateSnapshotOnScaleChange == value) {
				return;
			}
			this._updateSnapshotOnScaleChange = value;
			this.invalidate("data");
		}
		
		public function get useSnapshotDelayWorkaround() : Boolean {
			return this._useSnapshotDelayWorkaround;
		}
		
		public function set useSnapshotDelayWorkaround(value:Boolean) : void {
			if(this._useSnapshotDelayWorkaround == value) {
				return;
			}
			this._useSnapshotDelayWorkaround = value;
			this.invalidate("data");
		}
		
		override public function dispose() : void {
			var _local1:int = 0;
			var _local2:int = 0;
			var _local3:Image = null;
			if(this.textSnapshot) {
				this.textSnapshot.texture.dispose();
				this.removeChild(this.textSnapshot,true);
				this.textSnapshot = null;
			}
			if(this.textSnapshots) {
				_local1 = int(this.textSnapshots.length);
				_local2 = 0;
				while(_local2 < _local1) {
					_local3 = this.textSnapshots[_local2];
					_local3.texture.dispose();
					this.removeChild(_local3,true);
					_local2++;
				}
				this.textSnapshots = null;
			}
			this.textField = null;
			this.stateContext = null;
			this._previousActualWidth = NaN;
			this._previousActualHeight = NaN;
			this._needsNewTexture = false;
			this._snapshotWidth = 0;
			this._snapshotHeight = 0;
			super.dispose();
		}
		
		override public function render(painter:Painter) : void {
			var _local3:Number = NaN;
			var _local4:Number = NaN;
			var _local5:Number = NaN;
			var _local8:Number = NaN;
			var _local9:Number = NaN;
			var _local13:int = 0;
			var _local10:Number = NaN;
			var _local11:Number = NaN;
			var _local2:* = NaN;
			var _local6:* = NaN;
			var _local7:* = NaN;
			var _local12:* = NaN;
			var _local14:Image = null;
			if(this.textSnapshot) {
				this.getTransformationMatrix(this.stage,HELPER_MATRIX);
				if(this._updateSnapshotOnScaleChange) {
					_local3 = matrixToScaleX(HELPER_MATRIX);
					_local4 = matrixToScaleY(HELPER_MATRIX);
					if(_local3 != this._lastGlobalScaleX || _local4 != this._lastGlobalScaleY || Starling.contentScaleFactor != this._lastContentScaleFactor) {
						this.invalidate("size");
						this.validate();
					}
				}
				_local5 = Starling.current.contentScaleFactor;
				if(!this._nativeFilters || this._nativeFilters.length === 0) {
					_local8 = 0;
					_local9 = 0;
				} else {
					_local8 = this._textSnapshotOffsetX / _local5;
					_local9 = this._textSnapshotOffsetY / _local5;
				}
				_local13 = -1;
				_local10 = this._snapshotWidth;
				_local11 = this._snapshotHeight;
				_local2 = _local8;
				_local6 = _local9;
				do {
					_local7 = _local10;
					if(_local7 > this._maxTextureDimensions) {
						_local7 = this._maxTextureDimensions;
					}
					do {
						_local12 = _local11;
						if(_local12 > this._maxTextureDimensions) {
							_local12 = this._maxTextureDimensions;
						}
						if(_local13 < 0) {
							_local14 = this.textSnapshot;
						} else {
							_local14 = this.textSnapshots[_local13];
						}
						_local14.x = _local2 / _local5;
						_local14.y = _local6 / _local5;
						if(this._updateSnapshotOnScaleChange) {
							_local14.x /= this._lastGlobalScaleX;
							_local14.y /= this._lastGlobalScaleX;
						}
						_local13++;
						_local6 += _local12;
					}
					while(_local11 -= _local12, _local11 > 0);
					
					_local2 += _local7;
					_local10 -= _local7;
					_local6 = _local9;
					_local11 = this._snapshotHeight;
				}
				while(_local10 > 0);
				
			}
			super.render(painter);
		}
		
		public function measureText(result:Point = null) : Point {
			if(!result) {
				result = new Point();
			}
			var _local2:* = this._explicitWidth !== this._explicitWidth;
			var _local3:* = this._explicitHeight !== this._explicitHeight;
			if(!_local2 && !_local3) {
				result.x = this._explicitWidth;
				result.y = this._explicitHeight;
				return result;
			}
			if(!this._isInitialized) {
				this.initializeNow();
			}
			this.commit();
			return this.measure(result);
		}
		
		public function setTextFormatForState(state:String, textFormat:TextFormat) : void {
			if(textFormat) {
				if(!this._textFormatForState) {
					this._textFormatForState = {};
				}
				this._textFormatForState[state] = textFormat;
			} else {
				delete this._textFormatForState[state];
			}
			if(this._stateContext && this._stateContext.currentState === state) {
				this.invalidate("state");
			}
		}
		
		override protected function initialize() : void {
			var _local1:Number = NaN;
			if(!this.textField) {
				this.textField = new TextField();
				_local1 = Starling.contentScaleFactor;
				this.textField.scaleX = _local1;
				this.textField.scaleY = _local1;
				this.textField.mouseEnabled = this.textField.mouseWheelEnabled = false;
				this.textField.selectable = false;
				this.textField.multiline = true;
			}
		}
		
		override protected function draw() : void {
			var _local1:Boolean = this.isInvalid("size");
			this.commit();
			this._hasMeasured = false;
			_local1 = this.autoSizeIfNeeded() || _local1;
			this.layout(_local1);
		}
		
		protected function commit() : void {
			var _local2:Boolean = this.isInvalid("styles");
			var _local3:Boolean = this.isInvalid("data");
			var _local1:Boolean = this.isInvalid("state");
			if(_local2 || _local1) {
				this.refreshTextFormat();
			}
			if(_local2) {
				this.textField.antiAliasType = this._antiAliasType;
				this.textField.background = this._background;
				this.textField.backgroundColor = this._backgroundColor;
				this.textField.border = this._border;
				this.textField.borderColor = this._borderColor;
				this.textField.condenseWhite = this._condenseWhite;
				this.textField.displayAsPassword = this._displayAsPassword;
				this.textField.gridFitType = this._gridFitType;
				this.textField.sharpness = this._sharpness;
				this.textField.thickness = this._thickness;
				this.textField.filters = this._nativeFilters;
			}
			if(_local3 || _local2 || _local1) {
				this.textField.wordWrap = this._wordWrap;
				this.textField.embedFonts = this._embedFonts;
				if(this._styleSheet) {
					this.textField.styleSheet = this._styleSheet;
				} else {
					this.textField.styleSheet = null;
					this.textField.defaultTextFormat = this.currentTextFormat;
				}
				if(this._isHTML) {
					this.textField.htmlText = this._text;
				} else {
					this.textField.text = this._text;
				}
			}
		}
		
		protected function measure(result:Point = null) : Point {
			var _local2:Number = NaN;
			if(!result) {
				result = new Point();
			}
			var _local4:* = this._explicitWidth !== this._explicitWidth;
			var _local7:* = this._explicitHeight !== this._explicitHeight;
			this.textField.autoSize = "left";
			this.textField.wordWrap = false;
			var _local6:Number = Starling.contentScaleFactor;
			var _local8:Number = 4;
			if(this._useGutter) {
				_local8 = 0;
			}
			var _local3:Number = this._explicitWidth;
			if(_local4) {
				_local2 = this.textField.width;
				_local3 = this.textField.width / _local6 - _local8;
				if(_local3 < this._explicitMinWidth) {
					_local3 = this._explicitMinWidth;
				} else if(_local3 > this._explicitMaxWidth) {
					_local3 = this._explicitMaxWidth;
				}
			}
			if(!_local4 || this.textField.width / _local6 - _local8 > _local3) {
				this.textField.width = _local3 + _local8;
				this.textField.wordWrap = this._wordWrap;
			}
			var _local5:Number = this._explicitHeight;
			if(_local7) {
				_local5 = this.textField.height / _local6 - _local8;
				_local5 = roundUpToNearest(_local5,0.05);
				if(_local5 < this._explicitMinHeight) {
					_local5 = this._explicitMinHeight;
				} else if(_local5 > this._explicitMaxHeight) {
					_local5 = this._explicitMaxHeight;
				}
			}
			this.textField.autoSize = "none";
			this.textField.width = this.actualWidth + _local8;
			this.textField.height = this.actualHeight + _local8;
			result.x = _local3;
			result.y = _local5;
			this._hasMeasured = true;
			return result;
		}
		
		protected function layout(sizeInvalid:Boolean) : void {
			var _local12:Number = NaN;
			var _local7:Number = NaN;
			var _local11:BitmapData = null;
			var _local9:* = false;
			var _local10:ConcreteTexture = null;
			var _local8:* = false;
			var _local4:Boolean = this.isInvalid("styles");
			var _local5:Boolean = this.isInvalid("data");
			var _local2:Boolean = this.isInvalid("state");
			var _local3:Number = Starling.contentScaleFactor;
			var _local6:Number = 4;
			if(this._useGutter) {
				_local6 = 0;
			}
			if(!this._hasMeasured && this._wordWrap) {
				this.textField.autoSize = "left";
				this.textField.wordWrap = false;
				if(this.textField.width / _local3 - _local6 > this.actualWidth) {
					this.textField.wordWrap = true;
				}
				this.textField.autoSize = "none";
				this.textField.width = this.actualWidth + _local6;
			}
			if(sizeInvalid) {
				this.textField.width = this.actualWidth + _local6;
				this.textField.height = this.actualHeight + _local6;
				_local12 = Math.ceil(this.actualWidth * _local3);
				_local7 = Math.ceil(this.actualHeight * _local3);
				if(this._updateSnapshotOnScaleChange) {
					this.getTransformationMatrix(this.stage,HELPER_MATRIX);
					_local12 *= matrixToScaleX(HELPER_MATRIX);
					_local7 *= matrixToScaleY(HELPER_MATRIX);
				}
				if(_local12 >= 1 && _local7 >= 1 && this._nativeFilters && this._nativeFilters.length > 0) {
					HELPER_MATRIX.identity();
					HELPER_MATRIX.scale(_local3,_local3);
					_local11 = new BitmapData(_local12,_local7,true,0xff00ff);
					_local11.draw(this.textField,HELPER_MATRIX,null,null,HELPER_RECTANGLE);
					this.measureNativeFilters(_local11,HELPER_RECTANGLE);
					_local11.dispose();
					_local11 = null;
					this._textSnapshotOffsetX = HELPER_RECTANGLE.x;
					this._textSnapshotOffsetY = HELPER_RECTANGLE.y;
					_local12 = HELPER_RECTANGLE.width;
					_local7 = HELPER_RECTANGLE.height;
				}
				_local9 = Starling.current.profile != "baselineConstrained";
				if(_local9) {
					if(_local12 > this._maxTextureDimensions) {
						this._snapshotWidth = int(_local12 / this._maxTextureDimensions) * this._maxTextureDimensions + _local12 % this._maxTextureDimensions;
					} else {
						this._snapshotWidth = _local12;
					}
				} else if(_local12 > this._maxTextureDimensions) {
					this._snapshotWidth = int(_local12 / this._maxTextureDimensions) * this._maxTextureDimensions + MathUtil.getNextPowerOfTwo(_local12 % this._maxTextureDimensions);
				} else {
					this._snapshotWidth = MathUtil.getNextPowerOfTwo(_local12);
				}
				if(_local9) {
					if(_local7 > this._maxTextureDimensions) {
						this._snapshotHeight = int(_local7 / this._maxTextureDimensions) * this._maxTextureDimensions + _local7 % this._maxTextureDimensions;
					} else {
						this._snapshotHeight = _local7;
					}
				} else if(_local7 > this._maxTextureDimensions) {
					this._snapshotHeight = int(_local7 / this._maxTextureDimensions) * this._maxTextureDimensions + MathUtil.getNextPowerOfTwo(_local7 % this._maxTextureDimensions);
				} else {
					this._snapshotHeight = MathUtil.getNextPowerOfTwo(_local7);
				}
				_local10 = !!this.textSnapshot ? this.textSnapshot.texture.root : null;
				this._needsNewTexture = this._needsNewTexture || !this.textSnapshot || _local10 && (_local10.scale != _local3 || this._snapshotWidth != _local10.nativeWidth || this._snapshotHeight != _local10.nativeHeight);
				this._snapshotVisibleWidth = _local12;
				this._snapshotVisibleHeight = _local7;
			}
			if(_local4 || _local5 || _local2 || this._needsNewTexture || this.actualWidth != this._previousActualWidth || this.actualHeight != this._previousActualHeight) {
				this._previousActualWidth = this.actualWidth;
				this._previousActualHeight = this.actualHeight;
				_local8 = this._text.length > 0;
				if(_local8) {
					if(this._useSnapshotDelayWorkaround) {
						this.addEventListener("enterFrame",enterFrameHandler);
					} else {
						this.refreshSnapshot();
					}
				}
				if(this.textSnapshot) {
					this.textSnapshot.visible = _local8 && this._snapshotWidth > 0 && this._snapshotHeight > 0;
					this.textSnapshot.pixelSnapping = this._pixelSnapping;
				}
				if(this.textSnapshots) {
					for each(var _local13 in this.textSnapshots) {
						_local13.pixelSnapping = this._pixelSnapping;
					}
				}
			}
		}
		
		protected function autoSizeIfNeeded() : Boolean {
			var _local3:* = this._explicitWidth !== this._explicitWidth;
			var _local7:* = this._explicitHeight !== this._explicitHeight;
			var _local4:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local8:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local3 && !_local7 && !_local4 && !_local8) {
				return false;
			}
			this.measure(HELPER_POINT);
			var _local2:Number = this._explicitWidth;
			if(_local3) {
				_local2 = HELPER_POINT.x;
			}
			var _local5:Number = this._explicitHeight;
			if(_local7) {
				_local5 = HELPER_POINT.y;
			}
			var _local1:* = this._explicitMinWidth;
			if(_local4) {
				if(_local3) {
					_local1 = 0;
				} else {
					_local1 = _local2;
				}
			}
			var _local6:* = this._explicitMinHeight;
			if(_local8) {
				_local6 = _local5;
			}
			return this.saveMeasurements(_local2,_local5,_local1,_local6);
		}
		
		protected function measureNativeFilters(bitmapData:BitmapData, result:Rectangle = null) : Rectangle {
			var _local3:int = 0;
			var _local7:BitmapFilter = null;
			var _local10:Rectangle = null;
			var _local8:Number = NaN;
			var _local11:Number = NaN;
			var _local9:Number = NaN;
			var _local12:Number = NaN;
			if(!result) {
				result = new Rectangle();
			}
			var _local6:* = 0;
			var _local13:* = 0;
			var _local5:* = 0;
			var _local4:* = 0;
			var _local14:int = int(this._nativeFilters.length);
			_local3 = 0;
			while(_local3 < _local14) {
				_local7 = this._nativeFilters[_local3];
				_local10 = bitmapData.generateFilterRect(bitmapData.rect,_local7);
				_local8 = _local10.x;
				_local11 = _local10.y;
				_local9 = _local10.width;
				_local12 = _local10.height;
				if(_local6 > _local8) {
					_local6 = _local8;
				}
				if(_local13 > _local11) {
					_local13 = _local11;
				}
				if(_local5 < _local9) {
					_local5 = _local9;
				}
				if(_local4 < _local12) {
					_local4 = _local12;
				}
				_local3++;
			}
			result.setTo(_local6,_local13,_local5,_local4);
			return result;
		}
		
		protected function refreshTextFormat() : void {
			var _local2:TextFormat = null;
			var _local1:String = null;
			if(this._stateContext && this._textFormatForState) {
				_local1 = this._stateContext.currentState;
				if(_local1 in this._textFormatForState) {
					_local2 = TextFormat(this._textFormatForState[_local1]);
				}
			}
			if(!_local2 && !this._isEnabled && this._disabledTextFormat) {
				_local2 = this._disabledTextFormat;
			}
			if(!_local2 && this._selectedTextFormat && this._stateContext is IToggle && IToggle(this._stateContext).isSelected) {
				_local2 = this._selectedTextFormat;
			}
			if(!_local2) {
				if(!this._textFormat) {
					this._textFormat = new TextFormat();
				}
				_local2 = this._textFormat;
			}
			this.currentTextFormat = _local2;
		}
		
		protected function createTextureOnRestoreCallback(snapshot:Image) : void {
			var self:TextFieldTextRenderer = this;
			var texture:Texture = snapshot.texture;
			texture.root.onRestore = function():void {
				var _local2:Number = Starling.contentScaleFactor;
				HELPER_MATRIX.identity();
				HELPER_MATRIX.scale(_local2,_local2);
				var _local1:BitmapData = self.drawTextFieldRegionToBitmapData(snapshot.x,snapshot.y,texture.nativeWidth,texture.nativeHeight);
				texture.root.uploadBitmapData(_local1);
				_local1.dispose();
			};
		}
		
		protected function drawTextFieldRegionToBitmapData(textFieldX:Number, textFieldY:Number, bitmapWidth:Number, bitmapHeight:Number, bitmapData:BitmapData = null) : BitmapData {
			var _local6:Number = Starling.contentScaleFactor;
			var _local7:Number = this._snapshotVisibleWidth - textFieldX;
			var _local9:Number = this._snapshotVisibleHeight - textFieldY;
			if(!bitmapData || bitmapData.width != bitmapWidth || bitmapData.height != bitmapHeight) {
				if(bitmapData) {
					bitmapData.dispose();
				}
				bitmapData = new BitmapData(bitmapWidth,bitmapHeight,true,0xff00ff);
			} else {
				bitmapData.fillRect(bitmapData.rect,0xff00ff);
			}
			var _local8:Number = 2 * _local6;
			if(this._useGutter) {
				_local8 = 0;
			}
			HELPER_MATRIX.tx = -(textFieldX + _local8) - this._textSnapshotOffsetX;
			HELPER_MATRIX.ty = -(textFieldY + _local8) - this._textSnapshotOffsetY;
			HELPER_RECTANGLE.setTo(0,0,_local7,_local9);
			bitmapData.draw(this.textField,HELPER_MATRIX,null,null,HELPER_RECTANGLE);
			return bitmapData;
		}
		
		protected function refreshSnapshot() : void {
			var _local2:Number = NaN;
			var _local4:Number = NaN;
			var _local10:BitmapData = null;
			var _local8:* = NaN;
			var _local14:* = NaN;
			var _local7:Texture = null;
			var _local16:Image = null;
			var _local12:Texture = null;
			var _local11:int = 0;
			var _local6:* = 0;
			if(this._snapshotWidth <= 0 || this._snapshotHeight <= 0) {
				return;
			}
			var _local3:Number = Starling.contentScaleFactor;
			if(this._updateSnapshotOnScaleChange) {
				this.getTransformationMatrix(this.stage,HELPER_MATRIX);
				_local2 = matrixToScaleX(HELPER_MATRIX);
				_local4 = matrixToScaleY(HELPER_MATRIX);
			}
			HELPER_MATRIX.identity();
			HELPER_MATRIX.scale(_local3,_local3);
			if(this._updateSnapshotOnScaleChange) {
				HELPER_MATRIX.scale(_local2,_local4);
			}
			var _local9:Number = this._snapshotWidth;
			var _local13:Number = this._snapshotHeight;
			var _local1:Number = 0;
			var _local5:Number = 0;
			var _local15:int = -1;
			do {
				_local8 = _local9;
				if(_local8 > this._maxTextureDimensions) {
					_local8 = this._maxTextureDimensions;
				}
				do {
					_local14 = _local13;
					if(_local14 > this._maxTextureDimensions) {
						_local14 = this._maxTextureDimensions;
					}
					_local10 = this.drawTextFieldRegionToBitmapData(_local1,_local5,_local8,_local14,_local10);
					if(!this.textSnapshot || this._needsNewTexture) {
						_local7 = Texture.empty(_local10.width / _local3,_local10.height / _local3,true,false,false,_local3);
						_local7.root.uploadBitmapData(_local10);
					}
					_local16 = null;
					if(_local15 >= 0) {
						if(!this.textSnapshots) {
							this.textSnapshots = new Vector.<Image>(0);
						} else if(this.textSnapshots.length > _local15) {
							_local16 = this.textSnapshots[_local15];
						}
					} else {
						_local16 = this.textSnapshot;
					}
					if(!_local16) {
						_local16 = new Image(_local7);
						_local16.pixelSnapping = true;
						this.addChild(_local16);
					} else if(this._needsNewTexture) {
						_local16.texture.dispose();
						_local16.texture = _local7;
						_local16.readjustSize();
					} else {
						_local12 = _local16.texture;
						_local12.root.uploadBitmapData(_local10);
					}
					if(_local7) {
						this.createTextureOnRestoreCallback(_local16);
					}
					if(_local15 >= 0) {
						this.textSnapshots[_local15] = _local16;
					} else {
						this.textSnapshot = _local16;
					}
					_local16.x = _local1 / _local3;
					_local16.y = _local5 / _local3;
					if(this._updateSnapshotOnScaleChange) {
						_local16.scaleX = 1 / _local2;
						_local16.scaleY = 1 / _local4;
						_local16.x /= _local2;
						_local16.y /= _local4;
					}
					_local15++;
					_local5 += _local14;
				}
				while(_local13 -= _local14, _local13 > 0);
				
				_local1 += _local8;
				_local9 -= _local8;
				_local5 = 0;
				_local13 = this._snapshotHeight;
			}
			while(_local9 > 0);
			
			_local10.dispose();
			if(this.textSnapshots) {
				_local11 = int(this.textSnapshots.length);
				_local6 = _local15;
				while(_local6 < _local11) {
					_local16 = this.textSnapshots[_local6];
					_local16.texture.dispose();
					_local16.removeFromParent(true);
					_local6++;
				}
				if(_local15 == 0) {
					this.textSnapshots = null;
				} else {
					this.textSnapshots.length = _local15;
				}
			}
			if(this._updateSnapshotOnScaleChange) {
				this._lastGlobalScaleX = _local2;
				this._lastGlobalScaleY = _local4;
				this._lastContentScaleFactor = _local3;
			}
			this._needsNewTexture = false;
		}
		
		protected function enterFrameHandler(event:Event) : void {
			this.removeEventListener("enterFrame",enterFrameHandler);
			this.refreshSnapshot();
		}
		
		protected function stateContext_stateChangeHandler(event:Event) : void {
			this.invalidate("state");
		}
	}
}

