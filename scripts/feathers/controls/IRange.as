package feathers.controls {
	import feathers.core.IFeathersControl;
	
	public interface IRange extends IFeathersControl {
		function get minimum() : Number;
		
		function set minimum(value:Number) : void;
		
		function get maximum() : Number;
		
		function set maximum(value:Number) : void;
		
		function get value() : Number;
		
		function set value(value:Number) : void;
		
		function get step() : Number;
		
		function set step(value:Number) : void;
	}
}

