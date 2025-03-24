package feathers.core {
	import flash.utils.Dictionary;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	import starling.display.Stage;
	import starling.events.Event;
	import starling.events.ResizeEvent;
	
	public class DefaultPopUpManager implements IPopUpManager {
		protected var _popUps:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
		
		protected var _popUpToOverlay:Dictionary = new Dictionary(true);
		
		protected var _popUpToFocusManager:Dictionary = new Dictionary(true);
		
		protected var _centeredPopUps:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
		
		protected var _overlayFactory:Function = defaultOverlayFactory;
		
		protected var _ignoreRemoval:Boolean = false;
		
		protected var _root:DisplayObjectContainer;
		
		public function DefaultPopUpManager(root:DisplayObjectContainer = null) {
			super();
			this.root = root;
		}
		
		public static function defaultOverlayFactory() : DisplayObject {
			var _local1:Quad = new Quad(100,100,0);
			_local1.alpha = 0;
			return _local1;
		}
		
		public function get overlayFactory() : Function {
			return this._overlayFactory;
		}
		
		public function set overlayFactory(value:Function) : void {
			this._overlayFactory = value;
		}
		
		public function get root() : DisplayObjectContainer {
			return this._root;
		}
		
		public function set root(value:DisplayObjectContainer) : void {
			var _local6:int = 0;
			var _local3:DisplayObject = null;
			var _local4:DisplayObject = null;
			if(this._root == value) {
				return;
			}
			var _local5:int = int(this._popUps.length);
			var _local2:Boolean = this._ignoreRemoval;
			this._ignoreRemoval = true;
			_local6 = 0;
			while(_local6 < _local5) {
				_local3 = this._popUps[_local6];
				_local4 = DisplayObject(_popUpToOverlay[_local3]);
				_local3.removeFromParent(false);
				if(_local4) {
					_local4.removeFromParent(false);
				}
				_local6++;
			}
			this._ignoreRemoval = _local2;
			this._root = value;
			_local6 = 0;
			while(_local6 < _local5) {
				_local3 = this._popUps[_local6];
				_local4 = DisplayObject(_popUpToOverlay[_local3]);
				if(_local4) {
					this._root.addChild(_local4);
				}
				this._root.addChild(_local3);
				_local6++;
			}
		}
		
		public function addPopUp(popUp:DisplayObject, isModal:Boolean = true, isCentered:Boolean = true, customOverlayFactory:Function = null) : DisplayObject {
			var _local5:DisplayObject = null;
			if(isModal) {
				if(customOverlayFactory == null) {
					customOverlayFactory = this._overlayFactory;
				}
				if(customOverlayFactory == null) {
					customOverlayFactory = defaultOverlayFactory;
				}
				_local5 = customOverlayFactory();
				_local5.width = this._root.stage.stageWidth;
				_local5.height = this._root.stage.stageHeight;
				this._root.addChild(_local5);
				this._popUpToOverlay[popUp] = _local5;
			}
			this._popUps.push(popUp);
			this._root.addChild(popUp);
			popUp.addEventListener("removedFromStage",popUp_removedFromStageHandler);
			if(this._popUps.length == 1) {
				this._root.stage.addEventListener("resize",stage_resizeHandler);
			}
			if(isModal && FocusManager.isEnabledForStage(this._root.stage) && popUp is DisplayObjectContainer) {
				this._popUpToFocusManager[popUp] = FocusManager.pushFocusManager(DisplayObjectContainer(popUp));
			}
			if(isCentered) {
				if(popUp is IFeathersControl) {
					popUp.addEventListener("resize",popUp_resizeHandler);
				}
				this._centeredPopUps.push(popUp);
				this.centerPopUp(popUp);
			}
			return popUp;
		}
		
		public function removePopUp(popUp:DisplayObject, dispose:Boolean = false) : DisplayObject {
			var _local3:int = int(this._popUps.indexOf(popUp));
			if(_local3 < 0) {
				throw new ArgumentError("Display object is not a pop-up.");
			}
			popUp.removeFromParent(dispose);
			return popUp;
		}
		
		public function isPopUp(popUp:DisplayObject) : Boolean {
			return this._popUps.indexOf(popUp) >= 0;
		}
		
		public function isTopLevelPopUp(popUp:DisplayObject) : Boolean {
			var _local4:* = 0;
			var _local2:DisplayObject = null;
			var _local3:DisplayObject = null;
			var _local5:int;
			_local4 = _local5 = this._popUps.length - 1;
			while(_local4 >= 0) {
				_local2 = this._popUps[_local4];
				if(_local2 == popUp) {
					return true;
				}
				_local3 = this._popUpToOverlay[_local2] as DisplayObject;
				if(_local3) {
					return false;
				}
				_local4--;
			}
			return false;
		}
		
		public function centerPopUp(popUp:DisplayObject) : void {
			var _local2:Stage = this._root.stage;
			if(popUp is IValidating) {
				IValidating(popUp).validate();
			}
			popUp.x = Math.round((_local2.stageWidth - popUp.width) / 2);
			popUp.y = Math.round((_local2.stageHeight - popUp.height) / 2);
		}
		
		protected function popUp_resizeHandler(event:Event) : void {
			var _local2:DisplayObject = DisplayObject(event.currentTarget);
			var _local3:int = int(this._centeredPopUps.indexOf(_local2));
			if(_local3 < 0) {
				return;
			}
			this.centerPopUp(_local2);
		}
		
		protected function popUp_removedFromStageHandler(event:Event) : void {
			if(this._ignoreRemoval) {
				return;
			}
			var _local2:DisplayObject = DisplayObject(event.currentTarget);
			_local2.removeEventListener("removedFromStage",popUp_removedFromStageHandler);
			var _local5:int = int(this._popUps.indexOf(_local2));
			this._popUps.removeAt(_local5);
			var _local4:DisplayObject = DisplayObject(this._popUpToOverlay[_local2]);
			if(_local4) {
				_local4.removeFromParent(true);
				delete _popUpToOverlay[_local2];
			}
			var _local3:IFocusManager = this._popUpToFocusManager[_local2] as IFocusManager;
			if(_local3) {
				delete this._popUpToFocusManager[_local2];
				FocusManager.removeFocusManager(_local3);
			}
			_local5 = int(this._centeredPopUps.indexOf(_local2));
			if(_local5 >= 0) {
				if(_local2 is IFeathersControl) {
					_local2.removeEventListener("resize",popUp_resizeHandler);
				}
				this._centeredPopUps.removeAt(_local5);
			}
			if(_popUps.length == 0) {
				this._root.stage.removeEventListener("resize",stage_resizeHandler);
			}
		}
		
		protected function stage_resizeHandler(event:ResizeEvent) : void {
			var _local6:int = 0;
			var _local2:DisplayObject = null;
			var _local4:DisplayObject = null;
			var _local3:Stage = this._root.stage;
			var _local5:int = int(this._popUps.length);
			_local6 = 0;
			while(_local6 < _local5) {
				_local2 = this._popUps[_local6];
				_local4 = DisplayObject(this._popUpToOverlay[_local2]);
				if(_local4) {
					_local4.width = _local3.stageWidth;
					_local4.height = _local3.stageHeight;
				}
				_local6++;
			}
			_local5 = int(this._centeredPopUps.length);
			_local6 = 0;
			while(_local6 < _local5) {
				_local2 = this._centeredPopUps[_local6];
				centerPopUp(_local2);
				_local6++;
			}
		}
	}
}

