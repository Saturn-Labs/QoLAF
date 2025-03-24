package feathers.controls {
	import feathers.controls.text.ITextEditorViewPort;
	import feathers.controls.text.TextFieldTextEditorViewPort;
	import feathers.core.IAdvancedNativeFocusOwner;
	import feathers.core.IFeathersControl;
	import feathers.core.IMeasureDisplayObject;
	import feathers.core.INativeFocusOwner;
	import feathers.core.IStateContext;
	import feathers.core.IStateObserver;
	import feathers.core.PopUpManager;
	import feathers.core.PropertyProxy;
	import feathers.skins.IStyleProvider;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	public class TextArea extends Scroller implements IAdvancedNativeFocusOwner, IStateContext {
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
		
		public static const STATE_ENABLED:String = "enabled";
		
		public static const STATE_DISABLED:String = "disabled";
		
		public static const STATE_FOCUSED:String = "focused";
		
		public static const DEFAULT_CHILD_STYLE_NAME_TEXT_EDITOR:String = "feathers-text-area-text-editor";
		
		public static const DEFAULT_CHILD_STYLE_NAME_ERROR_CALLOUT:String = "feathers-text-input-error-callout";
		
		protected static const INVALIDATION_FLAG_ERROR_CALLOUT_FACTORY:String = "errorCalloutFactory";
		
		public static var globalStyleProvider:IStyleProvider;
		
		private static const HELPER_POINT:Point = new Point();
		
		protected var textEditorViewPort:ITextEditorViewPort;
		
		protected var callout:TextCallout;
		
		protected var textEditorStyleName:String = "feathers-text-area-text-editor";
		
		protected var errorCalloutStyleName:String = "feathers-text-input-error-callout";
		
		protected var _textEditorHasFocus:Boolean = false;
		
		protected var _isWaitingToSetFocus:Boolean = false;
		
		protected var _pendingSelectionStartIndex:int = -1;
		
		protected var _pendingSelectionEndIndex:int = -1;
		
		protected var _textAreaTouchPointID:int = -1;
		
		protected var _oldMouseCursor:String = null;
		
		protected var _ignoreTextChanges:Boolean = false;
		
		protected var _currentState:String = "enabled";
		
		protected var _text:String = "";
		
		protected var _maxChars:int = 0;
		
		protected var _restrict:String;
		
		protected var _isEditable:Boolean = true;
		
		protected var _errorString:String = null;
		
		protected var _stateToSkin:Object = {};
		
		protected var _stateToSkinFunction:Function;
		
		protected var _textEditorFactory:Function;
		
		protected var _customTextEditorStyleName:String;
		
		protected var _textEditorProperties:PropertyProxy;
		
		protected var _customErrorCalloutStyleName:String;
		
		public function TextArea() {
			super();
			this._measureViewPort = false;
			this.addEventListener("touch",textArea_touchHandler);
			this.addEventListener("removedFromStage",textArea_removedFromStageHandler);
		}
		
		public function get nativeFocus() : Object {
			if(this.textEditorViewPort is INativeFocusOwner) {
				return INativeFocusOwner(this.textEditorViewPort).nativeFocus;
			}
			return null;
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return TextArea.globalStyleProvider;
		}
		
		override public function get isFocusEnabled() : Boolean {
			if(this._isEditable) {
				return this._isEnabled && this._isFocusEnabled;
			}
			return super.isFocusEnabled;
		}
		
		public function get hasFocus() : Boolean {
			if(!this._focusManager) {
				return this._textEditorHasFocus;
			}
			return this._hasFocus;
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
		
		override public function get backgroundDisabledSkin() : DisplayObject {
			return this.getSkinForState("disabled");
		}
		
		override public function set backgroundDisabledSkin(value:DisplayObject) : void {
			this.setSkinForState("disabled",value);
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
		
		override public function showFocus() : void {
			if(!this._focusManager || this._focusManager.focus != this) {
				return;
			}
			this.selectRange(0,this._text.length);
			super.showFocus();
		}
		
		public function setFocus() : void {
			if(this._textEditorHasFocus) {
				return;
			}
			if(this.textEditorViewPort) {
				this._isWaitingToSetFocus = false;
				this.textEditorViewPort.setFocus();
			} else {
				this._isWaitingToSetFocus = true;
				this.invalidate("selected");
			}
		}
		
		public function clearFocus() : void {
			this._isWaitingToSetFocus = false;
			if(!this.textEditorViewPort || !this._textEditorHasFocus) {
				return;
			}
			this.textEditorViewPort.clearFocus();
		}
		
		public function selectRange(startIndex:int, endIndex:int = -1) : void {
			if(endIndex < 0) {
				endIndex = startIndex;
			}
			if(startIndex < 0) {
				throw new RangeError("Expected start index greater than or equal to 0. Received " + startIndex + ".");
			}
			if(endIndex > this._text.length) {
				throw new RangeError("Expected start index less than " + this._text.length + ". Received " + endIndex + ".");
			}
			if(this.textEditorViewPort) {
				this._pendingSelectionStartIndex = -1;
				this._pendingSelectionEndIndex = -1;
				this.textEditorViewPort.selectRange(startIndex,endIndex);
			} else {
				this._pendingSelectionStartIndex = startIndex;
				this._pendingSelectionEndIndex = endIndex;
				this.invalidate("selected");
			}
		}
		
		override public function dispose() : void {
			var _local1:DisplayObject = null;
			for(var _local2 in this._stateToSkin) {
				_local1 = this._stateToSkin[_local2] as DisplayObject;
				if(_local1 !== null && _local1.parent !== this) {
					_local1.dispose();
				}
			}
			super.dispose();
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
		
		override protected function draw() : void {
			var _local1:Boolean = false;
			var _local5:Boolean = this.isInvalid("textEditor");
			var _local3:Boolean = this.isInvalid("data");
			var _local4:Boolean = this.isInvalid("styles");
			var _local2:Boolean = this.isInvalid("state");
			if(_local5) {
				this.createTextEditor();
			}
			if(_local5 || _local4) {
				this.refreshTextEditorProperties();
			}
			if(_local5 || _local3) {
				_local1 = this._ignoreTextChanges;
				this._ignoreTextChanges = true;
				this.textEditorViewPort.text = this._text;
				this._ignoreTextChanges = _local1;
			}
			if(_local5 || _local2) {
				this.textEditorViewPort.isEnabled = this._isEnabled;
				if(!this._isEnabled && Mouse.supportsNativeCursor && this._oldMouseCursor) {
					Mouse.cursor = this._oldMouseCursor;
					this._oldMouseCursor = null;
				}
			}
			super.draw();
			this.doPendingActions();
		}
		
		protected function createTextEditor() : void {
			if(this.textEditorViewPort) {
				this.textEditorViewPort.removeEventListener("change",textEditor_changeHandler);
				this.textEditorViewPort.removeEventListener("focusIn",textEditor_focusInHandler);
				this.textEditorViewPort.removeEventListener("focusOut",textEditor_focusOutHandler);
				this.textEditorViewPort = null;
			}
			if(this._textEditorFactory != null) {
				this.textEditorViewPort = ITextEditorViewPort(this._textEditorFactory());
			} else {
				this.textEditorViewPort = new TextFieldTextEditorViewPort();
			}
			var _local1:String = this._customTextEditorStyleName != null ? this._customTextEditorStyleName : this.textEditorStyleName;
			this.textEditorViewPort.styleNameList.add(_local1);
			if(this.textEditorViewPort is IStateObserver) {
				IStateObserver(this.textEditorViewPort).stateContext = this;
			}
			this.textEditorViewPort.addEventListener("change",textEditor_changeHandler);
			this.textEditorViewPort.addEventListener("focusIn",textEditor_focusInHandler);
			this.textEditorViewPort.addEventListener("focusOut",textEditor_focusOutHandler);
			var _local2:ITextEditorViewPort = ITextEditorViewPort(this._viewPort);
			this.viewPort = this.textEditorViewPort;
			if(_local2) {
				_local2.dispose();
			}
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
			var _local2:int = 0;
			if(this._isWaitingToSetFocus || this._focusManager && this._focusManager.focus == this) {
				this._isWaitingToSetFocus = false;
				if(!this._textEditorHasFocus) {
					this.textEditorViewPort.setFocus();
				}
			}
			if(this._pendingSelectionStartIndex >= 0) {
				_local1 = this._pendingSelectionStartIndex;
				_local2 = this._pendingSelectionEndIndex;
				this._pendingSelectionStartIndex = -1;
				this._pendingSelectionEndIndex = -1;
				this.selectRange(_local1,_local2);
			}
		}
		
		protected function refreshTextEditorProperties() : void {
			var _local2:Object = null;
			this.textEditorViewPort.maxChars = this._maxChars;
			this.textEditorViewPort.restrict = this._restrict;
			this.textEditorViewPort.isEditable = this._isEditable;
			for(var _local1 in this._textEditorProperties) {
				_local2 = this._textEditorProperties[_local1];
				this.textEditorViewPort[_local1] = _local2;
			}
		}
		
		override protected function refreshBackgroundSkin() : void {
			var _local2:IMeasureDisplayObject = null;
			var _local1:DisplayObject = this.currentBackgroundSkin;
			this.currentBackgroundSkin = this.getCurrentSkin();
			switch(_local1) {
				default:
					if(_local1 is IStateObserver) {
						IStateObserver(_local1).stateContext = null;
					}
					this.removeChild(_local1,false);
				case null:
					if(this.currentBackgroundSkin !== null) {
						if(this.currentBackgroundSkin is IStateObserver) {
							IStateObserver(this.currentBackgroundSkin).stateContext = this;
						}
						this.addChildAt(this.currentBackgroundSkin,0);
						if(this.currentBackgroundSkin is IFeathersControl) {
							IFeathersControl(this.currentBackgroundSkin).initializeNow();
						}
						if(this.currentBackgroundSkin is IMeasureDisplayObject) {
							_local2 = IMeasureDisplayObject(this.currentBackgroundSkin);
							this._explicitBackgroundWidth = _local2.explicitWidth;
							this._explicitBackgroundHeight = _local2.explicitHeight;
							this._explicitBackgroundMinWidth = _local2.explicitMinWidth;
							this._explicitBackgroundMinHeight = _local2.explicitMinHeight;
							break;
						}
						this._explicitBackgroundWidth = this.currentBackgroundSkin.width;
						this._explicitBackgroundHeight = this.currentBackgroundSkin.height;
						this._explicitBackgroundMinWidth = this._explicitBackgroundWidth;
						this._explicitBackgroundMinHeight = this._explicitBackgroundHeight;
					}
					break;
				case this.currentBackgroundSkin:
			}
		}
		
		protected function getCurrentSkin() : DisplayObject {
			if(this._stateToSkinFunction != null) {
				return DisplayObject(this._stateToSkinFunction(this,this._currentState,this.currentBackgroundSkin));
			}
			var _local1:DisplayObject = this._stateToSkin[this._currentState] as DisplayObject;
			if(_local1 !== null) {
				return _local1;
			}
			return this._backgroundSkin;
		}
		
		protected function refreshState() : void {
			if(this._isEnabled) {
				if(this._textEditorHasFocus) {
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
		
		protected function setFocusOnTextEditorWithTouch(touch:Touch) : void {
			if(!this.isFocusEnabled) {
				return;
			}
			touch.getLocation(this.stage,HELPER_POINT);
			var _local2:Boolean = this.contains(this.stage.hitTest(HELPER_POINT));
			if(!this._textEditorHasFocus && _local2) {
				this.globalToLocal(HELPER_POINT,HELPER_POINT);
				HELPER_POINT.x -= this._paddingLeft;
				HELPER_POINT.y -= this._paddingTop;
				this._isWaitingToSetFocus = false;
				this.textEditorViewPort.setFocus(HELPER_POINT);
			}
		}
		
		protected function textArea_touchHandler(event:TouchEvent) : void {
			var _local3:Touch = null;
			if(!this._isEnabled) {
				this._textAreaTouchPointID = -1;
				return;
			}
			var _local2:DisplayObject = DisplayObject(this.horizontalScrollBar);
			var _local4:DisplayObject = DisplayObject(this.verticalScrollBar);
			if(this._textAreaTouchPointID >= 0) {
				_local3 = event.getTouch(this,"ended",this._textAreaTouchPointID);
				if(!_local3 || _local3.isTouching(_local4) || _local3.isTouching(_local2)) {
					return;
				}
				this.removeEventListener("scroll",textArea_scrollHandler);
				this._textAreaTouchPointID = -1;
				if(this.textEditorViewPort.setTouchFocusOnEndedPhase) {
					this.setFocusOnTextEditorWithTouch(_local3);
				}
			} else {
				_local3 = event.getTouch(this,"began");
				if(_local3) {
					if(_local3.isTouching(_local4) || _local3.isTouching(_local2)) {
						return;
					}
					this._textAreaTouchPointID = _local3.id;
					if(!this.textEditorViewPort.setTouchFocusOnEndedPhase) {
						this.setFocusOnTextEditorWithTouch(_local3);
					}
					this.addEventListener("scroll",textArea_scrollHandler);
					return;
				}
				_local3 = event.getTouch(this,"hover");
				if(_local3) {
					if(_local3.isTouching(_local4) || _local3.isTouching(_local2)) {
						return;
					}
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
		
		protected function textArea_scrollHandler(event:Event) : void {
			this.removeEventListener("scroll",textArea_scrollHandler);
			this._textAreaTouchPointID = -1;
		}
		
		protected function textArea_removedFromStageHandler(event:Event) : void {
			if(!this._focusManager && this._textEditorHasFocus) {
				this.clearFocus();
			}
			this._isWaitingToSetFocus = false;
			this._textEditorHasFocus = false;
			this._textAreaTouchPointID = -1;
			this.removeEventListener("scroll",textArea_scrollHandler);
			if(Mouse.supportsNativeCursor && this._oldMouseCursor) {
				Mouse.cursor = this._oldMouseCursor;
				this._oldMouseCursor = null;
			}
		}
		
		override protected function focusInHandler(event:Event) : void {
			if(!this._focusManager) {
				return;
			}
			super.focusInHandler(event);
			this.setFocus();
		}
		
		override protected function focusOutHandler(event:Event) : void {
			if(!this._focusManager) {
				return;
			}
			super.focusOutHandler(event);
			this.textEditorViewPort.clearFocus();
			this.invalidate("state");
		}
		
		override protected function stage_keyDownHandler(event:KeyboardEvent) : void {
			if(this._isEditable) {
				return;
			}
			super.stage_keyDownHandler(event);
		}
		
		protected function textEditor_changeHandler(event:Event) : void {
			if(this._ignoreTextChanges) {
				return;
			}
			this.text = this.textEditorViewPort.text;
		}
		
		protected function textEditor_focusInHandler(event:Event) : void {
			this._textEditorHasFocus = true;
			this.refreshState();
			if(this._errorString !== null && this._errorString.length > 0) {
				this.createErrorCallout();
			}
			this._touchPointID = -1;
			this.invalidate("state");
			if(this._focusManager && this.isFocusEnabled && this._focusManager.focus !== this) {
				this._focusManager.focus = this;
			} else if(!this._focusManager) {
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
			this.invalidate("state");
			if(this._focusManager && this._focusManager.focus === this) {
				this._focusManager.focus = null;
			} else if(!this._focusManager) {
				this.dispatchEventWith("focusOut");
			}
		}
	}
}

