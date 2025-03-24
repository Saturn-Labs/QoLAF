package starling.display {
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.utils.getQualifiedClassName;
	import starling.core.starling_internal;
	import starling.errors.AbstractClassError;
	import starling.events.Event;
	import starling.filters.FragmentFilter;
	import starling.rendering.BatchToken;
	import starling.rendering.Painter;
	import starling.utils.MatrixUtil;
	
	use namespace starling_internal;
	
	public class DisplayObjectContainer extends DisplayObject {
		private static var sHelperMatrix:Matrix = new Matrix();
		
		private static var sHelperPoint:Point = new Point();
		
		private static var sBroadcastListeners:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
		
		private static var sSortBuffer:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
		
		private static var sCacheToken:BatchToken = new BatchToken();
		
		private var _children:Vector.<DisplayObject>;
		
		private var _touchGroup:Boolean;
		
		public function DisplayObjectContainer() {
			super();
			if(Capabilities.isDebugger && getQualifiedClassName(this) == "starling.display::DisplayObjectContainer") {
				throw new AbstractClassError();
			}
			_children = new Vector.<DisplayObject>(0);
		}
		
		private static function mergeSort(input:Vector.<DisplayObject>, compareFunc:Function, startIndex:int, length:int, buffer:Vector.<DisplayObject>) : void {
			var _local9:* = 0;
			var _local7:int = 0;
			var _local8:int = 0;
			var _local10:* = 0;
			var _local6:int = 0;
			if(length > 1) {
				_local7 = startIndex + length;
				_local8 = length / 2;
				_local10 = startIndex;
				_local6 = startIndex + _local8;
				mergeSort(input,compareFunc,startIndex,_local8,buffer);
				mergeSort(input,compareFunc,startIndex + _local8,length - _local8,buffer);
				_local9 = 0;
				while(_local9 < length) {
					if(_local10 < startIndex + _local8 && (_local6 == _local7 || compareFunc(input[_local10],input[_local6]) <= 0)) {
						buffer[_local9] = input[_local10];
						_local10++;
					} else {
						buffer[_local9] = input[_local6];
						_local6++;
					}
					_local9++;
				}
				_local9 = startIndex;
				while(_local9 < _local7) {
					input[_local9] = buffer[_local9 - startIndex];
					_local9++;
				}
			}
		}
		
		override public function dispose() : void {
			var _local1:int = 0;
			_local1 = _children.length - 1;
			while(_local1 >= 0) {
				_children[_local1].dispose();
				_local1--;
			}
			super.dispose();
		}
		
		public function addChild(child:DisplayObject) : DisplayObject {
			return addChildAt(child,_children.length);
		}
		
		public function addChildAt(child:DisplayObject, index:int) : DisplayObject {
			var _local3:DisplayObjectContainer = null;
			var _local4:int = int(_children.length);
			if(index >= 0 && index <= _local4) {
				setRequiresRedraw();
				if(child.parent == this) {
					setChildIndex(child,index);
				} else {
					_children.insertAt(index,child);
					child.removeFromParent();
					child.starling_internal::setParent(this);
					child.dispatchEventWith("added",true);
					if(stage) {
						_local3 = child as DisplayObjectContainer;
						if(_local3) {
							_local3.broadcastEventWith("addedToStage");
						} else {
							child.dispatchEventWith("addedToStage");
						}
					}
				}
				return child;
			}
			throw new RangeError("Invalid child index");
		}
		
		public function removeChild(child:DisplayObject, dispose:Boolean = false) : DisplayObject {
			var _local3:int = getChildIndex(child);
			if(_local3 != -1) {
				return removeChildAt(_local3,dispose);
			}
			return null;
		}
		
		public function removeChildAt(index:int, dispose:Boolean = false) : DisplayObject {
			var _local4:DisplayObject = null;
			var _local3:DisplayObjectContainer = null;
			if(index >= 0 && index < _children.length) {
				setRequiresRedraw();
				_local4 = _children[index];
				_local4.dispatchEventWith("removed",true);
				if(stage) {
					_local3 = _local4 as DisplayObjectContainer;
					if(_local3) {
						_local3.broadcastEventWith("removedFromStage");
					} else {
						_local4.dispatchEventWith("removedFromStage");
					}
				}
				_local4.starling_internal::setParent(null);
				index = int(_children.indexOf(_local4));
				if(index >= 0) {
					_children.removeAt(index);
				}
				if(dispose) {
					_local4.dispose();
				}
				return _local4;
			}
			throw new RangeError("Invalid child index");
		}
		
		public function removeChildren(beginIndex:int = 0, endIndex:int = -1, dispose:Boolean = false) : void {
			var _local4:* = 0;
			if(endIndex < 0 || endIndex >= numChildren) {
				endIndex = numChildren - 1;
			}
			_local4 = beginIndex;
			while(_local4 <= endIndex) {
				removeChildAt(beginIndex,dispose);
				_local4++;
			}
		}
		
		public function getChildAt(index:int) : DisplayObject {
			var _local2:int = int(_children.length);
			if(index < 0) {
				index = _local2 + index;
			}
			if(index >= 0 && index < _local2) {
				return _children[index];
			}
			throw new RangeError("Invalid child index");
		}
		
		public function getChildByName(name:String) : DisplayObject {
			var _local3:int = 0;
			var _local2:int = int(_children.length);
			_local3 = 0;
			while(_local3 < _local2) {
				if(_children[_local3].name == name) {
					return _children[_local3];
				}
				_local3++;
			}
			return null;
		}
		
		public function getChildIndex(child:DisplayObject) : int {
			return _children.indexOf(child);
		}
		
		public function setChildIndex(child:DisplayObject, index:int) : void {
			var _local3:int = getChildIndex(child);
			if(_local3 == index) {
				return;
			}
			if(_local3 == -1) {
				throw new ArgumentError("Not a child of this container");
			}
			_children.removeAt(_local3);
			_children.insertAt(index,child);
			setRequiresRedraw();
		}
		
		public function swapChildren(child1:DisplayObject, child2:DisplayObject) : void {
			var _local3:int = getChildIndex(child1);
			var _local4:int = getChildIndex(child2);
			if(_local3 == -1 || _local4 == -1) {
				throw new ArgumentError("Not a child of this container");
			}
			swapChildrenAt(_local3,_local4);
		}
		
		public function swapChildrenAt(index1:int, index2:int) : void {
			var _local4:DisplayObject = getChildAt(index1);
			var _local3:DisplayObject = getChildAt(index2);
			_children[index1] = _local3;
			_children[index2] = _local4;
			setRequiresRedraw();
		}
		
		public function sortChildren(compareFunction:Function) : void {
			sSortBuffer.length = _children.length;
			mergeSort(_children,compareFunction,0,_children.length,sSortBuffer);
			sSortBuffer.length = 0;
			setRequiresRedraw();
		}
		
		public function contains(child:DisplayObject) : Boolean {
			while(child) {
				if(child == this) {
					return true;
				}
				child = child.parent;
			}
			return false;
		}
		
		override public function getBounds(targetSpace:DisplayObject, out:Rectangle = null) : Rectangle {
			var _local4:Number = NaN;
			var _local3:Number = NaN;
			var _local8:int = 0;
			if(out == null) {
				out = new Rectangle();
			}
			var _local7:int = int(_children.length);
			if(_local7 == 0) {
				getTransformationMatrix(targetSpace,sHelperMatrix);
				MatrixUtil.transformCoords(sHelperMatrix,0,0,sHelperPoint);
				out.setTo(sHelperPoint.x,sHelperPoint.y,0,0);
			} else if(_local7 == 1) {
				_children[0].getBounds(targetSpace,out);
			} else {
				_local4 = 1.7976931348623157e+308;
				var _local6:Number = -1.7976931348623157e+308;
				_local3 = 1.7976931348623157e+308;
				var _local5:Number = -1.7976931348623157e+308;
				_local8 = 0;
				while(_local8 < _local7) {
					_children[_local8].getBounds(targetSpace,out);
					if(_local4 > out.x) {
						_local4 = out.x;
					}
					if(_local6 < out.right) {
						_local6 = out.right;
					}
					if(_local3 > out.y) {
						_local3 = out.y;
					}
					if(_local5 < out.bottom) {
						_local5 = out.bottom;
					}
					_local8++;
				}
				out.setTo(_local4,_local3,_local6 - _local4,_local5 - _local3);
			}
			return out;
		}
		
		override public function hitTest(localPoint:Point) : DisplayObject {
			var _local4:int = 0;
			var _local7:DisplayObject = null;
			if(!visible || !touchable || !hitTestMask(localPoint)) {
				return null;
			}
			var _local6:DisplayObject = null;
			var _local5:Number = localPoint.x;
			var _local2:Number = localPoint.y;
			var _local3:int = int(_children.length);
			_local4 = _local3 - 1;
			while(_local4 >= 0) {
				_local7 = _children[_local4];
				if(!_local7.isMask) {
					sHelperMatrix.copyFrom(_local7.transformationMatrix);
					sHelperMatrix.invert();
					MatrixUtil.transformCoords(sHelperMatrix,_local5,_local2,sHelperPoint);
					_local6 = _local7.hitTest(sHelperPoint);
					if(_local6) {
						return _touchGroup ? this : _local6;
					}
				}
				_local4--;
			}
			return null;
		}
		
		override public function render(painter:Painter) : void {
			var _local7:int = 0;
			var _local10:DisplayObject = null;
			var _local9:BatchToken = null;
			var _local3:BatchToken = null;
			var _local2:FragmentFilter = null;
			var _local11:DisplayObject = null;
			var _local6:int = int(_children.length);
			var _local5:uint = painter.frameID;
			var _local4:* = _local5 != 0;
			var _local8:* = _lastParentOrSelfChangeFrameID == _local5;
			_local7 = 0;
			while(_local7 < _local6) {
				_local10 = _children[_local7];
				if(_local10._hasVisibleArea) {
					if(_local8) {
						_local10._lastParentOrSelfChangeFrameID = _local5;
					}
					if(false && _local10._lastParentOrSelfChangeFrameID != _local5 && _local10._lastChildChangeFrameID != _local5 && _local10._tokenFrameID == _local5 - 1 && _local4) {
						painter.pushState(sCacheToken);
						painter.drawFromCache(_local10._pushToken,_local10._popToken);
						painter.popState(_local10._popToken);
						_local10._pushToken.copyFrom(sCacheToken);
					} else {
						_local9 = _local4 ? _local10._pushToken : null;
						_local3 = _local4 ? _local10._popToken : null;
						_local2 = _local10._filter;
						_local11 = _local10._mask;
						painter.pushState(_local9);
						painter.setStateTo(_local10.transformationMatrix,_local10.alpha,_local10.blendMode);
						if(_local11) {
							painter.drawMask(_local11,_local10);
						}
						if(_local2) {
							_local2.render(painter);
						} else {
							_local10.render(painter);
						}
						if(_local11) {
							painter.eraseMask(_local11,_local10);
						}
						painter.popState(_local3);
					}
					if(_local4) {
						_local10._tokenFrameID = _local5;
					}
				}
				_local7++;
			}
		}
		
		public function broadcastEvent(event:Event) : void {
			var _local3:* = 0;
			if(event.bubbles) {
				throw new ArgumentError("Broadcast of bubbling events is prohibited");
			}
			var _local4:int = int(sBroadcastListeners.length);
			getChildEventListeners(this,event.type,sBroadcastListeners);
			var _local2:int = int(sBroadcastListeners.length);
			_local3 = _local4;
			while(_local3 < _local2) {
				sBroadcastListeners[_local3].dispatchEvent(event);
				_local3++;
			}
			sBroadcastListeners.length = _local4;
		}
		
		public function broadcastEventWith(eventType:String, data:Object = null) : void {
			var _local3:Event = Event.starling_internal::fromPool(eventType,false,data);
			broadcastEvent(_local3);
			Event.starling_internal::toPool(_local3);
		}
		
		public function get numChildren() : int {
			return _children.length;
		}
		
		public function get touchGroup() : Boolean {
			return _touchGroup;
		}
		
		public function set touchGroup(value:Boolean) : void {
			_touchGroup = value;
		}
		
		internal function getChildEventListeners(object:DisplayObject, eventType:String, listeners:Vector.<DisplayObject>) : void {
			var _local5:* = undefined;
			var _local6:int = 0;
			var _local7:int = 0;
			var _local4:DisplayObjectContainer = object as DisplayObjectContainer;
			if(object.hasEventListener(eventType)) {
				listeners[listeners.length] = object;
			}
			if(_local4) {
				_local5 = _local4._children;
				_local6 = int(_local5.length);
				_local7 = 0;
				while(_local7 < _local6) {
					getChildEventListeners(_local5[_local7],eventType,listeners);
					_local7++;
				}
			}
		}
	}
}

