package feathers.layout {
	import starling.events.EventDispatcher;
	
	public class VerticalLayoutData extends EventDispatcher implements ILayoutData {
		protected var _percentWidth:Number;
		
		protected var _percentHeight:Number;
		
		public function VerticalLayoutData(percentWidth:Number = NaN, percentHeight:Number = NaN) {
			super();
			this._percentWidth = percentWidth;
			this._percentHeight = percentHeight;
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
	}
}

