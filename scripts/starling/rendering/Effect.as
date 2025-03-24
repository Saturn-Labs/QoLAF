package starling.rendering {
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import starling.core.Starling;
	import starling.errors.MissingContextError;
	import starling.utils.execute;
	
	public class Effect {
		public static const VERTEX_FORMAT:VertexDataFormat = VertexDataFormat.fromString("position:float2");
		
		private static var sProgramNameCache:Dictionary = new Dictionary();
		
		private var _vertexBuffer:VertexBuffer3D;
		
		private var _vertexBufferSize:int;
		
		private var _indexBuffer:IndexBuffer3D;
		
		private var _indexBufferSize:int;
		
		private var _indexBufferUsesQuadLayout:Boolean;
		
		private var _mvpMatrix3D:Matrix3D;
		
		private var _onRestore:Function;
		
		private var _programBaseName:String;
		
		public function Effect() {
			super();
			_mvpMatrix3D = new Matrix3D();
			_programBaseName = getQualifiedClassName(this);
			Starling.current.stage3D.addEventListener("context3DCreate",onContextCreated,false,20,true);
		}
		
		public function dispose() : void {
			Starling.current.stage3D.removeEventListener("context3DCreate",onContextCreated);
			purgeBuffers();
		}
		
		private function onContextCreated(event:Event) : void {
			purgeBuffers();
			execute(_onRestore,this);
		}
		
		public function purgeBuffers(vertexBuffer:Boolean = true, indexBuffer:Boolean = true) : void {
			if(_vertexBuffer && vertexBuffer) {
				try {
					_vertexBuffer.dispose();
				}
				catch(e:Error) {
				}
				_vertexBuffer = null;
			}
			if(_indexBuffer && indexBuffer) {
				try {
					_indexBuffer.dispose();
				}
				catch(e:Error) {
				}
				_indexBuffer = null;
			}
		}
		
		public function uploadIndexData(indexData:IndexData, bufferUsage:String = "staticDraw") : void {
			var _local3:int = indexData.numIndices;
			var _local5:Boolean = indexData.useQuadLayout;
			var _local4:Boolean = _indexBufferUsesQuadLayout;
			if(_indexBuffer) {
				if(_local3 <= _indexBufferSize) {
					if(!_local5 || !_local4) {
						indexData.uploadToIndexBuffer(_indexBuffer);
						_indexBufferUsesQuadLayout = _local5 && _local3 == _indexBufferSize;
					}
				} else {
					purgeBuffers(false,true);
				}
			}
			if(_indexBuffer == null) {
				_indexBuffer = indexData.createIndexBuffer(true,bufferUsage);
				_indexBufferSize = _local3;
				_indexBufferUsesQuadLayout = _local5;
			}
		}
		
		public function uploadVertexData(vertexData:VertexData, bufferUsage:String = "staticDraw") : void {
			if(_vertexBuffer) {
				if(vertexData.size <= _vertexBufferSize) {
					vertexData.uploadToVertexBuffer(_vertexBuffer);
				} else {
					purgeBuffers(true,false);
				}
			}
			if(_vertexBuffer == null) {
				_vertexBuffer = vertexData.createVertexBuffer(true,bufferUsage);
				_vertexBufferSize = vertexData.size;
			}
		}
		
		public function render(firstIndex:int = 0, numTriangles:int = -1) : void {
			if(numTriangles < 0) {
				numTriangles = _indexBufferSize / 3;
			}
			if(numTriangles == 0) {
				return;
			}
			var _local3:Context3D = Starling.context;
			if(_local3 == null) {
				throw new MissingContextError();
			}
			beforeDraw(_local3);
			_local3.drawTriangles(indexBuffer,firstIndex,numTriangles);
			afterDraw(_local3);
		}
		
		protected function beforeDraw(context:Context3D) : void {
			program.activate(context);
			vertexFormat.setVertexBufferAt(0,vertexBuffer,"position");
			context.setProgramConstantsFromMatrix("vertex",0,mvpMatrix3D,true);
		}
		
		protected function afterDraw(context:Context3D) : void {
			context.setVertexBufferAt(0,null);
		}
		
		protected function createProgram() : Program {
			var _local1:String = ["m44 op, va0, vc0","seq v0, va0, va0"].join("\n");
			var _local2:String = "mov oc, v0";
			return Program.fromSource(_local1,_local2);
		}
		
		protected function get programVariantName() : uint {
			return 0;
		}
		
		protected function get programBaseName() : String {
			return _programBaseName;
		}
		
		protected function set programBaseName(value:String) : void {
			_programBaseName = value;
		}
		
		protected function get programName() : String {
			var _local3:String = this.programBaseName;
			var _local2:uint = this.programVariantName;
			var _local4:Dictionary = sProgramNameCache[_local3];
			if(_local4 == null) {
				_local4 = new Dictionary();
				sProgramNameCache[_local3] = _local4;
			}
			var _local1:* = _local4[_local2];
			if(_local1 == null) {
				if(_local2) {
					_local1 = _local3 + "#" + _local2.toString(16);
				} else {
					_local1 = _local3;
				}
				_local4[_local2] = _local1;
			}
			return _local1;
		}
		
		protected function get program() : Program {
			var _local2:String = this.programName;
			var _local1:Painter = Starling.painter;
			var _local3:Program = _local1.getProgram(_local2);
			if(_local3 == null) {
				_local3 = createProgram();
				_local1.registerProgram(_local2,_local3);
			}
			return _local3;
		}
		
		public function get onRestore() : Function {
			return _onRestore;
		}
		
		public function set onRestore(value:Function) : void {
			_onRestore = value;
		}
		
		public function get vertexFormat() : VertexDataFormat {
			return VERTEX_FORMAT;
		}
		
		public function get mvpMatrix3D() : Matrix3D {
			return _mvpMatrix3D;
		}
		
		public function set mvpMatrix3D(value:Matrix3D) : void {
			_mvpMatrix3D.copyFrom(value);
		}
		
		protected function get indexBuffer() : IndexBuffer3D {
			return _indexBuffer;
		}
		
		protected function get indexBufferSize() : int {
			return _indexBufferSize;
		}
		
		protected function get vertexBuffer() : VertexBuffer3D {
			return _vertexBuffer;
		}
		
		protected function get vertexBufferSize() : int {
			return _vertexBufferSize;
		}
	}
}

