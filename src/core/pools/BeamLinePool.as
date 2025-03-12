package core.pools
{
	import core.hud.components.BeamLine;
	import core.scene.Game;
	
	public class BeamLinePool
	{
		private var inactiveLines:Vector.<BeamLine>;
		
		private var activeLines:Vector.<BeamLine>;
		
		private var g:Game;
		
		public function BeamLinePool(param1:Game)
		{
			var _loc3_:int = 0;
			var _loc2_:BeamLine = null;
			inactiveLines = new Vector.<BeamLine>();
			activeLines = new Vector.<BeamLine>();
			super();
			this.g = param1;
			_loc3_ = 0;
			while (_loc3_ < 4)
			{
				_loc2_ = new BeamLine(param1);
				inactiveLines.push(_loc2_);
				_loc3_++;
			}
		}
		
		public function getLine():BeamLine
		{
			var _loc1_:BeamLine = null;
			if (inactiveLines.length > 0)
			{
				_loc1_ = inactiveLines.pop();
			}
			else
			{
				_loc1_ = new BeamLine(g);
			}
			activeLines.push(_loc1_);
			return _loc1_;
		}
		
		public function removeLine(param1:BeamLine):void
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
