package starling.events {
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Stage;
	
	public class TouchProcessor {
		private static var sUpdatedTouches:Vector.<Touch> = new Vector.<Touch>(0);
		
		private static var sHoveringTouchData:Vector.<Object> = new Vector.<Object>(0);
		
		private static var sHelperPoint:Point = new Point();
		
		private var _stage:Stage;
		
		private var _root:DisplayObject;
		
		private var _elapsedTime:Number;
		
		private var _lastTaps:Vector.<Touch>;
		
		private var _shiftDown:Boolean = false;
		
		private var _ctrlDown:Boolean = false;
		
		private var _multitapTime:Number = 0.3;
		
		private var _multitapDistance:Number = 25;
		
		private var _touchEvent:TouchEvent;
		
		private var _touchMarker:TouchMarker;
		
		private var _simulateMultitouch:Boolean;
		
		protected var _queue:Vector.<Array>;
		
		protected var _currentTouches:Vector.<Touch>;
		
		public function TouchProcessor(stage:Stage) {
			super();
			_root = _stage = stage;
			_elapsedTime = 0;
			_currentTouches = new Vector.<Touch>(0);
			_queue = new Vector.<Array>(0);
			_lastTaps = new Vector.<Touch>(0);
			_touchEvent = new TouchEvent("touch");
			_stage.addEventListener("keyDown",onKey);
			_stage.addEventListener("keyUp",onKey);
			monitorInterruptions(true);
		}
		
		public function dispose() : void {
			monitorInterruptions(false);
			_stage.removeEventListener("keyDown",onKey);
			_stage.removeEventListener("keyUp",onKey);
			if(_touchMarker) {
				_touchMarker.dispose();
			}
		}
		
		public function advanceTime(passedTime:Number) : void {
			var _local2:int = 0;
			var _local3:Touch = null;
			var _local4:Array = null;
			_elapsedTime += passedTime;
			sUpdatedTouches.length = 0;
			if(_lastTaps.length > 0) {
				_local2 = _lastTaps.length - 1;
				while(_local2 >= 0) {
					if(_elapsedTime - _lastTaps[_local2].timestamp > _multitapTime) {
						_lastTaps.removeAt(_local2);
					}
					_local2--;
				}
			}
			while(_queue.length > 0) {
				for each(_local3 in _currentTouches) {
					if(_local3.phase == "began" || _local3.phase == "moved") {
						_local3.phase = "stationary";
					}
				}
				while(_queue.length > 0 && !containsTouchWithID(sUpdatedTouches,_queue[_queue.length - 1][0])) {
					_local4 = _queue.pop();
					_local3 = createOrUpdateTouch(_local4[0],_local4[1],_local4[2],_local4[3],_local4[4],_local4[5],_local4[6]);
					sUpdatedTouches[sUpdatedTouches.length] = _local3;
				}
				processTouches(sUpdatedTouches,_shiftDown,_ctrlDown);
				_local2 = _currentTouches.length - 1;
				while(_local2 >= 0) {
					if(_currentTouches[_local2].phase == "ended") {
						_currentTouches.removeAt(_local2);
					}
					_local2--;
				}
				sUpdatedTouches.length = 0;
			}
		}
		
		protected function processTouches(touches:Vector.<Touch>, shiftDown:Boolean, ctrlDown:Boolean) : void {
			var _local4:* = null;
			sHoveringTouchData.length = 0;
			_touchEvent.resetTo("touch",_currentTouches,shiftDown,ctrlDown);
			for each(_local4 in touches) {
				if(_local4.phase == "hover" && _local4.target) {
					sHoveringTouchData[sHoveringTouchData.length] = {
						"touch":_local4,
						"target":_local4.target,
						"bubbleChain":_local4.bubbleChain
					};
				}
				if(_local4.phase == "hover" || _local4.phase == "began") {
					sHelperPoint.setTo(_local4.globalX,_local4.globalY);
					_local4.target = _root.hitTest(sHelperPoint);
				}
			}
			for each(var _local5 in sHoveringTouchData) {
				if(_local5.touch.target != _local5.target) {
					_touchEvent.dispatch(_local5.bubbleChain);
				}
			}
			for each(_local4 in touches) {
				_local4.dispatchEvent(_touchEvent);
			}
			_touchEvent.resetTo("touch");
		}
		
		public function enqueue(touchID:int, phase:String, globalX:Number, globalY:Number, pressure:Number = 1, width:Number = 1, height:Number = 1) : void {
			_queue.unshift(arguments);
			if(_ctrlDown && _touchMarker && touchID == 0) {
				_touchMarker.moveMarker(globalX,globalY,_shiftDown);
				_queue.unshift([1,phase,_touchMarker.mockX,_touchMarker.mockY]);
			}
		}
		
		public function enqueueMouseLeftStage() : void {
			var _local1:Touch = getCurrentTouch(0);
			if(_local1 == null || _local1.phase != "hover") {
				return;
			}
			var _local2:int = 1;
			var _local8:Number = _local1.globalX;
			var _local6:Number = _local1.globalY;
			var _local4:Number = _local1.globalX;
			var _local7:Number = _stage.stageWidth - _local4;
			var _local3:Number = _local1.globalY;
			var _local9:Number = _stage.stageHeight - _local3;
			var _local5:Number = Math.min(_local4,_local7,_local3,_local9);
			if(_local5 == _local4) {
				_local8 = -_local2;
			} else if(_local5 == _local7) {
				_local8 = _stage.stageWidth + _local2;
			} else if(_local5 == _local3) {
				_local6 = -_local2;
			} else {
				_local6 = _stage.stageHeight + _local2;
			}
			enqueue(0,"hover",_local8,_local6);
		}
		
		public function cancelTouches() : void {
			if(_currentTouches.length > 0) {
				for each(var _local1 in _currentTouches) {
					if(_local1.phase == "began" || _local1.phase == "moved" || _local1.phase == "stationary") {
						_local1.phase = "ended";
						_local1.cancelled = true;
					}
				}
				processTouches(_currentTouches,_shiftDown,_ctrlDown);
			}
			_currentTouches.length = 0;
			_queue.length = 0;
		}
		
		private function createOrUpdateTouch(touchID:int, phase:String, globalX:Number, globalY:Number, pressure:Number = 1, width:Number = 1, height:Number = 1) : Touch {
			var _local8:Touch = getCurrentTouch(touchID);
			if(_local8 == null) {
				_local8 = new Touch(touchID);
				addCurrentTouch(_local8);
			}
			_local8.globalX = globalX;
			_local8.globalY = globalY;
			_local8.phase = phase;
			_local8.timestamp = _elapsedTime;
			_local8.pressure = pressure;
			_local8.width = width;
			_local8.height = height;
			if(phase == "began") {
				updateTapCount(_local8);
			}
			return _local8;
		}
		
		private function updateTapCount(touch:Touch) : void {
			var _local4:Number = NaN;
			var _local5:* = null;
			var _local2:Number = _multitapDistance * _multitapDistance;
			for each(var _local3 in _lastTaps) {
				_local4 = Math.pow(_local3.globalX - touch.globalX,2) + Math.pow(_local3.globalY - touch.globalY,2);
				if(_local4 <= _local2) {
					_local5 = _local3;
					break;
				}
			}
			if(_local5) {
				touch.tapCount = _local5.tapCount + 1;
				_lastTaps.removeAt(_lastTaps.indexOf(_local5));
			} else {
				touch.tapCount = 1;
			}
			_lastTaps[_lastTaps.length] = touch.clone();
		}
		
		private function addCurrentTouch(touch:Touch) : void {
			var _local2:int = 0;
			_local2 = _currentTouches.length - 1;
			while(_local2 >= 0) {
				if(_currentTouches[_local2].id == touch.id) {
					_currentTouches.removeAt(_local2);
				}
				_local2--;
			}
			_currentTouches[_currentTouches.length] = touch;
		}
		
		private function getCurrentTouch(touchID:int) : Touch {
			for each(var _local2 in _currentTouches) {
				if(_local2.id == touchID) {
					return _local2;
				}
			}
			return null;
		}
		
		private function containsTouchWithID(touches:Vector.<Touch>, touchID:int) : Boolean {
			for each(var _local3 in touches) {
				if(_local3.id == touchID) {
					return true;
				}
			}
			return false;
		}
		
		public function get simulateMultitouch() : Boolean {
			return _simulateMultitouch;
		}
		
		public function set simulateMultitouch(value:Boolean) : void {
			var target:Starling;
			var createTouchMarker:* = function():void {
				target.removeEventListener("context3DCreate",createTouchMarker);
				if(_touchMarker == null) {
					_touchMarker = new TouchMarker();
					_touchMarker.visible = false;
					_stage.addChild(_touchMarker);
				}
			};
			if(simulateMultitouch == value) {
				return;
			}
			_simulateMultitouch = value;
			target = Starling.current;
			if(value && _touchMarker == null) {
				if(Starling.current.contextValid) {
					createTouchMarker();
				} else {
					target.addEventListener("context3DCreate",createTouchMarker);
				}
			} else if(!value && _touchMarker) {
				_touchMarker.removeFromParent(true);
				_touchMarker = null;
			}
		}
		
		public function get multitapTime() : Number {
			return _multitapTime;
		}
		
		public function set multitapTime(value:Number) : void {
			_multitapTime = value;
		}
		
		public function get multitapDistance() : Number {
			return _multitapDistance;
		}
		
		public function set multitapDistance(value:Number) : void {
			_multitapDistance = value;
		}
		
		public function get root() : DisplayObject {
			return _root;
		}
		
		public function set root(value:DisplayObject) : void {
			_root = value;
		}
		
		public function get stage() : Stage {
			return _stage;
		}
		
		public function get numCurrentTouches() : int {
			return _currentTouches.length;
		}
		
		private function onKey(event:KeyboardEvent) : void {
			var _local2:Boolean = false;
			var _local4:Touch = null;
			var _local3:Touch = null;
			if(event.keyCode == 17 || event.keyCode == 15) {
				_local2 = _ctrlDown;
				_ctrlDown = event.type == "keyDown";
				if(_touchMarker && _local2 != _ctrlDown) {
					_touchMarker.visible = _ctrlDown;
					_touchMarker.moveCenter(_stage.stageWidth / 2,_stage.stageHeight / 2);
					_local4 = getCurrentTouch(0);
					_local3 = getCurrentTouch(1);
					if(_local4) {
						_touchMarker.moveMarker(_local4.globalX,_local4.globalY);
					}
					if(_local2 && _local3 && _local3.phase != "ended") {
						_queue.unshift([1,"ended",_local3.globalX,_local3.globalY]);
					} else if(_ctrlDown && _local4) {
						if(_local4.phase == "hover" || _local4.phase == "ended") {
							_queue.unshift([1,"hover",_touchMarker.mockX,_touchMarker.mockY]);
						} else {
							_queue.unshift([1,"began",_touchMarker.mockX,_touchMarker.mockY]);
						}
					}
				}
			} else if(event.keyCode == 16) {
				_shiftDown = event.type == "keyDown";
			}
		}
		
		private function monitorInterruptions(enable:Boolean) : void {
			var _local3:Object = null;
			var _local2:Object = null;
			try {
				_local3 = getDefinitionByName("flash.desktop::NativeApplication");
				_local2 = _local3["nativeApplication"];
				if(enable) {
					_local2.addEventListener("deactivate",onInterruption,false,0,true);
				} else {
					_local2.removeEventListener("deactivate",onInterruption);
				}
			}
			catch(e:Error) {
			}
		}
		
		private function onInterruption(event:Object) : void {
			cancelTouches();
		}
	}
}

