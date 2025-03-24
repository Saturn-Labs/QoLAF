package feathers.controls.popups {
	import feathers.core.IFeathersControl;
	import feathers.core.IValidating;
	import feathers.core.PopUpManager;
	import feathers.utils.display.getDisplayObjectDepthFromStage;
	import flash.errors.IllegalOperationError;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Stage;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.events.ResizeEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	public class VerticalCenteredPopUpContentManager extends EventDispatcher implements IPopUpContentManager {
		private static const HELPER_POINT:Point = new Point();
		
		public var marginTop:Number = 0;
		
		public var marginRight:Number = 0;
		
		public var marginBottom:Number = 0;
		
		public var marginLeft:Number = 0;
		
		protected var _overlayFactory:Function = null;
		
		protected var content:DisplayObject;
		
		protected var touchPointID:int = -1;
		
		public function VerticalCenteredPopUpContentManager() {
			super();
		}
		
		public function get margin() : Number {
			return this.marginTop;
		}
		
		public function set margin(value:Number) : void {
			this.marginTop = 0;
			this.marginRight = 0;
			this.marginBottom = 0;
			this.marginLeft = 0;
		}
		
		public function get overlayFactory() : Function {
			return this._overlayFactory;
		}
		
		public function set overlayFactory(value:Function) : void {
			this._overlayFactory = value;
		}
		
		public function get isOpen() : Boolean {
			return this.content !== null;
		}
		
		public function open(content:DisplayObject, source:DisplayObject) : void {
			if(this.isOpen) {
				throw new IllegalOperationError("Pop-up content is already open. Close the previous content before opening new content.");
			}
			this.content = content;
			PopUpManager.addPopUp(this.content,true,false,this._overlayFactory);
			if(this.content is IFeathersControl) {
				this.content.addEventListener("resize",content_resizeHandler);
			}
			this.content.addEventListener("removedFromStage",content_removedFromStageHandler);
			this.layout();
			var _local3:Stage = Starling.current.stage;
			_local3.addEventListener("touch",stage_touchHandler);
			_local3.addEventListener("resize",stage_resizeHandler);
			var _local4:int = -getDisplayObjectDepthFromStage(this.content);
			Starling.current.nativeStage.addEventListener("keyDown",nativeStage_keyDownHandler,false,_local4,true);
			this.dispatchEventWith("open");
		}
		
		public function close() : void {
			if(!this.isOpen) {
				return;
			}
			var _local2:DisplayObject = this.content;
			this.content = null;
			var _local1:Stage = Starling.current.stage;
			_local1.removeEventListener("touch",stage_touchHandler);
			_local1.removeEventListener("resize",stage_resizeHandler);
			Starling.current.nativeStage.removeEventListener("keyDown",nativeStage_keyDownHandler);
			if(_local2 is IFeathersControl) {
				_local2.removeEventListener("resize",content_resizeHandler);
			}
			_local2.removeEventListener("removedFromStage",content_removedFromStageHandler);
			if(_local2.parent) {
				_local2.removeFromParent(false);
			}
			this.dispatchEventWith("close");
		}
		
		public function dispose() : void {
			this.close();
		}
		
		protected function layout() : void {
			var _local3:IFeathersControl = null;
			var _local2:Stage = Starling.current.stage;
			var _local5:Number = _local2.stageWidth;
			if(_local5 > _local2.stageHeight) {
				_local5 = _local2.stageHeight;
			}
			_local5 -= this.marginLeft + this.marginRight;
			var _local4:Number = _local2.stageHeight - this.marginTop - this.marginBottom;
			var _local1:Boolean = false;
			if(this.content is IFeathersControl) {
				_local3 = IFeathersControl(this.content);
				_local3.minWidth = _local5;
				_local3.maxWidth = _local5;
				_local3.maxHeight = _local4;
				_local1 = true;
			}
			if(this.content is IValidating) {
				IValidating(this.content).validate();
			}
			if(!_local1) {
				if(this.content.width > _local5) {
					this.content.width = _local5;
				}
				if(this.content.height > _local4) {
					this.content.height = _local4;
				}
			}
			this.content.x = Math.round((_local2.stageWidth - this.content.width) / 2);
			this.content.y = Math.round((_local2.stageHeight - this.content.height) / 2);
		}
		
		protected function content_resizeHandler(event:Event) : void {
			this.layout();
		}
		
		protected function content_removedFromStageHandler(event:Event) : void {
			this.close();
		}
		
		protected function nativeStage_keyDownHandler(event:KeyboardEvent) : void {
			if(event.isDefaultPrevented()) {
				return;
			}
			if(event.keyCode != 16777238 && event.keyCode != 27) {
				return;
			}
			event.preventDefault();
			this.close();
		}
		
		protected function stage_resizeHandler(event:ResizeEvent) : void {
			this.layout();
		}
		
		protected function stage_touchHandler(event:TouchEvent) : void {
			var _local4:Touch = null;
			var _local5:DisplayObject = null;
			var _local3:* = false;
			if(!PopUpManager.isTopLevelPopUp(this.content)) {
				return;
			}
			var _local2:Stage = Starling.current.stage;
			if(this.touchPointID >= 0) {
				_local4 = event.getTouch(_local2,"ended",this.touchPointID);
				if(!_local4) {
					return;
				}
				_local4.getLocation(_local2,HELPER_POINT);
				_local5 = _local2.hitTest(HELPER_POINT);
				_local3 = false;
				if(this.content is DisplayObjectContainer) {
					_local3 = Boolean(DisplayObjectContainer(this.content).contains(_local5));
				} else {
					_local3 = this.content == _local5;
				}
				if(!_local3) {
					this.touchPointID = -1;
					this.close();
				}
			} else {
				_local4 = event.getTouch(_local2,"began");
				if(!_local4) {
					return;
				}
				_local4.getLocation(_local2,HELPER_POINT);
				_local5 = _local2.hitTest(HELPER_POINT);
				_local3 = false;
				if(this.content is DisplayObjectContainer) {
					_local3 = Boolean(DisplayObjectContainer(this.content).contains(_local5));
				} else {
					_local3 = this.content == _local5;
				}
				if(_local3) {
					return;
				}
				this.touchPointID = _local4.id;
			}
		}
	}
}

