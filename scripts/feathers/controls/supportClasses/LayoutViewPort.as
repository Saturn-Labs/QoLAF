package feathers.controls.supportClasses {
	import feathers.controls.LayoutGroup;
	import feathers.core.IValidating;
	import feathers.layout.ILayoutDisplayObject;
	import starling.display.DisplayObject;
	
	public class LayoutViewPort extends LayoutGroup implements IViewPort {
		private var _actualMinVisibleWidth:Number = 0;
		
		private var _explicitMinVisibleWidth:Number;
		
		private var _maxVisibleWidth:Number = Infinity;
		
		private var _actualVisibleWidth:Number = 0;
		
		private var _explicitVisibleWidth:Number;
		
		private var _actualMinVisibleHeight:Number = 0;
		
		private var _explicitMinVisibleHeight:Number;
		
		private var _maxVisibleHeight:Number = Infinity;
		
		private var _actualVisibleHeight:Number = 0;
		
		private var _explicitVisibleHeight:Number;
		
		private var _contentX:Number = 0;
		
		private var _contentY:Number = 0;
		
		private var _horizontalScrollPosition:Number = 0;
		
		private var _verticalScrollPosition:Number = 0;
		
		public function LayoutViewPort() {
			super();
		}
		
		public function get minVisibleWidth() : Number {
			if(this._explicitMinVisibleWidth !== this._explicitMinVisibleWidth) {
				return this._actualMinVisibleWidth;
			}
			return this._explicitMinVisibleWidth;
		}
		
		public function set minVisibleWidth(value:Number) : void {
			if(this._explicitMinVisibleWidth == value) {
				return;
			}
			var _local2:* = value !== value;
			if(_local2 && this._explicitMinVisibleWidth !== this._explicitMinVisibleWidth) {
				return;
			}
			var _local3:Number = this._explicitMinVisibleWidth;
			this._explicitMinVisibleWidth = value;
			if(_local2) {
				this._actualMinVisibleWidth = 0;
				this.invalidate("size");
			} else {
				this._actualMinVisibleWidth = value;
				if(this._explicitVisibleWidth !== this._explicitVisibleWidth && (this._actualVisibleWidth < value || this._actualVisibleWidth === _local3)) {
					this.invalidate("size");
				}
			}
		}
		
		public function get maxVisibleWidth() : Number {
			return this._maxVisibleWidth;
		}
		
		public function set maxVisibleWidth(value:Number) : void {
			if(this._maxVisibleWidth == value) {
				return;
			}
			if(value !== value) {
				throw new ArgumentError("maxVisibleWidth cannot be NaN");
			}
			var _local2:Number = this._maxVisibleWidth;
			this._maxVisibleWidth = value;
			if(this._explicitVisibleWidth !== this._explicitVisibleWidth && (this._actualVisibleWidth > value || this._actualVisibleWidth === _local2)) {
				this.invalidate("size");
			}
		}
		
		public function get visibleWidth() : Number {
			if(this._explicitVisibleWidth !== this._explicitVisibleWidth) {
				return this._actualVisibleWidth;
			}
			return this._explicitVisibleWidth;
		}
		
		public function set visibleWidth(value:Number) : void {
			if(this._explicitVisibleWidth == value || value !== value && this._explicitVisibleWidth !== this._explicitVisibleWidth) {
				return;
			}
			this._explicitVisibleWidth = value;
			if(this._actualVisibleWidth !== value) {
				this.invalidate("size");
			}
		}
		
		public function get minVisibleHeight() : Number {
			if(this._explicitMinVisibleHeight !== this._explicitMinVisibleHeight) {
				return this._actualMinVisibleHeight;
			}
			return this._explicitMinVisibleHeight;
		}
		
		public function set minVisibleHeight(value:Number) : void {
			if(this._explicitMinVisibleHeight == value) {
				return;
			}
			var _local2:* = value !== value;
			if(_local2 && this._explicitMinVisibleHeight !== this._explicitMinVisibleHeight) {
				return;
			}
			var _local3:Number = this._explicitMinVisibleHeight;
			this._explicitMinVisibleHeight = value;
			if(_local2) {
				this._actualMinVisibleHeight = 0;
				this.invalidate("size");
			} else {
				this._actualMinVisibleHeight = value;
				if(this._explicitVisibleHeight !== this._explicitVisibleHeight && (this._actualVisibleHeight < value || this._actualVisibleHeight === _local3)) {
					this.invalidate("size");
				}
			}
		}
		
		public function get maxVisibleHeight() : Number {
			return this._maxVisibleHeight;
		}
		
		public function set maxVisibleHeight(value:Number) : void {
			if(this._maxVisibleHeight == value) {
				return;
			}
			if(value !== value) {
				throw new ArgumentError("maxVisibleHeight cannot be NaN");
			}
			var _local2:Number = this._maxVisibleHeight;
			this._maxVisibleHeight = value;
			if(this._explicitVisibleHeight !== this._explicitVisibleHeight && (this._actualVisibleHeight > value || this._actualVisibleHeight === _local2)) {
				this.invalidate("size");
			}
		}
		
		public function get visibleHeight() : Number {
			if(this._explicitVisibleHeight !== this._explicitVisibleHeight) {
				return this._actualVisibleHeight;
			}
			return this._explicitVisibleHeight;
		}
		
		public function set visibleHeight(value:Number) : void {
			if(this._explicitVisibleHeight == value || value !== value && this._explicitVisibleHeight !== this._explicitVisibleHeight) {
				return;
			}
			this._explicitVisibleHeight = value;
			if(this._actualVisibleHeight !== value) {
				this.invalidate("size");
			}
		}
		
		public function get contentX() : Number {
			return this._contentX;
		}
		
		public function get contentY() : Number {
			return this._contentY;
		}
		
		public function get horizontalScrollStep() : Number {
			if(this.actualWidth < this.actualHeight) {
				return this.actualWidth / 10;
			}
			return this.actualHeight / 10;
		}
		
		public function get verticalScrollStep() : Number {
			if(this.actualWidth < this.actualHeight) {
				return this.actualWidth / 10;
			}
			return this.actualHeight / 10;
		}
		
		public function get horizontalScrollPosition() : Number {
			return this._horizontalScrollPosition;
		}
		
		public function set horizontalScrollPosition(value:Number) : void {
			if(this._horizontalScrollPosition == value) {
				return;
			}
			this._horizontalScrollPosition = value;
			this.invalidate("scroll");
		}
		
		public function get verticalScrollPosition() : Number {
			return this._verticalScrollPosition;
		}
		
		public function set verticalScrollPosition(value:Number) : void {
			if(this._verticalScrollPosition == value) {
				return;
			}
			this._verticalScrollPosition = value;
			this.invalidate("scroll");
		}
		
		public function get requiresMeasurementOnScroll() : Boolean {
			return this._layout !== null && this._layout.requiresLayoutOnScroll && (this._explicitVisibleWidth !== this._explicitVisibleWidth || this._explicitVisibleHeight !== this._explicitVisibleHeight);
		}
		
		override public function dispose() : void {
			this.layout = null;
			super.dispose();
		}
		
		override protected function refreshViewPortBounds() : void {
			var _local1:* = this._explicitVisibleWidth !== this._explicitVisibleWidth;
			var _local3:* = this._explicitVisibleHeight !== this._explicitVisibleHeight;
			var _local2:* = this._explicitMinVisibleWidth !== this._explicitMinVisibleWidth;
			var _local4:* = this._explicitMinVisibleHeight !== this._explicitMinVisibleHeight;
			this.viewPortBounds.x = 0;
			this.viewPortBounds.y = 0;
			this.viewPortBounds.scrollX = this._horizontalScrollPosition;
			this.viewPortBounds.scrollY = this._verticalScrollPosition;
			if(this._autoSizeMode === "stage" && _local1) {
				this.viewPortBounds.explicitWidth = this.stage.stageWidth;
			} else {
				this.viewPortBounds.explicitWidth = this._explicitVisibleWidth;
			}
			if(this._autoSizeMode === "stage" && _local3) {
				this.viewPortBounds.explicitHeight = this.stage.stageHeight;
			} else {
				this.viewPortBounds.explicitHeight = this._explicitVisibleHeight;
			}
			if(_local2) {
				this.viewPortBounds.minWidth = 0;
			} else {
				this.viewPortBounds.minWidth = this._explicitMinVisibleWidth;
			}
			if(_local4) {
				this.viewPortBounds.minHeight = 0;
			} else {
				this.viewPortBounds.minHeight = this._explicitMinVisibleHeight;
			}
			this.viewPortBounds.maxWidth = this._maxVisibleWidth;
			this.viewPortBounds.maxHeight = this._maxVisibleHeight;
		}
		
		override protected function handleLayoutResult() : void {
			var _local1:Number = this._layoutResult.contentWidth;
			var _local4:Number = this._layoutResult.contentHeight;
			this.saveMeasurements(_local1,_local4,_local1,_local4);
			this._contentX = this._layoutResult.contentX;
			this._contentY = this._layoutResult.contentY;
			var _local2:Number = this._layoutResult.viewPortWidth;
			var _local3:Number = this._layoutResult.viewPortHeight;
			this._actualVisibleWidth = _local2;
			this._actualVisibleHeight = _local3;
			this._actualMinVisibleWidth = _local2;
			this._actualMinVisibleHeight = _local3;
		}
		
		override protected function handleManualLayout() : void {
			var _local7:int = 0;
			var _local1:DisplayObject = null;
			var _local16:Number = NaN;
			var _local18:Number = NaN;
			var _local9:Number = NaN;
			var _local3:Number = NaN;
			var _local14:* = 0;
			var _local13:* = 0;
			var _local17:Number;
			var _local5:* = _local17 = this.viewPortBounds.explicitWidth;
			this.doNothing();
			if(_local5 !== _local5) {
				_local5 = 0;
			}
			var _local6:Number;
			var _local4:* = _local6 = this.viewPortBounds.explicitHeight;
			this.doNothing();
			if(_local4 !== _local4) {
				_local4 = 0;
			}
			this._ignoreChildChanges = true;
			var _local11:int = int(this.items.length);
			_local7 = 0;
			while(_local7 < _local11) {
				_local1 = this.items[_local7];
				if(!(_local1 is ILayoutDisplayObject && !ILayoutDisplayObject(_local1).includeInLayout)) {
					if(_local1 is IValidating) {
						IValidating(_local1).validate();
					}
					_local16 = _local1.x;
					_local18 = _local1.y;
					_local9 = _local16 + _local1.width;
					_local3 = _local18 + _local1.height;
					if(_local16 === _local16 && _local16 < _local14) {
						_local14 = _local16;
					}
					if(_local18 === _local18 && _local18 < _local13) {
						_local13 = _local18;
					}
					if(_local9 === _local9 && _local9 > _local5) {
						_local5 = _local9;
					}
					if(_local3 === _local3 && _local3 > _local4) {
						_local4 = _local3;
					}
				}
				_local7++;
			}
			this._contentX = _local14;
			this._contentY = _local13;
			var _local8:Number = this.viewPortBounds.minWidth;
			var _local19:Number = this.viewPortBounds.maxWidth;
			var _local12:Number = this.viewPortBounds.minHeight;
			var _local15:Number = this.viewPortBounds.maxHeight;
			var _local2:* = _local5 - _local14;
			if(_local2 < _local8) {
				_local2 = _local8;
			} else if(_local2 > _local19) {
				_local2 = _local19;
			}
			var _local10:* = _local4 - _local13;
			if(_local10 < _local12) {
				_local10 = _local12;
			} else if(_local10 > _local15) {
				_local10 = _local15;
			}
			this._ignoreChildChanges = false;
			if(_local17 !== _local17) {
				this._actualVisibleWidth = _local2;
			} else {
				this._actualVisibleWidth = _local17;
			}
			if(_local6 !== _local6) {
				this._actualVisibleHeight = _local10;
			} else {
				this._actualVisibleHeight = _local6;
			}
			this._layoutResult.contentX = 0;
			this._layoutResult.contentY = 0;
			this._layoutResult.contentWidth = _local2;
			this._layoutResult.contentHeight = _local10;
			this._layoutResult.viewPortWidth = _local2;
			this._layoutResult.viewPortHeight = _local10;
		}
		
		protected function doNothing() : void {
		}
	}
}

