package starling.filters {
	import starling.rendering.FilterEffect;
	import starling.utils.Color;
	
	public class ColorMatrixFilter extends FragmentFilter {
		private static const LUMA_R:Number = 0.299;
		
		private static const LUMA_G:Number = 0.587;
		
		private static const LUMA_B:Number = 0.114;
		
		private static var sMatrix:Vector.<Number> = new Vector.<Number>(0);
		
		public function ColorMatrixFilter(matrix:Vector.<Number> = null) {
			super();
			if(matrix) {
				colorEffect.matrix = matrix;
			}
		}
		
		override protected function createEffect() : FilterEffect {
			return new ColorMatrixEffect();
		}
		
		public function invert() : void {
			concatValues(-1,0,0,0,255,0,-1,0,0,255,0,0,-1,0,255,0,0,0,1,0);
		}
		
		public function adjustSaturation(sat:Number) : void {
			sat += 1;
			var _local3:Number = 1 - sat;
			var _local4:Number = _local3 * 0.299;
			var _local2:Number = _local3 * 0.587;
			var _local5:Number = _local3 * 0.114;
			concatValues(_local4 + sat,_local2,_local5,0,0,_local4,_local2 + sat,_local5,0,0,_local4,_local2,_local5 + sat,0,0,0,0,0,1,0);
		}
		
		public function adjustContrast(value:Number) : void {
			var _local2:Number = value + 1;
			var _local3:Number = 128 * (1 - _local2);
			concatValues(_local2,0,0,0,_local3,0,_local2,0,0,_local3,0,0,_local2,0,_local3,0,0,0,1,0);
		}
		
		public function adjustBrightness(value:Number) : void {
			value *= 255;
			concatValues(1,0,0,0,value,0,1,0,0,value,0,0,1,0,value,0,0,0,1,0);
		}
		
		public function adjustHue(value:Number) : void {
			value *= 3.141592653589793;
			var _local2:Number = Math.cos(value);
			var _local3:Number = Math.sin(value);
			concatValues(0.299 + _local2 * (1 - 0.299) + _local3 * -0.299,0.587 + _local2 * -0.587 + _local3 * -0.587,0.114 + _local2 * -0.114 + _local3 * (1 - 0.114),0,0,0.299 + _local2 * -0.299 + _local3 * 0.143,0.587 + _local2 * (1 - 0.587) + _local3 * 0.14,0.114 + _local2 * -0.114 + _local3 * -0.283,0,0,0.299 + _local2 * -0.299 + _local3 * -0.7010000000000001,0.587 + _local2 * -0.587 + _local3 * 0.587,0.114 + _local2 * (1 - 0.114) + _local3 * 0.114,0,0,0,0,0,1,0);
		}
		
		public function tint(color:uint, amount:Number = 1) : void {
			var _local4:Number = Color.getRed(color) / 255;
			var _local6:Number = Color.getGreen(color) / 255;
			var _local5:Number = Color.getBlue(color) / 255;
			var _local3:Number = 1 - amount;
			var _local8:Number = amount * _local4;
			var _local7:Number = amount * _local6;
			var _local9:Number = amount * _local5;
			concatValues(_local3 + _local8 * 0.299,_local8 * 0.587,_local8 * 0.114,0,0,_local7 * 0.299,_local3 + _local7 * 0.587,_local7 * 0.114,0,0,_local9 * 0.299,_local9 * 0.587,_local3 + _local9 * 0.114,0,0,0,0,0,1,0);
		}
		
		public function reset() : void {
			matrix = null;
		}
		
		public function concat(matrix:Vector.<Number>) : void {
			colorEffect.concat(matrix);
			setRequiresRedraw();
		}
		
		public function concatValues(m0:Number, m1:Number, m2:Number, m3:Number, m4:Number, m5:Number, m6:Number, m7:Number, m8:Number, m9:Number, m10:Number, m11:Number, m12:Number, m13:Number, m14:Number, m15:Number, m16:Number, m17:Number, m18:Number, m19:Number) : void {
			sMatrix.length = 0;
			sMatrix.push(m0,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15,m16,m17,m18,m19);
			concat(sMatrix);
		}
		
		public function get matrix() : Vector.<Number> {
			return colorEffect.matrix;
		}
		
		public function set matrix(value:Vector.<Number>) : void {
			colorEffect.matrix = value;
			setRequiresRedraw();
		}
		
		private function get colorEffect() : ColorMatrixEffect {
			return this.effect as ColorMatrixEffect;
		}
	}
}

