package com.greensock.plugins {
	import com.greensock.TweenLite;
	
	public class ShortRotationPlugin extends TweenPlugin {
		public static const API:Number = 2;
		
		public function ShortRotationPlugin() {
			super("shortRotation");
			_overwriteProps.pop();
		}
		
		override public function _onInitTween(target:Object, value:*, tween:TweenLite) : Boolean {
			var _local6:Number = NaN;
			if(typeof value == "number") {
				return false;
			}
			var _local5:* = value.useRadians == true;
			for(var _local4 in value) {
				if(_local4 != "useRadians") {
					_local6 = Number(target[_local4] is Function ? target[_local4.indexOf("set") || !("get" + _local4.substr(3) in target) ? _local4 : "get" + _local4.substr(3)]() : target[_local4]);
					_initRotation(target,_local4,_local6,typeof value[_local4] == "number" ? Number(value[_local4]) : _local6 + Number(value[_local4].split("=").join("")),_local5);
				}
			}
			return true;
		}
		
		public function _initRotation(target:Object, p:String, start:Number, end:Number, useRadians:Boolean = false) : void {
			var _local7:Number = NaN;
			_local7 = useRadians ? 3.141592653589793 * 2 : 6 * 60;
			var _local6:Number = (end - start) % _local7;
			if(_local6 != _local6 % (_local7 / 2)) {
				_local6 = _local6 < 0 ? _local6 + _local7 : _local6 - _local7;
			}
			_addTween(target,p,start,start + _local6,p);
			_overwriteProps[_overwriteProps.length] = p;
		}
	}
}

