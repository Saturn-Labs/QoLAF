package com.greensock.plugins {
	import com.greensock.TweenLite;
	
	public class HexColorsPlugin extends TweenPlugin {
		public static const API:Number = 2;
		
		protected var _colors:Array;
		
		public function HexColorsPlugin() {
			super("hexColors");
			_overwriteProps = [];
			_colors = [];
		}
		
		override public function _onInitTween(target:Object, value:*, tween:TweenLite) : Boolean {
			for(var _local4 in value) {
				_initColor(target,_local4,uint(value[_local4]));
			}
			return true;
		}
		
		public function _initColor(target:Object, p:String, end:uint) : void {
			var _local8:* = false;
			var _local5:* = 0;
			_local8 = typeof target[p] == "function";
			var _local7:uint = uint(!_local8 ? target[p] : target[p.indexOf("set") || !("get" + p.substr(3) in target) ? p : "get" + p.substr(3)]());
			if(_local7 != end) {
				_local5 = uint(_local7 >> 16);
				var _local6:uint = uint(_local7 >> 8 & 0xFF);
				var _local4:uint = uint(_local7 & 0xFF);
				_colors[_colors.length] = new ColorProp(target,p,_local8,_local5,(end >> 16) - _local5,_local6,(end >> 8 & 0xFF) - _local6,_local4,(end & 0xFF) - _local4);
				_overwriteProps[_overwriteProps.length] = p;
			}
		}
		
		override public function _kill(lookup:Object) : Boolean {
			var _local2:int = int(_colors.length);
			while(_local2--) {
				if(lookup[_colors[_local2].p] != null) {
					_colors.splice(_local2,1);
				}
			}
			return super._kill(lookup);
		}
		
		override public function setRatio(v:Number) : void {
			var _local3:ColorProp = null;
			var _local2:Number = NaN;
			var _local4:int = int(_colors.length);
			while(true) {
				_local4--;
				if(_local4 <= -1) {
					break;
				}
				_local3 = _colors[_local4];
				_local2 = _local3.rs + v * _local3.rc << 16 | _local3.gs + v * _local3.gc << 8 | _local3.bs + v * _local3.bc;
				if(_local3.f) {
					_local3.t[_local3.p](_local2);
				} else {
					_local3.t[_local3.p] = _local2;
				}
			}
		}
	}
}

class ColorProp {
	public var t:Object;
	
	public var p:String;
	
	public var f:Boolean;
	
	public var rs:int;
	
	public var rc:int;
	
	public var gs:int;
	
	public var gc:int;
	
	public var bs:int;
	
	public var bc:int;
	
	public function ColorProp(t:Object, p:String, f:Boolean, rs:int, rc:int, gs:int, gc:int, bs:int, bc:int) {
		super();
		this.t = t;
		this.p = p;
		this.f = f;
		this.rs = rs;
		this.rc = rc;
		this.gs = gs;
		this.gc = gc;
		this.bs = bs;
		this.bc = bc;
	}
}
