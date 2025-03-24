package com.greensock.plugins {
	import com.greensock.TweenLite;
	import com.greensock.core.PropTween;
	
	public class TweenPlugin {
		public static const version:String = "12.0.13";
		
		public static const API:Number = 2;
		
		public var _propName:String;
		
		public var _overwriteProps:Array;
		
		public var _priority:int = 0;
		
		protected var _firstPT:PropTween;
		
		public function TweenPlugin(props:String = "", priority:int = 0) {
			super();
			_overwriteProps = props.split(",");
			_propName = _overwriteProps[0];
			_priority = priority || 0;
		}
		
		private static function _onTweenEvent(type:String, tween:TweenLite) : Boolean {
			var _local7:Boolean = false;
			var _local6:* = null;
			var _local5:* = null;
			var _local3:PropTween = null;
			var _local8:* = null;
			var _local4:* = tween._firstPT;
			if(type == "_onInitAllProps") {
				while(_local4) {
					_local3 = _local4._next;
					_local8 = _local6;
					while(_local8 && _local8.pr > _local4.pr) {
						_local8 = _local8._next;
					}
					if(_local4._prev = !!_local8 ? _local8._prev : _local5) {
						_local4._prev._next = _local4;
					} else {
						_local6 = _local4;
					}
					if(_local4._next = _local8) {
						_local8._prev = _local4;
					} else {
						_local5 = _local4;
					}
					_local4 = _local3;
				}
				_local4 = tween._firstPT = _local6;
			}
			while(_local4) {
				if(_local4.pg) {
					if(type in _local4.t) {
						if(_local4.t[type]()) {
							_local7 = true;
						}
					}
				}
				_local4 = _local4._next;
			}
			return _local7;
		}
		
		public static function activate(plugins:Array) : Boolean {
			TweenLite._onPluginEvent = TweenPlugin._onTweenEvent;
			var _local2:int = int(plugins.length);
			while(true) {
				_local2--;
				if(_local2 <= -1) {
					break;
				}
				if(plugins[_local2].API == 2) {
					TweenLite._plugins[new (plugins[_local2] as Class)()._propName] = plugins[_local2];
				}
			}
			return true;
		}
		
		public function _onInitTween(target:Object, value:*, tween:TweenLite) : Boolean {
			return false;
		}
		
		protected function _addTween(target:Object, propName:String, start:Number, end:*, overwriteProp:String = null, round:Boolean = false) : PropTween {
			var _local7:Number = NaN;
			if(end != null && (_local7 = typeof end === "number" || end.charAt(1) !== "=" ? end - start : (int(end.charAt(0) + "1")) * Number(end.substr(2)))) {
				_firstPT = new PropTween(target,propName,start,_local7,overwriteProp || propName,false,_firstPT);
				_firstPT.r = round;
				return _firstPT;
			}
			return null;
		}
		
		public function setRatio(v:Number) : void {
			var _local2:Number = NaN;
			var _local3:PropTween = _firstPT;
			while(_local3) {
				_local2 = _local3.c * v + _local3.s;
				if(_local3.r) {
					_local2 = _local2 + (_local2 > 0 ? 0.5 : -0.5) | 0;
				}
				if(_local3.f) {
					_local3.t[_local3.p](_local2);
				} else {
					_local3.t[_local3.p] = _local2;
				}
				_local3 = _local3._next;
			}
		}
		
		public function _roundProps(lookup:Object, value:Boolean = true) : void {
			var _local3:PropTween = _firstPT;
			while(_local3) {
				if(_propName in lookup || _local3.n != null && _local3.n.split(_propName + "_").join("") in lookup) {
					_local3.r = value;
				}
				_local3 = _local3._next;
			}
		}
		
		public function _kill(lookup:Object) : Boolean {
			var _local3:int = 0;
			if(_propName in lookup) {
				_overwriteProps = [];
			} else {
				_local3 = int(_overwriteProps.length);
				while(true) {
					_local3--;
					if(_local3 <= -1) {
						break;
					}
					if(_overwriteProps[_local3] in lookup) {
						_overwriteProps.splice(_local3,1);
					}
				}
			}
			var _local2:PropTween = _firstPT;
			while(_local2) {
				if(_local2.n in lookup) {
					if(_local2._next) {
						_local2._next._prev = _local2._prev;
					}
					if(_local2._prev) {
						_local2._prev._next = _local2._next;
						_local2._prev = null;
					} else if(_firstPT == _local2) {
						_firstPT = _local2._next;
					}
				}
				_local2 = _local2._next;
			}
			return false;
		}
	}
}

