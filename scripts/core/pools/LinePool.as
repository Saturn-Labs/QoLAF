package core.pools {
	import core.hud.components.Line;
	import core.scene.Game;
	
	public class LinePool {
		private var inactiveLines:Vector.<Line>;
		
		private var activeLines:Vector.<Line>;
		
		private var g:Game;
		
		public function LinePool(g:Game) {
			var _local2:int = 0;
			var _local3:Line = null;
			inactiveLines = new Vector.<Line>();
			activeLines = new Vector.<Line>();
			super();
			this.g = g;
			_local2 = 0;
			while(_local2 < 4) {
				_local3 = new Line();
				inactiveLines.push(_local3);
				_local2++;
			}
		}
		
		public function getLine() : Line {
			var _local1:Line = null;
			if(inactiveLines.length > 0) {
				_local1 = inactiveLines.pop();
			} else {
				_local1 = new Line();
			}
			activeLines.push(_local1);
			return _local1;
		}
		
		public function removeLine(bl:Line) : void {
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

