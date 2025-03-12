package core.pools
{
	import core.hud.components.Line;
	import core.scene.Game;
	
	public class LinePool
	{
		private var inactiveLines:Vector.<Line>;
		
		private var activeLines:Vector.<Line>;
		
		private var g:Game;
		
		public function LinePool(param1:Game)
		{
			var _loc3_:int = 0;
			var _loc2_:Line = null;
			inactiveLines = new Vector.<Line>();
			activeLines = new Vector.<Line>();
			super();
			this.g = param1;
			_loc3_ = 0;
			while (_loc3_ < 4)
			{
				_loc2_ = new Line();
				inactiveLines.push(_loc2_);
				_loc3_++;
			}
		}
		
		public function getLine():Line
		{
			var _loc1_:Line = null;
			if (inactiveLines.length > 0)
			{
				_loc1_ = inactiveLines.pop();
			}
			else
			{
				_loc1_ = new Line();
			}
			activeLines.push(_loc1_);
			return _loc1_;
		}
		
		public function removeLine(param1:Line):void
		{
			var _loc2_:int = int(activeLines.indexOf(param1));
			if (_loc2_ == -1)
			{
				return;
			}
			activeLines.splice(_loc2_, 1);
			inactiveLines.push(param1);
		}
		
		public function dispose():void
		{
			for each (var _loc1_:* in inactiveLines)
			{
				_loc1_.dispose();
			}
			for each (_loc1_ in activeLines)
			{
				_loc1_.dispose();
			}
			activeLines = null;
			inactiveLines = null;
		}
	}
}
