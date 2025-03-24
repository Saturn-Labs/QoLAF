package feathers.controls {
	import feathers.core.FeathersControl;
	import feathers.core.IValidating;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.ILayout;
	import feathers.layout.IVirtualLayout;
	import feathers.layout.LayoutBoundsResult;
	import feathers.layout.VerticalLayout;
	import feathers.layout.ViewPortBounds;
	import feathers.skins.IStyleProvider;
	import flash.geom.Point;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	public class PageIndicator extends FeathersControl {
		public static const DIRECTION_VERTICAL:String = "vertical";
		
		public static const DIRECTION_HORIZONTAL:String = "horizontal";
		
		public static const VERTICAL_ALIGN_TOP:String = "top";
		
		public static const VERTICAL_ALIGN_MIDDLE:String = "middle";
		
		public static const VERTICAL_ALIGN_BOTTOM:String = "bottom";
		
		public static const HORIZONTAL_ALIGN_LEFT:String = "left";
		
		public static const HORIZONTAL_ALIGN_CENTER:String = "center";
		
		public static const HORIZONTAL_ALIGN_RIGHT:String = "right";
		
		public static const INTERACTION_MODE_PREVIOUS_NEXT:String = "previousNext";
		
		public static const INTERACTION_MODE_PRECISE:String = "precise";
		
		public static var globalStyleProvider:IStyleProvider;
		
		private static const LAYOUT_RESULT:LayoutBoundsResult = new LayoutBoundsResult();
		
		private static const SUGGESTED_BOUNDS:ViewPortBounds = new ViewPortBounds();
		
		private static const HELPER_POINT:Point = new Point();
		
		protected var selectedSymbol:DisplayObject;
		
		protected var cache:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
		
		protected var unselectedSymbols:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
		
		protected var symbols:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
		
		protected var touchPointID:int = -1;
		
		protected var _pageCount:int = 1;
		
		protected var _selectedIndex:int = 0;
		
		protected var _interactionMode:String = "previousNext";
		
		protected var _layout:ILayout;
		
		protected var _direction:String = "horizontal";
		
		protected var _horizontalAlign:String = "center";
		
		protected var _verticalAlign:String = "middle";
		
		protected var _gap:Number = 0;
		
		protected var _paddingTop:Number = 0;
		
		protected var _paddingRight:Number = 0;
		
		protected var _paddingBottom:Number = 0;
		
		protected var _paddingLeft:Number = 0;
		
		protected var _normalSymbolFactory:Function = defaultNormalSymbolFactory;
		
		protected var _selectedSymbolFactory:Function = defaultSelectedSymbolFactory;
		
		public function PageIndicator() {
			super();
			this.isQuickHitAreaEnabled = true;
			this.addEventListener("touch",touchHandler);
		}
		
		protected static function defaultSelectedSymbolFactory() : Quad {
			return new Quad(25,25,0xffffff);
		}
		
		protected static function defaultNormalSymbolFactory() : Quad {
			return new Quad(25,25,0xcccccc);
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return PageIndicator.globalStyleProvider;
		}
		
		public function get pageCount() : int {
			return this._pageCount;
		}
		
		public function set pageCount(value:int) : void {
			if(this._pageCount == value) {
				return;
			}
			this._pageCount = value;
			this.invalidate("data");
		}
		
		public function get selectedIndex() : int {
			return this._selectedIndex;
		}
		
		public function set selectedIndex(value:int) : void {
			value = Math.max(0,Math.min(value,this._pageCount - 1));
			if(this._selectedIndex == value) {
				return;
			}
			this._selectedIndex = value;
			this.invalidate("selected");
			this.dispatchEventWith("change");
		}
		
		public function get interactionMode() : String {
			return this._interactionMode;
		}
		
		public function set interactionMode(value:String) : void {
			this._interactionMode = value;
		}
		
		public function get direction() : String {
			return this._direction;
		}
		
		public function set direction(value:String) : void {
			if(this._direction == value) {
				return;
			}
			this._direction = value;
			this.invalidate("layout");
		}
		
		public function get horizontalAlign() : String {
			return this._horizontalAlign;
		}
		
		public function set horizontalAlign(value:String) : void {
			if(this._horizontalAlign == value) {
				return;
			}
			this._horizontalAlign = value;
			this.invalidate("layout");
		}
		
		public function get verticalAlign() : String {
			return this._verticalAlign;
		}
		
		public function set verticalAlign(value:String) : void {
			if(this._verticalAlign == value) {
				return;
			}
			this._verticalAlign = value;
			this.invalidate("layout");
		}
		
		public function get gap() : Number {
			return this._gap;
		}
		
		public function set gap(value:Number) : void {
			if(this._gap == value) {
				return;
			}
			this._gap = value;
			this.invalidate("layout");
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
		
		public function get normalSymbolFactory() : Function {
			return this._normalSymbolFactory;
		}
		
		public function set normalSymbolFactory(value:Function) : void {
			if(this._normalSymbolFactory == value) {
				return;
			}
			this._normalSymbolFactory = value;
			this.invalidate("styles");
		}
		
		public function get selectedSymbolFactory() : Function {
			return this._selectedSymbolFactory;
		}
		
		public function set selectedSymbolFactory(value:Function) : void {
			if(this._selectedSymbolFactory == value) {
				return;
			}
			this._selectedSymbolFactory = value;
			this.invalidate("styles");
		}
		
		override protected function draw() : void {
			var _local3:Boolean = this.isInvalid("data");
			var _local2:Boolean = this.isInvalid("selected");
			var _local4:Boolean = this.isInvalid("styles");
			var _local1:Boolean = this.isInvalid("layout");
			if(_local3 || _local2 || _local4) {
				this.refreshSymbols(_local4);
			}
			this.layoutSymbols(_local1);
		}
		
		protected function refreshSymbols(symbolsInvalid:Boolean) : void {
			var _local5:int = 0;
			var _local4:int = 0;
			var _local2:DisplayObject = null;
			this.symbols.length = 0;
			var _local3:Vector.<DisplayObject> = this.cache;
			if(symbolsInvalid) {
				_local5 = int(this.unselectedSymbols.length);
				_local4 = 0;
				while(_local4 < _local5) {
					_local2 = this.unselectedSymbols.shift();
					this.removeChild(_local2,true);
					_local4++;
				}
				if(this.selectedSymbol) {
					this.removeChild(this.selectedSymbol,true);
					this.selectedSymbol = null;
				}
			}
			this.cache = this.unselectedSymbols;
			this.unselectedSymbols = _local3;
			_local4 = 0;
			while(_local4 < this._pageCount) {
				if(_local4 == this._selectedIndex) {
					if(!this.selectedSymbol) {
						this.selectedSymbol = this._selectedSymbolFactory();
						this.addChild(this.selectedSymbol);
					}
					this.symbols.push(this.selectedSymbol);
					if(this.selectedSymbol is IValidating) {
						IValidating(this.selectedSymbol).validate();
					}
				} else {
					if(this.cache.length > 0) {
						_local2 = this.cache.shift();
					} else {
						_local2 = this._normalSymbolFactory();
						this.addChild(_local2);
					}
					this.unselectedSymbols.push(_local2);
					this.symbols.push(_local2);
					if(_local2 is IValidating) {
						IValidating(_local2).validate();
					}
				}
				_local4++;
			}
			_local5 = int(this.cache.length);
			_local4 = 0;
			while(_local4 < _local5) {
				_local2 = this.cache.shift();
				this.removeChild(_local2,true);
				_local4++;
			}
		}
		
		protected function layoutSymbols(layoutInvalid:Boolean) : void {
			var _local2:VerticalLayout = null;
			var _local3:HorizontalLayout = null;
			if(layoutInvalid) {
				if(this._direction == "vertical" && !(this._layout is VerticalLayout)) {
					this._layout = new VerticalLayout();
					IVirtualLayout(this._layout).useVirtualLayout = false;
				} else if(this._direction != "vertical" && !(this._layout is HorizontalLayout)) {
					this._layout = new HorizontalLayout();
					IVirtualLayout(this._layout).useVirtualLayout = false;
				}
				if(this._layout is VerticalLayout) {
					_local2 = VerticalLayout(this._layout);
					_local2.paddingTop = this._paddingTop;
					_local2.paddingRight = this._paddingRight;
					_local2.paddingBottom = this._paddingBottom;
					_local2.paddingLeft = this._paddingLeft;
					_local2.gap = this._gap;
					_local2.horizontalAlign = this._horizontalAlign;
					_local2.verticalAlign = this._verticalAlign;
				}
				if(this._layout is HorizontalLayout) {
					_local3 = HorizontalLayout(this._layout);
					_local3.paddingTop = this._paddingTop;
					_local3.paddingRight = this._paddingRight;
					_local3.paddingBottom = this._paddingBottom;
					_local3.paddingLeft = this._paddingLeft;
					_local3.gap = this._gap;
					_local3.horizontalAlign = this._horizontalAlign;
					_local3.verticalAlign = this._verticalAlign;
				}
			}
			SUGGESTED_BOUNDS.x = SUGGESTED_BOUNDS.y = 0;
			SUGGESTED_BOUNDS.scrollX = SUGGESTED_BOUNDS.scrollY = 0;
			SUGGESTED_BOUNDS.explicitWidth = this._explicitWidth;
			SUGGESTED_BOUNDS.explicitHeight = this._explicitHeight;
			SUGGESTED_BOUNDS.maxWidth = this._explicitMaxWidth;
			SUGGESTED_BOUNDS.maxHeight = this._explicitMaxHeight;
			SUGGESTED_BOUNDS.minWidth = this._explicitMinWidth;
			SUGGESTED_BOUNDS.minHeight = this._explicitMinHeight;
			this._layout.layout(this.symbols,SUGGESTED_BOUNDS,LAYOUT_RESULT);
			this.saveMeasurements(LAYOUT_RESULT.contentWidth,LAYOUT_RESULT.contentHeight,LAYOUT_RESULT.contentWidth,LAYOUT_RESULT.contentHeight);
		}
		
		protected function touchHandler(event:TouchEvent) : void {
			var _local4:Touch = null;
			var _local3:Boolean = false;
			var _local7:int = 0;
			var _local2:Number = NaN;
			var _local5:* = 0;
			var _local6:Number = NaN;
			if(!this._isEnabled || this._pageCount < 2) {
				this.touchPointID = -1;
				return;
			}
			if(this.touchPointID >= 0) {
				_local4 = event.getTouch(this,"ended",this.touchPointID);
				if(!_local4) {
					return;
				}
				this.touchPointID = -1;
				_local4.getLocation(this.stage,HELPER_POINT);
				_local3 = this.contains(this.stage.hitTest(HELPER_POINT));
				if(_local3) {
					_local7 = this._pageCount - 1;
					this.globalToLocal(HELPER_POINT,HELPER_POINT);
					if(this._direction == "vertical") {
						if(this._interactionMode === "precise") {
							_local2 = this.selectedSymbol.height + (this.unselectedSymbols[0].height + this._gap) * _local7;
							_local5 = Math.round(_local7 * (HELPER_POINT.y - this.symbols[0].y) / _local2);
							if(_local5 < 0) {
								_local5 = 0;
							} else if(_local5 > _local7) {
								_local5 = _local7;
							}
							this.selectedIndex = _local5;
						} else {
							if(HELPER_POINT.y < this.selectedSymbol.y) {
								this.selectedIndex = Math.max(0,this._selectedIndex - 1);
							}
							if(HELPER_POINT.y > this.selectedSymbol.y + this.selectedSymbol.height) {
								this.selectedIndex = Math.min(_local7,this._selectedIndex + 1);
							}
						}
					} else if(this._interactionMode === "precise") {
						_local6 = this.selectedSymbol.width + (this.unselectedSymbols[0].width + this._gap) * _local7;
						_local5 = Math.round(_local7 * (HELPER_POINT.x - this.symbols[0].x) / _local6);
						if(_local5 < 0) {
							_local5 = 0;
						} else if(_local5 >= this._pageCount) {
							_local5 = _local7;
						}
						this.selectedIndex = _local5;
					} else {
						if(HELPER_POINT.x < this.selectedSymbol.x) {
							this.selectedIndex = Math.max(0,this._selectedIndex - 1);
						}
						if(HELPER_POINT.x > this.selectedSymbol.x + this.selectedSymbol.width) {
							this.selectedIndex = Math.min(_local7,this._selectedIndex + 1);
						}
					}
				}
			} else {
				_local4 = event.getTouch(this,"began");
				if(!_local4) {
					return;
				}
				this.touchPointID = _local4.id;
			}
		}
	}
}

