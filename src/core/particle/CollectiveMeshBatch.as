package core.particle
{
	import starling.display.MeshBatch;
	
	public class CollectiveMeshBatch extends MeshBatch
	{
		private static var effectsBatch:CollectiveMeshBatch;
		
		private static var meshBatches:Vector.<CollectiveMeshBatch> = new Vector.<CollectiveMeshBatch>();
		
		private var hasBeenUpdated:Boolean = false;
		private var emitters:Vector.<Emitter>;
		
		public function CollectiveMeshBatch()
		{
			emitters = new Vector.<Emitter>();
			super();
			batchable = false;
		}
		
		public static function Create(param1:Emitter):CollectiveMeshBatch
		{
			var _loc2_:CollectiveMeshBatch = null;
			if (param1.canvasTarget != null)
			{
				_loc2_ = new CollectiveMeshBatch();
				meshBatches.push(_loc2_);
				_loc2_.emitters.push(param1);
				return _loc2_;
			}
			if (!effectsBatch)
			{
				effectsBatch = new CollectiveMeshBatch();
			}
			effectsBatch.emitters.push(param1);
			return effectsBatch;
		}
		
		public static function AllMeshesAreUpdated():void
		{
			var _loc2_:int = 0;
			var _loc1_:CollectiveMeshBatch = null;
			_loc2_ = meshBatches.length - 1;
			while (_loc2_ > -1)
			{
				_loc1_ = meshBatches[_loc2_];
				_loc1_.markUpdated();
				if (_loc1_.emitters.length == 0)
				{
					_loc1_.clear();
				}
				_loc2_--;
			}
			if (effectsBatch)
			{
				effectsBatch.markUpdated();
			}
		}
		
		public static function dispose():void
		{
			effectsBatch.dispose();
			effectsBatch = null;
			for each (var _loc1_:* in meshBatches)
			{
				_loc1_.emitters.length = 0;
				_loc1_.dispose();
			}
			meshBatches.length = 0;
		}
		
		override public function clear():void
		{
			if (!hasBeenUpdated)
			{
				return;
			}
			super.clear();
			hasBeenUpdated = false;
		}
		
		public function markUpdated():void
		{
			hasBeenUpdated = true;
		}
		
		public function remove(param1:Emitter):void
		{
			if (emitters.indexOf(param1) == -1)
			{
				return;
			}
			emitters.removeAt(emitters.indexOf(param1));
		}
	}
}
