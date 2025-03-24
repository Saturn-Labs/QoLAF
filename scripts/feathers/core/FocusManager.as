package feathers.core {
	import flash.utils.Dictionary;
	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	import starling.display.Stage;
	
	public class FocusManager {
		protected static const FOCUS_MANAGER_NOT_ENABLED_ERROR:String = "The specified action is not permitted when the focus manager is not enabled.";
		
		protected static const FOCUS_MANAGER_ROOT_MUST_BE_ON_STAGE_ERROR:String = "A focus manager may not be added or removed for a display object that is not on stage.";
		
		protected static const STAGE_TO_STACK:Dictionary = new Dictionary(true);
		
		public static var focusManagerFactory:Function = defaultFocusManagerFactory;
		
		public function FocusManager() {
			super();
		}
		
		public static function getFocusManagerForStage(stage:Stage) : IFocusManager {
			var _local2:Vector.<IFocusManager> = STAGE_TO_STACK[stage] as Vector.<IFocusManager>;
			if(!_local2) {
				return null;
			}
			return _local2[_local2.length - 1];
		}
		
		public static function defaultFocusManagerFactory(root:DisplayObjectContainer) : IFocusManager {
			return new DefaultFocusManager(root);
		}
		
		public static function isEnabledForStage(stage:Stage) : Boolean {
			var _local2:Vector.<IFocusManager> = STAGE_TO_STACK[stage];
			return _local2 != null;
		}
		
		public static function setEnabledForStage(stage:Stage, isEnabled:Boolean) : void {
			var _local4:IFocusManager = null;
			var _local3:Vector.<IFocusManager> = STAGE_TO_STACK[stage];
			if(isEnabled && _local3 || !isEnabled && !_local3) {
				return;
			}
			if(isEnabled) {
				STAGE_TO_STACK[stage] = new Vector.<IFocusManager>(0);
				pushFocusManager(stage);
			} else {
				while(_local3.length > 0) {
					_local4 = _local3.pop();
					_local4.isEnabled = false;
				}
				delete STAGE_TO_STACK[stage];
			}
		}
		
		public static function get focus() : IFocusDisplayObject {
			var _local1:IFocusManager = getFocusManagerForStage(Starling.current.stage);
			if(_local1) {
				return _local1.focus;
			}
			return null;
		}
		
		public static function set focus(value:IFocusDisplayObject) : void {
			var _local2:IFocusManager = getFocusManagerForStage(Starling.current.stage);
			if(!_local2) {
				throw new Error("The specified action is not permitted when the focus manager is not enabled.");
			}
			_local2.focus = value;
		}
		
		public static function pushFocusManager(root:DisplayObjectContainer) : IFocusManager {
			var _local5:IFocusManager = null;
			var _local3:Stage = root.stage;
			if(!_local3) {
				throw new ArgumentError("A focus manager may not be added or removed for a display object that is not on stage.");
			}
			var _local2:Vector.<IFocusManager> = STAGE_TO_STACK[_local3] as Vector.<IFocusManager>;
			if(!_local2) {
				throw new Error("The specified action is not permitted when the focus manager is not enabled.");
			}
			var _local4:IFocusManager = FocusManager.focusManagerFactory(root);
			_local4.isEnabled = true;
			if(_local2.length > 0) {
				_local5 = _local2[_local2.length - 1];
				_local5.isEnabled = false;
			}
			_local2.push(_local4);
			return _local4;
		}
		
		public static function removeFocusManager(manager:IFocusManager) : void {
			var _local3:Stage = manager.root.stage;
			var _local2:Vector.<IFocusManager> = STAGE_TO_STACK[_local3] as Vector.<IFocusManager>;
			if(!_local2) {
				throw new Error("The specified action is not permitted when the focus manager is not enabled.");
			}
			var _local4:int = int(_local2.indexOf(manager));
			if(_local4 < 0) {
				return;
			}
			manager.isEnabled = false;
			_local2.removeAt(_local4);
			if(_local4 > 0 && _local4 == _local2.length) {
				manager = _local2[_local2.length - 1];
				manager.isEnabled = true;
			}
		}
		
		public function disableAll() : void {
			var _local2:Stage = null;
			var _local1:* = undefined;
			var _local3:IFocusManager = null;
			for(var _local4 in STAGE_TO_STACK) {
				_local2 = Stage(_local4);
				_local1 = STAGE_TO_STACK[_local2];
				while(_local1.length > 0) {
					_local3 = _local1.pop();
					_local3.isEnabled = false;
				}
				delete STAGE_TO_STACK[_local2];
			}
		}
	}
}

