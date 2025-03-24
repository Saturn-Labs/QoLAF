package feathers.controls.supportClasses {
	import feathers.controls.IScreen;
	import feathers.core.FeathersControl;
	import feathers.core.IFeathersControl;
	import feathers.core.IMeasureDisplayObject;
	import feathers.core.IValidating;
	import feathers.utils.skins.resetFluidChildDimensionsForMeasurement;
	import flash.errors.IllegalOperationError;
	import flash.utils.getDefinitionByName;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.errors.AbstractMethodError;
	import starling.events.Event;
	
	public class BaseScreenNavigator extends FeathersControl {
		protected static var SIGNAL_TYPE:Class;
		
		public static const AUTO_SIZE_MODE_STAGE:String = "stage";
		
		public static const AUTO_SIZE_MODE_CONTENT:String = "content";
		
		protected var _activeScreenID:String;
		
		protected var _activeScreen:DisplayObject;
		
		protected var _activeScreenExplicitWidth:Number;
		
		protected var _activeScreenExplicitHeight:Number;
		
		protected var _activeScreenExplicitMinWidth:Number;
		
		protected var _activeScreenExplicitMinHeight:Number;
		
		protected var _activeScreenExplicitMaxWidth:Number;
		
		protected var _activeScreenExplicitMaxHeight:Number;
		
		protected var _screens:Object = {};
		
		protected var _previousScreenInTransitionID:String;
		
		protected var _previousScreenInTransition:DisplayObject;
		
		protected var _nextScreenID:String = null;
		
		protected var _nextScreenTransition:Function = null;
		
		protected var _clearAfterTransition:Boolean = false;
		
		protected var _clipContent:Boolean = false;
		
		protected var _autoSizeMode:String = "stage";
		
		protected var _waitingTransition:Function;
		
		private var _waitingForTransitionFrameCount:int = 1;
		
		protected var _isTransitionActive:Boolean = false;
		
		public function BaseScreenNavigator() {
			super();
			if(Object(this).constructor == BaseScreenNavigator) {
				throw new Error("FeathersControl is an abstract class. For a lightweight Feathers wrapper, use feathers.controls.LayoutGroup.");
			}
			if(!SIGNAL_TYPE) {
				try {
					SIGNAL_TYPE = Class(getDefinitionByName("org.osflash.signals.ISignal"));
				}
				catch(error:Error) {
				}
			}
			this.addEventListener("addedToStage",screenNavigator_addedToStageHandler);
			this.addEventListener("removedFromStage",screenNavigator_removedFromStageHandler);
		}
		
		protected static function defaultTransition(oldScreen:DisplayObject, newScreen:DisplayObject, completeCallback:Function) : void {
			completeCallback();
		}
		
		public function get activeScreenID() : String {
			return this._activeScreenID;
		}
		
		public function get activeScreen() : DisplayObject {
			return this._activeScreen;
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
			this.invalidate("styles");
		}
		
		public function get autoSizeMode() : String {
			return this._autoSizeMode;
		}
		
		public function set autoSizeMode(value:String) : void {
			if(this._autoSizeMode == value) {
				return;
			}
			this._autoSizeMode = value;
			if(this._activeScreen) {
				if(this._autoSizeMode == "content") {
					this._activeScreen.addEventListener("resize",activeScreen_resizeHandler);
				} else {
					this._activeScreen.removeEventListener("resize",activeScreen_resizeHandler);
				}
			}
			this.invalidate("size");
		}
		
		public function get isTransitionActive() : Boolean {
			return this._isTransitionActive;
		}
		
		override public function dispose() : void {
			if(this._activeScreen) {
				this.cleanupActiveScreen();
				this._activeScreen = null;
				this._activeScreenID = null;
			}
			super.dispose();
		}
		
		public function removeAllScreens() : void {
			if(this._isTransitionActive) {
				throw new IllegalOperationError("Cannot remove all screens while a transition is active.");
			}
			if(this._activeScreen) {
				this.clearScreenInternal(null);
				this.dispatchEventWith("clear");
			}
			for(var _local1 in this._screens) {
				delete this._screens[_local1];
			}
		}
		
		public function hasScreen(id:String) : Boolean {
			return this._screens.hasOwnProperty(id);
		}
		
		public function getScreenIDs(result:Vector.<String> = null) : Vector.<String> {
			if(result) {
				result.length = 0;
			} else {
				result = new Vector.<String>(0);
			}
			var _local3:int = 0;
			for(var _local2 in this._screens) {
				result[_local3] = _local2;
				_local3++;
			}
			return result;
		}
		
		override protected function draw() : void {
			var _local1:Boolean = this.isInvalid("size");
			var _local2:Boolean = this.isInvalid("selected");
			var _local3:Boolean = this.isInvalid("styles");
			_local1 = this.autoSizeIfNeeded() || _local1;
			if(_local1 || _local2) {
				if(this._activeScreen) {
					if(this._activeScreen.width != this.actualWidth) {
						this._activeScreen.width = this.actualWidth;
					}
					if(this._activeScreen.height != this.actualHeight) {
						this._activeScreen.height = this.actualHeight;
					}
				}
			}
			if(_local3 || _local1) {
				this.refreshMask();
			}
		}
		
		protected function autoSizeIfNeeded() : Boolean {
			var _local3:* = this._explicitWidth !== this._explicitWidth;
			var _local8:* = this._explicitHeight !== this._explicitHeight;
			var _local4:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local10:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local3 && !_local8 && !_local4 && !_local10) {
				return false;
			}
			var _local9:Boolean = this._autoSizeMode === "content" || this.stage === null;
			var _local7:IMeasureDisplayObject = this._activeScreen as IMeasureDisplayObject;
			if(_local9) {
				if(this._activeScreen !== null) {
					resetFluidChildDimensionsForMeasurement(this._activeScreen,this._explicitWidth,this._explicitHeight,this._explicitMinWidth,this._explicitMinHeight,this._explicitMaxWidth,this._explicitMaxHeight,this._activeScreenExplicitWidth,this._activeScreenExplicitHeight,this._activeScreenExplicitMinWidth,this._activeScreenExplicitMinHeight,this._activeScreenExplicitMaxWidth,this._activeScreenExplicitMaxHeight);
					if(this._activeScreen is IValidating) {
						IValidating(this._activeScreen).validate();
					}
				}
			}
			var _local2:Number = this._explicitWidth;
			if(_local3) {
				if(_local9) {
					if(this._activeScreen !== null) {
						_local2 = this._activeScreen.width;
					} else {
						_local2 = 0;
					}
				} else {
					_local2 = this.stage.stageWidth;
				}
			}
			var _local5:Number = this._explicitHeight;
			if(_local8) {
				if(_local9) {
					if(this._activeScreen !== null) {
						_local5 = this._activeScreen.height;
					} else {
						_local5 = 0;
					}
				} else {
					_local5 = this.stage.stageHeight;
				}
			}
			var _local1:Number = this._explicitMinWidth;
			if(_local4) {
				if(_local9) {
					if(_local7 !== null) {
						_local1 = _local7.minWidth;
					} else if(this._activeScreen !== null) {
						_local1 = this._activeScreen.width;
					} else {
						_local1 = 0;
					}
				} else {
					_local1 = this.stage.stageWidth;
				}
			}
			var _local6:Number = this._explicitMinHeight;
			if(_local10) {
				if(_local9) {
					if(_local7 !== null) {
						_local6 = _local7.minHeight;
					} else if(this._activeScreen !== null) {
						_local6 = this._activeScreen.height;
					} else {
						_local6 = 0;
					}
				} else {
					_local6 = this.stage.stageHeight;
				}
			}
			return this.saveMeasurements(_local2,_local5,_local1,_local6);
		}
		
		protected function addScreenInternal(id:String, item:IScreenNavigatorItem) : void {
			if(this._screens.hasOwnProperty(id)) {
				throw new ArgumentError("Screen with id \'" + id + "\' already defined. Cannot add two screens with the same id.");
			}
			this._screens[id] = item;
		}
		
		protected function refreshMask() : void {
			if(!this._clipContent) {
				return;
			}
			var _local1:DisplayObject = this.mask as Quad;
			if(_local1) {
				_local1.width = this.actualWidth;
				_local1.height = this.actualHeight;
			} else {
				_local1 = new Quad(1,1,0xff00ff);
				_local1.width = this.actualWidth;
				_local1.height = this.actualHeight;
				this.mask = _local1;
			}
		}
		
		protected function removeScreenInternal(id:String) : IScreenNavigatorItem {
			if(!this._screens.hasOwnProperty(id)) {
				throw new ArgumentError("Screen \'" + id + "\' cannot be removed because it has not been added.");
			}
			if(this._isTransitionActive && (id == this._previousScreenInTransitionID || id == this._activeScreenID)) {
				throw new IllegalOperationError("Cannot remove a screen while it is transitioning in or out.");
			}
			if(this._activeScreenID == id) {
				this.clearScreenInternal(null);
				this.dispatchEventWith("clear");
			}
			var _local2:IScreenNavigatorItem = IScreenNavigatorItem(this._screens[id]);
			delete this._screens[id];
			return _local2;
		}
		
		protected function showScreenInternal(id:String, transition:Function, properties:Object = null) : DisplayObject {
			var _local7:IScreen = null;
			if(!this.hasScreen(id)) {
				throw new ArgumentError("Screen with id \'" + id + "\' cannot be shown because it has not been defined.");
			}
			if(this._isTransitionActive) {
				this._nextScreenID = id;
				this._nextScreenTransition = transition;
				this._clearAfterTransition = false;
				return null;
			}
			this._previousScreenInTransition = this._activeScreen;
			this._previousScreenInTransitionID = this._activeScreenID;
			if(this._activeScreen !== null) {
				this.cleanupActiveScreen();
			}
			this._isTransitionActive = true;
			var _local4:IScreenNavigatorItem = IScreenNavigatorItem(this._screens[id]);
			this._activeScreen = _local4.getScreen();
			this._activeScreenID = id;
			for(var _local5 in properties) {
				this._activeScreen[_local5] = properties[_local5];
			}
			if(this._activeScreen is IScreen) {
				_local7 = IScreen(this._activeScreen);
				_local7.screenID = this._activeScreenID;
				_local7.owner = this;
			}
			if(this._autoSizeMode === "content" || !this.stage) {
				this._activeScreen.addEventListener("resize",activeScreen_resizeHandler);
			}
			this.prepareActiveScreen();
			var _local8:* = this._previousScreenInTransition === this._activeScreen;
			this.addChild(this._activeScreen);
			if(this._activeScreen is IFeathersControl) {
				IFeathersControl(this._activeScreen).initializeNow();
			}
			var _local6:IMeasureDisplayObject = this._activeScreen as IMeasureDisplayObject;
			if(_local6 !== null) {
				this._activeScreenExplicitWidth = _local6.explicitWidth;
				this._activeScreenExplicitHeight = _local6.explicitHeight;
				this._activeScreenExplicitMinWidth = _local6.explicitMinWidth;
				this._activeScreenExplicitMinHeight = _local6.explicitMinHeight;
				this._activeScreenExplicitMaxWidth = _local6.explicitMaxWidth;
				this._activeScreenExplicitMaxHeight = _local6.explicitMaxHeight;
			} else {
				this._activeScreenExplicitWidth = this._activeScreen.width;
				this._activeScreenExplicitHeight = this._activeScreen.height;
				this._activeScreenExplicitMinWidth = this._activeScreenExplicitWidth;
				this._activeScreenExplicitMinHeight = this._activeScreenExplicitHeight;
				this._activeScreenExplicitMaxWidth = this._activeScreenExplicitWidth;
				this._activeScreenExplicitMaxHeight = this._activeScreenExplicitHeight;
			}
			this.invalidate("selected");
			if(this._validationQueue && !this._validationQueue.isValidating) {
				this._validationQueue.advanceTime(0);
			} else if(!this._isValidating) {
				this.validate();
			}
			if(_local8) {
				this._previousScreenInTransition = null;
				this._previousScreenInTransitionID = null;
				this._isTransitionActive = false;
			} else {
				this.dispatchEventWith("transitionStart");
				this._activeScreen.dispatchEventWith("transitionInStart");
				if(this._previousScreenInTransition !== null) {
					this._previousScreenInTransition.dispatchEventWith("transitionOutStart");
				}
				if(transition !== null) {
					this._activeScreen.visible = false;
					this._waitingForTransitionFrameCount = 0;
					this._waitingTransition = transition;
					this.addEventListener("enterFrame",waitingForTransition_enterFrameHandler);
				} else {
					defaultTransition(this._previousScreenInTransition,this._activeScreen,transitionComplete);
				}
			}
			this.dispatchEventWith("change");
			return this._activeScreen;
		}
		
		protected function clearScreenInternal(transition:Function = null) : void {
			if(this._activeScreen === null) {
				return;
			}
			if(this._isTransitionActive) {
				this._nextScreenID = null;
				this._clearAfterTransition = true;
				this._nextScreenTransition = transition;
				return;
			}
			this.cleanupActiveScreen();
			this._isTransitionActive = true;
			this._previousScreenInTransition = this._activeScreen;
			this._previousScreenInTransitionID = this._activeScreenID;
			this._activeScreen = null;
			this._activeScreenID = null;
			this.dispatchEventWith("transitionStart");
			this._previousScreenInTransition.dispatchEventWith("transitionOutStart");
			if(transition !== null) {
				this._waitingForTransitionFrameCount = 0;
				this._waitingTransition = transition;
				this.addEventListener("enterFrame",waitingForTransition_enterFrameHandler);
			} else {
				defaultTransition(this._previousScreenInTransition,this._activeScreen,transitionComplete);
			}
			this.invalidate("selected");
		}
		
		protected function prepareActiveScreen() : void {
			throw new AbstractMethodError();
		}
		
		protected function cleanupActiveScreen() : void {
			throw new AbstractMethodError();
		}
		
		protected function transitionComplete(cancelTransition:Boolean = false) : void {
			var _local2:IScreenNavigatorItem = null;
			var _local4:IMeasureDisplayObject = null;
			var _local3:DisplayObject = null;
			var _local7:DisplayObject = null;
			var _local6:String = null;
			var _local5:IScreen = null;
			this._isTransitionActive = this._clearAfterTransition || this._nextScreenID;
			if(cancelTransition) {
				if(this._activeScreen !== null) {
					_local2 = IScreenNavigatorItem(this._screens[this._activeScreenID]);
					this.cleanupActiveScreen();
					this.removeChild(this._activeScreen,_local2.canDispose);
					if(!_local2.canDispose) {
						this._activeScreen.width = this._activeScreenExplicitWidth;
						this._activeScreen.height = this._activeScreenExplicitHeight;
						_local4 = this._activeScreen as IMeasureDisplayObject;
						if(_local4 !== null) {
							_local4.minWidth = this._activeScreenExplicitMinWidth;
							_local4.minHeight = this._activeScreenExplicitMinHeight;
						}
					}
				}
				this._activeScreen = this._previousScreenInTransition;
				this._activeScreenID = this._previousScreenInTransitionID;
				this._previousScreenInTransition = null;
				this._previousScreenInTransitionID = null;
				this.prepareActiveScreen();
				this.dispatchEventWith("transitionCancel");
			} else {
				_local3 = this._activeScreen;
				_local7 = this._previousScreenInTransition;
				_local6 = this._previousScreenInTransitionID;
				_local2 = IScreenNavigatorItem(this._screens[_local6]);
				this._previousScreenInTransition = null;
				this._previousScreenInTransitionID = null;
				if(_local7 !== null) {
					_local7.dispatchEventWith("transitionOutComplete");
				}
				if(_local3 !== null) {
					_local3.dispatchEventWith("transitionInComplete");
				}
				this.dispatchEventWith("transitionComplete");
				if(_local7 !== null) {
					if(_local7 is IScreen) {
						_local5 = IScreen(_local7);
						_local5.screenID = null;
						_local5.owner = null;
					}
					_local7.removeEventListener("resize",activeScreen_resizeHandler);
					this.removeChild(_local7,_local2.canDispose);
				}
			}
			this._isTransitionActive = false;
			if(this._clearAfterTransition) {
				this.clearScreenInternal(this._nextScreenTransition);
			} else if(this._nextScreenID !== null) {
				this.showScreenInternal(this._nextScreenID,this._nextScreenTransition);
			}
			this._nextScreenID = null;
			this._nextScreenTransition = null;
			this._clearAfterTransition = false;
		}
		
		protected function screenNavigator_addedToStageHandler(event:Event) : void {
			this.stage.addEventListener("resize",stage_resizeHandler);
		}
		
		protected function screenNavigator_removedFromStageHandler(event:Event) : void {
			this.stage.removeEventListener("resize",stage_resizeHandler);
		}
		
		protected function activeScreen_resizeHandler(event:Event) : void {
			if(this._isValidating || this._autoSizeMode != "content") {
				return;
			}
			this.invalidate("size");
		}
		
		protected function stage_resizeHandler(event:Event) : void {
			this.invalidate("size");
		}
		
		private function waitingForTransition_enterFrameHandler(event:Event) : void {
			if(this._waitingForTransitionFrameCount < 2) {
				this._waitingForTransitionFrameCount++;
				return;
			}
			this.removeEventListener("enterFrame",waitingForTransition_enterFrameHandler);
			if(this._activeScreen) {
				this._activeScreen.visible = true;
			}
			var _local2:Function = this._waitingTransition;
			this._waitingTransition = null;
			_local2(this._previousScreenInTransition,this._activeScreen,transitionComplete);
		}
	}
}

