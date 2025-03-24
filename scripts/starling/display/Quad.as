package starling.display {
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import starling.rendering.IndexData;
	import starling.rendering.VertexData;
	import starling.styles.MeshStyle;
	import starling.textures.Texture;
	import starling.utils.RectangleUtil;
	
	public class Quad extends Mesh {
		private static var sPoint3D:Vector3D = new Vector3D();
		
		private static var sMatrix:Matrix = new Matrix();
		
		private static var sMatrix3D:Matrix3D = new Matrix3D();
		
		private var _bounds:Rectangle;
		
		public function Quad(width:Number, height:Number, color:uint = 16777215) {
			_bounds = new Rectangle(0,0,width,height);
			var _local4:VertexData = new VertexData(MeshStyle.VERTEX_FORMAT,4);
			var _local5:IndexData = new IndexData(6);
			super(_local4,_local5);
			if(width == 0 || height == 0) {
				throw new ArgumentError("Invalid size: width and height must not be zero");
			}
			setupVertices();
			this.color = color;
		}
		
		public static function fromTexture(texture:Texture) : Quad {
			var _local2:Quad = new Quad(100,100);
			_local2.texture = texture;
			_local2.readjustSize();
			return _local2;
		}
		
		protected function setupVertices() : void {
			var _local1:String = "position";
			var _local5:String = "texCoords";
			var _local2:Texture = style.texture;
			var _local3:VertexData = this.vertexData;
			var _local4:IndexData = this.indexData;
			_local4.numIndices = 0;
			_local4.addQuad(0,1,2,3);
			if(_local3.numVertices != 4) {
				_local3.numVertices = 4;
				_local3.trim();
			}
			if(_local2) {
				_local2.setupVertexPositions(_local3,0,"position",_bounds);
				_local2.setupTextureCoordinates(_local3,0,_local5);
			} else {
				_local3.setPoint(0,_local1,_bounds.left,_bounds.top);
				_local3.setPoint(1,_local1,_bounds.right,_bounds.top);
				_local3.setPoint(2,_local1,_bounds.left,_bounds.bottom);
				_local3.setPoint(3,_local1,_bounds.right,_bounds.bottom);
				_local3.setPoint(0,_local5,0,0);
				_local3.setPoint(1,_local5,1,0);
				_local3.setPoint(2,_local5,0,1);
				_local3.setPoint(3,_local5,1,1);
			}
			setRequiresRedraw();
		}
		
		override public function getBounds(targetSpace:DisplayObject, out:Rectangle = null) : Rectangle {
			var _local3:Number = NaN;
			var _local4:Number = NaN;
			if(out == null) {
				out = new Rectangle();
			}
			if(targetSpace == this) {
				out.copyFrom(_bounds);
			} else if(targetSpace == parent && !isRotated) {
				_local3 = this.scaleX;
				_local4 = this.scaleY;
				out.setTo(x - pivotX * _local3,y - pivotY * _local4,_bounds.width * _local3,_bounds.height * _local4);
				if(_local3 < 0) {
					out.width *= -1;
					out.x -= out.width;
				}
				if(_local4 < 0) {
					out.height *= -1;
					out.y -= out.height;
				}
			} else if(is3D && stage) {
				stage.getCameraPosition(targetSpace,sPoint3D);
				getTransformationMatrix3D(targetSpace,sMatrix3D);
				RectangleUtil.getBoundsProjected(_bounds,sMatrix3D,sPoint3D,out);
			} else {
				getTransformationMatrix(targetSpace,sMatrix);
				RectangleUtil.getBounds(_bounds,sMatrix,out);
			}
			return out;
		}
		
		override public function hitTest(localPoint:Point) : DisplayObject {
			if(!visible || !touchable || !hitTestMask(localPoint)) {
				return null;
			}
			if(_bounds.containsPoint(localPoint)) {
				return this;
			}
			return null;
		}
		
		public function readjustSize(width:Number = -1, height:Number = -1) : void {
			if(width <= 0) {
				width = !!texture ? texture.frameWidth : _bounds.width;
			}
			if(height <= 0) {
				height = !!texture ? texture.frameHeight : _bounds.height;
			}
			if(width != _bounds.width || height != _bounds.height) {
				_bounds.setTo(0,0,width,height);
				setupVertices();
			}
		}
		
		override public function set texture(value:Texture) : void {
			if(value != texture) {
				super.texture = value;
				setupVertices();
			}
		}
	}
}

