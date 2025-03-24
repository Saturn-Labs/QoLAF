package com.greensock.plugins {
	import com.greensock.*;
	import flash.media.SoundTransform;
	
	public class VolumePlugin extends TweenPlugin {
		public static const API:Number = 2;
		
		protected var _target:Object;
		
		protected var _st:SoundTransform;
		
		public function VolumePlugin() {
			super("volume");
		}
		
		override public function _onInitTween(target:Object, value:*, tween:TweenLite) : Boolean {
			if(isNaN(value) || Boolean(target.hasOwnProperty("volume")) || !target.hasOwnProperty("soundTransform")) {
				return false;
			}
			_target = target;
			_st = _target.soundTransform;
			_addTween(_st,"volume",_st.volume,value,"volume");
			return true;
		}
		
		override public function setRatio(v:Number) : void {
			super.setRatio(v);
			_target.soundTransform = _st;
		}
	}
}

