package feathers.skins {
	import feathers.core.IFeathersControl;
	import feathers.core.IMeasureDisplayObject;
	import feathers.core.IStateContext;
	import feathers.core.IStateObserver;
	import feathers.core.IToggle;
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.Texture;
	
	public class ImageSkin extends Image implements IMeasureDisplayObject, IStateObserver {
		protected var _defaultTexture:Texture;
		
		protected var _disabledTexture:Texture;
		
		protected var _selectedTexture:Texture;
		
		protected var _defaultColor:uint = 4294967295;
		
		protected var _disabledColor:uint = 4294967295;
		
		protected var _selectedColor:uint = 4294967295;
		
		protected var _stateContext:IStateContext;
		
		protected var _explicitWidth:Number = NaN;
		
		protected var _explicitHeight:Number = NaN;
		
		protected var _explicitMinWidth:Number = NaN;
		
		protected var _explicitMaxWidth:Number = Infinity;
		
		protected var _explicitMinHeight:Number = NaN;
		
		protected var _explicitMaxHeight:Number = Infinity;
		
		protected var _stateToTexture:Object = {};
		
		protected var _stateToColor:Object = {};
		
		public function ImageSkin(defaultTexture:Texture = null) {
			super(defaultTexture);
			this.defaultTexture = defaultTexture;
		}
		
		public function get defaultTexture() : Texture {
			return this._defaultTexture;
		}
		
		public function set defaultTexture(value:Texture) : void {
			if(this._defaultTexture === value) {
				return;
			}
			this._defaultTexture = value;
			this.updateTextureFromContext();
		}
		
		public function get disabledTexture() : Texture {
			return this._disabledTexture;
		}
		
		public function set disabledTexture(value:Texture) : void {
			if(this._disabledTexture === value) {
				return;
			}
			this._disabledTexture = value;
			this.updateTextureFromContext();
		}
		
		public function get selectedTexture() : Texture {
			return this._selectedTexture;
		}
		
		public function set selectedTexture(value:Texture) : void {
			if(this._selectedTexture === value) {
				return;
			}
			this._selectedTexture = value;
			this.updateTextureFromContext();
		}
		
		public function get defaultColor() : uint {
			return this._defaultColor;
		}
		
		public function set defaultColor(value:uint) : void {
			if(this._defaultColor === value) {
				return;
			}
			this._defaultColor = value;
			this.updateColorFromContext();
		}
		
		public function get disabledColor() : uint {
			return this._disabledColor;
		}
		
		public function set disabledColor(value:uint) : void {
			if(this._disabledColor === value) {
				return;
			}
			this._disabledColor = value;
			this.updateColorFromContext();
		}
		
		public function get selectedColor() : uint {
			return this._selectedColor;
		}
		
		public function set selectedColor(value:uint) : void {
			if(this._selectedColor === value) {
				return;
			}
			this._selectedColor = value;
			this.updateColorFromContext();
		}
		
		public function get stateContext() : IStateContext {
			return this._stateContext;
		}
		
		public function set stateContext(value:IStateContext) : void {
			if(this._stateContext === value) {
				return;
			}
			if(this._stateContext) {
				this._stateContext.removeEventListener("stageChange",stateContext_stageChangeHandler);
			}
			this._stateContext = value;
			if(this._stateContext) {
				this._stateContext.addEventListener("stageChange",stateContext_stageChangeHandler);
			}
			this.updateTextureFromContext();
			this.updateColorFromContext();
		}
		
		public function get explicitWidth() : Number {
			return this._explicitWidth;
		}
		
		override public function set width(value:Number) : void {
			if(this._explicitWidth === value) {
				return;
			}
			if(value !== value && this._explicitWidth !== this._explicitWidth) {
				return;
			}
			this._explicitWidth = value;
			if(value === value) {
				super.width = value;
			} else {
				this.readjustSize();
			}
			this.dispatchEventWith("resize");
		}
		
		public function get explicitHeight() : Number {
			return this._explicitHeight;
		}
		
		override public function set height(value:Number) : void {
			if(this._explicitHeight === value) {
				return;
			}
			if(value !== value && this._explicitHeight !== this._explicitHeight) {
				return;
			}
			this._explicitHeight = value;
			if(value === value) {
				super.height = value;
			} else {
				this.readjustSize();
			}
			this.dispatchEventWith("resize");
		}
		
		public function get explicitMinWidth() : Number {
			return this._explicitMinWidth;
		}
		
		public function get minWidth() : Number {
			if(this._explicitMinWidth === this._explicitMinWidth) {
				return this._explicitMinWidth;
			}
			return 0;
		}
		
		public function set minWidth(value:Number) : void {
			if(this._explicitMinWidth === value) {
				return;
			}
			if(value !== value && this._explicitMinWidth !== this._explicitMinWidth) {
				return;
			}
			this._explicitMinWidth = value;
			this.dispatchEventWith("resize");
		}
		
		public function get explicitMaxWidth() : Number {
			return this._explicitMaxWidth;
		}
		
		public function get maxWidth() : Number {
			return this._explicitMaxWidth;
		}
		
		public function set maxWidth(value:Number) : void {
			if(this._explicitMaxWidth === value) {
				return;
			}
			if(value !== value && this._explicitMaxWidth !== this._explicitMaxWidth) {
				return;
			}
			this._explicitMaxWidth = value;
			this.dispatchEventWith("resize");
		}
		
		public function get explicitMinHeight() : Number {
			return this._explicitMinHeight;
		}
		
		public function get minHeight() : Number {
			if(this._explicitMinHeight === this._explicitMinHeight) {
				return this._explicitMinHeight;
			}
			return 0;
		}
		
		public function set minHeight(value:Number) : void {
			if(this._explicitMinHeight === value) {
				return;
			}
			if(value !== value && this._explicitMinHeight !== this._explicitMinHeight) {
				return;
			}
			this._explicitMinHeight = value;
			this.dispatchEventWith("resize");
		}
		
		public function get explicitMaxHeight() : Number {
			return this._explicitMaxHeight;
		}
		
		public function get maxHeight() : Number {
			return this._explicitMaxHeight;
		}
		
		public function set maxHeight(value:Number) : void {
			if(this._explicitMaxHeight === value) {
				return;
			}
			if(value !== value && this._explicitMaxHeight !== this._explicitMaxHeight) {
				return;
			}
			this._explicitMaxHeight = value;
			this.dispatchEventWith("resize");
		}
		
		public function getTextureForState(state:String) : Texture {
			return this._stateToTexture[state] as Texture;
		}
		
		public function setTextureForState(state:String, texture:Texture) : void {
			if(texture !== null) {
				this._stateToTexture[state] = texture;
			} else {
				delete this._stateToTexture[state];
			}
			this.updateTextureFromContext();
		}
		
		public function getColorForState(state:String) : uint {
			if(state in this._stateToColor) {
				return this._stateToColor[state] as uint;
			}
			return 4294967295;
		}
		
		public function setColorForState(state:String, color:uint) : void {
			if(color !== 4294967295) {
				this._stateToColor[state] = color;
			} else {
				delete this._stateToColor[state];
			}
			this.updateColorFromContext();
		}
		
		override public function readjustSize(width:Number = -1, height:Number = -1) : void {
			super.readjustSize(width,height);
			if(this._explicitWidth === this._explicitWidth) {
				super.width = this._explicitWidth;
			}
			if(this._explicitHeight === this._explicitHeight) {
				super.height = this._explicitHeight;
			}
		}
		
		protected function updateTextureFromContext() : void {
			var _local1:Texture = null;
			if(this._stateContext === null) {
				_local1 = this._defaultTexture;
			} else {
				_local1 = this._stateToTexture[this._stateContext.currentState] as Texture;
				if(_local1 === null && this._disabledTexture !== null && this._stateContext is IFeathersControl && !IFeathersControl(this._stateContext).isEnabled) {
					_local1 = this._disabledTexture;
				}
				if(_local1 === null && this._selectedTexture !== null && this._stateContext is IToggle && Boolean(IToggle(this._stateContext).isSelected)) {
					_local1 = this._selectedTexture;
				}
				if(_local1 === null) {
					_local1 = this._defaultTexture;
				}
			}
			this.texture = _local1;
		}
		
		protected function updateColorFromContext() : void {
			if(this._stateContext === null) {
				if(this._defaultColor !== 4294967295) {
					this.color = this._defaultColor;
				}
				return;
			}
			var _local1:* = 4294967295;
			var _local2:String = this._stateContext.currentState;
			if(_local2 in this._stateToColor) {
				_local1 = this._stateToColor[_local2] as uint;
			}
			if(_local1 === 4294967295 && this._disabledColor !== 4294967295 && this._stateContext is IFeathersControl && !IFeathersControl(this._stateContext).isEnabled) {
				_local1 = this._disabledColor;
			}
			if(_local1 === 4294967295 && this._selectedColor !== 4294967295 && this._stateContext is IToggle && Boolean(IToggle(this._stateContext).isSelected)) {
				_local1 = this._selectedColor;
			}
			if(_local1 === 4294967295) {
				_local1 = this._defaultColor;
			}
			if(_local1 !== 4294967295) {
				this.color = _local1;
			}
		}
		
		protected function stateContext_stageChangeHandler(event:Event) : void {
			this.updateTextureFromContext();
			this.updateColorFromContext();
		}
	}
}

