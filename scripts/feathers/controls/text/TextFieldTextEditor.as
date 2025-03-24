package feathers.controls.text {
	import feathers.core.FeathersControl;
	import feathers.core.FocusManager;
	import feathers.core.INativeFocusOwner;
	import feathers.core.IStateContext;
	import feathers.core.IStateObserver;
	import feathers.core.ITextEditor;
	import feathers.skins.IStyleProvider;
	import feathers.utils.display.stageToStarling;
	import feathers.utils.geom.matrixToRotation;
	import feathers.utils.geom.matrixToScaleX;
	import feathers.utils.geom.matrixToScaleY;
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.SoftKeyboardEvent;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.rendering.Painter;
	import starling.textures.ConcreteTexture;
	import starling.textures.Texture;
	import starling.utils.MathUtil;
	import starling.utils.MatrixUtil;
	
	public class TextFieldTextEditor extends FeathersControl implements ITextEditor, INativeFocusOwner, IStateObserver {
		private static var HELPER_MATRIX3D:Matrix3D;
		
		private static var HELPER_POINT3D:Vector3D;
		
		public static var globalStyleProvider:IStyleProvider;
		
		private static const HELPER_MATRIX:Matrix = new Matrix();
		
		private static const HELPER_POINT:Point = new Point();
		
		protected var textField:TextField;
		
		protected var textSnapshot:Image;
		
		protected var measureTextField:TextField;
		
		protected var _snapshotWidth:int = 0;
		
		protected var _snapshotHeight:int = 0;
		
		protected var _textFieldSnapshotClipRect:Rectangle = new Rectangle();
		
		protected var _textFieldOffsetX:Number = 0;
		
		protected var _textFieldOffsetY:Number = 0;
		
		protected var _lastGlobalScaleX:Number = 0;
		
		protected var _lastGlobalScaleY:Number = 0;
		
		protected var _needsNewTexture:Boolean = false;
		
		protected var _text:String = "";
		
		protected var _previousTextFormat:TextFormat;
		
		protected var currentTextFormat:TextFormat;
		
		protected var _textFormatForState:Object;
		
		protected var _textFormat:TextFormat;
		
		protected var _disabledTextFormat:TextFormat;
		
		protected var _embedFonts:Boolean = false;
		
		protected var _wordWrap:Boolean = false;
		
		protected var _multiline:Boolean = false;
		
		protected var _isHTML:Boolean = false;
		
		protected var _alwaysShowSelection:Boolean = false;
		
		protected var _displayAsPassword:Boolean = false;
		
		protected var _maxChars:int = 0;
		
		protected var _restrict:String;
		
		protected var _isEditable:Boolean = true;
		
		protected var _isSelectable:Boolean = true;
		
		private var _antiAliasType:String = "advanced";
		
		private var _gridFitType:String = "pixel";
		
		private var _sharpness:Number = 0;
		
		private var _thickness:Number = 0;
		
		private var _background:Boolean = false;
		
		private var _backgroundColor:uint = 16777215;
		
		private var _border:Boolean = false;
		
		private var _borderColor:uint = 0;
		
		protected var _useGutter:Boolean = false;
		
		protected var _textFieldHasFocus:Boolean = false;
		
		protected var _isWaitingToSetFocus:Boolean = false;
		
		protected var _pendingSelectionBeginIndex:int = -1;
		
		protected var _pendingSelectionEndIndex:int = -1;
		
		protected var _stateContext:IStateContext;
		
		protected var _updateSnapshotOnScaleChange:Boolean = false;
		
		protected var _useSnapshotDelayWorkaround:Boolean = false;
		
		protected var resetScrollOnFocusOut:Boolean = true;
		
		public function TextFieldTextEditor() {
			super();
			this.isQuickHitAreaEnabled = true;
			this.addEventListener("addedToStage",textEditor_addedToStageHandler);
			this.addEventListener("removedFromStage",textEditor_removedFromStageHandler);
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return globalStyleProvider;
		}
		
		public function get nativeFocus() : Object {
			return this.textField;
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
			this.dispatchEventWith("change");
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
		
		public function get textFormat() : TextFormat {
			return this._textFormat;
		}
		
		public function set textFormat(value:TextFormat) : void {
			if(this._textFormat == value) {
				return;
			}
			this._textFormat = value;
			this._previousTextFormat = null;
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
		
		public function get multiline() : Boolean {
			return this._multiline;
		}
		
		public function set multiline(value:Boolean) : void {
			if(this._multiline == value) {
				return;
			}
			this._multiline = value;
			this.invalidate("styles");
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
		
		public function get alwaysShowSelection() : Boolean {
			return this._alwaysShowSelection;
		}
		
		public function set alwaysShowSelection(value:Boolean) : void {
			if(this._alwaysShowSelection == value) {
				return;
			}
			this._alwaysShowSelection = value;
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
		
		public function get maxChars() : int {
			return this._maxChars;
		}
		
		public function set maxChars(value:int) : void {
			if(this._maxChars == value) {
				return;
			}
			this._maxChars = value;
			this.invalidate("styles");
		}
		
		public function get restrict() : String {
			return this._restrict;
		}
		
		public function set restrict(value:String) : void {
			if(this._restrict == value) {
				return;
			}
			this._restrict = value;
			this.invalidate("styles");
		}
		
		public function get isEditable() : Boolean {
			return this._isEditable;
		}
		
		public function set isEditable(value:Boolean) : void {
			if(this._isEditable == value) {
				return;
			}
			this._isEditable = value;
			this.invalidate("styles");
		}
		
		public function get isSelectable() : Boolean {
			return this._isSelectable;
		}
		
		public function set isSelectable(value:Boolean) : void {
			if(this._isSelectable == value) {
				return;
			}
			this._isSelectable = value;
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
		
		public function get setTouchFocusOnEndedPhase() : Boolean {
			return false;
		}
		
		public function get selectionBeginIndex() : int {
			if(this._pendingSelectionBeginIndex >= 0) {
				return this._pendingSelectionBeginIndex;
			}
			if(this.textField) {
				return this.textField.selectionBeginIndex;
			}
			return 0;
		}
		
		public function get selectionEndIndex() : int {
			if(this._pendingSelectionEndIndex >= 0) {
				return this._pendingSelectionEndIndex;
			}
			if(this.textField) {
				return this.textField.selectionEndIndex;
			}
			return 0;
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
			if(this.textSnapshot) {
				this.textSnapshot.texture.dispose();
				this.removeChild(this.textSnapshot,true);
				this.textSnapshot = null;
			}
			if(this.textField) {
				if(this.textField.parent) {
					this.textField.parent.removeChild(this.textField);
				}
				this.textField.removeEventListener("change",textField_changeHandler);
				this.textField.removeEventListener("focusIn",textField_focusInHandler);
				this.textField.removeEventListener("focusOut",textField_focusOutHandler);
				this.textField.removeEventListener("keyDown",textField_keyDownHandler);
				this.textField.removeEventListener("softKeyboardActivate",textField_softKeyboardActivateHandler);
				this.textField.removeEventListener("softKeyboardDeactivate",textField_softKeyboardDeactivateHandler);
			}
			this.textField = null;
			this.measureTextField = null;
			this.stateContext = null;
			super.dispose();
		}
		
		override public function render(painter:Painter) : void {
			if(this.textSnapshot) {
				if(this._updateSnapshotOnScaleChange) {
					this.getTransformationMatrix(this.stage,HELPER_MATRIX);
					if(matrixToScaleX(HELPER_MATRIX) != this._lastGlobalScaleX || matrixToScaleY(HELPER_MATRIX) != this._lastGlobalScaleY) {
						this.invalidate("size");
						this.validate();
					}
				}
				this.positionSnapshot();
			}
			if(this.textField && this.textField.visible) {
				this.transformTextField();
			}
			super.render(painter);
		}
		
		public function setFocus(position:Point = null) : void {
			var _local6:Number = NaN;
			var _local4:Number = NaN;
			var _local8:Number = NaN;
			var _local10:Number = NaN;
			var _local12:Number = NaN;
			var _local7:* = NaN;
			var _local9:* = NaN;
			var _local2:Number = NaN;
			var _local3:Number = NaN;
			var _local5:int = 0;
			var _local13:Rectangle = null;
			var _local11:Number = NaN;
			if(this.textField) {
				if(!this.textField.parent) {
					Starling.current.nativeStage.addChild(this.textField);
				}
				if(position !== null) {
					_local6 = 1;
					if(Starling.current.supportHighResolutions) {
						_local6 = Starling.current.nativeStage.contentsScaleFactor;
					}
					_local4 = Starling.contentScaleFactor / _local6;
					_local8 = this.textField.scaleX;
					_local10 = this.textField.scaleY;
					_local12 = 2;
					if(this._useGutter) {
						_local12 = 0;
					}
					_local7 = position.x + _local12;
					_local9 = position.y + _local12;
					if(_local7 < _local12) {
						_local7 = _local12;
					} else {
						_local2 = this.textField.width / _local8 - _local12;
						if(_local7 > _local2) {
							_local7 = _local2;
						}
					}
					if(_local9 < _local12) {
						_local9 = _local12;
					} else {
						_local3 = this.textField.height / _local10 - _local12;
						if(_local9 > _local3) {
							_local9 = _local3;
						}
					}
					this._pendingSelectionBeginIndex = this.getSelectionIndexAtPoint(_local7,_local9);
					if(this._pendingSelectionBeginIndex < 0) {
						if(this._multiline) {
							_local5 = this.textField.getLineIndexAtPoint(this.textField.width / 2 / _local8,_local9);
							try {
								this._pendingSelectionBeginIndex = this.textField.getLineOffset(_local5) + this.textField.getLineLength(_local5);
								if(this._pendingSelectionBeginIndex != this._text.length) {
									this._pendingSelectionBeginIndex--;
								}
							}
							catch(error:Error) {
								this._pendingSelectionBeginIndex = this._text.length;
							}
						} else {
							this._pendingSelectionBeginIndex = this.getSelectionIndexAtPoint(_local7,this.textField.getLineMetrics(0).ascent / 2);
							if(this._pendingSelectionBeginIndex < 0) {
								this._pendingSelectionBeginIndex = this._text.length;
							}
						}
					} else {
						_local13 = this.textField.getCharBoundaries(this._pendingSelectionBeginIndex);
						if(_local13) {
							_local11 = _local13.x;
							if(_local13 && _local11 + _local13.width - _local7 < _local7 - _local11) {
								this._pendingSelectionBeginIndex++;
							}
						}
					}
					this._pendingSelectionEndIndex = this._pendingSelectionBeginIndex;
				} else {
					this._pendingSelectionBeginIndex = this._pendingSelectionEndIndex = -1;
				}
				if(!FocusManager.isEnabledForStage(this.stage)) {
					Starling.current.nativeStage.focus = this.textField;
				}
				this.textField.requestSoftKeyboard();
				if(this._textFieldHasFocus) {
					this.invalidate("selected");
				}
			} else {
				this._isWaitingToSetFocus = true;
			}
		}
		
		public function clearFocus() : void {
			if(!this._textFieldHasFocus) {
				return;
			}
			var _local1:Stage = Starling.current.nativeStage;
			if(_local1.focus === this.textField) {
				_local1.focus = null;
			}
		}
		
		public function selectRange(beginIndex:int, endIndex:int) : void {
			if(!this._isEditable && !this._isSelectable) {
				return;
			}
			if(this.textField) {
				if(!this._isValidating) {
					this.validate();
				}
				this.textField.setSelection(beginIndex,endIndex);
			} else {
				this._pendingSelectionBeginIndex = beginIndex;
				this._pendingSelectionEndIndex = endIndex;
			}
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
			this.textField = new TextField();
			this.textField.tabEnabled = false;
			this.textField.visible = false;
			this.textField.needsSoftKeyboard = true;
			this.textField.addEventListener("change",textField_changeHandler);
			this.textField.addEventListener("focusIn",textField_focusInHandler);
			this.textField.addEventListener("focusOut",textField_focusOutHandler);
			this.textField.addEventListener("keyDown",textField_keyDownHandler);
			this.textField.addEventListener("softKeyboardActivate",textField_softKeyboardActivateHandler);
			this.textField.addEventListener("softKeyboardDeactivate",textField_softKeyboardDeactivateHandler);
			this.measureTextField = new TextField();
			this.measureTextField.autoSize = "left";
			this.measureTextField.selectable = false;
			this.measureTextField.tabEnabled = false;
			this.measureTextField.mouseWheelEnabled = false;
			this.measureTextField.mouseEnabled = false;
		}
		
		override protected function draw() : void {
			var _local1:Boolean = this.isInvalid("size");
			this.commit();
			_local1 = this.autoSizeIfNeeded() || _local1;
			this.layout(_local1);
		}
		
		protected function commit() : void {
			var _local2:Boolean = this.isInvalid("styles");
			var _local3:Boolean = this.isInvalid("data");
			var _local1:Boolean = this.isInvalid("state");
			if(_local3 || _local2 || _local1) {
				this.refreshTextFormat();
				this.commitStylesAndData(this.textField);
			}
		}
		
		protected function autoSizeIfNeeded() : Boolean {
			var _local1:* = this._explicitWidth !== this._explicitWidth;
			var _local3:* = this._explicitHeight !== this._explicitHeight;
			var _local2:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local4:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local1 && !_local3 && !_local2 && !_local4) {
				return false;
			}
			this.measure(HELPER_POINT);
			return this.saveMeasurements(HELPER_POINT.x,HELPER_POINT.y,HELPER_POINT.x,HELPER_POINT.y);
		}
		
		protected function measure(result:Point = null) : Point {
			if(!result) {
				result = new Point();
			}
			var _local3:* = this._explicitWidth !== this._explicitWidth;
			var _local5:* = this._explicitHeight !== this._explicitHeight;
			if(!_local3 && !_local5) {
				result.x = this._explicitWidth;
				result.y = this._explicitHeight;
				return result;
			}
			this.commitStylesAndData(this.measureTextField);
			var _local6:Number = 4;
			if(this._useGutter) {
				_local6 = 0;
			}
			var _local2:Number = this._explicitWidth;
			if(_local3) {
				this.measureTextField.wordWrap = false;
				_local2 = this.measureTextField.width - _local6;
				if(_local2 < this._explicitMinWidth) {
					_local2 = this._explicitMinWidth;
				} else if(_local2 > this._explicitMaxWidth) {
					_local2 = this._explicitMaxWidth;
				}
			}
			var _local4:Number = this._explicitHeight;
			if(_local5) {
				this.measureTextField.wordWrap = this._wordWrap;
				this.measureTextField.width = _local2 + _local6;
				_local4 = this.measureTextField.height - _local6;
				if(this._useGutter) {
					_local4 += 4;
				}
				if(_local4 < this._explicitMinHeight) {
					_local4 = this._explicitMinHeight;
				} else if(_local4 > this._explicitMaxHeight) {
					_local4 = this._explicitMaxHeight;
				}
			}
			result.x = _local2;
			result.y = _local4;
			return result;
		}
		
		protected function commitStylesAndData(textField:TextField) : void {
			var _local2:* = false;
			textField.antiAliasType = this._antiAliasType;
			textField.background = this._background;
			textField.backgroundColor = this._backgroundColor;
			textField.border = this._border;
			textField.borderColor = this._borderColor;
			textField.gridFitType = this._gridFitType;
			textField.sharpness = this._sharpness;
			textField.thickness = this._thickness;
			textField.maxChars = this._maxChars;
			textField.restrict = this._restrict;
			textField.alwaysShowSelection = this._alwaysShowSelection;
			textField.displayAsPassword = this._displayAsPassword;
			textField.wordWrap = this._wordWrap;
			textField.multiline = this._multiline;
			textField.embedFonts = this._embedFonts;
			textField.type = this._isEditable ? "input" : "dynamic";
			textField.selectable = this._isEnabled && (this._isEditable || this._isSelectable);
			if(textField === this.textField) {
				_local2 = this._previousTextFormat != this.currentTextFormat;
				this._previousTextFormat = this.currentTextFormat;
			}
			textField.defaultTextFormat = this.currentTextFormat;
			if(this._isHTML) {
				if(_local2 || textField.htmlText != this._text) {
					if(textField == this.textField && this._pendingSelectionBeginIndex < 0) {
						this._pendingSelectionBeginIndex = this.textField.selectionBeginIndex;
						this._pendingSelectionEndIndex = this.textField.selectionEndIndex;
					}
					textField.htmlText = this._text;
				}
			} else if(_local2 || textField.text != this._text) {
				if(textField == this.textField && this._pendingSelectionBeginIndex < 0) {
					this._pendingSelectionBeginIndex = this.textField.selectionBeginIndex;
					this._pendingSelectionEndIndex = this.textField.selectionEndIndex;
				}
				textField.text = this._text;
			}
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
			if(!_local2) {
				if(!this._textFormat) {
					this._textFormat = new TextFormat();
				}
				_local2 = this._textFormat;
			}
			this.currentTextFormat = _local2;
		}
		
		protected function layout(sizeInvalid:Boolean) : void {
			var _local3:Boolean = this.isInvalid("styles");
			var _local4:Boolean = this.isInvalid("data");
			var _local2:Boolean = this.isInvalid("state");
			if(sizeInvalid) {
				this.refreshSnapshotParameters();
				this.refreshTextFieldSize();
				this.transformTextField();
				this.positionSnapshot();
			}
			this.checkIfNewSnapshotIsNeeded();
			if(!this._textFieldHasFocus && (sizeInvalid || _local3 || _local4 || _local2 || this._needsNewTexture)) {
				if(this._useSnapshotDelayWorkaround) {
					this.addEventListener("enterFrame",refreshSnapshot_enterFrameHandler);
				} else {
					this.refreshSnapshot();
				}
			}
			this.doPendingActions();
		}
		
		protected function getSelectionIndexAtPoint(pointX:Number, pointY:Number) : int {
			return this.textField.getCharIndexAtPoint(pointX,pointY);
		}
		
		protected function refreshTextFieldSize() : void {
			var _local1:Number = 4;
			if(this._useGutter) {
				_local1 = 0;
			}
			this.textField.width = this.actualWidth + _local1;
			this.textField.height = this.actualHeight + _local1;
		}
		
		protected function refreshSnapshotParameters() : void {
			this._textFieldOffsetX = 0;
			this._textFieldOffsetY = 0;
			this._textFieldSnapshotClipRect.x = 0;
			this._textFieldSnapshotClipRect.y = 0;
			var _local1:Number = Starling.contentScaleFactor;
			var _local2:Number = this.actualWidth * _local1;
			if(this._updateSnapshotOnScaleChange) {
				this.getTransformationMatrix(this.stage,HELPER_MATRIX);
				_local2 *= matrixToScaleX(HELPER_MATRIX);
			}
			if(_local2 < 0) {
				_local2 = 0;
			}
			var _local3:Number = this.actualHeight * _local1;
			if(this._updateSnapshotOnScaleChange) {
				_local3 *= matrixToScaleY(HELPER_MATRIX);
			}
			if(_local3 < 0) {
				_local3 = 0;
			}
			this._textFieldSnapshotClipRect.width = _local2;
			this._textFieldSnapshotClipRect.height = _local3;
		}
		
		protected function transformTextField() : void {
			HELPER_POINT.x = HELPER_POINT.y = 0;
			this.getTransformationMatrix(this.stage,HELPER_MATRIX);
			var _local3:Number = matrixToScaleX(HELPER_MATRIX);
			var _local5:Number = matrixToScaleY(HELPER_MATRIX);
			var _local2:* = _local3;
			if(_local5 < _local2) {
				_local2 = _local5;
			}
			var _local1:Starling = stageToStarling(this.stage);
			if(_local1 === null) {
				_local1 = Starling.current;
			}
			var _local8:Number = 1;
			if(_local1.supportHighResolutions) {
				_local8 = _local1.nativeStage.contentsScaleFactor;
			}
			var _local6:Number = _local1.contentScaleFactor / _local8;
			var _local7:Number = 0;
			if(!this._useGutter) {
				_local7 = 2 * _local2;
			}
			if(this.is3D) {
				HELPER_MATRIX3D = this.getTransformationMatrix3D(this.stage,HELPER_MATRIX3D);
				HELPER_POINT3D = MatrixUtil.transformCoords3D(HELPER_MATRIX3D,-_local7,-_local7,0,HELPER_POINT3D);
				HELPER_POINT.setTo(HELPER_POINT3D.x,HELPER_POINT3D.y);
			} else {
				MatrixUtil.transformCoords(HELPER_MATRIX,-_local7,-_local7,HELPER_POINT);
			}
			var _local4:Rectangle = _local1.viewPort;
			this.textField.x = Math.round(_local4.x + HELPER_POINT.x * _local6);
			this.textField.y = Math.round(_local4.y + HELPER_POINT.y * _local6);
			this.textField.rotation = matrixToRotation(HELPER_MATRIX) * (3 * 60) / 3.141592653589793;
			this.textField.scaleX = matrixToScaleX(HELPER_MATRIX) * _local6;
			this.textField.scaleY = matrixToScaleY(HELPER_MATRIX) * _local6;
		}
		
		protected function positionSnapshot() : void {
			if(!this.textSnapshot) {
				return;
			}
			this.getTransformationMatrix(this.stage,HELPER_MATRIX);
			this.textSnapshot.x = Math.round(HELPER_MATRIX.tx) - HELPER_MATRIX.tx;
			this.textSnapshot.y = Math.round(HELPER_MATRIX.ty) - HELPER_MATRIX.ty;
		}
		
		protected function checkIfNewSnapshotIsNeeded() : void {
			var _local1:* = Starling.current.profile != "baselineConstrained";
			if(_local1) {
				this._snapshotWidth = this._textFieldSnapshotClipRect.width;
				this._snapshotHeight = this._textFieldSnapshotClipRect.height;
			} else {
				this._snapshotWidth = MathUtil.getNextPowerOfTwo(this._textFieldSnapshotClipRect.width);
				this._snapshotHeight = MathUtil.getNextPowerOfTwo(this._textFieldSnapshotClipRect.height);
			}
			var _local2:ConcreteTexture = !!this.textSnapshot ? this.textSnapshot.texture.root : null;
			this._needsNewTexture = this._needsNewTexture || !this.textSnapshot || _local2.scale != Starling.contentScaleFactor || this._snapshotWidth != _local2.width || this._snapshotHeight != _local2.height;
		}
		
		protected function doPendingActions() : void {
			var _local1:int = 0;
			var _local2:int = 0;
			if(this._isWaitingToSetFocus) {
				this._isWaitingToSetFocus = false;
				this.setFocus();
			}
			if(this._pendingSelectionBeginIndex >= 0) {
				_local1 = this._pendingSelectionBeginIndex;
				_local2 = this._pendingSelectionEndIndex;
				this._pendingSelectionBeginIndex = -1;
				this._pendingSelectionEndIndex = -1;
				this.selectRange(_local1,_local2);
			}
		}
		
		protected function texture_onRestore() : void {
			if(this.textSnapshot && this.textSnapshot.texture && this.textSnapshot.texture.scale != Starling.contentScaleFactor) {
				this.invalidate("size");
			} else {
				this.refreshSnapshot();
			}
		}
		
		protected function refreshSnapshot() : void {
			var _local1:Number = NaN;
			var _local4:Number = NaN;
			var _local7:Texture = null;
			var _local6:Texture = null;
			if(this._snapshotWidth <= 0 || this._snapshotHeight <= 0) {
				return;
			}
			var _local5:Number = 2;
			if(this._useGutter) {
				_local5 = 0;
			}
			var _local3:Number = Starling.contentScaleFactor;
			if(this._updateSnapshotOnScaleChange) {
				this.getTransformationMatrix(this.stage,HELPER_MATRIX);
				_local1 = matrixToScaleX(HELPER_MATRIX);
				_local4 = matrixToScaleY(HELPER_MATRIX);
			}
			HELPER_MATRIX.identity();
			HELPER_MATRIX.translate(this._textFieldOffsetX - _local5,this._textFieldOffsetY - _local5);
			HELPER_MATRIX.scale(_local3,_local3);
			if(this._updateSnapshotOnScaleChange) {
				HELPER_MATRIX.scale(_local1,_local4);
			}
			var _local2:BitmapData = new BitmapData(this._snapshotWidth,this._snapshotHeight,true,0xff00ff);
			_local2.draw(this.textField,HELPER_MATRIX,null,null,this._textFieldSnapshotClipRect);
			if(!this.textSnapshot || this._needsNewTexture) {
				_local7 = Texture.empty(_local2.width / _local3,_local2.height / _local3,true,false,false,_local3);
				_local7.root.uploadBitmapData(_local2);
				_local7.root.onRestore = texture_onRestore;
			}
			if(!this.textSnapshot) {
				this.textSnapshot = new Image(_local7);
				this.textSnapshot.pixelSnapping = true;
				this.addChild(this.textSnapshot);
			} else if(this._needsNewTexture) {
				this.textSnapshot.texture.dispose();
				this.textSnapshot.texture = _local7;
				this.textSnapshot.readjustSize();
			} else {
				_local6 = this.textSnapshot.texture;
				_local6.root.uploadBitmapData(_local2);
			}
			if(this._updateSnapshotOnScaleChange) {
				this.textSnapshot.scaleX = 1 / _local1;
				this.textSnapshot.scaleY = 1 / _local4;
				this._lastGlobalScaleX = _local1;
				this._lastGlobalScaleY = _local4;
			}
			this.textSnapshot.alpha = this._text.length > 0 ? 1 : 0;
			_local2.dispose();
			this._needsNewTexture = false;
		}
		
		protected function textEditor_addedToStageHandler(event:starling.events.Event) : void {
			if(!this.textField.parent) {
				Starling.current.nativeStage.addChild(this.textField);
			}
		}
		
		protected function textEditor_removedFromStageHandler(event:starling.events.Event) : void {
			if(this.textField.parent) {
				this.textField.parent.removeChild(this.textField);
			}
		}
		
		protected function hasFocus_enterFrameHandler(event:starling.events.Event) : void {
			var _local2:DisplayObject = null;
			if(this.textSnapshot) {
				this.textSnapshot.visible = !this._textFieldHasFocus;
			}
			this.textField.visible = this._textFieldHasFocus;
			if(this._textFieldHasFocus) {
				_local2 = this;
				do {
					if(!_local2.visible) {
						this.clearFocus();
						break;
					}
					_local2 = _local2.parent;
				}
				while(_local2);
				
			} else {
				this.removeEventListener("enterFrame",hasFocus_enterFrameHandler);
			}
		}
		
		protected function refreshSnapshot_enterFrameHandler(event:starling.events.Event) : void {
			this.removeEventListener("enterFrame",refreshSnapshot_enterFrameHandler);
			this.refreshSnapshot();
		}
		
		protected function stage_touchHandler(event:TouchEvent) : void {
			var _local3:Touch = event.getTouch(this.stage,"began");
			if(!_local3) {
				return;
			}
			_local3.getLocation(this.stage,HELPER_POINT);
			var _local2:Boolean = this.contains(this.stage.hitTest(HELPER_POINT));
			if(_local2) {
				return;
			}
			this.clearFocus();
		}
		
		protected function textField_changeHandler(event:flash.events.Event) : void {
			if(this._isHTML) {
				this.text = this.textField.htmlText;
			} else {
				this.text = this.textField.text;
			}
		}
		
		protected function textField_focusInHandler(event:FocusEvent) : void {
			this._textFieldHasFocus = true;
			this.stage.addEventListener("touch",stage_touchHandler);
			this.addEventListener("enterFrame",hasFocus_enterFrameHandler);
			this.dispatchEventWith("focusIn");
		}
		
		protected function textField_focusOutHandler(event:FocusEvent) : void {
			this._textFieldHasFocus = false;
			this.stage.removeEventListener("touch",stage_touchHandler);
			if(this.resetScrollOnFocusOut) {
				this.textField.scrollH = this.textField.scrollV = 0;
			}
			this.invalidate("data");
			this.dispatchEventWith("focusOut");
		}
		
		protected function textField_keyDownHandler(event:KeyboardEvent) : void {
			if(event.keyCode == 13) {
				this.dispatchEventWith("enter");
			} else if(!FocusManager.isEnabledForStage(this.stage) && event.keyCode == 9) {
				this.clearFocus();
			}
		}
		
		protected function textField_softKeyboardActivateHandler(event:SoftKeyboardEvent) : void {
			this.dispatchEventWith("softKeyboardActivate",true);
		}
		
		protected function textField_softKeyboardDeactivateHandler(event:SoftKeyboardEvent) : void {
			this.dispatchEventWith("softKeyboardDeactivate",true);
		}
		
		protected function stateContext_stateChangeHandler(event:starling.events.Event) : void {
			this.invalidate("state");
		}
	}
}

