package starling.rendering {
	import flash.display3D.Context3D;
	import starling.textures.Texture;
	import starling.utils.RenderUtil;
	
	public class FilterEffect extends Effect {
		public static const STD_VERTEX_SHADER:String = "m44 op, va0, vc0 \nmov v0, va1";
		
		public static const VERTEX_FORMAT:VertexDataFormat = Effect.VERTEX_FORMAT.extend("texCoords:float2");
		
		private var _texture:Texture;
		
		private var _textureSmoothing:String;
		
		private var _textureRepeat:Boolean;
		
		public function FilterEffect() {
			super();
			_textureSmoothing = "bilinear";
		}
		
		protected static function tex(resultReg:String, uvReg:String, sampler:int, texture:Texture, convertToPmaIfRequired:Boolean = true) : String {
			return RenderUtil.createAGALTexOperation(resultReg,uvReg,sampler,texture,convertToPmaIfRequired);
		}
		
		override protected function get programVariantName() : uint {
			return RenderUtil.getTextureVariantBits(_texture);
		}
		
		override protected function createProgram() : Program {
			var _local1:String = null;
			var _local2:String = null;
			if(_texture) {
				_local1 = "m44 op, va0, vc0 \nmov v0, va1";
				_local2 = tex("oc","v0",0,_texture);
				return Program.fromSource(_local1,_local2);
			}
			return super.createProgram();
		}
		
		override protected function beforeDraw(context:Context3D) : void {
			var _local2:Boolean = false;
			super.beforeDraw(context);
			if(_texture) {
				_local2 = _textureRepeat && _texture.root.isPotTexture;
				RenderUtil.setSamplerStateAt(0,_texture.mipMapping,_textureSmoothing,_local2);
				context.setTextureAt(0,_texture.base);
				vertexFormat.setVertexBufferAt(1,vertexBuffer,"texCoords");
			}
		}
		
		override protected function afterDraw(context:Context3D) : void {
			if(_texture) {
				context.setTextureAt(0,null);
				context.setVertexBufferAt(1,null);
			}
			super.afterDraw(context);
		}
		
		override public function get vertexFormat() : VertexDataFormat {
			return VERTEX_FORMAT;
		}
		
		public function get texture() : Texture {
			return _texture;
		}
		
		public function set texture(value:Texture) : void {
			_texture = value;
		}
		
		public function get textureSmoothing() : String {
			return _textureSmoothing;
		}
		
		public function set textureSmoothing(value:String) : void {
			_textureSmoothing = value;
		}
		
		public function get textureRepeat() : Boolean {
			return _textureRepeat;
		}
		
		public function set textureRepeat(value:Boolean) : void {
			_textureRepeat = value;
		}
	}
}

