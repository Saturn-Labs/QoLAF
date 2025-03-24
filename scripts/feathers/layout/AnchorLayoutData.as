package feathers.layout {
	import starling.display.DisplayObject;
	import starling.events.EventDispatcher;
	
	public class AnchorLayoutData extends EventDispatcher implements ILayoutData {
		protected var _percentWidth:Number = NaN;
		
		protected var _percentHeight:Number = NaN;
		
		protected var _topAnchorDisplayObject:DisplayObject;
		
		protected var _top:Number = NaN;
		
		protected var _rightAnchorDisplayObject:DisplayObject;
		
		protected var _right:Number = NaN;
		
		protected var _bottomAnchorDisplayObject:DisplayObject;
		
		protected var _bottom:Number = NaN;
		
		protected var _leftAnchorDisplayObject:DisplayObject;
		
		protected var _left:Number = NaN;
		
		protected var _horizontalCenterAnchorDisplayObject:DisplayObject;
		
		protected var _horizontalCenter:Number = NaN;
		
		protected var _verticalCenterAnchorDisplayObject:DisplayObject;
		
		protected var _verticalCenter:Number = NaN;
		
		public function AnchorLayoutData(top:Number = NaN, right:Number = NaN, bottom:Number = NaN, left:Number = NaN, horizontalCenter:Number = NaN, verticalCenter:Number = NaN) {
			super();
			this.top = top;
			this.right = right;
			this.bottom = bottom;
			this.left = left;
			this.horizontalCenter = horizontalCenter;
			this.verticalCenter = verticalCenter;
		}
		
		public function get percentWidth() : Number {
			return this._percentWidth;
		}
		
		public function set percentWidth(value:Number) : void {
			if(this._percentWidth == value) {
				return;
			}
			this._percentWidth = value;
			this.dispatchEventWith("change");
		}
		
		public function get percentHeight() : Number {
			return this._percentHeight;
		}
		
		public function set percentHeight(value:Number) : void {
			if(this._percentHeight == value) {
				return;
			}
			this._percentHeight = value;
			this.dispatchEventWith("change");
		}
		
		public function get topAnchorDisplayObject() : DisplayObject {
			return this._topAnchorDisplayObject;
		}
		
		public function set topAnchorDisplayObject(value:DisplayObject) : void {
			if(this._topAnchorDisplayObject == value) {
				return;
			}
			this._topAnchorDisplayObject = value;
			this.dispatchEventWith("change");
		}
		
		public function get top() : Number {
			return this._top;
		}
		
		public function set top(value:Number) : void {
			if(this._top == value) {
				return;
			}
			this._top = value;
			this.dispatchEventWith("change");
		}
		
		public function get rightAnchorDisplayObject() : DisplayObject {
			return this._rightAnchorDisplayObject;
		}
		
		public function set rightAnchorDisplayObject(value:DisplayObject) : void {
			if(this._rightAnchorDisplayObject == value) {
				return;
			}
			this._rightAnchorDisplayObject = value;
			this.dispatchEventWith("change");
		}
		
		public function get right() : Number {
			return this._right;
		}
		
		public function set right(value:Number) : void {
			if(this._right == value) {
				return;
			}
			this._right = value;
			this.dispatchEventWith("change");
		}
		
		public function get bottomAnchorDisplayObject() : DisplayObject {
			return this._bottomAnchorDisplayObject;
		}
		
		public function set bottomAnchorDisplayObject(value:DisplayObject) : void {
			if(this._bottomAnchorDisplayObject == value) {
				return;
			}
			this._bottomAnchorDisplayObject = value;
			this.dispatchEventWith("change");
		}
		
		public function get bottom() : Number {
			return this._bottom;
		}
		
		public function set bottom(value:Number) : void {
			if(this._bottom == value) {
				return;
			}
			this._bottom = value;
			this.dispatchEventWith("change");
		}
		
		public function get leftAnchorDisplayObject() : DisplayObject {
			return this._leftAnchorDisplayObject;
		}
		
		public function set leftAnchorDisplayObject(value:DisplayObject) : void {
			if(this._leftAnchorDisplayObject == value) {
				return;
			}
			this._leftAnchorDisplayObject = value;
			this.dispatchEventWith("change");
		}
		
		public function get left() : Number {
			return this._left;
		}
		
		public function set left(value:Number) : void {
			if(this._left == value) {
				return;
			}
			this._left = value;
			this.dispatchEventWith("change");
		}
		
		public function get horizontalCenterAnchorDisplayObject() : DisplayObject {
			return this._horizontalCenterAnchorDisplayObject;
		}
		
		public function set horizontalCenterAnchorDisplayObject(value:DisplayObject) : void {
			if(this._horizontalCenterAnchorDisplayObject == value) {
				return;
			}
			this._horizontalCenterAnchorDisplayObject = value;
			this.dispatchEventWith("change");
		}
		
		public function get horizontalCenter() : Number {
			return this._horizontalCenter;
		}
		
		public function set horizontalCenter(value:Number) : void {
			if(this._horizontalCenter == value) {
				return;
			}
			this._horizontalCenter = value;
			this.dispatchEventWith("change");
		}
		
		public function get verticalCenterAnchorDisplayObject() : DisplayObject {
			return this._verticalCenterAnchorDisplayObject;
		}
		
		public function set verticalCenterAnchorDisplayObject(value:DisplayObject) : void {
			if(this._verticalCenterAnchorDisplayObject == value) {
				return;
			}
			this._verticalCenterAnchorDisplayObject = value;
			this.dispatchEventWith("change");
		}
		
		public function get verticalCenter() : Number {
			return this._verticalCenter;
		}
		
		public function set verticalCenter(value:Number) : void {
			if(this._verticalCenter == value) {
				return;
			}
			this._verticalCenter = value;
			this.dispatchEventWith("change");
		}
	}
}

