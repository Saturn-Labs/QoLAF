package feathers.layout {
	import feathers.core.IFeathersControl;
	import feathers.core.IMeasureDisplayObject;
	import feathers.core.IValidating;
	import flash.errors.IllegalOperationError;
	import flash.geom.Point;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.events.EventDispatcher;
	
	public class VerticalLayout extends EventDispatcher implements IVariableVirtualLayout, ITrimmedVirtualLayout, IGroupedLayout {
		public static const VERTICAL_ALIGN_TOP:String = "top";
		
		public static const VERTICAL_ALIGN_MIDDLE:String = "middle";
		
		public static const VERTICAL_ALIGN_BOTTOM:String = "bottom";
		
		public static const HORIZONTAL_ALIGN_LEFT:String = "left";
		
		public static const HORIZONTAL_ALIGN_CENTER:String = "center";
		
		public static const HORIZONTAL_ALIGN_RIGHT:String = "right";
		
		public static const HORIZONTAL_ALIGN_JUSTIFY:String = "justify";
		
		protected var _heightCache:Array = [];
		
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
		
		protected var _stickyHeader:Boolean = false;
		
		protected var _headerIndices:Vector.<int>;
		
		protected var _useVirtualLayout:Boolean = true;
		
		protected var _hasVariableItemDimensions:Boolean = false;
		
		protected var _distributeHeights:Boolean = false;
		
		protected var _requestedRowCount:int = 0;
		
		protected var _beforeVirtualizedItemCount:int = 0;
		
		protected var _afterVirtualizedItemCount:int = 0;
		
		protected var _typicalItem:DisplayObject;
		
		protected var _resetTypicalItemDimensionsOnMeasure:Boolean = false;
		
		protected var _typicalItemWidth:Number = NaN;
		
		protected var _typicalItemHeight:Number = NaN;
		
		protected var _scrollPositionVerticalAlign:String = "middle";
		
		public function VerticalLayout() {
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
		
		public function get stickyHeader() : Boolean {
			return this._stickyHeader;
		}
		
		public function set stickyHeader(value:Boolean) : void {
			if(this._stickyHeader == value) {
				return;
			}
			this._stickyHeader = value;
			this.dispatchEventWith("change");
		}
		
		public function get headerIndices() : Vector.<int> {
			return this._headerIndices;
		}
		
		public function set headerIndices(value:Vector.<int>) : void {
			if(this._headerIndices == value) {
				return;
			}
			this._headerIndices = value;
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
		
		public function get distributeHeights() : Boolean {
			return this._distributeHeights;
		}
		
		public function set distributeHeights(value:Boolean) : void {
			if(this._distributeHeights == value) {
				return;
			}
			this._distributeHeights = value;
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
		
		public function get scrollPositionVerticalAlign() : String {
			return this._scrollPositionVerticalAlign;
		}
		
		public function set scrollPositionVerticalAlign(value:String) : void {
			this._scrollPositionVerticalAlign = value;
		}
		
		public function get requiresLayoutOnScroll() : Boolean {
			return this._useVirtualLayout || this._headerIndices && this._stickyHeader;
		}
		
		public function layout(items:Vector.<DisplayObject>, viewPortBounds:ViewPortBounds = null, result:LayoutBoundsResult = null) : LayoutBoundsResult {
			var _local25:Number = NaN;
			var _local23:Number = NaN;
			var _local38:Number = NaN;
			var _local42:int = 0;
			var _local20:DisplayObject = null;
			var _local11:int = 0;
			var _local13:Number = NaN;
			var _local14:* = NaN;
			var _local7:* = NaN;
			var _local30:DisplayObject = null;
			var _local37:Number = NaN;
			var _local6:ILayoutDisplayObject = null;
			var _local18:VerticalLayoutData = null;
			var _local33:Number = NaN;
			var _local31:IFeathersControl = null;
			var _local29:Number = NaN;
			var _local24:Number = NaN;
			var _local12:* = NaN;
			var _local55:Number = !!viewPortBounds ? viewPortBounds.scrollX : 0;
			var _local52:Number = !!viewPortBounds ? viewPortBounds.scrollY : 0;
			var _local49:Number = !!viewPortBounds ? viewPortBounds.x : 0;
			var _local51:Number = !!viewPortBounds ? viewPortBounds.y : 0;
			var _local43:Number = !!viewPortBounds ? viewPortBounds.minWidth : 0;
			var _local9:Number = !!viewPortBounds ? viewPortBounds.minHeight : 0;
			var _local16:Number = !!viewPortBounds ? viewPortBounds.maxWidth : Infinity;
			var _local35:Number = !!viewPortBounds ? viewPortBounds.maxHeight : Infinity;
			var _local47:Number = !!viewPortBounds ? viewPortBounds.explicitWidth : NaN;
			var _local53:Number = !!viewPortBounds ? viewPortBounds.explicitHeight : NaN;
			if(this._useVirtualLayout) {
				this.prepareTypicalItem(_local47 - this._paddingLeft - this._paddingRight);
				_local25 = !!this._typicalItem ? this._typicalItem.width : 0;
				_local23 = !!this._typicalItem ? this._typicalItem.height : 0;
			}
			var _local44:* = _local47 !== _local47;
			var _local41:* = _local53 !== _local53;
			if(!_local41 && this._distributeHeights) {
				_local38 = this.calculateDistributedHeight(items,_local53,_local9,_local35,false);
			}
			if(!this._useVirtualLayout || this._hasVariableItemDimensions || this._distributeHeights || this._horizontalAlign != "justify" || _local44) {
				this.validateItems(items,_local47 - this._paddingLeft - this._paddingRight,_local43 - this._paddingLeft - this._paddingRight,_local16 - this._paddingLeft - this._paddingRight,_local53 - this._paddingTop - this._paddingBottom,_local9 - this._paddingTop - this._paddingBottom,_local35 - this._paddingTop - this._paddingBottom,_local38);
			}
			if(_local41 && this._distributeHeights) {
				_local38 = this.calculateDistributedHeight(items,_local53,_local9,_local35,true);
			}
			var _local19:* = _local38 === _local38;
			if(!this._useVirtualLayout) {
				this.applyPercentHeights(items,_local53,_local9,_local35);
			}
			var _local32:* = this._firstGap === this._firstGap;
			var _local28:* = this._lastGap === this._lastGap;
			var _local54:* = this._useVirtualLayout ? _local25 : 0;
			var _local26:Number;
			var _local10:* = _local26 = _local51 + this._paddingTop;
			var _local50:int = 0;
			var _local45:int;
			var _local46:* = _local45 = int(items.length);
			if(this._useVirtualLayout && !this._hasVariableItemDimensions) {
				_local46 += this._beforeVirtualizedItemCount + this._afterVirtualizedItemCount;
				_local50 = this._beforeVirtualizedItemCount;
				_local10 += this._beforeVirtualizedItemCount * (_local23 + this._gap);
				if(_local32 && this._beforeVirtualizedItemCount > 0) {
					_local10 = _local10 - this._gap + this._firstGap;
				}
			}
			var _local17:int = _local46 - 2;
			this._discoveredItemsCache.length = 0;
			var _local34:int = 0;
			var _local36:Number = 0;
			var _local27:int = -1;
			var _local22:int = -1;
			var _local8:int = 0;
			var _local48:* = Infinity;
			if(this._headerIndices && this._stickyHeader) {
				_local8 = int(this._headerIndices.length);
				if(_local8 > 0) {
					_local27 = 0;
					_local22 = this._headerIndices[_local27];
				}
			}
			_local42 = 0;
			while(_local42 < _local45) {
				_local20 = items[_local42];
				_local11 = _local42 + _local50;
				if(_local22 === _local11) {
					if(_local10 - _local26 < _local52) {
						_local27++;
						if(_local27 < _local8) {
							_local22 = this._headerIndices[_local27];
						}
					} else {
						_local27--;
						if(_local27 >= 0) {
							_local22 = this._headerIndices[_local27];
							_local48 = _local10;
						}
					}
				}
				_local36 = this._gap;
				if(_local32 && _local11 == 0) {
					_local36 = this._firstGap;
				} else if(_local28 && _local11 > 0 && _local11 == _local17) {
					_local36 = this._lastGap;
				}
				if(this._useVirtualLayout && this._hasVariableItemDimensions) {
					_local13 = Number(this._heightCache[_local11]);
				}
				if(this._useVirtualLayout && !_local20) {
					if(!this._hasVariableItemDimensions || _local13 !== _local13) {
						_local10 += _local23 + _local36;
					} else {
						_local10 += _local13 + _local36;
					}
				} else if(!(_local20 is ILayoutDisplayObject && !ILayoutDisplayObject(_local20).includeInLayout)) {
					_local20.y = _local20.pivotY + _local10;
					_local14 = _local20.width;
					if(_local19) {
						_local20.height = _local7 = _local38;
					} else {
						_local7 = _local20.height;
					}
					if(this._useVirtualLayout) {
						if(this._hasVariableItemDimensions) {
							if(_local7 != _local13) {
								this._heightCache[_local11] = _local7;
								if(_local10 < _local52 && _local13 !== _local13 && _local7 != _local23) {
									this.dispatchEventWith("scroll",false,new Point(0,_local7 - _local23));
								}
								this.dispatchEventWith("change");
							}
						} else if(_local23 >= 0) {
							_local20.height = _local7 = _local23;
						}
					}
					_local10 += _local7 + _local36;
					if(_local14 > _local54) {
						_local54 = _local14;
					}
					if(this._useVirtualLayout) {
						this._discoveredItemsCache[_local34] = _local20;
						_local34++;
					}
				}
				_local42++;
			}
			if(this._useVirtualLayout && !this._hasVariableItemDimensions) {
				_local10 += this._afterVirtualizedItemCount * (_local23 + this._gap);
				if(_local28 && this._afterVirtualizedItemCount > 0) {
					_local10 = _local10 - this._gap + this._lastGap;
				}
			}
			if(_local22 >= 0) {
				_local30 = items[_local22];
				this.positionStickyHeader(_local30,_local52,_local48);
			}
			var _local39:Vector.<DisplayObject> = this._useVirtualLayout ? this._discoveredItemsCache : items;
			var _local21:int = int(_local39.length);
			var _local15:Number = _local54 + this._paddingLeft + this._paddingRight;
			var _local40:* = _local47;
			if(_local40 !== _local40) {
				_local40 = _local15;
				if(_local40 < _local43) {
					_local40 = _local43;
				} else if(_local40 > _local16) {
					_local40 = _local16;
				}
			}
			var _local4:Number = _local10 - _local36 + this._paddingBottom - _local51;
			var _local5:* = _local53;
			if(_local5 !== _local5) {
				_local5 = _local4;
				if(this._requestedRowCount > 0) {
					_local5 = this._requestedRowCount * (_local23 + this._gap) - this._gap + this._paddingTop + this._paddingBottom;
				} else {
					_local5 = _local4;
				}
				if(_local5 < _local9) {
					_local5 = _local9;
				} else if(_local5 > _local35) {
					_local5 = _local35;
				}
			}
			if(_local4 < _local5) {
				_local37 = 0;
				if(this._verticalAlign == "bottom") {
					_local37 = _local5 - _local4;
				} else if(this._verticalAlign == "middle") {
					_local37 = Math.round((_local5 - _local4) / 2);
				}
				if(_local37 != 0) {
					_local42 = 0;
					while(_local42 < _local21) {
						_local20 = _local39[_local42];
						if(!(_local20 is ILayoutDisplayObject && !ILayoutDisplayObject(_local20).includeInLayout)) {
							_local20.y += _local37;
						}
						_local42++;
					}
				}
			}
			_local42 = 0;
			while(_local42 < _local21) {
				_local20 = _local39[_local42];
				_local6 = _local20 as ILayoutDisplayObject;
				if(!(_local6 && !_local6.includeInLayout)) {
					if(this._horizontalAlign == "justify") {
						_local20.x = _local20.pivotX + _local49 + this._paddingLeft;
						_local20.width = _local40 - this._paddingLeft - this._paddingRight;
					} else {
						if(_local6) {
							_local18 = _local6.layoutData as VerticalLayoutData;
							if(_local18) {
								_local33 = _local18.percentWidth;
								if(_local33 === _local33) {
									if(_local33 < 0) {
										_local33 = 0;
									}
									if(_local33 > 100) {
										_local33 = 100;
									}
									_local14 = _local33 * (_local40 - this._paddingLeft - this._paddingRight) / 100;
									if(_local20 is IFeathersControl) {
										_local31 = IFeathersControl(_local20);
										_local29 = Number(_local31.minWidth);
										if(_local14 < _local29) {
											_local14 = _local29;
										} else {
											_local24 = Number(_local31.maxWidth);
											if(_local14 > _local24) {
												_local14 = _local24;
											}
										}
									}
									_local20.width = _local14;
								}
							}
						}
						_local12 = _local40;
						if(_local15 > _local12) {
							_local12 = _local15;
						}
						switch(this._horizontalAlign) {
							case "right":
								_local20.x = _local20.pivotX + _local49 + _local12 - this._paddingRight - _local20.width;
								break;
							case "center":
								_local20.x = _local20.pivotX + _local49 + this._paddingLeft + Math.round((_local12 - this._paddingLeft - this._paddingRight - _local20.width) / 2);
								break;
							default:
								_local20.x = _local20.pivotX + _local49 + this._paddingLeft;
						}
					}
				}
				_local42++;
			}
			this._discoveredItemsCache.length = 0;
			if(!result) {
				result = new LayoutBoundsResult();
			}
			result.contentX = 0;
			result.contentWidth = this._horizontalAlign == "justify" ? _local40 : _local15;
			result.contentY = 0;
			result.contentHeight = _local4;
			result.viewPortWidth = _local40;
			result.viewPortHeight = _local5;
			return result;
		}
		
		public function measureViewPort(itemCount:int, viewPortBounds:ViewPortBounds = null, result:Point = null) : Point {
			var _local14:Number = NaN;
			var _local20:* = NaN;
			var _local6:int = 0;
			var _local17:Number = NaN;
			var _local11:* = NaN;
			var _local9:* = NaN;
			if(!result) {
				result = new Point();
			}
			if(!this._useVirtualLayout) {
				throw new IllegalOperationError("measureViewPort() may be called only if useVirtualLayout is true.");
			}
			var _local12:Number = !!viewPortBounds ? viewPortBounds.explicitWidth : NaN;
			var _local19:Number = !!viewPortBounds ? viewPortBounds.explicitHeight : NaN;
			var _local4:* = _local12 !== _local12;
			var _local18:* = _local19 !== _local19;
			if(!_local4 && !_local18) {
				result.x = _local12;
				result.y = _local19;
				return result;
			}
			var _local7:Number = !!viewPortBounds ? viewPortBounds.minWidth : 0;
			var _local13:Number = !!viewPortBounds ? viewPortBounds.minHeight : 0;
			var _local21:Number = !!viewPortBounds ? viewPortBounds.maxWidth : Infinity;
			var _local16:Number = !!viewPortBounds ? viewPortBounds.maxHeight : Infinity;
			this.prepareTypicalItem(_local12 - this._paddingLeft - this._paddingRight);
			var _local10:Number = !!this._typicalItem ? this._typicalItem.width : 0;
			var _local5:Number = !!this._typicalItem ? this._typicalItem.height : 0;
			var _local8:* = this._firstGap === this._firstGap;
			var _local15:* = this._lastGap === this._lastGap;
			if(this._distributeHeights) {
				_local14 = (_local5 + this._gap) * itemCount;
			} else {
				_local14 = 0;
				_local20 = _local10;
				if(!this._hasVariableItemDimensions) {
					_local14 += (_local5 + this._gap) * itemCount;
				} else {
					_local6 = 0;
					while(_local6 < itemCount) {
						_local17 = Number(this._heightCache[_local6]);
						if(_local17 !== _local17) {
							_local14 += _local5 + this._gap;
						} else {
							_local14 += _local17 + this._gap;
						}
						_local6++;
					}
				}
			}
			_local14 -= this._gap;
			if(_local8 && itemCount > 1) {
				_local14 = _local14 - this._gap + this._firstGap;
			}
			if(_local15 && itemCount > 2) {
				_local14 = _local14 - this._gap + this._lastGap;
			}
			if(_local4) {
				_local11 = _local20 + this._paddingLeft + this._paddingRight;
				if(_local11 < _local7) {
					_local11 = _local7;
				} else if(_local11 > _local21) {
					_local11 = _local21;
				}
				result.x = _local11;
			} else {
				result.x = _local12;
			}
			if(_local18) {
				if(this._requestedRowCount > 0) {
					_local9 = (_local5 + this._gap) * this._requestedRowCount - this._gap;
				} else {
					_local9 = _local14;
				}
				_local9 += this._paddingTop + this._paddingBottom;
				if(_local9 < _local13) {
					_local9 = _local13;
				} else if(_local9 > _local16) {
					_local9 = _local16;
				}
				result.y = _local9;
			} else {
				result.y = _local19;
			}
			return result;
		}
		
		public function resetVariableVirtualCache() : void {
			this._heightCache.length = 0;
		}
		
		public function resetVariableVirtualCacheAtIndex(index:int, item:DisplayObject = null) : void {
			delete this._heightCache[index];
			if(item) {
				this._heightCache[index] = item.height;
				this.dispatchEventWith("change");
			}
		}
		
		public function addToVariableVirtualCacheAtIndex(index:int, item:DisplayObject = null) : void {
			var _local3:* = !!item ? item.height : undefined;
			this._heightCache.insertAt(index,_local3);
		}
		
		public function removeFromVariableVirtualCacheAtIndex(index:int) : void {
			this._heightCache.removeAt(index);
		}
		
		public function getVisibleIndicesAtScrollPosition(scrollX:Number, scrollY:Number, width:Number, height:Number, itemCount:int, result:Vector.<int> = null) : Vector.<int> {
			var _local15:Number = NaN;
			var _local33:int = 0;
			var _local36:int = 0;
			var _local34:int = 0;
			var _local26:* = 0;
			var _local18:Number = NaN;
			var _local19:Number = NaN;
			var _local8:* = NaN;
			var _local12:* = NaN;
			var _local21:Boolean = false;
			var _local13:int = 0;
			var _local10:int = 0;
			var _local16:int = 0;
			var _local17:* = 0;
			if(result) {
				result.length = 0;
			} else {
				result = new Vector.<int>(0);
			}
			if(!this._useVirtualLayout) {
				throw new IllegalOperationError("getVisibleIndicesAtScrollPosition() may be called only if useVirtualLayout is true.");
			}
			this.prepareTypicalItem(width - this._paddingLeft - this._paddingRight);
			var _local27:Number = !!this._typicalItem ? this._typicalItem.width : 0;
			var _local24:Number = !!this._typicalItem ? this._typicalItem.height : 0;
			var _local11:* = this._firstGap === this._firstGap;
			var _local32:* = this._lastGap === this._lastGap;
			var _local7:* = 0;
			var _local30:int = Math.ceil(height / (_local24 + this._gap)) + 1;
			if(!this._hasVariableItemDimensions) {
				_local15 = itemCount * (_local24 + this._gap) - this._gap;
				if(_local11 && itemCount > 1) {
					_local15 = _local15 - this._gap + this._firstGap;
				}
				if(_local32 && itemCount > 2) {
					_local15 = _local15 - this._gap + this._lastGap;
				}
				_local33 = 0;
				if(_local15 < height) {
					if(this._verticalAlign == "bottom") {
						_local33 = Math.ceil((height - _local15) / (_local24 + this._gap));
					} else if(this._verticalAlign == "middle") {
						_local33 = Math.ceil((height - _local15) / (_local24 + this._gap) / 2);
					}
				}
				_local36 = (scrollY - this._paddingTop) / (_local24 + this._gap);
				if(_local36 < 0) {
					_local36 = 0;
				}
				_local36 -= _local33;
				_local34 = _local36 + _local30;
				if(_local34 >= itemCount) {
					_local34 = itemCount - 1;
				}
				_local36 = _local34 - _local30;
				if(_local36 < 0) {
					_local36 = 0;
				}
				_local26 = _local36;
				while(_local26 <= _local34) {
					if(_local26 >= 0 && _local26 < itemCount) {
						result[_local7] = _local26;
					} else if(_local26 < 0) {
						result[_local7] = itemCount + _local26;
					} else if(_local26 >= itemCount) {
						result[_local7] = _local26 - itemCount;
					}
					_local7++;
					_local26++;
				}
				return result;
			}
			var _local31:int = -1;
			var _local22:int = -1;
			var _local9:int = 0;
			if(this._headerIndices && this._stickyHeader) {
				_local9 = int(this._headerIndices.length);
				if(_local9 > 0) {
					_local31 = 0;
					_local22 = this._headerIndices[_local31];
				}
			}
			var _local20:int = itemCount - 2;
			var _local23:Number = scrollY + height;
			var _local28:Number = this._paddingTop;
			var _local29:Boolean = false;
			var _local14:* = _local28;
			_local26 = 0;
			while(_local26 < itemCount) {
				if(_local22 === _local26) {
					if(_local14 - _local28 < scrollY) {
						_local31++;
						if(_local31 < _local9) {
							_local22 = this._headerIndices[_local31];
						}
					} else {
						_local31--;
						if(_local31 >= 0) {
							_local22 = this._headerIndices[_local31];
							_local29 = true;
						}
					}
				}
				_local18 = this._gap;
				if(_local11 && _local26 == 0) {
					_local18 = this._firstGap;
				} else if(_local32 && _local26 > 0 && _local26 == _local20) {
					_local18 = this._lastGap;
				}
				_local19 = Number(this._heightCache[_local26]);
				if(_local19 !== _local19) {
					_local8 = _local24;
				} else {
					_local8 = _local19;
				}
				_local12 = _local14;
				_local14 += _local8 + _local18;
				if(_local14 > scrollY && _local12 < _local23) {
					result[_local7] = _local26;
					_local7++;
				}
				if(_local14 >= _local23) {
					if(!_local29) {
						_local31--;
						if(_local31 >= 0) {
							_local22 = this._headerIndices[_local31];
						}
					}
					break;
				}
				_local26++;
			}
			if(_local22 >= 0 && result.indexOf(_local22) < 0) {
				_local21 = false;
				_local26 = 0;
				while(_local26 < _local7) {
					if(_local22 <= result[_local26]) {
						result.insertAt(_local26,_local22);
						_local21 = true;
						break;
					}
					_local26++;
				}
				if(!_local21) {
					result[_local7] = _local22;
				}
				_local7++;
			}
			var _local35:int = int(result.length);
			var _local25:int = _local30 - _local35;
			if(_local25 > 0 && _local35 > 0) {
				_local13 = result[0];
				_local10 = _local13 - _local25;
				if(_local10 < 0) {
					_local10 = 0;
				}
				_local26 = _local13 - 1;
				while(_local26 >= _local10) {
					if(_local26 !== _local22) {
						result.insertAt(0,_local26);
					}
					_local26--;
				}
			}
			_local35 = int(result.length);
			_local25 = _local30 - _local35;
			_local7 = _local35;
			if(_local25 > 0) {
				_local16 = int(_local35 > 0 ? result[_local35 - 1] + 1 : 0);
				_local17 = _local16 + _local25;
				if(_local17 > itemCount) {
					_local17 = itemCount;
				}
				_local26 = _local16;
				while(_local26 < _local17) {
					if(_local26 !== _local22) {
						result[_local7] = _local26;
						_local7++;
					}
					_local26++;
				}
			}
			return result;
		}
		
		public function getNearestScrollPositionForIndex(index:int, scrollX:Number, scrollY:Number, items:Vector.<DisplayObject>, x:Number, y:Number, width:Number, height:Number, result:Point = null) : Point {
			var _local11:Number = NaN;
			var _local13:Number = NaN;
			var _local14:Number = NaN;
			var _local10:Number = this.calculateMaxScrollYOfIndex(index,items,x,y,width,height);
			if(this._useVirtualLayout) {
				if(this._hasVariableItemDimensions) {
					_local11 = Number(this._heightCache[index]);
					if(_local11 !== _local11) {
						_local11 = this._typicalItem.height;
					}
				} else {
					_local11 = this._typicalItem.height;
				}
			} else {
				_local11 = items[index].height;
			}
			if(!result) {
				result = new Point();
			}
			result.x = 0;
			var _local12:Number = _local10 - (height - _local11);
			if(scrollY >= _local12 && scrollY <= _local10) {
				result.y = scrollY;
			} else {
				_local13 = Math.abs(_local10 - scrollY);
				_local14 = Math.abs(_local12 - scrollY);
				if(_local14 < _local13) {
					result.y = _local12;
				} else {
					result.y = _local10;
				}
			}
			return result;
		}
		
		public function getScrollPositionForIndex(index:int, items:Vector.<DisplayObject>, x:Number, y:Number, width:Number, height:Number, result:Point = null) : Point {
			var _local9:Number = NaN;
			var _local8:Number = this.calculateMaxScrollYOfIndex(index,items,x,y,width,height);
			if(this._useVirtualLayout) {
				if(this._hasVariableItemDimensions) {
					_local9 = Number(this._heightCache[index]);
					if(_local9 !== _local9) {
						_local9 = this._typicalItem.height;
					}
				} else {
					_local9 = this._typicalItem.height;
				}
			} else {
				_local9 = items[index].height;
			}
			if(!result) {
				result = new Point();
			}
			result.x = 0;
			if(this._scrollPositionVerticalAlign == "middle") {
				_local8 -= Math.round((height - _local9) / 2);
			} else if(this._scrollPositionVerticalAlign == "bottom") {
				_local8 -= height - _local9;
			}
			result.y = _local8;
			return result;
		}
		
		protected function validateItems(items:Vector.<DisplayObject>, explicitWidth:Number, minWidth:Number, maxWidth:Number, explicitHeight:Number, minHeight:Number, maxHeight:Number, distributedHeight:Number) : void {
			var _local23:int = 0;
			var _local20:DisplayObject = null;
			var _local12:IFeathersControl = null;
			var _local9:ILayoutDisplayObject = null;
			var _local19:VerticalLayoutData = null;
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
			var _local10:* = this._horizontalAlign == "justify";
			var _local24:int = int(items.length);
			_local23 = 0;
			while(_local23 < _local24) {
				_local20 = items[_local23];
				if(!(!_local20 || _local20 is ILayoutDisplayObject && !ILayoutDisplayObject(_local20).includeInLayout)) {
					if(_local10) {
						_local20.width = explicitWidth;
						if(_local20 is IFeathersControl) {
							_local12 = IFeathersControl(_local20);
							_local12.minWidth = minWidth;
							_local12.maxWidth = maxWidth;
						}
					} else if(_local20 is ILayoutDisplayObject) {
						_local9 = ILayoutDisplayObject(_local20);
						_local19 = _local9.layoutData as VerticalLayoutData;
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
								_local20.width = _local18;
							}
							if(_local16 === _local16) {
								_local11 = _local25 * _local16 / 100;
								_local26 = IMeasureDisplayObject(_local20);
								_local15 = _local26.explicitMinHeight;
								if(_local26.explicitMinHeight === _local26.explicitMinHeight && _local11 < _local15) {
									_local11 = _local15;
								}
								_local26.maxHeight = _local11;
								_local20.height = NaN;
							}
						}
					}
					if(this._distributeHeights) {
						_local20.height = distributedHeight;
					}
					if(_local20 is IValidating) {
						IValidating(_local20).validate();
					}
				}
				_local23++;
			}
		}
		
		protected function prepareTypicalItem(justifyWidth:Number) : void {
			var _local4:ILayoutDisplayObject = null;
			var _local3:VerticalLayoutData = null;
			var _local5:Number = NaN;
			if(!this._typicalItem) {
				return;
			}
			var _local2:Boolean = false;
			if(this._horizontalAlign == "justify" && justifyWidth === justifyWidth) {
				_local2 = true;
				this._typicalItem.width = justifyWidth;
			} else if(this._typicalItem is ILayoutDisplayObject) {
				_local4 = ILayoutDisplayObject(this._typicalItem);
				_local3 = _local4.layoutData as VerticalLayoutData;
				if(_local3 !== null) {
					_local5 = _local3.percentWidth;
					if(_local5 === _local5) {
						if(_local5 < 0) {
							_local5 = 0;
						}
						if(_local5 > 100) {
							_local5 = 100;
						}
						_local2 = true;
						this._typicalItem.width = justifyWidth * _local5 / 100;
					}
				}
			}
			if(!_local2 && this._resetTypicalItemDimensionsOnMeasure) {
				this._typicalItem.width = this._typicalItemWidth;
			}
			if(this._resetTypicalItemDimensionsOnMeasure) {
				this._typicalItem.height = this._typicalItemHeight;
			}
			if(this._typicalItem is IValidating) {
				IValidating(this._typicalItem).validate();
			}
		}
		
		protected function calculateDistributedHeight(items:Vector.<DisplayObject>, explicitHeight:Number, minHeight:Number, maxHeight:Number, measureItems:Boolean) : Number {
			var _local6:* = NaN;
			var _local9:int = 0;
			var _local7:DisplayObject = null;
			var _local8:Number = NaN;
			var _local12:Boolean = false;
			var _local13:* = explicitHeight !== explicitHeight;
			var _local10:int = int(items.length);
			if(measureItems && _local13) {
				_local6 = 0;
				_local9 = 0;
				while(_local9 < _local10) {
					_local7 = items[_local9];
					_local8 = _local7.height;
					if(_local8 > _local6) {
						_local6 = _local8;
					}
					_local9++;
				}
				explicitHeight = _local6 * _local10 + this._paddingTop + this._paddingBottom + this._gap * (_local10 - 1);
				_local12 = false;
				if(explicitHeight > maxHeight) {
					explicitHeight = maxHeight;
					_local12 = true;
				} else if(explicitHeight < minHeight) {
					explicitHeight = minHeight;
					_local12 = true;
				}
				if(!_local12) {
					return _local6;
				}
			}
			var _local11:* = explicitHeight;
			if(_local13 && maxHeight < Infinity) {
				_local11 = maxHeight;
			}
			_local11 = _local11 - this._paddingTop - this._paddingBottom - this._gap * (_local10 - 1);
			if(_local10 > 1 && this._firstGap === this._firstGap) {
				_local11 += this._gap - this._firstGap;
			}
			if(_local10 > 2 && this._lastGap === this._lastGap) {
				_local11 += this._gap - this._lastGap;
			}
			return _local11 / _local10;
		}
		
		protected function applyPercentHeights(items:Vector.<DisplayObject>, explicitHeight:Number, minHeight:Number, maxHeight:Number) : void {
			var _local10:int = 0;
			var _local7:DisplayObject = null;
			var _local8:ILayoutDisplayObject = null;
			var _local6:VerticalLayoutData = null;
			var _local17:Number = NaN;
			var _local11:IFeathersControl = null;
			var _local12:Boolean = false;
			var _local20:Number = NaN;
			var _local9:* = NaN;
			var _local21:* = NaN;
			var _local18:Number = NaN;
			var _local5:* = explicitHeight;
			this._discoveredItemsCache.length = 0;
			var _local16:Number = 0;
			var _local19:Number = 0;
			var _local13:Number = 0;
			var _local15:int = int(items.length);
			var _local14:int = 0;
			_local10 = 0;
			for(; _local10 < _local15; _local10++) {
				_local7 = items[_local10];
				if(_local7 is ILayoutDisplayObject) {
					_local8 = ILayoutDisplayObject(_local7);
					if(!_local8.includeInLayout) {
						continue;
					}
					_local6 = _local8.layoutData as VerticalLayoutData;
					if(_local6) {
						_local17 = _local6.percentHeight;
						if(_local17 === _local17) {
							if(_local8 is IFeathersControl) {
								_local11 = IFeathersControl(_local8);
								_local19 += _local11.minHeight;
							}
							_local13 += _local17;
							this._discoveredItemsCache[_local14] = _local7;
							_local14++;
							continue;
						}
					}
				}
				_local16 += _local7.height;
			}
			_local16 += this._gap * (_local15 - 1);
			if(this._firstGap === this._firstGap && _local15 > 1) {
				_local16 += this._firstGap - this._gap;
			} else if(this._lastGap === this._lastGap && _local15 > 2) {
				_local16 += this._lastGap - this._gap;
			}
			_local16 += this._paddingTop + this._paddingBottom;
			if(_local13 < 100) {
				_local13 = 100;
			}
			if(_local5 !== _local5) {
				_local5 = _local16 + _local19;
				if(_local5 < minHeight) {
					_local5 = minHeight;
				} else if(_local5 > maxHeight) {
					_local5 = maxHeight;
				}
			}
			_local5 -= _local16;
			if(_local5 < 0) {
				_local5 = 0;
			}
			do {
				_local12 = false;
				_local20 = _local5 / _local13;
				_local10 = 0;
				while(_local10 < _local14) {
					_local8 = ILayoutDisplayObject(this._discoveredItemsCache[_local10]);
					if(_local8) {
						_local6 = VerticalLayoutData(_local8.layoutData);
						_local17 = _local6.percentHeight;
						_local9 = _local20 * _local17;
						if(_local8 is IFeathersControl) {
							_local11 = IFeathersControl(_local8);
							_local21 = Number(_local11.minHeight);
							if(_local21 > _local5) {
								_local21 = _local5;
							}
							if(_local9 < _local21) {
								_local9 = _local21;
								_local5 -= _local9;
								_local13 -= _local17;
								this._discoveredItemsCache[_local10] = null;
								_local12 = true;
							} else {
								_local18 = Number(_local11.maxHeight);
								if(_local9 > _local18) {
									_local9 = _local18;
									_local5 -= _local9;
									_local13 -= _local17;
									this._discoveredItemsCache[_local10] = null;
									_local12 = true;
								}
							}
						}
						_local8.height = _local9;
						if(_local8 is IValidating) {
							IValidating(_local8).validate();
						}
					}
					_local10++;
				}
			}
			while(_local12);
			
			this._discoveredItemsCache.length = 0;
		}
		
		protected function calculateMaxScrollYOfIndex(index:int, items:Vector.<DisplayObject>, x:Number, y:Number, width:Number, height:Number) : Number {
			var _local13:Number = NaN;
			var _local9:Number = NaN;
			var _local11:int = 0;
			var _local8:DisplayObject = null;
			var _local18:int = 0;
			var _local21:Number = NaN;
			var _local10:* = NaN;
			if(this._useVirtualLayout) {
				this.prepareTypicalItem(width - this._paddingLeft - this._paddingRight);
				_local13 = !!this._typicalItem ? this._typicalItem.width : 0;
				_local9 = !!this._typicalItem ? this._typicalItem.height : 0;
			}
			var _local12:* = this._firstGap === this._firstGap;
			var _local19:* = this._lastGap === this._lastGap;
			var _local16:Number = y + this._paddingTop;
			var _local23:* = 0;
			var _local20:Number = this._gap;
			var _local17:int = 0;
			var _local22:Number = 0;
			var _local14:int;
			var _local15:* = _local14 = int(items.length);
			if(this._useVirtualLayout && !this._hasVariableItemDimensions) {
				_local15 += this._beforeVirtualizedItemCount + this._afterVirtualizedItemCount;
				if(index < this._beforeVirtualizedItemCount) {
					_local17 = index + 1;
					_local23 = _local9;
					_local20 = this._gap;
				} else {
					_local17 = this._beforeVirtualizedItemCount;
					_local22 = index - items.length - this._beforeVirtualizedItemCount + 1;
					if(_local22 < 0) {
						_local22 = 0;
					}
					_local16 += _local22 * (_local9 + this._gap);
				}
				_local16 += _local17 * (_local9 + this._gap);
			}
			index -= _local17 + _local22;
			var _local7:int = _local15 - 2;
			_local11 = 0;
			while(_local11 <= index) {
				_local8 = items[_local11];
				_local18 = _local11 + _local17;
				if(_local12 && _local18 == 0) {
					_local20 = this._firstGap;
				} else if(_local19 && _local18 > 0 && _local18 == _local7) {
					_local20 = this._lastGap;
				} else {
					_local20 = this._gap;
				}
				if(this._useVirtualLayout && this._hasVariableItemDimensions) {
					_local21 = Number(this._heightCache[_local18]);
				}
				if(this._useVirtualLayout && !_local8) {
					if(!this._hasVariableItemDimensions || _local21 !== _local21) {
						_local23 = _local9;
					} else {
						_local23 = _local21;
					}
				} else {
					_local10 = _local8.height;
					if(this._useVirtualLayout) {
						if(this._hasVariableItemDimensions) {
							if(_local10 != _local21) {
								this._heightCache[_local18] = _local10;
								this.dispatchEventWith("change");
							}
						} else if(_local9 >= 0) {
							_local8.height = _local10 = _local9;
						}
					}
					_local23 = _local10;
				}
				_local16 += _local23 + _local20;
				_local11++;
			}
			return _local16 - (_local23 + _local20);
		}
		
		protected function positionStickyHeader(header:DisplayObject, scrollY:Number, maxY:Number) : void {
			if(!header || header.y >= scrollY) {
				return;
			}
			if(header is IValidating) {
				IValidating(header).validate();
			}
			maxY -= header.height;
			if(maxY > scrollY) {
				maxY = scrollY;
			}
			header.y = maxY;
			var _local4:DisplayObjectContainer = header.parent;
			if(_local4) {
				_local4.setChildIndex(header,_local4.numChildren - 1);
			}
		}
	}
}

