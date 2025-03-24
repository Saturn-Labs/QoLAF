package feathers.core {
	import flash.utils.Dictionary;
	import starling.display.DisplayObjectContainer;
	import starling.display.Stage;
	
	public class ToolTipManager {
		protected static const STAGE_TO_MANAGER:Dictionary = new Dictionary(true);
		
		public static var toolTipManagerFactory:Function = defaultToolTipManagerFactory;
		
		public function ToolTipManager() {
			super();
		}
		
		public static function getToolTipManagerForStage(stage:Stage) : IToolTipManager {
			return IToolTipManager(STAGE_TO_MANAGER[stage]);
		}
		
		public static function defaultToolTipManagerFactory(root:DisplayObjectContainer) : IToolTipManager {
			return new DefaultToolTipManager(root);
		}
		
		public static function isEnabledForStage(stage:Stage) : Boolean {
			return IToolTipManager(STAGE_TO_MANAGER[stage]) !== null;
		}
		
		public static function setEnabledForStage(stage:Stage, isEnabled:Boolean) : void {
			var _local3:IToolTipManager = IToolTipManager(STAGE_TO_MANAGER[stage]);
			if(isEnabled && _local3 || !isEnabled && !_local3) {
				return;
			}
			if(isEnabled) {
				STAGE_TO_MANAGER[stage] = toolTipManagerFactory(stage);
			} else {
				_local3.dispose();
				delete STAGE_TO_MANAGER[stage];
			}
		}
		
		public function disableAll() : void {
			var _local1:Stage = null;
			var _local2:IToolTipManager = null;
			for(var _local3 in STAGE_TO_MANAGER) {
				_local1 = Stage(_local3);
				_local2 = IToolTipManager(STAGE_TO_MANAGER[_local1]);
				_local2.dispose();
				delete STAGE_TO_MANAGER[_local1];
			}
		}
	}
}

