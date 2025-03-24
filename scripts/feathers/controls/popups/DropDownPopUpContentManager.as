package feathers.controls.popups {
	import feathers.core.IFeathersControl;
	import feathers.core.IValidating;
	import feathers.core.PopUpManager;
	import feathers.core.ValidationQueue;
	import feathers.utils.display.getDisplayObjectDepthFromStage;
	import feathers.utils.display.stageToStarling;
	import flash.errors.IllegalOperationError;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Stage;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.events.ResizeEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	public class DropDownPopUpContentManager extends EventDispatcher implements IPopUpContentManager {
		public static const PRIMARY_DIRECTION_DOWN:String = "down";
		
		public static const PRIMARY_DIRECTION_UP:String = "up";
		
		private static const HELPER_RECTANGLE:Rectangle = new Rectangle();
		
		protected var content:DisplayObject;
		
		protected var source:DisplayObject;
		
		protected var _isModal:Boolean = false;
		
		protected var _overlayFactory:Function;
		
		protected var _gap:Number = 0;
		
		protected var _primaryDirection:String = "bottom";
		
		protected var _fitContentMinWidthToOrigin:Boolean = true;
		
		protected var _lastGlobalX:Number;
		
		protected var _lastGlobalY:Number;
		
		public function DropDownPopUpContentManager() {
			super();
		}
		
		public function get isOpen() : Boolean {
			return this.content !== null;
		}
		
		public function get isModal() : Boolean {
			return this._isModal;
		}
		
		public function set isModal(value:Boolean) : void {
			this._isModal = value;
		}
		
		public function get overlayFactory() : Function {
			return this._overlayFactory;
		}
		
		public function set overlayFactory(value:Function) : void {
			this._overlayFactory = value;
		}
		
		public function get gap() : Number {
			return this._gap;
		}
		
		public function set gap(value:Number) : void {
			this._gap = value;
		}
		
		public function get primaryDirection() : String {
			return this._primaryDirection;
		}
		
		public function set primaryDirection(value:String) : void {
			if(value === "up") {
				value = "top";
			} else if(value === "down") {
				value = "bottom";
			}
			this._primaryDirection = value;
		}
		
		public function get fitContentMinWidthToOrigin() : Boolean {
			return this._fitContentMinWidthToOrigin;
		}
		
		public function set fitContentMinWidthToOrigin(value:Boolean) : void {
			this._fitContentMinWidthToOrigin = value;
		}
		
		public function open(content:DisplayObject, source:DisplayObject) : void {
			if(this.isOpen) {
				throw new IllegalOperationError("Pop-up content is already open. Close the previous content before opening new content.");
			}
			this.content = content;
			this.source = source;
			PopUpManager.addPopUp(this.content,this._isModal,false,this._overlayFactory);
			if(this.content is IFeathersControl) {
				this.content.addEventListener("resize",content_resizeHandler);
			}
			this.content.addEventListener("removedFromStage",content_removedFromStageHandler);
			this.layout();
			var _local3:Stage = this.source.stage;
			_local3.addEventListener("touch",stage_touchHandler);
			_local3.addEventListener("resize",stage_resizeHandler);
			_local3.addEventListener("enterFrame",stage_enterFrameHandler);
			var _local4:int = -getDisplayObjectDepthFromStage(this.content);
			Starling.current.nativeStage.addEventListener("keyDown",nativeStage_keyDownHandler,false,_local4,true);
			this.dispatchEventWith("open");
		}
		
		public function close() : void {
			if(!this.isOpen) {
				return;
			}
			var _local3:DisplayObject = this.content;
			this.content = null;
			this.source = null;
			var _local2:Stage = _local3.stage;
			_local2.removeEventListener("touch",stage_touchHandler);
			_local2.removeEventListener("resize",stage_resizeHandler);
			_local2.removeEventListener("enterFrame",stage_enterFrameHandler);
			var _local1:Starling = stageToStarling(_local2);
			_local1.nativeStage.removeEventListener("keyDown",nativeStage_keyDownHandler);
			if(_local3 is IFeathersControl) {
				_local3.removeEventListener("resize",content_resizeHandler);
			}
			_local3.removeEventListener("removedFromStage",content_removedFromStageHandler);
			if(_local3.parent) {
				_local3.removeFromParent(false);
			}
			this.dispatchEventWith("close");
		}
		
		public function dispose() : void {
			this.close();
		}
		
		protected function layout() : void {
			if(this.source is IValidating) {
				IValidating(this.source).validate();
				if(!this.isOpen) {
					return;
				}
			}
			var _local7:Number = this.source.width;
			var _local1:Boolean = false;
			var _local4:IFeathersControl = this.content as IFeathersControl;
			if(this._fitContentMinWidthToOrigin && _local4 && _local4.minWidth < _local7) {
				_local4.minWidth = _local7;
				_local1 = true;
			}
			if(this.content is IValidating) {
				_local4.validate();
			}
			if(!_local1 && this._fitContentMinWidthToOrigin && this.content.width < _local7) {
				this.content.width = _local7;
			}
			var _local5:Stage = this.source.stage;
			var _local3:Starling = stageToStarling(_local5);
			var _local6:ValidationQueue = ValidationQueue.forStarling(_local3);
			if(_local6 && !_local6.isValidating) {
				_local6.advanceTime(0);
			}
			var _local2:Rectangle = this.source.getBounds(_local5);
			this._lastGlobalX = _local2.x;
			this._lastGlobalY = _local2.y;
			var _local10:Number = _local5.stageHeight - this.content.height - (_local2.y + _local2.height + this._gap);
			if(this._primaryDirection == "bottom" && _local10 >= 0) {
				layoutBelow(_local2);
				return;
			}
			var _local8:Number = _local2.y - this._gap - this.content.height;
			if(_local8 >= 0) {
				layoutAbove(_local2);
				return;
			}
			if(this._primaryDirection == "top" && _local10 >= 0) {
				layoutBelow(_local2);
				return;
			}
			if(_local8 >= _local10) {
				layoutAbove(_local2);
			} else {
				layoutBelow(_local2);
			}
			var _local9:Number = _local5.stageHeight - (_local2.y + _local2.height);
			if(_local4) {
				if(_local4.maxHeight > _local9) {
					_local4.maxHeight = _local9;
				}
			} else if(this.content.height > _local9) {
				this.content.height = _local9;
			}
		}
		
		protected function layoutAbove(globalOrigin:Rectangle) : void {
			var _local3:Number = globalOrigin.x;
			var _local2:* = this.content.stage.stageWidth - this.content.width;
			if(_local2 > _local3) {
				_local2 = _local3;
			}
			if(_local2 < 0) {
				_local2 = 0;
			}
			this.content.x = _local2;
			this.content.y = globalOrigin.y - this.content.height - this._gap;
		}
		
		protected function layoutBelow(globalOrigin:Rectangle) : void {
			var _local3:Number = globalOrigin.x;
			var _local2:* = this.content.stage.stageWidth - this.content.width;
			if(_local2 > _local3) {
				_local2 = _local3;
			}
			if(_local2 < 0) {
				_local2 = 0;
			}
			this.content.x = _local2;
			this.content.y = globalOrigin.y + globalOrigin.height + this._gap;
		}
		
		protected function content_resizeHandler(event:Event) : void {
			this.layout();
		}
		
		protected function stage_enterFrameHandler(event:Event) : void {
			this.source.getBounds(this.source.stage,HELPER_RECTANGLE);
			if(HELPER_RECTANGLE.x != this._lastGlobalX || HELPER_RECTANGLE.y != this._lastGlobalY) {
				this.layout();
			}
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
			var _local4:DisplayObject = DisplayObject(event.target);
			if(this.content == _local4 || this.content is DisplayObjectContainer && Boolean(DisplayObjectContainer(this.content).contains(_local4))) {
				return;
			}
			if(this.source == _local4 || this.source is DisplayObjectContainer && Boolean(DisplayObjectContainer(this.source).contains(_local4))) {
				return;
			}
			if(!PopUpManager.isTopLevelPopUp(this.content)) {
				return;
			}
			var _local2:Stage = Stage(event.currentTarget);
			var _local3:Touch = event.getTouch(_local2,"began");
			if(!_local3) {
				return;
			}
			this.close();
		}
	}
}

