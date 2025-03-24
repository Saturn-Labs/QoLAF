package feathers.controls {
	import feathers.core.IValidating;
	import feathers.data.ListCollection;
	import feathers.layout.ILayout;
	import feathers.layout.ISpinnerLayout;
	import feathers.layout.VerticalSpinnerLayout;
	import feathers.skins.IStyleProvider;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	
	public class SpinnerList extends List {
		public static var globalStyleProvider:IStyleProvider;
		
		protected var _selectionOverlaySkin:DisplayObject;
		
		public function SpinnerList() {
			super();
			this._scrollBarDisplayMode = "none";
			this._snapToPages = true;
			this._snapOnComplete = true;
			this.decelerationRate = 0.99;
			this.addEventListener("triggered",spinnerList_triggeredHandler);
			this.addEventListener("scrollComplete",spinnerList_scrollCompleteHandler);
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			if(SpinnerList.globalStyleProvider) {
				return SpinnerList.globalStyleProvider;
			}
			return List.globalStyleProvider;
		}
		
		override public function set snapToPages(value:Boolean) : void {
			if(!value) {
				throw new ArgumentError("SpinnerList requires snapToPages to be true.");
			}
			super.snapToPages = value;
		}
		
		override public function set allowMultipleSelection(value:Boolean) : void {
			if(value) {
				throw new ArgumentError("SpinnerList requires allowMultipleSelection to be false.");
			}
			super.allowMultipleSelection = value;
		}
		
		override public function set isSelectable(value:Boolean) : void {
			if(!value) {
				throw new ArgumentError("SpinnerList requires isSelectable to be true.");
			}
			super.snapToPages = value;
		}
		
		override public function set layout(value:ILayout) : void {
			if(value && !(value is ISpinnerLayout)) {
				throw new ArgumentError("SpinnerList requires layouts to implement the ISpinnerLayout interface.");
			}
			super.layout = value;
		}
		
		override public function set selectedIndex(value:int) : void {
			if(value < 0 && this._dataProvider !== null && this._dataProvider.length > 0) {
				return;
			}
			if(this._selectedIndex !== value) {
				this.scrollToDisplayIndex(value,0);
			}
			super.selectedIndex = value;
		}
		
		override public function set selectedItem(value:Object) : void {
			if(this._dataProvider === null) {
				this.selectedIndex = -1;
				return;
			}
			var _local2:int = this._dataProvider.getItemIndex(value);
			if(_local2 < 0) {
				return;
			}
			this.selectedIndex = _local2;
		}
		
		override public function set dataProvider(value:ListCollection) : void {
			if(this._dataProvider == value) {
				return;
			}
			super.dataProvider = value;
			if(!this._dataProvider || this._dataProvider.length == 0) {
				this.selectedIndex = -1;
			} else {
				this.selectedIndex = 0;
			}
		}
		
		public function get selectionOverlaySkin() : DisplayObject {
			return this._selectionOverlaySkin;
		}
		
		public function set selectionOverlaySkin(value:DisplayObject) : void {
			if(this._selectionOverlaySkin == value) {
				return;
			}
			if(this._selectionOverlaySkin && this._selectionOverlaySkin.parent == this) {
				this.removeRawChildInternal(this._selectionOverlaySkin);
			}
			this._selectionOverlaySkin = value;
			if(this._selectionOverlaySkin) {
				this.addRawChildInternal(this._selectionOverlaySkin);
			}
			this.invalidate("styles");
		}
		
		override protected function initialize() : void {
			var _local1:VerticalSpinnerLayout = null;
			if(this._layout == null) {
				if(this._hasElasticEdges && this._verticalScrollPolicy === "auto" && this._scrollBarDisplayMode !== "fixed") {
					this.verticalScrollPolicy = "on";
				}
				_local1 = new VerticalSpinnerLayout();
				_local1.useVirtualLayout = true;
				_local1.padding = 0;
				_local1.gap = 0;
				_local1.horizontalAlign = "justify";
				_local1.requestedRowCount = 4;
				this.layout = _local1;
			}
			super.initialize();
		}
		
		override protected function refreshMinAndMaxScrollPositions() : void {
			super.refreshMinAndMaxScrollPositions();
			if(this._maxVerticalScrollPosition != this._minVerticalScrollPosition) {
				this.actualPageHeight = ISpinnerLayout(this._layout).snapInterval;
			} else if(this._maxHorizontalScrollPosition != this._minHorizontalScrollPosition) {
				this.actualPageWidth = ISpinnerLayout(this._layout).snapInterval;
			}
		}
		
		override protected function handlePendingScroll() : void {
			var _local1:int = 0;
			if(this.pendingItemIndex >= 0) {
				_local1 = this.pendingItemIndex;
				this.pendingItemIndex = -1;
				if(this._maxVerticalPageIndex != this._minVerticalPageIndex) {
					this.pendingVerticalPageIndex = this.calculateNearestPageIndexForItem(_local1,this._verticalPageIndex,this._maxVerticalPageIndex);
					this.hasPendingVerticalPageIndex = this.pendingVerticalPageIndex !== this._verticalPageIndex;
				} else if(this._maxHorizontalPageIndex != this._minHorizontalPageIndex) {
					this.pendingHorizontalPageIndex = this.calculateNearestPageIndexForItem(_local1,this._horizontalPageIndex,this._maxHorizontalPageIndex);
					this.hasPendingHorizontalPageIndex = this.pendingHorizontalPageIndex !== this._horizontalPageIndex;
				}
			}
			super.handlePendingScroll();
		}
		
		override protected function layoutChildren() : void {
			var _local2:Number = NaN;
			var _local1:Number = NaN;
			super.layoutChildren();
			if(this._selectionOverlaySkin) {
				if(this._selectionOverlaySkin is IValidating) {
					IValidating(this._selectionOverlaySkin).validate();
				}
				if(this._maxVerticalPageIndex != this._minVerticalPageIndex) {
					this._selectionOverlaySkin.width = this.actualWidth - this._leftViewPortOffset - this._rightViewPortOffset;
					_local2 = this.actualPageHeight;
					if(_local2 > this.actualHeight) {
						_local2 = this.actualHeight;
					}
					this._selectionOverlaySkin.height = _local2;
					this._selectionOverlaySkin.x = this._leftViewPortOffset;
					this._selectionOverlaySkin.y = Math.round(this._topViewPortOffset + (this.actualHeight - this._topViewPortOffset - this._bottomViewPortOffset - _local2) / 2);
				} else if(this._maxHorizontalPageIndex != this._minHorizontalPageIndex) {
					_local1 = this.actualPageWidth;
					if(_local1 > this.actualWidth) {
						_local1 = this.actualWidth;
					}
					this._selectionOverlaySkin.width = _local1;
					this._selectionOverlaySkin.height = this.actualHeight - this._topViewPortOffset - this._bottomViewPortOffset;
					this._selectionOverlaySkin.x = Math.round(this._leftViewPortOffset + (this.actualWidth - this._leftViewPortOffset - this._rightViewPortOffset - _local1) / 2);
					this._selectionOverlaySkin.y = this._topViewPortOffset;
				}
			}
		}
		
		protected function calculateNearestPageIndexForItem(itemIndex:int, currentPageIndex:int, maxPageIndex:int) : int {
			var _local6:Number = NaN;
			var _local4:Number = NaN;
			if(maxPageIndex != 0x7fffffff) {
				return itemIndex;
			}
			var _local7:int = this._dataProvider.length;
			var _local5:int = currentPageIndex / _local7;
			var _local8:int = currentPageIndex % _local7;
			if(itemIndex < _local8) {
				_local6 = _local5 * _local7 + itemIndex;
				_local4 = (_local5 + 1) * _local7 + itemIndex;
			} else {
				_local6 = (_local5 - 1) * _local7 + itemIndex;
				_local4 = _local5 * _local7 + itemIndex;
			}
			if(_local4 - currentPageIndex < currentPageIndex - _local6) {
				return _local4;
			}
			return _local6;
		}
		
		protected function spinnerList_scrollCompleteHandler(event:Event) : void {
			var _local2:int = 0;
			var _local3:int = this._dataProvider.length;
			if(this._maxVerticalPageIndex != this._minVerticalPageIndex) {
				_local2 = this._verticalPageIndex % _local3;
			} else if(this._maxHorizontalPageIndex != this._minHorizontalPageIndex) {
				_local2 = this._horizontalPageIndex % _local3;
			}
			if(_local2 < 0) {
				_local2 = _local3 + _local2;
			}
			this.selectedIndex = _local2;
		}
		
		protected function spinnerList_triggeredHandler(event:Event, item:Object) : void {
			var _local3:int = this._dataProvider.getItemIndex(item);
			if(this._maxVerticalPageIndex != this._minVerticalPageIndex) {
				_local3 = this.calculateNearestPageIndexForItem(_local3,this._verticalPageIndex,this._maxVerticalPageIndex);
				this.throwToPage(this._horizontalPageIndex,_local3,this._pageThrowDuration);
			} else if(this._maxHorizontalPageIndex != this._minHorizontalPageIndex) {
				_local3 = this.calculateNearestPageIndexForItem(_local3,this._horizontalPageIndex,this._maxHorizontalPageIndex);
				this.throwToPage(_local3,this._verticalPageIndex);
			}
		}
		
		override protected function stage_keyDownHandler(event:KeyboardEvent) : void {
			var _local4:int = 0;
			var _local2:int = 0;
			if(!this._dataProvider) {
				return;
			}
			var _local3:Boolean = false;
			if(event.keyCode == 36) {
				if(this._dataProvider.length > 0) {
					this.selectedIndex = 0;
					_local3 = true;
				}
			} else if(event.keyCode == 35) {
				this.selectedIndex = this._dataProvider.length - 1;
				_local3 = true;
			} else if(event.keyCode == 38) {
				_local4 = this._selectedIndex - 1;
				if(_local4 < 0) {
					_local4 = this._dataProvider.length + _local4;
				}
				this.selectedIndex = _local4;
				_local3 = true;
			} else if(event.keyCode == 40) {
				_local4 = this._selectedIndex + 1;
				if(_local4 >= this._dataProvider.length) {
					_local4 -= this._dataProvider.length;
				}
				this.selectedIndex = _local4;
				_local3 = true;
			}
			if(_local3) {
				if(this._maxVerticalPageIndex != this._minVerticalPageIndex) {
					_local2 = this.calculateNearestPageIndexForItem(this._selectedIndex,this._verticalPageIndex,this._maxVerticalPageIndex);
					this.throwToPage(this._horizontalPageIndex,_local2,this._pageThrowDuration);
				} else if(this._maxHorizontalPageIndex != this._minHorizontalPageIndex) {
					_local2 = this.calculateNearestPageIndexForItem(this._selectedIndex,this._horizontalPageIndex,this._maxHorizontalPageIndex);
					this.throwToPage(_local2,this._verticalPageIndex);
				}
			}
		}
	}
}

