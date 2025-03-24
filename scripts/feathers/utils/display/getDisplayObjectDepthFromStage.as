package feathers.utils.display {
	import starling.display.DisplayObject;
	
	public function getDisplayObjectDepthFromStage(target:DisplayObject) : int {
		if(!target.stage) {
			return -1;
		}
		var _local2:int = 0;
		while(target.parent) {
			target = target.parent;
			_local2++;
		}
		return _local2;
	}
}

