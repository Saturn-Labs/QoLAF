package feathers.controls {
	import feathers.core.IGroupedToggle;
	import feathers.core.ToggleGroup;
	import feathers.skins.IStyleProvider;
	import flash.errors.IllegalOperationError;
	import starling.events.Event;
	
	public class Radio extends ToggleButton implements IGroupedToggle {
		public static const DEFAULT_CHILD_STYLE_NAME_LABEL:String = "feathers-radio-label";
		
		public static const STATE_UP:String = "up";
		
		public static const STATE_DOWN:String = "down";
		
		public static const STATE_HOVER:String = "hover";
		
		public static const STATE_DISABLED:String = "disabled";
		
		public static const STATE_UP_AND_SELECTED:String = "upAndSelected";
		
		public static const STATE_DOWN_AND_SELECTED:String = "downAndSelected";
		
		public static const STATE_HOVER_AND_SELECTED:String = "hoverAndSelected";
		
		public static const STATE_DISABLED_AND_SELECTED:String = "disabledAndSelected";
		
		public static const ICON_POSITION_TOP:String = "top";
		
		public static const ICON_POSITION_RIGHT:String = "right";
		
		public static const ICON_POSITION_BOTTOM:String = "bottom";
		
		public static const ICON_POSITION_LEFT:String = "left";
		
		public static const ICON_POSITION_MANUAL:String = "manual";
		
		public static const ICON_POSITION_LEFT_BASELINE:String = "leftBaseline";
		
		public static const ICON_POSITION_RIGHT_BASELINE:String = "rightBaseline";
		
		public static const HORIZONTAL_ALIGN_LEFT:String = "left";
		
		public static const HORIZONTAL_ALIGN_CENTER:String = "center";
		
		public static const HORIZONTAL_ALIGN_RIGHT:String = "right";
		
		public static const VERTICAL_ALIGN_TOP:String = "top";
		
		public static const VERTICAL_ALIGN_MIDDLE:String = "middle";
		
		public static const VERTICAL_ALIGN_BOTTOM:String = "bottom";
		
		public static var globalStyleProvider:IStyleProvider;
		
		public static const defaultRadioGroup:ToggleGroup = new ToggleGroup();
		
		public function Radio() {
			super();
			super.isToggle = true;
			this.labelStyleName = "feathers-radio-label";
			this.addEventListener("addedToStage",radio_addedToStageHandler);
			this.addEventListener("removedFromStage",radio_removedFromStageHandler);
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return Radio.globalStyleProvider;
		}
		
		override public function set isToggle(value:Boolean) : void {
			throw IllegalOperationError("Radio isToggle must always be true.");
		}
		
		override public function set toggleGroup(value:ToggleGroup) : void {
			if(this._toggleGroup === value) {
				return;
			}
			if(!value && this._toggleGroup !== defaultRadioGroup && this.stage) {
				value = defaultRadioGroup;
			}
			super.toggleGroup = value;
		}
		
		protected function radio_addedToStageHandler(event:Event) : void {
			if(!this._toggleGroup) {
				this.toggleGroup = defaultRadioGroup;
			}
		}
		
		protected function radio_removedFromStageHandler(event:Event) : void {
			if(this._toggleGroup == defaultRadioGroup) {
				this._toggleGroup.removeItem(this);
			}
		}
	}
}

