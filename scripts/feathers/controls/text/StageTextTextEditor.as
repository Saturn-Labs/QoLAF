package feathers.controls.text {
	import feathers.core.FeathersControl;
	import feathers.core.FocusManager;
	import feathers.core.IMultilineTextEditor;
	import feathers.core.INativeFocusOwner;
	import feathers.skins.IStyleProvider;
	import feathers.text.StageTextField;
	import feathers.utils.display.stageToStarling;
	import feathers.utils.geom.matrixToScaleX;
	import feathers.utils.geom.matrixToScaleY;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.SoftKeyboardEvent;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getDefinitionByName;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.events.Event;
	import starling.rendering.Painter;
	import starling.textures.ConcreteTexture;
	import starling.textures.Texture;
	import starling.utils.MatrixUtil;
	import starling.utils.SystemUtil;
	
	public class StageTextTextEditor extends FeathersControl implements IMultilineTextEditor, INativeFocusOwner {
		private static var HELPER_MATRIX3D:Matrix3D;
		
		private static var HELPER_POINT3D:Vector3D;
		
		public static var globalStyleProvider:IStyleProvider;
		
		private static const HELPER_MATRIX:Matrix = new Matrix();
		
		private static const HELPER_POINT:Point = new Point();
		
		protected var stageText:Object;
		
		protected var textSnapshot:Image;
		
		protected var _needsNewTexture:Boolean = false;
		
		protected var _ignoreStageTextChanges:Boolean = false;
		
		protected var _text:String = "";
		
		protected var _measureTextField:TextField;
		
		protected var _stageTextIsTextField:Boolean = false;
		
		protected var _stageTextHasFocus:Boolean = false;
		
		protected var _isWaitingToSetFocus:Boolean = false;
		
		protected var _pendingSelectionBeginIndex:int = -1;
		
		protected var _pendingSelectionEndIndex:int = -1;
		
		protected var _stageTextIsComplete:Boolean = false;
		
		protected var _autoCapitalize:String = "none";
		
		protected var _autoCorrect:Boolean = false;
		
		protected var _color:uint = 0;
		
		protected var _disabledColor:uint = 10066329;
		
		protected var _displayAsPassword:Boolean = false;
		
		protected var _isEditable:Boolean = true;
		
		protected var _isSelectable:Boolean = true;
		
		protected var _fontFamily:String = null;
		
		protected var _fontPosture:String = "normal";
		
		protected var _fontSize:int = 12;
		
		protected var _fontWeight:String = "normal";
		
		protected var _locale:String = "en";
		
		protected var _maxChars:int = 0;
		
		protected var _multiline:Boolean = false;
		
		protected var _restrict:String;
		
		protected var _returnKeyLabel:String = "default";
		
		protected var _softKeyboardType:String = "default";
		
		protected var _textAlign:String = "start";
		
		protected var _lastGlobalScaleX:Number = 0;
		
		protected var _lastGlobalScaleY:Number = 0;
		
		protected var _updateSnapshotOnScaleChange:Boolean = false;
		
		public function StageTextTextEditor() {
			super();
			this._stageTextIsTextField = /^(Windows|Mac OS|Linux) .*/.exec(Capabilities.os) || Capabilities.playerType === "Desktop" && Capabilities.isDebugger;
			this.isQuickHitAreaEnabled = true;
			this.addEventListener("removedFromStage",textEditor_removedFromStageHandler);
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return globalStyleProvider;
		}
		
		public function get nativeFocus() : Object {
			if(!this._isEditable) {
				return null;
			}
			return this.stageText;
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
		
		public function get selectionBeginIndex() : int {
			if(this._pendingSelectionBeginIndex >= 0) {
				return this._pendingSelectionBeginIndex;
			}
			if(this.stageText) {
				return this.stageText.selectionAnchorIndex;
			}
			return 0;
		}
		
		public function get selectionEndIndex() : int {
			if(this._pendingSelectionEndIndex >= 0) {
				return this._pendingSelectionEndIndex;
			}
			if(this.stageText) {
				return this.stageText.selectionActiveIndex;
			}
			return 0;
		}
		
		public function get baseline() : Number {
			if(!this._measureTextField) {
				return 0;
			}
			return this._measureTextField.getLineMetrics(0).ascent;
		}
		
		public function get autoCapitalize() : String {
			return this._autoCapitalize;
		}
		
		public function set autoCapitalize(value:String) : void {
			if(this._autoCapitalize == value) {
				return;
			}
			this._autoCapitalize = value;
			this.invalidate("styles");
		}
		
		public function get autoCorrect() : Boolean {
			return this._autoCorrect;
		}
		
		public function set autoCorrect(value:Boolean) : void {
			if(this._autoCorrect == value) {
				return;
			}
			this._autoCorrect = value;
			this.invalidate("styles");
		}
		
		public function get color() : uint {
			return this._color;
		}
		
		public function set color(value:uint) : void {
			if(this._color == value) {
				return;
			}
			this._color = value;
			this.invalidate("styles");
		}
		
		public function get disabledColor() : uint {
			return this._disabledColor;
		}
		
		public function set disabledColor(value:uint) : void {
			if(this._disabledColor == value) {
				return;
			}
			this._disabledColor = value;
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
		
		public function get setTouchFocusOnEndedPhase() : Boolean {
			return true;
		}
		
		public function get fontFamily() : String {
			return this._fontFamily;
		}
		
		public function set fontFamily(value:String) : void {
			if(this._fontFamily == value) {
				return;
			}
			this._fontFamily = value;
			this.invalidate("styles");
		}
		
		public function get fontPosture() : String {
			return this._fontPosture;
		}
		
		public function set fontPosture(value:String) : void {
			if(this._fontPosture == value) {
				return;
			}
			this._fontPosture = value;
			this.invalidate("styles");
		}
		
		public function get fontSize() : int {
			return this._fontSize;
		}
		
		public function set fontSize(value:int) : void {
			if(this._fontSize == value) {
				return;
			}
			this._fontSize = value;
			this.invalidate("styles");
		}
		
		public function get fontWeight() : String {
			return this._fontWeight;
		}
		
		public function set fontWeight(value:String) : void {
			if(this._fontWeight == value) {
				return;
			}
			this._fontWeight = value;
			this.invalidate("styles");
		}
		
		public function get locale() : String {
			return this._locale;
		}
		
		public function set locale(value:String) : void {
			if(this._locale == value) {
				return;
			}
			this._locale = value;
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
		
		public function get returnKeyLabel() : String {
			return this._returnKeyLabel;
		}
		
		public function set returnKeyLabel(value:String) : void {
			if(this._returnKeyLabel == value) {
				return;
			}
			this._returnKeyLabel = value;
			this.invalidate("styles");
		}
		
		public function get softKeyboardType() : String {
			return this._softKeyboardType;
		}
		
		public function set softKeyboardType(value:String) : void {
			if(this._softKeyboardType == value) {
				return;
			}
			this._softKeyboardType = value;
			this.invalidate("styles");
		}
		
		public function get textAlign() : String {
			return this._textAlign;
		}
		
		public function set textAlign(value:String) : void {
			if(this._textAlign == value) {
				return;
			}
			this._textAlign = value;
			this.invalidate("styles");
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
		
		override public function dispose() : void {
			if(this._measureTextField) {
				Starling.current.nativeStage.removeChild(this._measureTextField);
				this._measureTextField = null;
			}
			if(this.stageText) {
				this.disposeStageText();
			}
			if(this.textSnapshot) {
				this.textSnapshot.texture.dispose();
				this.removeChild(this.textSnapshot,true);
				this.textSnapshot = null;
			}
			super.dispose();
		}
		
		override public function render(painter:Painter) : void {
			if(this._stageTextHasFocus) {
				painter.excludeFromCache(this);
			}
			if(this.textSnapshot && this._updateSnapshotOnScaleChange) {
				this.getTransformationMatrix(this.stage,HELPER_MATRIX);
				if(matrixToScaleX(HELPER_MATRIX) != this._lastGlobalScaleX || matrixToScaleY(HELPER_MATRIX) != this._lastGlobalScaleY) {
					this.invalidate("size");
					this.validate();
				}
			}
			if(this.stageText && this.stageText.visible) {
				this.refreshViewPortAndFontSize();
			}
			if(this.textSnapshot) {
				this.positionSnapshot();
			}
			super.render(painter);
		}
		
		public function setFocus(position:Point = null) : void {
			var _local6:Number = NaN;
			var _local2:Number = NaN;
			var _local4:int = 0;
			var _local5:Rectangle = null;
			var _local3:Number = NaN;
			if(!this._isEditable && SystemUtil.platform === "AND") {
				return;
			}
			if(!this._isEditable && !this._isSelectable) {
				return;
			}
			if(this.stage && !this.stageText.stage) {
				this.stageText.stage = Starling.current.nativeStage;
			}
			if(this.stageText && this._stageTextIsComplete) {
				if(position) {
					_local6 = position.x + 2;
					_local2 = position.y + 2;
					if(_local6 < 0) {
						this._pendingSelectionBeginIndex = this._pendingSelectionEndIndex = 0;
					} else {
						this._pendingSelectionBeginIndex = this._measureTextField.getCharIndexAtPoint(_local6,_local2);
						if(this._pendingSelectionBeginIndex < 0) {
							if(this._multiline) {
								_local4 = _local2 / this._measureTextField.getLineMetrics(0).height;
								try {
									this._pendingSelectionBeginIndex = this._measureTextField.getLineOffset(_local4) + this._measureTextField.getLineLength(_local4);
									if(this._pendingSelectionBeginIndex != this._text.length) {
										this._pendingSelectionBeginIndex--;
									}
								}
								catch(error:Error) {
									this._pendingSelectionBeginIndex = this._text.length;
								}
							} else {
								this._pendingSelectionBeginIndex = this._measureTextField.getCharIndexAtPoint(_local6,this._measureTextField.getLineMetrics(0).ascent / 2);
								if(this._pendingSelectionBeginIndex < 0) {
									this._pendingSelectionBeginIndex = this._text.length;
								}
							}
						} else {
							_local5 = this._measureTextField.getCharBoundaries(this._pendingSelectionBeginIndex);
							_local3 = _local5.x;
							if(_local5 && _local3 + _local5.width - _local6 < _local6 - _local3) {
								this._pendingSelectionBeginIndex++;
							}
						}
						this._pendingSelectionEndIndex = this._pendingSelectionBeginIndex;
					}
				} else {
					this._pendingSelectionBeginIndex = this._pendingSelectionEndIndex = -1;
				}
				this.stageText.visible = true;
				if(this._isEditable) {
					this.stageText.assignFocus();
				}
			} else {
				this._isWaitingToSetFocus = true;
			}
		}
		
		public function clearFocus() : void {
			if(!this._stageTextHasFocus) {
				return;
			}
			Starling.current.nativeStage.focus = null;
		}
		
		public function selectRange(beginIndex:int, endIndex:int) : void {
			if(this._stageTextIsComplete && this.stageText) {
				this._pendingSelectionBeginIndex = -1;
				this._pendingSelectionEndIndex = -1;
				this.stageText.selectRange(beginIndex,endIndex);
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
			var _local4:Boolean = this.isInvalid("styles");
			var _local5:Boolean = this.isInvalid("data");
			if(_local4 || _local5) {
				this.refreshMeasureProperties();
			}
			return this.measure(result);
		}
		
		override protected function initialize() : void {
			if(this._measureTextField && !this._measureTextField.parent) {
				Starling.current.nativeStage.addChild(this._measureTextField);
			} else if(!this._measureTextField) {
				this._measureTextField = new TextField();
				this._measureTextField.visible = false;
				this._measureTextField.mouseEnabled = this._measureTextField.mouseWheelEnabled = false;
				this._measureTextField.autoSize = "left";
				this._measureTextField.multiline = false;
				this._measureTextField.wordWrap = false;
				this._measureTextField.embedFonts = false;
				this._measureTextField.defaultTextFormat = new TextFormat(null,11,0,false,false,false);
				Starling.current.nativeStage.addChild(this._measureTextField);
			}
			this.createStageText();
		}
		
		override protected function draw() : void {
			var _local1:Boolean = this.isInvalid("size");
			this.commit();
			_local1 = this.autoSizeIfNeeded() || _local1;
			this.layout(_local1);
		}
		
		protected function commit() : void {
			var _local1:Boolean = this.isInvalid("state");
			var _local2:Boolean = this.isInvalid("styles");
			var _local3:Boolean = this.isInvalid("data");
			if(_local2 || _local3) {
				this.refreshMeasureProperties();
			}
			var _local4:Boolean = this._ignoreStageTextChanges;
			this._ignoreStageTextChanges = true;
			if(_local1 || _local2) {
				this.refreshStageTextProperties();
			}
			if(_local3) {
				if(this.stageText.text != this._text) {
					if(this._pendingSelectionBeginIndex < 0) {
						this._pendingSelectionBeginIndex = this.stageText.selectionActiveIndex;
						this._pendingSelectionEndIndex = this.stageText.selectionAnchorIndex;
					}
					this.stageText.text = this._text;
				}
			}
			this._ignoreStageTextChanges = _local4;
			if(_local2 || _local1) {
				this.stageText.editable = this._isEditable && this._isEnabled;
			}
		}
		
		protected function measure(result:Point = null) : Point {
			if(!result) {
				result = new Point();
			}
			var _local3:* = this._explicitWidth !== this._explicitWidth;
			var _local5:* = this._explicitHeight !== this._explicitHeight;
			this._measureTextField.autoSize = "left";
			var _local2:Number = this._explicitWidth;
			if(_local3) {
				_local2 = this._measureTextField.textWidth;
				if(_local2 < this._explicitMinWidth) {
					_local2 = this._explicitMinWidth;
				} else if(_local2 > this._explicitMaxWidth) {
					_local2 = this._explicitMaxWidth;
				}
			}
			this._measureTextField.width = _local2 + 4;
			var _local4:Number = this._explicitHeight;
			if(_local5) {
				if(this._stageTextIsTextField) {
					_local4 = this._measureTextField.textHeight;
				} else {
					_local4 = this._measureTextField.height;
				}
				if(_local4 < this._explicitMinHeight) {
					_local4 = this._explicitMinHeight;
				} else if(_local4 > this._explicitMaxHeight) {
					_local4 = this._explicitMaxHeight;
				}
			}
			this._measureTextField.autoSize = "none";
			this._measureTextField.width = this.actualWidth + 4;
			this._measureTextField.height = this.actualHeight;
			result.x = _local2;
			result.y = _local4;
			return result;
		}
		
		protected function layout(sizeInvalid:Boolean) : void {
			var _local3:Rectangle = null;
			var _local4:ConcreteTexture = null;
			var _local8:* = false;
			var _local5:Boolean = this.isInvalid("state");
			var _local6:Boolean = this.isInvalid("styles");
			var _local7:Boolean = this.isInvalid("data");
			var _local2:Boolean = this.isInvalid("skin");
			if(sizeInvalid || _local6 || _local2 || _local5) {
				this.refreshViewPortAndFontSize();
				this.refreshMeasureTextFieldDimensions();
				_local3 = this.stageText.viewPort;
				_local4 = !!this.textSnapshot ? this.textSnapshot.texture.root : null;
				this._needsNewTexture = this._needsNewTexture || !this.textSnapshot || _local4.scale != Starling.contentScaleFactor || _local3.width != _local4.width || _local3.height != _local4.height;
			}
			if(!this._stageTextHasFocus && (_local5 || _local6 || _local7 || sizeInvalid || this._needsNewTexture)) {
				_local8 = this._text.length > 0;
				if(_local8) {
					this.refreshSnapshot();
				}
				if(this.textSnapshot) {
					this.textSnapshot.visible = !this._stageTextHasFocus;
					this.textSnapshot.alpha = _local8 ? 1 : 0;
				}
				this.stageText.visible = false;
			}
			this.doPendingActions();
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
		
		protected function refreshMeasureProperties() : void {
			this._measureTextField.displayAsPassword = this._displayAsPassword;
			this._measureTextField.maxChars = this._maxChars;
			this._measureTextField.restrict = this._restrict;
			this._measureTextField.multiline = this._measureTextField.wordWrap = this._multiline;
			var _local2:TextFormat = this._measureTextField.defaultTextFormat;
			_local2.color = this._color;
			_local2.font = this._fontFamily;
			_local2.italic = this._fontPosture == "italic";
			_local2.size = this._fontSize;
			_local2.bold = this._fontWeight == "bold";
			var _local1:String = this._textAlign;
			if(_local1 == "start") {
				_local1 = "left";
			} else if(_local1 == "end") {
				_local1 = "right";
			}
			_local2.align = _local1;
			this._measureTextField.defaultTextFormat = _local2;
			this._measureTextField.setTextFormat(_local2);
			if(this._text.length == 0) {
				this._measureTextField.text = " ";
			} else {
				this._measureTextField.text = this._text;
			}
		}
		
		protected function refreshStageTextProperties() : void {
			if(this.stageText.multiline != this._multiline) {
				if(this.stageText) {
					this.disposeStageText();
				}
				this.createStageText();
			}
			this.stageText.autoCapitalize = this._autoCapitalize;
			this.stageText.autoCorrect = this._autoCorrect;
			if(this._isEnabled) {
				this.stageText.color = this._color;
			} else {
				this.stageText.color = this._disabledColor;
			}
			this.stageText.displayAsPassword = this._displayAsPassword;
			this.stageText.fontFamily = this._fontFamily;
			this.stageText.fontPosture = this._fontPosture;
			this.stageText.fontWeight = this._fontWeight;
			this.stageText.locale = this._locale;
			this.stageText.maxChars = this._maxChars;
			this.stageText.restrict = this._restrict;
			this.stageText.returnKeyLabel = this._returnKeyLabel;
			this.stageText.softKeyboardType = this._softKeyboardType;
			this.stageText.textAlign = this._textAlign;
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
				_local2 = this._pendingSelectionEndIndex < 0 ? this._pendingSelectionBeginIndex : this._pendingSelectionEndIndex;
				this._pendingSelectionBeginIndex = -1;
				this._pendingSelectionEndIndex = -1;
				if(this.stageText.selectionAnchorIndex != _local1 || this.stageText.selectionActiveIndex != _local2) {
					this.selectRange(_local1,_local2);
				}
			}
		}
		
		protected function texture_onRestore() : void {
			if(this.textSnapshot.texture.scale != Starling.contentScaleFactor) {
				this.invalidate("size");
			} else {
				this.refreshSnapshot();
				if(this.textSnapshot) {
					this.textSnapshot.visible = !this._stageTextHasFocus;
					this.textSnapshot.alpha = this._text.length > 0 ? 1 : 0;
				}
				if(!this._stageTextHasFocus) {
					this.stageText.visible = false;
				}
			}
		}
		
		protected function refreshSnapshot() : void {
			var _local3:BitmapData = null;
			var _local8:Texture = null;
			var _local4:Number = NaN;
			var _local6:Texture = null;
			if(this.stage && !this.stageText.stage) {
				this.stageText.stage = Starling.current.nativeStage;
			}
			if(!this.stageText.stage) {
				this.invalidate("data");
				return;
			}
			var _local1:Rectangle = this.stageText.viewPort;
			if(_local1.width == 0 || _local1.height == 0) {
				return;
			}
			var _local7:Number = 1;
			if(Starling.current.supportHighResolutions) {
				_local7 = Starling.current.nativeStage.contentsScaleFactor;
			}
			try {
				_local3 = new BitmapData(_local1.width * _local7,_local1.height * _local7,true,0xff00ff);
				this.stageText.drawViewPortToBitmapData(_local3);
			}
			catch(error:Error) {
				_local3.dispose();
				_local3 = new BitmapData(_local1.width,_local1.height,true,0xff00ff);
				this.stageText.drawViewPortToBitmapData(_local3);
			}
			if(!this.textSnapshot || this._needsNewTexture) {
				_local4 = Starling.contentScaleFactor;
				_local8 = Texture.empty(_local3.width / _local4,_local3.height / _local4,true,false,false,_local4);
				_local8.root.uploadBitmapData(_local3);
				_local8.root.onRestore = texture_onRestore;
			}
			if(!this.textSnapshot) {
				this.textSnapshot = new Image(_local8);
				this.textSnapshot.pixelSnapping = true;
				this.addChild(this.textSnapshot);
			} else if(this._needsNewTexture) {
				this.textSnapshot.texture.dispose();
				this.textSnapshot.texture = _local8;
				this.textSnapshot.readjustSize();
			} else {
				_local6 = this.textSnapshot.texture;
				_local6.root.uploadBitmapData(_local3);
			}
			this.getTransformationMatrix(this.stage,HELPER_MATRIX);
			var _local2:Number = matrixToScaleX(HELPER_MATRIX);
			var _local5:Number = matrixToScaleY(HELPER_MATRIX);
			if(this._updateSnapshotOnScaleChange) {
				this.textSnapshot.scaleX = 1 / _local2;
				this.textSnapshot.scaleY = 1 / _local5;
				this._lastGlobalScaleX = _local2;
				this._lastGlobalScaleY = _local5;
			} else {
				this.textSnapshot.scaleX = 1;
				this.textSnapshot.scaleY = 1;
			}
			if(_local7 > 1 && _local3.width == _local1.width) {
				this.textSnapshot.scaleX *= _local7;
				this.textSnapshot.scaleY *= _local7;
			}
			_local3.dispose();
			this._needsNewTexture = false;
		}
		
		protected function refreshViewPortAndFontSize() : void {
			var _local2:Number = NaN;
			var _local6:Number = NaN;
			var _local10:* = NaN;
			HELPER_POINT.x = HELPER_POINT.y = 0;
			var _local3:Number = 0;
			var _local5:Number = 0;
			if(this._stageTextIsTextField) {
				_local3 = 2;
				_local5 = 4;
			}
			this.getTransformationMatrix(this.stage,HELPER_MATRIX);
			if(this._stageTextHasFocus || this._updateSnapshotOnScaleChange) {
				_local2 = matrixToScaleX(HELPER_MATRIX);
				_local6 = matrixToScaleY(HELPER_MATRIX);
				_local10 = _local2;
				if(_local6 < _local10) {
					_local10 = _local6;
				}
			} else {
				_local2 = 1;
				_local6 = 1;
				_local10 = 1;
			}
			if(this.is3D) {
				HELPER_MATRIX3D = this.getTransformationMatrix3D(this.stage,HELPER_MATRIX3D);
				HELPER_POINT3D = MatrixUtil.transformCoords3D(HELPER_MATRIX3D,-_local3,-_local3,0,HELPER_POINT3D);
				HELPER_POINT.setTo(HELPER_POINT3D.x,HELPER_POINT3D.y);
			} else {
				MatrixUtil.transformCoords(HELPER_MATRIX,-_local3,-_local3,HELPER_POINT);
			}
			var _local9:Starling = stageToStarling(this.stage);
			if(_local9 === null) {
				_local9 = Starling.current;
			}
			var _local8:Number = 1;
			if(_local9.supportHighResolutions) {
				_local8 = _local9.nativeStage.contentsScaleFactor;
			}
			var _local7:Number = _local9.contentScaleFactor / _local8;
			var _local4:Rectangle = _local9.viewPort;
			var _local12:Rectangle = this.stageText.viewPort;
			if(!_local12) {
				_local12 = new Rectangle();
			}
			_local12.x = Math.round(_local4.x + HELPER_POINT.x * _local7);
			_local12.y = Math.round(_local4.y + HELPER_POINT.y * _local7);
			var _local11:Number = Math.round((this.actualWidth + _local5) * _local7 * _local2);
			if(_local11 < 1 || _local11 !== _local11) {
				_local11 = 1;
			}
			var _local13:Number = Math.round((this.actualHeight + _local5) * _local7 * _local6);
			if(_local13 < 1 || _local13 !== _local13) {
				_local13 = 1;
			}
			_local12.width = _local11;
			_local12.height = _local13;
			this.stageText.viewPort = _local12;
			var _local1:int = this._fontSize * _local7 * _local10;
			if(this.stageText.fontSize != _local1) {
				this.stageText.fontSize = _local1;
			}
		}
		
		protected function refreshMeasureTextFieldDimensions() : void {
			this._measureTextField.width = this.actualWidth + 4;
			this._measureTextField.height = this.actualHeight;
		}
		
		protected function positionSnapshot() : void {
			this.getTransformationMatrix(this.stage,HELPER_MATRIX);
			var _local1:Number = 0;
			if(this._stageTextIsTextField) {
				_local1 = 2;
			}
			this.textSnapshot.x = Math.round(HELPER_MATRIX.tx) - HELPER_MATRIX.tx - _local1;
			this.textSnapshot.y = Math.round(HELPER_MATRIX.ty) - HELPER_MATRIX.ty - _local1;
		}
		
		protected function disposeStageText() : void {
			if(!this.stageText) {
				return;
			}
			this.stageText.removeEventListener("change",stageText_changeHandler);
			this.stageText.removeEventListener("keyDown",stageText_keyDownHandler);
			this.stageText.removeEventListener("keyUp",stageText_keyUpHandler);
			this.stageText.removeEventListener("focusIn",stageText_focusInHandler);
			this.stageText.removeEventListener("focusOut",stageText_focusOutHandler);
			this.stageText.removeEventListener("complete",stageText_completeHandler);
			this.stageText.removeEventListener("softKeyboardActivate",stageText_softKeyboardActivateHandler);
			this.stageText.removeEventListener("softKeyboardDeactivate",stageText_softKeyboardDeactivateHandler);
			this.stageText.stage = null;
			this.stageText.dispose();
			this.stageText = null;
		}
		
		protected function createStageText() : void {
			var _local1:Class = null;
			var _local3:Object = null;
			var _local2:Class = null;
			this._stageTextIsComplete = false;
			try {
				_local1 = Class(getDefinitionByName("flash.text.StageText"));
				_local2 = Class(getDefinitionByName("flash.text.StageTextInitOptions"));
				_local3 = new _local2(this._multiline);
			}
			catch(error:Error) {
				_local1 = StageTextField;
				_local3 = {"multiline":this._multiline};
			}
			this.stageText = new _local1(_local3);
			this.stageText.visible = false;
			this.stageText.addEventListener("change",stageText_changeHandler);
			this.stageText.addEventListener("keyDown",stageText_keyDownHandler);
			this.stageText.addEventListener("keyUp",stageText_keyUpHandler);
			this.stageText.addEventListener("focusIn",stageText_focusInHandler);
			this.stageText.addEventListener("focusOut",stageText_focusOutHandler);
			this.stageText.addEventListener("softKeyboardActivate",stageText_softKeyboardActivateHandler);
			this.stageText.addEventListener("softKeyboardDeactivate",stageText_softKeyboardDeactivateHandler);
			this.stageText.addEventListener("complete",stageText_completeHandler);
			this.invalidate();
		}
		
		protected function dispatchKeyFocusChangeEvent(event:KeyboardEvent) : void {
			var _local2:Starling = stageToStarling(this.stage);
			var _local3:FocusEvent = new FocusEvent("keyFocusChange",true,false,null,event.shiftKey,event.keyCode);
			_local2.nativeStage.dispatchEvent(_local3);
		}
		
		protected function textEditor_removedFromStageHandler(event:starling.events.Event) : void {
			this.stageText.stage = null;
		}
		
		protected function stageText_changeHandler(event:flash.events.Event) : void {
			if(this._ignoreStageTextChanges) {
				return;
			}
			this.text = this.stageText.text;
		}
		
		protected function stageText_completeHandler(event:flash.events.Event) : void {
			this.stageText.removeEventListener("complete",stageText_completeHandler);
			this.invalidate();
			this._stageTextIsComplete = true;
		}
		
		protected function stageText_focusInHandler(event:FocusEvent) : void {
			this._stageTextHasFocus = true;
			this.addEventListener("enterFrame",hasFocus_enterFrameHandler);
			if(this.textSnapshot) {
				this.textSnapshot.visible = false;
			}
			this.invalidate("skin");
			this.dispatchEventWith("focusIn");
		}
		
		protected function stageText_focusOutHandler(event:FocusEvent) : void {
			this._stageTextHasFocus = false;
			this.stageText.selectRange(1,1);
			this.invalidate("data");
			this.invalidate("skin");
			this.dispatchEventWith("focusOut");
		}
		
		protected function hasFocus_enterFrameHandler(event:starling.events.Event) : void {
			var _local2:DisplayObject = null;
			if(this._stageTextHasFocus) {
				_local2 = this;
				do {
					if(!_local2.visible) {
						this.stageText.stage.focus = null;
						break;
					}
					_local2 = _local2.parent;
				}
				while(_local2);
				
			} else {
				this.removeEventListener("enterFrame",hasFocus_enterFrameHandler);
			}
		}
		
		protected function stageText_keyDownHandler(event:KeyboardEvent) : void {
			if(!this._multiline && (event.keyCode == 13 || event.keyCode == 16777230)) {
				event.preventDefault();
				this.dispatchEventWith("enter");
			} else if(event.keyCode == 16777238) {
				event.preventDefault();
				Starling.current.nativeStage.focus = Starling.current.nativeStage;
			}
			if(event.keyCode === 9 && FocusManager.isEnabledForStage(this.stage)) {
				event.preventDefault();
				this.dispatchKeyFocusChangeEvent(event);
			}
		}
		
		protected function stageText_keyUpHandler(event:KeyboardEvent) : void {
			if(!this._multiline && (event.keyCode == 13 || event.keyCode == 16777230)) {
				event.preventDefault();
			}
			if(event.keyCode === 9 && FocusManager.isEnabledForStage(this.stage)) {
				event.preventDefault();
			}
		}
		
		protected function stageText_softKeyboardActivateHandler(event:SoftKeyboardEvent) : void {
			this.dispatchEventWith("softKeyboardActivate",true);
		}
		
		protected function stageText_softKeyboardDeactivateHandler(event:SoftKeyboardEvent) : void {
			this.dispatchEventWith("softKeyboardDeactivate",true);
		}
	}
}

