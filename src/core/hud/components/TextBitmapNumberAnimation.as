package core.hud.components
{
	import com.greensock.TweenMax;
	
	public class TextBitmapNumberAnimation extends TextBitmap
	{
		private var current:int;
		
		private var from:int;
		
		private var to:int;
		
		private var increase:int;
		
		private var delay:Number;
		
		private var id:int;
		
		private var callback:Function;
		
		public function TextBitmapNumberAnimation(param1:int = 0, param2:int = 0, param3:String = "", param4:int = 13)
		{
			id = Math.random() * 100;
			super(param1, param2, param3, param4);
		}
		
		public function animate(param1:int, param2:int, param3:int, param4:Function = null):void
		{
			this.callback = param4;
			this.from = param1;
			this.to = param2;
			var _loc5_:int = param2 - param1;
			var _loc6_:int = Math.ceil(param3 / 50);
			increase = _loc5_ / _loc6_;
			if (increase == 0)
			{
				increase = 1;
			}
			delay = param3 / _loc6_ / 1000;
			current = param1;
			next();
		}
		
		private function next():void
		{
			var _loc1_:Boolean = false;
			current += increase;
			if (current >= to)
			{
				current = to;
				_loc1_ = true;
			}
			text = "" + current;
			if (_loc1_)
			{
				if (Boolean(callback))
				{
					callback();
				}
				return;
			}
			TweenMax.delayedCall(delay, next);
		}
	}
}
