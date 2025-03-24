package feathers.controls {
	import feathers.controls.supportClasses.LayoutViewPort;
	import feathers.core.IFeathersControl;
	import feathers.core.IFocusContainer;
	import feathers.layout.ILayout;
	import feathers.layout.ILayoutDisplayObject;
	import feathers.layout.IVirtualLayout;
	import feathers.skins.IStyleProvider;
	import feathers.utils.display.stageToStarling;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	
	public class ScrollContainer extends Scroller implements IScrollContainer, IFocusContainer {
		public static const ALTERNATE_STYLE_NAME_TOOLBAR:String = "feathers-toolbar-scroll-container";
		
		public static const SCROLL_POLICY_AUTO:String = "auto";
		
		public static const SCROLL_POLICY_ON:String = "on";
		
		public static const SCROLL_POLICY_OFF:String = "off";
		
		public static const SCROLL_BAR_DISPLAY_MODE_FLOAT:String = "float";
		
		public static const SCROLL_BAR_DISPLAY_MODE_FIXED:String = "fixed";
		
		public static const SCROLL_BAR_DISPLAY_MODE_FIXED_FLOAT:String = "fixedFloat";
		
		public static const SCROLL_BAR_DISPLAY_MODE_NONE:String = "none";
		
		public static const VERTICAL_SCROLL_BAR_POSITION_RIGHT:String = "right";
		
		public static const VERTICAL_SCROLL_BAR_POSITION_LEFT:String = "left";
		
		public static const INTERACTION_MODE_TOUCH:String = "touch";
		
		public static const INTERACTION_MODE_MOUSE:String = "mouse";
		
		public static const INTERACTION_MODE_TOUCH_AND_SCROLL_BARS:String = "touchAndScrollBars";
		
		public static const MOUSE_WHEEL_SCROLL_DIRECTION_VERTICAL:String = "vertical";
		
		public static const MOUSE_WHEEL_SCROLL_DIRECTION_HORIZONTAL:String = "horizontal";
		
		public static const DECELERATION_RATE_NORMAL:Number = 0.998;
		
		public static const DECELERATION_RATE_FAST:Number = 0.99;
		
		public static const AUTO_SIZE_MODE_STAGE:String = "stage";
		
		public static const AUTO_SIZE_MODE_CONTENT:String = "content";
		
		public static var globalStyleProvider:IStyleProvider;
		
		protected var displayListBypassEnabled:Boolean = true;
		
		protected var layoutViewPort:LayoutViewPort;
		
		protected var _isChildFocusEnabled:Boolean = true;
		
		protected var _layout:ILayout;
		
		protected var _autoSizeMode:String = "content";
		
		protected var _ignoreChildChanges:Boolean = false;
		
		public function ScrollContainer() {
			super();
			this.layoutViewPort = new LayoutViewPort();
			this.viewPort = this.layoutViewPort;
			this.addEventListener("addedToStage",scrollContainer_addedToStageHandler);
			this.addEventListener("removedFromStage",scrollContainer_removedFromStageHandler);
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return ScrollContainer.globalStyleProvider;
		}
		
		public function get isChildFocusEnabled() : Boolean {
			return this._isEnabled && this._isChildFocusEnabled;
		}
		
		public function set isChildFocusEnabled(value:Boolean) : void {
			this._isChildFocusEnabled = value;
		}
		
		public function get layout() : ILayout {
			return this._layout;
		}
		
		public function set layout(value:ILayout) : void {
			if(this._layout == value) {
				return;
			}
			this._layout = value;
			this.invalidate("layout");
		}
		
		public function get autoSizeMode() : String {
			return this._autoSizeMode;
		}
		
		public function set autoSizeMode(value:String) : void {
			if(this._autoSizeMode == value) {
				return;
			}
			this._autoSizeMode = value;
			this._measureViewPort = this._autoSizeMode != "stage";
			if(this.stage) {
				if(this._autoSizeMode == "stage") {
					this.stage.addEventListener("resize",stage_resizeHandler);
				} else {
					this.stage.removeEventListener("resize",stage_resizeHandler);
				}
			}
			this.invalidate("size");
		}
		
		override public function get numChildren() : int {
			if(!this.displayListBypassEnabled) {
				return super.numChildren;
			}
			return DisplayObjectContainer(this.viewPort).numChildren;
		}
		
		public function get numRawChildren() : int {
			var _local2:Boolean = this.displayListBypassEnabled;
			this.displayListBypassEnabled = false;
			var _local1:int = super.numChildren;
			this.displayListBypassEnabled = _local2;
			return _local1;
		}
		
		override public function getChildByName(name:String) : DisplayObject {
			if(!this.displayListBypassEnabled) {
				return super.getChildByName(name);
			}
			return DisplayObjectContainer(this.viewPort).getChildByName(name);
		}
		
		public function getRawChildByName(name:String) : DisplayObject {
			var _local2:Boolean = this.displayListBypassEnabled;
			this.displayListBypassEnabled = false;
			var _local3:DisplayObject = super.getChildByName(name);
			this.displayListBypassEnabled = _local2;
			return _local3;
		}
		
		override public function getChildAt(index:int) : DisplayObject {
			if(!this.displayListBypassEnabled) {
				return super.getChildAt(index);
			}
			return DisplayObjectContainer(this.viewPort).getChildAt(index);
		}
		
		public function getRawChildAt(index:int) : DisplayObject {
			var _local2:Boolean = this.displayListBypassEnabled;
			this.displayListBypassEnabled = false;
			var _local3:DisplayObject = super.getChildAt(index);
			this.displayListBypassEnabled = _local2;
			return _local3;
		}
		
		public function addRawChild(child:DisplayObject) : DisplayObject {
			var _local2:Boolean = this.displayListBypassEnabled;
			this.displayListBypassEnabled = false;
			if(child.parent == this) {
				super.setChildIndex(child,super.numChildren);
			} else {
				child = super.addChildAt(child,super.numChildren);
			}
			this.displayListBypassEnabled = _local2;
			return child;
		}
		
		override public function addChild(child:DisplayObject) : DisplayObject {
			return this.addChildAt(child,this.numChildren);
		}
		
		override public function addChildAt(child:DisplayObject, index:int) : DisplayObject {
			if(!this.displayListBypassEnabled) {
				return super.addChildAt(child,index);
			}
			var _local3:DisplayObject = DisplayObjectContainer(this.viewPort).addChildAt(child,index);
			if(_local3 is IFeathersControl) {
				_local3.addEventListener("resize",child_resizeHandler);
			}
			if(_local3 is ILayoutDisplayObject) {
				_local3.addEventListener("layoutDataChange",child_layoutDataChangeHandler);
			}
			this.invalidate("size");
			return _local3;
		}
		
		public function addRawChildAt(child:DisplayObject, index:int) : DisplayObject {
			var _local3:Boolean = this.displayListBypassEnabled;
			this.displayListBypassEnabled = false;
			child = super.addChildAt(child,index);
			this.displayListBypassEnabled = _local3;
			return child;
		}
		
		public function removeRawChild(child:DisplayObject, dispose:Boolean = false) : DisplayObject {
			var _local3:Boolean = this.displayListBypassEnabled;
			this.displayListBypassEnabled = false;
			var _local4:int = super.getChildIndex(child);
			if(_local4 >= 0) {
				super.removeChildAt(_local4,dispose);
			}
			this.displayListBypassEnabled = _local3;
			return child;
		}
		
		override public function removeChildAt(index:int, dispose:Boolean = false) : DisplayObject {
			if(!this.displayListBypassEnabled) {
				return super.removeChildAt(index,dispose);
			}
			var _local3:DisplayObject = DisplayObjectContainer(this.viewPort).removeChildAt(index,dispose);
			if(_local3 is IFeathersControl) {
				_local3.removeEventListener("resize",child_resizeHandler);
			}
			if(_local3 is ILayoutDisplayObject) {
				_local3.removeEventListener("layoutDataChange",child_layoutDataChangeHandler);
			}
			this.invalidate("size");
			return _local3;
		}
		
		public function removeRawChildAt(index:int, dispose:Boolean = false) : DisplayObject {
			var _local3:Boolean = this.displayListBypassEnabled;
			this.displayListBypassEnabled = false;
			var _local4:DisplayObject = super.removeChildAt(index,dispose);
			this.displayListBypassEnabled = _local3;
			return _local4;
		}
		
		override public function getChildIndex(child:DisplayObject) : int {
			if(!this.displayListBypassEnabled) {
				return super.getChildIndex(child);
			}
			return DisplayObjectContainer(this.viewPort).getChildIndex(child);
		}
		
		public function getRawChildIndex(child:DisplayObject) : int {
			var _local2:Boolean = this.displayListBypassEnabled;
			this.displayListBypassEnabled = false;
			var _local3:int = super.getChildIndex(child);
			this.displayListBypassEnabled = _local2;
			return _local3;
		}
		
		override public function setChildIndex(child:DisplayObject, index:int) : void {
			if(!this.displayListBypassEnabled) {
				super.setChildIndex(child,index);
				return;
			}
			DisplayObjectContainer(this.viewPort).setChildIndex(child,index);
		}
		
		public function setRawChildIndex(child:DisplayObject, index:int) : void {
			var _local3:Boolean = this.displayListBypassEnabled;
			this.displayListBypassEnabled = false;
			super.setChildIndex(child,index);
			this.displayListBypassEnabled = _local3;
		}
		
		public function swapRawChildren(child1:DisplayObject, child2:DisplayObject) : void {
			var _local3:int = this.getRawChildIndex(child1);
			var _local5:int = this.getRawChildIndex(child2);
			if(_local3 < 0 || _local5 < 0) {
				throw new ArgumentError("Not a child of this container");
			}
			var _local4:Boolean = this.displayListBypassEnabled;
			this.displayListBypassEnabled = false;
			this.swapRawChildrenAt(_local3,_local5);
			this.displayListBypassEnabled = _local4;
		}
		
		override public function swapChildrenAt(index1:int, index2:int) : void {
			if(!this.displayListBypassEnabled) {
				super.swapChildrenAt(index1,index2);
				return;
			}
			DisplayObjectContainer(this.viewPort).swapChildrenAt(index1,index2);
		}
		
		public function swapRawChildrenAt(index1:int, index2:int) : void {
			var _local3:Boolean = this.displayListBypassEnabled;
			this.displayListBypassEnabled = false;
			super.swapChildrenAt(index1,index2);
			this.displayListBypassEnabled = _local3;
		}
		
		override public function sortChildren(compareFunction:Function) : void {
			if(!this.displayListBypassEnabled) {
				super.sortChildren(compareFunction);
				return;
			}
			DisplayObjectContainer(this.viewPort).sortChildren(compareFunction);
		}
		
		public function sortRawChildren(compareFunction:Function) : void {
			var _local2:Boolean = this.displayListBypassEnabled;
			this.displayListBypassEnabled = false;
			super.sortChildren(compareFunction);
			this.displayListBypassEnabled = _local2;
		}
		
		public function readjustLayout() : void {
			this.layoutViewPort.readjustLayout();
			this.invalidate("size");
		}
		
		override protected function initialize() : void {
			var _local1:Starling = null;
			if(this.stage !== null) {
				_local1 = stageToStarling(this.stage);
				if(_local1.root === this) {
					this.autoSizeMode = "stage";
				}
			}
			super.initialize();
		}
		
		override protected function draw() : void {
			var _local1:Boolean = this.isInvalid("layout");
			if(_local1) {
				if(this._layout is IVirtualLayout) {
					IVirtualLayout(this._layout).useVirtualLayout = false;
				}
				this.layoutViewPort.layout = this._layout;
			}
			var _local2:Boolean = this._ignoreChildChanges;
			this._ignoreChildChanges = true;
			super.draw();
			this._ignoreChildChanges = _local2;
		}
		
		override protected function autoSizeIfNeeded() : Boolean {
			var _local1:Number = NaN;
			var _local4:Number = NaN;
			var _local2:* = this._explicitWidth !== this._explicitWidth;
			var _local5:* = this._explicitHeight !== this._explicitHeight;
			var _local3:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local6:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local2 && !_local5 && !_local3 && !_local6) {
				return false;
			}
			if(this._autoSizeMode === "stage") {
				_local1 = this.stage.stageWidth;
				_local4 = this.stage.stageHeight;
				return this.saveMeasurements(_local1,_local4,_local1,_local4);
			}
			return super.autoSizeIfNeeded();
		}
		
		protected function scrollContainer_addedToStageHandler(event:Event) : void {
			if(this._autoSizeMode == "stage") {
				this.stage.addEventListener("resize",stage_resizeHandler);
			}
		}
		
		protected function scrollContainer_removedFromStageHandler(event:Event) : void {
			this.stage.removeEventListener("resize",stage_resizeHandler);
		}
		
		protected function child_resizeHandler(event:Event) : void {
			if(this._ignoreChildChanges) {
				return;
			}
			this.invalidate("size");
		}
		
		protected function child_layoutDataChangeHandler(event:Event) : void {
			if(this._ignoreChildChanges) {
				return;
			}
			this.invalidate("size");
		}
		
		protected function stage_resizeHandler(event:Event) : void {
			this.invalidate("size");
		}
	}
}

