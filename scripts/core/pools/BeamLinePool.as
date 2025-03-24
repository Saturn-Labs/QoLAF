package core.pools {
	import core.hud.components.BeamLine;
	import core.scene.Game;
	
	public class BeamLinePool {
		private var inactiveLines:Vector.<BeamLine>;
		
		private var activeLines:Vector.<BeamLine>;
		
		private var g:Game;
		
		public function BeamLinePool(g:Game) {
			var _local2:int = 0;
			var _local3:BeamLine = null;
			inactiveLines = new Vector.<BeamLine>();
			activeLines = new Vector.<BeamLine>();
			super();
			this.g = g;
			_local2 = 0;
			while(_local2 < 4) {
				_local3 = new BeamLine(g);
				inactiveLines.push(_local3);
				_local2++;
			}
		}
		
		public function getLine() : BeamLine {
			var _local1:BeamLine = null;
			if(inactiveLines.length > 0) {
				_local1 = inactiveLines.pop();
			} else {
				_local1 = new BeamLine(g);
			}
			activeLines.push(_local1);
			return _local1;
		}
		
		public function removeLine(bl:BeamLine) : void {
			var _local2:int = int(activeLines.indexOf(bl));
			if(_local2 == -1) {
				return;
			}
			activeLines.splice(_local2,1);
			inactiveLines.push(bl);
		}
		
		public function dispose() : void {
			for each(var _local1 in inactiveLines) {
				_local1.dispose();
			}
			for each(_local1 in activeLines) {
				_local1.dispose();
			}
			activeLines = null;
			inactiveLines = null;
		}
	}
}

