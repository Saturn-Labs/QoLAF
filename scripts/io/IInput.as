package io {
	public interface IInput {
		function get isMousePressed() : Boolean;
		
		function get isMouseRightPressed() : Boolean;
		
		function isKeyPressed(keyCode:uint) : Boolean;
		
		function isKeyReleased(keyCode:uint) : Boolean;
		
		function isKeyDown(keyCode:uint) : Boolean;
		
		function isKeyUp(keyCode:uint) : Boolean;
		
		function listenToKeys(keys:Array, callback:Function) : void;
		
		function stopListenToKeys(callback:Function) : void;
		
		function dispose() : void;
		
		function isAnyKeyPressed() : Boolean;
		
		function hasMouseMoved() : Boolean;
		
		function reset() : void;
	}
}

