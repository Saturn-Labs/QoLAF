package mx.core {
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	public interface IChildList {
		function get numChildren() : int;
		
		function addChild(child:DisplayObject) : DisplayObject;
		
		function addChildAt(child:DisplayObject, index:int) : DisplayObject;
		
		function removeChild(child:DisplayObject) : DisplayObject;
		
		function removeChildAt(index:int) : DisplayObject;
		
		function getChildAt(index:int) : DisplayObject;
		
		function getChildByName(name:String) : DisplayObject;
		
		function getChildIndex(child:DisplayObject) : int;
		
		function setChildIndex(child:DisplayObject, newIndex:int) : void;
		
		function getObjectsUnderPoint(point:Point) : Array;
		
		function contains(child:DisplayObject) : Boolean;
	}
}

