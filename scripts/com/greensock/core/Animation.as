package com.greensock.core {
	import flash.display.Shape;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	public class Animation {
		public static const version:String = "12.1.1";
		
		public static var _rootTimeline:SimpleTimeline;
		
		public static var _rootFramesTimeline:SimpleTimeline;
		
		protected static var _rootFrame:Number = -1;
		
		protected static var _tinyNum:Number = 1e-10;
		
		public static var ticker:Shape = new Shape();
		
		protected static var _tickEvent:Event = new Event("tick");
		
		protected var _onUpdate:Function;
		
		public var _delay:Number;
		
		public var _rawPrevTime:Number;
		
		public var _active:Boolean;
		
		public var _gc:Boolean;
		
		public var _initted:Boolean;
		
		public var _startTime:Number;
		
		public var _time:Number;
		
		public var _totalTime:Number;
		
		public var _duration:Number;
		
		public var _totalDuration:Number;
		
		public var _pauseTime:Number;
		
		public var _timeScale:Number;
		
		public var _reversed:Boolean;
		
		public var _timeline:SimpleTimeline;
		
		public var _dirty:Boolean;
		
		public var _paused:Boolean;
		
		public var _next:Animation;
		
		public var _prev:Animation;
		
		public var vars:Object;
		
		public var timeline:SimpleTimeline;
		
		public var data:*;
		
		public function Animation(duration:Number = 0, vars:Object = null) {
			super();
			this.vars = vars || {};
			if(this.vars._isGSVars) {
				this.vars = this.vars.vars;
			}
			_duration = _totalDuration = duration || 0;
			_delay = Number(this.vars.delay) || 0;
			_timeScale = 1;
			_totalTime = _time = 0;
			data = this.vars.data;
			_rawPrevTime = -1;
			if(_rootTimeline == null) {
				if(_rootFrame != -1) {
					return;
				}
				_rootFrame = 0;
				_rootFramesTimeline = new SimpleTimeline();
				_rootTimeline = new SimpleTimeline();
				_rootTimeline._startTime = getTimer() / 1000;
				_rootFramesTimeline._startTime = 0;
				_rootTimeline._active = _rootFramesTimeline._active = true;
				ticker.addEventListener("enterFrame",_updateRoot,false,0,true);
			}
			var _local3:SimpleTimeline = !!this.vars.useFrames ? _rootFramesTimeline : _rootTimeline;
			_local3.add(this,_local3._time);
			_reversed = this.vars.reversed == true;
			if(this.vars.paused) {
				paused(true);
			}
		}
		
		public static function _updateRoot(event:Event = null) : void {
			_rootFrame++;
			_rootTimeline.render((getTimer() / 1000 - _rootTimeline._startTime) * _rootTimeline._timeScale,false,false);
			_rootFramesTimeline.render((_rootFrame - _rootFramesTimeline._startTime) * _rootFramesTimeline._timeScale,false,false);
			ticker.dispatchEvent(_tickEvent);
		}
		
		public function play(from:* = null, suppressEvents:Boolean = true) : * {
			if(from != null) {
				seek(from,suppressEvents);
			}
			reversed(false);
			return paused(false);
		}
		
		public function pause(atTime:* = null, suppressEvents:Boolean = true) : * {
			if(atTime != null) {
				seek(atTime,suppressEvents);
			}
			return paused(true);
		}
		
		public function resume(from:* = null, suppressEvents:Boolean = true) : * {
			if(from != null) {
				seek(from,suppressEvents);
			}
			return paused(false);
		}
		
		public function seek(time:*, suppressEvents:Boolean = true) : * {
			return totalTime(time,suppressEvents);
		}
		
		public function restart(includeDelay:Boolean = false, suppressEvents:Boolean = true) : * {
			reversed(false);
			paused(false);
			return totalTime(includeDelay ? -_delay : 0,suppressEvents,true);
		}
		
		public function reverse(from:* = null, suppressEvents:Boolean = true) : * {
			if(from != null) {
				seek(from || totalDuration(),suppressEvents);
			}
			reversed(true);
			return paused(false);
		}
		
		public function render(time:Number, suppressEvents:Boolean = false, force:Boolean = false) : void {
		}
		
		public function invalidate() : * {
			return this;
		}
		
		public function isActive() : Boolean {
			var _local1:Number = NaN;
			var _local2:SimpleTimeline = _timeline;
			return _local2 == null || !_gc && !_paused && _local2.isActive() && (_local1 = _local2.rawTime()) >= _startTime && _local1 < _startTime + totalDuration() / _timeScale;
		}
		
		public function _enabled(enabled:Boolean, ignoreTimeline:Boolean = false) : Boolean {
			_gc = !enabled;
			_active = enabled && !_paused && _totalTime > 0 && _totalTime < _totalDuration;
			if(!ignoreTimeline) {
				if(enabled && timeline == null) {
					_timeline.add(this,_startTime - _delay);
				} else if(!enabled && timeline != null) {
					_timeline._remove(this,true);
				}
			}
			return false;
		}
		
		public function _kill(vars:Object = null, target:Object = null) : Boolean {
			return _enabled(false,false);
		}
		
		public function kill(vars:Object = null, target:Object = null) : * {
			_kill(vars,target);
			return this;
		}
		
		protected function _uncache(includeSelf:Boolean) : * {
			var _local2:Animation = includeSelf ? this : timeline;
			while(_local2) {
				_local2._dirty = true;
				_local2 = _local2.timeline;
			}
			return this;
		}
		
		protected function _swapSelfInParams(params:Array) : Array {
			var _local2:int = int(params.length);
			var _local3:Array = params.concat();
			while(true) {
				_local2--;
				if(_local2 <= -1) {
					break;
				}
				if(params[_local2] === "{self}") {
					_local3[_local2] = this;
				}
			}
			return _local3;
		}
		
		public function eventCallback(type:String, callback:Function = null, params:Array = null) : * {
			if(type == null) {
				return null;
			}
			if(type.substr(0,2) == "on") {
				if(arguments.length == 1) {
					return vars[type];
				}
				if(callback == null) {
					delete vars[type];
				} else {
					vars[type] = callback;
					vars[type + "Params"] = params is Array && params.join("").indexOf("{self}") !== -1 ? _swapSelfInParams(params) : params;
				}
				if(type == "onUpdate") {
					_onUpdate = callback;
				}
			}
			return this;
		}
		
		public function delay(value:Number = NaN) : * {
			if(!arguments.length) {
				return _delay;
			}
			if(_timeline.smoothChildTiming) {
				startTime(_startTime + value - _delay);
			}
			_delay = value;
			return this;
		}
		
		public function duration(value:Number = NaN) : * {
			if(!arguments.length) {
				_dirty = false;
				return _duration;
			}
			_duration = _totalDuration = value;
			_uncache(true);
			if(_timeline.smoothChildTiming) {
				if(_time > 0) {
					if(_time < _duration) {
						if(value != 0) {
							totalTime(_totalTime * (value / _duration),true);
						}
					}
				}
			}
			return this;
		}
		
		public function totalDuration(value:Number = NaN) : * {
			_dirty = false;
			return !arguments.length ? _totalDuration : duration(value);
		}
		
		public function time(value:Number = NaN, suppressEvents:Boolean = false) : * {
			if(!arguments.length) {
				return _time;
			}
			if(_dirty) {
				totalDuration();
			}
			if(value > _duration) {
				value = _duration;
			}
			return totalTime(value,suppressEvents);
		}
		
		public function totalTime(time:Number = NaN, suppressEvents:Boolean = false, uncapped:Boolean = false) : * {
			var _local5:SimpleTimeline = null;
			if(!arguments.length) {
				return _totalTime;
			}
			if(_timeline) {
				if(time < 0 && !uncapped) {
					time += totalDuration();
				}
				if(_timeline.smoothChildTiming) {
					if(_dirty) {
						totalDuration();
					}
					if(time > _totalDuration && !uncapped) {
						time = _totalDuration;
					}
					_local5 = _timeline;
					_startTime = (_paused ? _pauseTime : _local5._time) - (!_reversed ? time : _totalDuration - time) / _timeScale;
					if(!_timeline._dirty) {
						_uncache(false);
					}
					if(_local5._timeline != null) {
						while(_local5._timeline) {
							if(_local5._timeline._time !== (_local5._startTime + _local5._totalTime) / _local5._timeScale) {
								_local5.totalTime(_local5._totalTime,true);
							}
							_local5 = _local5._timeline;
						}
					}
				}
				if(_gc) {
					_enabled(true,false);
				}
				if(_totalTime != time || _duration === 0) {
					render(time,suppressEvents,false);
				}
			}
			return this;
		}
		
		public function progress(value:Number = NaN, suppressEvents:Boolean = false) : * {
			return !arguments.length ? _time / duration() : totalTime(duration() * value,suppressEvents);
		}
		
		public function totalProgress(value:Number = NaN, suppressEvents:Boolean = false) : * {
			return !arguments.length ? _time / duration() : totalTime(duration() * value,suppressEvents);
		}
		
		public function startTime(value:Number = NaN) : * {
			if(!arguments.length) {
				return _startTime;
			}
			if(value != _startTime) {
				_startTime = value;
				if(timeline) {
					if(timeline._sortChildren) {
						timeline.add(this,value - _delay);
					}
				}
			}
			return this;
		}
		
		public function timeScale(value:Number = NaN) : * {
			var _local3:Number = NaN;
			if(!arguments.length) {
				return _timeScale;
			}
			value ||= 0.000001;
			if(_timeline && _timeline.smoothChildTiming) {
				_local3 = _pauseTime || _pauseTime == 0 ? _pauseTime : _timeline._totalTime;
				_startTime = _local3 - (_local3 - _startTime) * _timeScale / value;
			}
			_timeScale = value;
			return _uncache(false);
		}
		
		public function reversed(value:Boolean = false) : * {
			if(!arguments.length) {
				return _reversed;
			}
			if(value != _reversed) {
				_reversed = value;
				totalTime(_timeline && !_timeline.smoothChildTiming ? totalDuration() - _totalTime : _totalTime,true);
			}
			return this;
		}
		
		public function paused(value:Boolean = false) : * {
			var _local4:Number = NaN;
			if(!arguments.length) {
				return _paused;
			}
			if(value != _paused) {
				if(_timeline) {
					_local4 = _timeline.rawTime();
					var _local3:Number = _local4 - _pauseTime;
					if(!value && _timeline.smoothChildTiming) {
						_startTime += _local3;
						_uncache(false);
					}
					_pauseTime = value ? _local4 : NaN;
					_paused = value;
					_active = !value && _totalTime > 0 && _totalTime < _totalDuration;
					if(!value && _local3 != 0 && _initted && duration() !== 0) {
						render(_timeline.smoothChildTiming ? _totalTime : (_local4 - _startTime) / _timeScale,true,true);
					}
				}
			}
			if(_gc && !value) {
				_enabled(true,false);
			}
			return this;
		}
	}
}

