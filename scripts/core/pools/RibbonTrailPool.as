package core.pools {
	import core.scene.Game;
	import extensions.RibbonTrail;
	import starling.display.MeshBatch;
	
	public class RibbonTrailPool {
		private var meshBatch:MeshBatch;
		
		private var inactiveRibbonTrails:Vector.<RibbonTrail>;
		
		private var activeRibbonTrails:Vector.<RibbonTrail>;
		
		private var g:Game;
		
		public function RibbonTrailPool(g:Game) {
			var _local3:int = 0;
			var _local2:RibbonTrail = null;
			meshBatch = new MeshBatch();
			inactiveRibbonTrails = new Vector.<RibbonTrail>();
			activeRibbonTrails = new Vector.<RibbonTrail>();
			super();
			this.g = g;
			_local3 = 0;
			while(_local3 < 4) {
				_local2 = new RibbonTrail(g,10);
				inactiveRibbonTrails.push(_local2);
				_local3++;
			}
			meshBatch.blendMode = "add";
			g.canvasEffects.addChild(meshBatch);
		}
		
		public function getRibbonTrail() : RibbonTrail {
			var _local1:RibbonTrail = null;
			if(inactiveRibbonTrails.length > 0) {
				_local1 = inactiveRibbonTrails.pop();
			} else {
				_local1 = new RibbonTrail(g,10);
			}
			activeRibbonTrails.push(_local1);
			if(activeRibbonTrails.length > 1000) {
				g.client.errorLog.writeError("> 1000 trails in active pool.","","",{});
			}
			if(inactiveRibbonTrails.length > 1000) {
				g.client.errorLog.writeError("> 1000 trails in inactive pool","","",{});
			}
			return _local1;
		}
		
		public function update() : void {
			var _local2:int = 0;
			var _local1:RibbonTrail = null;
			meshBatch.clear();
			var _local3:int = int(activeRibbonTrails.length);
			_local2 = 0;
			while(_local2 < _local3) {
				_local1 = activeRibbonTrails[_local2];
				if(_local1.isPlaying) {
					meshBatch.addMesh(_local1);
				}
				_local2++;
			}
		}
		
		public function removeRibbonTrail(rt:RibbonTrail) : void {
			var _local2:int = int(activeRibbonTrails.indexOf(rt));
			if(_local2 == -1) {
				return;
			}
			activeRibbonTrails.splice(_local2,1);
			inactiveRibbonTrails.push(rt);
		}
		
		public function dispose() : void {
			for each(var _local1 in inactiveRibbonTrails) {
				_local1.dispose();
			}
			for each(_local1 in activeRibbonTrails) {
				_local1.dispose();
			}
			activeRibbonTrails = null;
			inactiveRibbonTrails = null;
		}
	}
}

