package mx.core {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import mx.managers.ISystemManager;
	
	public interface IUIComponent extends IFlexDisplayObject {
		function get baselinePosition() : Number;
		
		function get document() : Object;
		
		function set document(value:Object) : void;
		
		function get enabled() : Boolean;
		
		function set enabled(value:Boolean) : void;
		
		function get explicitHeight() : Number;
		
		function set explicitHeight(value:Number) : void;
		
		function get explicitMaxHeight() : Number;
		
		function get explicitMaxWidth() : Number;
		
		function get explicitMinHeight() : Number;
		
		function get explicitMinWidth() : Number;
		
		function get explicitWidth() : Number;
		
		function set explicitWidth(value:Number) : void;
		
		function get focusPane() : Sprite;
		
		function set focusPane(value:Sprite) : void;
		
		function get includeInLayout() : Boolean;
		
		function set includeInLayout(value:Boolean) : void;
		
		function get isPopUp() : Boolean;
		
		function set isPopUp(value:Boolean) : void;
		
		function get maxHeight() : Number;
		
		function get maxWidth() : Number;
		
		function get measuredMinHeight() : Number;
		
		function set measuredMinHeight(value:Number) : void;
		
		function get measuredMinWidth() : Number;
		
		function set measuredMinWidth(value:Number) : void;
		
		function get minHeight() : Number;
		
		function get minWidth() : Number;
		
		function get owner() : DisplayObjectContainer;
		
		function set owner(value:DisplayObjectContainer) : void;
		
		function get percentHeight() : Number;
		
		function set percentHeight(value:Number) : void;
		
		function get percentWidth() : Number;
		
		function set percentWidth(value:Number) : void;
		
		function get systemManager() : ISystemManager;
		
		function set systemManager(value:ISystemManager) : void;
		
		function get tweeningProperties() : Array;
		
		function set tweeningProperties(value:Array) : void;
		
		function initialize() : void;
		
		function parentChanged(p:DisplayObjectContainer) : void;
		
		function getExplicitOrMeasuredWidth() : Number;
		
		function getExplicitOrMeasuredHeight() : Number;
		
		function setVisible(value:Boolean, noEvent:Boolean = false) : void;
		
		function owns(displayObject:DisplayObject) : Boolean;
	}
}

