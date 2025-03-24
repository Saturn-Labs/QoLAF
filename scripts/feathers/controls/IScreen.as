package feathers.controls {
	import feathers.core.IFeathersControl;
	
	public interface IScreen extends IFeathersControl {
		function get screenID() : String;
		
		function set screenID(value:String) : void;
		
		function get owner() : Object;
		
		function set owner(value:Object) : void;
	}
}

