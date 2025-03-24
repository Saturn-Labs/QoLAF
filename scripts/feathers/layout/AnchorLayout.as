package feathers.layout {
	import feathers.core.IFeathersControl;
	import flash.errors.IllegalOperationError;
	import flash.geom.Point;
	import starling.display.DisplayObject;
	import starling.events.EventDispatcher;
	
	public class AnchorLayout extends EventDispatcher implements ILayout {
		protected static const CIRCULAR_REFERENCE_ERROR:String = "It is impossible to create this layout due to a circular reference in the AnchorLayoutData.";
		
		private static const HELPER_POINT:Point = new Point();
		
		protected var _helperVector1:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
		
		protected var _helperVector2:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
		
		public function AnchorLayout() {
			super();
		}
		
		public function get requiresLayoutOnScroll() : Boolean {
			return false;
		}
		
		public function layout(items:Vector.<DisplayObject>, viewPortBounds:ViewPortBounds = null, result:LayoutBoundsResult = null) : LayoutBoundsResult {
			var _local8:Number = !!viewPortBounds ? viewPortBounds.x : 0;
			var _local9:Number = !!viewPortBounds ? viewPortBounds.y : 0;
			var _local5:Number = !!viewPortBounds ? viewPortBounds.minWidth : 0;
			var _local6:Number = !!viewPortBounds ? viewPortBounds.minHeight : 0;
			var _local15:Number = !!viewPortBounds ? viewPortBounds.maxWidth : Infinity;
			var _local10:Number = !!viewPortBounds ? viewPortBounds.maxHeight : Infinity;
			var _local7:Number = !!viewPortBounds ? viewPortBounds.explicitWidth : NaN;
			var _local13:Number = !!viewPortBounds ? viewPortBounds.explicitHeight : NaN;
			var _local11:* = _local7;
			var _local14:* = _local13;
			var _local4:* = _local7 !== _local7;
			var _local12:* = _local13 !== _local13;
			if(_local4 || _local12) {
				this.validateItems(items,_local7,_local13,_local15,_local10,true);
				this.measureViewPort(items,_local11,_local14,HELPER_POINT);
				if(_local4) {
					_local11 = HELPER_POINT.x;
					if(_local11 < _local5) {
						_local11 = _local5;
					} else if(_local11 > _local15) {
						_local11 = _local15;
					}
				}
				if(_local12) {
					_local14 = HELPER_POINT.y;
					if(_local14 < _local6) {
						_local14 = _local6;
					} else if(_local14 > _local10) {
						_local14 = _local10;
					}
				}
			} else {
				this.validateItems(items,_local7,_local13,_local15,_local10,false);
			}
			this.layoutWithBounds(items,_local8,_local9,_local11,_local14);
			this.measureContent(items,_local11,_local14,HELPER_POINT);
			if(!result) {
				result = new LayoutBoundsResult();
			}
			result.contentWidth = HELPER_POINT.x;
			result.contentHeight = HELPER_POINT.y;
			result.viewPortWidth = _local11;
			result.viewPortHeight = _local14;
			return result;
		}
		
		public function getNearestScrollPositionForIndex(index:int, scrollX:Number, scrollY:Number, items:Vector.<DisplayObject>, x:Number, y:Number, width:Number, height:Number, result:Point = null) : Point {
			return this.getScrollPositionForIndex(index,items,x,y,width,height,result);
		}
		
		public function getScrollPositionForIndex(index:int, items:Vector.<DisplayObject>, x:Number, y:Number, width:Number, height:Number, result:Point = null) : Point {
			if(!result) {
				result = new Point();
			}
			result.x = 0;
			result.y = 0;
			return result;
		}
		
		protected function measureViewPort(items:Vector.<DisplayObject>, viewPortWidth:Number, viewPortHeight:Number, result:Point = null) : Point {
			var _local6:* = NaN;
			this._helperVector1.length = 0;
			this._helperVector2.length = 0;
			HELPER_POINT.x = 0;
			HELPER_POINT.y = 0;
			var _local7:* = items;
			var _local8:Vector.<DisplayObject> = this._helperVector1;
			this.measureVector(items,_local8,HELPER_POINT);
			var _local5:Number = _local8.length;
			while(_local5 > 0) {
				if(_local8 == this._helperVector1) {
					_local7 = this._helperVector1;
					_local8 = this._helperVector2;
				} else {
					_local7 = this._helperVector2;
					_local8 = this._helperVector1;
				}
				this.measureVector(_local7,_local8,HELPER_POINT);
				_local6 = _local5;
				_local5 = _local8.length;
				if(_local6 == _local5) {
					this._helperVector1.length = 0;
					this._helperVector2.length = 0;
					throw new IllegalOperationError("It is impossible to create this layout due to a circular reference in the AnchorLayoutData.");
				}
			}
			this._helperVector1.length = 0;
			this._helperVector2.length = 0;
			if(!result) {
				result = HELPER_POINT.clone();
			}
			return result;
		}
		
		protected function measureVector(items:Vector.<DisplayObject>, unpositionedItems:Vector.<DisplayObject>, result:Point = null) : Point {
			var _local8:int = 0;
			var _local6:DisplayObject = null;
			var _local4:AnchorLayoutData = null;
			var _local7:ILayoutDisplayObject = null;
			var _local5:Boolean = false;
			if(!result) {
				result = new Point();
			}
			unpositionedItems.length = 0;
			var _local10:int = int(items.length);
			var _local9:int = 0;
			_local8 = 0;
			for(; _local8 < _local10; _local8++) {
				_local6 = items[_local8];
				if(_local6 is ILayoutDisplayObject) {
					_local7 = ILayoutDisplayObject(_local6);
					if(!_local7.includeInLayout) {
						continue;
					}
					_local4 = _local7.layoutData as AnchorLayoutData;
				}
				_local5 = !_local4 || this.isReadyForLayout(_local4,_local8,items,unpositionedItems);
				if(!_local5) {
					unpositionedItems[_local9] = _local6;
					_local9++;
				} else {
					this.measureItem(_local6,result);
				}
			}
			return result;
		}
		
		protected function measureItem(item:DisplayObject, result:Point) : void {
			var _local4:ILayoutDisplayObject = null;
			var _local3:AnchorLayoutData = null;
			var _local8:Number = NaN;
			var _local6:* = result.x;
			var _local5:* = result.y;
			var _local7:Boolean = false;
			if(item is ILayoutDisplayObject) {
				_local4 = ILayoutDisplayObject(item);
				_local3 = _local4.layoutData as AnchorLayoutData;
				if(_local3) {
					_local8 = this.measureItemHorizontally(_local4,_local3);
					if(_local8 > _local6) {
						_local6 = _local8;
					}
					_local8 = this.measureItemVertically(_local4,_local3);
					if(_local8 > _local5) {
						_local5 = _local8;
					}
					_local7 = true;
				}
			}
			if(!_local7) {
				_local8 = item.x - item.pivotX + item.width;
				if(_local8 > _local6) {
					_local6 = _local8;
				}
				_local8 = item.y - item.pivotY + item.height;
				if(_local8 > _local5) {
					_local5 = _local8;
				}
			}
			result.x = _local6;
			result.y = _local5;
		}
		
		protected function measureItemHorizontally(item:ILayoutDisplayObject, layoutData:AnchorLayoutData) : Number {
			var _local7:Number = NaN;
			var _local4:Number = Number(item.width);
			if(layoutData && item is IFeathersControl) {
				_local7 = layoutData.percentWidth;
				this.doNothing();
				if(_local7 === _local7) {
					_local4 = Number(IFeathersControl(item).minWidth);
				}
			}
			var _local6:DisplayObject = DisplayObject(item);
			var _local3:Number = this.getLeftOffset(_local6);
			var _local5:Number = this.getRightOffset(_local6);
			return _local4 + _local3 + _local5;
		}
		
		protected function measureItemVertically(item:ILayoutDisplayObject, layoutData:AnchorLayoutData) : Number {
			var _local3:Number = NaN;
			var _local6:Number = Number(item.height);
			if(layoutData && item is IFeathersControl) {
				_local3 = layoutData.percentHeight;
				this.doNothing();
				if(_local3 === _local3) {
					_local6 = Number(IFeathersControl(item).minHeight);
				}
			}
			var _local7:DisplayObject = DisplayObject(item);
			var _local4:Number = this.getTopOffset(_local7);
			var _local5:Number = this.getBottomOffset(_local7);
			return _local6 + _local4 + _local5;
		}
		
		protected function doNothing() : void {
		}
		
		protected function getTopOffset(item:DisplayObject) : Number {
			var _local5:ILayoutDisplayObject = null;
			var _local2:AnchorLayoutData = null;
			var _local12:Number = NaN;
			var _local8:* = false;
			var _local4:DisplayObject = null;
			var _local6:Number = NaN;
			var _local9:* = false;
			var _local10:DisplayObject = null;
			var _local3:Number = NaN;
			var _local13:* = false;
			var _local11:DisplayObject = null;
			var _local7:Number = NaN;
			if(item is ILayoutDisplayObject) {
				_local5 = ILayoutDisplayObject(item);
				_local2 = _local5.layoutData as AnchorLayoutData;
				if(_local2) {
					_local12 = _local2.top;
					_local8 = _local12 === _local12;
					if(_local8) {
						_local4 = _local2.topAnchorDisplayObject;
						if(!_local4) {
							return _local12;
						}
						_local12 += _local4.height + this.getTopOffset(_local4);
					} else {
						_local12 = 0;
					}
					_local6 = _local2.bottom;
					_local9 = _local6 === _local6;
					if(_local9) {
						_local10 = _local2.bottomAnchorDisplayObject;
						if(_local10) {
							_local12 = Math.max(_local12,-_local10.height - _local6 + this.getTopOffset(_local10));
						}
					}
					_local3 = _local2.verticalCenter;
					_local13 = _local3 === _local3;
					if(_local13) {
						_local11 = _local2.verticalCenterAnchorDisplayObject;
						if(_local11) {
							_local7 = _local3 - Math.round((item.height - _local11.height) / 2);
							_local12 = Math.max(_local12,_local7 + this.getTopOffset(_local11));
						} else if(_local3 > 0) {
							return _local3 * 2;
						}
					}
					return _local12;
				}
			}
			return 0;
		}
		
		protected function getRightOffset(item:DisplayObject) : Number {
			var _local3:ILayoutDisplayObject = null;
			var _local2:AnchorLayoutData = null;
			var _local4:Number = NaN;
			var _local6:* = false;
			var _local13:DisplayObject = null;
			var _local9:Number = NaN;
			var _local11:* = false;
			var _local10:DisplayObject = null;
			var _local5:Number = NaN;
			var _local12:* = false;
			var _local8:DisplayObject = null;
			var _local7:Number = NaN;
			if(item is ILayoutDisplayObject) {
				_local3 = ILayoutDisplayObject(item);
				_local2 = _local3.layoutData as AnchorLayoutData;
				if(_local2) {
					_local4 = _local2.right;
					_local6 = _local4 === _local4;
					if(_local6) {
						_local13 = _local2.rightAnchorDisplayObject;
						if(!_local13) {
							return _local4;
						}
						_local4 += _local13.width + this.getRightOffset(_local13);
					} else {
						_local4 = 0;
					}
					_local9 = _local2.left;
					_local11 = _local9 === _local9;
					if(_local11) {
						_local10 = _local2.leftAnchorDisplayObject;
						if(_local10) {
							_local4 = Math.max(_local4,-_local10.width - _local9 + this.getRightOffset(_local10));
						}
					}
					_local5 = _local2.horizontalCenter;
					_local12 = _local5 === _local5;
					if(_local12) {
						_local8 = _local2.horizontalCenterAnchorDisplayObject;
						if(_local8) {
							_local7 = -_local5 - Math.round((item.width - _local8.width) / 2);
							_local4 = Math.max(_local4,_local7 + this.getRightOffset(_local8));
						} else if(_local5 < 0) {
							return -_local5 * 2;
						}
					}
					return _local4;
				}
			}
			return 0;
		}
		
		protected function getBottomOffset(item:DisplayObject) : Number {
			var _local5:ILayoutDisplayObject = null;
			var _local2:AnchorLayoutData = null;
			var _local6:Number = NaN;
			var _local9:* = false;
			var _local10:DisplayObject = null;
			var _local12:Number = NaN;
			var _local8:* = false;
			var _local4:DisplayObject = null;
			var _local3:Number = NaN;
			var _local13:* = false;
			var _local11:DisplayObject = null;
			var _local7:Number = NaN;
			if(item is ILayoutDisplayObject) {
				_local5 = ILayoutDisplayObject(item);
				_local2 = _local5.layoutData as AnchorLayoutData;
				if(_local2) {
					_local6 = _local2.bottom;
					_local9 = _local6 === _local6;
					if(_local9) {
						_local10 = _local2.bottomAnchorDisplayObject;
						if(!_local10) {
							return _local6;
						}
						_local6 += _local10.height + this.getBottomOffset(_local10);
					} else {
						_local6 = 0;
					}
					_local12 = _local2.top;
					_local8 = _local12 === _local12;
					if(_local8) {
						_local4 = _local2.topAnchorDisplayObject;
						if(_local4) {
							_local6 = Math.max(_local6,-_local4.height - _local12 + this.getBottomOffset(_local4));
						}
					}
					_local3 = _local2.verticalCenter;
					_local13 = _local3 === _local3;
					if(_local13) {
						_local11 = _local2.verticalCenterAnchorDisplayObject;
						if(_local11) {
							_local7 = -_local3 - Math.round((item.height - _local11.height) / 2);
							_local6 = Math.max(_local6,_local7 + this.getBottomOffset(_local11));
						} else if(_local3 < 0) {
							return -_local3 * 2;
						}
					}
					return _local6;
				}
			}
			return 0;
		}
		
		protected function getLeftOffset(item:DisplayObject) : Number {
			var _local3:ILayoutDisplayObject = null;
			var _local2:AnchorLayoutData = null;
			var _local9:Number = NaN;
			var _local11:* = false;
			var _local10:DisplayObject = null;
			var _local4:Number = NaN;
			var _local6:* = false;
			var _local13:DisplayObject = null;
			var _local5:Number = NaN;
			var _local12:* = false;
			var _local8:DisplayObject = null;
			var _local7:Number = NaN;
			if(item is ILayoutDisplayObject) {
				_local3 = ILayoutDisplayObject(item);
				_local2 = _local3.layoutData as AnchorLayoutData;
				if(_local2) {
					_local9 = _local2.left;
					_local11 = _local9 === _local9;
					if(_local11) {
						_local10 = _local2.leftAnchorDisplayObject;
						if(!_local10) {
							return _local9;
						}
						_local9 += _local10.width + this.getLeftOffset(_local10);
					} else {
						_local9 = 0;
					}
					_local4 = _local2.right;
					_local6 = _local4 === _local4;
					if(_local6) {
						_local13 = _local2.rightAnchorDisplayObject;
						if(_local13) {
							_local9 = Math.max(_local9,-_local13.width - _local4 + this.getLeftOffset(_local13));
						}
					}
					_local5 = _local2.horizontalCenter;
					_local12 = _local5 === _local5;
					if(_local12) {
						_local8 = _local2.horizontalCenterAnchorDisplayObject;
						if(_local8) {
							_local7 = _local5 - Math.round((item.width - _local8.width) / 2);
							_local9 = Math.max(_local9,_local7 + this.getLeftOffset(_local8));
						} else if(_local5 > 0) {
							return _local5 * 2;
						}
					}
					return _local9;
				}
			}
			return 0;
		}
		
		protected function layoutWithBounds(items:Vector.<DisplayObject>, x:Number, y:Number, width:Number, height:Number) : void {
			var _local7:* = NaN;
			this._helperVector1.length = 0;
			this._helperVector2.length = 0;
			var _local8:* = items;
			var _local9:Vector.<DisplayObject> = this._helperVector1;
			this.layoutVector(items,_local9,x,y,width,height);
			var _local6:Number = _local9.length;
			while(_local6 > 0) {
				if(_local9 == this._helperVector1) {
					_local8 = this._helperVector1;
					_local9 = this._helperVector2;
				} else {
					_local8 = this._helperVector2;
					_local9 = this._helperVector1;
				}
				this.layoutVector(_local8,_local9,x,y,width,height);
				_local7 = _local6;
				_local6 = _local9.length;
				if(_local7 == _local6) {
					this._helperVector1.length = 0;
					this._helperVector2.length = 0;
					throw new IllegalOperationError("It is impossible to create this layout due to a circular reference in the AnchorLayoutData.");
				}
			}
			this._helperVector1.length = 0;
			this._helperVector2.length = 0;
		}
		
		protected function layoutVector(items:Vector.<DisplayObject>, unpositionedItems:Vector.<DisplayObject>, boundsX:Number, boundsY:Number, viewPortWidth:Number, viewPortHeight:Number) : void {
			var _local11:int = 0;
			var _local9:DisplayObject = null;
			var _local10:ILayoutDisplayObject = null;
			var _local7:AnchorLayoutData = null;
			var _local8:Boolean = false;
			unpositionedItems.length = 0;
			var _local13:int = int(items.length);
			var _local12:int = 0;
			_local11 = 0;
			while(_local11 < _local13) {
				_local9 = items[_local11];
				_local10 = _local9 as ILayoutDisplayObject;
				if(!(!_local10 || !_local10.includeInLayout)) {
					_local7 = _local10.layoutData as AnchorLayoutData;
					if(_local7) {
						_local8 = this.isReadyForLayout(_local7,_local11,items,unpositionedItems);
						if(!_local8) {
							unpositionedItems[_local12] = _local9;
							_local12++;
						} else {
							this.positionHorizontally(_local10,_local7,boundsX,boundsY,viewPortWidth,viewPortHeight);
							this.positionVertically(_local10,_local7,boundsX,boundsY,viewPortWidth,viewPortHeight);
						}
					}
				}
				_local11++;
			}
		}
		
		protected function positionHorizontally(item:ILayoutDisplayObject, layoutData:AnchorLayoutData, boundsX:Number, boundsY:Number, viewPortWidth:Number, viewPortHeight:Number) : void {
			var _local19:* = NaN;
			var _local8:Number = NaN;
			var _local23:Number = NaN;
			var _local17:DisplayObject = null;
			var _local21:DisplayObject = null;
			var _local7:* = NaN;
			var _local13:DisplayObject = null;
			var _local22:Number = NaN;
			var _local15:Number = NaN;
			var _local16:IFeathersControl = item as IFeathersControl;
			var _local11:Number = layoutData.percentWidth;
			if(_local11 === _local11) {
				if(_local11 < 0) {
					_local11 = 0;
				} else if(_local11 > 100) {
					_local11 = 100;
				}
				_local19 = _local11 * 0.01 * viewPortWidth;
				if(_local16) {
					_local8 = Number(_local16.minWidth);
					_local23 = Number(_local16.maxWidth);
					if(_local19 < _local8) {
						_local19 = _local8;
					} else if(_local19 > _local23) {
						_local19 = _local23;
					}
				}
				if(_local19 > viewPortWidth) {
					_local19 = viewPortWidth;
				}
				item.width = _local19;
			}
			var _local14:Number = layoutData.left;
			var _local18:* = _local14 === _local14;
			if(_local18) {
				_local17 = layoutData.leftAnchorDisplayObject;
				if(_local17) {
					item.x = item.pivotX + _local17.x - _local17.pivotX + _local17.width + _local14;
				} else {
					item.x = item.pivotX + boundsX + _local14;
				}
			}
			var _local10:Number = layoutData.horizontalCenter;
			var _local20:* = _local10 === _local10;
			var _local9:Number = layoutData.right;
			var _local12:* = _local9 === _local9;
			if(_local12) {
				_local21 = layoutData.rightAnchorDisplayObject;
				if(_local18) {
					_local7 = viewPortWidth;
					if(_local21) {
						_local7 = _local21.x - _local21.pivotX;
					}
					if(_local17) {
						_local7 -= _local17.x - _local17.pivotX + _local17.width;
					}
					item.width = _local7 - _local9 - _local14;
				} else if(_local20) {
					_local13 = layoutData.horizontalCenterAnchorDisplayObject;
					if(_local13) {
						_local22 = _local13.x - _local13.pivotX + Math.round(_local13.width / 2) + _local10;
					} else {
						_local22 = Math.round(viewPortWidth / 2) + _local10;
					}
					if(_local21) {
						_local15 = _local21.x - _local21.pivotX - _local9;
					} else {
						_local15 = viewPortWidth - _local9;
					}
					item.width = 2 * (_local15 - _local22);
					item.x = item.pivotX + viewPortWidth - _local9 - item.width;
				} else if(_local21) {
					item.x = item.pivotX + _local21.x - _local21.pivotX - item.width - _local9;
				} else {
					item.x = item.pivotX + boundsX + viewPortWidth - _local9 - item.width;
				}
			} else if(_local20) {
				_local13 = layoutData.horizontalCenterAnchorDisplayObject;
				if(_local13) {
					_local22 = _local13.x - _local13.pivotX + Math.round(_local13.width / 2) + _local10;
				} else {
					_local22 = Math.round(viewPortWidth / 2) + _local10;
				}
				if(_local18) {
					item.width = 2 * (_local22 - item.x + item.pivotX);
				} else {
					item.x = item.pivotX + _local22 - Math.round(item.width / 2);
				}
			}
		}
		
		protected function positionVertically(item:ILayoutDisplayObject, layoutData:AnchorLayoutData, boundsX:Number, boundsY:Number, viewPortWidth:Number, viewPortHeight:Number) : void {
			var _local10:* = NaN;
			var _local12:Number = NaN;
			var _local19:Number = NaN;
			var _local8:DisplayObject = null;
			var _local14:DisplayObject = null;
			var _local22:* = NaN;
			var _local15:DisplayObject = null;
			var _local16:Number = NaN;
			var _local23:Number = NaN;
			var _local20:IFeathersControl = item as IFeathersControl;
			var _local17:Number = layoutData.percentHeight;
			if(_local17 === _local17) {
				if(_local17 < 0) {
					_local17 = 0;
				} else if(_local17 > 100) {
					_local17 = 100;
				}
				_local10 = _local17 * 0.01 * viewPortHeight;
				if(_local20) {
					_local12 = Number(_local20.minHeight);
					_local19 = Number(_local20.maxHeight);
					if(_local10 < _local12) {
						_local10 = _local12;
					} else if(_local10 > _local19) {
						_local10 = _local19;
					}
				}
				if(_local10 > viewPortHeight) {
					_local10 = viewPortHeight;
				}
				item.height = _local10;
			}
			var _local18:Number = layoutData.top;
			var _local11:* = _local18 === _local18;
			if(_local11) {
				_local8 = layoutData.topAnchorDisplayObject;
				if(_local8) {
					item.y = item.pivotY + _local8.y - _local8.pivotY + _local8.height + _local18;
				} else {
					item.y = item.pivotY + boundsY + _local18;
				}
			}
			var _local7:Number = layoutData.verticalCenter;
			var _local21:* = _local7 === _local7;
			var _local9:Number = layoutData.bottom;
			var _local13:* = _local9 === _local9;
			if(_local13) {
				_local14 = layoutData.bottomAnchorDisplayObject;
				if(_local11) {
					_local22 = viewPortHeight;
					if(_local14) {
						_local22 = _local14.y - _local14.pivotY;
					}
					if(_local8) {
						_local22 -= _local8.y - _local8.pivotY + _local8.height;
					}
					item.height = _local22 - _local9 - _local18;
				} else if(_local21) {
					_local15 = layoutData.verticalCenterAnchorDisplayObject;
					if(_local15) {
						_local16 = _local15.y - _local15.pivotY + Math.round(_local15.height / 2) + _local7;
					} else {
						_local16 = Math.round(viewPortHeight / 2) + _local7;
					}
					if(_local14) {
						_local23 = _local14.y - _local14.pivotY - _local9;
					} else {
						_local23 = viewPortHeight - _local9;
					}
					item.height = 2 * (_local23 - _local16);
					item.y = item.pivotY + viewPortHeight - _local9 - item.height;
				} else if(_local14) {
					item.y = item.pivotY + _local14.y - _local14.pivotY - item.height - _local9;
				} else {
					item.y = item.pivotY + boundsY + viewPortHeight - _local9 - item.height;
				}
			} else if(_local21) {
				_local15 = layoutData.verticalCenterAnchorDisplayObject;
				if(_local15) {
					_local16 = _local15.y - _local15.pivotY + Math.round(_local15.height / 2) + _local7;
				} else {
					_local16 = Math.round(viewPortHeight / 2) + _local7;
				}
				if(_local11) {
					item.height = 2 * (_local16 - item.y + item.pivotY);
				} else {
					item.y = item.pivotY + _local16 - Math.round(item.height / 2);
				}
			}
		}
		
		protected function measureContent(items:Vector.<DisplayObject>, viewPortWidth:Number, viewPortHeight:Number, result:Point = null) : Point {
			var _local9:int = 0;
			var _local5:DisplayObject = null;
			var _local10:Number = NaN;
			var _local6:Number = NaN;
			var _local8:* = viewPortWidth;
			var _local7:* = viewPortHeight;
			var _local11:int = int(items.length);
			_local9 = 0;
			while(_local9 < _local11) {
				_local5 = items[_local9];
				_local10 = _local5.x - _local5.pivotX + _local5.width;
				_local6 = _local5.y - _local5.pivotY + _local5.height;
				if(_local10 === _local10 && _local10 > _local8) {
					_local8 = _local10;
				}
				if(_local6 === _local6 && _local6 > _local7) {
					_local7 = _local6;
				}
				_local9++;
			}
			result.x = _local8;
			result.y = _local7;
			return result;
		}
		
		protected function isReadyForLayout(layoutData:AnchorLayoutData, index:int, items:Vector.<DisplayObject>, unpositionedItems:Vector.<DisplayObject>) : Boolean {
			var _local10:int = index + 1;
			var _local9:DisplayObject = layoutData.leftAnchorDisplayObject;
			if(_local9 && (items.indexOf(_local9,_local10) >= _local10 || unpositionedItems.indexOf(_local9) >= 0)) {
				return false;
			}
			var _local11:DisplayObject = layoutData.rightAnchorDisplayObject;
			if(_local11 && (items.indexOf(_local11,_local10) >= _local10 || unpositionedItems.indexOf(_local11) >= 0)) {
				return false;
			}
			var _local5:DisplayObject = layoutData.topAnchorDisplayObject;
			if(_local5 && (items.indexOf(_local5,_local10) >= _local10 || unpositionedItems.indexOf(_local5) >= 0)) {
				return false;
			}
			var _local6:DisplayObject = layoutData.bottomAnchorDisplayObject;
			if(_local6 && (items.indexOf(_local6,_local10) >= _local10 || unpositionedItems.indexOf(_local6) >= 0)) {
				return false;
			}
			var _local7:DisplayObject = layoutData.horizontalCenterAnchorDisplayObject;
			if(_local7 && (items.indexOf(_local7,_local10) >= _local10 || unpositionedItems.indexOf(_local7) >= 0)) {
				return false;
			}
			var _local8:DisplayObject = layoutData.verticalCenterAnchorDisplayObject;
			if(_local8 && (items.indexOf(_local8,_local10) >= _local10 || unpositionedItems.indexOf(_local8) >= 0)) {
				return false;
			}
			return true;
		}
		
		protected function isReferenced(item:DisplayObject, items:Vector.<DisplayObject>) : Boolean {
			var _local4:int = 0;
			var _local5:ILayoutDisplayObject = null;
			var _local3:AnchorLayoutData = null;
			var _local6:int = int(items.length);
			_local4 = 0;
			while(_local4 < _local6) {
				_local5 = items[_local4] as ILayoutDisplayObject;
				if(!(!_local5 || _local5 == item)) {
					_local3 = _local5.layoutData as AnchorLayoutData;
					if(_local3) {
						if(_local3.leftAnchorDisplayObject == item || _local3.horizontalCenterAnchorDisplayObject == item || _local3.rightAnchorDisplayObject == item || _local3.topAnchorDisplayObject == item || _local3.verticalCenterAnchorDisplayObject == item || _local3.bottomAnchorDisplayObject == item) {
							return true;
						}
					}
				}
				_local4++;
			}
			return false;
		}
		
		protected function validateItems(items:Vector.<DisplayObject>, explicitWidth:Number, explicitHeight:Number, maxWidth:Number, maxHeight:Number, force:Boolean) : void {
			var _local25:int = 0;
			var _local26:IFeathersControl = null;
			var _local15:ILayoutDisplayObject = null;
			var _local20:AnchorLayoutData = null;
			var _local34:Number = NaN;
			var _local35:* = false;
			var _local33:DisplayObject = null;
			var _local27:Number = NaN;
			var _local7:DisplayObject = null;
			var _local10:* = false;
			var _local11:Number = NaN;
			var _local17:* = false;
			var _local9:Number = NaN;
			var _local19:* = false;
			var _local13:Number = NaN;
			var _local24:* = false;
			var _local28:DisplayObject = null;
			var _local23:Number = NaN;
			var _local31:* = false;
			var _local8:DisplayObject = null;
			var _local14:Number = NaN;
			var _local29:* = false;
			var _local21:Number = NaN;
			var _local16:* = false;
			var _local22:* = explicitWidth !== explicitWidth;
			var _local18:* = explicitHeight !== explicitHeight;
			var _local12:* = explicitWidth;
			if(_local22 && maxWidth < Infinity) {
				_local12 = maxWidth;
			}
			var _local32:* = explicitHeight;
			if(_local18 && maxHeight < Infinity) {
				_local32 = maxHeight;
			}
			var _local30:int = int(items.length);
			_local25 = 0;
			for(; _local25 < _local30; _local25++) {
				_local26 = items[_local25] as IFeathersControl;
				if(_local26) {
					if(_local26 is ILayoutDisplayObject) {
						_local15 = ILayoutDisplayObject(_local26);
						if(!_local15.includeInLayout) {
							continue;
						}
						_local20 = _local15.layoutData as AnchorLayoutData;
						if(_local20) {
							_local34 = _local20.left;
							_local35 = _local34 === _local34;
							_local33 = _local20.leftAnchorDisplayObject;
							_local27 = _local20.right;
							_local7 = _local20.rightAnchorDisplayObject;
							_local10 = _local27 === _local27;
							_local11 = _local20.percentWidth;
							_local17 = _local11 === _local11;
							if(!_local22) {
								if(_local35 && _local33 === null && _local10 && _local7 === null) {
									_local26.width = _local12 - _local34 - _local27;
								} else if(_local17) {
									if(_local11 < 0) {
										_local11 = 0;
									} else if(_local11 > 100) {
										_local11 = 100;
									}
									_local26.width = _local11 * 0.01 * _local12;
								}
							}
							_local9 = _local20.horizontalCenter;
							_local19 = _local9 === _local9;
							_local13 = _local20.top;
							_local24 = _local13 === _local13;
							_local28 = _local20.topAnchorDisplayObject;
							_local23 = _local20.bottom;
							_local31 = _local23 === _local23;
							_local8 = _local20.bottomAnchorDisplayObject;
							_local14 = _local20.percentHeight;
							_local29 = _local14 === _local14;
							if(!_local18) {
								if(_local24 && _local28 === null && _local31 && _local8 === null) {
									_local26.height = _local32 - _local13 - _local23;
								} else if(_local29) {
									if(_local14 < 0) {
										_local14 = 0;
									} else if(_local14 > 100) {
										_local14 = 100;
									}
									_local26.height = _local14 * 0.01 * _local32;
								}
							}
							_local21 = _local20.verticalCenter;
							_local16 = _local21 === _local21;
							if(_local10 && !_local35 && !_local19 || _local19) {
								_local26.validate();
								continue;
							}
							if(_local31 && !_local24 && !_local16 || _local16) {
								_local26.validate();
								continue;
							}
						}
					}
					if(force) {
						_local26.validate();
					} else if(this.isReferenced(DisplayObject(_local26),items)) {
						_local26.validate();
					}
				}
			}
		}
	}
}

