package feathers.utils.display {
	import starling.core.Starling;
	import starling.display.Stage;
	
	public function stageToStarling(stage:Stage) : Starling {
		for each(var _local2 in Starling.all) {
			if(_local2.stage === stage) {
				return _local2;
			}
		}
		return null;
	}
}

