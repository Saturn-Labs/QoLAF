package core.player {
	import data.DataLocator;
	
	public class Mission {
		public var id:String;
		
		public var type:String;
		
		public var majorType:String;
		
		public var viewed:Boolean;
		
		public var finished:Boolean;
		
		public var claimed:Boolean;
		
		public var created:Number;
		
		public var missionTypeKey:String;
		
		public var count:int;
		
		public var expires:Number;
		
		private var _missionType:Object = null;
		
		public function Mission() {
			super();
		}
		
		public function getMissionType() : Object {
			if(_missionType != null) {
				return _missionType;
			}
			_missionType = DataLocator.getService().loadKey("MissionTypes",missionTypeKey);
			return _missionType;
		}
	}
}

