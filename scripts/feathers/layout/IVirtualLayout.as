package feathers.layout {
	import flash.geom.Point;
	import starling.display.DisplayObject;
	
	public interface IVirtualLayout extends ILayout {
		function get useVirtualLayout() : Boolean;
		
		function set useVirtualLayout(value:Boolean) : void;
		
		function get typicalItem() : DisplayObject;
		
		function set typicalItem(value:DisplayObject) : void;
		
		function measureViewPort(itemCount:int, viewPortBounds:ViewPortBounds = null, result:Point = null) : Point;
		
		function getVisibleIndicesAtScrollPosition(scrollX:Number, scrollY:Number, width:Number, height:Number, itemCount:int, result:Vector.<int> = null) : Vector.<int>;
	}
}

