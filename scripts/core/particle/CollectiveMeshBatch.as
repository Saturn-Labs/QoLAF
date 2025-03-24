package core.particle {
	import starling.display.MeshBatch;
	
	public class CollectiveMeshBatch extends MeshBatch {
		private static var effectsBatch:CollectiveMeshBatch;
		
		private static var meshBatches:Vector.<CollectiveMeshBatch> = new Vector.<CollectiveMeshBatch>();
		
		private var hasBeenUpdated:Boolean = false;
		
		private var emitters:Vector.<Emitter> = new Vector.<Emitter>();
		
		public function CollectiveMeshBatch() {
			super();
			batchable = false;
		}
		
		public static function Create(e:Emitter) : CollectiveMeshBatch {
			var _local2:CollectiveMeshBatch = null;
			if(e.canvasTarget != null) {
				_local2 = new CollectiveMeshBatch();
				meshBatches.push(_local2);
				_local2.emitters.push(e);
				return _local2;
			}
			if(!effectsBatch) {
				effectsBatch = new CollectiveMeshBatch();
			}
			effectsBatch.emitters.push(e);
			return effectsBatch;
		}
		
		public static function AllMeshesAreUpdated() : void {
			var _local2:int = 0;
			var _local1:CollectiveMeshBatch = null;
			_local2 = meshBatches.length - 1;
			while(_local2 > -1) {
				_local1 = meshBatches[_local2];
				_local1.markUpdated();
				if(_local1.emitters.length == 0) {
					_local1.clear();
				}
				_local2--;
			}
			if(effectsBatch) {
				effectsBatch.markUpdated();
			}
		}
		
		public static function dispose() : void {
			effectsBatch.dispose();
			effectsBatch = null;
			for each(var _local1 in meshBatches) {
				_local1.emitters.length = 0;
				_local1.dispose();
			}
			meshBatches.length = 0;
		}
		
		override public function clear() : void {
			if(!hasBeenUpdated) {
				return;
			}
			super.clear();
			hasBeenUpdated = false;
		}
		
		public function markUpdated() : void {
			hasBeenUpdated = true;
		}
		
		public function remove(e:Emitter) : void {
			if(emitters.indexOf(e) == -1) {
				return;
			}
			emitters.removeAt(emitters.indexOf(e));
		}
	}
}

