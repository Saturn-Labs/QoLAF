package starling.rendering {
	import flash.display3D.Context3D;
	import flash.utils.getQualifiedClassName;
	
	public class MeshEffect extends FilterEffect {
		public static const VERTEX_FORMAT:VertexDataFormat = FilterEffect.VERTEX_FORMAT.extend("color:bytes4");
		
		private static var sRenderAlpha:Vector.<Number> = new Vector.<Number>(4,true);
		
		private var _alpha:Number;
		
		private var _tinted:Boolean;
		
		private var _optimizeIfNotTinted:Boolean;
		
		public function MeshEffect() {
			super();
			_alpha = 1;
			_optimizeIfNotTinted = getQualifiedClassName(this) == "starling.rendering::MeshEffect";
		}
		
		override protected function get programVariantName() : uint {
			var _local1:uint = uint(_optimizeIfNotTinted && !_tinted && _alpha == 1);
			return super.programVariantName | _local1 << 3;
		}
		
		override protected function createProgram() : Program {
			var _local2:String = null;
			var _local1:String = null;
			if(texture) {
				if(_optimizeIfNotTinted && !_tinted && _alpha == 1) {
					return super.createProgram();
				}
				_local1 = "m44 op, va0, vc0 \nmov v0, va1      \nmul v1, va2, vc4 \n";
				_local2 = tex("ft0","v0",0,texture) + "mul oc, ft0, v1  \n";
			} else {
				_local1 = "m44 op, va0, vc0 \nmul v0, va2, vc4 \n";
				_local2 = "mov oc, v0       \n";
			}
			return Program.fromSource(_local1,_local2);
		}
		
		override protected function beforeDraw(context:Context3D) : void {
			super.beforeDraw(context);
			sRenderAlpha[0] = sRenderAlpha[1] = sRenderAlpha[2] = sRenderAlpha[3] = _alpha;
			context.setProgramConstantsFromVector("vertex",4,sRenderAlpha);
			if(_tinted || _alpha != 1 || !_optimizeIfNotTinted || texture == null) {
				vertexFormat.setVertexBufferAt(2,vertexBuffer,"color");
			}
		}
		
		override protected function afterDraw(context:Context3D) : void {
			context.setVertexBufferAt(2,null);
			super.afterDraw(context);
		}
		
		override public function get vertexFormat() : VertexDataFormat {
			return VERTEX_FORMAT;
		}
		
		public function get alpha() : Number {
			return _alpha;
		}
		
		public function set alpha(value:Number) : void {
			_alpha = value;
		}
		
		public function get tinted() : Boolean {
			return _tinted;
		}
		
		public function set tinted(value:Boolean) : void {
			_tinted = value;
		}
	}
}

