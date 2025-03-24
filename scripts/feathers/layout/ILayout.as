package feathers.layout {
	import feathers.core.IFeathersEventDispatcher;
	import flash.geom.Point;
	import starling.display.DisplayObject;
	
	public interface ILayout extends IFeathersEventDispatcher {
		function get requiresLayoutOnScroll() : Boolean;
		
		function layout(items:Vector.<DisplayObject>, viewPortBounds:ViewPortBounds = null, result:LayoutBoundsResult = null) : LayoutBoundsResult;
		
		function getScrollPositionForIndex(index:int, items:Vector.<DisplayObject>, x:Number, y:Number, width:Number, height:Number, result:Point = null) : Point;
		
		function getNearestScrollPositionForIndex(index:int, scrollX:Number, scrollY:Number, items:Vector.<DisplayObject>, x:Number, y:Number, width:Number, height:Number, result:Point = null) : Point;
	}
}

