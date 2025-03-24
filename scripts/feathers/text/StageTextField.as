package feathers.text {
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public final class StageTextField extends EventDispatcher {
		private var _textField:TextField;
		
		private var _textFormat:TextFormat;
		
		private var _isComplete:Boolean = false;
		
		private var _autoCapitalize:String = "none";
		
		private var _autoCorrect:Boolean = false;
		
		private var _color:uint = 0;
		
		private var _fontFamily:String = null;
		
		private var _locale:String = "en";
		
		private var _returnKeyLabel:String = "default";
		
		private var _softKeyboardType:String = "default";
		
		private var _textAlign:String = "start";
		
		private var _viewPort:Rectangle = new Rectangle();
		
		public function StageTextField(initOptions:Object = null) {
			super();
			this.initialize(initOptions);
		}
		
		public function get autoCapitalize() : String {
			return this._autoCapitalize;
		}
		
		public function set autoCapitalize(value:String) : void {
			this._autoCapitalize = value;
		}
		
		public function get autoCorrect() : Boolean {
			return this._autoCorrect;
		}
		
		public function set autoCorrect(value:Boolean) : void {
			this._autoCorrect = value;
		}
		
		public function get color() : uint {
			return this._textFormat.color as uint;
		}
		
		public function set color(value:uint) : void {
			if(this._textFormat.color == value) {
				return;
			}
			this._textFormat.color = value;
			this._textField.defaultTextFormat = this._textFormat;
			this._textField.setTextFormat(this._textFormat);
		}
		
		public function get displayAsPassword() : Boolean {
			return this._textField.displayAsPassword;
		}
		
		public function set displayAsPassword(value:Boolean) : void {
			this._textField.displayAsPassword = value;
		}
		
		public function get editable() : Boolean {
			return this._textField.type == "input";
		}
		
		public function set editable(value:Boolean) : void {
			this._textField.type = value ? "input" : "dynamic";
		}
		
		public function get fontFamily() : String {
			return this._textFormat.font;
		}
		
		public function set fontFamily(value:String) : void {
			if(this._textFormat.font == value) {
				return;
			}
			this._textFormat.font = value;
			this._textField.defaultTextFormat = this._textFormat;
			this._textField.setTextFormat(this._textFormat);
		}
		
		public function get fontPosture() : String {
			return !!this._textFormat.italic ? "italic" : "normal";
		}
		
		public function set fontPosture(value:String) : void {
			if(this.fontPosture == value) {
				return;
			}
			this._textFormat.italic = value == "italic";
			this._textField.defaultTextFormat = this._textFormat;
			this._textField.setTextFormat(this._textFormat);
		}
		
		public function get fontSize() : int {
			return this._textFormat.size as int;
		}
		
		public function set fontSize(value:int) : void {
			if(this._textFormat.size == value) {
				return;
			}
			this._textFormat.size = value;
			this._textField.defaultTextFormat = this._textFormat;
			this._textField.setTextFormat(this._textFormat);
		}
		
		public function get fontWeight() : String {
			return !!this._textFormat.bold ? "bold" : "normal";
		}
		
		public function set fontWeight(value:String) : void {
			if(this.fontWeight == value) {
				return;
			}
			this._textFormat.bold = value == "bold";
			this._textField.defaultTextFormat = this._textFormat;
			this._textField.setTextFormat(this._textFormat);
		}
		
		public function get locale() : String {
			return this._locale;
		}
		
		public function set locale(value:String) : void {
			this._locale = value;
		}
		
		public function get maxChars() : int {
			return this._textField.maxChars;
		}
		
		public function set maxChars(value:int) : void {
			this._textField.maxChars = value;
		}
		
		public function get multiline() : Boolean {
			return this._textField.multiline;
		}
		
		public function get restrict() : String {
			return this._textField.restrict;
		}
		
		public function set restrict(value:String) : void {
			this._textField.restrict = value;
		}
		
		public function get returnKeyLabel() : String {
			return this._returnKeyLabel;
		}
		
		public function set returnKeyLabel(value:String) : void {
			this._returnKeyLabel = value;
		}
		
		public function get selectionActiveIndex() : int {
			return this._textField.selectionBeginIndex;
		}
		
		public function get selectionAnchorIndex() : int {
			return this._textField.selectionEndIndex;
		}
		
		public function get softKeyboardType() : String {
			return this._softKeyboardType;
		}
		
		public function set softKeyboardType(value:String) : void {
			this._softKeyboardType = value;
		}
		
		public function get stage() : Stage {
			return this._textField.stage;
		}
		
		public function set stage(value:Stage) : void {
			if(this._textField.stage == value) {
				return;
			}
			if(this._textField.stage) {
				this._textField.parent.removeChild(this._textField);
			}
			if(value) {
				value.addChild(this._textField);
				this.dispatchCompleteIfPossible();
			}
		}
		
		public function get text() : String {
			return this._textField.text;
		}
		
		public function set text(value:String) : void {
			this._textField.text = value;
		}
		
		public function get textAlign() : String {
			return this._textAlign;
		}
		
		public function set textAlign(value:String) : void {
			if(this._textAlign == value) {
				return;
			}
			this._textAlign = value;
			if(value == "start") {
				value = "left";
			} else if(value == "end") {
				value = "right";
			}
			this._textFormat.align = value;
			this._textField.defaultTextFormat = this._textFormat;
			this._textField.setTextFormat(this._textFormat);
		}
		
		public function get viewPort() : Rectangle {
			return this._viewPort;
		}
		
		public function set viewPort(value:Rectangle) : void {
			if(!value || value.width < 0 || value.height < 0) {
				throw new RangeError("The Rectangle value is not valid.");
			}
			this._viewPort = value;
			this._textField.x = this._viewPort.x;
			this._textField.y = this._viewPort.y;
			this._textField.width = this._viewPort.width;
			this._textField.height = this._viewPort.height;
			this.dispatchCompleteIfPossible();
		}
		
		public function get visible() : Boolean {
			return this._textField.visible;
		}
		
		public function set visible(value:Boolean) : void {
			this._textField.visible = value;
		}
		
		public function assignFocus() : void {
			if(!this._textField.parent) {
				return;
			}
			this._textField.stage.focus = this._textField;
		}
		
		public function dispose() : void {
			this.stage = null;
			this._textField = null;
			this._textFormat = null;
		}
		
		public function drawViewPortToBitmapData(bitmap:BitmapData) : void {
			if(!bitmap) {
				throw new Error("The bitmap is null.");
			}
			if(bitmap.width != this._viewPort.width || bitmap.height != this._viewPort.height) {
				throw new ArgumentError("The bitmap\'s width or height is different from view port\'s width or height.");
			}
			bitmap.draw(this._textField);
		}
		
		public function selectRange(anchorIndex:int, activeIndex:int) : void {
			this._textField.setSelection(anchorIndex,activeIndex);
		}
		
		private function dispatchCompleteIfPossible() : void {
			if(!this._textField.stage || this._viewPort.isEmpty()) {
				this._isComplete = false;
			}
			if(this._textField.stage && !this._viewPort.isEmpty()) {
				this._isComplete = true;
				this.dispatchEvent(new Event("complete"));
			}
		}
		
		private function initialize(initOptions:Object) : void {
			this._textField = new TextField();
			this._textField.type = "input";
			var _local2:Boolean = initOptions && initOptions.hasOwnProperty("multiline") && initOptions.multiline;
			this._textField.multiline = _local2;
			this._textField.wordWrap = _local2;
			this._textField.addEventListener("change",textField_eventHandler);
			this._textField.addEventListener("focusIn",textField_eventHandler);
			this._textField.addEventListener("focusOut",textField_eventHandler);
			this._textField.addEventListener("keyDown",textField_eventHandler);
			this._textField.addEventListener("keyUp",textField_eventHandler);
			this._textField.addEventListener("keyFocusChange",textField_keyFocusChangeHandler);
			this._textFormat = new TextFormat(null,11,0,false,false,false);
			this._textField.defaultTextFormat = this._textFormat;
		}
		
		private function textField_eventHandler(event:Event) : void {
			this.dispatchEvent(event);
		}
		
		private function textField_keyFocusChangeHandler(event:FocusEvent) : void {
			event.preventDefault();
			event.stopImmediatePropagation();
			event.stopPropagation();
		}
	}
}

