package feathers.core {
	import feathers.controls.supportClasses.LayoutViewPort;
	import feathers.utils.display.stageToStarling;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.errors.IllegalOperationError;
	import flash.events.FocusEvent;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	public class DefaultFocusManager implements IFocusManager {
		protected static var NATIVE_STAGE_TO_FOCUS_TARGET:Dictionary = new Dictionary(true);
		
		protected var _starling:Starling;
		
		protected var _nativeFocusTarget:NativeFocusTarget;
		
		protected var _root:DisplayObjectContainer;
		
		protected var _isEnabled:Boolean = false;
		
		protected var _savedFocus:IFocusDisplayObject;
		
		protected var _focus:IFocusDisplayObject;
		
		public function DefaultFocusManager(root:DisplayObjectContainer) {
			super();
			if(!root.stage) {
				throw new ArgumentError("Focus manager root must be added to the stage.");
			}
			this._root = root;
			this._starling = stageToStarling(root.stage);
		}
		
		public function get root() : DisplayObjectContainer {
			return this._root;
		}
		
		public function get isEnabled() : Boolean {
			return this._isEnabled;
		}
		
		public function set isEnabled(value:Boolean) : void {
			var _local2:IFocusDisplayObject = null;
			if(this._isEnabled == value) {
				return;
			}
			this._isEnabled = value;
			if(this._isEnabled) {
				this._nativeFocusTarget = NATIVE_STAGE_TO_FOCUS_TARGET[this._starling.nativeStage] as NativeFocusTarget;
				if(!this._nativeFocusTarget) {
					this._nativeFocusTarget = new NativeFocusTarget();
					this._starling.nativeStage.addChild(_nativeFocusTarget);
				} else {
					this._nativeFocusTarget.referenceCount++;
				}
				this.setFocusManager(this._root);
				this._root.addEventListener("added",topLevelContainer_addedHandler);
				this._root.addEventListener("removed",topLevelContainer_removedHandler);
				this._root.addEventListener("touch",topLevelContainer_touchHandler);
				this._starling.nativeStage.addEventListener("keyFocusChange",stage_keyFocusChangeHandler,false,0,true);
				this._starling.nativeStage.addEventListener("mouseFocusChange",stage_mouseFocusChangeHandler,false,0,true);
				if(this._savedFocus && !this._savedFocus.stage) {
					this._savedFocus = null;
				}
				this.focus = this._savedFocus;
				this._savedFocus = null;
			} else {
				this._nativeFocusTarget.referenceCount--;
				if(this._nativeFocusTarget.referenceCount <= 0) {
					this._nativeFocusTarget.parent.removeChild(this._nativeFocusTarget);
					delete NATIVE_STAGE_TO_FOCUS_TARGET[this._starling.nativeStage];
				}
				this._nativeFocusTarget = null;
				this._root.removeEventListener("added",topLevelContainer_addedHandler);
				this._root.removeEventListener("removed",topLevelContainer_removedHandler);
				this._root.removeEventListener("touch",topLevelContainer_touchHandler);
				this._starling.nativeStage.removeEventListener("keyFocusChange",stage_keyFocusChangeHandler);
				this._starling.nativeStage.addEventListener("mouseFocusChange",stage_mouseFocusChangeHandler);
				_local2 = this.focus;
				this.focus = null;
				this._savedFocus = _local2;
			}
		}
		
		public function get focus() : IFocusDisplayObject {
			return this._focus;
		}
		
		public function set focus(value:IFocusDisplayObject) : void {
			var _local6:Object = null;
			var _local5:IAdvancedNativeFocusOwner = null;
			if(this._focus === value) {
				return;
			}
			var _local3:Boolean = false;
			var _local4:IFeathersDisplayObject = this._focus;
			if(this._isEnabled && value !== null && value.isFocusEnabled && value.focusManager === this) {
				this._focus = value;
				_local3 = true;
			} else {
				this._focus = null;
			}
			var _local2:Stage = this._starling.nativeStage;
			if(_local4 is INativeFocusOwner) {
				_local6 = INativeFocusOwner(_local4).nativeFocus;
				if(_local6 === null && _local2 !== null) {
					_local6 = _local2.focus;
				}
				if(_local6 is IEventDispatcher) {
					IEventDispatcher(_local6).removeEventListener("focusOut",nativeFocus_focusOutHandler);
				}
			}
			if(_local4 !== null) {
				_local4.dispatchEventWith("focusOut");
			}
			if(_local3 && this._focus !== value) {
				return;
			}
			if(this._isEnabled) {
				if(this._focus !== null) {
					_local6 = null;
					if(this._focus is INativeFocusOwner) {
						_local6 = INativeFocusOwner(this._focus).nativeFocus;
						if(_local6 is InteractiveObject) {
							_local2.focus = InteractiveObject(_local6);
						} else if(_local6 !== null) {
							if(!(this._focus is IAdvancedNativeFocusOwner)) {
								throw new IllegalOperationError("If nativeFocus does not return an InteractiveObject, class must implement IAdvancedNativeFocusOwner interface");
							}
							_local5 = IAdvancedNativeFocusOwner(this._focus);
							if(!_local5.hasFocus) {
								_local5.setFocus();
							}
						}
					}
					if(_local6 === null) {
						_local6 = this._nativeFocusTarget;
						_local2.focus = this._nativeFocusTarget;
					}
					if(_local6 is IEventDispatcher) {
						IEventDispatcher(_local6).addEventListener("focusOut",nativeFocus_focusOutHandler,false,0,true);
					}
					this._focus.dispatchEventWith("focusIn");
				} else {
					_local2.focus = null;
				}
			} else {
				this._savedFocus = value;
			}
		}
		
		protected function setFocusManager(target:DisplayObject) : void {
			var _local3:IFocusDisplayObject = null;
			var _local2:DisplayObjectContainer = null;
			var _local6:int = 0;
			var _local4:int = 0;
			var _local8:DisplayObject = null;
			var _local7:IFocusExtras = null;
			var _local5:* = undefined;
			if(target is IFocusDisplayObject) {
				_local3 = IFocusDisplayObject(target);
				_local3.focusManager = this;
			}
			if(target is DisplayObjectContainer && !(target is IFocusDisplayObject) || target is IFocusContainer && Boolean(IFocusContainer(target).isChildFocusEnabled)) {
				_local2 = DisplayObjectContainer(target);
				_local6 = _local2.numChildren;
				_local4 = 0;
				while(_local4 < _local6) {
					_local8 = _local2.getChildAt(_local4);
					this.setFocusManager(_local8);
					_local4++;
				}
				if(_local2 is IFocusExtras) {
					_local7 = IFocusExtras(_local2);
					_local5 = _local7.focusExtrasBefore;
					if(_local5) {
						_local6 = int(_local5.length);
						_local4 = 0;
						while(_local4 < _local6) {
							_local8 = _local5[_local4];
							this.setFocusManager(_local8);
							_local4++;
						}
					}
					_local5 = _local7.focusExtrasAfter;
					if(_local5) {
						_local6 = int(_local5.length);
						_local4 = 0;
						while(_local4 < _local6) {
							_local8 = _local5[_local4];
							this.setFocusManager(_local8);
							_local4++;
						}
					}
				}
			}
		}
		
		protected function clearFocusManager(target:DisplayObject) : void {
			var _local3:IFocusDisplayObject = null;
			var _local2:DisplayObjectContainer = null;
			var _local6:int = 0;
			var _local4:int = 0;
			var _local8:DisplayObject = null;
			var _local7:IFocusExtras = null;
			var _local5:* = undefined;
			if(target is IFocusDisplayObject) {
				_local3 = IFocusDisplayObject(target);
				if(_local3.focusManager == this) {
					if(this._focus == _local3) {
						this.focus = _local3.focusOwner;
					}
					_local3.focusManager = null;
				}
			}
			if(target is DisplayObjectContainer) {
				_local2 = DisplayObjectContainer(target);
				_local6 = _local2.numChildren;
				_local4 = 0;
				while(_local4 < _local6) {
					_local8 = _local2.getChildAt(_local4);
					this.clearFocusManager(_local8);
					_local4++;
				}
				if(_local2 is IFocusExtras) {
					_local7 = IFocusExtras(_local2);
					_local5 = _local7.focusExtrasBefore;
					if(_local5) {
						_local6 = int(_local5.length);
						_local4 = 0;
						while(_local4 < _local6) {
							_local8 = _local5[_local4];
							this.clearFocusManager(_local8);
							_local4++;
						}
					}
					_local5 = _local7.focusExtrasAfter;
					if(_local5) {
						_local6 = int(_local5.length);
						_local4 = 0;
						while(_local4 < _local6) {
							_local8 = _local5[_local4];
							this.clearFocusManager(_local8);
							_local4++;
						}
					}
				}
			}
		}
		
		protected function findPreviousContainerFocus(container:DisplayObjectContainer, beforeChild:DisplayObject, fallbackToGlobal:Boolean) : IFocusDisplayObject {
			var _local8:IFocusExtras = null;
			var _local9:* = undefined;
			var _local11:* = false;
			var _local7:int = 0;
			var _local10:* = 0;
			var _local12:DisplayObject = null;
			var _local5:IFocusDisplayObject = null;
			var _local6:IFocusDisplayObject = null;
			if(container is LayoutViewPort) {
				container = container.parent;
			}
			var _local4:* = beforeChild == null;
			if(container is IFocusExtras) {
				_local8 = IFocusExtras(container);
				_local9 = _local8.focusExtrasAfter;
				if(_local9) {
					_local11 = false;
					if(beforeChild) {
						_local7 = _local9.indexOf(beforeChild) - 1;
						_local4 = _local7 >= -1;
						_local11 = !_local4;
					} else {
						_local7 = _local9.length - 1;
					}
					if(!_local11) {
						_local10 = _local7;
						while(_local10 >= 0) {
							_local12 = _local9[_local10];
							_local5 = this.findPreviousChildFocus(_local12);
							if(this.isValidFocus(_local5)) {
								return _local5;
							}
							_local10--;
						}
					}
				}
			}
			if(beforeChild && !_local4) {
				_local7 = container.getChildIndex(beforeChild) - 1;
				_local4 = _local7 >= -1;
			} else {
				_local7 = container.numChildren - 1;
			}
			_local10 = _local7;
			while(_local10 >= 0) {
				_local12 = container.getChildAt(_local10);
				_local5 = this.findPreviousChildFocus(_local12);
				if(this.isValidFocus(_local5)) {
					return _local5;
				}
				_local10--;
			}
			if(container is IFocusExtras) {
				_local9 = _local8.focusExtrasBefore;
				if(_local9) {
					_local11 = false;
					if(beforeChild && !_local4) {
						_local7 = _local9.indexOf(beforeChild) - 1;
						_local4 = _local7 >= -1;
						_local11 = !_local4;
					} else {
						_local7 = _local9.length - 1;
					}
					if(!_local11) {
						_local10 = _local7;
						while(_local10 >= 0) {
							_local12 = _local9[_local10];
							_local5 = this.findPreviousChildFocus(_local12);
							if(this.isValidFocus(_local5)) {
								return _local5;
							}
							_local10--;
						}
					}
				}
			}
			if(fallbackToGlobal && container != this._root) {
				if(container is IFocusDisplayObject) {
					_local6 = IFocusDisplayObject(container);
					if(this.isValidFocus(_local6)) {
						return _local6;
					}
				}
				return this.findPreviousContainerFocus(container.parent,container,true);
			}
			return null;
		}
		
		protected function findNextContainerFocus(container:DisplayObjectContainer, afterChild:DisplayObject, fallbackToGlobal:Boolean) : IFocusDisplayObject {
			var _local6:IFocusExtras = null;
			var _local8:* = undefined;
			var _local10:* = false;
			var _local5:int = 0;
			var _local11:int = 0;
			var _local9:* = 0;
			var _local12:DisplayObject = null;
			var _local4:IFocusDisplayObject = null;
			if(container is LayoutViewPort) {
				container = container.parent;
			}
			var _local7:* = afterChild == null;
			if(container is IFocusExtras) {
				_local6 = IFocusExtras(container);
				_local8 = _local6.focusExtrasBefore;
				if(_local8) {
					_local10 = false;
					if(afterChild) {
						_local5 = _local8.indexOf(afterChild) + 1;
						_local7 = _local5 > 0;
						_local10 = !_local7;
					} else {
						_local5 = 0;
					}
					if(!_local10) {
						_local11 = int(_local8.length);
						_local9 = _local5;
						while(_local9 < _local11) {
							_local12 = _local8[_local9];
							_local4 = this.findNextChildFocus(_local12);
							if(this.isValidFocus(_local4)) {
								return _local4;
							}
							_local9++;
						}
					}
				}
			}
			if(afterChild && !_local7) {
				_local5 = container.getChildIndex(afterChild) + 1;
				_local7 = _local5 > 0;
			} else {
				_local5 = 0;
			}
			_local11 = container.numChildren;
			_local9 = _local5;
			while(_local9 < _local11) {
				_local12 = container.getChildAt(_local9);
				_local4 = this.findNextChildFocus(_local12);
				if(this.isValidFocus(_local4)) {
					return _local4;
				}
				_local9++;
			}
			if(container is IFocusExtras) {
				_local8 = _local6.focusExtrasAfter;
				if(_local8) {
					_local10 = false;
					if(afterChild && !_local7) {
						_local5 = _local8.indexOf(afterChild) + 1;
						_local7 = _local5 > 0;
						_local10 = !_local7;
					} else {
						_local5 = 0;
					}
					if(!_local10) {
						_local11 = int(_local8.length);
						_local9 = _local5;
						while(_local9 < _local11) {
							_local12 = _local8[_local9];
							_local4 = this.findNextChildFocus(_local12);
							if(this.isValidFocus(_local4)) {
								return _local4;
							}
							_local9++;
						}
					}
				}
			}
			if(fallbackToGlobal && container != this._root) {
				return this.findNextContainerFocus(container.parent,container,true);
			}
			return null;
		}
		
		protected function findPreviousChildFocus(child:DisplayObject) : IFocusDisplayObject {
			var _local4:DisplayObjectContainer = null;
			var _local2:IFocusDisplayObject = null;
			var _local3:IFocusDisplayObject = null;
			if(child is DisplayObjectContainer && !(child is IFocusDisplayObject) || child is IFocusContainer && Boolean(IFocusContainer(child).isChildFocusEnabled)) {
				_local4 = DisplayObjectContainer(child);
				_local2 = this.findPreviousContainerFocus(_local4,null,false);
				if(_local2) {
					return _local2;
				}
			}
			if(child is IFocusDisplayObject) {
				_local3 = IFocusDisplayObject(child);
				if(this.isValidFocus(_local3)) {
					return _local3;
				}
			}
			return null;
		}
		
		protected function findNextChildFocus(child:DisplayObject) : IFocusDisplayObject {
			var _local3:IFocusDisplayObject = null;
			var _local4:DisplayObjectContainer = null;
			var _local2:IFocusDisplayObject = null;
			if(child is IFocusDisplayObject) {
				_local3 = IFocusDisplayObject(child);
				if(this.isValidFocus(_local3)) {
					return _local3;
				}
			}
			if(child is DisplayObjectContainer && !(child is IFocusDisplayObject) || child is IFocusContainer && Boolean(IFocusContainer(child).isChildFocusEnabled)) {
				_local4 = DisplayObjectContainer(child);
				_local2 = this.findNextContainerFocus(_local4,null,false);
				if(_local2) {
					return _local2;
				}
			}
			return null;
		}
		
		protected function isValidFocus(child:IFocusDisplayObject) : Boolean {
			if(!child || !child.isFocusEnabled || child.focusManager != this) {
				return false;
			}
			var _local2:IFeathersControl = child as IFeathersControl;
			if(_local2 && !_local2.isEnabled) {
				return false;
			}
			return true;
		}
		
		protected function stage_mouseFocusChangeHandler(event:FocusEvent) : void {
			if(event.relatedObject) {
				this.focus = null;
				return;
			}
			event.preventDefault();
		}
		
		protected function stage_keyFocusChangeHandler(event:FocusEvent) : void {
			var _local3:IFocusDisplayObject = null;
			if(event.keyCode != 9 && event.keyCode != 0) {
				return;
			}
			var _local2:IFocusDisplayObject = this._focus;
			if(_local2 && _local2.focusOwner) {
				_local3 = _local2.focusOwner;
			} else if(event.shiftKey) {
				if(_local2) {
					if(_local2.previousTabFocus) {
						_local3 = _local2.previousTabFocus;
					} else {
						_local3 = this.findPreviousContainerFocus(_local2.parent,DisplayObject(_local2),true);
					}
				}
				if(!_local3) {
					_local3 = this.findPreviousContainerFocus(this._root,null,false);
				}
			} else {
				if(_local2) {
					if(_local2.nextTabFocus) {
						_local3 = _local2.nextTabFocus;
					} else if(_local2 is IFocusContainer && Boolean(IFocusContainer(_local2).isChildFocusEnabled)) {
						_local3 = this.findNextContainerFocus(DisplayObjectContainer(_local2),null,true);
					} else {
						_local3 = this.findNextContainerFocus(_local2.parent,DisplayObject(_local2),true);
					}
				}
				if(!_local3) {
					_local3 = this.findNextContainerFocus(this._root,null,false);
				}
			}
			if(_local3) {
				event.preventDefault();
			}
			this.focus = _local3;
			if(this._focus) {
				this._focus.showFocus();
			}
		}
		
		protected function topLevelContainer_addedHandler(event:Event) : void {
			this.setFocusManager(DisplayObject(event.target));
		}
		
		protected function topLevelContainer_removedHandler(event:Event) : void {
			this.clearFocusManager(DisplayObject(event.target));
		}
		
		protected function topLevelContainer_touchHandler(event:TouchEvent) : void {
			var _local2:IFocusDisplayObject = null;
			var _local3:Touch = event.getTouch(this._root,"began");
			if(!_local3) {
				return;
			}
			var _local4:* = null;
			var _local5:DisplayObject = _local3.target;
			do {
				if(_local5 is IFocusDisplayObject) {
					_local2 = IFocusDisplayObject(_local5);
					if(this.isValidFocus(_local2)) {
						if(!_local4 || !(_local2 is IFocusContainer) || !IFocusContainer(_local2).isChildFocusEnabled) {
							_local4 = _local2;
						}
					}
				}
			}
			while(_local5 = _local5.parent, _local5);
			
			this.focus = _local4;
		}
		
		protected function nativeFocus_focusOutHandler(event:FocusEvent) : void {
			var _local3:Object = event.currentTarget;
			var _local2:Stage = this._starling.nativeStage;
			if(_local2.focus !== null && _local2.focus !== _local3) {
				if(_local3 is IEventDispatcher) {
					IEventDispatcher(_local3).removeEventListener("focusOut",nativeFocus_focusOutHandler);
				}
			} else if(this._focus !== null) {
				if(this._focus is INativeFocusOwner && INativeFocusOwner(this._focus).nativeFocus !== _local3) {
					return;
				}
				if(_local3 is InteractiveObject) {
					_local2.focus = InteractiveObject(_local3);
				} else {
					IAdvancedNativeFocusOwner(this._focus).setFocus();
				}
			}
		}
	}
}

import flash.display.Sprite;

class NativeFocusTarget extends Sprite {
	public var referenceCount:int = 1;
	
	public function NativeFocusTarget() {
		super();
		this.tabEnabled = true;
		this.mouseEnabled = false;
		this.mouseChildren = false;
		this.alpha = 0;
	}
}
