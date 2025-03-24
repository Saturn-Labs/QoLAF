package feathers.core {
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	
	public interface IPopUpManager {
		function get overlayFactory() : Function;
		
		function set overlayFactory(value:Function) : void;
		
		function get root() : DisplayObjectContainer;
		
		function set root(value:DisplayObjectContainer) : void;
		
		function addPopUp(popUp:DisplayObject, isModal:Boolean = true, isCentered:Boolean = true, customOverlayFactory:Function = null) : DisplayObject;
		
		function removePopUp(popUp:DisplayObject, dispose:Boolean = false) : DisplayObject;
		
		function isPopUp(popUp:DisplayObject) : Boolean;
		
		function isTopLevelPopUp(popUp:DisplayObject) : Boolean;
		
		function centerPopUp(popUp:DisplayObject) : void;
	}
}

