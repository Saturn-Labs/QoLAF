package com.greensock.plugins {
	import com.greensock.TweenLite;
	import com.greensock.core.PropTween;
	
	public class RoundPropsPlugin extends TweenPlugin {
		public static const API:Number = 2;
		
		protected var _tween:TweenLite;
		
		public function RoundPropsPlugin() {
			super("roundProps",-1);
			_overwriteProps.length = 0;
		}
		
		override public function _onInitTween(target:Object, value:*, tween:TweenLite) : Boolean {
			_tween = tween;
			return true;
		}
		
		public function _onInitAllProps() : Boolean {
			var _local5:String = null;
			var _local3:* = null;
			var _local1:PropTween = null;
			var _local7:Array = null;
			_local7 = _tween.vars.roundProps is Array ? _tween.vars.roundProps : _tween.vars.roundProps.split(",");
			var _local6:int = int(_local7.length);
			var _local2:Object = {};
			var _local4:PropTween = _tween._propLookup.roundProps;
			while(true) {
				_local6--;
				if(_local6 <= -1) {
					break;
				}
				_local2[_local7[_local6]] = 1;
			}
			_local6 = int(_local7.length);
			while(true) {
				_local6--;
				if(_local6 <= -1) {
					break;
				}
				_local5 = _local7[_local6];
				_local3 = _tween._firstPT;
				while(_local3) {
					_local1 = _local3._next;
					if(_local3.pg) {
						_local3.t._roundProps(_local2,true);
					} else if(_local3.n == _local5) {
						_add(_local3.t,_local5,_local3.s,_local3.c);
						if(_local1) {
							_local1._prev = _local3._prev;
						}
						if(_local3._prev) {
							_local3._prev._next = _local1;
						} else if(_tween._firstPT == _local3) {
							_tween._firstPT = _local1;
						}
						_local3._next = _local3._prev = null;
						_tween._propLookup[_local5] = _local4;
					}
					_local3 = _local1;
				}
			}
			return false;
		}
		
		public function _add(target:Object, p:String, s:Number, c:Number) : void {
			_addTween(target,p,s,s + c,p,true);
			_overwriteProps[_overwriteProps.length] = p;
		}
	}
}

