package feathers.controls.renderers {
	import feathers.controls.GroupedList;
	import feathers.controls.ImageLoader;
	import feathers.core.FeathersControl;
	import feathers.core.IFeathersControl;
	import feathers.core.IMeasureDisplayObject;
	import feathers.core.ITextRenderer;
	import feathers.core.IValidating;
	import feathers.core.PropertyProxy;
	import feathers.skins.IStyleProvider;
	import feathers.utils.skins.resetFluidChildDimensionsForMeasurement;
	import flash.geom.Point;
	import starling.display.DisplayObject;
	
	public class DefaultGroupedListHeaderOrFooterRenderer extends FeathersControl implements IGroupedListHeaderRenderer, IGroupedListFooterRenderer {
		public static const HORIZONTAL_ALIGN_LEFT:String = "left";
		
		public static const HORIZONTAL_ALIGN_CENTER:String = "center";
		
		public static const HORIZONTAL_ALIGN_RIGHT:String = "right";
		
		public static const HORIZONTAL_ALIGN_JUSTIFY:String = "justify";
		
		public static const VERTICAL_ALIGN_TOP:String = "top";
		
		public static const VERTICAL_ALIGN_MIDDLE:String = "middle";
		
		public static const VERTICAL_ALIGN_BOTTOM:String = "bottom";
		
		public static const VERTICAL_ALIGN_JUSTIFY:String = "justify";
		
		public static const DEFAULT_CHILD_STYLE_NAME_CONTENT_LABEL:String = "feathers-header-footer-renderer-content-label";
		
		public static var globalStyleProvider:IStyleProvider;
		
		private static const HELPER_POINT:Point = new Point();
		
		protected var contentLabelStyleName:String = "feathers-header-footer-renderer-content-label";
		
		protected var contentImage:ImageLoader;
		
		protected var contentLabel:ITextRenderer;
		
		protected var content:DisplayObject;
		
		protected var _data:Object;
		
		protected var _groupIndex:int = -1;
		
		protected var _layoutIndex:int = -1;
		
		protected var _owner:GroupedList;
		
		protected var _factoryID:String;
		
		protected var _horizontalAlign:String = "left";
		
		protected var _verticalAlign:String = "middle";
		
		protected var _contentField:String = "content";
		
		protected var _contentFunction:Function;
		
		protected var _contentSourceField:String = "source";
		
		protected var _contentSourceFunction:Function;
		
		protected var _contentLabelField:String = "label";
		
		protected var _contentLabelFunction:Function;
		
		protected var _contentLoaderFactory:Function = defaultImageLoaderFactory;
		
		protected var _contentLabelFactory:Function;
		
		protected var _customContentLabelStyleName:String;
		
		protected var _contentLabelProperties:PropertyProxy;
		
		protected var _explicitBackgroundWidth:Number;
		
		protected var _explicitBackgroundHeight:Number;
		
		protected var _explicitBackgroundMinWidth:Number;
		
		protected var _explicitBackgroundMinHeight:Number;
		
		protected var _explicitBackgroundMaxWidth:Number;
		
		protected var _explicitBackgroundMaxHeight:Number;
		
		protected var _explicitContentWidth:Number;
		
		protected var _explicitContentHeight:Number;
		
		protected var _explicitContentMinWidth:Number;
		
		protected var _explicitContentMinHeight:Number;
		
		protected var _explicitContentMaxWidth:Number;
		
		protected var _explicitContentMaxHeight:Number;
		
		protected var currentBackgroundSkin:DisplayObject;
		
		protected var _backgroundSkin:DisplayObject;
		
		protected var _backgroundDisabledSkin:DisplayObject;
		
		protected var _paddingTop:Number = 0;
		
		protected var _paddingRight:Number = 0;
		
		protected var _paddingBottom:Number = 0;
		
		protected var _paddingLeft:Number = 0;
		
		public function DefaultGroupedListHeaderOrFooterRenderer() {
			super();
		}
		
		protected static function defaultImageLoaderFactory() : ImageLoader {
			return new ImageLoader();
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return DefaultGroupedListHeaderOrFooterRenderer.globalStyleProvider;
		}
		
		public function get data() : Object {
			return this._data;
		}
		
		public function set data(value:Object) : void {
			if(this._data == value) {
				return;
			}
			this._data = value;
			this.invalidate("data");
		}
		
		public function get groupIndex() : int {
			return this._groupIndex;
		}
		
		public function set groupIndex(value:int) : void {
			this._groupIndex = value;
		}
		
		public function get layoutIndex() : int {
			return this._layoutIndex;
		}
		
		public function set layoutIndex(value:int) : void {
			this._layoutIndex = value;
		}
		
		public function get owner() : GroupedList {
			return this._owner;
		}
		
		public function set owner(value:GroupedList) : void {
			if(this._owner == value) {
				return;
			}
			this._owner = value;
			this.invalidate("data");
		}
		
		public function get factoryID() : String {
			return this._factoryID;
		}
		
		public function set factoryID(value:String) : void {
			this._factoryID = value;
		}
		
		public function get horizontalAlign() : String {
			return this._horizontalAlign;
		}
		
		public function set horizontalAlign(value:String) : void {
			if(this._horizontalAlign == value) {
				return;
			}
			this._horizontalAlign = value;
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
		
		public function get contentField() : String {
			return this._contentField;
		}
		
		public function set contentField(value:String) : void {
			if(this._contentField == value) {
				return;
			}
			this._contentField = value;
			this.invalidate("data");
		}
		
		public function get contentFunction() : Function {
			return this._contentFunction;
		}
		
		public function set contentFunction(value:Function) : void {
			if(this._contentFunction == value) {
				return;
			}
			this._contentFunction = value;
			this.invalidate("data");
		}
		
		public function get contentSourceField() : String {
			return this._contentSourceField;
		}
		
		public function set contentSourceField(value:String) : void {
			if(this._contentSourceField == value) {
				return;
			}
			this._contentSourceField = value;
			this.invalidate("data");
		}
		
		public function get contentSourceFunction() : Function {
			return this._contentSourceFunction;
		}
		
		public function set contentSourceFunction(value:Function) : void {
			if(this.contentSourceFunction == value) {
				return;
			}
			this._contentSourceFunction = value;
			this.invalidate("data");
		}
		
		public function get contentLabelField() : String {
			return this._contentLabelField;
		}
		
		public function set contentLabelField(value:String) : void {
			if(this._contentLabelField == value) {
				return;
			}
			this._contentLabelField = value;
			this.invalidate("data");
		}
		
		public function get contentLabelFunction() : Function {
			return this._contentLabelFunction;
		}
		
		public function set contentLabelFunction(value:Function) : void {
			if(this._contentLabelFunction == value) {
				return;
			}
			this._contentLabelFunction = value;
			this.invalidate("data");
		}
		
		public function get contentLoaderFactory() : Function {
			return this._contentLoaderFactory;
		}
		
		public function set contentLoaderFactory(value:Function) : void {
			if(this._contentLoaderFactory == value) {
				return;
			}
			this._contentLoaderFactory = value;
			this.invalidate("styles");
		}
		
		public function get contentLabelFactory() : Function {
			return this._contentLabelFactory;
		}
		
		public function set contentLabelFactory(value:Function) : void {
			if(this._contentLabelFactory == value) {
				return;
			}
			this._contentLabelFactory = value;
			this.invalidate("styles");
		}
		
		public function get customContentLabelStyleName() : String {
			return this._customContentLabelStyleName;
		}
		
		public function set customContentLabelStyleName(value:String) : void {
			if(this._customContentLabelStyleName == value) {
				return;
			}
			this._customContentLabelStyleName = value;
			this.invalidate("textRenderer");
		}
		
		public function get contentLabelProperties() : Object {
			if(!this._contentLabelProperties) {
				this._contentLabelProperties = new PropertyProxy(contentLabelProperties_onChange);
			}
			return this._contentLabelProperties;
		}
		
		public function set contentLabelProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._contentLabelProperties == value) {
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
			if(this._contentLabelProperties) {
				this._contentLabelProperties.removeOnChangeCallback(contentLabelProperties_onChange);
			}
			this._contentLabelProperties = PropertyProxy(value);
			if(this._contentLabelProperties) {
				this._contentLabelProperties.addOnChangeCallback(contentLabelProperties_onChange);
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
			if(this._backgroundSkin && this._backgroundSkin != this._backgroundDisabledSkin) {
				this.removeChild(this._backgroundSkin);
			}
			this._backgroundSkin = value;
			if(this._backgroundSkin && this._backgroundSkin.parent != this) {
				this._backgroundSkin.visible = false;
				this.addChildAt(this._backgroundSkin,0);
			}
			this.invalidate("styles");
		}
		
		public function get backgroundDisabledSkin() : DisplayObject {
			return this._backgroundDisabledSkin;
		}
		
		public function set backgroundDisabledSkin(value:DisplayObject) : void {
			if(this._backgroundDisabledSkin == value) {
				return;
			}
			if(this._backgroundDisabledSkin && this._backgroundDisabledSkin != this._backgroundSkin) {
				this.removeChild(this._backgroundDisabledSkin);
			}
			this._backgroundDisabledSkin = value;
			if(this._backgroundDisabledSkin && this._backgroundDisabledSkin.parent != this) {
				this._backgroundDisabledSkin.visible = false;
				this.addChildAt(this._backgroundDisabledSkin,0);
			}
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
		
		override public function dispose() : void {
			if(this.content) {
				this.content.removeFromParent();
			}
			if(this.contentImage) {
				this.contentImage.dispose();
				this.contentImage = null;
			}
			if(this.contentLabel) {
				DisplayObject(this.contentLabel).dispose();
				this.contentLabel = null;
			}
			super.dispose();
		}
		
		protected function itemToContent(item:Object) : DisplayObject {
			var _local2:Object = null;
			var _local3:Object = null;
			if(this._contentSourceFunction != null) {
				_local2 = this._contentSourceFunction(item);
				this.refreshContentSource(_local2);
				return this.contentImage;
			}
			if(this._contentSourceField != null && item && item.hasOwnProperty(this._contentSourceField)) {
				_local2 = item[this._contentSourceField];
				this.refreshContentSource(_local2);
				return this.contentImage;
			}
			if(this._contentLabelFunction != null) {
				_local3 = this._contentLabelFunction(item);
				if(_local3 is String) {
					this.refreshContentLabel(_local3 as String);
				} else if(_local3 !== null) {
					this.refreshContentLabel(_local3.toString());
				} else {
					this.refreshContentLabel(null);
				}
				return DisplayObject(this.contentLabel);
			}
			if(this._contentLabelField != null && item && item.hasOwnProperty(this._contentLabelField)) {
				_local3 = item[this._contentLabelField];
				if(_local3 is String) {
					this.refreshContentLabel(_local3 as String);
				} else if(_local3 !== null) {
					this.refreshContentLabel(_local3.toString());
				} else {
					this.refreshContentLabel(null);
				}
				return DisplayObject(this.contentLabel);
			}
			if(this._contentFunction != null) {
				return this._contentFunction(item) as DisplayObject;
			}
			if(this._contentField != null && item && item.hasOwnProperty(this._contentField)) {
				return item[this._contentField] as DisplayObject;
			}
			if(item is String) {
				this.refreshContentLabel(item as String);
				return DisplayObject(this.contentLabel);
			}
			if(item !== null) {
				this.refreshContentLabel(item.toString());
				return DisplayObject(this.contentLabel);
			}
			this.refreshContentLabel(null);
			return null;
		}
		
		override protected function draw() : void {
			var _local3:Boolean = this.isInvalid("data");
			var _local4:Boolean = this.isInvalid("styles");
			var _local2:Boolean = this.isInvalid("state");
			var _local1:Boolean = this.isInvalid("size");
			if(_local4 || _local2) {
				this.refreshBackgroundSkin();
			}
			if(_local3) {
				this.commitData();
			}
			if(_local3 || _local4) {
				this.refreshContentLabelStyles();
			}
			if(_local3 || _local2) {
				this.refreshEnabled();
			}
			_local1 = this.autoSizeIfNeeded() || _local1;
			this.layoutChildren();
		}
		
		protected function autoSizeIfNeeded() : Boolean {
			var _local5:Number = NaN;
			var _local3:* = this._explicitWidth !== this._explicitWidth;
			var _local9:* = this._explicitHeight !== this._explicitHeight;
			var _local4:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local11:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local3 && !_local9 && !_local4 && !_local11) {
				return false;
			}
			var _local6:IMeasureDisplayObject = this.content as IMeasureDisplayObject;
			if(this.contentLabel !== null) {
				_local5 = this._explicitWidth;
				if(_local3) {
					_local5 = this._explicitMaxWidth;
				}
				this.contentLabel.maxWidth = _local5 - this._paddingLeft - this._paddingRight;
				this.contentLabel.measureText(HELPER_POINT);
			} else if(this.content !== null) {
				if(this._horizontalAlign === "justify" && this._verticalAlign === "justify") {
					resetFluidChildDimensionsForMeasurement(this.content,this._explicitWidth - this._paddingLeft - this._paddingRight,this._explicitHeight - this._paddingTop - this._paddingBottom,this._explicitMinWidth - this._paddingLeft - this._paddingRight,this._explicitMinHeight - this._paddingTop - this._paddingBottom,this._explicitMaxWidth - this._paddingLeft - this._paddingRight,this._explicitMaxHeight - this._paddingTop - this._paddingBottom,this._explicitContentWidth,this._explicitContentHeight,this._explicitContentMinWidth,this._explicitContentMinHeight,this._explicitContentMaxWidth,this._explicitContentMaxHeight);
				} else {
					this.content.width = this._explicitContentWidth;
					this.content.height = this._explicitContentHeight;
					if(_local6 !== null) {
						_local6.minWidth = this._explicitContentMinWidth;
						_local6.minHeight = this._explicitContentMinHeight;
					}
				}
				if(this.content is IValidating) {
					IValidating(this.content).validate();
				}
			}
			resetFluidChildDimensionsForMeasurement(this.currentBackgroundSkin,this._explicitWidth,this._explicitHeight,this._explicitMinWidth,this._explicitMinHeight,this._explicitMaxWidth,this._explicitMaxHeight,this._explicitBackgroundWidth,this._explicitBackgroundHeight,this._explicitBackgroundMinWidth,this._explicitBackgroundMinHeight,this._explicitBackgroundMaxWidth,this._explicitBackgroundMaxHeight);
			var _local10:IMeasureDisplayObject = this.currentBackgroundSkin as IMeasureDisplayObject;
			var _local2:Number = this._explicitWidth;
			if(_local3) {
				if(this.contentLabel !== null) {
					_local2 = HELPER_POINT.x;
				} else if(this.content !== null) {
					_local2 = this.content.width;
				} else {
					_local2 = 0;
				}
				_local2 += this._paddingLeft + this._paddingRight;
				if(this.currentBackgroundSkin !== null && this.currentBackgroundSkin.width > _local2) {
					_local2 = this.currentBackgroundSkin.width;
				}
			}
			var _local7:Number = this._explicitHeight;
			if(_local9) {
				if(this.contentLabel !== null) {
					_local7 = HELPER_POINT.y;
				} else if(this.content !== null) {
					_local7 = this.content.height;
				} else {
					_local7 = 0;
				}
				_local7 += this._paddingTop + this._paddingBottom;
				if(this.currentBackgroundSkin !== null && this.currentBackgroundSkin.height > _local7) {
					_local7 = this.currentBackgroundSkin.height;
				}
			}
			var _local1:Number = this._explicitMinWidth;
			if(_local4) {
				if(this.contentLabel !== null) {
					_local1 = HELPER_POINT.x;
				} else if(_local6 !== null) {
					_local1 = _local6.minWidth;
				} else if(this.content !== null) {
					_local1 = this.content.width;
				} else {
					_local1 = 0;
				}
				_local1 += this._paddingLeft + this._paddingRight;
				switch(_local10) {
					default:
						if(_local10.minWidth > _local1) {
							_local1 = _local10.minWidth;
						}
						break;
					case null:
						if(this._explicitBackgroundMinWidth > _local1) {
							_local1 = this._explicitBackgroundMinWidth;
						}
						break;
					case null:
				}
			}
			var _local8:Number = this._explicitMinHeight;
			if(_local11) {
				if(this.contentLabel !== null) {
					_local8 = HELPER_POINT.y;
				} else if(_local6 !== null) {
					_local8 = _local6.minHeight;
				} else if(this.content !== null) {
					_local8 = this.content.height;
				} else {
					_local8 = 0;
				}
				_local8 += this._paddingTop + this._paddingBottom;
				switch(_local10) {
					default:
						if(_local10.minHeight > _local8) {
							_local8 = _local10.minHeight;
						}
						break;
					case null:
						if(this._explicitBackgroundMinHeight > _local8) {
							_local8 = this._explicitBackgroundMinHeight;
						}
						break;
					case null:
				}
			}
			return this.saveMeasurements(_local2,_local7,_local1,_local8);
		}
		
		protected function refreshBackgroundSkin() : void {
			var _local1:IMeasureDisplayObject = null;
			this.currentBackgroundSkin = this._backgroundSkin;
			if(!this._isEnabled && this._backgroundDisabledSkin !== null) {
				if(this._backgroundSkin !== null) {
					this._backgroundSkin.visible = false;
				}
				this.currentBackgroundSkin = this._backgroundDisabledSkin;
			} else if(this._backgroundDisabledSkin !== null) {
				this._backgroundDisabledSkin.visible = false;
			}
			if(this.currentBackgroundSkin !== null) {
				this.currentBackgroundSkin.visible = true;
				if(this.currentBackgroundSkin is IFeathersControl) {
					IFeathersControl(this.currentBackgroundSkin).initializeNow();
				}
				if(this.currentBackgroundSkin is IMeasureDisplayObject) {
					_local1 = IMeasureDisplayObject(this.currentBackgroundSkin);
					this._explicitBackgroundWidth = _local1.explicitWidth;
					this._explicitBackgroundHeight = _local1.explicitHeight;
					this._explicitBackgroundMinWidth = _local1.explicitMinWidth;
					this._explicitBackgroundMinHeight = _local1.explicitMinHeight;
					this._explicitBackgroundMaxWidth = _local1.explicitMaxWidth;
					this._explicitBackgroundMaxHeight = _local1.explicitMaxHeight;
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
		
		protected function commitData() : void {
			var _local1:DisplayObject = null;
			var _local2:IMeasureDisplayObject = null;
			if(this._owner) {
				_local1 = this.itemToContent(this._data);
				switch(_local1) {
					default:
						this.content.removeFromParent();
					case null:
						this.content = _local1;
						if(this.content !== null) {
							this.addChild(this.content);
							if(this.content is IFeathersControl) {
								IFeathersControl(this.content).initializeNow();
							}
							if(this.content is IMeasureDisplayObject) {
								_local2 = IMeasureDisplayObject(this.content);
								this._explicitContentWidth = _local2.explicitWidth;
								this._explicitContentHeight = _local2.explicitHeight;
								this._explicitContentMinWidth = _local2.explicitMinWidth;
								this._explicitContentMinHeight = _local2.explicitMinHeight;
								this._explicitContentMaxWidth = _local2.explicitMaxWidth;
								this._explicitContentMaxHeight = _local2.explicitMaxHeight;
								break;
							}
							this._explicitContentWidth = this.content.width;
							this._explicitContentHeight = this.content.height;
							this._explicitContentMinWidth = this._explicitContentWidth;
							this._explicitContentMinHeight = this._explicitContentHeight;
							this._explicitContentMaxWidth = this._explicitContentWidth;
							this._explicitContentMaxHeight = this._explicitContentHeight;
						}
						break;
					case this.content:
				}
			} else if(this.content) {
				this.content.removeFromParent();
				this.content = null;
			}
		}
		
		protected function refreshContentSource(source:Object) : void {
			if(!this.contentImage) {
				this.contentImage = this._contentLoaderFactory();
			}
			this.contentImage.source = source;
		}
		
		protected function refreshContentLabel(label:String) : void {
			var _local2:Function = null;
			var _local3:String = null;
			if(label !== null) {
				if(this.contentLabel === null) {
					_local2 = this._contentLabelFactory != null ? this._contentLabelFactory : FeathersControl.defaultTextRendererFactory;
					this.contentLabel = ITextRenderer(_local2());
					_local3 = this._customContentLabelStyleName != null ? this._customContentLabelStyleName : this.contentLabelStyleName;
					FeathersControl(this.contentLabel).styleNameList.add(_local3);
				}
				this.contentLabel.text = label;
			} else if(this.contentLabel !== null) {
				DisplayObject(this.contentLabel).removeFromParent(true);
				this.contentLabel = null;
			}
		}
		
		protected function refreshEnabled() : void {
			if(this.content is IFeathersControl) {
				IFeathersControl(this.content).isEnabled = this._isEnabled;
			}
		}
		
		protected function refreshContentLabelStyles() : void {
			var _local2:Object = null;
			if(!this.contentLabel) {
				return;
			}
			for(var _local1 in this._contentLabelProperties) {
				_local2 = this._contentLabelProperties[_local1];
				this.contentLabel[_local1] = _local2;
			}
		}
		
		protected function layoutChildren() : void {
			if(this.currentBackgroundSkin !== null) {
				this.currentBackgroundSkin.width = this.actualWidth;
				this.currentBackgroundSkin.height = this.actualHeight;
			}
			if(this.content === null) {
				return;
			}
			if(this.contentLabel !== null) {
				this.contentLabel.maxWidth = this.actualWidth - this._paddingLeft - this._paddingRight;
			}
			if(this.content is IValidating) {
				IValidating(this.content).validate();
			}
			switch(this._horizontalAlign) {
				case "center":
					this.content.x = this._paddingLeft + (this.actualWidth - this._paddingLeft - this._paddingRight - this.content.width) / 2;
					break;
				case "right":
					this.content.x = this.actualWidth - this._paddingRight - this.content.width;
					break;
				case "justify":
					this.content.x = this._paddingLeft;
					this.content.width = this.actualWidth - this._paddingLeft - this._paddingRight;
					break;
				default:
					this.content.x = this._paddingLeft;
			}
			switch(this._verticalAlign) {
				case "top":
					this.content.y = this._paddingTop;
					break;
				case "bottom":
					this.content.y = this.actualHeight - this._paddingBottom - this.content.height;
					break;
				case "justify":
					this.content.y = this._paddingTop;
					this.content.height = this.actualHeight - this._paddingTop - this._paddingBottom;
					break;
				default:
					this.content.y = this._paddingTop + (this.actualHeight - this._paddingTop - this._paddingBottom - this.content.height) / 2;
			}
		}
		
		protected function contentLabelProperties_onChange(proxy:PropertyProxy, name:String) : void {
			this.invalidate("styles");
		}
	}
}

