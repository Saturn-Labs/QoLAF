package feathers.core {
	import flash.geom.Point;
	
	public interface ITextRenderer extends IFeathersControl, ITextBaselineControl {
		function get text() : String;
		
		function set text(value:String) : void;
		
		function get wordWrap() : Boolean;
		
		function set wordWrap(value:Boolean) : void;
		
		function measureText(result:Point = null) : Point;
	}
}

