package com.greensock {
	import com.greensock.core.Animation;
	import com.greensock.core.PropTween;
	import com.greensock.core.SimpleTimeline;
	import com.greensock.easing.Ease;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	public class TweenLite extends Animation {
		public static const version:String = "12.1.4";
		
		public static var defaultOverwrite:String = "auto";
		
		public static var _onPluginEvent:Function;
		
		protected static var _overwriteLookup:Object;
		
		public static var defaultEase:Ease = new Ease(null,null,1,1);
		
		public static var ticker:Shape = Animation.ticker;
		
		public static var _plugins:Object = {};
		
		protected static var _tweenLookup:Dictionary = new Dictionary(false);
		
		protected static var _reservedProps:Object = {
			"ease":1,
			"delay":1,
			"overwrite":1,
			"onComplete":1,
			"onCompleteParams":1,
			"onCompleteScope":1,
			"useFrames":1,
			"runBackwards":1,
			"startAt":1,
			"onUpdate":1,
			"onUpdateParams":1,
			"onUpdateScope":1,
			"onStart":1,
			"onStartParams":1,
			"onStartScope":1,
			"onReverseComplete":1,
			"onReverseCompleteParams":1,
			"onReverseCompleteScope":1,
			"onRepeat":1,
			"onRepeatParams":1,
			"onRepeatScope":1,
			"easeParams":1,
			"yoyo":1,
			"onCompleteListener":1,
			"onUpdateListener":1,
			"onStartListener":1,
			"onReverseCompleteListener":1,
			"onRepeatListener":1,
			"orientToBezier":1,
			"immediateRender":1,
			"repeat":1,
			"repeatDelay":1,
			"data":1,
			"paused":1,
			"reversed":1
		};
		
		public var target:Object;
		
		public var ratio:Number;
		
		public var _propLookup:Object;
		
		public var _firstPT:PropTween;
		
		protected var _targets:Array;
		
		public var _ease:Ease;
		
		protected var _easeType:int;
		
		protected var _easePower:int;
		
		protected var _siblings:Array;
		
		protected var _overwrite:int;
		
		protected var _overwrittenProps:Object;
		
		protected var _notifyPluginsOfEnabled:Boolean;
		
		protected var _startAt:TweenLite;
		
		public function TweenLite(target:Object, duration:Number, vars:Object) {
			var _local4:int = 0;
			super(duration,vars);
			if(target == null) {
				throw new Error("Cannot tween a null object. Duration: " + duration + ", data: " + this.data);
			}
			if(!_overwriteLookup) {
				_overwriteLookup = {
					"none":0,
					"all":1,
					"auto":2,
					"concurrent":3,
					"allOnStart":4,
					"preexisting":5,
					"true":1,
					"false":0
				};
				ticker.addEventListener("enterFrame",_dumpGarbage,false,-1,true);
			}
			ratio = 0;
			this.target = target;
			_ease = defaultEase;
			_overwrite = !("overwrite" in this.vars) ? _overwriteLookup[defaultOverwrite] : (typeof this.vars.overwrite === "number" ? this.vars.overwrite >> 0 : _overwriteLookup[this.vars.overwrite]);
			if(this.target is Array && typeof this.target[0] === "object") {
				_targets = this.target.concat();
				_propLookup = [];
				_siblings = [];
				_local4 = int(_targets.length);
				while(true) {
					_local4--;
					if(_local4 <= -1) {
						break;
					}
					_siblings[_local4] = _register(_targets[_local4],this,false);
					if(_overwrite == 1) {
						if(_siblings[_local4].length > 1) {
							_applyOverwrite(_targets[_local4],this,null,1,_siblings[_local4]);
						}
					}
				}
			} else {
				_propLookup = {};
				_siblings = _tweenLookup[target];
				if(_siblings == null) {
					_siblings = _tweenLookup[target] = [this];
				} else {
					_siblings[_siblings.length] = this;
					if(_overwrite == 1) {
						_applyOverwrite(target,this,null,1,_siblings);
					}
				}
			}
			if(this.vars.immediateRender || duration == 0 && _delay == 0 && this.vars.immediateRender != false) {
				render(-_delay,false,true);
			}
		}
		
		public static function to(target:Object, duration:Number, vars:Object) : TweenLite {
			return new TweenLite(target,duration,vars);
		}
		
		public static function from(target:Object, duration:Number, vars:Object) : TweenLite {
			vars = _prepVars(vars,true);
			vars.runBackwards = true;
			return new TweenLite(target,duration,vars);
		}
		
		public static function fromTo(target:Object, duration:Number, fromVars:Object, toVars:Object) : TweenLite {
			toVars = _prepVars(toVars,true);
			fromVars = _prepVars(fromVars);
			toVars.startAt = fromVars;
			toVars.immediateRender = toVars.immediateRender != false && fromVars.immediateRender != false;
			return new TweenLite(target,duration,toVars);
		}
		
		protected static function _prepVars(vars:Object, immediateRender:Boolean = false) : Object {
			if(vars._isGSVars) {
				vars = vars.vars;
			}
			if(immediateRender && !("immediateRender" in vars)) {
				vars.immediateRender = true;
			}
			return vars;
		}
		
		public static function delayedCall(delay:Number, callback:Function, params:Array = null, useFrames:Boolean = false) : TweenLite {
			return new TweenLite(callback,0,{
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
		
		public static function set(target:Object, vars:Object) : TweenLite {
			return new TweenLite(target,0,vars);
		}
		
		private static function _dumpGarbage(event:Event) : void {
			var _local3:Array = null;
			var _local2:Object = null;
			var _local4:int = 0;
			if(_rootFrame / (60) >> 0 === _rootFrame / (60)) {
				for(_local2 in _tweenLookup) {
					_local3 = _tweenLookup[_local2];
					_local4 = int(_local3.length);
					while(true) {
						_local4--;
						if(_local4 <= -1) {
							break;
						}
						if(_local3[_local4]._gc) {
							_local3.splice(_local4,1);
						}
					}
					if(_local3.length === 0) {
						delete _tweenLookup[_local2];
					}
				}
			}
		}
		
		public static function killTweensOf(target:*, onlyActive:* = false, vars:Object = null) : void {
			var _local4:Array = null;
			if(typeof onlyActive === "object") {
				vars = onlyActive;
				onlyActive = false;
			}
			_local4 = TweenLite.getTweensOf(target,onlyActive);
			var _local5:int = int(_local4.length);
			while(true) {
				_local5--;
				if(_local5 <= -1) {
					break;
				}
				_local4[_local5]._kill(vars,target);
			}
		}
		
		public static function killDelayedCallsTo(func:Function) : void {
			killTweensOf(func);
		}
		
		public static function getTweensOf(target:*, onlyActive:Boolean = false) : Array {
			var _local3:Array = null;
			var _local6:* = 0;
			var _local4:TweenLite = null;
			var _local5:int = 0;
			if(target is Array && typeof target[0] != "string" && typeof target[0] != "number") {
				_local5 = int(target.length);
				_local3 = [];
				while(true) {
					_local5--;
					if(_local5 <= -1) {
						break;
					}
					_local3 = _local3.concat(getTweensOf(target[_local5],onlyActive));
				}
				_local5 = int(_local3.length);
				while(true) {
					_local5--;
					if(_local5 <= -1) {
						break;
					}
					_local4 = _local3[_local5];
					_local6 = _local5;
					while(true) {
						_local6--;
						if(_local6 <= -1) {
							break;
						}
						if(_local4 === _local3[_local6]) {
							_local3.splice(_local5,1);
						}
					}
				}
			} else {
				_local3 = _register(target).concat();
				_local5 = int(_local3.length);
				while(true) {
					_local5--;
					if(_local5 <= -1) {
						break;
					}
					if(_local3[_local5]._gc || onlyActive && !_local3[_local5].isActive()) {
						_local3.splice(_local5,1);
					}
				}
			}
			return _local3;
		}
		
		protected static function _register(target:Object, tween:TweenLite = null, scrub:Boolean = false) : Array {
			var _local5:int = 0;
			var _local4:Array = _tweenLookup[target];
			if(_local4 == null) {
				_local4 = _tweenLookup[target] = [];
			}
			if(tween) {
				_local5 = int(_local4.length);
				_local4[_local5] = tween;
				if(scrub) {
					while(true) {
						_local5--;
						if(_local5 <= -1) {
							break;
						}
						if(_local4[_local5] === tween) {
							_local4.splice(_local5,1);
						}
					}
				}
			}
			return _local4;
		}
		
		protected static function _applyOverwrite(target:Object, tween:TweenLite, props:Object, mode:int, siblings:Array) : Boolean {
			var _local14:Boolean = false;
			var _local6:TweenLite = null;
			var _local7:* = 0;
			var _local8:int = 0;
			var _local10:Number = NaN;
			if(mode == 1 || mode >= 4) {
				_local8 = int(siblings.length);
				_local7 = 0;
				while(_local7 < _local8) {
					_local6 = siblings[_local7];
					if(_local6 != tween) {
						if(!_local6._gc) {
							if(_local6._enabled(false,false)) {
								_local14 = true;
							}
						}
					} else if(mode == 5) {
						break;
					}
					_local7++;
				}
				return _local14;
			}
			var _local13:Number = tween._startTime + 1e-10;
			var _local12:Array = [];
			var _local9:int = 0;
			var _local11:* = tween._duration == 0;
			_local7 = int(siblings.length);
			while(true) {
				_local7--;
				if(_local7 <= -1) {
					break;
				}
				_local6 = siblings[_local7];
				if(!(_local6 === tween || _local6._gc || _local6._paused)) {
					if(_local6._timeline != tween._timeline) {
						_local10 ||= _checkOverlap(tween,0,_local11);
						if(_checkOverlap(_local6,_local10,_local11) === 0) {
							_local12[_local9++] = _local6;
						}
					} else if(_local6._startTime <= _local13) {
						if(_local6._startTime + _local6.totalDuration() / _local6._timeScale > _local13) {
							if(!((_local11 || !_local6._initted) && _local13 - _local6._startTime <= 2e-10)) {
								_local12[_local9++] = _local6;
							}
						}
					}
				}
			}
			_local7 = _local9;
			while(true) {
				_local7--;
				if(_local7 <= -1) {
					break;
				}
				_local6 = _local12[_local7];
				if(mode == 2) {
					if(_local6._kill(props,target)) {
						_local14 = true;
					}
				}
				if(mode !== 2 || !_local6._firstPT && _local6._initted) {
					if(_local6._enabled(false,false)) {
						_local14 = true;
					}
				}
			}
			return _local14;
		}
		
		private static function _checkOverlap(tween:Animation, reference:Number, zeroDur:Boolean) : Number {
			var _local6:SimpleTimeline = null;
			_local6 = tween._timeline;
			var _local7:Number = _local6._timeScale;
			var _local5:Number = tween._startTime;
			var _local4:Number = 1e-10;
			while(_local6._timeline) {
				_local5 += _local6._startTime;
				_local7 *= _local6._timeScale;
				if(_local6._paused) {
					return -100;
				}
				_local6 = _local6._timeline;
			}
			_local5 += tween.totalDuration() / tween._timeScale / _local7;
			_local5 /= _local7;
			return _local5 > reference ? _local5 - reference : (zeroDur && _local5 == reference || !tween._initted && _local5 - reference < 2 * _local4 ? _local4 : (_local5 > reference + _local4 ? 0 : _local5 - reference - _local4));
		}
		
		protected function _init() : void {
			var _local5:int = 0;
			var _local2:Boolean = false;
			var _local3:PropTween = null;
			var _local1:String = null;
			var _local6:Object = null;
			var _local4:Boolean = Boolean(vars.immediateRender);
			if(vars.startAt) {
				if(_startAt != null) {
					_startAt.render(-1,true);
				}
				vars.startAt.overwrite = 0;
				vars.startAt.immediateRender = true;
				_startAt = new TweenLite(target,0,vars.startAt);
				if(_local4) {
					if(_time > 0) {
						_startAt = null;
					} else if(_duration !== 0) {
						return;
					}
				}
			} else if(vars.runBackwards && _duration !== 0) {
				if(_startAt != null) {
					_startAt.render(-1,true);
					_startAt = null;
				} else {
					_local6 = {};
					for(_local1 in vars) {
						if(!(_local1 in _reservedProps)) {
							_local6[_local1] = vars[_local1];
						}
					}
					_local6.overwrite = 0;
					_local6.data = "isFromStart";
					_startAt = TweenLite.to(target,0,_local6);
					if(!_local4) {
						_startAt.render(-1,true);
					} else if(_time === 0) {
						return;
					}
				}
			}
			if(vars.ease is Ease) {
				_ease = vars.easeParams is Array ? vars.ease.config.apply(vars.ease,vars.easeParams) : vars.ease;
			} else if(typeof vars.ease === "function") {
				_ease = new Ease(vars.ease,vars.easeParams);
			} else {
				_ease = defaultEase;
			}
			_easeType = _ease._type;
			_easePower = _ease._power;
			_firstPT = null;
			if(_targets) {
				_local5 = int(_targets.length);
				while(true) {
					_local5--;
					if(_local5 <= -1) {
						break;
					}
					if(_initProps(_targets[_local5],_propLookup[_local5] = {},_siblings[_local5],!!_overwrittenProps ? _overwrittenProps[_local5] : null)) {
						_local2 = true;
					}
				}
			} else {
				_local2 = _initProps(target,_propLookup,_siblings,_overwrittenProps);
			}
			if(_local2) {
				_onPluginEvent("_onInitAllProps",this);
			}
			if(_overwrittenProps) {
				if(_firstPT == null) {
					if(typeof target !== "function") {
						_enabled(false,false);
					}
				}
			}
			if(vars.runBackwards) {
				_local3 = _firstPT;
				while(_local3) {
					_local3.s += _local3.c;
					_local3.c = -_local3.c;
					_local3 = _local3._next;
				}
			}
			_onUpdate = vars.onUpdate;
			_initted = true;
		}
		
		protected function _initProps(target:Object, propLookup:Object, siblings:Array, overwrittenProps:Object) : Boolean {
			var _local5:String = null;
			var _local9:int = 0;
			var _local7:Boolean = false;
			var _local8:Object = null;
			var _local6:Object = null;
			var _local10:Object = this.vars;
			if(target == null) {
				return false;
			}
			for(_local5 in _local10) {
				_local6 = _local10[_local5];
				if(_local5 in _reservedProps) {
					if(_local6 is Array) {
						if(_local6.join("").indexOf("{self}") !== -1) {
							_local10[_local5] = _swapSelfInParams(_local6 as Array);
						}
					}
				} else if(_local5 in _plugins && (_local8 = new _plugins[_local5]())._onInitTween(target,_local6,this)) {
					_firstPT = new PropTween(_local8,"setRatio",0,1,_local5,true,_firstPT,_local8._priority);
					_local9 = int(_local8._overwriteProps.length);
					while(true) {
						_local9--;
						if(_local9 <= -1) {
							break;
						}
						propLookup[_local8._overwriteProps[_local9]] = _firstPT;
					}
					if(_local8._priority || "_onInitAllProps" in _local8) {
						_local7 = true;
					}
					if("_onDisable" in _local8 || "_onEnable" in _local8) {
						_notifyPluginsOfEnabled = true;
					}
				} else {
					_firstPT = propLookup[_local5] = new PropTween(target,_local5,0,1,_local5,false,_firstPT);
					_firstPT.s = !_firstPT.f ? Number(target[_local5]) : target[_local5.indexOf("set") || !("get" + _local5.substr(3) in target) ? _local5 : "get" + _local5.substr(3)]();
					_firstPT.c = typeof _local6 === "number" ? Number(_local6) - _firstPT.s : (typeof _local6 === "string" && _local6.charAt(1) === "=" ? (int(_local6.charAt(0) + "1")) * Number(_local6.substr(2)) : Number(Number(_local6) || 0));
				}
			}
			if(overwrittenProps) {
				if(_kill(overwrittenProps,target)) {
					return _initProps(target,propLookup,siblings,overwrittenProps);
				}
			}
			if(_overwrite > 1) {
				if(_firstPT != null) {
					if(siblings.length > 1) {
						if(_applyOverwrite(target,this,propLookup,_overwrite,siblings)) {
							_kill(propLookup,target);
							return _initProps(target,propLookup,siblings,overwrittenProps);
						}
					}
				}
			}
			return _local7;
		}
		
		override public function render(time:Number, suppressEvents:Boolean = false, force:Boolean = false) : void {
			var _local7:String = null;
			var _local5:PropTween = null;
			var _local6:Number = NaN;
			var _local9:Boolean = false;
			var _local4:Number = NaN;
			var _local8:Number = _time;
			if(time >= _duration) {
				_totalTime = _time = _duration;
				ratio = _ease._calcEnd ? _ease.getRatio(1) : 1;
				if(!_reversed) {
					_local9 = true;
					_local7 = "onComplete";
				}
				if(_duration == 0) {
					_local6 = _rawPrevTime;
					if(_startTime === _timeline._duration) {
						time = 0;
					}
					if(time === 0 || _local6 < 0 || _local6 === _tinyNum) {
						if(_local6 !== time) {
							force = true;
							if(_local6 > 0 && _local6 !== _tinyNum) {
								_local7 = "onReverseComplete";
							}
						}
					}
					_rawPrevTime = _local6 = !suppressEvents || time !== 0 || _rawPrevTime === time ? time : _tinyNum;
				}
			} else if(time < 1e-7) {
				_totalTime = _time = 0;
				ratio = _ease._calcEnd ? _ease.getRatio(0) : 0;
				if(_local8 !== 0 || _duration === 0 && _rawPrevTime > 0 && _rawPrevTime !== _tinyNum) {
					_local7 = "onReverseComplete";
					_local9 = _reversed;
				}
				if(time < 0) {
					_active = false;
					if(_duration == 0) {
						if(_rawPrevTime >= 0) {
							force = true;
						}
						_rawPrevTime = _local6 = !suppressEvents || time !== 0 || _rawPrevTime === time ? time : _tinyNum;
					}
				} else if(!_initted) {
					force = true;
				}
			} else {
				_totalTime = _time = time;
				if(_easeType) {
					_local4 = time / _duration;
					if(_easeType == 1 || _easeType == 3 && _local4 >= 0.5) {
						_local4 = 1 - _local4;
					}
					if(_easeType == 3) {
						_local4 *= 2;
					}
					if(_easePower == 1) {
						_local4 *= _local4;
					} else if(_easePower == 2) {
						_local4 *= _local4 * _local4;
					} else if(_easePower == 3) {
						_local4 *= _local4 * _local4 * _local4;
					} else if(_easePower == 4) {
						_local4 *= _local4 * _local4 * _local4 * _local4;
					}
					if(_easeType == 1) {
						ratio = 1 - _local4;
					} else if(_easeType == 2) {
						ratio = _local4;
					} else if(time / _duration < 0.5) {
						ratio = _local4 / 2;
					} else {
						ratio = 1 - _local4 / 2;
					}
				} else {
					ratio = _ease.getRatio(time / _duration);
				}
			}
			if(_time == _local8 && !force) {
				return;
			}
			if(!_initted) {
				_init();
				if(!_initted || _gc) {
					return;
				}
				if(_time && !_local9) {
					ratio = _ease.getRatio(_time / _duration);
				} else if(_local9 && _ease._calcEnd) {
					ratio = _ease.getRatio(_time === 0 ? 0 : 1);
				}
			}
			if(!_active) {
				if(!_paused && _time !== _local8 && time >= 0) {
					_active = true;
				}
			}
			if(_local8 == 0) {
				if(_startAt != null) {
					if(time >= 0) {
						_startAt.render(time,suppressEvents,force);
					} else if(!_local7) {
						_local7 = "_dummyGS";
					}
				}
				if(vars.onStart) {
					if(_time != 0 || _duration == 0) {
						if(!suppressEvents) {
							vars.onStart.apply(null,vars.onStartParams);
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
					if(_time !== _local8 || _local9) {
						_onUpdate.apply(null,vars.onUpdateParams);
					}
				}
			}
			if(_local7) {
				if(!_gc) {
					if(time < 0 && _startAt != null && _onUpdate == null && _startTime != 0) {
						_startAt.render(time,suppressEvents,force);
					}
					if(_local9) {
						if(_timeline.autoRemoveChildren) {
							_enabled(false,false);
						}
						_active = false;
					}
					if(!suppressEvents) {
						if(vars[_local7]) {
							vars[_local7].apply(null,vars[_local7 + "Params"]);
						}
					}
					if(_duration === 0 && _rawPrevTime === _tinyNum && _local6 !== _tinyNum) {
						_rawPrevTime = 0;
					}
				}
			}
		}
		
		override public function _kill(vars:Object = null, target:Object = null) : Boolean {
			var _local5:Object = null;
			var _local3:String = null;
			var _local4:PropTween = null;
			var _local8:Object = null;
			var _local10:Boolean = false;
			var _local9:Object = null;
			var _local6:Boolean = false;
			var _local7:int = 0;
			if(vars === "all") {
				vars = null;
			}
			if(vars == null) {
				if(target == null || target == this.target) {
					return _enabled(false,false);
				}
			}
			target = target || _targets || this.target;
			if(target is Array && typeof target[0] === "object") {
				_local7 = int(target.length);
				while(true) {
					_local7--;
					if(_local7 <= -1) {
						break;
					}
					if(_kill(vars,target[_local7])) {
						_local10 = true;
					}
				}
			} else {
				if(_targets) {
					_local7 = int(_targets.length);
					while(true) {
						_local7--;
						if(_local7 <= -1) {
							break;
						}
						if(target === _targets[_local7]) {
							_local8 = _propLookup[_local7] || {};
							_overwrittenProps ||= [];
							_local5 = _overwrittenProps[_local7] = !!vars ? _overwrittenProps[_local7] || {} : "all";
							break;
						}
					}
				} else {
					if(target !== this.target) {
						return false;
					}
					_local8 = _propLookup;
					_local5 = _overwrittenProps = !!vars ? _overwrittenProps || {} : "all";
				}
				if(_local8) {
					_local9 = vars || _local8;
					_local6 = vars != _local5 && _local5 != "all" && vars != _local8 && (typeof vars != "object" || vars._tempKill != true);
					for(_local3 in _local9) {
						_local4 = _local8[_local3];
						if(_local4 != null) {
							if(_local4.pg && _local4.t._kill(_local9)) {
								_local10 = true;
							}
							if(!_local4.pg || _local4.t._overwriteProps.length === 0) {
								if(_local4._prev) {
									_local4._prev._next = _local4._next;
								} else if(_local4 == _firstPT) {
									_firstPT = _local4._next;
								}
								if(_local4._next) {
									_local4._next._prev = _local4._prev;
								}
								_local4._next = _local4._prev = null;
							}
							delete _local8[_local3];
						}
						if(_local6) {
							_local5[_local3] = 1;
						}
					}
					if(_firstPT == null && _initted) {
						_enabled(false,false);
					}
				}
			}
			return _local10;
		}
		
		override public function invalidate() : * {
			if(_notifyPluginsOfEnabled) {
				_onPluginEvent("_onDisable",this);
			}
			_firstPT = null;
			_overwrittenProps = null;
			_onUpdate = null;
			_startAt = null;
			_initted = _active = _notifyPluginsOfEnabled = false;
			_propLookup = !!_targets ? {} : [];
			return this;
		}
		
		override public function _enabled(enabled:Boolean, ignoreTimeline:Boolean = false) : Boolean {
			var _local3:int = 0;
			if(enabled && _gc) {
				if(_targets) {
					_local3 = int(_targets.length);
					while(true) {
						_local3--;
						if(_local3 <= -1) {
							break;
						}
						_siblings[_local3] = _register(_targets[_local3],this,true);
					}
				} else {
					_siblings = _register(target,this,true);
				}
			}
			super._enabled(enabled,ignoreTimeline);
			if(_notifyPluginsOfEnabled) {
				if(_firstPT != null) {
					return _onPluginEvent(enabled ? "_onEnable" : "_onDisable",this);
				}
			}
			return false;
		}
	}
}

