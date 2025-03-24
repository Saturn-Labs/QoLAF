package feathers.controls.text {
	import feathers.core.FeathersControl;
	import feathers.core.IStateContext;
	import feathers.core.IStateObserver;
	import feathers.core.ITextRenderer;
	import feathers.core.IToggle;
	import feathers.skins.IStyleProvider;
	import feathers.text.BitmapFontTextFormat;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.display.Image;
	import starling.display.MeshBatch;
	import starling.events.Event;
	import starling.rendering.Painter;
	import starling.text.BitmapChar;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.MathUtil;
	
	public class BitmapFontTextRenderer extends FeathersControl implements ITextRenderer, IStateObserver {
		private static var HELPER_IMAGE:Image;
		
		private static const CHARACTER_ID_SPACE:int = 32;
		
		private static const CHARACTER_ID_TAB:int = 9;
		
		private static const CHARACTER_ID_LINE_FEED:int = 10;
		
		private static const CHARACTER_ID_CARRIAGE_RETURN:int = 13;
		
		private static var CHARACTER_BUFFER:Vector.<CharLocation>;
		
		private static var CHAR_LOCATION_POOL:Vector.<CharLocation>;
		
		private static const FUZZY_MAX_WIDTH_PADDING:Number = 0.000001;
		
		public static var globalStyleProvider:IStyleProvider;
		
		private static const HELPER_POINT:Point = new Point();
		
		private static const HELPER_RESULT:MeasureTextResult = new MeasureTextResult();
		
		protected var _characterBatch:MeshBatch;
		
		protected var _batchX:Number = 0;
		
		protected var _textFormatChanged:Boolean = true;
		
		protected var currentTextFormat:BitmapFontTextFormat;
		
		protected var _textFormatForState:Object;
		
		protected var _textFormat:BitmapFontTextFormat;
		
		protected var _disabledTextFormat:BitmapFontTextFormat;
		
		protected var _selectedTextFormat:BitmapFontTextFormat;
		
		protected var _text:String = null;
		
		protected var _textureSmoothing:String = "bilinear";
		
		protected var _pixelSnapping:Boolean = true;
		
		protected var _wordWrap:Boolean = false;
		
		protected var _truncateToFit:Boolean = true;
		
		protected var _truncationText:String = "...";
		
		protected var _useSeparateBatch:Boolean = true;
		
		protected var _stateContext:IStateContext;
		
		private var _compilerWorkaround:Object;
		
		protected var _lastLayoutWidth:Number = 0;
		
		protected var _lastLayoutHeight:Number = 0;
		
		protected var _lastLayoutIsTruncated:Boolean = false;
		
		public function BitmapFontTextRenderer() {
			super();
			if(!CHAR_LOCATION_POOL) {
				CHAR_LOCATION_POOL = new Vector.<CharLocation>(0);
			}
			if(!CHARACTER_BUFFER) {
				CHARACTER_BUFFER = new Vector.<CharLocation>(0);
			}
			this.isQuickHitAreaEnabled = true;
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return BitmapFontTextRenderer.globalStyleProvider;
		}
		
		override public function set maxWidth(value:Number) : void {
			var _local2:Boolean = value > this._explicitMaxWidth && this._lastLayoutIsTruncated;
			super.maxWidth = value;
			if(_local2) {
				this.invalidate("size");
			}
		}
		
		public function get textFormat() : BitmapFontTextFormat {
			return this._textFormat;
		}
		
		public function set textFormat(value:BitmapFontTextFormat) : void {
			if(this._textFormat == value) {
				return;
			}
			this._textFormat = value;
			this.invalidate("styles");
		}
		
		public function get disabledTextFormat() : BitmapFontTextFormat {
			return this._disabledTextFormat;
		}
		
		public function set disabledTextFormat(value:BitmapFontTextFormat) : void {
			if(this._disabledTextFormat == value) {
				return;
			}
			this._disabledTextFormat = value;
			this.invalidate("styles");
		}
		
		public function get selectedTextFormat() : BitmapFontTextFormat {
			return this._selectedTextFormat;
		}
		
		public function set selectedTextFormat(value:BitmapFontTextFormat) : void {
			if(this._selectedTextFormat == value) {
				return;
			}
			this._selectedTextFormat = value;
			this.invalidate("styles");
		}
		
		public function get text() : String {
			return this._text;
		}
		
		public function set text(value:String) : void {
			if(this._text == value) {
				return;
			}
			this._text = value;
			this.invalidate("data");
		}
		
		public function get textureSmoothing() : String {
			return this._textureSmoothing;
		}
		
		public function set textureSmoothing(value:String) : void {
			if(this._textureSmoothing == value) {
				return;
			}
			this._textureSmoothing = value;
			this.invalidate("styles");
		}
		
		public function get pixelSnapping() : Boolean {
			return _pixelSnapping;
		}
		
		public function set pixelSnapping(value:Boolean) : void {
			if(this._pixelSnapping === value) {
				return;
			}
			this._pixelSnapping = value;
			this.invalidate("styles");
		}
		
		public function get wordWrap() : Boolean {
			return _wordWrap;
		}
		
		public function set wordWrap(value:Boolean) : void {
			if(this._wordWrap == value) {
				return;
			}
			this._wordWrap = value;
			this.invalidate("styles");
		}
		
		public function get truncateToFit() : Boolean {
			return _truncateToFit;
		}
		
		public function set truncateToFit(value:Boolean) : void {
			if(this._truncateToFit == value) {
				return;
			}
			this._truncateToFit = value;
			this.invalidate("data");
		}
		
		public function get truncationText() : String {
			return _truncationText;
		}
		
		public function set truncationText(value:String) : void {
			if(this._truncationText == value) {
				return;
			}
			this._truncationText = value;
			this.invalidate("data");
		}
		
		public function get useSeparateBatch() : Boolean {
			return this._useSeparateBatch;
		}
		
		public function set useSeparateBatch(value:Boolean) : void {
			if(this._useSeparateBatch == value) {
				return;
			}
			this._useSeparateBatch = value;
			this.invalidate("styles");
		}
		
		public function get baseline() : Number {
			if(!this._textFormat) {
				return 0;
			}
			var _local4:BitmapFont = this._textFormat.font;
			var _local1:Number = this._textFormat.size;
			var _local3:Number = _local1 / _local4.size;
			if(_local3 !== _local3) {
				_local3 = 1;
			}
			var _local2:Number = _local4.baseline;
			this._compilerWorkaround = _local2;
			if(_local2 !== _local2) {
				return _local4.lineHeight * _local3;
			}
			return _local2 * _local3;
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
		
		override public function dispose() : void {
			this.stateContext = null;
			super.dispose();
		}
		
		override public function render(painter:Painter) : void {
			this._characterBatch.x = this._batchX;
			super.render(painter);
		}
		
		public function measureText(result:Point = null) : Point {
			var _local15:int = 0;
			var _local14:int = 0;
			var _local16:BitmapChar = null;
			var _local22:Number = NaN;
			var _local9:Boolean = false;
			var _local24:Boolean = false;
			if(!result) {
				result = new Point();
			}
			var _local13:* = this._explicitWidth !== this._explicitWidth;
			var _local10:* = this._explicitHeight !== this._explicitHeight;
			if(!_local13 && !_local10) {
				result.x = this._explicitWidth;
				result.y = this._explicitHeight;
				return result;
			}
			if(this.isInvalid("styles") || this.isInvalid("state")) {
				this.refreshTextFormat();
			}
			if(!this.currentTextFormat || this._text === null) {
				result.setTo(0,0);
				return result;
			}
			var _local26:BitmapFont = this.currentTextFormat.font;
			var _local17:Number = this.currentTextFormat.size;
			var _local19:Number = this.currentTextFormat.letterSpacing;
			var _local3:Boolean = this.currentTextFormat.isKerningEnabled;
			var _local7:Number = _local17 / _local26.size;
			if(_local7 !== _local7) {
				_local7 = 1;
			}
			var _local23:Number = _local26.lineHeight * _local7 + this.currentTextFormat.leading;
			var _local6:Number = this._explicitWidth;
			if(_local6 !== _local6) {
				_local6 = this._explicitMaxWidth;
			}
			var _local5:* = 0;
			var _local20:Number = 0;
			var _local8:Number = 0;
			var _local21:Number = NaN;
			var _local2:int = this._text.length;
			var _local12:* = 0;
			var _local11:Number = 0;
			var _local18:int = 0;
			var _local4:String = "";
			var _local25:String = "";
			_local15 = 0;
			while(_local15 < _local2) {
				_local14 = int(this._text.charCodeAt(_local15));
				if(_local14 == 10 || _local14 == 13) {
					_local20 -= _local19;
					if(_local20 < 0) {
						_local20 = 0;
					}
					if(_local5 < _local20) {
						_local5 = _local20;
					}
					_local21 = NaN;
					_local20 = 0;
					_local8 += _local23;
					_local12 = 0;
					_local18 = 0;
					_local11 = 0;
				} else {
					_local16 = _local26.getChar(_local14);
					if(!_local16) {
						trace("Missing character " + String.fromCharCode(_local14) + " in font " + _local26.name + ".");
					} else {
						if(_local3 && _local21 === _local21) {
							_local20 += _local16.getKerning(_local21) * _local7;
						}
						_local22 = _local16.xAdvance * _local7;
						if(this._wordWrap) {
							_local9 = _local14 == 32 || _local14 == 9;
							_local24 = _local21 == 32 || _local21 == 9;
							if(_local9) {
								if(!_local24) {
									_local11 = 0;
								}
								_local11 += _local22;
							} else if(_local24) {
								_local12 = _local20;
								_local18++;
								_local4 += _local25;
								_local25 = "";
							}
							if(!_local9 && _local18 > 0 && _local20 + _local22 > _local6) {
								_local11 = _local12 - _local11;
								if(_local5 < _local11) {
									_local5 = _local11;
								}
								_local21 = NaN;
								_local20 -= _local12;
								_local8 += _local23;
								_local12 = 0;
								_local11 = 0;
								_local18 = 0;
								_local4 = "";
							}
						}
						_local20 += _local22 + _local19;
						_local21 = _local14;
						_local25 += String.fromCharCode(_local14);
					}
				}
				_local15++;
			}
			_local20 -= _local19;
			if(_local20 < 0) {
				_local20 = 0;
			}
			if(this._wordWrap) {
				while(_local20 > _local6 && !MathUtil.isEquivalent(_local20,_local6)) {
					_local20 -= _local6;
					_local8 += _local23;
				}
			}
			if(_local5 < _local20) {
				_local5 = _local20;
			}
			if(_local13) {
				result.x = _local5;
			} else {
				result.x = this._explicitWidth;
			}
			if(_local10) {
				result.y = _local8 + _local23 - this.currentTextFormat.leading;
			} else {
				result.y = this._explicitHeight;
			}
			return result;
		}
		
		public function setTextFormatForState(state:String, textFormat:BitmapFontTextFormat) : void {
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
			if(!this._characterBatch) {
				this._characterBatch = new MeshBatch();
				this._characterBatch.touchable = false;
				this.addChild(this._characterBatch);
			}
		}
		
		override protected function draw() : void {
			var _local1:* = false;
			var _local4:Boolean = this.isInvalid("data");
			var _local5:Boolean = this.isInvalid("styles");
			var _local3:Boolean = this.isInvalid("state");
			if(_local5 || _local3) {
				this.refreshTextFormat();
			}
			if(_local5) {
				this._characterBatch.pixelSnapping = this._pixelSnapping;
				this._characterBatch.batchable = !this._useSeparateBatch;
			}
			var _local2:Number = this._explicitWidth;
			if(_local2 !== _local2) {
				_local2 = this._explicitMaxWidth;
			}
			if(this._wordWrap) {
				_local1 = _local2 !== this._lastLayoutWidth;
			} else {
				_local1 = _local2 < this._lastLayoutWidth;
				if(!_local1) {
					_local1 = this._lastLayoutIsTruncated && _local2 !== this._lastLayoutWidth;
				}
			}
			if(_local4 || _local1 || this._textFormatChanged) {
				this._textFormatChanged = false;
				this._characterBatch.clear();
				if(!this.currentTextFormat || this._text === null) {
					this.saveMeasurements(0,0,0,0);
					return;
				}
				this.layoutCharacters(HELPER_RESULT);
				this._lastLayoutWidth = HELPER_RESULT.width;
				this._lastLayoutHeight = HELPER_RESULT.height;
				this._lastLayoutIsTruncated = HELPER_RESULT.isTruncated;
			}
			this.saveMeasurements(this._lastLayoutWidth,this._lastLayoutHeight,this._lastLayoutWidth,this._lastLayoutHeight);
		}
		
		protected function layoutCharacters(result:MeasureTextResult = null) : MeasureTextResult {
			var _local17:String = null;
			var _local20:int = 0;
			var _local18:int = 0;
			var _local21:BitmapChar = null;
			var _local28:Number = NaN;
			var _local13:Boolean = false;
			var _local31:Boolean = false;
			var _local29:CharLocation = null;
			var _local9:String = null;
			if(!result) {
				result = new MeasureTextResult();
			}
			var _local32:BitmapFont = this.currentTextFormat.font;
			var _local22:Number = this.currentTextFormat.size;
			var _local25:Number = this.currentTextFormat.letterSpacing;
			var _local3:Boolean = this.currentTextFormat.isKerningEnabled;
			var _local7:Number = _local22 / _local32.size;
			if(_local7 !== _local7) {
				_local7 = 1;
			}
			var _local30:Number = _local32.lineHeight * _local7 + this.currentTextFormat.leading;
			var _local10:Number = _local32.offsetX * _local7;
			var _local12:Number = _local32.offsetY * _local7;
			var _local11:* = this._explicitWidth === this._explicitWidth;
			var _local23:* = this.currentTextFormat.align != "left";
			var _local6:Number = _local11 ? this._explicitWidth : this._explicitMaxWidth;
			if(_local23 && _local6 == Infinity) {
				this.measureText(HELPER_POINT);
				_local6 = HELPER_POINT.x;
			}
			var _local14:* = this._text;
			if(this._truncateToFit) {
				_local17 = this.getTruncatedText(_local6);
				result.isTruncated = _local17 !== _local14;
				_local14 = _local17;
			} else {
				result.isTruncated = false;
			}
			CHARACTER_BUFFER.length = 0;
			var _local5:* = 0;
			var _local26:Number = 0;
			var _local8:Number = 0;
			var _local27:Number = NaN;
			var _local4:Boolean = false;
			var _local16:* = 0;
			var _local15:Number = 0;
			var _local19:int = 0;
			var _local24:int = 0;
			var _local2:int = int(!!_local14 ? _local14.length : 0);
			_local20 = 0;
			while(_local20 < _local2) {
				_local4 = false;
				_local18 = int(_local14.charCodeAt(_local20));
				if(_local18 == 10 || _local18 == 13) {
					_local26 -= _local25;
					if(_local26 < 0) {
						_local26 = 0;
					}
					if(this._wordWrap || _local23) {
						this.alignBuffer(_local6,_local26,0);
						this.addBufferToBatch(0);
					}
					if(_local5 < _local26) {
						_local5 = _local26;
					}
					_local27 = NaN;
					_local26 = 0;
					_local8 += _local30;
					_local16 = 0;
					_local15 = 0;
					_local19 = 0;
					_local24 = 0;
				} else {
					_local21 = _local32.getChar(_local18);
					if(!_local21) {
						trace("Missing character " + String.fromCharCode(_local18) + " in font " + _local32.name + ".");
					} else {
						if(_local3 && _local27 === _local27) {
							_local26 += _local21.getKerning(_local27) * _local7;
						}
						_local28 = _local21.xAdvance * _local7;
						if(this._wordWrap) {
							_local13 = _local18 == 32 || _local18 == 9;
							_local31 = _local27 == 32 || _local27 == 9;
							if(_local13) {
								if(!_local31) {
									_local15 = 0;
								}
								_local15 += _local28;
							} else if(_local31) {
								_local16 = _local26;
								_local19 = 0;
								_local24++;
								_local4 = true;
							}
							if(_local4 && !_local23) {
								this.addBufferToBatch(0);
							}
							if(!_local13 && _local24 > 0 && _local26 + _local28 - _local6 > 0.000001) {
								if(_local23) {
									this.trimBuffer(_local19);
									this.alignBuffer(_local6,_local16 - _local15,_local19);
									this.addBufferToBatch(_local19);
								}
								this.moveBufferedCharacters(-_local16,_local30,0);
								_local15 = _local16 - _local15;
								if(_local5 < _local15) {
									_local5 = _local15;
								}
								_local27 = NaN;
								_local26 -= _local16;
								_local8 += _local30;
								_local16 = 0;
								_local15 = 0;
								_local19 = 0;
								_local4 = false;
								_local24 = 0;
							}
						}
						if(this._wordWrap || _local23) {
							_local29 = CHAR_LOCATION_POOL.length > 0 ? CHAR_LOCATION_POOL.shift() : new CharLocation();
							_local29.char = _local21;
							_local29.x = _local26 + _local10 + _local21.xOffset * _local7;
							_local29.y = _local8 + _local12 + _local21.yOffset * _local7;
							_local29.scale = _local7;
							CHARACTER_BUFFER[CHARACTER_BUFFER.length] = _local29;
							_local19++;
						} else {
							this.addCharacterToBatch(_local21,_local26 + _local10 + _local21.xOffset * _local7,_local8 + _local12 + _local21.yOffset * _local7,_local7);
						}
						_local26 += _local28 + _local25;
						_local27 = _local18;
					}
				}
				_local20++;
			}
			_local26 -= _local25;
			if(_local26 < 0) {
				_local26 = 0;
			}
			if(this._wordWrap || _local23) {
				this.alignBuffer(_local6,_local26,0);
				this.addBufferToBatch(0);
			}
			if(this._wordWrap) {
				while(_local26 > _local6 && !MathUtil.isEquivalent(_local26,_local6)) {
					_local26 -= _local6;
					_local8 += _local30;
				}
			}
			if(_local5 < _local26) {
				_local5 = _local26;
			}
			if(_local23 && !_local11) {
				_local9 = this._textFormat.align;
				if(_local9 == "center") {
					this._batchX = (_local5 - _local6) / 2;
				} else if(_local9 == "right") {
					this._batchX = _local5 - _local6;
				}
			} else {
				this._batchX = 0;
			}
			this._characterBatch.x = this._batchX;
			result.width = _local5;
			result.height = _local8 + _local30 - this.currentTextFormat.leading;
			return result;
		}
		
		protected function trimBuffer(skipCount:int) : void {
			var _local5:int = 0;
			var _local6:CharLocation = null;
			var _local7:BitmapChar = null;
			var _local4:int = 0;
			var _local2:int = 0;
			var _local3:int = CHARACTER_BUFFER.length - skipCount;
			_local5 = _local3 - 1;
			while(_local5 >= 0) {
				_local6 = CHARACTER_BUFFER[_local5];
				_local7 = _local6.char;
				_local4 = _local7.charID;
				if(!(_local4 == 32 || _local4 == 9)) {
					break;
				}
				_local2++;
				_local5--;
			}
			if(_local2 > 0) {
				CHARACTER_BUFFER.splice(_local5 + 1,_local2);
			}
		}
		
		protected function alignBuffer(maxLineWidth:Number, currentLineWidth:Number, skipCount:int) : void {
			var _local4:String = this.currentTextFormat.align;
			if(_local4 == "center") {
				this.moveBufferedCharacters(Math.round((maxLineWidth - currentLineWidth) / 2),0,skipCount);
			} else if(_local4 == "right") {
				this.moveBufferedCharacters(maxLineWidth - currentLineWidth,0,skipCount);
			}
		}
		
		protected function addBufferToBatch(skipCount:int) : void {
			var _local3:int = 0;
			var _local4:CharLocation = null;
			var _local2:int = CHARACTER_BUFFER.length - skipCount;
			var _local5:int = int(CHAR_LOCATION_POOL.length);
			_local3 = 0;
			while(_local3 < _local2) {
				_local4 = CHARACTER_BUFFER.shift();
				this.addCharacterToBatch(_local4.char,_local4.x,_local4.y,_local4.scale);
				_local4.char = null;
				CHAR_LOCATION_POOL[_local5] = _local4;
				_local5++;
				_local3++;
			}
		}
		
		protected function moveBufferedCharacters(xOffset:Number, yOffset:Number, skipCount:int) : void {
			var _local5:int = 0;
			var _local6:CharLocation = null;
			var _local4:int = CHARACTER_BUFFER.length - skipCount;
			_local5 = 0;
			while(_local5 < _local4) {
				_local6 = CHARACTER_BUFFER[_local5];
				_local6.x = _local6.x + xOffset;
				_local6.y += yOffset;
				_local5++;
			}
		}
		
		protected function addCharacterToBatch(charData:BitmapChar, x:Number, y:Number, scale:Number, painter:Painter = null) : void {
			var _local6:Texture = charData.texture;
			var _local7:Rectangle = _local6.frame;
			if(_local7) {
				if(_local7.width === 0 || _local7.height === 0) {
					return;
				}
			} else if(_local6.width === 0 || _local6.height === 0) {
				return;
			}
			if(!HELPER_IMAGE) {
				HELPER_IMAGE = new Image(_local6);
			} else {
				HELPER_IMAGE.texture = _local6;
				HELPER_IMAGE.readjustSize();
			}
			HELPER_IMAGE.scaleX = HELPER_IMAGE.scaleY = scale;
			HELPER_IMAGE.x = x;
			HELPER_IMAGE.y = y;
			HELPER_IMAGE.color = this.currentTextFormat.color;
			HELPER_IMAGE.textureSmoothing = this._textureSmoothing;
			HELPER_IMAGE.pixelSnapping = this._pixelSnapping;
			if(painter !== null) {
				painter.pushState();
				painter.setStateTo(HELPER_IMAGE.transformationMatrix);
				painter.batchMesh(HELPER_IMAGE);
				painter.popState();
			} else {
				this._characterBatch.addMesh(HELPER_IMAGE);
			}
		}
		
		protected function refreshTextFormat() : void {
			var _local2:BitmapFontTextFormat = null;
			var _local1:String = null;
			if(this._stateContext && this._textFormatForState) {
				_local1 = this._stateContext.currentState;
				if(_local1 in this._textFormatForState) {
					_local2 = BitmapFontTextFormat(this._textFormatForState[_local1]);
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
					if(!TextField.getBitmapFont("mini")) {
						TextField.registerBitmapFont(new BitmapFont());
					}
					this._textFormat = new BitmapFontTextFormat("mini",NaN,0);
				}
				_local2 = this._textFormat;
			}
			if(this.currentTextFormat !== _local2) {
				this.currentTextFormat = _local2;
				this._textFormatChanged = true;
			}
		}
		
		protected function getTruncatedText(width:Number) : String {
			var _local7:* = 0;
			var _local5:int = 0;
			var _local8:BitmapChar = null;
			var _local13:Number = NaN;
			var _local14:Number = NaN;
			if(!this._text) {
				return "";
			}
			if(width == Infinity || this._wordWrap || this._text.indexOf(String.fromCharCode(10)) >= 0 || this._text.indexOf(String.fromCharCode(13)) >= 0) {
				return this._text;
			}
			var _local15:BitmapFont = this.currentTextFormat.font;
			var _local9:Number = this.currentTextFormat.size;
			var _local10:Number = this.currentTextFormat.letterSpacing;
			var _local4:Boolean = this.currentTextFormat.isKerningEnabled;
			var _local6:Number = _local9 / _local15.size;
			if(_local6 !== _local6) {
				_local6 = 1;
			}
			var _local11:Number = 0;
			var _local12:Number = NaN;
			var _local2:int = this._text.length;
			var _local3:* = -1;
			_local7 = 0;
			while(_local7 < _local2) {
				_local5 = int(this._text.charCodeAt(_local7));
				_local8 = _local15.getChar(_local5);
				if(_local8) {
					_local13 = 0;
					if(_local4 && _local12 === _local12) {
						_local13 = _local8.getKerning(_local12) * _local6;
					}
					_local11 += _local13 + _local8.xAdvance * _local6;
					if(_local11 > width) {
						_local14 = Math.abs(_local11 - width);
						if(_local14 > 0.000001) {
							_local3 = _local7;
							break;
						}
					}
					_local11 += _local10;
					_local12 = _local5;
				}
				_local7++;
			}
			if(_local3 >= 0) {
				_local2 = this._truncationText.length;
				_local7 = 0;
				while(_local7 < _local2) {
					_local5 = int(this._truncationText.charCodeAt(_local7));
					_local8 = _local15.getChar(_local5);
					if(_local8) {
						_local13 = 0;
						if(_local4 && _local12 === _local12) {
							_local13 = _local8.getKerning(_local12) * _local6;
						}
						_local11 += _local13 + _local8.xAdvance * _local6 + _local10;
						_local12 = _local5;
					}
					_local7++;
				}
				_local11 -= _local10;
				_local7 = _local3;
				while(_local7 >= 0) {
					_local5 = int(this._text.charCodeAt(_local7));
					_local12 = Number(_local7 > 0 ? this._text.charCodeAt(_local7 - 1) : NaN);
					_local8 = _local15.getChar(_local5);
					if(_local8) {
						_local13 = 0;
						if(_local4 && _local12 === _local12) {
							_local13 = _local8.getKerning(_local12) * _local6;
						}
						_local11 -= _local13 + _local8.xAdvance * _local6 + _local10;
						if(_local11 <= width) {
							return this._text.substr(0,_local7) + this._truncationText;
						}
					}
					_local7--;
				}
				return this._truncationText;
			}
			return this._text;
		}
		
		protected function stateContext_stateChangeHandler(event:Event) : void {
			this.invalidate("state");
		}
	}
}

import starling.text.BitmapChar;

class CharLocation {
	public var char:BitmapChar;
	
	public var scale:Number;
	
	public var x:Number;
	
	public var y:Number;
	
	public function CharLocation() {
		super();
	}
}
