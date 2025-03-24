package feathers.controls {
	import feathers.core.IFeathersControl;
	import starling.display.DisplayObject;
	
	public interface IScrollContainer extends IFeathersControl {
		function get numRawChildren() : int;
		
		function getRawChildByName(name:String) : DisplayObject;
		
		function getRawChildIndex(child:DisplayObject) : int;
		
		function getRawChildAt(index:int) : DisplayObject;
		
		function setRawChildIndex(child:DisplayObject, index:int) : void;
		
		function addRawChild(child:DisplayObject) : DisplayObject;
		
		function addRawChildAt(child:DisplayObject, index:int) : DisplayObject;
		
		function removeRawChild(child:DisplayObject, dispose:Boolean = false) : DisplayObject;
		
		function removeRawChildAt(index:int, dispose:Boolean = false) : DisplayObject;
		
		function swapRawChildren(child1:DisplayObject, child2:DisplayObject) : void;
		
		function swapRawChildrenAt(index1:int, index2:int) : void;
		
		function sortRawChildren(compareFunction:Function) : void;
	}
}

