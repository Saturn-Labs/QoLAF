package starling.text {
	import starling.display.MeshBatch;
	
	public interface ITextCompositor {
		function fillMeshBatch(meshBatch:MeshBatch, width:Number, height:Number, text:String, format:TextFormat, options:TextOptions = null) : void;
		
		function clearMeshBatch(meshBatch:MeshBatch) : void;
		
		function dispose() : void;
	}
}

