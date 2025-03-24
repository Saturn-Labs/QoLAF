package feathers.layout {
	import starling.display.DisplayObject;
	
	public interface IVariableVirtualLayout extends IVirtualLayout {
		function get hasVariableItemDimensions() : Boolean;
		
		function set hasVariableItemDimensions(value:Boolean) : void;
		
		function resetVariableVirtualCache() : void;
		
		function resetVariableVirtualCacheAtIndex(index:int, item:DisplayObject = null) : void;
		
		function addToVariableVirtualCacheAtIndex(index:int, item:DisplayObject = null) : void;
		
		function removeFromVariableVirtualCacheAtIndex(index:int) : void;
	}
}

