package starling.filters {
	import starling.rendering.FilterEffect;
	import starling.rendering.Painter;
	import starling.textures.Texture;
	
	public class BlurFilter extends FragmentFilter {
		private var _blurX:Number;
		
		private var _blurY:Number;
		
		public function BlurFilter(blurX:Number = 1, blurY:Number = 1, resolution:Number = 1) {
			super();
			_blurX = blurX;
			_blurY = blurY;
			this.resolution = resolution;
		}
		
		override public function process(painter:Painter, helper:IFilterHelper, input0:Texture = null, input1:Texture = null, input2:Texture = null, input3:Texture = null) : Texture {
			var _local11:* = null;
			var _local10:BlurEffect = this.effect as BlurEffect;
			if(_blurX == 0 && _blurY == 0) {
				_local10.strength = 0;
				return super.process(painter,helper,input0);
			}
			var _local9:Number = Math.abs(_blurX);
			var _local8:Number = Math.abs(_blurY);
			var _local7:* = input0;
			_local10.direction = "horizontal";
			while(_local9 > 0) {
				_local10.strength = Math.min(1,_local9);
				_local9 -= _local10.strength;
				_local11 = _local7;
				_local7 = super.process(painter,helper,_local11);
				if(_local11 != input0) {
					helper.putTexture(_local11);
				}
			}
			_local10.direction = "vertical";
			while(_local8 > 0) {
				_local10.strength = Math.min(1,_local8);
				_local8 -= _local10.strength;
				_local11 = _local7;
				_local7 = super.process(painter,helper,_local11);
				if(_local11 != input0) {
					helper.putTexture(_local11);
				}
			}
			return _local7;
		}
		
		override protected function createEffect() : FilterEffect {
			return new BlurEffect();
		}
		
		override public function set resolution(value:Number) : void {
			super.resolution = value;
			updatePadding();
		}
		
		override public function get numPasses() : int {
			return Math.ceil(_blurX) + Math.ceil(_blurY) || 1;
		}
		
		private function updatePadding() : void {
			var _local1:Number = (!!_blurX ? Math.ceil(Math.abs(_blurX)) + 3 : 1) / resolution;
			var _local2:Number = (!!_blurY ? Math.ceil(Math.abs(_blurY)) + 3 : 1) / resolution;
			padding.setTo(_local1,_local1,_local2,_local2);
		}
		
		public function get blurX() : Number {
			return _blurX;
		}
		
		public function set blurX(value:Number) : void {
			_blurX = value;
			updatePadding();
		}
		
		public function get blurY() : Number {
			return _blurY;
		}
		
		public function set blurY(value:Number) : void {
			_blurY = value;
			updatePadding();
		}
	}
}

import flash.display3D.Context3D;
import starling.rendering.FilterEffect;
import starling.rendering.Program;
import starling.utils.MathUtil;

class BlurEffect extends FilterEffect {
	public static const HORIZONTAL:String = "horizontal";
	
	public static const VERTICAL:String = "vertical";
	
	private static const MAX_SIGMA:Number = 2;
	
	private var _strength:Number;
	
	private var _direction:String;
	
	private var _offsets:Vector.<Number> = new <Number>[0,0,0,0];
	
	private var _weights:Vector.<Number> = new <Number>[0,0,0,0];
	
	private var sTmpWeights:Vector.<Number> = new Vector.<Number>(5,true);
	
	public function BlurEffect(direction:String = "horizontal", strength:Number = 1) {
		super();
		this.strength = strength;
		this.direction = direction;
	}
	
	override protected function createProgram() : Program {
		if(_strength == 0) {
			return super.createProgram();
		}
		var _local1:String = ["m44 op, va0, vc0     ","mov v0, va1          ","sub v1, va1, vc4.zwxx","sub v2, va1, vc4.xyxx","add v3, va1, vc4.xyxx","add v4, va1, vc4.zwxx"].join("\n");
		var _local2:String = [tex("ft0","v0",0,texture),"mul ft5, ft0, fc0.xxxx       ",tex("ft1","v1",0,texture),"mul ft1, ft1, fc0.zzzz       ","add ft5, ft5, ft1            ",tex("ft2","v2",0,texture),"mul ft2, ft2, fc0.yyyy       ","add ft5, ft5, ft2            ",tex("ft3","v3",0,texture),"mul ft3, ft3, fc0.yyyy       ","add ft5, ft5, ft3            ",tex("ft4","v4",0,texture),"mul ft4, ft4, fc0.zzzz       ","add  oc, ft5, ft4            "].join("\n");
		return Program.fromSource(_local1,_local2);
	}
	
	override protected function beforeDraw(context:Context3D) : void {
		super.beforeDraw(context);
		if(_strength) {
			updateParameters();
			context.setProgramConstantsFromVector("vertex",4,_offsets);
			context.setProgramConstantsFromVector("fragment",0,_weights);
		}
	}
	
	override protected function get programVariantName() : uint {
		return super.programVariantName | (!!_strength ? 16 : 0);
	}
	
	private function updateParameters() : void {
		var _local1:Number = NaN;
		var _local8:Number = NaN;
		var _local5:int = 0;
		if(_direction == "horizontal") {
			_local1 = _strength * 2;
			_local8 = 1 / texture.root.width;
		} else {
			_local1 = _strength * 2;
			_local8 = 1 / texture.root.height;
		}
		var _local9:Number = 2 * _local1 * _local1;
		var _local3:Number = 1 / Math.sqrt(_local9 * 3.141592653589793);
		_local5 = 0;
		while(_local5 < 5) {
			sTmpWeights[_local5] = _local3 * Math.exp(-_local5 * _local5 / _local9);
			_local5++;
		}
		_weights[0] = sTmpWeights[0];
		_weights[1] = sTmpWeights[1] + sTmpWeights[2];
		_weights[2] = sTmpWeights[3] + sTmpWeights[4];
		var _local2:Number = _weights[0] + 2 * _weights[1] + 2 * _weights[2];
		var _local4:Number = 1 / _local2;
		_weights[0] *= _local4;
		_weights[1] *= _local4;
		_weights[2] *= _local4;
		var _local7:Number = (_local8 * sTmpWeights[1] + 2 * _local8 * sTmpWeights[2]) / _weights[1];
		var _local6:Number = (3 * _local8 * sTmpWeights[3] + 4 * _local8 * sTmpWeights[4]) / _weights[2];
		if(_direction == "horizontal") {
			_offsets[0] = _local7;
			_offsets[1] = 0;
			_offsets[2] = _local6;
			_offsets[3] = 0;
		} else {
			_offsets[0] = 0;
			_offsets[1] = _local7;
			_offsets[2] = 0;
			_offsets[3] = _local6;
		}
	}
	
	public function get direction() : String {
		return _direction;
	}
	
	public function set direction(value:String) : void {
		_direction = value;
	}
	
	public function get strength() : Number {
		return _strength;
	}
	
	public function set strength(value:Number) : void {
		_strength = MathUtil.clamp(value,0,1);
	}
}
