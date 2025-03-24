package starling.animation {
	import starling.core.starling_internal;
	import starling.events.EventDispatcher;
	import starling.utils.Color;
	
	use namespace starling_internal;
	
	public class Tween extends EventDispatcher implements IAnimatable {
		private static const HINT_MARKER:String = "#";
		
		private static var sTweenPool:Vector.<Tween> = new Vector.<Tween>(0);
		
		private var _target:Object;
		
		private var _transitionFunc:Function;
		
		private var _transitionName:String;
		
		private var _properties:Vector.<String>;
		
		private var _startValues:Vector.<Number>;
		
		private var _endValues:Vector.<Number>;
		
		private var _updateFuncs:Vector.<Function>;
		
		private var _onStart:Function;
		
		private var _onUpdate:Function;
		
		private var _onRepeat:Function;
		
		private var _onComplete:Function;
		
		private var _onStartArgs:Array;
		
		private var _onUpdateArgs:Array;
		
		private var _onRepeatArgs:Array;
		
		private var _onCompleteArgs:Array;
		
		private var _totalTime:Number;
		
		private var _currentTime:Number;
		
		private var _progress:Number;
		
		private var _delay:Number;
		
		private var _roundToInt:Boolean;
		
		private var _nextTween:Tween;
		
		private var _repeatCount:int;
		
		private var _repeatDelay:Number;
		
		private var _reverse:Boolean;
		
		private var _currentCycle:int;
		
		public function Tween(target:Object, time:Number, transition:Object = "linear") {
			super();
			reset(target,time,transition);
		}
		
		internal static function getPropertyHint(property:String) : String {
			if(property.indexOf("color") != -1 || property.indexOf("Color") != -1) {
				return "rgb";
			}
			var _local2:int = int(property.indexOf("#"));
			if(_local2 != -1) {
				return property.substr(_local2 + 1);
			}
			return null;
		}
		
		internal static function getPropertyName(property:String) : String {
			var _local2:int = int(property.indexOf("#"));
			if(_local2 != -1) {
				return property.substring(0,_local2);
			}
			return property;
		}
		
		starling_internal static function fromPool(target:Object, time:Number, transition:Object = "linear") : Tween {
			if(sTweenPool.length) {
				return sTweenPool.pop().reset(target,time,transition);
			}
			return new Tween(target,time,transition);
		}
		
		starling_internal static function toPool(tween:Tween) : void {
			tween._onStart = tween._onUpdate = tween._onRepeat = tween._onComplete = null;
			tween._onStartArgs = tween._onUpdateArgs = tween._onRepeatArgs = tween._onCompleteArgs = null;
			tween._target = null;
			tween._transitionFunc = null;
			tween.removeEventListeners();
			sTweenPool.push(tween);
		}
		
		public function reset(target:Object, time:Number, transition:Object = "linear") : Tween {
			_target = target;
			_currentTime = 0;
			_totalTime = Math.max(0.0001,time);
			_progress = 0;
			_delay = _repeatDelay = 0;
			_onStart = _onUpdate = _onRepeat = _onComplete = null;
			_onStartArgs = _onUpdateArgs = _onRepeatArgs = _onCompleteArgs = null;
			_roundToInt = _reverse = false;
			_repeatCount = 1;
			_currentCycle = -1;
			_nextTween = null;
			if(transition is String) {
				this.transition = transition as String;
			} else {
				if(!(transition is Function)) {
					throw new ArgumentError("Transition must be either a string or a function");
				}
				this.transitionFunc = transition as Function;
			}
			if(_properties) {
				_properties.length = 0;
			} else {
				_properties = new Vector.<String>(0);
			}
			if(_startValues) {
				_startValues.length = 0;
			} else {
				_startValues = new Vector.<Number>(0);
			}
			if(_endValues) {
				_endValues.length = 0;
			} else {
				_endValues = new Vector.<Number>(0);
			}
			if(_updateFuncs) {
				_updateFuncs.length = 0;
			} else {
				_updateFuncs = new Vector.<Function>(0);
			}
			return this;
		}
		
		public function animate(property:String, endValue:Number) : void {
			if(_target == null) {
				return;
			}
			var _local3:int = int(_properties.length);
			var _local4:Function = getUpdateFuncFromProperty(property);
			_properties[_local3] = getPropertyName(property);
			_startValues[_local3] = NaN;
			_endValues[_local3] = endValue;
			_updateFuncs[_local3] = _local4;
		}
		
		public function scaleTo(factor:Number) : void {
			animate("scaleX",factor);
			animate("scaleY",factor);
		}
		
		public function moveTo(x:Number, y:Number) : void {
			animate("x",x);
			animate("y",y);
		}
		
		public function fadeTo(alpha:Number) : void {
			animate("alpha",alpha);
		}
		
		public function rotateTo(angle:Number, type:String = "rad") : void {
			animate("rotation#" + type,angle);
		}
		
		public function advanceTime(time:Number) : void {
			var _local6:int = 0;
			var _local7:Function = null;
			var _local5:Function = null;
			var _local8:Array = null;
			if(time == 0 || _repeatCount == 1 && _currentTime == _totalTime) {
				return;
			}
			var _local3:Number = _currentTime;
			var _local2:Number = _totalTime - _currentTime;
			var _local10:Number = time > _local2 ? time - _local2 : 0;
			_currentTime += time;
			if(_currentTime <= 0) {
				return;
			}
			if(_currentTime > _totalTime) {
				_currentTime = _totalTime;
			}
			if(_currentCycle < 0 && _local3 <= 0 && _currentTime > 0) {
				_currentCycle++;
				if(_onStart != null) {
					_onStart.apply(this,_onStartArgs);
				}
			}
			var _local11:Number = _currentTime / _totalTime;
			var _local9:Boolean = _reverse && _currentCycle % 2 == 1;
			var _local4:int = int(_startValues.length);
			_progress = _local9 ? _transitionFunc(1 - _local11) : _transitionFunc(_local11);
			_local6 = 0;
			while(_local6 < _local4) {
				if(_startValues[_local6] != _startValues[_local6]) {
					_startValues[_local6] = _target[_properties[_local6]] as Number;
				}
				_local7 = _updateFuncs[_local6] as Function;
				_local7(_properties[_local6],_startValues[_local6],_endValues[_local6]);
				_local6++;
			}
			if(_onUpdate != null) {
				_onUpdate.apply(this,_onUpdateArgs);
			}
			if(_local3 < _totalTime && _currentTime >= _totalTime) {
				if(_repeatCount == 0 || _repeatCount > 1) {
					_currentTime = -_repeatDelay;
					_currentCycle++;
					if(_repeatCount > 1) {
						_repeatCount--;
					}
					if(_onRepeat != null) {
						_onRepeat.apply(this,_onRepeatArgs);
					}
				} else {
					_local5 = _onComplete;
					_local8 = _onCompleteArgs;
					dispatchEventWith("removeFromJuggler");
					if(_local5 != null) {
						_local5.apply(this,_local8);
					}
					if(_currentTime == 0) {
						_local10 = 0;
					}
				}
			}
			if(_local10) {
				advanceTime(_local10);
			}
		}
		
		private function getUpdateFuncFromProperty(property:String) : Function {
			var _local3:Function = null;
			var _local2:String = getPropertyHint(property);
			switch(_local2) {
				case null:
					_local3 = updateStandard;
					break;
				case "rgb":
					_local3 = updateRgb;
					break;
				case "rad":
					_local3 = updateRad;
					break;
				case "deg":
					_local3 = updateDeg;
					break;
				default:
					trace("[Starling] Ignoring unknown property hint:",_local2);
					_local3 = updateStandard;
			}
			return _local3;
		}
		
		private function updateStandard(property:String, startValue:Number, endValue:Number) : void {
			var _local4:Number = startValue + _progress * (endValue - startValue);
			if(_roundToInt) {
				_local4 = Math.round(_local4);
			}
			_target[property] = _local4;
		}
		
		private function updateRgb(property:String, startValue:Number, endValue:Number) : void {
			_target[property] = Color.interpolate(uint(startValue),uint(endValue),_progress);
		}
		
		private function updateRad(property:String, startValue:Number, endValue:Number) : void {
			updateAngle(3.141592653589793,property,startValue,endValue);
		}
		
		private function updateDeg(property:String, startValue:Number, endValue:Number) : void {
			updateAngle(3 * 60,property,startValue,endValue);
		}
		
		private function updateAngle(pi:Number, property:String, startValue:Number, endValue:Number) : void {
			while(Math.abs(endValue - startValue) > pi) {
				if(startValue < endValue) {
					endValue -= 2 * pi;
				} else {
					endValue += 2 * pi;
				}
			}
			updateStandard(property,startValue,endValue);
		}
		
		public function getEndValue(property:String) : Number {
			var _local2:int = int(_properties.indexOf(property));
			if(_local2 == -1) {
				throw new ArgumentError("The property \'" + property + "\' is not animated");
			}
			return _endValues[_local2] as Number;
		}
		
		public function get isComplete() : Boolean {
			return _currentTime >= _totalTime && _repeatCount == 1;
		}
		
		public function get target() : Object {
			return _target;
		}
		
		public function get transition() : String {
			return _transitionName;
		}
		
		public function set transition(value:String) : void {
			_transitionName = value;
			_transitionFunc = Transitions.getTransition(value);
			if(_transitionFunc == null) {
				throw new ArgumentError("Invalid transiton: " + value);
			}
		}
		
		public function get transitionFunc() : Function {
			return _transitionFunc;
		}
		
		public function set transitionFunc(value:Function) : void {
			_transitionName = "custom";
			_transitionFunc = value;
		}
		
		public function get totalTime() : Number {
			return _totalTime;
		}
		
		public function get currentTime() : Number {
			return _currentTime;
		}
		
		public function get progress() : Number {
			return _progress;
		}
		
		public function get delay() : Number {
			return _delay;
		}
		
		public function set delay(value:Number) : void {
			_currentTime = _currentTime + _delay - value;
			_delay = value;
		}
		
		public function get repeatCount() : int {
			return _repeatCount;
		}
		
		public function set repeatCount(value:int) : void {
			_repeatCount = value;
		}
		
		public function get repeatDelay() : Number {
			return _repeatDelay;
		}
		
		public function set repeatDelay(value:Number) : void {
			_repeatDelay = value;
		}
		
		public function get reverse() : Boolean {
			return _reverse;
		}
		
		public function set reverse(value:Boolean) : void {
			_reverse = value;
		}
		
		public function get roundToInt() : Boolean {
			return _roundToInt;
		}
		
		public function set roundToInt(value:Boolean) : void {
			_roundToInt = value;
		}
		
		public function get onStart() : Function {
			return _onStart;
		}
		
		public function set onStart(value:Function) : void {
			_onStart = value;
		}
		
		public function get onUpdate() : Function {
			return _onUpdate;
		}
		
		public function set onUpdate(value:Function) : void {
			_onUpdate = value;
		}
		
		public function get onRepeat() : Function {
			return _onRepeat;
		}
		
		public function set onRepeat(value:Function) : void {
			_onRepeat = value;
		}
		
		public function get onComplete() : Function {
			return _onComplete;
		}
		
		public function set onComplete(value:Function) : void {
			_onComplete = value;
		}
		
		public function get onStartArgs() : Array {
			return _onStartArgs;
		}
		
		public function set onStartArgs(value:Array) : void {
			_onStartArgs = value;
		}
		
		public function get onUpdateArgs() : Array {
			return _onUpdateArgs;
		}
		
		public function set onUpdateArgs(value:Array) : void {
			_onUpdateArgs = value;
		}
		
		public function get onRepeatArgs() : Array {
			return _onRepeatArgs;
		}
		
		public function set onRepeatArgs(value:Array) : void {
			_onRepeatArgs = value;
		}
		
		public function get onCompleteArgs() : Array {
			return _onCompleteArgs;
		}
		
		public function set onCompleteArgs(value:Array) : void {
			_onCompleteArgs = value;
		}
		
		public function get nextTween() : Tween {
			return _nextTween;
		}
		
		public function set nextTween(value:Tween) : void {
			_nextTween = value;
		}
	}
}

