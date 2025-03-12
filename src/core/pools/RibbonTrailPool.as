package core.pools
{
	import core.scene.Game;
	import extensions.RibbonTrail;
	import starling.display.MeshBatch;
	
	public class RibbonTrailPool
	{
		private var meshBatch:MeshBatch;
		
		private var inactiveRibbonTrails:Vector.<RibbonTrail>;
		
		private var activeRibbonTrails:Vector.<RibbonTrail>;
		
		private var g:Game;
		
		public function RibbonTrailPool(param1:Game)
		{
			var _loc3_:int = 0;
			var _loc2_:RibbonTrail = null;
			meshBatch = new MeshBatch();
			inactiveRibbonTrails = new Vector.<RibbonTrail>();
			activeRibbonTrails = new Vector.<RibbonTrail>();
			super();
			this.g = param1;
			_loc3_ = 0;
			while (_loc3_ < 4)
			{
				_loc2_ = new RibbonTrail(param1, 10);
				inactiveRibbonTrails.push(_loc2_);
				_loc3_++;
			}
			meshBatch.blendMode = "add";
			param1.canvasEffects.addChild(meshBatch);
		}
		
		public function getRibbonTrail():RibbonTrail
		{
			var _loc1_:RibbonTrail = null;
			if (inactiveRibbonTrails.length > 0)
			{
				_loc1_ = inactiveRibbonTrails.pop();
			}
			else
			{
				_loc1_ = new RibbonTrail(g, 10);
			}
			activeRibbonTrails.push(_loc1_);
			if (activeRibbonTrails.length > 1000)
			{
				g.client.errorLog.writeError("> 1000 trails in active pool.", "", "", {});
			}
			if (inactiveRibbonTrails.length > 1000)
			{
				g.client.errorLog.writeError("> 1000 trails in inactive pool", "", "", {});
			}
			return _loc1_;
		}
		
		public function update():void
		{
			var _loc3_:int = 0;
			var _loc2_:RibbonTrail = null;
			meshBatch.clear();
			var _loc1_:int = int(activeRibbonTrails.length);
			_loc3_ = 0;
			while (_loc3_ < _loc1_)
			{
				_loc2_ = activeRibbonTrails[_loc3_];
				if (_loc2_.isPlaying)
				{
					meshBatch.addMesh(_loc2_);
				}
				_loc3_++;
			}
		}
		
		public function removeRibbonTrail(param1:RibbonTrail):void
		{
			var _loc2_:int = int(activeRibbonTrails.indexOf(param1));
			if (_loc2_ == -1)
			{
				return;
			}
			activeRibbonTrails.splice(_loc2_, 1);
			inactiveRibbonTrails.push(param1);
		}
		
		public function dispose():void
		{
			for each (var _loc1_:* in inactiveRibbonTrails)
			{
				_loc1_.dispose();
			}
			for each (_loc1_ in activeRibbonTrails)
			{
				_loc1_.dispose();
			}
			activeRibbonTrails = null;
			inactiveRibbonTrails = null;
		}
	}
}
