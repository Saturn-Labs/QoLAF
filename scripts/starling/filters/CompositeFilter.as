package starling.filters {
	import flash.geom.Point;
	import starling.rendering.FilterEffect;
	import starling.rendering.Painter;
	import starling.textures.Texture;
	
	public class CompositeFilter extends FragmentFilter {
		public function CompositeFilter() {
			super();
		}
		
		override public function process(painter:Painter, helper:IFilterHelper, input0:Texture = null, input1:Texture = null, input2:Texture = null, input3:Texture = null) : Texture {
			compositeEffect.texture = input0;
			compositeEffect.getLayerAt(1).texture = input1;
			compositeEffect.getLayerAt(2).texture = input2;
			compositeEffect.getLayerAt(3).texture = input3;
			if(input1) {
				input1.setupTextureCoordinates(vertexData,0,"texCoords1");
			}
			if(input2) {
				input2.setupTextureCoordinates(vertexData,0,"texCoords2");
			}
			if(input3) {
				input3.setupTextureCoordinates(vertexData,0,"texCoords3");
			}
			return super.process(painter,helper,input0,input1,input2,input3);
		}
		
		override protected function createEffect() : FilterEffect {
			return new CompositeEffect();
		}
		
		public function getOffsetAt(layerID:int, out:Point = null) : Point {
			if(out == null) {
				out = new Point();
			}
			out.x = compositeEffect.getLayerAt(layerID).x;
			out.y = compositeEffect.getLayerAt(layerID).y;
			return out;
		}
		
		public function setOffsetAt(layerID:int, x:Number, y:Number) : void {
			compositeEffect.getLayerAt(layerID).x = x;
			compositeEffect.getLayerAt(layerID).y = y;
		}
		
		public function getColorAt(layerID:int) : uint {
			return compositeEffect.getLayerAt(layerID).color;
		}
		
		public function setColorAt(layerID:int, color:uint, replace:Boolean = false) : void {
			compositeEffect.getLayerAt(layerID).color = color;
			compositeEffect.getLayerAt(layerID).replaceColor = replace;
		}
		
		public function getAlphaAt(layerID:int) : Number {
			return compositeEffect.getLayerAt(layerID).alpha;
		}
		
		public function setAlphaAt(layerID:int, alpha:Number) : void {
			compositeEffect.getLayerAt(layerID).alpha = alpha;
		}
		
		private function get compositeEffect() : CompositeEffect {
			return this.effect as CompositeEffect;
		}
	}
}

import flash.display3D.Context3D;
import starling.rendering.FilterEffect;
import starling.rendering.Program;
import starling.rendering.VertexDataFormat;
import starling.textures.Texture;
import starling.utils.Color;
import starling.utils.RenderUtil;
import starling.utils.StringUtil;

class CompositeEffect extends FilterEffect {
	public static const VERTEX_FORMAT:VertexDataFormat = FilterEffect.VERTEX_FORMAT.extend("texCoords1:float2, texCoords2:float2, texCoords3:float2");
	
	private static var sLayers:Array = [];
	
	private static var sOffset:Vector.<Number> = new <Number>[0,0,0,0];
	
	private static var sColor:Vector.<Number> = new <Number>[0,0,0,0];
	
	private var _layers:Vector.<CompositeLayer>;
	
	public function CompositeEffect(numLayers:int = 4) {
		var _local2:int = 0;
		super();
		if(numLayers < 1 || numLayers > 4) {
			throw new ArgumentError("number of layers must be between 1 and 4");
		}
		_layers = new Vector.<CompositeLayer>(numLayers,true);
		_local2 = 0;
		while(_local2 < numLayers) {
			_layers[_local2] = new CompositeLayer();
			_local2++;
		}
	}
	
	public function getLayerAt(layerID:int) : CompositeLayer {
		return _layers[layerID];
	}
	
	private function getUsedLayers(out:Array = null) : Array {
		if(out == null) {
			out = [];
		} else {
			out.length = 0;
		}
		for each(var _local2 in _layers) {
			if(_local2.texture) {
				out[out.length] = _local2;
			}
		}
		return out;
	}
	
