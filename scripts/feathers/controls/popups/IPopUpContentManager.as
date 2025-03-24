package feathers.controls.popups {
	import starling.display.DisplayObject;
	
	public interface IPopUpContentManager {
		function get isOpen() : Boolean;
		
		function open(content:DisplayObject, source:DisplayObject) : void;
		
		function close() : void;
		
		function dispose() : void;
	}
}

