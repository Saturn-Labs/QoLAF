package feathers.controls {
	import feathers.core.FeathersControl;
	import feathers.core.IAdvancedNativeFocusOwner;
	import feathers.core.IFeathersControl;
	import feathers.core.IMeasureDisplayObject;
	import feathers.core.IMultilineTextEditor;
	import feathers.core.INativeFocusOwner;
	import feathers.core.IStateContext;
	import feathers.core.IStateObserver;
	import feathers.core.ITextBaselineControl;
	import feathers.core.ITextEditor;
	import feathers.core.ITextRenderer;
	import feathers.core.IValidating;
	import feathers.core.PopUpManager;
	import feathers.core.PropertyProxy;
	import feathers.skins.IStyleProvider;
	import feathers.utils.skins.resetFluidChildDimensionsForMeasurement;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	public class TextInput extends FeathersControl implements ITextBaselineControl, IAdvancedNativeFocusOwner, IStateContext {
		protected static const INVALIDATION_FLAG_PROMPT_FACTORY:String = "promptFactory";
		
		protected static const INVALIDATION_FLAG_ERROR_CALLOUT_FACTORY:String = "errorCalloutFactory";
		
		public static const STATE_ENABLED:String = "enabled";
		
		public static const STATE_DISABLED:String = "disabled";
		
		public static const STATE_FOCUSED:String = "focused";
		
		public static const DEFAULT_CHILD_STYLE_NAME_TEXT_EDITOR:String = "feathers-text-input-text-editor";
		
		public static const DEFAULT_CHILD_STYLE_NAME_PROMPT:String = "feathers-text-input-prompt";
		
		public static const DEFAULT_CHILD_STYLE_NAME_ERROR_CALLOUT:String = "feathers-text-input-error-callout";
		
		public static const ALTERNATE_STYLE_NAME_SEARCH_TEXT_INPUT:String = "feathers-search-text-input";
		
		public static const VERTICAL_ALIGN_TOP:String = "top";
		
		public static const VERTICAL_ALIGN_MIDDLE:String = "middle";
		
		public static const VERTICAL_ALIGN_BOTTOM:String = "bottom";
		
		public static const VERTICAL_ALIGN_JUSTIFY:String = "justify";
		
		public static var globalStyleProvider:IStyleProvider;
		
		private static const HELPER_POINT:Point = new Point();
		
		protected var textEditor:ITextEditor;
		
		protected var promptTextRenderer:ITextRenderer;
		
		protected var currentBackground:DisplayObject;
		
		protected var currentIcon:DisplayObject;
		
		protected var callout:TextCallout;
		
		protected var textEditorStyleName:String = "feathers-text-input-text-editor";
		
		protected var promptStyleName:String = "feathers-text-input-prompt";
		
		protected var errorCalloutStyleName:String = "feathers-text-input-error-callout";
		
		protected var _textEditorHasFocus:Boolean = false;
		
		protected var _ignoreTextChanges:Boolean = false;
		
		protected var _touchPointID:int = -1;
		
		protected var _currentState:String = "enabled";
		
		protected var _text:String = "";
		
		protected var _prompt:String = null;
		
		protected var _typicalText:String = null;
		
		protected var _maxChars:int = 0;
		
		protected var _restrict:String;
		
		protected var _displayAsPassword:Boolean = false;
		
		protected var _isEditable:Boolean = true;
		
		protected var _isSelectable:Boolean = true;
		
		protected var _errorString:String = null;
		
		protected var _textEditorFactory:Function;
		
		protected var _customTextEditorStyleName:String;
		
		protected var _promptFactory:Function;
		
		protected var _customPromptStyleName:String;
		
		protected var _promptProperties:PropertyProxy;
		
		protected var _customErrorCalloutStyleName:String;
		
		protected var _explicitBackgroundWidth:Number;
		
		protected var _explicitBackgroundHeight:Number;
		
		protected var _explicitBackgroundMinWidth:Number;
		
		protected var _explicitBackgroundMinHeight:Number;
		
		protected var _explicitBackgroundMaxWidth:Number;
		
		protected var _explicitBackgroundMaxHeight:Number;
		
		protected var _backgroundSkin:DisplayObject;
		
		protected var _stateToSkin:Object = {};
		
		protected var _stateToSkinFunction:Function;
		
		protected var _originalIconWidth:Number = NaN;
		
		protected var _originalIconHeight:Number = NaN;
		
		protected var _defaultIcon:DisplayObject;
		
		protected var _stateToIcon:Object = {};
		
		protected var _stateToIconFunction:Function;
		
		protected var _gap:Number = 0;
		
		protected var _paddingTop:Number = 0;
		
		protected var _paddingRight:Number = 0;
		
		protected var _paddingBottom:Number = 0;
		
		protected var _paddingLeft:Number = 0;
		
		protected var _verticalAlign:String = "middle";
		
		protected var _isWaitingToSetFocus:Boolean = false;
		
		protected var _pendingSelectionBeginIndex:int = -1;
		
		protected var _pendingSelectionEndIndex:int = -1;
		
		protected var _oldMouseCursor:String = null;
		
		protected var _textEditorProperties:PropertyProxy;
		
		public function TextInput() {
			super();
			this.addEventListener("touch",textInput_touchHandler);
			this.addEventListener("removedFromStage",textInput_removedFromStageHandler);
		}
		
		public function get nativeFocus() : Object {
			if(this.textEditor is INativeFocusOwner) {
				return INativeFocusOwner(this.textEditor).nativeFocus;
			}
			return null;
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return TextInput.globalStyleProvider;
		}
		
		public function get hasFocus() : Boolean {
			return this._textEditorHasFocus;
		}
		
		override public function set isEnabled(value:Boolean) : void {
			super.isEnabled = value;
			this.refreshState();
		}
		
		public function get currentState() : String {
			return this._currentState;
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
			if(!this.textEditor) {
				return 0;
			}
			return this.textEditor.y + this.textEditor.baseline;
		}
		
		public function get prompt() : String {
			return this._prompt;
		}
		
		public function set prompt(value:String) : void {
			if(this._prompt == value) {
				return;
			}
			this._prompt = value;
			this.invalidate("styles");
		}
		
		public function get typicalText() : String {
			return this._typicalText;
		}
		
		public function set typicalText(value:String) : void {
			if(this._typicalText === value) {
				return;
			}
			this._typicalText = value;
			this.invalidate("data");
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
		
		public function get errorString() : String {
			return this._errorString;
		}
		
		public function set errorString(value:String) : void {
			if(this._errorString === value) {
				return;
			}
			this._errorString = value;
			this.refreshState();
			this.invalidate("styles");
		}
		
		public function get textEditorFactory() : Function {
			return this._textEditorFactory;
		}
		
		public function set textEditorFactory(value:Function) : void {
			if(this._textEditorFactory == value) {
				return;
			}
			this._textEditorFactory = value;
			this.invalidate("textEditor");
		}
		
		public function get customTextEditorStyleName() : String {
			return this._customTextEditorStyleName;
		}
		
		public function set customTextEditorStyleName(value:String) : void {
			if(this._customTextEditorStyleName == value) {
				return;
			}
			this._customTextEditorStyleName = value;
			this.invalidate("textRenderer");
		}
		
		public function get promptFactory() : Function {
			return this._promptFactory;
		}
		
		public function set promptFactory(value:Function) : void {
			if(this._promptFactory == value) {
				return;
			}
			this._promptFactory = value;
			this.invalidate("promptFactory");
		}
		
		public function get customPromptStyleName() : String {
			return this._customPromptStyleName;
		}
		
		public function set customPromptStyleName(value:String) : void {
			if(this._customPromptStyleName == value) {
				return;
			}
			this._customPromptStyleName = value;
			this.invalidate("textRenderer");
		}
		
		public function get promptProperties() : Object {
			if(!this._promptProperties) {
				this._promptProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._promptProperties;
		}
		
		public function set promptProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._promptProperties == value) {
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
			if(this._promptProperties) {
				this._promptProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._promptProperties = PropertyProxy(value);
			if(this._promptProperties) {
				this._promptProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get customErrorCalloutStyleName() : String {
			return this._customErrorCalloutStyleName;
		}
		
		public function set customErrorCalloutStyleName(value:String) : void {
			if(this._customErrorCalloutStyleName == value) {
				return;
			}
			this._customErrorCalloutStyleName = value;
			this.invalidate("errorCalloutFactory");
		}
		
		public function get backgroundSkin() : DisplayObject {
			return this._backgroundSkin;
		}
		
		public function set backgroundSkin(value:DisplayObject) : void {
			if(this._backgroundSkin === value) {
				return;
			}
			this._backgroundSkin = value;
			this.invalidate("skin");
		}
		
		public function get backgroundEnabledSkin() : DisplayObject {
			return this.getSkinForState("enabled");
		}
		
		public function set backgroundEnabledSkin(value:DisplayObject) : void {
			this.setSkinForState("enabled",value);
		}
		
		public function get backgroundFocusedSkin() : DisplayObject {
			return this.getSkinForState("focused");
		}
		
		public function set backgroundFocusedSkin(value:DisplayObject) : void {
			this.setSkinForState("focused",value);
		}
		
		public function get backgroundErrorSkin() : DisplayObject {
			return this.getSkinForState("error");
		}
		
		public function set backgroundErrorSkin(value:DisplayObject) : void {
			this.setSkinForState("error",value);
		}
		
		public function get backgroundDisabledSkin() : DisplayObject {
			return this.getSkinForState("disabled");
		}
		
		public function set backgroundDisabledSkin(value:DisplayObject) : void {
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
			this.invalidate("skin");
		}
		
		public function get defaultIcon() : DisplayObject {
			return this._defaultIcon;
		}
		
		public function set defaultIcon(value:DisplayObject) : void {
			if(this._defaultIcon === value) {
				return;
			}
			this._defaultIcon = value;
			this.invalidate("styles");
		}
		
		public function get enabledIcon() : DisplayObject {
			return this.getIconForState("enabled");
		}
		
		public function set enabledIcon(value:DisplayObject) : void {
			this.setIconForState("enabled",value);
		}
		
		public function get disabledIcon() : DisplayObject {
			return this.getIconForState("disabled");
		}
		
		public function set disabledIcon(value:DisplayObject) : void {
			this.setIconForState("disabled",value);
		}
		
		public function get focusedIcon() : DisplayObject {
			return this.getIconForState("focused");
		}
		
		public function set focusedIcon(value:DisplayObject) : void {
			this.setIconForState("focused",value);
		}
		
		public function get errorIcon() : DisplayObject {
			return this.getIconForState("error");
		}
		
		public function set errorIcon(value:DisplayObject) : void {
			this.setIconForState("error",value);
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
		
		public function get textEditorProperties() : Object {
			if(!this._textEditorProperties) {
				this._textEditorProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._textEditorProperties;
		}
		
		public function set textEditorProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._textEditorProperties == value) {
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
			if(this._textEditorProperties) {
				this._textEditorProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._textEditorProperties = PropertyProxy(value);
			if(this._textEditorProperties) {
				this._textEditorProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get selectionBeginIndex() : int {
			if(this._pendingSelectionBeginIndex >= 0) {
				return this._pendingSelectionBeginIndex;
			}
			if(this.textEditor) {
				return this.textEditor.selectionBeginIndex;
			}
			return 0;
		}
		
		public function get selectionEndIndex() : int {
			if(this._pendingSelectionEndIndex >= 0) {
				return this._pendingSelectionEndIndex;
			}
			if(this.textEditor) {
				return this.textEditor.selectionEndIndex;
			}
			return 0;
		}
		
		override public function set visible(value:Boolean) : void {
			if(!value) {
				this._isWaitingToSetFocus = false;
				if(this._textEditorHasFocus) {
					this.textEditor.clearFocus();
				}
			}
			super.visible = value;
		}
		
		override public function hitTest(localPoint:Point) : DisplayObject {
			if(!this.visible || !this.touchable) {
				return null;
			}
			if(this.mask && !this.hitTestMask(localPoint)) {
				return null;
			}
			return this._hitArea.containsPoint(localPoint) ? DisplayObject(this.textEditor) : null;
		}
		
		override public function showFocus() : void {
			if(!this._focusManager || this._focusManager.focus != this) {
				return;
			}
			this.selectRange(0,this._text.length);
			super.showFocus();
		}
		
		public function setFocus() : void {
			if(this._textEditorHasFocus || !this.visible || this._touchPointID >= 0) {
				return;
			}
			if(this.textEditor) {
				this._isWaitingToSetFocus = false;
				this.textEditor.setFocus();
			} else {
				this._isWaitingToSetFocus = true;
				this.invalidate("selected");
			}
		}
		
		public function clearFocus() : void {
			this._isWaitingToSetFocus = false;
			if(!this.textEditor || !this._textEditorHasFocus) {
				return;
			}
			this.textEditor.clearFocus();
		}
		
		public function selectRange(beginIndex:int, endIndex:int = -1) : void {
			if(endIndex < 0) {
				endIndex = beginIndex;
			}
			if(beginIndex < 0) {
				throw new RangeError("Expected start index >= 0. Received " + beginIndex + ".");
			}
			if(endIndex > this._text.length) {
				throw new RangeError("Expected end index <= " + this._text.length + ". Received " + endIndex + ".");
			}
			if(this.textEditor && (this._isValidating || !this.isInvalid())) {
				this._pendingSelectionBeginIndex = -1;
				this._pendingSelectionEndIndex = -1;
				this.textEditor.selectRange(beginIndex,endIndex);
			} else {
				this._pendingSelectionBeginIndex = beginIndex;
				this._pendingSelectionEndIndex = endIndex;
				this.invalidate("selected");
			}
		}
		
		public function getSkinForState(state:String) : DisplayObject {
			return this._stateToSkin[state] as DisplayObject;
		}
		
		public function setSkinForState(state:String, skin:DisplayObject) : void {
			if(skin !== null) {
				this._stateToSkin[state] = skin;
			} else {
				delete this._stateToSkin[state];
			}
			this.invalidate("styles");
		}
		
		public function getIconForState(state:String) : DisplayObject {
			return this._stateToIcon[state] as DisplayObject;
		}
		
		public function setIconForState(state:String, icon:DisplayObject) : void {
			if(icon !== null) {
				this._stateToIcon[state] = icon;
			} else {
				delete this._stateToIcon[state];
			}
			this.invalidate("styles");
		}
		
		override public function dispose() : void {
			var _local1:DisplayObject = null;
			var _local2:DisplayObject = null;
			if(this._backgroundSkin !== null && this._backgroundSkin.parent !== this) {
				this._backgroundSkin.dispose();
			}
			for(var _local3 in this._stateToSkin) {
				_local1 = this._stateToSkin[_local3] as DisplayObject;
				if(_local1 !== null && _local1.parent !== this) {
					_local1.dispose();
				}
			}
			if(this._defaultIcon !== null && this._defaultIcon.parent !== this) {
				this._defaultIcon.dispose();
			}
			for(_local3 in this._stateToIcon) {
				_local2 = this._stateToIcon[_local3] as DisplayObject;
				if(_local2 !== null && _local2.parent !== this) {
					_local2.dispose();
				}
			}
			super.dispose();
		}
		
		override protected function draw() : void {
			var _local3:Boolean = false;
			var _local6:Boolean = this.isInvalid("state");
			var _local7:Boolean = this.isInvalid("styles");
			var _local8:Boolean = this.isInvalid("data");
			var _local4:Boolean = this.isInvalid("skin");
			var _local1:Boolean = this.isInvalid("size");
			var _local9:Boolean = this.isInvalid("textEditor");
			var _local5:Boolean = this.isInvalid("promptFactory");
			var _local2:Boolean = this.isInvalid("focus");
			if(_local9) {
				this.createTextEditor();
			}
			if(_local5 || this._prompt !== null && !this.promptTextRenderer) {
				this.createPrompt();
			}
			if(_local9 || _local7) {
				this.refreshTextEditorProperties();
			}
			if(_local5 || _local7) {
				this.refreshPromptProperties();
			}
			if(_local9 || _local8) {
				_local3 = this._ignoreTextChanges;
				this._ignoreTextChanges = true;
				this.textEditor.text = this._text;
				this._ignoreTextChanges = _local3;
			}
			if(this.promptTextRenderer) {
				if(_local5 || _local8 || _local7) {
					this.promptTextRenderer.visible = this._prompt && this._text.length == 0;
				}
				if(_local5 || _local6) {
					this.promptTextRenderer.isEnabled = this._isEnabled;
				}
			}
			if(_local9 || _local6) {
				this.textEditor.isEnabled = this._isEnabled;
				if(!this._isEnabled && Mouse.supportsNativeCursor && this._oldMouseCursor) {
					Mouse.cursor = this._oldMouseCursor;
					this._oldMouseCursor = null;
				}
			}
			if(_local6 || _local4) {
				this.refreshBackgroundSkin();
			}
			if(_local6 || _local7) {
				this.refreshIcon();
			}
			_local1 = this.autoSizeIfNeeded() || _local1;
			this.layoutChildren();
			if(_local1 || _local2) {
				this.refreshFocusIndicator();
			}
			this.doPendingActions();
		}
		
		protected function autoSizeIfNeeded() : Boolean {
			var _local9:Number = NaN;
			var _local1:Number = NaN;
			var _local10:Boolean = false;
			var _local16:Number = NaN;
			var _local3:Number = NaN;
			var _local7:Number = NaN;
			var _local4:* = this._explicitWidth !== this._explicitWidth;
			var _local15:* = this._explicitHeight !== this._explicitHeight;
			var _local13:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local18:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local4 && !_local15 && !_local13 && !_local18) {
				return false;
			}
			var _local6:IMeasureDisplayObject = this.currentBackground as IMeasureDisplayObject;
			resetFluidChildDimensionsForMeasurement(this.currentBackground,this._explicitWidth,this._explicitHeight,this._explicitMinWidth,this._explicitMinHeight,this._explicitMaxWidth,this._explicitMaxHeight,this._explicitBackgroundWidth,this._explicitBackgroundHeight,this._explicitBackgroundMinWidth,this._explicitBackgroundMinHeight,this._explicitBackgroundMaxWidth,this._explicitBackgroundMaxHeight);
			if(this.currentBackground is IValidating) {
				IValidating(this.currentBackground).validate();
			}
			if(this.currentIcon is IValidating) {
				IValidating(this.currentIcon).validate();
			}
			var _local17:Number = 0;
			var _local8:Number = 0;
			if(this._typicalText !== null) {
				_local9 = Number(this.textEditor.width);
				_local1 = Number(this.textEditor.height);
				_local10 = this._ignoreTextChanges;
				this._ignoreTextChanges = true;
				this.textEditor.setSize(NaN,NaN);
				this.textEditor.text = this._typicalText;
				this.textEditor.measureText(HELPER_POINT);
				this.textEditor.text = this._text;
				this._ignoreTextChanges = _local10;
				_local17 = HELPER_POINT.x;
				_local8 = HELPER_POINT.y;
			}
			if(this._prompt !== null) {
				this.promptTextRenderer.setSize(NaN,NaN);
				this.promptTextRenderer.measureText(HELPER_POINT);
				if(HELPER_POINT.x > _local17) {
					_local17 = HELPER_POINT.x;
				}
				if(HELPER_POINT.y > _local8) {
					_local8 = HELPER_POINT.y;
				}
			}
			var _local2:* = this._explicitWidth;
			if(_local4) {
				_local2 = _local17;
				if(this._originalIconWidth === this._originalIconWidth) {
					_local2 += this._originalIconWidth + this._gap;
				}
				_local2 += this._paddingLeft + this._paddingRight;
				if(this.currentBackground !== null && this.currentBackground.width > _local2) {
					_local2 = this.currentBackground.width;
				}
			}
			var _local5:* = this._explicitHeight;
			if(_local15) {
				_local5 = _local8;
				if(this._originalIconHeight === this._originalIconHeight && this._originalIconHeight > _local5) {
					_local5 = this._originalIconHeight;
				}
				_local5 += this._paddingTop + this._paddingBottom;
				if(this.currentBackground !== null && this.currentBackground.height > _local5) {
					_local5 = this.currentBackground.height;
				}
			}
			var _local11:* = this._explicitMinWidth;
			if(_local13) {
				_local11 = _local17;
				if(this.currentIcon is IFeathersControl) {
					_local11 += IFeathersControl(this.currentIcon).minWidth + this._gap;
				} else if(this._originalIconWidth === this._originalIconWidth) {
					_local11 += this._originalIconWidth + this._gap;
				}
				_local11 += this._paddingLeft + this._paddingRight;
				_local16 = 0;
				if(_local6 !== null) {
					_local16 = _local6.minWidth;
				} else if(this.currentBackground !== null) {
					_local16 = this._explicitBackgroundMinWidth;
				}
				if(_local16 > _local11) {
					_local11 = _local16;
				}
			}
			var _local14:* = this._explicitMinHeight;
			if(_local18) {
				_local14 = _local8;
				if(this.currentIcon is IFeathersControl) {
					_local3 = Number(IFeathersControl(this.currentIcon).minHeight);
					if(_local3 > _local14) {
						_local14 = _local3;
					}
				} else if(this._originalIconHeight === this._originalIconHeight && this._originalIconHeight > _local14) {
					_local14 = this._originalIconHeight;
				}
				_local14 += this._paddingTop + this._paddingBottom;
				_local7 = 0;
				if(_local6 !== null) {
					_local7 = _local6.minHeight;
				} else if(this.currentBackground !== null) {
					_local7 = this._explicitBackgroundMinHeight;
				}
				if(_local7 > _local14) {
					_local14 = _local7;
				}
			}
			var _local12:Boolean = this.textEditor is IMultilineTextEditor && Boolean(IMultilineTextEditor(this.textEditor).multiline);
			if(this._typicalText !== null && (this._verticalAlign == "justify" || _local12)) {
				this.textEditor.width = _local9;
				this.textEditor.height = _local1;
			}
			return this.saveMeasurements(_local2,_local5,_local11,_local14);
		}
		
		protected function createTextEditor() : void {
			if(this.textEditor) {
				this.removeChild(DisplayObject(this.textEditor),true);
				this.textEditor.removeEventListener("change",textEditor_changeHandler);
				this.textEditor.removeEventListener("enter",textEditor_enterHandler);
				this.textEditor.removeEventListener("focusIn",textEditor_focusInHandler);
				this.textEditor.removeEventListener("focusOut",textEditor_focusOutHandler);
				this.textEditor = null;
			}
			var _local1:Function = this._textEditorFactory != null ? this._textEditorFactory : FeathersControl.defaultTextEditorFactory;
			this.textEditor = ITextEditor(_local1());
			var _local2:String = this._customTextEditorStyleName != null ? this._customTextEditorStyleName : this.textEditorStyleName;
			this.textEditor.styleNameList.add(_local2);
			if(this.textEditor is IStateObserver) {
				IStateObserver(this.textEditor).stateContext = this;
			}
			this.textEditor.addEventListener("change",textEditor_changeHandler);
			this.textEditor.addEventListener("enter",textEditor_enterHandler);
			this.textEditor.addEventListener("focusIn",textEditor_focusInHandler);
			this.textEditor.addEventListener("focusOut",textEditor_focusOutHandler);
			this.addChild(DisplayObject(this.textEditor));
		}
		
		protected function createPrompt() : void {
			if(this.promptTextRenderer) {
				this.removeChild(DisplayObject(this.promptTextRenderer),true);
				this.promptTextRenderer = null;
			}
			if(this._prompt === null) {
				return;
			}
			var _local1:Function = this._promptFactory != null ? this._promptFactory : FeathersControl.defaultTextRendererFactory;
			this.promptTextRenderer = ITextRenderer(_local1());
			var _local2:String = this._customPromptStyleName != null ? this._customPromptStyleName : this.promptStyleName;
			this.promptTextRenderer.styleNameList.add(_local2);
			this.addChild(DisplayObject(this.promptTextRenderer));
		}
		
		protected function createErrorCallout() : void {
			if(this.callout) {
				this.callout.removeFromParent(true);
				this.callout = null;
			}
			if(this._errorString === null) {
				return;
			}
			this.callout = new TextCallout();
			var _local1:String = this._customErrorCalloutStyleName != null ? this._customErrorCalloutStyleName : this.errorCalloutStyleName;
			this.callout.styleNameList.add(_local1);
			this.callout.closeOnKeys = null;
			this.callout.closeOnTouchBeganOutside = false;
			this.callout.closeOnTouchEndedOutside = false;
			this.callout.touchable = false;
			this.callout.text = this._errorString;
			this.callout.origin = this;
			PopUpManager.addPopUp(this.callout,false,false);
		}
		
		protected function changeState(state:String) : void {
			if(this._currentState === state) {
				return;
			}
			this._currentState = state;
			this.invalidate("state");
			this.dispatchEventWith("stageChange");
		}
		
		protected function doPendingActions() : void {
			var _local1:int = 0;
			var _local2:* = 0;
			var _local3:int = 0;
			if(this._isWaitingToSetFocus) {
				this._isWaitingToSetFocus = false;
				if(!this._textEditorHasFocus) {
					this.textEditor.setFocus();
				}
			}
			if(this._pendingSelectionBeginIndex >= 0) {
				_local1 = this._pendingSelectionBeginIndex;
				_local2 = this._pendingSelectionEndIndex;
				this._pendingSelectionBeginIndex = -1;
				this._pendingSelectionEndIndex = -1;
				if(_local2 >= 0) {
					_local3 = this._text.length;
					if(_local2 > _local3) {
						_local2 = _local3;
					}
				}
				this.selectRange(_local1,_local2);
			}
		}
		
		protected function refreshTextEditorProperties() : void {
			var _local2:Object = null;
			this.textEditor.displayAsPassword = this._displayAsPassword;
			this.textEditor.maxChars = this._maxChars;
			this.textEditor.restrict = this._restrict;
			this.textEditor.isEditable = this._isEditable;
			this.textEditor.isSelectable = this._isSelectable;
			for(var _local1 in this._textEditorProperties) {
				_local2 = this._textEditorProperties[_local1];
				this.textEditor[_local1] = _local2;
			}
		}
		
		protected function refreshPromptProperties() : void {
			var _local2:Object = null;
			if(!this.promptTextRenderer) {
				return;
			}
			this.promptTextRenderer.text = this._prompt;
			var _local3:DisplayObject = DisplayObject(this.promptTextRenderer);
			for(var _local1 in this._promptProperties) {
				_local2 = this._promptProperties[_local1];
				this.promptTextRenderer[_local1] = _local2;
			}
		}
		
		protected function refreshBackgroundSkin() : void {
			var _local2:IMeasureDisplayObject = null;
			var _local1:DisplayObject = this.currentBackground;
			this.currentBackground = this.getCurrentSkin();
			if(this.currentBackground !== _local1) {
				if(_local1) {
					if(_local1 is IStateObserver) {
						IStateObserver(_local1).stateContext = null;
					}
					this.removeChild(_local1,false);
				}
				if(this.currentBackground) {
					if(this.currentBackground is IStateObserver) {
						IStateObserver(this.currentBackground).stateContext = this;
					}
					this.addChildAt(this.currentBackground,0);
					if(this.currentBackground is IFeathersControl) {
						IFeathersControl(this.currentBackground).initializeNow();
					}
					if(this.currentBackground is IMeasureDisplayObject) {
						_local2 = IMeasureDisplayObject(this.currentBackground);
						this._explicitBackgroundWidth = _local2.explicitWidth;
						this._explicitBackgroundHeight = _local2.explicitHeight;
						this._explicitBackgroundMinWidth = _local2.explicitMinWidth;
						this._explicitBackgroundMinHeight = _local2.explicitMinHeight;
						this._explicitBackgroundMaxWidth = _local2.explicitMaxWidth;
						this._explicitBackgroundMaxHeight = _local2.explicitMaxHeight;
					} else {
						this._explicitBackgroundWidth = this.currentBackground.width;
						this._explicitBackgroundHeight = this.currentBackground.height;
						this._explicitBackgroundMinWidth = this._explicitBackgroundWidth;
						this._explicitBackgroundMinHeight = this._explicitBackgroundHeight;
						this._explicitBackgroundMaxWidth = this._explicitBackgroundWidth;
						this._explicitBackgroundMaxHeight = this._explicitBackgroundHeight;
					}
				}
			}
		}
		
		protected function refreshIcon() : void {
			var _local2:int = 0;
			var _local1:DisplayObject = this.currentIcon;
			this.currentIcon = this.getCurrentIcon();
			if(this.currentIcon is IFeathersControl) {
				IFeathersControl(this.currentIcon).isEnabled = this._isEnabled;
			}
			if(this.currentIcon !== _local1) {
				if(_local1) {
					if(_local1 is IStateObserver) {
						IStateObserver(_local1).stateContext = null;
					}
					this.removeChild(_local1,false);
				}
				if(this.currentIcon) {
					if(this.currentIcon is IStateObserver) {
						IStateObserver(this.currentIcon).stateContext = this;
					}
					_local2 = this.getChildIndex(DisplayObject(this.textEditor));
					this.addChildAt(this.currentIcon,_local2);
				}
			}
			if(this.currentIcon && (this._originalIconWidth !== this._originalIconWidth || this._originalIconHeight !== this._originalIconHeight)) {
				if(this.currentIcon is IValidating) {
					IValidating(this.currentIcon).validate();
				}
				this._originalIconWidth = this.currentIcon.width;
				this._originalIconHeight = this.currentIcon.height;
			}
		}
		
		protected function getCurrentSkin() : DisplayObject {
			if(this._stateToSkinFunction !== null) {
				return DisplayObject(this._stateToSkinFunction(this,this._currentState,this.currentBackground));
			}
			var _local1:DisplayObject = this._stateToSkin[this._currentState] as DisplayObject;
			if(_local1 !== null) {
				return _local1;
			}
			return this._backgroundSkin;
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
		
		protected function layoutChildren() : void {
			var _local5:Number = NaN;
			var _local2:Number = NaN;
			if(this.currentBackground !== null) {
				this.currentBackground.visible = true;
				this.currentBackground.touchable = true;
				this.currentBackground.width = this.actualWidth;
				this.currentBackground.height = this.actualHeight;
			}
			if(this.currentIcon is IValidating) {
				IValidating(this.currentIcon).validate();
			}
			if(this.currentIcon !== null) {
				this.currentIcon.x = this._paddingLeft;
				this.textEditor.x = this.currentIcon.x + this.currentIcon.width + this._gap;
				if(this.promptTextRenderer !== null) {
					this.promptTextRenderer.x = this.currentIcon.x + this.currentIcon.width + this._gap;
				}
			} else {
				this.textEditor.x = this._paddingLeft;
				if(this.promptTextRenderer !== null) {
					this.promptTextRenderer.x = this._paddingLeft;
				}
			}
			this.textEditor.width = this.actualWidth - this._paddingRight - this.textEditor.x;
			if(this.promptTextRenderer !== null) {
				this.promptTextRenderer.width = this.actualWidth - this._paddingRight - this.promptTextRenderer.x;
			}
			var _local1:Boolean = this.textEditor is IMultilineTextEditor && Boolean(IMultilineTextEditor(this.textEditor).multiline);
			if(_local1 || this._verticalAlign === "justify") {
				this.textEditor.height = this.actualHeight - this._paddingTop - this._paddingBottom;
			} else {
				this.textEditor.height = NaN;
			}
			this.textEditor.validate();
			if(this.promptTextRenderer !== null) {
				this.promptTextRenderer.validate();
			}
			var _local3:* = Number(this.textEditor.height);
			var _local4:* = Number(this.textEditor.baseline);
			if(this.promptTextRenderer !== null) {
				_local5 = Number(this.promptTextRenderer.baseline);
				_local2 = Number(this.promptTextRenderer.height);
				if(_local5 > _local4) {
					_local4 = _local5;
				}
				if(_local2 > _local3) {
					_local3 = _local2;
				}
			}
			if(_local1) {
				this.textEditor.y = this._paddingTop + _local4 - this.textEditor.baseline;
				if(this.promptTextRenderer !== null) {
					this.promptTextRenderer.y = this._paddingTop + _local4 - _local5;
					this.promptTextRenderer.height = this.actualHeight - this.promptTextRenderer.y - this._paddingBottom;
				}
				if(this.currentIcon !== null) {
					this.currentIcon.y = this._paddingTop;
				}
			} else {
				switch(this._verticalAlign) {
					case "justify":
						this.textEditor.y = this._paddingTop + _local4 - this.textEditor.baseline;
						if(this.promptTextRenderer) {
							this.promptTextRenderer.y = this._paddingTop + _local4 - _local5;
							this.promptTextRenderer.height = this.actualHeight - this.promptTextRenderer.y - this._paddingBottom;
						}
						if(this.currentIcon) {
							this.currentIcon.y = this._paddingTop;
						}
						break;
					case "top":
						this.textEditor.y = this._paddingTop + _local4 - this.textEditor.baseline;
						if(this.promptTextRenderer) {
							this.promptTextRenderer.y = this._paddingTop + _local4 - _local5;
						}
						if(this.currentIcon) {
							this.currentIcon.y = this._paddingTop;
						}
						break;
					case "bottom":
						this.textEditor.y = this.actualHeight - this._paddingBottom - _local3 + _local4 - this.textEditor.baseline;
						if(this.promptTextRenderer) {
							this.promptTextRenderer.y = this.actualHeight - this._paddingBottom - _local3 + _local4 - _local5;
						}
						if(this.currentIcon) {
							this.currentIcon.y = this.actualHeight - this._paddingBottom - this.currentIcon.height;
						}
						break;
					default:
						this.textEditor.y = _local4 - this.textEditor.baseline + this._paddingTop + Math.round((this.actualHeight - this._paddingTop - this._paddingBottom - _local3) / 2);
						if(this.promptTextRenderer) {
							this.promptTextRenderer.y = _local4 - _local5 + this._paddingTop + Math.round((this.actualHeight - this._paddingTop - this._paddingBottom - _local3) / 2);
						}
						if(this.currentIcon) {
							this.currentIcon.y = this._paddingTop + Math.round((this.actualHeight - this._paddingTop - this._paddingBottom - this.currentIcon.height) / 2);
						}
				}
			}
		}
		
		protected function setFocusOnTextEditorWithTouch(touch:Touch) : void {
			if(!this.isFocusEnabled) {
				return;
			}
			touch.getLocation(this.stage,HELPER_POINT);
			var _local2:Boolean = this.contains(this.stage.hitTest(HELPER_POINT));
			if(_local2 && !this._textEditorHasFocus) {
				this.textEditor.globalToLocal(HELPER_POINT,HELPER_POINT);
				this._isWaitingToSetFocus = false;
				this.textEditor.setFocus(HELPER_POINT);
			}
		}
		
		protected function refreshState() : void {
			if(this._isEnabled) {
				if(this._textEditorHasFocus || this._hasFocus) {
					this.changeState("focused");
				} else if(this._errorString !== null) {
					this.changeState("error");
				} else {
					this.changeState("enabled");
				}
			} else {
				this.changeState("disabled");
			}
		}
		
		protected function childProperties_onChange(proxy:PropertyProxy, name:Object) : void {
			this.invalidate("styles");
		}
		
		protected function textInput_removedFromStageHandler(event:Event) : void {
			if(!this._focusManager && this._textEditorHasFocus) {
				this.clearFocus();
			}
			this._textEditorHasFocus = false;
			this._isWaitingToSetFocus = false;
			this._touchPointID = -1;
			if(Mouse.supportsNativeCursor && this._oldMouseCursor) {
				Mouse.cursor = this._oldMouseCursor;
				this._oldMouseCursor = null;
			}
		}
		
		protected function textInput_touchHandler(event:TouchEvent) : void {
			var _local3:Touch = null;
			var _local2:Boolean = false;
			if(!this._isEnabled) {
				this._touchPointID = -1;
				return;
			}
			if(this._touchPointID >= 0) {
				_local3 = event.getTouch(this,"ended",this._touchPointID);
				if(!_local3) {
					return;
				}
				_local3.getLocation(this.stage,HELPER_POINT);
				_local2 = this.contains(this.stage.hitTest(HELPER_POINT));
				if(!_local2) {
					if(Mouse.supportsNativeCursor && this._oldMouseCursor) {
						Mouse.cursor = this._oldMouseCursor;
						this._oldMouseCursor = null;
					}
				}
				this._touchPointID = -1;
				if(this.textEditor.setTouchFocusOnEndedPhase) {
					this.setFocusOnTextEditorWithTouch(_local3);
				}
			} else {
				_local3 = event.getTouch(this,"began");
				if(_local3) {
					this._touchPointID = _local3.id;
					if(!this.textEditor.setTouchFocusOnEndedPhase) {
						this.setFocusOnTextEditorWithTouch(_local3);
					}
					return;
				}
				_local3 = event.getTouch(this,"hover");
				if(_local3) {
					if(Mouse.supportsNativeCursor && !this._oldMouseCursor) {
						this._oldMouseCursor = Mouse.cursor;
						Mouse.cursor = "ibeam";
					}
					return;
				}
				if(Mouse.supportsNativeCursor && this._oldMouseCursor) {
					Mouse.cursor = this._oldMouseCursor;
					this._oldMouseCursor = null;
				}
			}
		}
		
		override protected function focusInHandler(event:Event) : void {
			if(!this._focusManager) {
				return;
			}
			super.focusInHandler(event);
			this.refreshState();
			this.setFocus();
		}
		
		override protected function focusOutHandler(event:Event) : void {
			if(!this._focusManager) {
				return;
			}
			super.focusOutHandler(event);
			this.refreshState();
			this.textEditor.clearFocus();
		}
		
		protected function textEditor_changeHandler(event:Event) : void {
			if(this._ignoreTextChanges) {
				return;
			}
			this.text = this.textEditor.text;
		}
		
		protected function textEditor_enterHandler(event:Event) : void {
			this.dispatchEventWith("enter");
		}
		
		protected function textEditor_focusInHandler(event:Event) : void {
			if(!this.visible) {
				this.textEditor.clearFocus();
				return;
			}
			this._textEditorHasFocus = true;
			this.refreshState();
			if(this._errorString !== null && this._errorString.length > 0) {
				this.createErrorCallout();
			}
			if(this._focusManager !== null && this.isFocusEnabled) {
				if(this._focusManager.focus !== this) {
					this._focusManager.focus = this;
				}
			} else {
				this.dispatchEventWith("focusIn");
			}
		}
		
		protected function textEditor_focusOutHandler(event:Event) : void {
			this._textEditorHasFocus = false;
			this.refreshState();
			if(this.callout) {
				this.callout.removeFromParent(true);
				this.callout = null;
			}
			if(this._focusManager !== null && this.isFocusEnabled) {
				if(this._focusManager.focus === this) {
					this._focusManager.focus = null;
				}
			} else {
				this.dispatchEventWith("focusOut");
			}
		}
	}
}

