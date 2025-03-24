package feathers.controls {
	import feathers.core.FeathersControl;
	import feathers.core.IFeathersControl;
	import feathers.core.IMeasureDisplayObject;
	import feathers.core.IValidating;
	import feathers.layout.ILayout;
	import feathers.layout.ILayoutDisplayObject;
	import feathers.layout.IVirtualLayout;
	import feathers.layout.LayoutBoundsResult;
	import feathers.layout.ViewPortBounds;
	import feathers.skins.IStyleProvider;
	import feathers.utils.display.stageToStarling;
	import feathers.utils.skins.resetFluidChildDimensionsForMeasurement;
	import flash.geom.Point;
	import starling.core.Starling;
	import starling.core.starling_internal;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.filters.FragmentFilter;
	import starling.rendering.Painter;
	
	use namespace starling_internal;
	
	public class LayoutGroup extends FeathersControl {
		protected static const INVALIDATION_FLAG_CLIPPING:String = "clipping";
		
		public static const AUTO_SIZE_MODE_STAGE:String = "stage";
		
		public static const AUTO_SIZE_MODE_CONTENT:String = "content";
		
		public static const ALTERNATE_STYLE_NAME_TOOLBAR:String = "feathers-toolbar-layout-group";
		
		public static var globalStyleProvider:IStyleProvider;
		
		protected var items:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
		
		protected var viewPortBounds:ViewPortBounds = new ViewPortBounds();
		
		protected var _layoutResult:LayoutBoundsResult = new LayoutBoundsResult();
		
		protected var _layout:ILayout;
		
		protected var _clipContent:Boolean = false;
		
		protected var _explicitBackgroundWidth:Number;
		
		protected var _explicitBackgroundHeight:Number;
		
		protected var _explicitBackgroundMinWidth:Number;
		
		protected var _explicitBackgroundMinHeight:Number;
		
		protected var _explicitBackgroundMaxWidth:Number;
		
		protected var _explicitBackgroundMaxHeight:Number;
		
		protected var currentBackgroundSkin:DisplayObject;
		
		protected var _backgroundSkin:DisplayObject;
		
		protected var _backgroundDisabledSkin:DisplayObject;
		
		protected var _autoSizeMode:String = "content";
		
		protected var _ignoreChildChanges:Boolean = false;
		
		public function LayoutGroup() {
			super();
			this.addEventListener("addedToStage",layoutGroup_addedToStageHandler);
			this.addEventListener("removedFromStage",layoutGroup_removedFromStageHandler);
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return LayoutGroup.globalStyleProvider;
		}
		
		public function get layout() : ILayout {
			return this._layout;
		}
		
		public function set layout(value:ILayout) : void {
			if(this._layout == value) {
				return;
			}
			if(this._layout) {
				this._layout.removeEventListener("change",layout_changeHandler);
			}
			this._layout = value;
			if(this._layout) {
				if(this._layout is IVirtualLayout) {
					IVirtualLayout(this._layout).useVirtualLayout = false;
				}
				this._layout.addEventListener("change",layout_changeHandler);
				this.invalidate("layout");
			}
			this.invalidate("layout");
		}
		
		public function get clipContent() : Boolean {
			return this._clipContent;
		}
		
		public function set clipContent(value:Boolean) : void {
			if(this._clipContent == value) {
				return;
			}
			this._clipContent = value;
			if(!value) {
				this.mask = null;
			}
			this.invalidate("clipping");
		}
		
		public function get backgroundSkin() : DisplayObject {
			return this._backgroundSkin;
		}
		
		public function set backgroundSkin(value:DisplayObject) : void {
			if(this._backgroundSkin == value) {
				return;
			}
			if(value && value.parent) {
				value.removeFromParent();
			}
			this._backgroundSkin = value;
			this.invalidate("skin");
		}
		
		public function get backgroundDisabledSkin() : DisplayObject {
			return this._backgroundDisabledSkin;
		}
		
		public function set backgroundDisabledSkin(value:DisplayObject) : void {
			if(this._backgroundDisabledSkin == value) {
				return;
			}
			if(value && value.parent) {
				value.removeFromParent();
			}
			this._backgroundDisabledSkin = value;
			this.invalidate("skin");
		}
		
		public function get autoSizeMode() : String {
			return this._autoSizeMode;
		}
		
		public function set autoSizeMode(value:String) : void {
			if(this._autoSizeMode == value) {
				return;
			}
			this._autoSizeMode = value;
			if(this.stage) {
				if(this._autoSizeMode == "stage") {
					this.stage.addEventListener("resize",stage_resizeHandler);
				} else {
					this.stage.removeEventListener("resize",stage_resizeHandler);
				}
			}
			this.invalidate("size");
		}
		
		override public function addChildAt(child:DisplayObject, index:int) : DisplayObject {
			if(child is IFeathersControl) {
				child.addEventListener("resize",child_resizeHandler);
			}
			if(child is ILayoutDisplayObject) {
				child.addEventListener("layoutDataChange",child_layoutDataChangeHandler);
			}
			var _local3:int = int(this.items.indexOf(child));
			if(_local3 == index) {
				return child;
			}
			if(_local3 >= 0) {
				this.items.removeAt(_local3);
			}
			this.items.insertAt(index,child);
			this.invalidate("layout");
			return super.addChildAt(child,index);
		}
		
		override public function removeChildAt(index:int, dispose:Boolean = false) : DisplayObject {
			if(index >= 0 && index < this.items.length) {
				this.items.removeAt(index);
			}
			var _local3:DisplayObject = super.removeChildAt(index,dispose);
			if(_local3 is IFeathersControl) {
				_local3.removeEventListener("resize",child_resizeHandler);
			}
			if(_local3 is ILayoutDisplayObject) {
				_local3.removeEventListener("layoutDataChange",child_layoutDataChangeHandler);
			}
			this.invalidate("layout");
			return _local3;
		}
		
		override public function setChildIndex(child:DisplayObject, index:int) : void {
			super.setChildIndex(child,index);
			var _local3:int = int(this.items.indexOf(child));
			if(_local3 === index) {
				return;
			}
			this.items.removeAt(_local3);
			this.items.insertAt(index,child);
			this.invalidate("layout");
		}
		
		override public function swapChildrenAt(index1:int, index2:int) : void {
			super.swapChildrenAt(index1,index2);
			var _local4:DisplayObject = this.items[index1];
			var _local3:DisplayObject = this.items[index2];
			this.items[index1] = _local3;
			this.items[index2] = _local4;
			this.invalidate("layout");
		}
		
		override public function sortChildren(compareFunction:Function) : void {
			super.sortChildren(compareFunction);
			this.items.sort(compareFunction);
			this.invalidate("layout");
		}
		
		override public function hitTest(localPoint:Point) : DisplayObject {
			var _local4:Number = localPoint.x;
			var _local3:Number = localPoint.y;
			var _local2:DisplayObject = super.hitTest(localPoint);
			if(_local2) {
				if(!this._isEnabled) {
					return this;
				}
				return _local2;
			}
			if(!this.visible || !this.touchable) {
				return null;
			}
			if(this.currentBackgroundSkin && this._hitArea.contains(_local4,_local3)) {
				return this;
			}
			return null;
		}
		
		override public function render(painter:Painter) : void {
			var _local3:DisplayObject = null;
			var _local2:FragmentFilter = null;
			if(this.currentBackgroundSkin !== null && this.currentBackgroundSkin.visible && this.currentBackgroundSkin.alpha > 0) {
				this.currentBackgroundSkin.setRequiresRedraw();
				_local3 = this.currentBackgroundSkin.mask;
				_local2 = this.currentBackgroundSkin.filter;
				painter.pushState();
				painter.setStateTo(this.currentBackgroundSkin.transformationMatrix,this.currentBackgroundSkin.alpha,this.currentBackgroundSkin.blendMode);
				if(_local3 !== null) {
					painter.drawMask(_local3);
				}
				if(_local2 !== null) {
					_local2.render(painter);
				} else {
					this.currentBackgroundSkin.render(painter);
				}
				if(_local3 !== null) {
					painter.eraseMask(_local3);
				}
				painter.popState();
			}
			super.render(painter);
		}
		
		override public function dispose() : void {
			if(this.currentBackgroundSkin !== null) {
				this.currentBackgroundSkin.starling_internal::setParent(null);
			}
			if(this._backgroundSkin && this._backgroundSkin.parent !== this) {
				this._backgroundSkin.dispose();
			}
			if(this._backgroundDisabledSkin && this._backgroundDisabledSkin.parent !== this) {
				this._backgroundDisabledSkin.dispose();
			}
			this.layout = null;
			super.dispose();
		}
		
		public function readjustLayout() : void {
			this.invalidate("layout");
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
			var _local6:Boolean = false;
			var _local2:Boolean = this.isInvalid("layout");
			var _local1:Boolean = this.isInvalid("size");
			var _local5:Boolean = this.isInvalid("clipping");
			var _local7:Boolean = this.isInvalid("scroll");
			var _local3:Boolean = this.isInvalid("skin");
			var _local4:Boolean = this.isInvalid("state");
			if(!_local2 && _local7 && this._layout && this._layout.requiresLayoutOnScroll) {
				_local2 = true;
			}
			if(_local3 || _local4) {
				this.refreshBackgroundSkin();
			}
			if(_local1 || _local2 || _local3 || _local4) {
				this.refreshViewPortBounds();
				if(this._layout) {
					_local6 = this._ignoreChildChanges;
					this._ignoreChildChanges = true;
					this._layout.layout(this.items,this.viewPortBounds,this._layoutResult);
					this._ignoreChildChanges = _local6;
				} else {
					this.handleManualLayout();
				}
				this.handleLayoutResult();
				this.refreshBackgroundLayout();
				this.validateChildren();
			}
			if(_local1 || _local5) {
				this.refreshClipRect();
			}
		}
		
		protected function refreshBackgroundSkin() : void {
			var _local2:IMeasureDisplayObject = null;
			var _local1:DisplayObject = this.currentBackgroundSkin;
			if(!this._isEnabled && this._backgroundDisabledSkin !== null) {
				this.currentBackgroundSkin = this._backgroundDisabledSkin;
			} else {
				this.currentBackgroundSkin = this._backgroundSkin;
			}
			switch(_local1) {
				default:
					_local1.starling_internal::setParent(null);
				case null:
					if(this.currentBackgroundSkin !== null) {
						this.currentBackgroundSkin.starling_internal::setParent(this);
						if(this.currentBackgroundSkin is IFeathersControl) {
							IFeathersControl(this.currentBackgroundSkin).initializeNow();
						}
						if(this.currentBackgroundSkin is IMeasureDisplayObject) {
							_local2 = IMeasureDisplayObject(this.currentBackgroundSkin);
							this._explicitBackgroundWidth = _local2.explicitWidth;
							this._explicitBackgroundHeight = _local2.explicitHeight;
							this._explicitBackgroundMinWidth = _local2.explicitMinWidth;
							this._explicitBackgroundMinHeight = _local2.explicitMinHeight;
							this._explicitBackgroundMaxWidth = _local2.explicitMaxWidth;
							this._explicitBackgroundMaxHeight = _local2.explicitMaxHeight;
							break;
						}
						this._explicitBackgroundWidth = this.currentBackgroundSkin.width;
						this._explicitBackgroundHeight = this.currentBackgroundSkin.height;
						this._explicitBackgroundMinWidth = this._explicitBackgroundWidth;
						this._explicitBackgroundMinHeight = this._explicitBackgroundHeight;
						this._explicitBackgroundMaxWidth = this._explicitBackgroundWidth;
						this._explicitBackgroundMaxHeight = this._explicitBackgroundHeight;
					}
					break;
				case _local1:
			}
		}
		
		protected function refreshBackgroundLayout() : void {
			if(this.currentBackgroundSkin === null) {
				return;
			}
			if(this.currentBackgroundSkin.width !== this.actualWidth || this.currentBackgroundSkin.height !== this.actualHeight) {
				this.currentBackgroundSkin.width = this.actualWidth;
				this.currentBackgroundSkin.height = this.actualHeight;
			}
		}
		
		protected function refreshViewPortBounds() : void {
			var _local1:* = this._explicitWidth !== this._explicitWidth;
			var _local3:* = this._explicitHeight !== this._explicitHeight;
			var _local2:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local6:* = this._explicitMinHeight !== this._explicitMinHeight;
			resetFluidChildDimensionsForMeasurement(this.currentBackgroundSkin,this._explicitWidth,this._explicitHeight,this._explicitMinWidth,this._explicitMinHeight,this._explicitMaxWidth,this._explicitMaxHeight,this._explicitBackgroundWidth,this._explicitBackgroundHeight,this._explicitBackgroundMinWidth,this._explicitBackgroundMinHeight,this._explicitBackgroundMaxWidth,this._explicitBackgroundMaxHeight);
			this.viewPortBounds.x = 0;
			this.viewPortBounds.y = 0;
			this.viewPortBounds.scrollX = 0;
			this.viewPortBounds.scrollY = 0;
			if(_local1 && this._autoSizeMode === "stage") {
				this.viewPortBounds.explicitWidth = this.stage.stageWidth;
			} else {
				this.viewPortBounds.explicitWidth = this._explicitWidth;
			}
			if(_local3 && this._autoSizeMode === "stage") {
				this.viewPortBounds.explicitHeight = this.stage.stageHeight;
			} else {
				this.viewPortBounds.explicitHeight = this._explicitHeight;
			}
			var _local4:Number = this._explicitMinWidth;
			if(_local2) {
				_local4 = 0;
			}
			var _local5:Number = this._explicitMinHeight;
			if(_local6) {
				_local5 = 0;
			}
			if(this.currentBackgroundSkin !== null) {
				if(this.currentBackgroundSkin.width > _local4) {
					_local4 = this.currentBackgroundSkin.width;
				}
				if(this.currentBackgroundSkin.height > _local5) {
					_local5 = this.currentBackgroundSkin.height;
				}
			}
			this.viewPortBounds.minWidth = _local4;
			this.viewPortBounds.minHeight = _local5;
			this.viewPortBounds.maxWidth = this._explicitMaxWidth;
			this.viewPortBounds.maxHeight = this._explicitMaxHeight;
		}
		
		protected function handleLayoutResult() : void {
			var _local1:Number = this._layoutResult.viewPortWidth;
			var _local2:Number = this._layoutResult.viewPortHeight;
			this.saveMeasurements(_local1,_local2,_local1,_local2);
		}
		
		protected function handleManualLayout() : void {
			var _local7:int = 0;
			var _local1:DisplayObject = null;
			var _local9:Number = NaN;
			var _local2:Number = NaN;
			var _local4:* = this.viewPortBounds.explicitWidth;
			if(_local4 !== _local4) {
				_local4 = 0;
			}
			var _local3:* = this.viewPortBounds.explicitHeight;
			if(_local3 !== _local3) {
				_local3 = 0;
			}
			var _local10:Boolean = this._ignoreChildChanges;
			this._ignoreChildChanges = true;
			var _local12:int = int(this.items.length);
			_local7 = 0;
			while(_local7 < _local12) {
				_local1 = this.items[_local7];
				if(!(_local1 is ILayoutDisplayObject && !ILayoutDisplayObject(_local1).includeInLayout)) {
					if(_local1 is IValidating) {
						IValidating(_local1).validate();
					}
					_local9 = _local1.x + _local1.width;
					_local2 = _local1.y + _local1.height;
					if(_local9 === _local9 && _local9 > _local4) {
						_local4 = _local9;
					}
					if(_local2 === _local2 && _local2 > _local3) {
						_local3 = _local2;
					}
				}
				_local7++;
			}
			this._ignoreChildChanges = _local10;
			this._layoutResult.contentX = 0;
			this._layoutResult.contentY = 0;
			this._layoutResult.contentWidth = _local4;
			this._layoutResult.contentHeight = _local3;
			var _local8:Number = this.viewPortBounds.minWidth;
			var _local11:Number = this.viewPortBounds.minHeight;
			if(_local4 < _local8) {
				_local4 = _local8;
			}
			if(_local3 < _local11) {
				_local3 = _local11;
			}
			var _local5:Number = this.viewPortBounds.maxWidth;
			var _local6:Number = this.viewPortBounds.maxHeight;
			if(_local4 > _local5) {
				_local4 = _local5;
			}
			if(_local3 > _local6) {
				_local3 = _local6;
			}
			this._layoutResult.viewPortWidth = _local4;
			this._layoutResult.viewPortHeight = _local3;
		}
		
		protected function validateChildren() : void {
			var _local2:int = 0;
			var _local1:DisplayObject = null;
			if(this.currentBackgroundSkin is IValidating) {
				IValidating(this.currentBackgroundSkin).validate();
			}
			var _local3:int = int(this.items.length);
			_local2 = 0;
			while(_local2 < _local3) {
				_local1 = this.items[_local2];
				if(_local1 is IValidating) {
					IValidating(_local1).validate();
				}
				_local2++;
			}
		}
		
		protected function refreshClipRect() : void {
			if(!this._clipContent) {
				return;
			}
			var _local1:Quad = this.mask as Quad;
			if(_local1) {
				_local1.x = 0;
				_local1.y = 0;
				_local1.width = this.actualWidth;
				_local1.height = this.actualHeight;
			} else {
				_local1 = new Quad(1,1,0xff00ff);
				_local1.width = this.actualWidth;
				_local1.height = this.actualHeight;
				this.mask = _local1;
			}
		}
		
		protected function layoutGroup_addedToStageHandler(event:Event) : void {
			if(this._autoSizeMode == "stage") {
				this.stage.addEventListener("resize",stage_resizeHandler);
			}
		}
		
		protected function layoutGroup_removedFromStageHandler(event:Event) : void {
			this.stage.removeEventListener("resize",stage_resizeHandler);
		}
		
		protected function layout_changeHandler(event:Event) : void {
			this.invalidate("layout");
		}
		
		protected function child_resizeHandler(event:Event) : void {
			if(this._ignoreChildChanges) {
				return;
			}
			this.invalidate("layout");
		}
		
		protected function child_layoutDataChangeHandler(event:Event) : void {
			if(this._ignoreChildChanges) {
				return;
			}
			this.invalidate("layout");
		}
		
		protected function stage_resizeHandler(event:Event) : void {
			this.invalidate("layout");
		}
	}
}

