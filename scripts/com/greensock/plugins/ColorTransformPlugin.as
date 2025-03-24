package com.greensock.plugins {
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;
	
	public class ColorTransformPlugin extends TintPlugin {
		public static const API:Number = 2;
		
		public function ColorTransformPlugin() {
			super();
			_propName = "colorTransform";
		}
		
		override public function _onInitTween(target:Object, value:*, tween:TweenLite) : Boolean {
			var _local5:ColorTransform = null;
			var _local7:Number = NaN;
			var _local6:ColorTransform = new ColorTransform();
			if(target is DisplayObject) {
				_transform = DisplayObject(target).transform;
				_local5 = _transform.colorTransform;
			} else {
				if(!(target is ColorTransform)) {
					return false;
				}
				_local5 = target as ColorTransform;
			}
			if(value is ColorTransform) {
				_local6.concat(value);
			} else {
				_local6.concat(_local5);
			}
			for(var _local4 in value) {
				if(_local4 == "tint" || _local4 == "color") {
					if(value[_local4] != null) {
						_local6.color = int(value[_local4]);
					}
				} else if(!(_local4 == "tintAmount" || _local4 == "exposure" || _local4 == "brightness")) {
					_local6[_local4] = value[_local4];
				}
			}
			if(!(value is ColorTransform)) {
				if(!isNaN(value.tintAmount)) {
					_local7 = value.tintAmount / (1 - (_local6.redMultiplier + _local6.greenMultiplier + _local6.blueMultiplier) / 3);
					_local6.redOffset *= _local7;
					_local6.greenOffset *= _local7;
					_local6.blueOffset *= _local7;
					_local6.redMultiplier = _local6.greenMultiplier = _local6.blueMultiplier = 1 - value.tintAmount;
				} else if(!isNaN(value.exposure)) {
					_local6.redOffset = _local6.greenOffset = _local6.blueOffset = 255 * (value.exposure - 1);
					_local6.redMultiplier = _local6.greenMultiplier = _local6.blueMultiplier = 1;
				} else if(!isNaN(value.brightness)) {
					_local6.redOffset = _local6.greenOffset = _local6.blueOffset = Math.max(0,(value.brightness - 1) * 255);
					_local6.redMultiplier = _local6.greenMultiplier = _local6.blueMultiplier = 1 - Math.abs(value.brightness - 1);
				}
			}
			_init(_local5,_local6);
			return true;
		}
	}
}

