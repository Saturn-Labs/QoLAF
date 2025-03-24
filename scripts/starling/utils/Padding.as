package starling.utils {
	import starling.events.EventDispatcher;
	
	public class Padding extends EventDispatcher {
		private var _left:Number;
		
		private var _right:Number;
		
		private var _top:Number;
		
		private var _bottom:Number;
		
		public function Padding(left:Number = 0, right:Number = 0, top:Number = 0, bottom:Number = 0) {
			super();
			setTo(left,right,top,bottom);
		}
		
		public function setTo(left:Number = 0, right:Number = 0, top:Number = 0, bottom:Number = 0) : void {
			var _local5:Boolean = _left != left || _right != right || _top != top || _bottom != bottom;
			_left = left;
			_right = right;
			_top = top;
			_bottom = bottom;
			if(_local5) {
				dispatchEventWith("change");
			}
		}
		
		public function copyFrom(padding:Padding) : void {
			if(padding == null) {
				setTo(0,0,0,0);
			} else {
				setTo(padding._left,padding._right,padding._top,padding._bottom);
			}
		}
		
		public function clone() : Padding {
			return new Padding(_left,_right,_top,_bottom);
		}
		
		public function get left() : Number {
			return _left;
		}
		
		public function set left(value:Number) : void {
			if(_left != value) {
				_left = value;
				dispatchEventWith("change");
			}
		}
		
		public function get right() : Number {
			return _right;
		}
		
		public function set right(value:Number) : void {
			if(_right != value) {
				_right = value;
				dispatchEventWith("change");
			}
		}
		
		public function get top() : Number {
			return _top;
		}
		
		public function set top(value:Number) : void {
			if(_top != value) {
				_top = value;
				dispatchEventWith("change");
			}
		}
		
		public function get bottom() : Number {
			return _bottom;
		}
		
		public function set bottom(value:Number) : void {
			if(_bottom != value) {
				_bottom = value;
				dispatchEventWith("change");
			}
		}
	}
}

