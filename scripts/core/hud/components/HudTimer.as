package core.hud.components {
	import core.scene.Game;
	import generics.Util;
	import starling.display.Sprite;
	
	public class HudTimer extends Sprite {
		private var time:Text;
		
		private var startTime:Number;
		
		private var finishTime:Number;
		
		private var g:Game;
		
		private var complete:Boolean;
		
		private var running:Boolean = false;
		
		public function HudTimer(g:Game, textSize:int = 11) {
			super();
			this.g = g;
			complete = false;
			time = new Text();
			time.font = "Verdana";
			time.size = textSize;
			time.x = 95;
			time.alignRight();
			time.height = 20;
		}
		
		public function start(start:Number, finish:Number) : void {
			startTime = start;
			finishTime = finish;
			addChild(time);
			complete = false;
			running = true;
		}
		
		public function stop() : void {
			running = false;
		}
		
		public function isComplete() : Boolean {
			return complete;
		}
		
		public function update() : void {
			if(!running) {
				return;
			}
			var _local2:Number = g.time - startTime;
			var _local1:Number = finishTime - startTime;
			var _local3:Number = _local1 - _local2;
			if(_local3 <= 0) {
				_local3 = 0;
				running = false;
				complete = true;
			}
			time.text = Util.getFormattedTime(_local3);
		}
	}
}

