package feathers.layout {
	import feathers.core.IFeathersControl;
	import feathers.core.IValidating;
	import flash.errors.IllegalOperationError;
	import flash.geom.Point;
	import starling.display.DisplayObject;
	import starling.events.EventDispatcher;
	
	public class VerticalSpinnerLayout extends EventDispatcher implements ISpinnerLayout, ITrimmedVirtualLayout {
		public static const HORIZONTAL_ALIGN_LEFT:String = "left";
		
		public static const HORIZONTAL_ALIGN_CENTER:String = "center";
		
		public static const HORIZONTAL_ALIGN_RIGHT:String = "right";
		
		public static const HORIZONTAL_ALIGN_JUSTIFY:String = "justify";
		
		protected var _discoveredItemsCache:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
		
		protected var _gap:Number = 0;
		
		protected var _paddingRight:Number = 0;
		
		protected var _paddingLeft:Number = 0;
		
		protected var _horizontalAlign:String = "justify";
		
		protected var _useVirtualLayout:Boolean = true;
		
		protected var _requestedRowCount:int = 0;
		
		protected var _beforeVirtualizedItemCount:int = 0;
		
		protected var _afterVirtualizedItemCount:int = 0;
		
		protected var _typicalItem:DisplayObject;
		
		protected var _resetTypicalItemDimensionsOnMeasure:Boolean = false;
		
		protected var _typicalItemWidth:Number = NaN;
		
		protected var _typicalItemHeight:Number = NaN;
		
		protected var _repeatItems:Boolean = true;
		
		public function VerticalSpinnerLayout() {
			super();
		}
		
		public function get gap() : Number {
			return this._gap;
		}
		
		public function set gap(value:Number) : void {
			if(this._gap == value) {
				return;
			}
			this._gap = value;
			this.dispatchEventWith("change");
		}
		
		public function get padding() : Number {
			return this._paddingLeft;
		}
		
		public function set padding(value:Number) : void {
			this.paddingRight = value;
			this.paddingLeft = value;
		}
		
		public function get paddingRight() : Number {
			return this._paddingRight;
		}
		
		public function set paddingRight(value:Number) : void {
			if(this._paddingRight == value) {
				return;
			}
			this._paddingRight = value;
			this.dispatchEventWith("change");
		}
		
		public function get paddingLeft() : Number {
			return this._paddingLeft;
		}
		
		public function set paddingLeft(value:Number) : void {
			if(this._paddingLeft == value) {
				return;
			}
			this._paddingLeft = value;
			this.dispatchEventWith("change");
		}
		
		public function get horizontalAlign() : String {
			return this._horizontalAlign;
		}
		
		public function set horizontalAlign(value:String) : void {
			if(this._horizontalAlign == value) {
				return;
			}
			this._horizontalAlign = value;
			this.dispatchEventWith("change");
		}
		
		public function get useVirtualLayout() : Boolean {
			return this._useVirtualLayout;
		}
		
		public function set useVirtualLayout(value:Boolean) : void {
			if(this._useVirtualLayout == value) {
				return;
			}
			this._useVirtualLayout = value;
			this.dispatchEventWith("change");
		}
		
		public function get requestedRowCount() : int {
			return this._requestedRowCount;
		}
		
		public function set requestedRowCount(value:int) : void {
			if(value < 0) {
				throw RangeError("requestedRowCount requires a value >= 0");
			}
			if(this._requestedRowCount == value) {
				return;
			}
			this._requestedRowCount = value;
			this.dispatchEventWith("change");
		}
		
		public function get beforeVirtualizedItemCount() : int {
			return this._beforeVirtualizedItemCount;
		}
		
		public function set beforeVirtualizedItemCount(value:int) : void {
			if(this._beforeVirtualizedItemCount == value) {
				return;
			}
			this._beforeVirtualizedItemCount = value;
			this.dispatchEventWith("change");
		}
		
		public function get afterVirtualizedItemCount() : int {
			return this._afterVirtualizedItemCount;
		}
		
		public function set afterVirtualizedItemCount(value:int) : void {
			if(this._afterVirtualizedItemCount == value) {
				return;
			}
			this._afterVirtualizedItemCount = value;
			this.dispatchEventWith("change");
		}
		
		public function get typicalItem() : DisplayObject {
			return this._typicalItem;
		}
		
		public function set typicalItem(value:DisplayObject) : void {
			if(this._typicalItem == value) {
				return;
			}
			this._typicalItem = value;
			this.dispatchEventWith("change");
		}
		
		public function get resetTypicalItemDimensionsOnMeasure() : Boolean {
			return this._resetTypicalItemDimensionsOnMeasure;
		}
		
		public function set resetTypicalItemDimensionsOnMeasure(value:Boolean) : void {
			if(this._resetTypicalItemDimensionsOnMeasure == value) {
				return;
			}
			this._resetTypicalItemDimensionsOnMeasure = value;
			this.dispatchEventWith("change");
		}
		
		public function get typicalItemWidth() : Number {
			return this._typicalItemWidth;
		}
		
		public function set typicalItemWidth(value:Number) : void {
			if(this._typicalItemWidth == value) {
				return;
			}
			this._typicalItemWidth = value;
			this.dispatchEventWith("change");
		}
		
		public function get typicalItemHeight() : Number {
			return this._typicalItemHeight;
		}
		
		public function set typicalItemHeight(value:Number) : void {
			if(this._typicalItemHeight == value) {
				return;
			}
			this._typicalItemHeight = value;
			this.dispatchEventWith("change");
		}
		
		public function get repeatItems() : Boolean {
			return this._repeatItems;
		}
		
		public function set repeatItems(value:Boolean) : void {
			if(this._repeatItems == value) {
				return;
			}
			this._repeatItems = value;
			this.dispatchEventWith("change");
		}
		
		public function get snapInterval() : Number {
			return this._typicalItem.height + this._gap;
		}
		
		public function get requiresLayoutOnScroll() : Boolean {
			return true;
		}
		
		public function layout(items:Vector.<DisplayObject>, viewPortBounds:ViewPortBounds = null, result:LayoutBoundsResult = null) : LayoutBoundsResult {
			var _local26:Number = NaN;
			var _local23:Number = NaN;
			var _local24:int = 0;
			var _local19:DisplayObject = null;
			var _local13:Number = NaN;
			var _local6:ILayoutDisplayObject = null;
			var _local18:Number = NaN;
			var _local10:* = NaN;
			var _local35:Number = !!viewPortBounds ? viewPortBounds.scrollX : 0;
			var _local32:Number = !!viewPortBounds ? viewPortBounds.scrollY : 0;
			var _local30:Number = !!viewPortBounds ? viewPortBounds.x : 0;
			var _local31:Number = !!viewPortBounds ? viewPortBounds.y : 0;
			var _local25:Number = !!viewPortBounds ? viewPortBounds.minWidth : 0;
			var _local7:Number = !!viewPortBounds ? viewPortBounds.minHeight : 0;
			var _local17:Number = !!viewPortBounds ? viewPortBounds.maxWidth : Infinity;
			var _local11:Number = !!viewPortBounds ? viewPortBounds.maxHeight : Infinity;
			var _local29:Number = !!viewPortBounds ? viewPortBounds.explicitWidth : NaN;
			var _local33:Number = !!viewPortBounds ? viewPortBounds.explicitHeight : NaN;
			if(this._useVirtualLayout) {
				this.prepareTypicalItem(_local29 - this._paddingLeft - this._paddingRight);
				_local26 = !!this._typicalItem ? this._typicalItem.width : 0;
				_local23 = !!this._typicalItem ? this._typicalItem.height : 0;
			}
			if(!this._useVirtualLayout || this._horizontalAlign != "justify" || _local29 !== _local29) {
				this.validateItems(items,_local29 - this._paddingLeft - this._paddingRight,_local33);
			}
			var _local34:* = this._useVirtualLayout ? _local26 : 0;
			var _local8:* = _local31;
			var _local12:Number = this._gap;
			var _local27:int;
			var _local28:* = _local27 = int(items.length);
			if(this._useVirtualLayout) {
				_local28 += this._beforeVirtualizedItemCount + this._afterVirtualizedItemCount;
				_local8 += this._beforeVirtualizedItemCount * (_local23 + _local12);
			}
			this._discoveredItemsCache.length = 0;
			var _local9:int = 0;
			_local24 = 0;
			for(; _local24 < _local27; _local24++) {
				_local19 = items[_local24];
				if(_local19) {
					if(_local19 is ILayoutDisplayObject && !ILayoutDisplayObject(_local19).includeInLayout) {
						continue;
					}
					_local19.y = _local19.pivotY + _local8;
					_local19.height = _local23;
					_local13 = _local19.width;
					if(_local13 > _local34) {
						_local34 = _local13;
					}
					if(this._useVirtualLayout) {
						this._discoveredItemsCache[_local9] = _local19;
						_local9++;
					}
				}
				_local8 += _local23 + _local12;
			}
			if(this._useVirtualLayout) {
				_local8 += this._afterVirtualizedItemCount * (_local23 + _local12);
			}
			var _local20:Vector.<DisplayObject> = this._useVirtualLayout ? this._discoveredItemsCache : items;
			var _local21:int = int(_local20.length);
			var _local15:Number = _local34 + this._paddingLeft + this._paddingRight;
			var _local22:* = _local29;
			if(_local22 !== _local22) {
				_local22 = _local15;
				if(_local22 < _local25) {
					_local22 = _local25;
				} else if(_local22 > _local17) {
					_local22 = _local17;
				}
			}
			var _local4:Number = _local8 - _local12 - _local31;
			var _local5:* = _local33;
			if(_local5 !== _local5) {
				if(this._requestedRowCount > 0) {
					_local5 = this._requestedRowCount * (_local23 + _local12) - _local12;
				} else {
					_local5 = _local4;
				}
				if(_local5 < _local7) {
					_local5 = _local7;
				} else if(_local5 > _local11) {
					_local5 = _local11;
				}
			}
			var _local16:Boolean = this._repeatItems && _local4 > _local5;
			if(_local16) {
				_local4 += _local12;
			}
			var _local14:Number = Math.round((_local5 - _local23) / 2);
			if(!_local16) {
				_local4 += 2 * _local14;
			}
			_local24 = 0;
			while(_local24 < _local21) {
				_local19 = _local20[_local24];
				if(!(_local19 is ILayoutDisplayObject && !ILayoutDisplayObject(_local19).includeInLayout)) {
					_local19.y += _local14;
				}
				_local24++;
			}
			_local24 = 0;
			while(_local24 < _local21) {
				_local19 = _local20[_local24];
				_local6 = _local19 as ILayoutDisplayObject;
				if(!(_local6 && !_local6.includeInLayout)) {
					if(_local16) {
						_local18 = _local32 - _local14;
						if(_local18 > 0) {
							_local19.y += _local4 * (int((_local18 + _local5) / _local4));
							if(_local19.y >= _local32 + _local5) {
								_local19.y -= _local4;
							}
						} else if(_local18 < 0) {
							_local19.y += _local4 * (int(_local18 / _local4) - 1);
							if(_local19.y + _local19.height < _local32) {
								_local19.y += _local4;
							}
						}
					}
					if(this._horizontalAlign == "justify") {
						_local19.x = _local19.pivotX + _local30 + this._paddingLeft;
						_local19.width = _local22 - this._paddingLeft - this._paddingRight;
					} else {
						_local10 = _local22;
						if(_local15 > _local10) {
							_local10 = _local15;
						}
						switch(this._horizontalAlign) {
							case "right":
								_local19.x = _local19.pivotX + _local30 + _local10 - this._paddingRight - _local19.width;
								break;
							case "center":
								_local19.x = _local19.pivotX + _local30 + this._paddingLeft + Math.round((_local10 - this._paddingLeft - this._paddingRight - _local19.width) / 2);
								break;
							default:
								_local19.x = _local19.pivotX + _local30 + this._paddingLeft;
						}
					}
				}
				_local24++;
			}
			this._discoveredItemsCache.length = 0;
			if(!result) {
				result = new LayoutBoundsResult();
			}
			result.contentX = 0;
			result.contentWidth = this._horizontalAlign == "justify" ? _local22 : _local15;
			if(_local16) {
				result.contentY = -Infinity;
				result.contentHeight = Infinity;
			} else {
				result.contentY = 0;
				result.contentHeight = _local4;
			}
			result.viewPortWidth = _local22;
			result.viewPortHeight = _local5;
			return result;
		}
		
		public function measureViewPort(itemCount:int, viewPortBounds:ViewPortBounds = null, result:Point = null) : Point {
			var _local9:* = NaN;
			var _local7:* = NaN;
			if(!result) {
				result = new Point();
			}
			if(!this._useVirtualLayout) {
				throw new IllegalOperationError("measureViewPort() may be called only if useVirtualLayout is true.");
			}
			var _local10:Number = !!viewPortBounds ? viewPortBounds.explicitWidth : NaN;
			var _local16:Number = !!viewPortBounds ? viewPortBounds.explicitHeight : NaN;
			var _local4:* = _local10 !== _local10;
			var _local15:* = _local16 !== _local16;
			if(!_local4 && !_local15) {
				result.x = _local10;
				result.y = _local16;
				return result;
			}
			var _local6:Number = !!viewPortBounds ? viewPortBounds.minWidth : 0;
			var _local11:Number = !!viewPortBounds ? viewPortBounds.minHeight : 0;
			var _local18:Number = !!viewPortBounds ? viewPortBounds.maxWidth : Infinity;
			var _local13:Number = !!viewPortBounds ? viewPortBounds.maxHeight : Infinity;
			this.prepareTypicalItem(_local10 - this._paddingLeft - this._paddingRight);
			var _local8:Number = !!this._typicalItem ? this._typicalItem.width : 0;
			var _local5:Number = !!this._typicalItem ? this._typicalItem.height : 0;
			var _local14:Number = this._gap;
			var _local12:Number = 0;
			var _local17:* = _local8;
			_local12 += (_local5 + _local14) * itemCount;
			_local12 = _local12 - _local14;
			if(_local4) {
				_local9 = _local17 + this._paddingLeft + this._paddingRight;
				if(_local9 < _local6) {
					_local9 = _local6;
				} else if(_local9 > _local18) {
					_local9 = _local18;
				}
				result.x = _local9;
			} else {
				result.x = _local10;
			}
			if(_local15) {
				if(this._requestedRowCount > 0) {
					_local7 = (_local5 + _local14) * this._requestedRowCount - _local14;
				} else {
					_local7 = _local12;
				}
				if(_local7 < _local11) {
					_local7 = _local11;
				} else if(_local7 > _local13) {
					_local7 = _local13;
				}
				result.y = _local7;
			} else {
				result.y = _local16;
			}
			return result;
		}
		
		public function getVisibleIndicesAtScrollPosition(scrollX:Number, scrollY:Number, width:Number, height:Number, itemCount:int, result:Vector.<int> = null) : Vector.<int> {
			var _local14:int = 0;
			var _local13:int = 0;
			var _local9:* = 0;
			var _local15:int = 0;
			if(result) {
				result.length = 0;
			} else {
				result = new Vector.<int>(0);
			}
			if(!this._useVirtualLayout) {
				throw new IllegalOperationError("getVisibleIndicesAtScrollPosition() may be called only if useVirtualLayout is true.");
			}
			this.prepareTypicalItem(width - this._paddingLeft - this._paddingRight);
			var _local8:Number = !!this._typicalItem ? this._typicalItem.height : 0;
			var _local12:Number = this._gap;
			var _local7:int = 0;
			var _local11:int = Math.ceil(height / (_local8 + _local12)) + 1;
			var _local10:Number = itemCount * (_local8 + _local12) - _local12;
			scrollY -= Math.round((height - _local8) / 2);
			var _local16:Boolean = this._repeatItems && _local10 > height;
			if(_local16) {
				_local10 += _local12;
				scrollY %= _local10;
				if(scrollY < 0) {
					scrollY += _local10;
				}
				_local14 = scrollY / (_local8 + _local12);
				_local13 = _local14 + _local11;
			} else {
				_local14 = scrollY / (_local8 + _local12);
				if(_local14 < 0) {
					_local14 = 0;
				}
				_local13 = _local14 + _local11;
				if(_local13 >= itemCount) {
					_local13 = itemCount - 1;
				}
				_local14 = _local13 - _local11;
				if(_local14 < 0) {
					_local14 = 0;
				}
			}
			_local9 = _local14;
			while(_local9 <= _local13) {
				if(!_local16 || _local9 >= 0 && _local9 < itemCount) {
					result[_local7] = _local9;
				} else if(_local9 < 0) {
					result[_local7] = itemCount + _local9;
				} else if(_local9 >= itemCount) {
					_local15 = _local9 - itemCount;
					if(_local15 === _local14) {
						break;
					}
					result[_local7] = _local15;
				}
				_local7++;
				_local9++;
			}
			return result;
		}
		
		public function getNearestScrollPositionForIndex(index:int, scrollX:Number, scrollY:Number, items:Vector.<DisplayObject>, x:Number, y:Number, width:Number, height:Number, result:Point = null) : Point {
			return this.getScrollPositionForIndex(index,items,x,y,width,height,result);
		}
		
		public function getScrollPositionForIndex(index:int, items:Vector.<DisplayObject>, x:Number, y:Number, width:Number, height:Number, result:Point = null) : Point {
			this.prepareTypicalItem(width - this._paddingLeft - this._paddingRight);
			var _local8:Number = !!this._typicalItem ? this._typicalItem.height : 0;
			if(!result) {
				result = new Point();
			}
			result.x = 0;
			result.y = _local8 * index;
			return result;
		}
		
		protected function validateItems(items:Vector.<DisplayObject>, justifyWidth:Number, distributedHeight:Number) : void {
			var _local7:int = 0;
			var _local5:DisplayObject = null;
			var _local6:* = this._horizontalAlign == "justify";
			var _local4:Boolean = _local6 && justifyWidth === justifyWidth;
			var _local8:int = int(items.length);
			_local7 = 0;
			while(_local7 < _local8) {
				_local5 = items[_local7];
				if(!(!_local5 || _local5 is ILayoutDisplayObject && !ILayoutDisplayObject(_local5).includeInLayout)) {
					if(_local4) {
						_local5.width = justifyWidth;
					} else if(_local6 && _local5 is IFeathersControl) {
						_local5.width = NaN;
					}
					if(_local5 is IValidating) {
						IValidating(_local5).validate();
					}
				}
				_local7++;
			}
		}
		
		protected function prepareTypicalItem(justifyWidth:Number) : void {
			if(!this._typicalItem) {
				return;
			}
			if(this._horizontalAlign == "justify" && justifyWidth === justifyWidth) {
				this._typicalItem.width = justifyWidth;
			} else if(this._resetTypicalItemDimensionsOnMeasure) {
				this._typicalItem.width = this._typicalItemWidth;
			}
			if(this._resetTypicalItemDimensionsOnMeasure) {
				this._typicalItem.height = this._typicalItemHeight;
			}
			if(this._typicalItem is IValidating) {
				IValidating(this._typicalItem).validate();
			}
		}
	}
}

