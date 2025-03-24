package com.greensock {
	import com.greensock.core.Animation;
	import com.greensock.core.PropTween;
	import com.greensock.core.SimpleTimeline;
	import com.greensock.events.TweenEvent;
	import com.greensock.plugins.*;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.getTimer;
	
	public class TweenMax extends TweenLite implements IEventDispatcher {
		public static const version:String = "12.1.4";
		
		protected static var _listenerLookup:Object = {
			"onCompleteListener":"complete",
			"onUpdateListener":"change",
			"onStartListener":"start",
			"onRepeatListener":"repeat",
			"onReverseCompleteListener":"reverseComplete"
		};
		
		public static var ticker:Shape = Animation.ticker;
		
		public static var allTo:Function = staggerTo;
		
		public static var allFrom:Function = staggerFrom;
		
		public static var allFromTo:Function = staggerFromTo;
		
		TweenPlugin.activate([AutoAlphaPlugin,EndArrayPlugin,FramePlugin,RemoveTintPlugin,TintPlugin,VisiblePlugin,VolumePlugin,BevelFilterPlugin,BezierPlugin,BezierThroughPlugin,BlurFilterPlugin,ColorMatrixFilterPlugin,ColorTransformPlugin,DropShadowFilterPlugin,FrameLabelPlugin,GlowFilterPlugin,HexColorsPlugin,RoundPropsPlugin,ShortRotationPlugin]);
		
		protected var _dispatcher:EventDispatcher;
		
		protected var _hasUpdateListener:Boolean;
		
		protected var _repeat:int = 0;
		
		protected var _repeatDelay:Number = 0;
		
		protected var _cycle:int = 0;
		
		public var _yoyo:Boolean;
		
		public function TweenMax(target:Object, duration:Number, vars:Object) {
			super(target,duration,vars);
			_yoyo = this.vars.yoyo == true;
			_repeat = int(this.vars.repeat);
			_repeatDelay = this.vars.repeatDelay || 0;
			_dirty = true;
			if(this.vars.onCompleteListener || this.vars.onUpdateListener || this.vars.onStartListener || this.vars.onRepeatListener || this.vars.onReverseCompleteListener) {
				_initDispatcher();
				if(_duration == 0) {
					if(_delay == 0) {
						if(this.vars.immediateRender) {
							_dispatcher.dispatchEvent(new TweenEvent("change"));
							_dispatcher.dispatchEvent(new TweenEvent("complete"));
						}
					}
				}
			}
		}
		
		public static function killTweensOf(target:*, onlyActive:* = false, vars:Object = null) : void {
			TweenLite.killTweensOf(target,onlyActive,vars);
		}
		
		public static function killDelayedCallsTo(func:Function) : void {
			TweenLite.killTweensOf(func);
		}
		
		public static function getTweensOf(target:*, onlyActive:Boolean = false) : Array {
			return TweenLite.getTweensOf(target,onlyActive);
		}
		
		public static function to(target:Object, duration:Number, vars:Object) : TweenMax {
			return new TweenMax(target,duration,vars);
		}
		
		public static function from(target:Object, duration:Number, vars:Object) : TweenMax {
			vars = _prepVars(vars,true);
			vars.runBackwards = true;
			return new TweenMax(target,duration,vars);
		}
		
		public static function fromTo(target:Object, duration:Number, fromVars:Object, toVars:Object) : TweenMax {
			toVars = _prepVars(toVars,false);
			fromVars = _prepVars(fromVars,false);
			toVars.startAt = fromVars;
			toVars.immediateRender = toVars.immediateRender != false && fromVars.immediateRender != false;
			return new TweenMax(target,duration,toVars);
		}
		
		public static function staggerTo(targets:Array, duration:Number, vars:Object, stagger:Number = 0, onCompleteAll:Function = null, onCompleteAllParams:Array = null) : Array {
			var copy:Object;
			var p:String;
			vars = _prepVars(vars,false);
			var a:Array = [];
			var l:int = int(targets.length);
			var delay:Number = Number(vars.delay || 0);
			var i:int = 0;
			while(i < l) {
				copy = {};
				for(p in vars) {
					copy[p] = vars[p];
				}
				copy.delay = delay;
				if(i == l - 1) {
					if(onCompleteAll != null) {
						copy.onComplete = function():void {
							if(vars.onComplete) {
								vars.onComplete.apply(null,arguments);
							}
							onCompleteAll.apply(null,onCompleteAllParams);
						};
					}
				}
				a[i] = new TweenMax(targets[i],duration,copy);
				delay += stagger;
				i++;
			}
			return a;
		}
		
		public static function staggerFrom(targets:Array, duration:Number, vars:Object, stagger:Number = 0, onCompleteAll:Function = null, onCompleteAllParams:Array = null) : Array {
			vars = _prepVars(vars,true);
			vars.runBackwards = true;
			if(vars.immediateRender != false) {
				vars.immediateRender = true;
			}
			return staggerTo(targets,duration,vars,stagger,onCompleteAll,onCompleteAllParams);
		}
		
		public static function staggerFromTo(targets:Array, duration:Number, fromVars:Object, toVars:Object, stagger:Number = 0, onCompleteAll:Function = null, onCompleteAllParams:Array = null) : Array {
			toVars = _prepVars(toVars,false);
			fromVars = _prepVars(fromVars,false);
			toVars.startAt = fromVars;
			toVars.immediateRender = toVars.immediateRender != false && fromVars.immediateRender != false;
			return staggerTo(targets,duration,toVars,stagger,onCompleteAll,onCompleteAllParams);
		}
		
		public static function delayedCall(delay:Number, callback:Function, params:Array = null, useFrames:Boolean = false) : TweenMax {
			return new TweenMax(callback,0,{
				"delay":delay,
				"onComplete":callback,
				"onCompleteParams":params,
				"onReverseComplete":callback,
				"onReverseCompleteParams":params,
				"immediateRender":false,
				"useFrames":useFrames,
				"overwrite":0
			});
		}
		
		public static function set(target:Object, vars:Object) : TweenMax {
			return new TweenMax(target,0,vars);
		}
		
		public static function isTweening(target:Object) : Boolean {
			return TweenLite.getTweensOf(target,true).length > 0;
		}
		
		public static function getAllTweens(includeTimelines:Boolean = false) : Array {
			var _local2:Array = _getChildrenOf(_rootTimeline,includeTimelines);
			return _local2.concat(_getChildrenOf(_rootFramesTimeline,includeTimelines));
		}
		
		protected static function _getChildrenOf(timeline:SimpleTimeline, includeTimelines:Boolean) : Array {
			if(timeline == null) {
				return [];
			}
			var _local4:Array = [];
			var _local5:int = 0;
			var _local3:Animation = timeline._first;
			while(_local3) {
				if(_local3 is TweenLite) {
					_local4[_local5++] = _local3;
				} else {
					if(includeTimelines) {
						_local4[_local5++] = _local3;
					}
					_local4 = _local4.concat(_getChildrenOf(SimpleTimeline(_local3),includeTimelines));
					_local5 = int(_local4.length);
				}
				_local3 = _local3._next;
			}
			return _local4;
		}
		
		public static function killAll(complete:Boolean = false, tweens:Boolean = true, delayedCalls:Boolean = true, timelines:Boolean = true) : void {
			var _local7:Boolean = false;
			var _local6:Animation = null;
			var _local8:int = 0;
			var _local5:Array = null;
			_local5 = getAllTweens(timelines);
			var _local9:int = int(_local5.length);
			var _local10:Boolean = tweens && delayedCalls && timelines;
			_local8 = 0;
			while(_local8 < _local9) {
				_local6 = _local5[_local8];
				if(_local10 || _local6 is SimpleTimeline || (_local7 = TweenLite(_local6).target == TweenLite(_local6).vars.onComplete) && delayedCalls || tweens && !_local7) {
					if(complete) {
						_local6.totalTime(_local6.totalDuration());
					} else {
						_local6._enabled(false,false);
					}
				}
				_local8++;
			}
		}
		
		public static function killChildTweensOf(parent:DisplayObjectContainer, complete:Boolean = false) : void {
			var _local4:int = 0;
			var _local3:Array = null;
			_local3 = getAllTweens(false);
			var _local5:int = int(_local3.length);
			_local4 = 0;
			while(_local4 < _local5) {
				if(_containsChildOf(parent,_local3[_local4].target)) {
					if(complete) {
						_local3[_local4].totalTime(_local3[_local4].totalDuration());
					} else {
						_local3[_local4]._enabled(false,false);
					}
				}
				_local4++;
			}
		}
		
		private static function _containsChildOf(parent:DisplayObjectContainer, obj:Object) : Boolean {
			var _local4:DisplayObjectContainer = null;
			var _local3:int = 0;
			if(obj is Array) {
				_local3 = int(obj.length);
				while(true) {
					_local3--;
					if(_local3 <= -1) {
						break;
					}
					if(_containsChildOf(parent,obj[_local3])) {
						return true;
					}
				}
			} else if(obj is DisplayObject) {
				_local4 = obj.parent;
				while(_local4) {
					if(_local4 == parent) {
						return true;
					}
					_local4 = _local4.parent;
				}
			}
			return false;
		}
		
		public static function pauseAll(tweens:Boolean = true, delayedCalls:Boolean = true, timelines:Boolean = true) : void {
			_changePause(true,tweens,delayedCalls,timelines);
		}
		
		public static function resumeAll(tweens:Boolean = true, delayedCalls:Boolean = true, timelines:Boolean = true) : void {
			_changePause(false,tweens,delayedCalls,timelines);
		}
		
		private static function _changePause(pause:Boolean, tweens:Boolean = true, delayedCalls:Boolean = false, timelines:Boolean = true) : void {
			var _local7:Boolean = false;
			var _local5:Animation = null;
			var _local6:Array = null;
			_local6 = getAllTweens(timelines);
			var _local9:Boolean = tweens && delayedCalls && timelines;
			var _local8:int = int(_local6.length);
			while(true) {
				_local8--;
				if(_local8 <= -1) {
					break;
				}
				_local5 = _local6[_local8];
				_local7 = _local5 is TweenLite && TweenLite(_local5).target == _local5.vars.onComplete;
				if(_local9 || _local5 is SimpleTimeline || _local7 && delayedCalls || tweens && !_local7) {
					_local5.paused(pause);
				}
			}
		}
		
		public static function globalTimeScale(value:Number = NaN) : Number {
			if(!arguments.length) {
				return _rootTimeline == null ? 1 : _rootTimeline._timeScale;
			}
			value ||= 0.0001;
			if(_rootTimeline == null) {
				TweenLite.to({},0,{});
			}
			var _local4:SimpleTimeline = _rootTimeline;
			var _local3:Number = getTimer() / 1000;
			_local4._startTime = _local3 - (_local3 - _local4._startTime) * _local4._timeScale / value;
			_local4 = _rootFramesTimeline;
			_local3 = _rootFrame;
			_local4._startTime = _local3 - (_local3 - _local4._startTime) * _local4._timeScale / value;
			_rootFramesTimeline._timeScale = _rootTimeline._timeScale = value;
			return value;
		}
		
		override public function invalidate() : * {
			_yoyo = this.vars.yoyo == true;
			_repeat = this.vars.repeat || 0;
			_repeatDelay = this.vars.repeatDelay || 0;
			_hasUpdateListener = false;
			_initDispatcher();
			_uncache(true);
			return super.invalidate();
		}
		
		public function updateTo(vars:Object, resetDuration:Boolean = false) : * {
			var _local7:Number = NaN;
			var _local6:Number = NaN;
			var _local4:Number = NaN;
			var _local8:Number = ratio;
			if(resetDuration) {
				if(_startTime < _timeline._time) {
					_startTime = _timeline._time;
					_uncache(false);
					if(_gc) {
						_enabled(true,false);
					} else {
						_timeline.insert(this,_startTime - _delay);
					}
				}
			}
			for(var _local3 in vars) {
				this.vars[_local3] = vars[_local3];
			}
			if(_initted) {
				if(resetDuration) {
					_initted = false;
				} else {
					if(_gc) {
						_enabled(true,false);
					}
					if(_notifyPluginsOfEnabled) {
						if(_firstPT != null) {
							_onPluginEvent("_onDisable",this);
						}
					}
					if(_time / _duration > 0.998) {
						_local7 = _time;
						render(0,true,false);
						_initted = false;
						render(_local7,true,false);
					} else if(_time > 0) {
						_initted = false;
						_init();
						_local4 = 1 / (1 - _local8);
						var _local5:PropTween = _firstPT;
						while(_local5) {
							_local6 = _local5.s + _local5.c;
							_local5.c *= _local4;
							_local5.s = _local6 - _local5.c;
							_local5 = _local5._next;
						}
					}
				}
			}
			return this;
		}
		
		override public function render(time:Number, suppressEvents:Boolean = false, force:Boolean = false) : void {
			var _local15:Boolean = false;
			var _local13:String = null;
			var _local5:PropTween = null;
			var _local12:Number = NaN;
			var _local11:Number = NaN;
			var _local10:Number = NaN;
			if(!_initted) {
				if(_duration === 0 && vars.repeat) {
					invalidate();
				}
			}
			var _local7:Number = Number(!_dirty ? _totalDuration : totalDuration());
			var _local6:Number = _time;
			var _local9:Number = _totalTime;
			var _local4:Number = _cycle;
			if(time >= _local7) {
				_totalTime = _local7;
				_cycle = _repeat;
				if(_yoyo && (_cycle & 1) != 0) {
					_time = 0;
					ratio = _ease._calcEnd ? _ease.getRatio(0) : 0;
				} else {
					_time = _duration;
					ratio = _ease._calcEnd ? _ease.getRatio(1) : 1;
				}
				if(!_reversed) {
					_local15 = true;
					_local13 = "onComplete";
				}
				if(_duration == 0) {
					_local12 = _rawPrevTime;
					if(_startTime === _timeline._duration) {
						time = 0;
					}
					if(time === 0 || _local12 < 0 || _local12 === _tinyNum) {
						if(_local12 !== time) {
							force = true;
							if(_local12 > _tinyNum) {
								_local13 = "onReverseComplete";
							}
						}
					}
					_rawPrevTime = _local12 = !suppressEvents || time !== 0 || _rawPrevTime === time ? time : _tinyNum;
				}
			} else if(time < 1e-7) {
				_totalTime = _time = _cycle = 0;
				ratio = _ease._calcEnd ? _ease.getRatio(0) : 0;
				if(_local9 !== 0 || _duration === 0 && _rawPrevTime > 0 && _rawPrevTime !== _tinyNum) {
					_local13 = "onReverseComplete";
					_local15 = _reversed;
				}
				if(time < 0) {
					_active = false;
					if(_duration == 0) {
						if(_rawPrevTime >= 0) {
							force = true;
						}
						_rawPrevTime = _local12 = !suppressEvents || time !== 0 || _rawPrevTime === time ? time : _tinyNum;
					}
				} else if(!_initted) {
					force = true;
				}
			} else {
				_totalTime = _time = time;
				if(_repeat != 0) {
					_local11 = _duration + _repeatDelay;
					_cycle = _totalTime / _local11 >> 0;
					if(_cycle !== 0) {
						if(_cycle === _totalTime / _local11) {
							_cycle--;
						}
					}
					_time = _totalTime - _cycle * _local11;
					if(_yoyo) {
						if((_cycle & 1) != 0) {
							_time = _duration - _time;
						}
					}
					if(_time > _duration) {
						_time = _duration;
					} else if(_time < 0) {
						_time = 0;
					}
				}
				if(_easeType) {
					_local10 = _time / _duration;
					var _local8:int = _easeType;
					var _local14:int = _easePower;
					if(_local8 == 1 || _local8 == 3 && _local10 >= 0.5) {
						_local10 = 1 - _local10;
					}
					if(_local8 == 3) {
						_local10 *= 2;
					}
					if(_local14 == 1) {
						_local10 *= _local10;
					} else if(_local14 == 2) {
						_local10 *= _local10 * _local10;
					} else if(_local14 == 3) {
						_local10 *= _local10 * _local10 * _local10;
					} else if(_local14 == 4) {
						_local10 *= _local10 * _local10 * _local10 * _local10;
					}
					if(_local8 == 1) {
						ratio = 1 - _local10;
					} else if(_local8 == 2) {
						ratio = _local10;
					} else if(_time / _duration < 0.5) {
						ratio = _local10 / 2;
					} else {
						ratio = 1 - _local10 / 2;
					}
				} else {
					ratio = _ease.getRatio(_time / _duration);
				}
			}
			if(_local6 == _time && !force && _cycle === _local4) {
				if(_local9 !== _totalTime) {
					if(_onUpdate != null) {
						if(!suppressEvents) {
							_onUpdate.apply(vars.onUpdateScope || this,vars.onUpdateParams);
						}
					}
				}
				return;
			}
			if(!_initted) {
				_init();
				if(!_initted || _gc) {
					return;
				}
				if(_time && !_local15) {
					ratio = _ease.getRatio(_time / _duration);
				} else if(_local15 && _ease._calcEnd) {
					ratio = _ease.getRatio(_time === 0 ? 0 : 1);
				}
			}
			if(!_active) {
				if(!_paused && _time !== _local6 && time >= 0) {
					_active = true;
				}
			}
			if(_local9 == 0) {
				if(_startAt != null) {
					if(time >= 0) {
						_startAt.render(time,suppressEvents,force);
					} else if(!_local13) {
						_local13 = "_dummyGS";
					}
				}
				if(_totalTime != 0 || _duration == 0) {
					if(!suppressEvents) {
						if(vars.onStart) {
							vars.onStart.apply(null,vars.onStartParams);
						}
						if(_dispatcher) {
							_dispatcher.dispatchEvent(new TweenEvent("start"));
						}
					}
				}
			}
			_local5 = _firstPT;
			while(_local5) {
				if(_local5.f) {
					_local5.t[_local5.p](_local5.c * ratio + _local5.s);
				} else {
					_local5.t[_local5.p] = _local5.c * ratio + _local5.s;
				}
				_local5 = _local5._next;
			}
			if(_onUpdate != null) {
				if(time < 0 && _startAt != null && _startTime != 0) {
					_startAt.render(time,suppressEvents,force);
				}
				if(!suppressEvents) {
					if(_totalTime !== _local9 || _local15) {
						_onUpdate.apply(null,vars.onUpdateParams);
					}
				}
			}
			if(_hasUpdateListener) {
				if(time < 0 && _startAt != null && _onUpdate == null && _startTime != 0) {
					_startAt.render(time,suppressEvents,force);
				}
				if(!suppressEvents) {
					_dispatcher.dispatchEvent(new TweenEvent("change"));
				}
			}
			if(_cycle != _local4) {
				if(!suppressEvents) {
					if(!_gc) {
						if(vars.onRepeat) {
							vars.onRepeat.apply(null,vars.onRepeatParams);
						}
						if(_dispatcher) {
							_dispatcher.dispatchEvent(new TweenEvent("repeat"));
						}
					}
				}
			}
			if(_local13) {
				if(!_gc) {
					if(time < 0 && _startAt != null && _onUpdate == null && !_hasUpdateListener && _startTime != 0) {
						_startAt.render(time,suppressEvents,true);
					}
					if(_local15) {
						if(_timeline.autoRemoveChildren) {
							_enabled(false,false);
						}
						_active = false;
					}
					if(!suppressEvents) {
						if(vars[_local13]) {
							vars[_local13].apply(null,vars[_local13 + "Params"]);
						}
						if(_dispatcher) {
							_dispatcher.dispatchEvent(new TweenEvent(_local13 == "onComplete" ? "complete" : "reverseComplete"));
						}
					}
					if(_duration === 0 && _rawPrevTime === _tinyNum && _local12 !== _tinyNum) {
						_rawPrevTime = 0;
					}
				}
			}
		}
		
		protected function _initDispatcher() : Boolean {
			var _local1:String = null;
			var _local2:Boolean = false;
			for(_local1 in _listenerLookup) {
				if(_local1 in vars) {
					if(vars[_local1] is Function) {
						if(_dispatcher == null) {
							_dispatcher = new EventDispatcher(this);
						}
						_dispatcher.addEventListener(_listenerLookup[_local1],vars[_local1],false,0,true);
						_local2 = true;
					}
				}
			}
			return _local2;
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false) : void {
			if(_dispatcher == null) {
				_dispatcher = new EventDispatcher(this);
			}
			if(type == "change") {
				_hasUpdateListener = true;
			}
			_dispatcher.addEventListener(type,listener,useCapture,priority,useWeakReference);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false) : void {
			if(_dispatcher) {
				_dispatcher.removeEventListener(type,listener,useCapture);
			}
		}
		
		public function hasEventListener(type:String) : Boolean {
			return _dispatcher == null ? false : _dispatcher.hasEventListener(type);
		}
		
		public function willTrigger(type:String) : Boolean {
			return _dispatcher == null ? false : _dispatcher.willTrigger(type);
		}
		
		public function dispatchEvent(event:Event) : Boolean {
			return _dispatcher == null ? false : _dispatcher.dispatchEvent(event);
		}
		
		override public function progress(value:Number = NaN, suppressEvents:Boolean = false) : * {
			return !arguments.length ? _time / duration() : totalTime(duration() * (_yoyo && (_cycle & 1) !== 0 ? 1 - value : value) + _cycle * (_duration + _repeatDelay),suppressEvents);
		}
		
		override public function totalProgress(value:Number = NaN, suppressEvents:Boolean = false) : * {
			return !arguments.length ? _totalTime / totalDuration() : totalTime(totalDuration() * value,suppressEvents);
		}
		
		override public function time(value:Number = NaN, suppressEvents:Boolean = false) : * {
			if(!arguments.length) {
				return _time;
			}
			if(_dirty) {
				totalDuration();
			}
			if(value > _duration) {
				value = _duration;
			}
			if(_yoyo && (_cycle & 1) !== 0) {
				value = _duration - value + _cycle * (_duration + _repeatDelay);
			} else if(_repeat != 0) {
				value += _cycle * (_duration + _repeatDelay);
			}
			return totalTime(value,suppressEvents);
		}
		
		override public function duration(value:Number = NaN) : * {
			if(!arguments.length) {
				return this._duration;
			}
			return super.duration(value);
		}
		
		override public function totalDuration(value:Number = NaN) : * {
			if(!arguments.length) {
				if(_dirty) {
					_totalDuration = _repeat == -1 ? 999999999999 : _duration * (_repeat + 1) + _repeatDelay * _repeat;
					_dirty = false;
				}
				return _totalDuration;
			}
			return _repeat == -1 ? this : duration((value - _repeat * _repeatDelay) / (_repeat + 1));
		}
		
		public function repeat(value:int = 0) : * {
			if(!arguments.length) {
				return _repeat;
			}
			_repeat = value;
			return _uncache(true);
		}
		
		public function repeatDelay(value:Number = NaN) : * {
			if(!arguments.length) {
				return _repeatDelay;
			}
			_repeatDelay = value;
			return _uncache(true);
		}
		
		public function yoyo(value:Boolean = false) : * {
			if(!arguments.length) {
				return _yoyo;
			}
			_yoyo = value;
			return this;
		}
	}
}

