package feathers.controls {
	import feathers.core.FeathersControl;
	import feathers.core.IAdvancedNativeFocusOwner;
	import feathers.core.ITextBaselineControl;
	import feathers.core.PropertyProxy;
	import feathers.events.ExclusiveTouch;
	import feathers.skins.IStyleProvider;
	import feathers.utils.math.clamp;
	import feathers.utils.math.roundToNearest;
	import feathers.utils.math.roundToPrecision;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	public class NumericStepper extends FeathersControl implements IRange, IAdvancedNativeFocusOwner, ITextBaselineControl {
		protected static const INVALIDATION_FLAG_DECREMENT_BUTTON_FACTORY:String = "decrementButtonFactory";
		
		protected static const INVALIDATION_FLAG_INCREMENT_BUTTON_FACTORY:String = "incrementButtonFactory";
		
		protected static const INVALIDATION_FLAG_TEXT_INPUT_FACTORY:String = "textInputFactory";
		
		public static const DEFAULT_CHILD_STYLE_NAME_DECREMENT_BUTTON:String = "feathers-numeric-stepper-decrement-button";
		
		public static const DEFAULT_CHILD_STYLE_NAME_INCREMENT_BUTTON:String = "feathers-numeric-stepper-increment-button";
		
		public static const DEFAULT_CHILD_STYLE_NAME_TEXT_INPUT:String = "feathers-numeric-stepper-text-input";
		
		public static const BUTTON_LAYOUT_MODE_SPLIT_HORIZONTAL:String = "splitHorizontal";
		
		public static const BUTTON_LAYOUT_MODE_SPLIT_VERTICAL:String = "splitVertical";
		
		public static const BUTTON_LAYOUT_MODE_RIGHT_SIDE_VERTICAL:String = "rightSideVertical";
		
		public static var globalStyleProvider:IStyleProvider;
		
		protected var decrementButtonStyleName:String = "feathers-numeric-stepper-decrement-button";
		
		protected var incrementButtonStyleName:String = "feathers-numeric-stepper-increment-button";
		
		protected var textInputStyleName:String = "feathers-numeric-stepper-text-input";
		
		protected var decrementButton:Button;
		
		protected var incrementButton:Button;
		
		protected var textInput:TextInput;
		
		protected var textInputExplicitWidth:Number;
		
		protected var textInputExplicitHeight:Number;
		
		protected var textInputExplicitMinWidth:Number;
		
		protected var textInputExplicitMinHeight:Number;
		
		protected var touchPointID:int = -1;
		
		protected var _textInputHasFocus:Boolean = false;
		
		protected var _value:Number = 0;
		
		protected var _minimum:Number = 0;
		
		protected var _maximum:Number = 0;
		
		protected var _step:Number = 0;
		
		protected var _valueFormatFunction:Function;
		
		protected var _valueParseFunction:Function;
		
		protected var currentRepeatAction:Function;
		
		protected var _repeatTimer:Timer;
		
		protected var _repeatDelay:Number = 0.05;
		
		protected var _buttonLayoutMode:String = "splitHorizontal";
		
		protected var _buttonGap:Number = 0;
		
		protected var _textInputGap:Number = 0;
		
		protected var _decrementButtonFactory:Function;
		
		protected var _customDecrementButtonStyleName:String;
		
		protected var _decrementButtonProperties:PropertyProxy;
		
		protected var _decrementButtonLabel:String = null;
		
		protected var _incrementButtonFactory:Function;
		
		protected var _customIncrementButtonStyleName:String;
		
		protected var _incrementButtonProperties:PropertyProxy;
		
		protected var _incrementButtonLabel:String = null;
		
		protected var _textInputFactory:Function;
		
		protected var _customTextInputStyleName:String;
		
		protected var _textInputProperties:PropertyProxy;
		
		public function NumericStepper() {
			super();
			this.addEventListener("removedFromStage",numericStepper_removedFromStageHandler);
		}
		
		protected static function defaultDecrementButtonFactory() : Button {
			return new Button();
		}
		
		protected static function defaultIncrementButtonFactory() : Button {
			return new Button();
		}
		
		protected static function defaultTextInputFactory() : TextInput {
			return new TextInput();
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return NumericStepper.globalStyleProvider;
		}
		
		public function get nativeFocus() : Object {
			if(this.textInput !== null) {
				return this.textInput.nativeFocus;
			}
			return null;
		}
		
		public function get value() : Number {
			return this._value;
		}
		
		public function set value(newValue:Number) : void {
			if(this._step != 0 && newValue != this._maximum && newValue != this._minimum) {
				newValue = roundToPrecision(roundToNearest(newValue - this._minimum,this._step) + this._minimum,10);
			}
			newValue = clamp(newValue,this._minimum,this._maximum);
			if(this._value == newValue) {
				return;
			}
			this._value = newValue;
			this.invalidate("data");
			this.dispatchEventWith("change");
		}
		
		public function get minimum() : Number {
			return this._minimum;
		}
		
		public function set minimum(value:Number) : void {
			if(this._minimum == value) {
				return;
			}
			this._minimum = value;
			this.invalidate("data");
		}
		
		public function get maximum() : Number {
			return this._maximum;
		}
		
		public function set maximum(value:Number) : void {
			if(this._maximum == value) {
				return;
			}
			this._maximum = value;
			this.invalidate("data");
		}
		
		public function get step() : Number {
			return this._step;
		}
		
		public function set step(value:Number) : void {
			if(this._step == value) {
				return;
			}
			this._step = value;
		}
		
		public function get valueFormatFunction() : Function {
			return this._valueFormatFunction;
		}
		
		public function set valueFormatFunction(value:Function) : void {
			if(this._valueFormatFunction == value) {
				return;
			}
			this._valueFormatFunction = value;
			this.invalidate("styles");
		}
		
		public function get valueParseFunction() : Function {
			return this._valueParseFunction;
		}
		
		public function set valueParseFunction(value:Function) : void {
			this._valueParseFunction = value;
		}
		
		public function get repeatDelay() : Number {
			return this._repeatDelay;
		}
		
		public function set repeatDelay(value:Number) : void {
			if(this._repeatDelay == value) {
				return;
			}
			this._repeatDelay = value;
			this.invalidate("styles");
		}
		
		public function get buttonLayoutMode() : String {
			return this._buttonLayoutMode;
		}
		
		public function set buttonLayoutMode(value:String) : void {
			if(this._buttonLayoutMode == value) {
				return;
			}
			this._buttonLayoutMode = value;
			this.invalidate("styles");
		}
		
		public function get buttonGap() : Number {
			return this._buttonGap;
		}
		
		public function set buttonGap(value:Number) : void {
			if(this._buttonGap == value) {
				return;
			}
			this._buttonGap = value;
			this.invalidate("styles");
		}
		
		public function get textInputGap() : Number {
			return this._textInputGap;
		}
		
		public function set textInputGap(value:Number) : void {
			if(this._textInputGap == value) {
				return;
			}
			this._textInputGap = value;
			this.invalidate("styles");
		}
		
		public function get decrementButtonFactory() : Function {
			return this._decrementButtonFactory;
		}
		
		public function set decrementButtonFactory(value:Function) : void {
			if(this._decrementButtonFactory == value) {
				return;
			}
			this._decrementButtonFactory = value;
			this.invalidate("decrementButtonFactory");
		}
		
		public function get customDecrementButtonStyleName() : String {
			return this._customDecrementButtonStyleName;
		}
		
		public function set customDecrementButtonStyleName(value:String) : void {
			if(this._customDecrementButtonStyleName == value) {
				return;
			}
			this._customDecrementButtonStyleName = value;
			this.invalidate("decrementButtonFactory");
		}
		
		public function get decrementButtonProperties() : Object {
			if(!this._decrementButtonProperties) {
				this._decrementButtonProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._decrementButtonProperties;
		}
		
		public function set decrementButtonProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._decrementButtonProperties == value) {
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
			if(this._decrementButtonProperties) {
				this._decrementButtonProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._decrementButtonProperties = PropertyProxy(value);
			if(this._decrementButtonProperties) {
				this._decrementButtonProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get decrementButtonLabel() : String {
			return this._decrementButtonLabel;
		}
		
		public function set decrementButtonLabel(value:String) : void {
			if(this._decrementButtonLabel == value) {
				return;
			}
			this._decrementButtonLabel = value;
			this.invalidate("styles");
		}
		
		public function get incrementButtonFactory() : Function {
			return this._incrementButtonFactory;
		}
		
		public function set incrementButtonFactory(value:Function) : void {
			if(this._incrementButtonFactory == value) {
				return;
			}
			this._incrementButtonFactory = value;
			this.invalidate("incrementButtonFactory");
		}
		
		public function get customIncrementButtonStyleName() : String {
			return this._customIncrementButtonStyleName;
		}
		
		public function set customIncrementButtonStyleName(value:String) : void {
			if(this._customIncrementButtonStyleName == value) {
				return;
			}
			this._customIncrementButtonStyleName = value;
			this.invalidate("incrementButtonFactory");
		}
		
		public function get incrementButtonProperties() : Object {
			if(!this._incrementButtonProperties) {
				this._incrementButtonProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._incrementButtonProperties;
		}
		
		public function set incrementButtonProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._incrementButtonProperties == value) {
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
			if(this._incrementButtonProperties) {
				this._incrementButtonProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._incrementButtonProperties = PropertyProxy(value);
			if(this._incrementButtonProperties) {
				this._incrementButtonProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get incrementButtonLabel() : String {
			return this._incrementButtonLabel;
		}
		
		public function set incrementButtonLabel(value:String) : void {
			if(this._incrementButtonLabel == value) {
				return;
			}
			this._incrementButtonLabel = value;
			this.invalidate("styles");
		}
		
		public function get textInputFactory() : Function {
			return this._textInputFactory;
		}
		
		public function set textInputFactory(value:Function) : void {
			if(this._textInputFactory == value) {
				return;
			}
			this._textInputFactory = value;
			this.invalidate("textInputFactory");
		}
		
		public function get customTextInputStyleName() : String {
			return this._customTextInputStyleName;
		}
		
		public function set customTextInputStyleName(value:String) : void {
			if(this._customTextInputStyleName == value) {
				return;
			}
			this._customTextInputStyleName = value;
			this.invalidate("textInputFactory");
		}
		
		public function get textInputProperties() : Object {
			if(!this._textInputProperties) {
				this._textInputProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._textInputProperties;
		}
		
		public function set textInputProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._textInputProperties == value) {
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
			if(this._textInputProperties) {
				this._textInputProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._textInputProperties = PropertyProxy(value);
			if(this._textInputProperties) {
				this._textInputProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get baseline() : Number {
			if(!this.textInput) {
				return this.scaledActualHeight;
			}
			return this.scaleY * (this.textInput.y + this.textInput.baseline);
		}
		
		public function get hasFocus() : Boolean {
			return this._hasFocus;
		}
		
		public function setFocus() : void {
			if(this.textInput === null) {
				return;
			}
			this.textInput.setFocus();
		}
		
		override protected function draw() : void {
			var _local6:Boolean = this.isInvalid("data");
			var _local7:Boolean = this.isInvalid("styles");
			var _local2:Boolean = this.isInvalid("size");
			var _local4:Boolean = this.isInvalid("state");
			var _local5:Boolean = this.isInvalid("decrementButtonFactory");
			var _local1:Boolean = this.isInvalid("incrementButtonFactory");
			var _local8:Boolean = this.isInvalid("textInputFactory");
			var _local3:Boolean = this.isInvalid("focus");
			if(_local5) {
				this.createDecrementButton();
			}
			if(_local1) {
				this.createIncrementButton();
			}
			if(_local8) {
				this.createTextInput();
			}
			if(_local5 || _local7) {
				this.refreshDecrementButtonStyles();
			}
			if(_local1 || _local7) {
				this.refreshIncrementButtonStyles();
			}
			if(_local8 || _local7) {
				this.refreshTextInputStyles();
			}
			if(_local8 || _local6) {
				this.refreshTypicalText();
				this.refreshDisplayedText();
			}
			if(_local5 || _local4) {
				this.decrementButton.isEnabled = this._isEnabled;
			}
			if(_local1 || _local4) {
				this.incrementButton.isEnabled = this._isEnabled;
			}
			if(_local8 || _local4) {
				this.textInput.isEnabled = this._isEnabled;
			}
			_local2 = this.autoSizeIfNeeded() || _local2;
			this.layoutChildren();
			if(_local2 || _local3) {
				this.refreshFocusIndicator();
			}
		}
		
		protected function autoSizeIfNeeded() : Boolean {
			var _local24:* = NaN;
			var _local11:* = NaN;
			var _local4:* = this._explicitWidth !== this._explicitWidth;
			var _local19:* = this._explicitHeight !== this._explicitHeight;
			var _local14:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local22:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local4 && !_local19 && !_local14 && !_local22) {
				return false;
			}
			var _local3:* = this._explicitWidth;
			var _local6:* = this._explicitHeight;
			var _local12:* = this._explicitMinWidth;
			var _local18:* = this._explicitMinHeight;
			this.decrementButton.validate();
			this.incrementButton.validate();
			var _local20:Number = this.decrementButton.width;
			var _local15:Number = this.decrementButton.height;
			var _local9:Number = this.decrementButton.minWidth;
			var _local23:Number = this.decrementButton.minHeight;
			var _local5:Number = this.incrementButton.width;
			var _local10:Number = this.incrementButton.height;
			var _local16:Number = this.incrementButton.minWidth;
			var _local7:Number = this.incrementButton.minHeight;
			var _local13:Number = this.textInputExplicitWidth;
			var _local1:Number = this.textInputExplicitHeight;
			var _local21:Number = this.textInputExplicitMinWidth;
			var _local8:Number = this.textInputExplicitMinHeight;
			var _local17:Number = Infinity;
			var _local2:Number = Infinity;
			if(this._buttonLayoutMode === "rightSideVertical") {
				_local24 = _local20;
				if(_local5 > _local24) {
					_local24 = _local5;
				}
				_local11 = _local9;
				if(_local16 > _local11) {
					_local11 = _local16;
				}
				if(!_local4) {
					_local13 = this._explicitWidth - _local24 - this._textInputGap;
				}
				if(!_local19) {
					_local1 = this._explicitHeight;
				}
				if(!_local14) {
					_local21 = this._explicitMinWidth - _local11 - this._textInputGap;
					if(this.textInputExplicitMinWidth > _local21) {
						_local21 = this.textInputExplicitMinWidth;
					}
				}
				if(!_local22) {
					_local8 = this._explicitMinHeight;
					if(this.textInputExplicitMinHeight > _local8) {
						_local8 = this.textInputExplicitMinHeight;
					}
				}
				_local17 = this._explicitMaxWidth - _local24 - this._textInputGap;
			} else if(this._buttonLayoutMode === "splitVertical") {
				if(!_local4) {
					_local13 = this._explicitWidth;
				}
				if(!_local19) {
					_local1 = this._explicitHeight - _local15 - _local10;
				}
				if(!_local14) {
					_local21 = this._explicitMinWidth;
					if(this.textInputExplicitMinWidth > _local21) {
						_local21 = this.textInputExplicitMinWidth;
					}
				}
				if(!_local22) {
					_local8 = this._explicitMinHeight - _local23 - _local7;
					if(this.textInputExplicitMinHeight > _local8) {
						_local8 = this.textInputExplicitMinHeight;
					}
				}
				_local2 = this._explicitMaxHeight - _local15 - _local10;
			} else {
				if(!_local4) {
					_local13 = this._explicitWidth - _local20 - _local5;
				}
				if(!_local19) {
					_local1 = this._explicitHeight;
				}
				if(!_local14) {
					_local21 = this._explicitMinWidth - _local9 - _local16;
					if(_local21 < this.textInputExplicitMinWidth) {
						_local21 = this.textInputExplicitMinWidth;
					}
				}
				if(!_local22) {
					_local8 = this._explicitMinHeight;
					if(this.textInputExplicitMinHeight > _local8) {
						_local8 = this.textInputExplicitMinHeight;
					}
				}
				_local17 = this._explicitMaxWidth - _local20 - _local5;
			}
			if(_local13 < 0) {
				_local13 = 0;
			}
			if(_local1 < 0) {
				_local1 = 0;
			}
			if(_local21 < 0) {
				_local21 = 0;
			}
			if(_local8 < 0) {
				_local8 = 0;
			}
			this.textInput.width = _local13;
			this.textInput.height = _local1;
			this.textInput.minWidth = _local21;
			this.textInput.minHeight = _local8;
			this.textInput.maxWidth = _local17;
			this.textInput.maxHeight = _local2;
			this.textInput.validate();
			if(this._buttonLayoutMode === "rightSideVertical") {
				if(_local4) {
					_local3 = this.textInput.width + _local24 + this._textInputGap;
				}
				if(_local19) {
					_local6 = _local15 + this._buttonGap + _local10;
					if(this.textInput.height > _local6) {
						_local6 = this.textInput.height;
					}
				}
				if(_local14) {
					_local12 = this.textInput.minWidth + _local11 + this._textInputGap;
				}
				if(_local22) {
					_local18 = _local23 + this._buttonGap + _local7;
					if(this.textInput.minHeight > _local18) {
						_local18 = this.textInput.minHeight;
					}
				}
			} else if(this._buttonLayoutMode === "splitVertical") {
				if(_local4) {
					_local3 = this.textInput.width;
					if(_local20 > _local3) {
						_local3 = _local20;
					}
					if(_local5 > _local3) {
						_local3 = _local5;
					}
				}
				if(_local19) {
					_local6 = _local15 + this.textInput.height + _local10 + 2 * this._textInputGap;
				}
				if(_local14) {
					_local12 = this.textInput.minWidth;
					if(_local9 > _local12) {
						_local12 = _local9;
					}
					if(_local16 > _local12) {
						_local12 = _local16;
					}
				}
				if(_local22) {
					_local18 = _local23 + this.textInput.minHeight + _local7 + 2 * this._textInputGap;
				}
			} else {
				if(_local4) {
					_local3 = _local20 + this.textInput.width + _local5 + 2 * this._textInputGap;
				}
				if(_local19) {
					_local6 = this.textInput.height;
					if(_local15 > _local6) {
						_local6 = _local15;
					}
					if(_local10 > _local6) {
						_local6 = _local10;
					}
				}
				if(_local14) {
					_local12 = _local9 + this.textInput.minWidth + _local16 + 2 * this._textInputGap;
				}
				if(_local22) {
					_local18 = this.textInput.minHeight;
					if(_local23 > _local18) {
						_local18 = _local23;
					}
					if(_local7 > _local18) {
						_local18 = _local7;
					}
				}
			}
			return this.saveMeasurements(_local3,_local6,_local12,_local18);
		}
		
		protected function decrement() : void {
			this.value = this._value - this._step;
			this.validate();
			this.textInput.selectRange(0,this.textInput.text.length);
		}
		
		protected function increment() : void {
			this.value = this._value + this._step;
			this.validate();
			this.textInput.selectRange(0,this.textInput.text.length);
		}
		
		protected function toMinimum() : void {
			this.value = this._minimum;
			this.validate();
			this.textInput.selectRange(0,this.textInput.text.length);
		}
		
		protected function toMaximum() : void {
			this.value = this._maximum;
			this.validate();
			this.textInput.selectRange(0,this.textInput.text.length);
		}
		
		protected function createDecrementButton() : void {
			if(this.decrementButton) {
				this.decrementButton.removeFromParent(true);
				this.decrementButton = null;
			}
			var _local1:Function = this._decrementButtonFactory != null ? this._decrementButtonFactory : defaultDecrementButtonFactory;
			var _local2:String = this._customDecrementButtonStyleName != null ? this._customDecrementButtonStyleName : this.decrementButtonStyleName;
			this.decrementButton = Button(_local1());
			this.decrementButton.styleNameList.add(_local2);
			this.decrementButton.addEventListener("touch",decrementButton_touchHandler);
			this.addChild(this.decrementButton);
		}
		
		protected function createIncrementButton() : void {
			if(this.incrementButton) {
				this.incrementButton.removeFromParent(true);
				this.incrementButton = null;
			}
			var _local1:Function = this._incrementButtonFactory != null ? this._incrementButtonFactory : defaultIncrementButtonFactory;
			var _local2:String = this._customIncrementButtonStyleName != null ? this._customIncrementButtonStyleName : this.incrementButtonStyleName;
			this.incrementButton = Button(_local1());
			this.incrementButton.styleNameList.add(_local2);
			this.incrementButton.addEventListener("touch",incrementButton_touchHandler);
			this.addChild(this.incrementButton);
		}
		
		protected function createTextInput() : void {
			if(this.textInput) {
				this.textInput.removeFromParent(true);
				this.textInput = null;
			}
			var _local1:Function = this._textInputFactory != null ? this._textInputFactory : defaultTextInputFactory;
			var _local2:String = this._customTextInputStyleName != null ? this._customTextInputStyleName : this.textInputStyleName;
			this.textInput = TextInput(_local1());
			this.textInput.styleNameList.add(_local2);
			this.textInput.addEventListener("enter",textInput_enterHandler);
			this.textInput.addEventListener("focusIn",textInput_focusInHandler);
			this.textInput.addEventListener("focusOut",textInput_focusOutHandler);
			this.textInput.isFocusEnabled = !this._focusManager;
			this.addChild(this.textInput);
			this.textInput.initializeNow();
			this.textInputExplicitWidth = this.textInput.explicitWidth;
			this.textInputExplicitHeight = this.textInput.explicitHeight;
			this.textInputExplicitMinWidth = this.textInput.explicitMinWidth;
			this.textInputExplicitMinHeight = this.textInput.explicitMinHeight;
		}
		
		protected function refreshDecrementButtonStyles() : void {
			var _local2:Object = null;
			for(var _local1 in this._decrementButtonProperties) {
				_local2 = this._decrementButtonProperties[_local1];
				this.decrementButton[_local1] = _local2;
			}
			this.decrementButton.label = this._decrementButtonLabel;
		}
		
		protected function refreshIncrementButtonStyles() : void {
			var _local2:Object = null;
			for(var _local1 in this._incrementButtonProperties) {
				_local2 = this._incrementButtonProperties[_local1];
				this.incrementButton[_local1] = _local2;
			}
			this.incrementButton.label = this._incrementButtonLabel;
		}
		
		protected function refreshTextInputStyles() : void {
			var _local2:Object = null;
			for(var _local1 in this._textInputProperties) {
				_local2 = this._textInputProperties[_local1];
				this.textInput[_local1] = _local2;
			}
		}
		
		protected function refreshDisplayedText() : void {
			if(this._valueFormatFunction != null) {
				this.textInput.text = this._valueFormatFunction(this._value);
			} else {
				this.textInput.text = this._value.toString();
			}
		}
		
		protected function refreshTypicalText() : void {
			var _local4:int = 0;
			var _local1:String = "";
			var _local2:Number = Math.max(int(this._minimum).toString().length,int(this._maximum).toString().length,int(this._step).toString().length);
			var _local3:Number = Math.max(roundToPrecision(this._minimum - int(this._minimum),10).toString().length,roundToPrecision(this._maximum - int(this._maximum),10).toString().length,roundToPrecision(this._step - int(this._step),10).toString().length) - 2;
			if(_local3 < 0) {
				_local3 = 0;
			}
			var _local5:int = _local2 + _local3;
			_local4 = 0;
			while(_local4 < _local5) {
				_local1 += "0";
				_local4++;
			}
			if(_local3 > 0) {
				_local1 += ".";
			}
			this.textInput.typicalText = _local1;
		}
		
		protected function layoutChildren() : void {
			var _local1:Number = NaN;
			var _local3:Number = NaN;
			var _local2:Number = NaN;
			if(this._buttonLayoutMode === "rightSideVertical") {
				_local1 = (this.actualHeight - this._buttonGap) / 2;
				this.incrementButton.y = 0;
				this.incrementButton.height = _local1;
				this.incrementButton.validate();
				this.decrementButton.y = _local1 + this._buttonGap;
				this.decrementButton.height = _local1;
				this.decrementButton.validate();
				_local3 = Math.max(this.decrementButton.width,this.incrementButton.width);
				_local2 = this.actualWidth - _local3;
				this.decrementButton.x = _local2;
				this.incrementButton.x = _local2;
				this.textInput.x = 0;
				this.textInput.y = 0;
				this.textInput.width = _local2 - this._textInputGap;
				this.textInput.height = this.actualHeight;
			} else if(this._buttonLayoutMode === "splitVertical") {
				this.incrementButton.x = 0;
				this.incrementButton.y = 0;
				this.incrementButton.width = this.actualWidth;
				this.incrementButton.validate();
				this.decrementButton.x = 0;
				this.decrementButton.width = this.actualWidth;
				this.decrementButton.validate();
				this.decrementButton.y = this.actualHeight - this.decrementButton.height;
				this.textInput.x = 0;
				this.textInput.y = this.incrementButton.height + this._textInputGap;
				this.textInput.width = this.actualWidth;
				this.textInput.height = Math.max(0,this.actualHeight - this.decrementButton.height - this.incrementButton.height - 2 * this._textInputGap);
			} else {
				this.decrementButton.x = 0;
				this.decrementButton.y = 0;
				this.decrementButton.height = this.actualHeight;
				this.decrementButton.validate();
				this.incrementButton.y = 0;
				this.incrementButton.height = this.actualHeight;
				this.incrementButton.validate();
				this.incrementButton.x = this.actualWidth - this.incrementButton.width;
				this.textInput.x = this.decrementButton.width + this._textInputGap;
				this.textInput.width = this.actualWidth - this.decrementButton.width - this.incrementButton.width - 2 * this._textInputGap;
				this.textInput.height = this.actualHeight;
			}
			this.textInput.validate();
		}
		
		protected function startRepeatTimer(action:Function) : void {
			var _local2:ExclusiveTouch = null;
			var _local3:DisplayObject = null;
			if(this.touchPointID >= 0) {
				_local2 = ExclusiveTouch.forStage(this.stage);
				_local3 = _local2.getClaim(this.touchPointID);
				if(_local3 != this) {
					if(_local3) {
						return;
					}
					_local2.claimTouch(this.touchPointID,this);
				}
			}
			this.currentRepeatAction = action;
			if(this._repeatDelay > 0) {
				if(!this._repeatTimer) {
					this._repeatTimer = new Timer(this._repeatDelay * 1000);
					this._repeatTimer.addEventListener("timer",repeatTimer_timerHandler);
				} else {
					this._repeatTimer.reset();
					this._repeatTimer.delay = this._repeatDelay * 1000;
				}
				this._repeatTimer.start();
			}
		}
		
		protected function parseTextInputValue() : void {
			var _local1:Number = NaN;
			if(this._valueParseFunction != null) {
				_local1 = this._valueParseFunction(this.textInput.text);
			} else {
				_local1 = parseFloat(this.textInput.text);
			}
			if(_local1 === _local1) {
				this.value = _local1;
			}
			this.invalidate("data");
		}
		
		protected function childProperties_onChange(proxy:PropertyProxy, name:Object) : void {
			this.invalidate("styles");
		}
		
		protected function numericStepper_removedFromStageHandler(event:Event) : void {
			this.touchPointID = -1;
		}
		
		override protected function focusInHandler(event:Event) : void {
			super.focusInHandler(event);
			this.textInput.setFocus();
			this.textInput.selectRange(0,this.textInput.text.length);
			this.stage.addEventListener("keyDown",stage_keyDownHandler);
		}
		
		override protected function focusOutHandler(event:Event) : void {
			super.focusOutHandler(event);
			this.textInput.clearFocus();
			this.stage.removeEventListener("keyDown",stage_keyDownHandler);
		}
		
		protected function textInput_enterHandler(event:Event) : void {
			this.parseTextInputValue();
		}
		
		protected function textInput_focusInHandler(event:Event) : void {
			this._textInputHasFocus = true;
		}
		
		protected function textInput_focusOutHandler(event:Event) : void {
			this._textInputHasFocus = false;
			this.parseTextInputValue();
		}
		
		protected function decrementButton_touchHandler(event:TouchEvent) : void {
			var _local2:Touch = null;
			if(!this._isEnabled) {
				this.touchPointID = -1;
				return;
			}
			if(this.touchPointID >= 0) {
				_local2 = event.getTouch(this.decrementButton,"ended",this.touchPointID);
				if(!_local2) {
					return;
				}
				this.touchPointID = -1;
				this._repeatTimer.stop();
				this.dispatchEventWith("endInteraction");
			} else {
				_local2 = event.getTouch(this.decrementButton,"began");
				if(!_local2) {
					return;
				}
				if(this._textInputHasFocus) {
					this.parseTextInputValue();
				}
				this.touchPointID = _local2.id;
				this.dispatchEventWith("beginInteraction");
				this.decrement();
				this.startRepeatTimer(this.decrement);
			}
		}
		
		protected function incrementButton_touchHandler(event:TouchEvent) : void {
			var _local2:Touch = null;
			if(!this._isEnabled) {
				this.touchPointID = -1;
				return;
			}
			if(this.touchPointID >= 0) {
				_local2 = event.getTouch(this.incrementButton,"ended",this.touchPointID);
				if(!_local2) {
					return;
				}
				this.touchPointID = -1;
				this._repeatTimer.stop();
				this.dispatchEventWith("endInteraction");
			} else {
				_local2 = event.getTouch(this.incrementButton,"began");
				if(!_local2) {
					return;
				}
				if(this._textInputHasFocus) {
					this.parseTextInputValue();
				}
				this.touchPointID = _local2.id;
				this.dispatchEventWith("beginInteraction");
				this.increment();
				this.startRepeatTimer(this.increment);
			}
		}
		
		protected function stage_keyDownHandler(event:KeyboardEvent) : void {
			if(event.keyCode == 36) {
				event.preventDefault();
				this.toMinimum();
			} else if(event.keyCode == 35) {
				event.preventDefault();
				this.toMaximum();
			} else if(event.keyCode == 38) {
				event.preventDefault();
				this.increment();
			} else if(event.keyCode == 40) {
				event.preventDefault();
				this.decrement();
			}
		}
		
		protected function repeatTimer_timerHandler(event:TimerEvent) : void {
			if(this._repeatTimer.currentCount < 5) {
				return;
			}
			this.currentRepeatAction();
		}
	}
}