import flash.display3D.Context3D;
import starling.rendering.FilterEffect;
import starling.rendering.Program;

class ColorMatrixEffect extends FilterEffect {
	private static const MIN_COLOR:Vector.<Number> = new <Number>[0,0,0,0.0001];
	
	private static const IDENTITY:Array = [1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0];
	
	private static var sMatrix:Vector.<Number> = new Vector.<Number>(20,true);
	
	private var _userMatrix:Vector.<Number>;
	
	private var _shaderMatrix:Vector.<Number>;
	
	public function ColorMatrixEffect() {
		super();
		_userMatrix = new Vector.<Number>(0);
		_shaderMatrix = new Vector.<Number>(0);
		this.matrix = null;
	}
	
	override protected function createProgram() : Program {
		var _local1:String = "m44 op, va0, vc0 \nmov v0, va1";
		var _local2:String = [tex("ft0","v0",0,texture),"max ft0, ft0, fc5              ","div ft0.xyz, ft0.xyz, ft0.www  ","m44 ft0, ft0, fc0              ","add ft0, ft0, fc4              ","mul ft0.xyz, ft0.xyz, ft0.www  ","mov oc, ft0                    "].join("\n");
		return Program.fromSource(_local1,_local2);
	}
	
	override protected function beforeDraw(context:Context3D) : void {
		super.beforeDraw(context);
		context.setProgramConstantsFromVector("fragment",0,_shaderMatrix);
		context.setProgramConstantsFromVector("fragment",5,MIN_COLOR);
	}
	
	public function reset() : void {
		matrix = null;
	}
	
	public function concat(matrix:Vector.<Number>) : void {
		var _local4:int = 0;
		var _local2:int = 0;
		var _local3:int = 0;
		_local4 = 0;
		while(_local4 < 4) {
			_local2 = 0;
			while(_local2 < 5) {
				sMatrix[_local3 + _local2] = matrix[_local3] * _userMatrix[_local2] + matrix[_local3 + 1] * _userMatrix[_local2 + 5] + matrix[_local3 + 2] * _userMatrix[_local2 + 10] + matrix[_local3 + 3] * _userMatrix[_local2 + 15] + (_local2 == 4 ? matrix[_local3 + 4] : 0);
				_local2++;
			}
			_local3 += 5;
			_local4++;
		}
		copyMatrix(sMatrix,_userMatrix);
		updateShaderMatrix();
	}
	
	private function copyMatrix(from:Vector.<Number>, to:Vector.<Number>) : void {
		var _local3:int = 0;
		_local3 = 0;
		while(_local3 < 20) {
			to[_local3] = from[_local3];
			_local3++;
		}
	}
	
	private function updateShaderMatrix() : void {
		_shaderMatrix.length = 0;
		_shaderMatrix.push(_userMatrix[0],_userMatrix[1],_userMatrix[2],_userMatrix[3],_userMatrix[5],_userMatrix[6],_userMatrix[7],_userMatrix[8],_userMatrix[10],_userMatrix[11],_userMatrix[12],_userMatrix[13],_userMatrix[15],_userMatrix[16],_userMatrix[17],_userMatrix[18],_userMatrix[4] / 255,_userMatrix[9] / 255,_userMatrix[14] / 255,_userMatrix[19] / 255);
	}
	
	public function get matrix() : Vector.<Number> {
		return _userMatrix;
	}
	
	public function set matrix(value:Vector.<Number>) : void {
		if(value && value.length != 20) {
			throw new ArgumentError("Invalid matrix length: must be 20");
		}
		if(value == null) {
			_userMatrix.length = 0;
			_userMatrix.push.apply(_userMatrix,IDENTITY);
		} else {
			copyMatrix(value,_userMatrix);
		}
		updateShaderMatrix();
	}
}
