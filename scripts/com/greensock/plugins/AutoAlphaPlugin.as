package com.greensock.plugins {
	import com.greensock.TweenLite;
	
	public class AutoAlphaPlugin extends TweenPlugin {
		public static const API:Number = 2;
		
		protected var _target:Object;
		
		protected var _ignoreVisible:Boolean;
		
		public function AutoAlphaPlugin() {
			super("autoAlpha,alpha,visible");
		}
		
		override public function _onInitTween(target:Object, value:*, tween:TweenLite) : Boolean {
			_target = target;
			_addTween(target,"alpha",target.alpha,value,"alpha");
			return true;
		}
		
		override public function _kill(lookup:Object) : Boolean {
			_ignoreVisible = "visible" in lookup;
			return super._kill(lookup);
		}
		
		override public function setRatio(v:Number) : void {
			super.setRatio(v);
			if(!_ignoreVisible) {
				_target.visible = _target.alpha != 0;
			}
		}
	}
}

