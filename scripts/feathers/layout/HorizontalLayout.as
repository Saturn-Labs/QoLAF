package feathers.layout {
	import feathers.core.IFeathersControl;
	import feathers.core.IMeasureDisplayObject;
	import feathers.core.IValidating;
	import flash.errors.IllegalOperationError;
	import flash.geom.Point;
	import starling.display.DisplayObject;
	import starling.events.EventDispatcher;
	
	public class HorizontalLayout extends EventDispatcher implements IVariableVirtualLayout, ITrimmedVirtualLayout {
		public static const VERTICAL_ALIGN_TOP:String = "top";
		
		public static const VERTICAL_ALIGN_MIDDLE:String = "middle";
		
		public static const VERTICAL_ALIGN_BOTTOM:String = "bottom";
		
		public static const VERTICAL_ALIGN_JUSTIFY:String = "justify";
		
		public static const HORIZONTAL_ALIGN_LEFT:String = "left";
		
		public static const HORIZONTAL_ALIGN_CENTER:String = "center";
		
		public static const HORIZONTAL_ALIGN_RIGHT:String = "right";
		
		protected var _widthCache:Array = [];
		
		protected var _discoveredItemsCache:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
		
		protected var _gap:Number = 0;
		
		protected var _firstGap:Number = NaN;
		
		protected var _lastGap:Number = NaN;
		
		protected var _paddingTop:Number = 0;
		
		protected var _paddingRight:Number = 0;
		
		protected var _paddingBottom:Number = 0;
		
		protected var _paddingLeft:Number = 0;
		
		protected var _verticalAlign:String = "top";
		
		protected var _horizontalAlign:String = "left";
		
		protected var _useVirtualLayout:Boolean = true;
		
		protected var _hasVariableItemDimensions:Boolean = false;
		
		protected var _requestedColumnCount:int = 0;
		
		protected var _distributeWidths:Boolean = false;
		
		protected var _beforeVirtualizedItemCount:int = 0;
		
		protected var _afterVirtualizedItemCount:int = 0;
		
		protected var _typicalItem:DisplayObject;
		
		protected var _resetTypicalItemDimensionsOnMeasure:Boolean = false;
		
		protected var _typicalItemWidth:Number = NaN;
		
		protected var _typicalItemHeight:Number = NaN;
		
		protected var _scrollPositionHorizontalAlign:String = "center";
		
		public function HorizontalLayout() {
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
		
		public function get firstGap() : Number {
			return this._firstGap;
		}
		
		public function set firstGap(value:Number) : void {
			if(this._firstGap == value) {
				return;
			}
			this._firstGap = value;
			this.dispatchEventWith("change");
		}
		
		public function get lastGap() : Number {
			return this._lastGap;
		}
		
		public function set lastGap(value:Number) : void {
			if(this._lastGap == value) {
				return;
			}
			this._lastGap = value;
			this.dispatchEventWith("change");
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
			this.dispatchEventWith("change");
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
		
		public function get paddingBottom() : Number {
			return this._paddingBottom;
		}
		
		public function set paddingBottom(value:Number) : void {
			if(this._paddingBottom == value) {
				return;
			}
			this._paddingBottom = value;
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
		
		public function get verticalAlign() : String {
			return this._verticalAlign;
		}
		
		public function set verticalAlign(value:String) : void {
			if(this._verticalAlign == value) {
				return;
			}
			this._verticalAlign = value;
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
		
		public function get hasVariableItemDimensions() : Boolean {
			return this._hasVariableItemDimensions;
		}
		
		public function set hasVariableItemDimensions(value:Boolean) : void {
			if(this._hasVariableItemDimensions == value) {
				return;
			}
			this._hasVariableItemDimensions = value;
			this.dispatchEventWith("change");
		}
		
		public function get requestedColumnCount() : int {
			return this._requestedColumnCount;
		}
		
		public function set requestedColumnCount(value:int) : void {
			if(value < 0) {
				throw RangeError("requestedColumnCount requires a value >= 0");
			}
			if(this._requestedColumnCount == value) {
				return;
			}
			this._requestedColumnCount = value;
			this.dispatchEventWith("change");
		}
		
		public function get distributeWidths() : Boolean {
			return this._distributeWidths;
		}
		
		public function set distributeWidths(value:Boolean) : void {
			if(this._distributeWidths == value) {
				return;
			}
			this._distributeWidths = value;
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
		
		public function get scrollPositionHorizontalAlign() : String {
			return this._scrollPositionHorizontalAlign;
		}
		
		public function set scrollPositionHorizontalAlign(value:String) : void {
			this._scrollPositionHorizontalAlign = value;
		}
		
		public function get requiresLayoutOnScroll() : Boolean {
			return this._useVirtualLayout;
		}
		
		public function layout(items:Vector.<DisplayObject>, viewPortBounds:ViewPortBounds = null, result:LayoutBoundsResult = null) : LayoutBoundsResult {
			var _local35:Number = NaN;
			var _local30:Number = NaN;
			var _local31:Number = NaN;
			var _local32:int = 0;
			var _local25:DisplayObject = null;
			var _local14:int = 0;
			var _local38:Number = NaN;
			var _local19:* = NaN;
			var _local8:* = NaN;
			var _local44:Number = NaN;
			var _local7:ILayoutDisplayObject = null;
			var _local23:HorizontalLayoutData = null;
			var _local16:Number = NaN;
			var _local10:IFeathersControl = null;
			var _local48:Number = NaN;
			var _local43:Number = NaN;
			var _local6:* = NaN;
			var _local47:Number = !!viewPortBounds ? viewPortBounds.scrollX : 0;
			var _local45:Number = !!viewPortBounds ? viewPortBounds.scrollY : 0;
			var _local40:Number = !!viewPortBounds ? viewPortBounds.x : 0;
			var _local42:Number = !!viewPortBounds ? viewPortBounds.y : 0;
			var _local33:Number = !!viewPortBounds ? viewPortBounds.minWidth : 0;
			var _local13:Number = !!viewPortBounds ? viewPortBounds.minHeight : 0;
			var _local21:Number = !!viewPortBounds ? viewPortBounds.maxWidth : Infinity;
			var _local17:Number = !!viewPortBounds ? viewPortBounds.maxHeight : Infinity;
			var _local39:Number = !!viewPortBounds ? viewPortBounds.explicitWidth : NaN;
			var _local46:Number = !!viewPortBounds ? viewPortBounds.explicitHeight : NaN;
			if(this._useVirtualLayout) {
				this.prepareTypicalItem(_local46 - this._paddingTop - this._paddingBottom);
				_local35 = !!this._typicalItem ? this._typicalItem.width : 0;
				_local30 = !!this._typicalItem ? this._typicalItem.height : 0;
			}
			var _local34:* = _local39 !== _local39;
			var _local29:* = _local46 !== _local46;
			if(!_local34 && this._distributeWidths) {
				_local31 = this.calculateDistributedWidth(items,_local39,_local33,_local21,false);
			}
			if(!this._useVirtualLayout || this._hasVariableItemDimensions || this._distributeWidths || this._verticalAlign != "justify" || _local29) {
				this.validateItems(items,_local46 - this._paddingTop - this._paddingBottom,_local13 - this._paddingTop - this._paddingBottom,_local17 - this._paddingTop - this._paddingBottom,_local39 - this._paddingLeft - this._paddingRight,_local33 - this._paddingLeft - this._paddingRight,_local21 - this._paddingLeft - this._paddingRight,_local31);
			}
			if(_local34 && this._distributeWidths) {
				_local31 = this.calculateDistributedWidth(items,_local39,_local33,_local21,false);
			}
			var _local9:* = _local31 === _local31;
			if(!this._useVirtualLayout) {
				this.applyPercentWidths(items,_local39,_local33,_local21);
			}
			var _local11:* = this._firstGap === this._firstGap;
			var _local41:* = this._lastGap === this._lastGap;
			var _local24:* = this._useVirtualLayout ? _local30 : 0;
			var _local12:Number = _local40 + this._paddingLeft;
			var _local36:int;
			var _local37:* = _local36 = int(items.length);
			if(this._useVirtualLayout && !this._hasVariableItemDimensions) {
				_local37 += this._beforeVirtualizedItemCount + this._afterVirtualizedItemCount;
				_local12 += this._beforeVirtualizedItemCount * (_local35 + this._gap);
				if(_local11 && this._beforeVirtualizedItemCount > 0) {
					_local12 = _local12 - this._gap + this._firstGap;
				}
			}
			var _local22:int = _local37 - 2;
			this._discoveredItemsCache.length = 0;
			var _local15:int = 0;
			var _local18:Number = 0;
			_local32 = 0;
			while(_local32 < _local36) {
				_local25 = items[_local32];
				_local14 = _local32 + this._beforeVirtualizedItemCount;
				_local18 = this._gap;
				if(_local11 && _local14 == 0) {
					_local18 = this._firstGap;
				} else if(_local41 && _local14 > 0 && _local14 == _local22) {
					_local18 = this._lastGap;
				}
				if(this._useVirtualLayout && this._hasVariableItemDimensions) {
					_local38 = Number(this._widthCache[_local14]);
				}
				if(this._useVirtualLayout && !_local25) {
					if(!this._hasVariableItemDimensions || _local38 !== _local38) {
						_local12 += _local35 + _local18;
					} else {
						_local12 += _local38 + _local18;
					}
				} else if(!(_local25 is ILayoutDisplayObject && !ILayoutDisplayObject(_local25).includeInLayout)) {
					_local25.x = _local25.pivotX + _local12;
					if(_local9) {
						_local25.width = _local19 = _local31;
					} else {
						_local19 = _local25.width;
					}
					_local8 = _local25.height;
					if(this._useVirtualLayout) {
						if(this._hasVariableItemDimensions) {
							if(_local19 != _local38) {
								this._widthCache[_local14] = _local19;
								if(_local12 < _local47 && _local38 !== _local38 && _local19 != _local35) {
									this.dispatchEventWith("scroll",false,new Point(_local19 - _local35,0));
								}
								this.dispatchEventWith("change");
							}
						} else if(_local35 >= 0) {
							_local25.width = _local19 = _local35;
						}
					}
					_local12 += _local19 + _local18;
					if(_local8 > _local24) {
						_local24 = _local8;
					}
					if(this._useVirtualLayout) {
						this._discoveredItemsCache[_local15] = _local25;
						_local15++;
					}
				}
				_local32++;
			}
			if(this._useVirtualLayout && !this._hasVariableItemDimensions) {
				_local12 += this._afterVirtualizedItemCount * (_local35 + this._gap);
				if(_local41 && this._afterVirtualizedItemCount > 0) {
					_local12 = _local12 - this._gap + this._lastGap;
				}
			}
			var _local26:Vector.<DisplayObject> = this._useVirtualLayout ? this._discoveredItemsCache : items;
			var _local27:int = int(_local26.length);
			var _local4:Number = _local24 + this._paddingTop + this._paddingBottom;
			var _local5:* = _local46;
			if(_local5 !== _local5) {
				_local5 = _local4;
				if(_local5 < _local13) {
					_local5 = _local13;
				} else if(_local5 > _local17) {
					_local5 = _local17;
				}
			}
			var _local20:Number = _local12 - _local18 + this._paddingRight - _local40;
			var _local28:* = _local39;
			if(_local28 !== _local28) {
				if(this._requestedColumnCount > 0) {
					_local28 = (_local35 + this._gap) * this._requestedColumnCount - this._gap + this._paddingLeft + this._paddingRight;
				} else {
					_local28 = _local20;
				}
				if(_local28 < _local33) {
					_local28 = _local33;
				} else if(_local28 > _local21) {
					_local28 = _local21;
				}
			}
			if(_local20 < _local28) {
				_local44 = 0;
				if(this._horizontalAlign == "right") {
					_local44 = _local28 - _local20;
				} else if(this._horizontalAlign == "center") {
					_local44 = Math.round((_local28 - _local20) / 2);
				}
				if(_local44 != 0) {
					_local32 = 0;
					while(_local32 < _local27) {
						_local25 = _local26[_local32];
						if(!(_local25 is ILayoutDisplayObject && !ILayoutDisplayObject(_local25).includeInLayout)) {
							_local25.x += _local44;
						}
						_local32++;
					}
				}
			}
			_local32 = 0;
			while(_local32 < _local27) {
				_local25 = _local26[_local32];
				_local7 = _local25 as ILayoutDisplayObject;
				if(!(_local7 && !_local7.includeInLayout)) {
					if(this._verticalAlign == "justify") {
						_local25.y = _local25.pivotY + _local42 + this._paddingTop;
						_local25.height = _local5 - this._paddingTop - this._paddingBottom;
					} else {
						if(_local7) {
							_local23 = _local7.layoutData as HorizontalLayoutData;
							if(_local23) {
								_local16 = _local23.percentHeight;
								if(_local16 === _local16) {
									if(_local16 < 0) {
										_local16 = 0;
									}
									if(_local16 > 100) {
										_local16 = 100;
									}
									_local8 = _local16 * (_local5 - this._paddingTop - this._paddingBottom) / 100;
									if(_local25 is IFeathersControl) {
										_local10 = IFeathersControl(_local25);
										_local48 = Number(_local10.minHeight);
										if(_local8 < _local48) {
											_local8 = _local48;
										} else {
											_local43 = Number(_local10.maxHeight);
											if(_local8 > _local43) {
												_local8 = _local43;
											}
										}
									}
									_local25.height = _local8;
								}
							}
						}
						_local6 = _local5;
						if(_local4 > _local6) {
							_local6 = _local4;
						}
						switch(this._verticalAlign) {
							case "bottom":
								_local25.y = _local25.pivotY + _local42 + _local6 - this._paddingBottom - _local25.height;
								break;
							case "middle":
								_local25.y = _local25.pivotY + _local42 + this._paddingTop + Math.round((_local6 - this._paddingTop - this._paddingBottom - _local25.height) / 2);
								break;
							default:
								_local25.y = _local25.pivotY + _local42 + this._paddingTop;
						}
					}
				}
				_local32++;
			}
			this._discoveredItemsCache.length = 0;
			if(!result) {
				result = new LayoutBoundsResult();
			}
			result.contentX = 0;
			result.contentWidth = _local20;
			result.contentY = 0;
			result.contentHeight = this._verticalAlign == "justify" ? _local5 : _local4;
			result.viewPortWidth = _local28;
			result.viewPortHeight = _local5;
			return result;
		}
		
		public function measureViewPort(itemCount:int, viewPortBounds:ViewPortBounds = null, result:Point = null) : Point {
			var _local12:Number = NaN;
			var _local4:* = NaN;
			var _local7:int = 0;
			var _local13:Number = NaN;
			var _local14:* = NaN;
			var _local10:* = NaN;
			if(!result) {
				result = new Point();
			}
			if(!this._useVirtualLayout) {
				throw new IllegalOperationError("measureViewPort() may be called only if useVirtualLayout is true.");
			}
			var _local15:Number = !!viewPortBounds ? viewPortBounds.explicitWidth : NaN;
			var _local20:Number = !!viewPortBounds ? viewPortBounds.explicitHeight : NaN;
			var _local5:* = _local15 !== _local15;
			var _local19:* = _local20 !== _local20;
			if(!_local5 && !_local19) {
				result.x = _local15;
				result.y = _local20;
				return result;
			}
			var _local8:Number = !!viewPortBounds ? viewPortBounds.minWidth : 0;
			var _local16:Number = !!viewPortBounds ? viewPortBounds.minHeight : 0;
			var _local21:Number = !!viewPortBounds ? viewPortBounds.maxWidth : Infinity;
			var _local18:Number = !!viewPortBounds ? viewPortBounds.maxHeight : Infinity;
			this.prepareTypicalItem(_local20 - this._paddingTop - this._paddingBottom);
			var _local11:Number = !!this._typicalItem ? this._typicalItem.width : 0;
			var _local6:Number = !!this._typicalItem ? this._typicalItem.height : 0;
			var _local9:* = this._firstGap === this._firstGap;
			var _local17:* = this._lastGap === this._lastGap;
			if(this._distributeWidths) {
				_local12 = (_local11 + this._gap) * itemCount;
			} else {
				_local12 = 0;
				_local4 = _local6;
				if(!this._hasVariableItemDimensions) {
					_local12 += (_local11 + this._gap) * itemCount;
				} else {
					_local7 = 0;
					while(_local7 < itemCount) {
						_local13 = Number(this._widthCache[_local7]);
						if(_local13 !== _local13) {
							_local12 += _local11 + this._gap;
						} else {
							_local12 += _local13 + this._gap;
						}
						_local7++;
					}
				}
			}
			_local12 -= this._gap;
			if(_local9 && itemCount > 1) {
				_local12 = _local12 - this._gap + this._firstGap;
			}
			if(_local17 && itemCount > 2) {
				_local12 = _local12 - this._gap + this._lastGap;
			}
			if(_local5) {
				if(this._requestedColumnCount > 0) {
					_local14 = (_local11 + this._gap) * this._requestedColumnCount - this._gap + this._paddingLeft + this._paddingRight;
				} else {
					_local14 = _local12 + this._paddingLeft + this._paddingRight;
				}
				if(_local14 < _local8) {
					_local14 = _local8;
				} else if(_local14 > _local21) {
					_local14 = _local21;
				}
				result.x = _local14;
			} else {
				result.x = _local15;
			}
			if(_local19) {
				_local10 = _local4 + this._paddingTop + this._paddingBottom;
				if(_local10 < _local16) {
					_local10 = _local16;
				} else if(_local10 > _local18) {
					_local10 = _local18;
				}
				result.y = _local10;
			} else {
				result.y = _local20;
			}
			return result;
		}
		
		public function resetVariableVirtualCache() : void {
			this._widthCache.length = 0;
		}
		
		public function resetVariableVirtualCacheAtIndex(index:int, item:DisplayObject = null) : void {
			delete this._widthCache[index];
			if(item) {
				this._widthCache[index] = item.width;
				this.dispatchEventWith("change");
			}
		}
		
		public function addToVariableVirtualCacheAtIndex(index:int, item:DisplayObject = null) : void {
			var _local3:* = !!item ? item.width : undefined;
			this._widthCache.insertAt(index,_local3);
		}
		
		public function removeFromVariableVirtualCacheAtIndex(index:int) : void {
			this._widthCache.removeAt(index);
		}
		
		public function getVisibleIndicesAtScrollPosition(scrollX:Number, scrollY:Number, width:Number, height:Number, itemCount:int, result:Vector.<int> = null) : Vector.<int> {
			var _local8:Number = NaN;
			var _local27:int = 0;
			var _local30:int = 0;
			var _local28:int = 0;
			var _local22:* = 0;
			var _local16:Number = NaN;
			var _local24:Number = NaN;
			var _local17:* = NaN;
			var _local10:* = NaN;
			var _local13:int = 0;
			var _local9:int = 0;
			var _local14:int = 0;
			var _local15:* = 0;
			if(result) {
				result.length = 0;
			} else {
				result = new Vector.<int>(0);
			}
			if(!this._useVirtualLayout) {
				throw new IllegalOperationError("getVisibleIndicesAtScrollPosition() may be called only if useVirtualLayout is true.");
			}
			this.prepareTypicalItem(height - this._paddingTop - this._paddingBottom);
			var _local23:Number = !!this._typicalItem ? this._typicalItem.width : 0;
			var _local20:Number = !!this._typicalItem ? this._typicalItem.height : 0;
			var _local11:* = this._firstGap === this._firstGap;
			var _local26:* = this._lastGap === this._lastGap;
			var _local7:* = 0;
			var _local25:int = Math.ceil(width / (_local23 + this._gap)) + 1;
			if(!this._hasVariableItemDimensions) {
				_local8 = itemCount * (_local23 + this._gap) - this._gap;
				if(_local11 && itemCount > 1) {
					_local8 = _local8 - this._gap + this._firstGap;
				}
				if(_local26 && itemCount > 2) {
					_local8 = _local8 - this._gap + this._lastGap;
				}
				_local27 = 0;
				if(_local8 < width) {
					if(this._horizontalAlign == "right") {
						_local27 = Math.ceil((width - _local8) / (_local23 + this._gap));
					} else if(this._horizontalAlign == "center") {
						_local27 = Math.ceil((width - _local8) / (_local23 + this._gap) / 2);
					}
				}
				_local30 = (scrollX - this._paddingLeft) / (_local23 + this._gap);
				if(_local30 < 0) {
					_local30 = 0;
				}
				_local30 -= _local27;
				_local28 = _local30 + _local25;
				if(_local28 >= itemCount) {
					_local28 = itemCount - 1;
				}
				_local30 = _local28 - _local25;
				if(_local30 < 0) {
					_local30 = 0;
				}
				_local22 = _local30;
				while(_local22 <= _local28) {
					if(_local22 >= 0 && _local22 < itemCount) {
						result[_local7] = _local22;
					} else if(_local22 < 0) {
						result[_local7] = itemCount + _local22;
					} else if(_local22 >= itemCount) {
						result[_local7] = _local22 - itemCount;
					}
					_local7++;
					_local22++;
				}
				return result;
			}
			var _local18:int = itemCount - 2;
			var _local19:Number = scrollX + width;
			var _local12:Number = this._paddingLeft;
			_local22 = 0;
			while(_local22 < itemCount) {
				_local16 = this._gap;
				if(_local11 && _local22 == 0) {
					_local16 = this._firstGap;
				} else if(_local26 && _local22 > 0 && _local22 == _local18) {
					_local16 = this._lastGap;
				}
				_local24 = Number(this._widthCache[_local22]);
				if(_local24 !== _local24) {
					_local17 = _local23;
				} else {
					_local17 = _local24;
				}
				_local10 = _local12;
				_local12 += _local17 + _local16;
				if(_local12 > scrollX && _local10 < _local19) {
					result[_local7] = _local22;
					_local7++;
				}
				if(_local12 >= _local19) {
					break;
				}
				_local22++;
			}
			var _local29:int = int(result.length);
			var _local21:int = _local25 - _local29;
			if(_local21 > 0 && _local29 > 0) {
				_local13 = result[0];
				_local9 = _local13 - _local21;
				if(_local9 < 0) {
					_local9 = 0;
				}
				_local22 = _local13 - 1;
				while(_local22 >= _local9) {
					result.insertAt(0,_local22);
					_local22--;
				}
			}
			_local7 = _local29 = int(result.length);
			_local21 = _local25 - _local29;
			if(_local21 > 0) {
				_local14 = int(_local29 > 0 ? result[_local29 - 1] + 1 : 0);
				_local15 = _local14 + _local21;
				if(_local15 > itemCount) {
					_local15 = itemCount;
				}
				_local22 = _local14;
				while(_local22 < _local15) {
					result[_local7] = _local22;
					_local7++;
					_local22++;
				}
			}
			return result;
		}
		
		public function getNearestScrollPositionForIndex(index:int, scrollX:Number, scrollY:Number, items:Vector.<DisplayObject>, x:Number, y:Number, width:Number, height:Number, result:Point = null) : Point {
			var _local12:Number = NaN;
			var _local10:Number = NaN;
			var _local14:Number = NaN;
			var _local11:Number = this.calculateMaxScrollXOfIndex(index,items,x,y,width,height);
			if(this._useVirtualLayout) {
				if(this._hasVariableItemDimensions) {
					_local12 = Number(this._widthCache[index]);
					if(_local12 !== _local12) {
						_local12 = this._typicalItem.width;
					}
				} else {
					_local12 = this._typicalItem.width;
				}
			} else {
				_local12 = items[index].width;
			}
			if(!result) {
				result = new Point();
			}
			var _local13:Number = _local11 - (width - _local12);
			if(scrollX >= _local13 && scrollX <= _local11) {
				result.x = scrollX;
			} else {
				_local10 = Math.abs(_local11 - scrollX);
				_local14 = Math.abs(_local13 - scrollX);
				if(_local14 < _local10) {
					result.x = _local13;
				} else {
					result.x = _local11;
				}
			}
			result.y = 0;
			return result;
		}
		
		public function getScrollPositionForIndex(index:int, items:Vector.<DisplayObject>, x:Number, y:Number, width:Number, height:Number, result:Point = null) : Point {
			var _local9:Number = NaN;
			var _local8:Number = this.calculateMaxScrollXOfIndex(index,items,x,y,width,height);
			if(this._useVirtualLayout) {
				if(this._hasVariableItemDimensions) {
					_local9 = Number(this._widthCache[index]);
					if(_local9 !== _local9) {
						_local9 = this._typicalItem.width;
					}
				} else {
					_local9 = this._typicalItem.width;
				}
			} else {
				_local9 = items[index].width;
			}
			if(this._scrollPositionHorizontalAlign == "center") {
				_local8 -= Math.round((width - _local9) / 2);
			} else if(this._scrollPositionHorizontalAlign == "right") {
				_local8 -= width - _local9;
			}
			result.x = _local8;
			result.y = 0;
			return result;
		}
		
		protected function validateItems(items:Vector.<DisplayObject>, explicitHeight:Number, minHeight:Number, maxHeight:Number, explicitWidth:Number, minWidth:Number, maxWidth:Number, distributedWidth:Number) : void {
			var _local23:int = 0;
			var _local20:DisplayObject = null;
			var _local12:IFeathersControl = null;
			var _local9:ILayoutDisplayObject = null;
			var _local19:HorizontalLayoutData = null;
			var _local13:Number = NaN;
			var _local16:Number = NaN;
			var _local18:* = NaN;
			var _local26:IMeasureDisplayObject = null;
			var _local21:Number = NaN;
			var _local11:* = NaN;
			var _local15:Number = NaN;
			var _local22:* = explicitWidth !== explicitWidth;
			var _local17:* = explicitHeight !== explicitHeight;
			var _local14:* = explicitWidth;
			if(_local22) {
				_local14 = minWidth;
			}
			var _local25:* = explicitHeight;
			if(_local17) {
				_local25 = minHeight;
			}
			var _local10:* = this._verticalAlign == "justify";
			var _local24:int = int(items.length);
			_local23 = 0;
			while(_local23 < _local24) {
				_local20 = items[_local23];
				if(!(!_local20 || _local20 is ILayoutDisplayObject && !ILayoutDisplayObject(_local20).includeInLayout)) {
					if(this._distributeWidths) {
						_local20.width = distributedWidth;
					}
					if(_local10) {
						_local20.height = explicitHeight;
						if(_local20 is IFeathersControl) {
							_local12 = IFeathersControl(_local20);
							_local12.minHeight = minHeight;
							_local12.maxHeight = maxHeight;
						}
					} else if(_local20 is ILayoutDisplayObject) {
						_local9 = ILayoutDisplayObject(_local20);
						_local19 = _local9.layoutData as HorizontalLayoutData;
						if(_local19 !== null) {
							_local13 = _local19.percentWidth;
							_local16 = _local19.percentHeight;
							if(_local13 === _local13) {
								if(_local13 < 0) {
									_local13 = 0;
								}
								if(_local13 > 100) {
									_local13 = 100;
								}
								_local18 = _local14 * _local13 / 100;
								_local26 = IMeasureDisplayObject(_local20);
								_local21 = _local26.explicitMinWidth;
								if(_local26.explicitMinWidth === _local26.explicitMinWidth && _local18 < _local21) {
									_local18 = _local21;
								}
								_local26.maxWidth = _local18;
								_local20.width = NaN;
							}
							if(_local16 === _local16) {
								if(_local16 < 0) {
									_local16 = 0;
								}
								if(_local16 > 100) {
									_local16 = 100;
								}
								_local11 = _local25 * _local16 / 100;
								_local26 = IMeasureDisplayObject(_local20);
								_local15 = _local26.explicitMinHeight;
								if(_local26.explicitMinHeight === _local26.explicitMinHeight && _local11 < _local15) {
									_local11 = _local15;
								}
								_local20.height = _local11;
							}
						}
					}
					if(_local20 is IValidating) {
						IValidating(_local20).validate();
					}
				}
				_local23++;
			}
		}
		
		protected function prepareTypicalItem(justifyHeight:Number) : void {
			var _local4:ILayoutDisplayObject = null;
			var _local2:VerticalLayoutData = null;
			var _local3:Number = NaN;
			if(!this._typicalItem) {
				return;
			}
			if(this._resetTypicalItemDimensionsOnMeasure) {
				this._typicalItem.width = this._typicalItemWidth;
			}
			var _local5:Boolean = false;
			if(this._verticalAlign == "justify" && justifyHeight === justifyHeight) {
				_local5 = true;
				this._typicalItem.height = justifyHeight;
			} else if(this._typicalItem is ILayoutDisplayObject) {
				_local4 = ILayoutDisplayObject(this._typicalItem);
				_local2 = _local4.layoutData as VerticalLayoutData;
				if(_local2 !== null) {
					_local3 = _local2.percentHeight;
					if(_local3 === _local3) {
						if(_local3 < 0) {
							_local3 = 0;
						}
						if(_local3 > 100) {
							_local3 = 100;
						}
						_local5 = true;
						this._typicalItem.height = justifyHeight * _local3 / 100;
					}
				}
			}
			if(!_local5 && this._resetTypicalItemDimensionsOnMeasure) {
				this._typicalItem.height = this._typicalItemHeight;
			}
			if(this._typicalItem is IValidating) {
				IValidating(this._typicalItem).validate();
			}
		}
		
		protected function calculateDistributedWidth(items:Vector.<DisplayObject>, explicitWidth:Number, minWidth:Number, maxWidth:Number, measureItems:Boolean) : Number {
			var _local13:* = NaN;
			var _local8:int = 0;
			var _local6:DisplayObject = null;
			var _local12:Number = NaN;
			var _local11:Boolean = false;
			var _local7:* = explicitWidth !== explicitWidth;
			var _local9:int = int(items.length);
			if(measureItems && _local7) {
				_local13 = 0;
				_local8 = 0;
				while(_local8 < _local9) {
					_local6 = items[_local8];
					_local12 = _local6.width;
					if(_local12 > _local13) {
						_local13 = _local12;
					}
					_local8++;
				}
				explicitWidth = _local13 * _local9 + this._paddingLeft + this._paddingRight + this._gap * (_local9 - 1);
				_local11 = false;
				if(explicitWidth > maxWidth) {
					explicitWidth = maxWidth;
					_local11 = true;
				} else if(explicitWidth < minWidth) {
					explicitWidth = minWidth;
					_local11 = true;
				}
				if(!_local11) {
					return _local13;
				}
			}
			var _local10:* = explicitWidth;
			if(_local7 && maxWidth < Infinity) {
				_local10 = maxWidth;
			}
			_local10 = _local10 - this._paddingLeft - this._paddingRight - this._gap * (_local9 - 1);
			if(_local9 > 1 && this._firstGap === this._firstGap) {
				_local10 += this._gap - this._firstGap;
			}
			if(_local9 > 2 && this._lastGap === this._lastGap) {
				_local10 += this._gap - this._lastGap;
			}
			return _local10 / _local9;
		}
		
		protected function applyPercentWidths(items:Vector.<DisplayObject>, explicitWidth:Number, minWidth:Number, maxWidth:Number) : void {
			var _local9:int = 0;
			var _local6:DisplayObject = null;
			var _local7:ILayoutDisplayObject = null;
			var _local5:HorizontalLayoutData = null;
			var _local15:Number = NaN;
			var _local12:IFeathersControl = null;
			var _local13:Boolean = false;
			var _local19:Number = NaN;
			var _local18:* = NaN;
			var _local17:* = NaN;
			var _local8:Number = NaN;
			var _local20:* = explicitWidth;
			this._discoveredItemsCache.length = 0;
			var _local21:Number = 0;
			var _local10:Number = 0;
			var _local11:Number = 0;
			var _local16:int = int(items.length);
			var _local14:int = 0;
			_local9 = 0;
			for(; _local9 < _local16; _local9++) {
				_local6 = items[_local9];
				if(_local6 is ILayoutDisplayObject) {
					_local7 = ILayoutDisplayObject(_local6);
					if(!_local7.includeInLayout) {
						continue;
					}
					_local5 = _local7.layoutData as HorizontalLayoutData;
					if(_local5) {
						_local15 = _local5.percentWidth;
						if(_local15 === _local15) {
							if(_local7 is IFeathersControl) {
								_local12 = IFeathersControl(_local7);
								_local10 += _local12.minWidth;
							}
							_local11 += _local15;
							this._discoveredItemsCache[_local14] = _local6;
							_local14++;
							continue;
						}
					}
				}
				_local21 += _local6.width;
			}
			_local21 += this._gap * (_local16 - 1);
			if(this._firstGap === this._firstGap && _local16 > 1) {
				_local21 += this._firstGap - this._gap;
			} else if(this._lastGap === this._lastGap && _local16 > 2) {
				_local21 += this._lastGap - this._gap;
			}
			_local21 += this._paddingLeft + this._paddingRight;
			if(_local11 < 100) {
				_local11 = 100;
			}
			if(_local20 !== _local20) {
				_local20 = _local21 + _local10;
				if(_local20 < minWidth) {
					_local20 = minWidth;
				} else if(_local20 > maxWidth) {
					_local20 = maxWidth;
				}
			}
			_local20 -= _local21;
			if(_local20 < 0) {
				_local20 = 0;
			}
			do {
				_local13 = false;
				_local19 = _local20 / _local11;
				_local9 = 0;
				while(_local9 < _local14) {
					_local7 = ILayoutDisplayObject(this._discoveredItemsCache[_local9]);
					if(_local7) {
						_local5 = HorizontalLayoutData(_local7.layoutData);
						_local15 = _local5.percentWidth;
						_local18 = _local19 * _local15;
						if(_local7 is IFeathersControl) {
							_local12 = IFeathersControl(_local7);
							_local17 = Number(_local12.minWidth);
							if(_local17 > _local20) {
								_local17 = _local20;
							}
							if(_local18 < _local17) {
								_local18 = _local17;
								_local20 -= _local18;
								_local11 -= _local15;
								this._discoveredItemsCache[_local9] = null;
								_local13 = true;
							} else {
								_local8 = Number(_local12.maxWidth);
								if(_local18 > _local8) {
									_local18 = _local8;
									_local20 -= _local18;
									_local11 -= _local15;
									this._discoveredItemsCache[_local9] = null;
									_local13 = true;
								}
							}
						}
						_local7.width = _local18;
						if(_local7 is IValidating) {
							IValidating(_local7).validate();
						}
					}
					_local9++;
				}
			}
			while(_local13);
			
			this._discoveredItemsCache.length = 0;
		}
		
		protected function calculateMaxScrollXOfIndex(index:int, items:Vector.<DisplayObject>, x:Number, y:Number, width:Number, height:Number) : Number {
			var _local12:Number = NaN;
			var _local9:Number = NaN;
			var _local10:int = 0;
			var _local8:DisplayObject = null;
			var _local18:int = 0;
			var _local16:Number = NaN;
			var _local21:* = NaN;
			if(this._useVirtualLayout) {
				this.prepareTypicalItem(height - this._paddingTop - this._paddingBottom);
				_local12 = !!this._typicalItem ? this._typicalItem.width : 0;
				_local9 = !!this._typicalItem ? this._typicalItem.height : 0;
			}
			var _local11:* = this._firstGap === this._firstGap;
			var _local19:* = this._lastGap === this._lastGap;
			var _local13:Number = x + this._paddingLeft;
			var _local22:* = 0;
			var _local20:Number = this._gap;
			var _local17:int = 0;
			var _local23:Number = 0;
			var _local14:int;
			var _local15:* = _local14 = int(items.length);
			if(this._useVirtualLayout && !this._hasVariableItemDimensions) {
				_local15 += this._beforeVirtualizedItemCount + this._afterVirtualizedItemCount;
				if(index < this._beforeVirtualizedItemCount) {
					_local17 = index + 1;
					_local22 = _local12;
					_local20 = this._gap;
				} else {
					_local17 = this._beforeVirtualizedItemCount;
					_local23 = index - items.length - this._beforeVirtualizedItemCount + 1;
					if(_local23 < 0) {
						_local23 = 0;
					}
					_local13 += _local23 * (_local12 + this._gap);
				}
				_local13 += _local17 * (_local12 + this._gap);
			}
			index -= _local17 + _local23;
			var _local7:int = _local15 - 2;
			_local10 = 0;
			while(_local10 <= index) {
				_local8 = items[_local10];
				_local18 = _local10 + _local17;
				if(_local11 && _local18 == 0) {
					_local20 = this._firstGap;
				} else if(_local19 && _local18 > 0 && _local18 == _local7) {
					_local20 = this._lastGap;
				} else {
					_local20 = this._gap;
				}
				if(this._useVirtualLayout && this._hasVariableItemDimensions) {
					_local16 = Number(this._widthCache[_local18]);
				}
				if(this._useVirtualLayout && !_local8) {
					if(!this._hasVariableItemDimensions || _local16 !== _local16) {
						_local22 = _local12;
					} else {
						_local22 = _local16;
					}
				} else {
					_local21 = _local8.width;
					if(this._useVirtualLayout) {
						if(this._hasVariableItemDimensions) {
							if(_local21 != _local16) {
								this._widthCache[_local18] = _local21;
								this.dispatchEventWith("change");
							}
						} else if(_local12 >= 0) {
							_local8.width = _local21 = _local12;
						}
					}
					_local22 = _local21;
				}
				_local13 += _local22 + _local20;
				_local10++;
			}
			return _local13 - (_local22 + _local20);
		}
	}
}

