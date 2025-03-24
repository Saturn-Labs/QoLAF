package feathers.layout {
	import feathers.core.IValidating;
	import flash.errors.IllegalOperationError;
	import flash.geom.Point;
	import starling.display.DisplayObject;
	import starling.events.EventDispatcher;
	
	public class FlowLayout extends EventDispatcher implements IVariableVirtualLayout {
		public static const VERTICAL_ALIGN_TOP:String = "top";
		
		public static const VERTICAL_ALIGN_MIDDLE:String = "middle";
		
		public static const VERTICAL_ALIGN_BOTTOM:String = "bottom";
		
		public static const HORIZONTAL_ALIGN_LEFT:String = "left";
		
		public static const HORIZONTAL_ALIGN_CENTER:String = "center";
		
		public static const HORIZONTAL_ALIGN_RIGHT:String = "right";
		
		protected var _rowItems:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
		
		protected var _horizontalGap:Number = 0;
		
		protected var _verticalGap:Number = 0;
		
		protected var _firstHorizontalGap:Number = NaN;
		
		protected var _lastHorizontalGap:Number = NaN;
		
		protected var _paddingTop:Number = 0;
		
		protected var _paddingRight:Number = 0;
		
		protected var _paddingBottom:Number = 0;
		
		protected var _paddingLeft:Number = 0;
		
		protected var _horizontalAlign:String = "left";
		
		protected var _verticalAlign:String = "top";
		
		protected var _rowVerticalAlign:String = "top";
		
		protected var _useVirtualLayout:Boolean = true;
		
		protected var _typicalItem:DisplayObject;
		
		protected var _hasVariableItemDimensions:Boolean = true;
		
		protected var _widthCache:Array = [];
		
		protected var _heightCache:Array = [];
		
		public function FlowLayout() {
			super();
		}
		
		public function get gap() : Number {
			return this._horizontalGap;
		}
		
		public function set gap(value:Number) : void {
			this.horizontalGap = value;
			this.verticalGap = value;
		}
		
		public function get horizontalGap() : Number {
			return this._horizontalGap;
		}
		
		public function set horizontalGap(value:Number) : void {
			if(this._horizontalGap == value) {
				return;
			}
			this._horizontalGap = value;
			this.dispatchEventWith("change");
		}
		
		public function get verticalGap() : Number {
			return this._verticalGap;
		}
		
		public function set verticalGap(value:Number) : void {
			if(this._verticalGap == value) {
				return;
			}
			this._verticalGap = value;
			this.dispatchEventWith("change");
		}
		
		public function get firstHorizontalGap() : Number {
			return this._firstHorizontalGap;
		}
		
		public function set firstHorizontalGap(value:Number) : void {
			if(this._firstHorizontalGap == value) {
				return;
			}
			this._firstHorizontalGap = value;
			this.dispatchEventWith("change");
		}
		
		public function get lastHorizontalGap() : Number {
			return this._lastHorizontalGap;
		}
		
		public function set lastHorizontalGap(value:Number) : void {
			if(this._lastHorizontalGap == value) {
				return;
			}
			this._lastHorizontalGap = value;
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
		
		public function get rowVerticalAlign() : String {
			return this._rowVerticalAlign;
		}
		
		public function set rowVerticalAlign(value:String) : void {
			if(this._rowVerticalAlign == value) {
				return;
			}
			this._rowVerticalAlign = value;
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
		
		public function get requiresLayoutOnScroll() : Boolean {
			return this._useVirtualLayout;
		}
		
		public function layout(items:Vector.<DisplayObject>, viewPortBounds:ViewPortBounds = null, result:LayoutBoundsResult = null) : LayoutBoundsResult {
			var _local31:Number = NaN;
			var _local25:Number = NaN;
			var _local10:Number = NaN;
			var _local30:int = 0;
			var _local36:Number = NaN;
			var _local22:DisplayObject = null;
			var _local34:Number = NaN;
			var _local16:Number = NaN;
			var _local17:* = NaN;
			var _local7:* = NaN;
			var _local42:int = 0;
			var _local8:Number = NaN;
			var _local39:Number = NaN;
			var _local29:int = 0;
			var _local6:ILayoutDisplayObject = null;
			var _local32:* = NaN;
			var _local13:Number = NaN;
			var _local37:Number = !!viewPortBounds ? viewPortBounds.x : 0;
			var _local38:Number = !!viewPortBounds ? viewPortBounds.y : 0;
			var _local28:Number = !!viewPortBounds ? viewPortBounds.minWidth : 0;
			var _local11:Number = !!viewPortBounds ? viewPortBounds.minHeight : 0;
			var _local18:Number = !!viewPortBounds ? viewPortBounds.maxWidth : Infinity;
			var _local14:Number = !!viewPortBounds ? viewPortBounds.maxHeight : Infinity;
			var _local35:Number = !!viewPortBounds ? viewPortBounds.explicitWidth : NaN;
			var _local40:Number = !!viewPortBounds ? viewPortBounds.explicitHeight : NaN;
			var _local23:* = _local35 !== _local35;
			var _local20:Boolean = true;
			var _local24:* = _local35;
			if(_local23) {
				_local24 = _local18;
				if(_local24 === Infinity) {
					_local20 = false;
				}
			}
			if(this._useVirtualLayout) {
				if(this._typicalItem is IValidating) {
					IValidating(this._typicalItem).validate();
				}
				_local31 = !!this._typicalItem ? this._typicalItem.width : 0;
				_local25 = !!this._typicalItem ? this._typicalItem.height : 0;
			}
			var _local27:int = 0;
			var _local33:int = int(items.length);
			var _local12:Number = _local38 + this._paddingTop;
			var _local15:* = 0;
			var _local21:* = 0;
			var _local9:Number = this._verticalGap;
			var _local26:* = this._firstHorizontalGap === this._firstHorizontalGap;
			var _local41:* = this._lastHorizontalGap === this._lastHorizontalGap;
			var _local19:int = _local33 - 2;
			do {
				if(_local27 > 0) {
					_local12 += _local21 + _local9;
				}
				_local21 = this._useVirtualLayout ? _local25 : 0;
				_local10 = _local37 + this._paddingLeft;
				this._rowItems.length = 0;
				_local30 = 0;
				_local36 = 0;
				for(; _local27 < _local33; _local27++) {
					_local22 = items[_local27];
					_local36 = this._horizontalGap;
					if(_local26 && _local27 === 0) {
						_local36 = this._firstHorizontalGap;
					} else if(_local41 && _local27 > 0 && _local27 == _local19) {
						_local36 = this._lastHorizontalGap;
					}
					if(this._useVirtualLayout && this._hasVariableItemDimensions) {
						_local34 = Number(this._widthCache[_local27]);
						_local16 = Number(this._heightCache[_local27]);
					}
					if(this._useVirtualLayout && !_local22) {
						if(this._hasVariableItemDimensions) {
							if(_local34 !== _local34) {
								_local17 = _local31;
							} else {
								_local17 = _local34;
							}
							if(_local16 !== _local16) {
								_local7 = _local25;
							} else {
								_local7 = _local16;
							}
						} else {
							_local17 = _local31;
							_local7 = _local25;
						}
					} else {
						if(_local22 is ILayoutDisplayObject && !ILayoutDisplayObject(_local22).includeInLayout) {
							continue;
						}
						if(_local22 is IValidating) {
							IValidating(_local22).validate();
						}
						_local17 = _local22.width;
						_local7 = _local22.height;
						if(this._useVirtualLayout) {
							if(this._hasVariableItemDimensions) {
								if(_local17 != _local34) {
									this._widthCache[_local27] = _local17;
									this.dispatchEventWith("change");
								}
								if(_local7 != _local16) {
									this._heightCache[_local27] = _local7;
									this.dispatchEventWith("change");
								}
							} else {
								if(_local31 >= 0) {
									_local22.width = _local17 = _local31;
								}
								if(_local25 >= 0) {
									_local22.height = _local7 = _local25;
								}
							}
						}
					}
					if(_local20 && _local30 > 0 && _local10 + _local17 > _local24 - this._paddingRight) {
						_local42 = _local27 - 1;
						_local36 = this._horizontalGap;
						if(_local26 && _local42 === 0) {
							_local36 = this._firstHorizontalGap;
						} else if(_local41 && _local42 > 0 && _local42 == _local19) {
							_local36 = this._lastHorizontalGap;
						}
						break;
					}
					if(_local22) {
						this._rowItems[this._rowItems.length] = _local22;
						_local22.x = _local22.pivotX + _local10;
					}
					_local10 += _local17 + _local36;
					if(_local7 > _local21) {
						_local21 = _local7;
					}
					_local30++;
				}
				_local8 = _local10 - _local36 + this._paddingRight - _local37;
				if(_local8 > _local15) {
					_local15 = _local8;
				}
				_local30 = int(this._rowItems.length);
				if(_local20) {
					_local39 = 0;
					if(this._horizontalAlign === "right") {
						_local39 = _local24 - _local8;
					} else if(this._horizontalAlign === "center") {
						_local39 = Math.round((_local24 - _local8) / 2);
					}
					if(_local39 != 0) {
						_local29 = 0;
						while(_local29 < _local30) {
							_local22 = this._rowItems[_local29];
							if(!(_local22 is ILayoutDisplayObject && !ILayoutDisplayObject(_local22).includeInLayout)) {
								_local22.x += _local39;
							}
							_local29++;
						}
					}
				}
				_local29 = 0;
				while(_local29 < _local30) {
					_local22 = this._rowItems[_local29];
					_local6 = _local22 as ILayoutDisplayObject;
					if(!(_local6 && !_local6.includeInLayout)) {
						switch(this._rowVerticalAlign) {
							case "bottom":
								_local22.y = _local22.pivotY + _local12 + _local21 - _local22.height;
								break;
							case "middle":
								_local22.y = _local22.pivotY + _local12 + Math.round((_local21 - _local22.height) / 2);
								break;
							default:
								_local22.y = _local22.pivotY + _local12;
						}
					}
					_local29++;
				}
			}
			while(_local27 < _local33);
			
			this._rowItems.length = 0;
			if(_local20) {
				if(_local23) {
					_local32 = _local24;
					_local24 = _local15;
					if(_local24 < _local28) {
						_local24 = _local28;
					} else if(_local24 > _local18) {
						_local24 = _local18;
					}
					_local39 = 0;
					if(this._horizontalAlign === "right") {
						_local39 = _local32 - _local24;
					} else if(this._horizontalAlign === "center") {
						_local39 = Math.round((_local32 - _local24) / 2);
					}
					if(_local39 !== 0) {
						_local27 = 0;
						while(_local27 < _local33) {
							_local22 = items[_local27];
							if(!(!_local22 || _local22 is ILayoutDisplayObject && !ILayoutDisplayObject(_local22).includeInLayout)) {
								_local22.x -= _local39;
							}
							_local27++;
						}
					}
				}
			} else {
				_local24 = _local15;
			}
			var _local4:Number = _local12 + _local21 + this._paddingBottom;
			var _local5:* = _local40;
			if(_local5 !== _local5) {
				_local5 = _local4;
				if(_local5 < _local11) {
					_local5 = _local11;
				} else if(_local5 > _local14) {
					_local5 = _local14;
				}
			}
			if(_local4 < _local5 && this._verticalAlign != "top") {
				_local13 = _local5 - _local4;
				if(this._verticalAlign === "middle") {
					_local13 /= 2;
				}
				_local27 = 0;
				while(_local27 < _local33) {
					_local22 = items[_local27];
					if(!(!_local22 || _local22 is ILayoutDisplayObject && !ILayoutDisplayObject(_local22).includeInLayout)) {
						_local22.y += _local13;
					}
					_local27++;
				}
			}
			if(!result) {
				result = new LayoutBoundsResult();
			}
			result.contentX = 0;
			result.contentWidth = _local15;
			result.contentY = 0;
			result.contentHeight = _local4;
			result.viewPortWidth = _local24;
			result.viewPortHeight = _local5;
			return result;
		}
		
		public function measureViewPort(itemCount:int, viewPortBounds:ViewPortBounds = null, result:Point = null) : Point {
			var _local9:Number = NaN;
			var _local25:int = 0;
			var _local29:Number = NaN;
			var _local27:Number = NaN;
			var _local14:Number = NaN;
			var _local15:* = NaN;
			var _local6:* = NaN;
			var _local7:Number = NaN;
			if(!result) {
				result = new Point();
			}
			if(!this._useVirtualLayout) {
				throw new IllegalOperationError("measureViewPort() may be called only if useVirtualLayout is true.");
			}
			var _local30:Number = !!viewPortBounds ? viewPortBounds.x : 0;
			var _local31:Number = !!viewPortBounds ? viewPortBounds.y : 0;
			var _local24:Number = !!viewPortBounds ? viewPortBounds.minWidth : 0;
			var _local10:Number = !!viewPortBounds ? viewPortBounds.minHeight : 0;
			var _local16:Number = !!viewPortBounds ? viewPortBounds.maxWidth : Infinity;
			var _local12:Number = !!viewPortBounds ? viewPortBounds.maxHeight : Infinity;
			var _local28:Number = !!viewPortBounds ? viewPortBounds.explicitWidth : NaN;
			var _local32:Number = !!viewPortBounds ? viewPortBounds.explicitHeight : NaN;
			var _local18:Boolean = true;
			var _local20:* = _local28;
			if(_local20 !== _local20) {
				_local20 = _local16;
				if(_local20 === Infinity) {
					_local18 = false;
				}
			}
			if(this._typicalItem is IValidating) {
				IValidating(this._typicalItem).validate();
			}
			var _local26:Number = !!this._typicalItem ? this._typicalItem.width : 0;
			var _local21:Number = !!this._typicalItem ? this._typicalItem.height : 0;
			var _local23:int = 0;
			var _local11:Number = _local31 + this._paddingTop;
			var _local13:* = 0;
			var _local19:* = 0;
			var _local8:Number = this._verticalGap;
			var _local22:* = this._firstHorizontalGap === this._firstHorizontalGap;
			var _local33:* = this._lastHorizontalGap === this._lastHorizontalGap;
			var _local17:int = itemCount - 2;
			do {
				if(_local23 > 0) {
					_local11 += _local19 + _local8;
				}
				_local19 = this._useVirtualLayout ? _local21 : 0;
				_local9 = _local30 + this._paddingLeft;
				_local25 = 0;
				_local29 = 0;
				while(_local23 < itemCount) {
					_local29 = this._horizontalGap;
					if(_local22 && _local23 === 0) {
						_local29 = this._firstHorizontalGap;
					} else if(_local33 && _local23 > 0 && _local23 == _local17) {
						_local29 = this._lastHorizontalGap;
					}
					if(this._hasVariableItemDimensions) {
						_local27 = Number(this._widthCache[_local23]);
						_local14 = Number(this._heightCache[_local23]);
						if(_local27 !== _local27) {
							_local15 = _local26;
						} else {
							_local15 = _local27;
						}
						if(_local14 !== _local14) {
							_local6 = _local21;
						} else {
							_local6 = _local14;
						}
					} else {
						_local15 = _local26;
						_local6 = _local21;
					}
					if(_local18 && _local25 > 0 && _local9 + _local15 > _local20 - this._paddingRight) {
						break;
					}
					_local9 += _local15 + _local29;
					if(_local6 > _local19) {
						_local19 = _local6;
					}
					_local25++;
					_local23++;
				}
				_local7 = _local9 - _local29 + this._paddingRight - _local30;
				if(_local7 > _local13) {
					_local13 = _local7;
				}
			}
			while(_local23 < itemCount);
			
			if(_local18) {
				if(_local28 !== _local28) {
					_local20 = _local13;
					if(_local20 < _local24) {
						_local20 = _local24;
					} else if(_local20 > _local16) {
						_local20 = _local16;
					}
				}
			} else {
				_local20 = _local13;
			}
			var _local4:Number = _local11 + _local19 + this._paddingBottom;
			var _local5:* = _local32;
			if(_local5 !== _local5) {
				_local5 = _local4;
				if(_local5 < _local10) {
					_local5 = _local10;
				} else if(_local5 > _local12) {
					_local5 = _local12;
				}
			}
			result.x = _local20;
			result.y = _local5;
			return result;
		}
		
		public function getNearestScrollPositionForIndex(index:int, scrollX:Number, scrollY:Number, items:Vector.<DisplayObject>, x:Number, y:Number, width:Number, height:Number, result:Point = null) : Point {
			var _local12:Number = NaN;
			var _local13:Number = NaN;
			result = this.calculateMaxScrollYAndRowHeightOfIndex(index,items,x,y,width,height,result);
			var _local10:Number = result.x;
			var _local14:Number = result.y;
			result.x = 0;
			var _local11:Number = _local10 - (height - _local14);
			if(scrollY >= _local11 && scrollY <= _local10) {
				result.y = scrollY;
			} else {
				_local12 = Math.abs(_local10 - scrollY);
				_local13 = Math.abs(_local11 - scrollY);
				if(_local13 < _local12) {
					result.y = _local11;
				} else {
					result.y = _local10;
				}
			}
			return result;
		}
		
		public function getScrollPositionForIndex(index:int, items:Vector.<DisplayObject>, x:Number, y:Number, width:Number, height:Number, result:Point = null) : Point {
			var _local9:Number = NaN;
			result = this.calculateMaxScrollYAndRowHeightOfIndex(index,items,x,y,width,height,result);
			var _local8:Number = result.x;
			var _local10:Number = result.y;
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
			result.y = _local8 - Math.round((height - _local9) / 2);
			return result;
		}
		
		public function resetVariableVirtualCache() : void {
			this._widthCache.length = 0;
			this._heightCache.length = 0;
		}
		
		public function resetVariableVirtualCacheAtIndex(index:int, item:DisplayObject = null) : void {
			delete this._widthCache[index];
			delete this._heightCache[index];
			if(item) {
				this._widthCache[index] = item.width;
				this._heightCache[index] = item.height;
				this.dispatchEventWith("change");
			}
		}
		
		public function addToVariableVirtualCacheAtIndex(index:int, item:DisplayObject = null) : void {
			var _local3:* = !!item ? item.width : undefined;
			var _local4:* = !!item ? item.height : undefined;
			this._widthCache.insertAt(index,_local3);
			this._heightCache.insertAt(index,_local4);
		}
		
		public function removeFromVariableVirtualCacheAtIndex(index:int) : void {
			this._widthCache.removeAt(index);
			this._heightCache.removeAt(index);
		}
		
		public function getVisibleIndicesAtScrollPosition(scrollX:Number, scrollY:Number, width:Number, height:Number, itemCount:int, result:Vector.<int> = null) : Vector.<int> {
			var _local18:Number = NaN;
			var _local16:int = 0;
			var _local21:Number = NaN;
			var _local19:Number = NaN;
			var _local22:Number = NaN;
			var _local23:* = NaN;
			var _local12:* = NaN;
			if(result) {
				result.length = 0;
			} else {
				result = new Vector.<int>(0);
			}
			if(!this._useVirtualLayout) {
				throw new IllegalOperationError("getVisibleIndicesAtScrollPosition() may be called only if useVirtualLayout is true.");
			}
			if(this._typicalItem is IValidating) {
				IValidating(this._typicalItem).validate();
			}
			var _local17:Number = !!this._typicalItem ? this._typicalItem.width : 0;
			var _local11:Number = !!this._typicalItem ? this._typicalItem.height : 0;
			var _local8:int = 0;
			var _local14:int = 0;
			var _local20:Number = this._paddingTop;
			var _local9:* = 0;
			var _local15:Number = this._verticalGap;
			var _local10:Number = scrollY + height;
			var _local13:* = this._firstHorizontalGap === this._firstHorizontalGap;
			var _local24:* = this._lastHorizontalGap === this._lastHorizontalGap;
			var _local7:int = itemCount - 2;
			do {
				if(_local14 > 0) {
					_local20 += _local9 + _local15;
					if(_local20 >= _local10) {
						break;
					}
				}
				_local9 = _local11;
				_local18 = this._paddingLeft;
				_local16 = 0;
				while(_local14 < itemCount) {
					_local21 = this._horizontalGap;
					if(_local13 && _local14 === 0) {
						_local21 = this._firstHorizontalGap;
					} else if(_local24 && _local14 > 0 && _local14 == _local7) {
						_local21 = this._lastHorizontalGap;
					}
					if(this._hasVariableItemDimensions) {
						_local19 = Number(this._widthCache[_local14]);
						_local22 = Number(this._heightCache[_local14]);
					}
					if(this._hasVariableItemDimensions) {
						if(_local19 !== _local19) {
							_local23 = _local17;
						} else {
							_local23 = _local19;
						}
						if(_local22 !== _local22) {
							_local12 = _local11;
						} else {
							_local12 = _local22;
						}
					} else {
						_local23 = _local17;
						_local12 = _local11;
					}
					if(_local16 > 0 && _local18 + _local23 > width - this._paddingRight) {
						break;
					}
					if(_local20 + _local12 > scrollY) {
						result[_local8] = _local14;
						_local8++;
					}
					_local18 += _local23 + _local21;
					if(_local12 > _local9) {
						_local9 = _local12;
					}
					_local16++;
					_local14++;
				}
			}
			while(_local14 < itemCount);
			
			return result;
		}
		
		protected function calculateMaxScrollYAndRowHeightOfIndex(index:int, items:Vector.<DisplayObject>, x:Number, y:Number, width:Number, height:Number, result:Point = null) : Point {
			var _local15:Number = NaN;
			var _local10:Number = NaN;
			var _local17:Number = NaN;
			var _local14:int = 0;
			var _local9:DisplayObject = null;
			var _local18:Number = NaN;
			var _local22:Number = NaN;
			var _local23:* = NaN;
			var _local11:* = NaN;
			if(!result) {
				result = new Point();
			}
			if(this._useVirtualLayout) {
				if(this._typicalItem is IValidating) {
					IValidating(this._typicalItem).validate();
				}
				_local15 = !!this._typicalItem ? this._typicalItem.width : 0;
				_local10 = !!this._typicalItem ? this._typicalItem.height : 0;
			}
			var _local20:Number = this._horizontalGap;
			var _local13:Number = this._verticalGap;
			var _local8:* = 0;
			var _local19:Number = y + this._paddingTop;
			var _local12:int = 0;
			var _local16:int = int(items.length);
			var _local21:Boolean = false;
			while(!_local21) {
				if(_local12 > 0) {
					_local19 += _local8 + _local13;
				}
				_local8 = this._useVirtualLayout ? _local10 : 0;
				_local17 = x + this._paddingLeft;
				_local14 = 0;
				for(; _local12 < _local16; _local12++) {
					_local9 = items[_local12];
					if(this._useVirtualLayout && this._hasVariableItemDimensions) {
						_local18 = Number(this._widthCache[_local12]);
						_local22 = Number(this._heightCache[_local12]);
					}
					if(this._useVirtualLayout && !_local9) {
						if(this._hasVariableItemDimensions) {
							if(_local18 !== _local18) {
								_local23 = _local15;
							} else {
								_local23 = _local18;
							}
							if(_local22 !== _local22) {
								_local11 = _local10;
							} else {
								_local11 = _local22;
							}
						} else {
							_local23 = _local15;
							_local11 = _local10;
						}
					} else {
						if(_local9 is ILayoutDisplayObject && !ILayoutDisplayObject(_local9).includeInLayout) {
							continue;
						}
						if(_local9 is IValidating) {
							IValidating(_local9).validate();
						}
						_local23 = _local9.width;
						_local11 = _local9.height;
						if(this._useVirtualLayout && this._hasVariableItemDimensions) {
							if(this._hasVariableItemDimensions) {
								if(_local23 != _local18) {
									this._widthCache[_local12] = _local23;
									this.dispatchEventWith("change");
								}
								if(_local11 != _local22) {
									this._heightCache[_local12] = _local11;
									this.dispatchEventWith("change");
								}
							} else {
								if(_local15 >= 0) {
									_local23 = _local15;
								}
								if(_local10 >= 0) {
									_local11 = _local10;
								}
							}
						}
					}
					if(_local14 > 0 && _local17 + _local23 > width - this._paddingRight) {
						break;
					}
					if(_local12 === index) {
						_local21 = true;
					}
					if(_local11 > _local8) {
						_local8 = _local11;
					}
					_local17 += _local23 + _local20;
					_local14++;
				}
				if(_local12 >= _local16) {
					break;
				}
			}
			result.setTo(_local19,_local8);
			return result;
		}
	}
}

