package feathers.core {
	import starling.display.DisplayObjectContainer;
	
	public interface IFocusManager {
		function get isEnabled() : Boolean;
		
		function set isEnabled(value:Boolean) : void;
		
		function get focus() : IFocusDisplayObject;
		
		function set focus(value:IFocusDisplayObject) : void;
		
		function get root() : DisplayObjectContainer;
	}
}

