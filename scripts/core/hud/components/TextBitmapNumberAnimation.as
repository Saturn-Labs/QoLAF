package core.hud.components {
	import com.greensock.TweenMax;
	
	public class TextBitmapNumberAnimation extends TextBitmap {
		private var current:int;
		
		private var from:int;
		
		private var to:int;
		
		private var increase:int;
		
		private var delay:Number;
		
		private var id:int = Math.random() * 100;
		
		private var callback:Function;
		
		public function TextBitmapNumberAnimation(x:int = 0, y:int = 0, text:String = "", fontSize:int = 13) {
			super(x,y,text,fontSize);
		}
		
		public function animate(from:int, to:int, timeMillies:int, callback:Function = null) : void {
			this.callback = callback;
			this.from = from;
			this.to = to;
			var _local5:int = to - from;
			var _local6:int = Math.ceil(timeMillies / 50);
			increase = _local5 / _local6;
			if(increase == 0) {
				increase = 1;
			}
			delay = timeMillies / _local6 / 1000;
			current = from;
			next();
		}
		
		private function next() : void {
			var _local1:Boolean = false;
			current += increase;
			if(current >= to) {
				current = to;
				_local1 = true;
			}
			text = "" + current;
			if(_local1) {
				if(Boolean(callback)) {
					callback();
				}
				return;
			}
			TweenMax.delayedCall(delay,next);
		}
	}
}

