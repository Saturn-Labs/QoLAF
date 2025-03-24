package feathers.events {
	import flash.utils.Dictionary;
	import starling.display.DisplayObject;
	import starling.display.Stage;
	import starling.events.EventDispatcher;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	public class ExclusiveTouch extends EventDispatcher {
		protected static const stageToObject:Dictionary = new Dictionary(true);
		
		protected var _stageListenerCount:int = 0;
		
		protected var _stage:Stage;
		
		protected var _claims:Dictionary = new Dictionary();
		
		public function ExclusiveTouch(stage:Stage) {
			super();
			if(!stage) {
				throw new ArgumentError("Stage cannot be null.");
			}
			this._stage = stage;
		}
		
		public static function forStage(stage:Stage) : ExclusiveTouch {
			if(!stage) {
				throw new ArgumentError("Stage cannot be null.");
			}
			var _local2:ExclusiveTouch = ExclusiveTouch(stageToObject[stage]);
			if(_local2) {
				return _local2;
			}
			_local2 = new ExclusiveTouch(stage);
			stageToObject[stage] = _local2;
			return _local2;
		}
		
		public static function disposeForStage(stage:Stage) : void {
			delete stageToObject[stage];
		}
		
		public function claimTouch(touchID:int, target:DisplayObject) : Boolean {
			if(!target) {
				throw new ArgumentError("Target cannot be null.");
			}
			if(target.stage != this._stage) {
				throw new ArgumentError("Target cannot claim a touch on the selected stage because it appears on a different stage.");
			}
			if(touchID < 0) {
				throw new ArgumentError("Invalid touch. Touch ID must be >= 0.");
			}
			var _local3:DisplayObject = DisplayObject(this._claims[touchID]);
			if(_local3) {
				return false;
			}
			this._claims[touchID] = target;
			if(this._stageListenerCount == 0) {
				this._stage.addEventListener("touch",stage_touchHandler);
			}
			this._stageListenerCount++;
			this.dispatchEventWith("change",false,touchID);
			return true;
		}
		
		public function removeClaim(touchID:int) : void {
			var _local2:DisplayObject = DisplayObject(this._claims[touchID]);
			if(!_local2) {
				return;
			}
			delete this._claims[touchID];
			this.dispatchEventWith("change",false,touchID);
		}
		
		public function getClaim(touchID:int) : DisplayObject {
			if(touchID < 0) {
				throw new ArgumentError("Invalid touch. Touch ID must be >= 0.");
			}
			return DisplayObject(this._claims[touchID]);
		}
		
		protected function stage_touchHandler(event:TouchEvent) : void {
			var _local2:int = 0;
			var _local3:Touch = null;
			for(var _local4 in this._claims) {
				_local2 = _local4 as int;
				_local3 = event.getTouch(this._stage,"ended",_local2);
				if(_local3) {
					delete this._claims[_local4];
					this._stageListenerCount--;
				}
			}
			if(this._stageListenerCount == 0) {
				this._stage.removeEventListener("touch",stage_touchHandler);
			}
		}
	}
}

