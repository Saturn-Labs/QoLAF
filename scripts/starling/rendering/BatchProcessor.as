package starling.rendering {
	import flash.geom.Matrix;
	import starling.display.Mesh;
	import starling.display.MeshBatch;
	import starling.utils.MeshSubset;
	
	internal class BatchProcessor {
		private static var sMeshSubset:MeshSubset = new MeshSubset();
		
		private var _batches:Vector.<MeshBatch>;
		
		private var _batchPool:BatchPool;
		
		private var _currentBatch:MeshBatch;
		
		private var _currentStyleType:Class;
		
		private var _onBatchComplete:Function;
		
		private var _cacheToken:BatchToken;
		
		public function BatchProcessor() {
			super();
			_batches = new Vector.<MeshBatch>(0);
			_batchPool = new BatchPool();
			_cacheToken = new BatchToken();
		}
		
		public function dispose() : void {
			for each(var _local1 in _batches) {
				_local1.dispose();
			}
			_batches.length = 0;
			_batchPool.purge();
			_currentBatch = null;
			_onBatchComplete = null;
		}
		
		public function addMesh(mesh:Mesh, state:RenderState, subset:MeshSubset = null, ignoreTransformations:Boolean = false) : void {
			var _local6:Matrix = null;
			var _local5:Number = NaN;
			if(subset == null) {
				subset = sMeshSubset;
				subset.vertexID = subset.indexID = 0;
				subset.numVertices = mesh.numVertices;
				subset.numIndices = mesh.numIndices;
			} else {
				if(subset.numVertices < 0) {
					subset.numVertices = mesh.numVertices - subset.vertexID;
				}
				if(subset.numIndices < 0) {
					subset.numIndices = mesh.numIndices - subset.indexID;
				}
			}
			if(subset.numVertices > 0) {
				if(_currentBatch == null || !_currentBatch.canAddMesh(mesh,subset.numVertices)) {
					finishBatch();
					_currentStyleType = mesh.style.type;
					_currentBatch = _batchPool.get(_currentStyleType);
					_currentBatch.blendMode = !!state ? state.blendMode : mesh.blendMode;
					_cacheToken.setTo(_batches.length);
					_batches[_batches.length] = _currentBatch;
				}
				_local6 = !!state ? state._modelviewMatrix : null;
				_local5 = !!state ? state._alpha : 1;
				_currentBatch.addMesh(mesh,_local6,_local5,subset,ignoreTransformations);
				_cacheToken.vertexID += subset.numVertices;
				_cacheToken.indexID += subset.numIndices;
			}
		}
		
		public function finishBatch() : void {
			var _local1:MeshBatch = _currentBatch;
			if(_local1) {
				_currentBatch = null;
				_currentStyleType = null;
				if(_onBatchComplete != null) {
					_onBatchComplete(_local1);
				}
			}
		}
		
		public function clear() : void {
			var _local1:int = 0;
			var _local2:int = int(_batches.length);
			_local1 = 0;
			while(_local1 < _local2) {
				_batchPool.put(_batches[_local1]);
				_local1++;
			}
			_batches.length = 0;
			_currentBatch = null;
			_currentStyleType = null;
			_cacheToken.reset();
		}
		
		public function getBatchAt(batchID:int) : MeshBatch {
			return _batches[batchID];
		}
		
		public function trim() : void {
			_batchPool.purge();
		}
		
		public function fillToken(token:BatchToken) : BatchToken {
			token.batchID = _cacheToken.batchID;
			token.vertexID = _cacheToken.vertexID;
			token.indexID = _cacheToken.indexID;
			return token;
		}
		
		public function get numBatches() : int {
			return _batches.length;
		}
		
		public function get onBatchComplete() : Function {
			return _onBatchComplete;
		}
		
		public function set onBatchComplete(value:Function) : void {
			_onBatchComplete = value;
		}
	}
}

import flash.utils.Dictionary;
import starling.display.MeshBatch;

class BatchPool {
	private var _batchLists:Dictionary;
	
	public function BatchPool() {
		super();
		_batchLists = new Dictionary();
	}
	
	public function purge() : void {
		var _local1:int = 0;
		for each(var _local2 in _batchLists) {
			_local1 = 0;
			while(_local1 < _local2.length) {
				_local2[_local1].dispose();
				_local1++;
			}
			_local2.length = 0;
		}
	}
	
	public function get(styleType:Class) : MeshBatch {
		var _local2:Vector.<MeshBatch> = _batchLists[styleType];
		if(_local2 == null) {
			_local2 = new Vector.<MeshBatch>(0);
			_batchLists[styleType] = _local2;
		}
		if(_local2.length > 0) {
			return _local2.pop();
		}
		return new MeshBatch();
	}
	
	public function put(meshBatch:MeshBatch) : void {
		var _local2:Class = meshBatch.style.type;
		var _local3:Vector.<MeshBatch> = _batchLists[_local2];
		if(_local3 == null) {
			_local3 = new Vector.<MeshBatch>(0);
			_batchLists[_local2] = _local3;
		}
		meshBatch.clear();
		_local3[_local3.length] = meshBatch;
	}
}
