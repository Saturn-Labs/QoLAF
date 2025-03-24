package com.greensock.plugins {
	import com.greensock.TweenLite;
	import flash.display.MovieClip;
	
	public class FrameLabelPlugin extends FramePlugin {
		public static const API:Number = 2;
		
		public function FrameLabelPlugin() {
			super();
			_propName = "frameLabel";
		}
		
		override public function _onInitTween(target:Object, value:*, tween:TweenLite) : Boolean {
			if(!tween.target is MovieClip) {
				return false;
			}
			_target = target as MovieClip;
			this.frame = _target.currentFrame;
			var _local7:Array = _target.currentLabels;
			var _local6:String = value;
			var _local5:int = _target.currentFrame;
			var _local4:int = int(_local7.length);
			while(true) {
				_local4--;
				if(_local4 <= -1) {
					break;
				}
				if(_local7[_local4].name == _local6) {
					_local5 = int(_local7[_local4].frame);
					break;
				}
			}
			if(this.frame != _local5) {
				_addTween(this,"frame",this.frame,_local5,"frame",true);
			}
			return true;
		}
	}
}

