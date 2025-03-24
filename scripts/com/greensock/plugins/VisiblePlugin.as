package com.greensock.plugins {
	import com.greensock.TweenLite;
	
	public class VisiblePlugin extends TweenPlugin {
		public static const API:Number = 2;
		
		protected var _target:Object;
		
		protected var _tween:TweenLite;
		
		protected var _visible:Boolean;
		
		protected var _initVal:Boolean;
		
		protected var _progress:int;
		
		public function VisiblePlugin() {
			super("visible");
		}
		
		override public function _onInitTween(target:Object, value:*, tween:TweenLite) : Boolean {
			_target = target;
			_tween = tween;
			_progress = !!_tween.vars.runBackwards ? 0 : 1;
			_initVal = _target.visible;
			_visible = value;
			return true;
		}
		
		override public function setRatio(v:Number) : void {
			_target.visible = v == 1 && (_tween._time / _tween._duration == _progress || _tween._duration == 0) ? _visible : _initVal;
		}
	}
}

