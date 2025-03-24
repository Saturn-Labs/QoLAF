package com.greensock.plugins {
	import com.greensock.TweenLite;
	
	public class EndArrayPlugin extends TweenPlugin {
		public static const API:Number = 2;
		
		protected var _a:Array;
		
		protected var _round:Boolean;
		
		protected var _info:Array = [];
		
		public function EndArrayPlugin() {
			super("endArray");
		}
		
		override public function _onInitTween(target:Object, value:*, tween:TweenLite) : Boolean {
			if(!(target is Array) || !(value is Array)) {
				return false;
			}
			_init(target as Array,value);
			return true;
		}
		
		public function _init(start:Array, end:Array) : void {
			_a = start;
			var _local4:int = int(end.length);
			var _local3:int = 0;
			while(true) {
				_local4--;
				if(_local4 <= -1) {
					break;
				}
				if(start[_local4] != end[_local4] && start[_local4] != null) {
					_info[_local3++] = new ArrayTweenInfo(_local4,_a[_local4],end[_local4] - _a[_local4]);
				}
			}
		}
		
		override public function _roundProps(lookup:Object, value:Boolean = true) : void {
			if("endArray" in lookup) {
				_round = value;
			}
		}
		
		override public function setRatio(v:Number) : void {
			var _local3:ArrayTweenInfo = null;
			var _local2:Number = NaN;
			var _local4:int = int(_info.length);
			if(_round) {
				while(true) {
					_local4--;
					if(_local4 <= -1) {
						break;
					}
					_local3 = _info[_local4];
					_a[_local3.i] = (_local2 = _local3.c * v + _local3.s) > 0 ? _local2 + 0.5 >> 0 : _local2 - 0.5 >> 0;
				}
			} else {
				while(true) {
					_local4--;
					if(_local4 <= -1) {
						break;
					}
					_local3 = _info[_local4];
					_a[_local3.i] = _local3.c * v + _local3.s;
				}
			}
		}
	}
}

class ArrayTweenInfo {
	public var i:uint;
	
	public var s:Number;
	
	public var c:Number;
	
	public function ArrayTweenInfo(index:uint, start:Number, change:Number) {
		super();
		this.i = index;
		this.s = start;
		this.c = change;
	}
}
