package com.greensock.plugins {
	import com.greensock.TweenLite;
	import flash.filters.ColorMatrixFilter;
	
	public class ColorMatrixFilterPlugin extends FilterPlugin {
		public static const API:Number = 2;
		
		protected static var _lumR:Number = 0.212671;
		
		protected static var _lumG:Number = 0.71516;
		
		protected static var _lumB:Number = 0.072169;
		
		private static var _propNames:Array = [];
		
		protected static var _idMatrix:Array = [1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0];
		
		protected var _matrix:Array;
		
		protected var _matrixTween:EndArrayPlugin;
		
		public function ColorMatrixFilterPlugin() {
			super("colorMatrixFilter");
		}
		
		public static function colorize(m:Array, color:Number, amount:Number = 1) : Array {
			var _local6:Number = NaN;
			if(isNaN(color)) {
				return m;
			}
			if(isNaN(amount)) {
				amount = 1;
			}
			_local6 = (color >> 16 & 0xFF) / 255;
			var _local8:Number = (color >> 8 & 0xFF) / 255;
			var _local5:Number = (color & 0xFF) / 255;
			var _local4:Number = 1 - amount;
			var _local7:Array = [_local4 + amount * _local6 * _lumR,amount * _local6 * _lumG,amount * _local6 * _lumB,0,0,amount * _local8 * _lumR,_local4 + amount * _local8 * _lumG,amount * _local8 * _lumB,0,0,amount * _local5 * _lumR,amount * _local5 * _lumG,_local4 + amount * _local5 * _lumB,0,0,0,0,0,1,0];
			return applyMatrix(_local7,m);
		}
		
		public static function setThreshold(m:Array, n:Number) : Array {
			if(isNaN(n)) {
				return m;
			}
			var _local3:Array = [_lumR * 256,_lumG * 256,_lumB * 256,0,-256 * n,_lumR * 256,_lumG * 256,_lumB * 256,0,-256 * n,_lumR * 256,_lumG * 256,_lumB * 256,0,-256 * n,0,0,0,1,0];
			return applyMatrix(_local3,m);
		}
		
		public static function setHue(m:Array, n:Number) : Array {
			var _local5:Number = NaN;
			if(isNaN(n)) {
				return m;
			}
			n *= 3.141592653589793 / (3 * 60);
			_local5 = Math.cos(n);
			var _local4:Number = Math.sin(n);
			var _local3:Array = [_lumR + _local5 * (1 - _lumR) + _local4 * -_lumR,_lumG + _local5 * -_lumG + _local4 * -_lumG,_lumB + _local5 * -_lumB + _local4 * (1 - _lumB),0,0,_lumR + _local5 * -_lumR + _local4 * 0.143,_lumG + _local5 * (1 - _lumG) + _local4 * 0.14,_lumB + _local5 * -_lumB + _local4 * -0.283,0,0,_lumR + _local5 * -_lumR + _local4 * -(1 - _lumR),_lumG + _local5 * -_lumG + _local4 * _lumG,_lumB + _local5 * (1 - _lumB) + _local4 * _lumB,0,0,0,0,0,1,0,0,0,0,0,1];
			return applyMatrix(_local3,m);
		}
		
		public static function setBrightness(m:Array, n:Number) : Array {
			if(isNaN(n)) {
				return m;
			}
			n = n * 100 - 100;
			return applyMatrix([1,0,0,0,n,0,1,0,0,n,0,0,1,0,n,0,0,0,1,0,0,0,0,0,1],m);
		}
		
		public static function setSaturation(m:Array, n:Number) : Array {
			var _local3:Number = NaN;
			if(isNaN(n)) {
				return m;
			}
			_local3 = 1 - n;
			var _local4:Number = _local3 * _lumR;
			var _local7:Number = _local3 * _lumG;
			var _local5:Number = _local3 * _lumB;
			var _local6:Array = [_local4 + n,_local7,_local5,0,0,_local4,_local7 + n,_local5,0,0,_local4,_local7,_local5 + n,0,0,0,0,0,1,0];
			return applyMatrix(_local6,m);
		}
		
		public static function setContrast(m:Array, n:Number) : Array {
			if(isNaN(n)) {
				return m;
			}
			n += 0.01;
			var _local3:Array = [n,0,0,0,128 * (1 - n),0,n,0,0,128 * (1 - n),0,0,n,0,128 * (1 - n),0,0,0,1,0];
			return applyMatrix(_local3,m);
		}
		
		public static function applyMatrix(m:Array, m2:Array) : Array {
			var _local6:int = 0;
			var _local4:int = 0;
			if(!(m is Array) || !(m2 is Array)) {
				return m2;
			}
			var _local3:Array = [];
			var _local5:int = 0;
			var _local7:int = 0;
			_local6 = 0;
			while(_local6 < 4) {
				_local4 = 0;
				while(_local4 < 5) {
					_local7 = int(_local4 == 4 ? m[_local5 + 4] : 0);
					_local3[_local5 + _local4] = m[_local5] * m2[_local4] + m[_local5 + 1] * m2[_local4 + 5] + m[_local5 + 2] * m2[_local4 + 10] + m[_local5 + 3] * m2[_local4 + 15] + _local7;
					_local4 += 1;
				}
				_local5 += 5;
				_local6 += 1;
			}
			return _local3;
		}
		
		override public function _onInitTween(target:Object, value:*, tween:TweenLite) : Boolean {
			var _local4:Object = value;
			_initFilter(target,{
				"remove":value.remove,
				"index":value.index,
				"addFilter":value.addFilter
			},tween,ColorMatrixFilter,new ColorMatrixFilter(_idMatrix.slice()),_propNames);
			if(_filter == null) {
				trace("FILTER NULL! ");
				return true;
			}
			_matrix = ColorMatrixFilter(_filter).matrix;
			var _local5:Array = [];
			if(_local4.matrix != null && _local4.matrix is Array) {
				_local5 = _local4.matrix;
			} else {
				if(_local4.relative == true) {
					_local5 = _matrix.slice();
				} else {
					_local5 = _idMatrix.slice();
				}
				_local5 = setBrightness(_local5,_local4.brightness);
				_local5 = setContrast(_local5,_local4.contrast);
				_local5 = setHue(_local5,_local4.hue);
				_local5 = setSaturation(_local5,_local4.saturation);
				_local5 = setThreshold(_local5,_local4.threshold);
				if(!isNaN(_local4.colorize)) {
					_local5 = colorize(_local5,_local4.colorize,_local4.amount);
				}
			}
			_matrixTween = new EndArrayPlugin();
			_matrixTween._init(_matrix,_local5);
			return true;
		}
		
		override public function setRatio(v:Number) : void {
			_matrixTween.setRatio(v);
			ColorMatrixFilter(_filter).matrix = _matrix;
			super.setRatio(v);
		}
	}
}

