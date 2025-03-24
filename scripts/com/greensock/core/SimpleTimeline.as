package com.greensock.core {
	public class SimpleTimeline extends Animation {
		public var autoRemoveChildren:Boolean;
		
		public var smoothChildTiming:Boolean;
		
		public var _sortChildren:Boolean;
		
		public var _first:Animation;
		
		public var _last:Animation;
		
		public function SimpleTimeline(vars:Object = null) {
			super(0,vars);
			this.autoRemoveChildren = this.smoothChildTiming = true;
		}
		
		public function insert(child:*, position:* = 0) : * {
			return add(child,position || 0);
		}
		
		public function add(child:*, position:* = "+=0", align:String = "normal", stagger:Number = 0) : * {
			var _local5:Number = NaN;
			child._startTime = (Number(position || 0)) + child._delay;
			if(child._paused) {
				if(this != child._timeline) {
					child._pauseTime = child._startTime + (rawTime() - child._startTime) / child._timeScale;
				}
			}
			if(child.timeline) {
				child.timeline._remove(child,true);
			}
			child.timeline = child._timeline = this;
			if(child._gc) {
				child._enabled(true,true);
			}
			var _local6:Animation = _last;
			if(_sortChildren) {
				_local5 = Number(child._startTime);
				while(_local6 && _local6._startTime > _local5) {
					_local6 = _local6._prev;
				}
			}
			if(_local6) {
				child._next = _local6._next;
				_local6._next = Animation(child);
			} else {
				child._next = _first;
				_first = Animation(child);
			}
			if(child._next) {
				child._next._prev = child;
			} else {
				_last = Animation(child);
			}
			child._prev = _local6;
			if(_timeline) {
				_uncache(true);
			}
			return this;
		}
		
		public function _remove(tween:Animation, skipDisable:Boolean = false) : * {
			if(tween.timeline == this) {
				if(!skipDisable) {
					tween._enabled(false,true);
				}
				tween.timeline = null;
				if(tween._prev) {
					tween._prev._next = tween._next;
				} else if(_first === tween) {
					_first = tween._next;
				}
				if(tween._next) {
					tween._next._prev = tween._prev;
				} else if(_last === tween) {
					_last = tween._prev;
				}
				if(_timeline) {
					_uncache(true);
				}
			}
			return this;
		}
		
		override public function render(time:Number, suppressEvents:Boolean = false, force:Boolean = false) : void {
			var _local4:Animation = null;
			var _local5:* = _first;
			_totalTime = _time = _rawPrevTime = time;
			while(_local5) {
				_local4 = _local5._next;
				if(_local5._active || time >= _local5._startTime && !_local5._paused) {
					if(!_local5._reversed) {
						_local5.render((time - _local5._startTime) * _local5._timeScale,suppressEvents,force);
					} else {
						_local5.render((!_local5._dirty ? _local5._totalDuration : _local5.totalDuration()) - (time - _local5._startTime) * _local5._timeScale,suppressEvents,force);
					}
				}
				_local5 = _local4;
			}
		}
		
		public function rawTime() : Number {
			return _totalTime;
		}
	}
}

