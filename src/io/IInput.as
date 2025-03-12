package io
{
	
	public interface IInput
	{
		function get isMousePressed():Boolean;
		
		function get isMouseRightPressed():Boolean;
		
		function isKeyPressed(param1:uint):Boolean;
		
		function isKeyReleased(param1:uint):Boolean;
		
		function isKeyDown(param1:uint):Boolean;
		
		function isKeyUp(param1:uint):Boolean;
		
		function listenToKeys(param1:Array, param2:Function):void;
		
		function stopListenToKeys(param1:Function):void;
		
		function dispose():void;
		
		function isAnyKeyPressed():Boolean;
		
		function hasMouseMoved():Boolean;
		
		function reset():void;
	}
}
