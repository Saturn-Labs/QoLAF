package feathers.controls {
	import feathers.core.FeathersControl;
	import feathers.core.IFeathersControl;
	import feathers.core.IMeasureDisplayObject;
	import feathers.core.ITextBaselineControl;
	import feathers.core.ITextRenderer;
	import feathers.core.IToolTip;
	import feathers.core.IValidating;
	import feathers.core.PropertyProxy;
	import feathers.skins.IStyleProvider;
	import feathers.utils.skins.resetFluidChildDimensionsForMeasurement;
	import flash.geom.Point;
	import starling.display.DisplayObject;
	
	public class Label extends FeathersControl implements ITextBaselineControl, IToolTip {
		public static const DEFAULT_CHILD_STYLE_NAME_TEXT_RENDERER:String = "feathers-label-text-renderer";
		
		public static const ALTERNATE_STYLE_NAME_HEADING:String = "feathers-heading-label";
		
		public static const ALTERNATE_STYLE_NAME_DETAIL:String = "feathers-detail-label";
		
		public static const ALTERNATE_STYLE_NAME_TOOL_TIP:String = "feathers-tool-tip";
		
		public static var globalStyleProvider:IStyleProvider;
		
		private static const HELPER_POINT:Point = new Point();
		
		protected var textRendererStyleName:String = "feathers-label-text-renderer";
		
		protected var textRenderer:ITextRenderer;
		
		protected var _text:String = null;
		
		protected var _wordWrap:Boolean = false;
		
		protected var _textRendererFactory:Function;
		
		protected var _customTextRendererStyleName:String;
		
		protected var _textRendererProperties:PropertyProxy;
		
		protected var _explicitTextRendererWidth:Number;
		
		protected var _explicitTextRendererHeight:Number;
		
		protected var _explicitTextRendererMinWidth:Number;
		
		protected var _explicitTextRendererMinHeight:Number;
		
		protected var _explicitTextRendererMaxWidth:Number;
		
		protected var _explicitTextRendererMaxHeight:Number;
		
		protected var _explicitBackgroundWidth:Number;
		
		protected var _explicitBackgroundHeight:Number;
		
		protected var _explicitBackgroundMinWidth:Number;
		
		protected var _explicitBackgroundMinHeight:Number;
		
		protected var _explicitBackgroundMaxWidth:Number;
		
		protected var _explicitBackgroundMaxHeight:Number;
		
		protected var currentBackgroundSkin:DisplayObject;
		
		protected var _backgroundSkin:DisplayObject;
		
		protected var _backgroundDisabledSkin:DisplayObject;
		
		protected var _paddingTop:Number = 0;
		
		protected var _paddingRight:Number = 0;
		
		protected var _paddingBottom:Number = 0;
		
		protected var _paddingLeft:Number = 0;
		
		public function Label() {
			super();
			this.isQuickHitAreaEnabled = true;
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return Label.globalStyleProvider;
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
		
		public function get baseline() : Number {
			if(!this.textRenderer) {
				return this.scaledActualHeight;
			}
			return this.scaleY * (this.textRenderer.y + this.textRenderer.baseline);
		}
		
		public function get textRendererFactory() : Function {
			return this._textRendererFactory;
		}
		
		public function set textRendererFactory(value:Function) : void {
			if(this._textRendererFactory == value) {
				return;
			}
			this._textRendererFactory = value;
			this.invalidate("textRenderer");
		}
		
		public function get customTextRendererStyleName() : String {
			return this._customTextRendererStyleName;
		}
		
		public function set customTextRendererStyleName(value:String) : void {
			if(this._customTextRendererStyleName == value) {
				return;
			}
			this._customTextRendererStyleName = value;
			this.invalidate("textRenderer");
		}
		
		public function get textRendererProperties() : Object {
			if(!this._textRendererProperties) {
				this._textRendererProperties = new PropertyProxy(textRendererProperties_onChange);
			}
			return this._textRendererProperties;
		}
		
		public function set textRendererProperties(value:Object) : void {
			if(this._textRendererProperties == value) {
				return;
			}
			if(value && !(value is PropertyProxy)) {
				value = PropertyProxy.fromObject(value);
			}
			if(this._textRendererProperties) {
				this._textRendererProperties.removeOnChangeCallback(textRendererProperties_onChange);
			}
			this._textRendererProperties = PropertyProxy(value);
			if(this._textRendererProperties) {
				this._textRendererProperties.addOnChangeCallback(textRendererProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get backgroundSkin() : DisplayObject {
			return this._backgroundSkin;
		}
		
		public function set backgroundSkin(value:DisplayObject) : void {
			if(this._backgroundSkin == value) {
				return;
			}
			if(this._backgroundSkin && this.currentBackgroundSkin == this._backgroundSkin) {
				this.removeChild(this._backgroundSkin);
				this.currentBackgroundSkin = null;
			}
			this._backgroundSkin = value;
			this.invalidate("styles");
		}
		
		public function get backgroundDisabledSkin() : DisplayObject {
			return this._backgroundDisabledSkin;
		}
		
		public function set backgroundDisabledSkin(value:DisplayObject) : void {
			if(this._backgroundDisabledSkin == value) {
				return;
			}
			if(this._backgroundDisabledSkin && this.currentBackgroundSkin == this._backgroundDisabledSkin) {
				this.removeChild(this._backgroundDisabledSkin);
				this.currentBackgroundSkin = null;
			}
			this._backgroundDisabledSkin = value;
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
		
		override protected function draw() : void {
			var _local4:Boolean = this.isInvalid("data");
			var _local5:Boolean = this.isInvalid("styles");
			var _local1:Boolean = this.isInvalid("size");
			var _local2:Boolean = this.isInvalid("state");
			var _local3:Boolean = this.isInvalid("textRenderer");
			if(_local1 || _local5 || _local2) {
				this.refreshBackgroundSkin();
			}
			if(_local3) {
				this.createTextRenderer();
			}
			if(_local3 || _local4 || _local2) {
				this.refreshTextRendererData();
			}
			if(_local3 || _local2) {
				this.refreshEnabled();
			}
			if(_local3 || _local5 || _local2) {
				this.refreshTextRendererStyles();
			}
			_local1 = this.autoSizeIfNeeded() || _local1;
			this.layoutChildren();
		}
		
		protected function autoSizeIfNeeded() : Boolean {
			var _local8:Number = NaN;
			var _local10:Number = NaN;
			var _local3:* = this._explicitWidth !== this._explicitWidth;
			var _local7:* = this._explicitHeight !== this._explicitHeight;
			var _local4:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local11:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local3 && !_local7 && !_local4 && !_local11) {
				return false;
			}
			resetFluidChildDimensionsForMeasurement(DisplayObject(this.textRenderer),this._explicitWidth - this._paddingLeft - this._paddingRight,this._explicitHeight - this._paddingTop - this._paddingBottom,this._explicitMinWidth - this._paddingLeft - this._paddingRight,this._explicitMinHeight - this._paddingTop - this._paddingBottom,this._explicitMaxWidth - this._paddingLeft - this._paddingRight,this._explicitMaxHeight - this._paddingTop - this._paddingBottom,this._explicitTextRendererWidth,this._explicitTextRendererHeight,this._explicitTextRendererMinWidth,this._explicitTextRendererMinHeight,this._explicitTextRendererMaxWidth,this._explicitTextRendererMaxHeight);
			this.textRenderer.maxWidth = this._explicitMaxWidth - this._paddingLeft - this._paddingRight;
			this.textRenderer.maxHeight = this._explicitMaxHeight - this._paddingTop - this._paddingBottom;
			this.textRenderer.measureText(HELPER_POINT);
			var _local9:IMeasureDisplayObject = this.currentBackgroundSkin as IMeasureDisplayObject;
			resetFluidChildDimensionsForMeasurement(this.currentBackgroundSkin,this._explicitWidth,this._explicitHeight,this._explicitMinWidth,this._explicitMinHeight,this._explicitMaxWidth,this._explicitMaxHeight,this._explicitBackgroundWidth,this._explicitBackgroundHeight,this._explicitBackgroundMinWidth,this._explicitBackgroundMinHeight,this._explicitBackgroundMaxWidth,this._explicitBackgroundMaxHeight);
			if(this.currentBackgroundSkin is IValidating) {
				IValidating(this.currentBackgroundSkin).validate();
			}
			var _local1:* = this._explicitMinWidth;
			if(_local4) {
				if(this._text && !_local3) {
					_local1 = HELPER_POINT.x;
				} else {
					_local1 = 0;
				}
				_local1 += this._paddingLeft + this._paddingRight;
				_local8 = 0;
				if(_local9 !== null) {
					_local8 = _local9.minWidth;
				} else if(this.currentBackgroundSkin !== null) {
					_local8 = this._explicitBackgroundMinWidth;
				}
				if(_local8 > _local1) {
					_local1 = _local8;
				}
			}
			var _local6:* = this._explicitMinHeight;
			if(_local11) {
				if(this._text) {
					_local6 = HELPER_POINT.y;
				} else {
					_local6 = 0;
				}
				_local6 += this._paddingTop + this._paddingBottom;
				_local10 = 0;
				if(_local9 !== null) {
					_local10 = _local9.minHeight;
				} else if(this.currentBackgroundSkin !== null) {
					_local10 = this._explicitBackgroundMinHeight;
				}
				if(_local10 > _local6) {
					_local6 = _local10;
				}
			}
			var _local2:Number = this._explicitWidth;
			if(_local3) {
				if(this._text) {
					_local2 = HELPER_POINT.x;
				} else {
					_local2 = 0;
				}
				_local2 += this._paddingLeft + this._paddingRight;
				if(this.currentBackgroundSkin !== null && this.currentBackgroundSkin.width > _local2) {
					_local2 = this.currentBackgroundSkin.width;
				}
			}
			var _local5:Number = this._explicitHeight;
			if(_local7) {
				if(this._text) {
					_local5 = HELPER_POINT.y;
				} else {
					_local5 = 0;
				}
				_local5 += this._paddingTop + this._paddingBottom;
				if(this.currentBackgroundSkin !== null && this.currentBackgroundSkin.height > _local5) {
					_local5 = this.currentBackgroundSkin.height;
				}
			}
			return this.saveMeasurements(_local2,_local5,_local1,_local6);
		}
		
		protected function createTextRenderer() : void {
			if(this.textRenderer !== null) {
				this.removeChild(DisplayObject(this.textRenderer),true);
				this.textRenderer = null;
			}
			var _local1:Function = this._textRendererFactory != null ? this._textRendererFactory : FeathersControl.defaultTextRendererFactory;
			this.textRenderer = ITextRenderer(_local1());
			var _local2:String = this._customTextRendererStyleName != null ? this._customTextRendererStyleName : this.textRendererStyleName;
			this.textRenderer.styleNameList.add(_local2);
			this.addChild(DisplayObject(this.textRenderer));
			this.textRenderer.initializeNow();
			this._explicitTextRendererWidth = this.textRenderer.explicitWidth;
			this._explicitTextRendererHeight = this.textRenderer.explicitHeight;
			this._explicitTextRendererMinWidth = this.textRenderer.explicitMinWidth;
			this._explicitTextRendererMinHeight = this.textRenderer.explicitMinHeight;
			this._explicitTextRendererMaxWidth = this.textRenderer.explicitMaxWidth;
			this._explicitTextRendererMaxHeight = this.textRenderer.explicitMaxHeight;
		}
		
		protected function refreshBackgroundSkin() : void {
			var _local2:IMeasureDisplayObject = null;
			var _local1:DisplayObject = this._backgroundSkin;
			if(!this._isEnabled && this._backgroundDisabledSkin !== null) {
				_local1 = this._backgroundDisabledSkin;
			}
			if(this.currentBackgroundSkin != _local1) {
				if(this.currentBackgroundSkin !== null) {
					this.removeChild(this.currentBackgroundSkin);
				}
				this.currentBackgroundSkin = _local1;
				if(this.currentBackgroundSkin !== null) {
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
						this._explicitBackgroundMaxWidth = _local2.explicitMaxWidth;
						this._explicitBackgroundMaxHeight = _local2.explicitMaxHeight;
					} else {
						this._explicitBackgroundWidth = this.currentBackgroundSkin.width;
						this._explicitBackgroundHeight = this.currentBackgroundSkin.height;
						this._explicitBackgroundMinWidth = this._explicitBackgroundWidth;
						this._explicitBackgroundMinHeight = this._explicitBackgroundHeight;
						this._explicitBackgroundMaxWidth = this._explicitBackgroundWidth;
						this._explicitBackgroundMaxHeight = this._explicitBackgroundHeight;
					}
				}
			}
			if(this.currentBackgroundSkin !== null) {
				this.setChildIndex(this.currentBackgroundSkin,0);
			}
		}
		
		protected function layoutChildren() : void {
			if(this.currentBackgroundSkin !== null) {
				this.currentBackgroundSkin.x = 0;
				this.currentBackgroundSkin.y = 0;
				this.currentBackgroundSkin.width = this.actualWidth;
				this.currentBackgroundSkin.height = this.actualHeight;
			}
			this.textRenderer.x = this._paddingLeft;
			this.textRenderer.y = this._paddingTop;
			this.textRenderer.width = this.actualWidth - this._paddingLeft - this._paddingRight;
			this.textRenderer.height = this.actualHeight - this._paddingTop - this._paddingBottom;
			this.textRenderer.validate();
		}
		
		protected function refreshEnabled() : void {
			this.textRenderer.isEnabled = this._isEnabled;
		}
		
		protected function refreshTextRendererData() : void {
			this.textRenderer.text = this._text;
			this.textRenderer.visible = this._text && this._text.length > 0;
		}
		
		protected function refreshTextRendererStyles() : void {
			var _local2:Object = null;
			this.textRenderer.wordWrap = this._wordWrap;
			for(var _local1 in this._textRendererProperties) {
				_local2 = this._textRendererProperties[_local1];
				this.textRenderer[_local1] = _local2;
			}
		}
		
		protected function textRendererProperties_onChange(proxy:PropertyProxy, propertyName:String) : void {
			this.invalidate("styles");
		}
	}
}

