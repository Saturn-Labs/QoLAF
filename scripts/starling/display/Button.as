package starling.display {
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.styles.MeshStyle;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.textures.Texture;
	
	public class Button extends DisplayObjectContainer {
		private static const MAX_DRAG_DIST:Number = 50;
		
		private var _upState:Texture;
		
		private var _downState:Texture;
		
		private var _overState:Texture;
		
		private var _disabledState:Texture;
		
		private var _contents:Sprite;
		
		private var _body:Image;
		
		private var _textField:TextField;
		
		private var _textBounds:Rectangle;
		
		private var _overlay:Sprite;
		
		private var _scaleWhenDown:Number;
		
		private var _scaleWhenOver:Number;
		
		private var _alphaWhenDown:Number;
		
		private var _alphaWhenDisabled:Number;
		
		private var _useHandCursor:Boolean;
		
		private var _enabled:Boolean;
		
		private var _state:String;
		
		private var _triggerBounds:Rectangle;
		
		public function Button(upState:Texture, text:String = "", downState:Texture = null, overState:Texture = null, disabledState:Texture = null) {
			super();
			if(upState == null) {
				throw new ArgumentError("Texture \'upState\' cannot be null");
			}
			_upState = upState;
			_downState = downState;
			_overState = overState;
			_disabledState = disabledState;
			_state = "up";
			_body = new Image(upState);
			_body.pixelSnapping = true;
			_scaleWhenDown = !!downState ? 1 : 0.9;
			_scaleWhenOver = _alphaWhenDown = 1;
			_alphaWhenDisabled = !!disabledState ? 1 : 0.5;
			_enabled = true;
			_useHandCursor = true;
			_textBounds = new Rectangle(0,0,_body.width,_body.height);
			_triggerBounds = new Rectangle();
			_contents = new Sprite();
			_contents.addChild(_body);
			addChild(_contents);
			addEventListener("touch",onTouch);
			this.touchGroup = true;
			this.text = text;
		}
		
		override public function dispose() : void {
			if(_textField) {
				_textField.dispose();
			}
			super.dispose();
		}
		
		public function readjustSize() : void {
			var _local1:Number = _body.width;
			var _local4:Number = _body.height;
			_body.readjustSize();
			var _local2:Number = _body.width / _local1;
			var _local3:Number = _body.height / _local4;
			_textBounds.x *= _local2;
			_textBounds.y *= _local3;
			_textBounds.width *= _local2;
			_textBounds.height *= _local3;
			if(_textField) {
				createTextField();
			}
		}
		
		private function createTextField() : void {
			if(_textField == null) {
				_textField = new TextField(_textBounds.width,_textBounds.height);
				_textField.pixelSnapping = _body.pixelSnapping;
				_textField.touchable = false;
				_textField.autoScale = true;
				_textField.batchable = true;
			}
			_textField.width = _textBounds.width;
			_textField.height = _textBounds.height;
			_textField.x = _textBounds.x;
			_textField.y = _textBounds.y;
		}
		
		private function onTouch(event:TouchEvent) : void {
			var _local3:Boolean = false;
			Mouse.cursor = _useHandCursor && _enabled && event.interactsWith(this) ? "button" : "auto";
			var _local2:Touch = event.getTouch(this);
			if(!_enabled) {
				return;
			}
			if(_local2 == null) {
				state = "up";
			} else if(_local2.phase == "hover") {
				state = "over";
			} else if(_local2.phase == "began" && _state != "down") {
				_triggerBounds = getBounds(stage,_triggerBounds);
				_triggerBounds.inflate(50,50);
				state = "down";
			} else if(_local2.phase == "moved") {
				_local3 = _triggerBounds.contains(_local2.globalX,_local2.globalY);
				if(_state == "down" && !_local3) {
					state = "up";
				} else if(_state == "up" && _local3) {
					state = "down";
				}
			} else if(_local2.phase == "ended" && _state == "down") {
				state = "up";
				if(!_local2.cancelled) {
					dispatchEventWith("triggered",true);
				}
			}
		}
		
		public function get state() : String {
			return _state;
		}
		
		public function set state(value:String) : void {
			_state = value;
			_contents.x = _contents.y = 0;
			_contents.scaleX = _contents.scaleY = _contents.alpha = 1;
			switch(_state) {
				case "down":
					setStateTexture(_downState);
					_contents.alpha = _alphaWhenDown;
					_contents.scaleX = _contents.scaleY = _scaleWhenDown;
					_contents.x = (1 - _scaleWhenDown) / 2 * _body.width;
					_contents.y = (1 - _scaleWhenDown) / 2 * _body.height;
					break;
				case "up":
					setStateTexture(_upState);
					break;
				case "over":
					setStateTexture(_overState);
					_contents.scaleX = _contents.scaleY = _scaleWhenOver;
					_contents.x = (1 - _scaleWhenOver) / 2 * _body.width;
					_contents.y = (1 - _scaleWhenOver) / 2 * _body.height;
					break;
				case "disabled":
					setStateTexture(_disabledState);
					_contents.alpha = _alphaWhenDisabled;
					break;
				default:
					throw new ArgumentError("Invalid button state: " + _state);
			}
		}
		
		private function setStateTexture(texture:Texture) : void {
			_body.texture = !!texture ? texture : _upState;
		}
		
		public function get scaleWhenDown() : Number {
			return _scaleWhenDown;
		}
		
		public function set scaleWhenDown(value:Number) : void {
			_scaleWhenDown = value;
		}
		
		public function get scaleWhenOver() : Number {
			return _scaleWhenOver;
		}
		
		public function set scaleWhenOver(value:Number) : void {
			_scaleWhenOver = value;
		}
		
		public function get alphaWhenDown() : Number {
			return _alphaWhenDown;
		}
		
		public function set alphaWhenDown(value:Number) : void {
			_alphaWhenDown = value;
		}
		
		public function get alphaWhenDisabled() : Number {
			return _alphaWhenDisabled;
		}
		
		public function set alphaWhenDisabled(value:Number) : void {
			_alphaWhenDisabled = value;
		}
		
		public function get enabled() : Boolean {
			return _enabled;
		}
		
		public function set enabled(value:Boolean) : void {
			if(_enabled != value) {
				_enabled = value;
				state = value ? "up" : "disabled";
			}
		}
		
		public function get text() : String {
			return !!_textField ? _textField.text : "";
		}
		
		public function set text(value:String) : void {
			if(value.length == 0) {
				if(_textField) {
					_textField.text = value;
					_textField.removeFromParent();
				}
			} else {
				createTextField();
				_textField.text = value;
				if(_textField.parent == null) {
					_contents.addChild(_textField);
				}
			}
		}
		
		public function get textFormat() : TextFormat {
			if(_textField == null) {
				createTextField();
			}
			return _textField.format;
		}
		
		public function set textFormat(value:TextFormat) : void {
			if(_textField == null) {
				createTextField();
			}
			_textField.format = value;
		}
		
		public function get textStyle() : MeshStyle {
			if(_textField == null) {
				createTextField();
			}
			return _textField.style;
		}
		
		public function set textStyle(value:MeshStyle) : void {
			if(_textField == null) {
				createTextField();
			}
			_textField.style = value;
		}
		
		public function get style() : MeshStyle {
			return _body.style;
		}
		
		public function set style(value:MeshStyle) : void {
			_body.style = value;
		}
		
		public function get upState() : Texture {
			return _upState;
		}
		
		public function set upState(value:Texture) : void {
			if(value == null) {
				throw new ArgumentError("Texture \'upState\' cannot be null");
			}
			if(_upState != value) {
				_upState = value;
				if(_state == "up" || _state == "disabled" && _disabledState == null || _state == "down" && _downState == null || _state == "over" && _overState == null) {
					setStateTexture(value);
				}
			}
		}
		
		public function get downState() : Texture {
			return _downState;
		}
		
		public function set downState(value:Texture) : void {
			if(_downState != value) {
				_downState = value;
				if(_state == "down") {
					setStateTexture(value);
				}
			}
		}
		
		public function get overState() : Texture {
			return _overState;
		}
		
		public function set overState(value:Texture) : void {
			if(_overState != value) {
				_overState = value;
				if(_state == "over") {
					setStateTexture(value);
				}
			}
		}
		
		public function get disabledState() : Texture {
			return _disabledState;
		}
		
		public function set disabledState(value:Texture) : void {
			if(_disabledState != value) {
				_disabledState = value;
				if(_state == "disabled") {
					setStateTexture(value);
				}
			}
		}
		
		public function get textBounds() : Rectangle {
			return _textBounds;
		}
		
		public function set textBounds(value:Rectangle) : void {
			_textBounds.copyFrom(value);
			createTextField();
		}
		
		public function get color() : uint {
			return _body.color;
		}
		
		public function set color(value:uint) : void {
			_body.color = value;
		}
		
		public function get textureSmoothing() : String {
			return _body.textureSmoothing;
		}
		
		public function set textureSmoothing(value:String) : void {
			_body.textureSmoothing = value;
		}
		
		public function get overlay() : Sprite {
			if(_overlay == null) {
				_overlay = new Sprite();
			}
			_contents.addChild(_overlay);
			return _overlay;
		}
		
		override public function get useHandCursor() : Boolean {
			return _useHandCursor;
		}
		
		override public function set useHandCursor(value:Boolean) : void {
			_useHandCursor = value;
		}
		
		public function get pixelSnapping() : Boolean {
			return _body.pixelSnapping;
		}
		
		public function set pixelSnapping(value:Boolean) : void {
			_body.pixelSnapping = value;
			if(_textField) {
				_textField.pixelSnapping = value;
			}
		}
		
		override public function set width(value:Number) : void {
			var _local2:Number = value / (this.scaleX || 1);
			var _local3:Number = _local2 / (_body.width || 1);
			_body.width = _local2;
			_textBounds.x *= _local3;
			_textBounds.width *= _local3;
			if(_textField) {
				_textField.width = _local2;
			}
		}
		
		override public function set height(value:Number) : void {
			var _local2:Number = value / (this.scaleY || 1);
			var _local3:Number = _local2 / (_body.height || 1);
			_body.height = _local2;
			_textBounds.y *= _local3;
			_textBounds.height *= _local3;
			if(_textField) {
				_textField.height = _local2;
			}
		}
		
		public function get scale9Grid() : Rectangle {
			return _body.scale9Grid;
		}
		
		public function set scale9Grid(value:Rectangle) : void {
			_body.scale9Grid = value;
		}
	}
}

