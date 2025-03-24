package feathers.controls {
	import feathers.skins.IStyleProvider;
	import feathers.utils.display.getDisplayObjectDepthFromStage;
	import feathers.utils.display.stageToStarling;
	import flash.events.KeyboardEvent;
	import starling.core.Starling;
	import starling.events.Event;
	
	public class ScrollScreen extends ScrollContainer implements IScreen {
		public static const SCROLL_POLICY_AUTO:String = "auto";
		
		public static const SCROLL_POLICY_ON:String = "on";
		
		public static const SCROLL_POLICY_OFF:String = "off";
		
		public static const SCROLL_BAR_DISPLAY_MODE_FLOAT:String = "float";
		
		public static const SCROLL_BAR_DISPLAY_MODE_FIXED:String = "fixed";
		
		public static const SCROLL_BAR_DISPLAY_MODE_NONE:String = "none";
		
		public static const VERTICAL_SCROLL_BAR_POSITION_RIGHT:String = "right";
		
		public static const VERTICAL_SCROLL_BAR_POSITION_LEFT:String = "left";
		
		public static const INTERACTION_MODE_TOUCH:String = "touch";
		
		public static const INTERACTION_MODE_MOUSE:String = "mouse";
		
		public static const INTERACTION_MODE_TOUCH_AND_SCROLL_BARS:String = "touchAndScrollBars";
		
		public static const DECELERATION_RATE_NORMAL:Number = 0.998;
		
		public static const DECELERATION_RATE_FAST:Number = 0.99;
		
		public static const AUTO_SIZE_MODE_STAGE:String = "stage";
		
		public static const AUTO_SIZE_MODE_CONTENT:String = "content";
		
		public static var globalStyleProvider:IStyleProvider;
		
		protected var _screenID:String;
		
		protected var _owner:Object;
		
		protected var backButtonHandler:Function;
		
		protected var menuButtonHandler:Function;
		
		protected var searchButtonHandler:Function;
		
		public function ScrollScreen() {
			this.addEventListener("addedToStage",scrollScreen_addedToStageHandler);
			super();
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return ScrollScreen.globalStyleProvider;
		}
		
		public function get screenID() : String {
			return this._screenID;
		}
		
		public function set screenID(value:String) : void {
			this._screenID = value;
		}
		
		public function get owner() : Object {
			return this._owner;
		}
		
		public function set owner(value:Object) : void {
			this._owner = value;
		}
		
		protected function scrollScreen_addedToStageHandler(event:Event) : void {
			this.addEventListener("removedFromStage",scrollScreen_removedFromStageHandler);
			var _local3:int = -getDisplayObjectDepthFromStage(this);
			var _local2:Starling = stageToStarling(this.stage);
			_local2.nativeStage.addEventListener("keyDown",scrollScreen_nativeStage_keyDownHandler,false,_local3,true);
		}
		
		protected function scrollScreen_removedFromStageHandler(event:Event) : void {
			this.removeEventListener("removedFromStage",scrollScreen_removedFromStageHandler);
			var _local2:Starling = stageToStarling(this.stage);
			_local2.nativeStage.removeEventListener("keyDown",scrollScreen_nativeStage_keyDownHandler);
		}
		
		protected function scrollScreen_nativeStage_keyDownHandler(event:KeyboardEvent) : void {
			if(event.isDefaultPrevented()) {
				return;
			}
			if(this.backButtonHandler != null && event.keyCode == 16777238) {
				event.preventDefault();
				this.backButtonHandler();
			}
			if(this.menuButtonHandler != null && event.keyCode == 16777234) {
				event.preventDefault();
				this.menuButtonHandler();
			}
			if(this.searchButtonHandler != null && event.keyCode == 16777247) {
				event.preventDefault();
				this.searchButtonHandler();
			}
		}
	}
}