	override protected function createProgram() : Program {
		var _local6:int = 0;
		var _local3:Array = null;
		var _local9:CompositeLayer = null;
		var _local5:Array = null;
		var _local7:String = null;
		var _local8:String = null;
		var _local2:String = null;
		var _local4:Array = getUsedLayers(sLayers);
		var _local1:int = int(_local4.length);
		if(_local1) {
			_local3 = ["m44 op, va0, vc0"];
			_local9 = _layers[0];
			_local6 = 0;
			while(_local6 < _local1) {
				_local3.push(StringUtil.format("add v{0}, va{1}, vc{2}",_local6,_local6 + 1,_local6 + 4));
				_local6++;
			}
			_local5 = ["seq ft5, v0, v0"];
			_local6 = 0;
			while(_local6 < _local1) {
				_local7 = "ft" + _local6;
				_local8 = "fc" + _local6;
				_local2 = "v" + _local6;
				_local9 = _layers[_local6];
				_local5.push(tex(_local7,_local2,_local6,_local4[_local6].texture));
				if(_local9.replaceColor) {
					_local5.push("mul " + _local7 + ".w,   " + _local7 + ".w,   " + _local8 + ".w","sat " + _local7 + ".w,   " + _local7 + ".w    ","mul " + _local7 + ".xyz, " + _local8 + ".xyz, " + _local7 + ".www");
				} else {
					_local5.push("mul " + _local7 + ", " + _local7 + ", " + _local8);
				}
				if(_local6 != 0) {
					_local5.push("sub ft4, ft5, " + _local7 + ".wwww","mul ft0, ft0, ft4","add ft0, ft0, " + _local7);
				}
				_local6++;
			}
			_local5.push("mov oc, ft0");
			return Program.fromSource(_local3.join("\n"),_local5.join("\n"));
		}
		return super.createProgram();
	}
	
	override protected function get programVariantName() : uint {
		var _local3:* = 0;
		var _local6:CompositeLayer = null;
		var _local5:int = 0;
		var _local2:uint = 0;
		var _local4:Array = getUsedLayers(sLayers);
		var _local1:int = int(_local4.length);
		_local5 = 0;
		while(_local5 < _local1) {
			_local6 = _local4[_local5];
			_local3 = uint(RenderUtil.getTextureVariantBits(_local6.texture) | int(_local6.replaceColor) << 3);
			_local2 |= _local3 << _local5 * 4;
			_local5++;
		}
		return _local2;
	}
	
	override protected function beforeDraw(context:Context3D) : void {
		var _local5:int = 0;
		var _local6:CompositeLayer = null;
		var _local3:Texture = null;
		var _local7:Number = NaN;
		var _local4:Array = getUsedLayers(sLayers);
		var _local2:int = int(_local4.length);
		if(_local2) {
			_local5 = 0;
			while(_local5 < _local2) {
				_local6 = _local4[_local5];
				_local3 = _local6.texture;
				_local7 = _local6.replaceColor ? 1 : _local6.alpha;
				sOffset[0] = -_local6.x / (_local3.root.nativeWidth / _local3.scale);
				sOffset[1] = -_local6.y / (_local3.root.nativeHeight / _local3.scale);
				sColor[0] = Color.getRed(_local6.color) * _local7 / 255;
				sColor[1] = Color.getGreen(_local6.color) * _local7 / 255;
				sColor[2] = Color.getBlue(_local6.color) * _local7 / 255;
				sColor[3] = _local6.alpha;
				context.setProgramConstantsFromVector("vertex",_local5 + 4,sOffset);
				context.setProgramConstantsFromVector("fragment",_local5,sColor);
				context.setTextureAt(_local5,_local3.base);
				RenderUtil.setSamplerStateAt(_local5,_local3.mipMapping,textureSmoothing);
				_local5++;
			}
			_local5 = 1;
			while(_local5 < _local2) {
				vertexFormat.setVertexBufferAt(_local5 + 1,vertexBuffer,"texCoords" + _local5);
				_local5++;
			}
		}
		super.beforeDraw(context);
	}
	
	override protected function afterDraw(context:Context3D) : void {
		var _local4:int = 0;
		var _local3:Array = getUsedLayers(sLayers);
		var _local2:int = int(_local3.length);
		_local4 = 0;
		while(_local4 < _local2) {
			context.setTextureAt(_local4,null);
			context.setVertexBufferAt(_local4 + 1,null);
			_local4++;
		}
		super.afterDraw(context);
	}
	
	override public function get vertexFormat() : VertexDataFormat {
		return VERTEX_FORMAT;
	}
	
	public function get numLayers() : int {
		return _layers.length;
	}
	
	override public function set texture(value:Texture) : void {
		_layers[0].texture = value;
		super.texture = value;
	}
}

class CompositeLayer {
	public var texture:Texture;
	
	public var x:Number;
	
	public var y:Number;
	
	public var color:uint;
	
	public var alpha:Number;
	
	public var replaceColor:Boolean;
	
	public function CompositeLayer() {
		super();
		x = y = 0;
		alpha = 1;
		color = 0xffffff;
	}
}
