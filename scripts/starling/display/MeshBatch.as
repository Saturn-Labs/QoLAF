package starling.display {
	import flash.geom.Matrix;
	import starling.rendering.IndexData;
	import starling.rendering.MeshEffect;
	import starling.rendering.Painter;
	import starling.rendering.VertexData;
	import starling.styles.MeshStyle;
	import starling.utils.MatrixUtil;
	import starling.utils.MeshSubset;
	
	public class MeshBatch extends Mesh {
		public static const MAX_NUM_VERTICES:int = 65535;
		
		private static var sFullMeshSubset:MeshSubset = new MeshSubset();
		
		private var _effect:MeshEffect;
		
		private var _batchable:Boolean;
		
		private var _vertexSyncRequired:Boolean;
		
		private var _indexSyncRequired:Boolean;
		
		public function MeshBatch() {
			var _local1:VertexData = new VertexData();
			var _local2:IndexData = new IndexData();
			super(_local1,_local2);
		}
		
		override public function dispose() : void {
			if(_effect) {
				_effect.dispose();
			}
			super.dispose();
		}
		
		override public function setVertexDataChanged() : void {
			_vertexSyncRequired = true;
			super.setVertexDataChanged();
		}
		
		override public function setIndexDataChanged() : void {
			_indexSyncRequired = true;
			super.setIndexDataChanged();
		}
		
		private function setVertexAndIndexDataChanged() : void {
			_vertexSyncRequired = _indexSyncRequired = true;
		}
		
		private function syncVertexBuffer() : void {
			_effect.uploadVertexData(_vertexData);
			_vertexSyncRequired = false;
		}
		
		private function syncIndexBuffer() : void {
			_effect.uploadIndexData(_indexData);
			_indexSyncRequired = false;
		}
		
		public function clear() : void {
			if(_parent) {
				setRequiresRedraw();
			}
			_vertexData.numVertices = 0;
			_indexData.numIndices = 0;
			_vertexSyncRequired = true;
			_indexSyncRequired = true;
		}
		
		public function addMesh(mesh:Mesh, matrix:Matrix = null, alpha:Number = 1, subset:MeshSubset = null, ignoreTransformations:Boolean = false) : void {
			if(ignoreTransformations) {
				matrix = null;
			} else if(matrix == null) {
				matrix = mesh.transformationMatrix;
			}
			if(subset == null) {
				subset = sFullMeshSubset;
			}
			var _local7:int = int(_vertexData.numVertices);
			var _local8:int = int(_indexData.numIndices);
			var _local6:MeshStyle = mesh._style;
			if(_local7 == 0) {
				setupFor(mesh);
			}
			_local6.batchVertexData(_style,_local7,matrix,subset.vertexID,subset.numVertices);
			_local6.batchIndexData(_style,_local8,_local7 - subset.vertexID,subset.indexID,subset.numIndices);
			if(alpha != 1) {
				_vertexData.scaleAlphas("color",alpha,_local7,subset.numVertices);
			}
			if(_parent) {
				setRequiresRedraw();
			}
			_indexSyncRequired = _vertexSyncRequired = true;
		}
		
		public function addMeshAt(mesh:Mesh, indexID:int, vertexID:int) : void {
			var _local5:int = mesh.numIndices;
			var _local4:int = mesh.numVertices;
			var _local7:Matrix = mesh.transformationMatrix;
			var _local6:MeshStyle = mesh._style;
			if(_vertexData.numVertices == 0) {
				setupFor(mesh);
			}
			_local6.batchVertexData(_style,vertexID,_local7,0,_local4);
			_local6.batchIndexData(_style,indexID,vertexID,0,_local5);
			if(alpha != 1) {
				_vertexData.scaleAlphas("color",alpha,vertexID,_local4);
			}
			if(_parent) {
				setRequiresRedraw();
			}
			_indexSyncRequired = _vertexSyncRequired = true;
		}
		
		private function setupFor(mesh:Mesh) : void {
			var _local3:MeshStyle = mesh._style;
			var _local2:Class = _local3.type;
			if(_style.type != _local2) {
				setStyle(new _local2() as MeshStyle,false);
			}
			_style.copyFrom(_local3);
		}
		
		public function canAddMesh(mesh:Mesh, numVertices:int = -1) : Boolean {
			var _local3:int = int(_vertexData.numVertices);
			if(_local3 == 0) {
				return true;
			}
			if(numVertices < 0) {
				numVertices = mesh.numVertices;
			}
			if(numVertices == 0) {
				return true;
			}
			if(numVertices + _local3 > 0xffff) {
				return false;
			}
			return _style.canBatchWith(mesh._style);
		}
		
		override public function render(painter:Painter) : void {
			if(_vertexData.numVertices == 0) {
				return;
			}
			if(_pixelSnapping) {
				MatrixUtil.snapToPixels(painter.state.modelviewMatrix,painter.pixelSize);
			}
			if(_batchable) {
				painter.batchMesh(this);
			} else {
				painter.finishMeshBatch();
				painter.drawCount += 1;
				painter.prepareToDraw();
				painter.excludeFromCache(this);
				if(_vertexSyncRequired) {
					syncVertexBuffer();
				}
				if(_indexSyncRequired) {
					syncIndexBuffer();
				}
				_style.updateEffect(_effect,painter.state);
				_effect.render(0,_indexData.numTriangles);
			}
		}
		
		override public function setStyle(meshStyle:MeshStyle = null, mergeWithPredecessor:Boolean = true) : void {
			super.setStyle(meshStyle,mergeWithPredecessor);
			if(_effect) {
				_effect.dispose();
			}
			_effect = style.createEffect();
			_effect.onRestore = setVertexAndIndexDataChanged;
			setVertexAndIndexDataChanged();
		}
		
		public function set numVertices(value:int) : void {
			if(_vertexData.numVertices != value) {
				_vertexData.numVertices = value;
				_vertexSyncRequired = true;
				setRequiresRedraw();
			}
		}
		
		public function set numIndices(value:int) : void {
			if(_indexData.numIndices != value) {
				_indexData.numIndices = value;
				_indexSyncRequired = true;
				setRequiresRedraw();
			}
		}
		
		public function get batchable() : Boolean {
			return _batchable;
		}
		
		public function set batchable(value:Boolean) : void {
			if(_batchable != value) {
				_batchable = value;
				setRequiresRedraw();
			}
		}
	}
}

