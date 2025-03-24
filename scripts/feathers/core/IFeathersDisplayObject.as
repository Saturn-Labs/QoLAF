package feathers.core {
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Stage;
	import starling.filters.FragmentFilter;
	import starling.rendering.Painter;
	
	public interface IFeathersDisplayObject extends IFeathersEventDispatcher {
		function get x() : Number;
		
		function set x(value:Number) : void;
		
		function get y() : Number;
		
		function set y(value:Number) : void;
		
		function get width() : Number;
		
		function set width(value:Number) : void;
		
		function get height() : Number;
		
		function set height(value:Number) : void;
		
		function get pivotX() : Number;
		
		function set pivotX(value:Number) : void;
		
		function get pivotY() : Number;
		
		function set pivotY(value:Number) : void;
		
		function get scaleX() : Number;
		
		function set scaleX(value:Number) : void;
		
		function get scaleY() : Number;
		
		function set scaleY(value:Number) : void;
		
		function get skewX() : Number;
		
		function set skewX(value:Number) : void;
		
		function get skewY() : Number;
		
		function set skewY(value:Number) : void;
		
		function get blendMode() : String;
		
		function set blendMode(value:String) : void;
		
		function get name() : String;
		
		function set name(value:String) : void;
		
		function get touchable() : Boolean;
		
		function set touchable(value:Boolean) : void;
		
		function get visible() : Boolean;
		
		function set visible(value:Boolean) : void;
		
		function get alpha() : Number;
		
		function set alpha(value:Number) : void;
		
		function get rotation() : Number;
		
		function set rotation(value:Number) : void;
		
		function get mask() : DisplayObject;
		
		function set mask(value:DisplayObject) : void;
		
		function get parent() : DisplayObjectContainer;
		
		function get base() : DisplayObject;
		
		function get root() : DisplayObject;
		
		function get stage() : Stage;
		
		function get transformationMatrix() : Matrix;
		
		function get useHandCursor() : Boolean;
		
		function set useHandCursor(value:Boolean) : void;
		
		function get bounds() : Rectangle;
		
		function get filter() : FragmentFilter;
		
		function set filter(value:FragmentFilter) : void;
		
		function removeFromParent(dispose:Boolean = false) : void;
		
		function hitTest(localPoint:Point) : DisplayObject;
		
		function localToGlobal(localPoint:Point, resultPoint:Point = null) : Point;
		
		function globalToLocal(globalPoint:Point, resultPoint:Point = null) : Point;
		
		function getTransformationMatrix(targetSpace:DisplayObject, resultMatrix:Matrix = null) : Matrix;
		
		function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null) : Rectangle;
		
		function render(painter:Painter) : void;
		
		function dispose() : void;
	}
}

