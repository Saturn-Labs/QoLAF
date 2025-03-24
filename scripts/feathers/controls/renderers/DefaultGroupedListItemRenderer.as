package feathers.controls.renderers {
	import feathers.controls.GroupedList;
	import feathers.skins.IStyleProvider;
	
	public class DefaultGroupedListItemRenderer extends BaseDefaultItemRenderer implements IGroupedListItemRenderer {
		public static const ALTERNATE_STYLE_NAME_DRILL_DOWN:String = "feathers-drill-down-item-renderer";
		
		public static const ALTERNATE_STYLE_NAME_CHECK:String = "feathers-check-item-renderer";
		
		public static const DEFAULT_CHILD_STYLE_NAME_LABEL:String = "feathers-item-renderer-label";
		
		public static const DEFAULT_CHILD_STYLE_NAME_ICON_LABEL:String = "feathers-item-renderer-icon-label";
		
		public static const DEFAULT_CHILD_STYLE_NAME_ACCESSORY_LABEL:String = "feathers-item-renderer-accessory-label";
		
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
		
		public static const ACCESSORY_POSITION_TOP:String = "top";
		
		public static const ACCESSORY_POSITION_RIGHT:String = "right";
		
		public static const ACCESSORY_POSITION_BOTTOM:String = "bottom";
		
		public static const ACCESSORY_POSITION_LEFT:String = "left";
		
		public static const ACCESSORY_POSITION_MANUAL:String = "manual";
		
		public static const LAYOUT_ORDER_LABEL_ACCESSORY_ICON:String = "labelAccessoryIcon";
		
		public static const LAYOUT_ORDER_LABEL_ICON_ACCESSORY:String = "labelIconAccessory";
		
		public static var globalStyleProvider:IStyleProvider;
		
		protected var _groupIndex:int = -1;
		
		protected var _itemIndex:int = -1;
		
		protected var _layoutIndex:int = -1;
		
		public function DefaultGroupedListItemRenderer() {
			super();
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return DefaultGroupedListItemRenderer.globalStyleProvider;
		}
		
		public function get groupIndex() : int {
			return this._groupIndex;
		}
		
		public function set groupIndex(value:int) : void {
			this._groupIndex = value;
		}
		
		public function get itemIndex() : int {
			return this._itemIndex;
		}
		
		public function set itemIndex(value:int) : void {
			this._itemIndex = value;
		}
		
		public function get layoutIndex() : int {
			return this._layoutIndex;
		}
		
		public function set layoutIndex(value:int) : void {
			this._layoutIndex = value;
		}
		
		public function get owner() : GroupedList {
			return GroupedList(this._owner);
		}
		
		public function set owner(value:GroupedList) : void {
			var _local2:GroupedList = null;
			if(this._owner == value) {
				return;
			}
			if(this._owner) {
				this._owner.removeEventListener("scrollStart",owner_scrollStartHandler);
				this._owner.removeEventListener("scrollComplete",owner_scrollCompleteHandler);
			}
			this._owner = value;
			if(this._owner) {
				_local2 = GroupedList(this._owner);
				this.isSelectableWithoutToggle = _local2.isSelectable;
				this._owner.addEventListener("scrollStart",owner_scrollStartHandler);
				this._owner.addEventListener("scrollComplete",owner_scrollCompleteHandler);
			}
			this.invalidate("data");
		}
		
		override public function dispose() : void {
			this.owner = null;
			super.dispose();
		}
	}
}

