package feathers.controls {
	import feathers.core.FeathersControl;
	import feathers.core.IFeathersControl;
	import feathers.core.IMeasureDisplayObject;
	import feathers.core.IValidating;
	import feathers.skins.IStyleProvider;
	import feathers.utils.math.clamp;
	import feathers.utils.skins.resetFluidChildDimensionsForMeasurement;
	import starling.display.DisplayObject;
	
	public class ProgressBar extends FeathersControl {
		public static const DIRECTION_HORIZONTAL:String = "horizontal";
		
		public static const DIRECTION_VERTICAL:String = "vertical";
		
		public static var globalStyleProvider:IStyleProvider;
		
		protected var _direction:String = "horizontal";
		
		protected var _value:Number = 0;
		
		protected var _minimum:Number = 0;
		
		protected var _maximum:Number = 1;
		
		protected var _explicitBackgroundWidth:Number;
		
		protected var _explicitBackgroundHeight:Number;
		
		protected var _explicitBackgroundMinWidth:Number;
		
		protected var _explicitBackgroundMinHeight:Number;
		
		protected var _explicitBackgroundMaxWidth:Number;
		
		protected var _explicitBackgroundMaxHeight:Number;
		
		protected var currentBackground:DisplayObject;
		
		protected var _backgroundSkin:DisplayObject;
		
		protected var _backgroundDisabledSkin:DisplayObject;
		
		protected var _originalFillWidth:Number = NaN;
		
		protected var _originalFillHeight:Number = NaN;
		
		protected var currentFill:DisplayObject;
		
		protected var _fillSkin:DisplayObject;
		
		protected var _fillDisabledSkin:DisplayObject;
		
		protected var _paddingTop:Number = 0;
		
		protected var _paddingRight:Number = 0;
		
		protected var _paddingBottom:Number = 0;
		
		protected var _paddingLeft:Number = 0;
		
		public function ProgressBar() {
			super();
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return ProgressBar.globalStyleProvider;
		}
		
		public function get direction() : String {
			return this._direction;
		}
		
		public function set direction(value:String) : void {
			if(this._direction == value) {
				return;
			}
			this._direction = value;
			this.invalidate("data");
		}
		
		public function get value() : Number {
			return this._value;
		}
		
		public function set value(newValue:Number) : void {
			newValue = clamp(newValue,this._minimum,this._maximum);
			if(this._value == newValue) {
				return;
			}
			this._value = newValue;
			this.invalidate("data");
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
		
		public function get fillSkin() : DisplayObject {
			return this._fillSkin;
		}
		
		public function set fillSkin(value:DisplayObject) : void {
			if(this._fillSkin == value) {
				return;
			}
			if(this._fillSkin && this._fillSkin != this._fillDisabledSkin) {
				this.removeChild(this._fillSkin);
			}
			this._fillSkin = value;
			if(this._fillSkin && this._fillSkin.parent != this) {
				this._fillSkin.visible = false;
				this.addChild(this._fillSkin);
			}
			this.invalidate("styles");
		}
		
		public function get fillDisabledSkin() : DisplayObject {
			return this._fillDisabledSkin;
		}
		
		public function set fillDisabledSkin(value:DisplayObject) : void {
			if(this._fillDisabledSkin == value) {
				return;
			}
			if(this._fillDisabledSkin && this._fillDisabledSkin != this._fillSkin) {
				this.removeChild(this._fillDisabledSkin);
			}
			this._fillDisabledSkin = value;
			if(this._fillDisabledSkin && this._fillDisabledSkin.parent != this) {
				this._fillDisabledSkin.visible = false;
				this.addChild(this._fillDisabledSkin);
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
		
		override protected function draw() : void {
			var _local3:Boolean = this.isInvalid("styles");
			var _local2:Boolean = this.isInvalid("state");
			var _local1:Boolean = this.isInvalid("size");
			if(_local3 || _local2) {
				this.refreshBackground();
				this.refreshFill();
			}
			this.autoSizeIfNeeded();
			this.layoutChildren();
			if(this.currentBackground is IValidating) {
				IValidating(this.currentBackground).validate();
			}
			if(this.currentFill is IValidating) {
				IValidating(this.currentFill).validate();
			}
		}
		
		protected function autoSizeIfNeeded() : Boolean {
			var _local13:Number = NaN;
			var _local6:Number = NaN;
			var _local2:Number = NaN;
			var _local10:Number = NaN;
			var _local3:* = this._explicitWidth !== this._explicitWidth;
			var _local11:* = this._explicitHeight !== this._explicitHeight;
			var _local8:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local12:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local3 && !_local11 && !_local8 && !_local12) {
				return false;
			}
			var _local5:IMeasureDisplayObject = this.currentBackground as IMeasureDisplayObject;
			resetFluidChildDimensionsForMeasurement(this.currentBackground,this._explicitWidth,this._explicitHeight,this._explicitMinWidth,this._explicitMinHeight,this._explicitMaxWidth,this._explicitMaxHeight,this._explicitBackgroundWidth,this._explicitBackgroundHeight,this._explicitBackgroundMinWidth,this._explicitBackgroundMinHeight,this._explicitBackgroundMaxWidth,this._explicitBackgroundMaxHeight);
			if(this.currentBackground is IValidating) {
				IValidating(this.currentBackground).validate();
			}
			if(this.currentFill is IValidating) {
				IValidating(this.currentFill).validate();
			}
			var _local7:* = this._explicitMinWidth;
			if(_local8) {
				if(_local5 !== null) {
					_local7 = _local5.minWidth;
				} else if(this.currentBackground !== null) {
					_local7 = this._explicitBackgroundMinWidth;
				} else {
					_local7 = 0;
				}
				_local13 = this._originalFillWidth;
				if(this.currentFill is IFeathersControl) {
					_local13 = Number(IFeathersControl(this.currentFill).minWidth);
				}
				_local13 += this._paddingLeft + this._paddingRight;
				if(_local13 > _local7) {
					_local7 = _local13;
				}
			}
			var _local9:* = this._explicitMinHeight;
			if(_local12) {
				if(_local5 !== null) {
					_local9 = _local5.minHeight;
				} else if(this.currentBackground !== null) {
					_local9 = this._explicitBackgroundMinHeight;
				} else {
					_local9 = 0;
				}
				_local6 = this._originalFillHeight;
				if(this.currentFill is IFeathersControl) {
					_local6 = Number(IFeathersControl(this.currentFill).minHeight);
				}
				_local6 += this._paddingTop + this._paddingBottom;
				if(_local6 > _local9) {
					_local9 = _local6;
				}
			}
			var _local1:* = this._explicitWidth;
			if(_local3) {
				if(this.currentBackground !== null) {
					_local1 = this.currentBackground.width;
				} else {
					_local1 = 0;
				}
				_local2 = this._originalFillWidth + this._paddingLeft + this._paddingRight;
				if(_local2 > _local1) {
					_local1 = _local2;
				}
			}
			var _local4:* = this._explicitHeight;
			if(_local11) {
				if(this.currentBackground !== null) {
					_local4 = this.currentBackground.height;
				} else {
					_local4 = 0;
				}
				_local10 = this._originalFillHeight + this._paddingTop + this._paddingBottom;
				if(_local10 > _local4) {
					_local4 = _local10;
				}
			}
			return this.saveMeasurements(_local1,_local4,_local7,_local9);
		}
		
		protected function refreshBackground() : void {
			var _local1:IMeasureDisplayObject = null;
			this.currentBackground = this._backgroundSkin;
			if(this._backgroundDisabledSkin !== null) {
				if(this._isEnabled) {
					this._backgroundDisabledSkin.visible = false;
				} else {
					this.currentBackground = this._backgroundDisabledSkin;
					if(this._backgroundSkin !== null) {
						this._backgroundSkin.visible = false;
					}
				}
			}
			if(this.currentBackground !== null) {
				this.currentBackground.visible = true;
				if(this.currentBackground is IFeathersControl) {
					IFeathersControl(this.currentBackground).initializeNow();
				}
				if(this.currentBackground is IMeasureDisplayObject) {
					_local1 = IMeasureDisplayObject(this.currentBackground);
					this._explicitBackgroundWidth = _local1.explicitWidth;
					this._explicitBackgroundHeight = _local1.explicitHeight;
					this._explicitBackgroundMinWidth = _local1.explicitMinWidth;
					this._explicitBackgroundMinHeight = _local1.explicitMinHeight;
					this._explicitBackgroundMaxWidth = _local1.explicitMaxWidth;
					this._explicitBackgroundMaxHeight = _local1.explicitMaxHeight;
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
		
		protected function refreshFill() : void {
			this.currentFill = this._fillSkin;
			if(this._fillDisabledSkin) {
				if(this._isEnabled) {
					this._fillDisabledSkin.visible = false;
				} else {
					this.currentFill = this._fillDisabledSkin;
					if(this._backgroundSkin) {
						this._fillSkin.visible = false;
					}
				}
			}
			if(this.currentFill) {
				if(this.currentFill is IValidating) {
					IValidating(this.currentFill).validate();
				}
				if(this._originalFillWidth !== this._originalFillWidth) {
					this._originalFillWidth = this.currentFill.width;
				}
				if(this._originalFillHeight !== this._originalFillHeight) {
					this._originalFillHeight = this.currentFill.height;
				}
				this.currentFill.visible = true;
			}
		}
		
		protected function layoutChildren() : void {
			var _local1:Number = NaN;
			if(this.currentBackground) {
				this.currentBackground.width = this.actualWidth;
				this.currentBackground.height = this.actualHeight;
			}
			if(this._minimum === this._maximum) {
				_local1 = 1;
			} else {
				_local1 = (this._value - this._minimum) / (this._maximum - this._minimum);
				if(_local1 < 0) {
					_local1 = 0;
				} else if(_local1 > 1) {
					_local1 = 1;
				}
			}
			if(this._direction === "vertical") {
				this.currentFill.width = this.actualWidth - this._paddingLeft - this._paddingRight;
				this.currentFill.height = Math.round(this._originalFillHeight + _local1 * (this.actualHeight - this._paddingTop - this._paddingBottom - this._originalFillHeight));
				this.currentFill.x = this._paddingLeft;
				this.currentFill.y = this.actualHeight - this._paddingBottom - this.currentFill.height;
			} else {
				this.currentFill.width = Math.round(this._originalFillWidth + _local1 * (this.actualWidth - this._paddingLeft - this._paddingRight - this._originalFillWidth));
				this.currentFill.height = this.actualHeight - this._paddingTop - this._paddingBottom;
				this.currentFill.x = this._paddingLeft;
				this.currentFill.y = this._paddingTop;
			}
		}
	}
}

