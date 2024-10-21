package core.hud.components
{
	import core.scene.Game;
	import generics.Util;
	import starling.display.Sprite;
	
	public class HudTimer extends Sprite
	{
		private var time:Text;
		
		private var startTime:Number;
		
		private var finishTime:Number;
		
		private var g:Game;
		
		private var complete:Boolean;
		
		private var running:Boolean = false;
		
		public function HudTimer(param1:Game, param2:int = 11)
		{
			super();
			this.g = param1;
			complete = false;
			time = new Text();
			time.font = "Verdana";
			time.size = param2;
			time.x = 95;
			time.alignRight();
			time.height = 20;
		}
		
		public function start(param1:Number, param2:Number):void
		{
			startTime = param1;
			finishTime = param2;
			addChild(time);
			complete = false;
			running = true;
		}
		
		public function stop():void
		{
			running = false;
		}
		
		public function isComplete():Boolean
		{
			return complete;
		}
		
		public function update():void
		{
			if (!running)
			{
				return;
			}
			var _loc2_:Number = g.time - startTime;
			var _loc3_:Number = finishTime - startTime;
			var _loc1_:Number = _loc3_ - _loc2_;
			if (_loc1_ <= 0)
			{
				_loc1_ = 0;
				running = false;
				complete = true;
			}
			time.text = Util.getFormattedTime(_loc1_);
		}
	}
}
