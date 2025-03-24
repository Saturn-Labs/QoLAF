package feathers.controls.renderers {
	import feathers.controls.GroupedList;
	import feathers.core.IToggle;
	
	public interface IGroupedListItemRenderer extends IToggle {
		function get data() : Object;
		
		function set data(value:Object) : void;
		
		function get groupIndex() : int;
		
		function set groupIndex(value:int) : void;
		
		function get itemIndex() : int;
		
		function set itemIndex(value:int) : void;
		
		function get layoutIndex() : int;
		
		function set layoutIndex(value:int) : void;
		
		function get owner() : GroupedList;
		
		function set owner(value:GroupedList) : void;
		
		function get factoryID() : String;
		
		function set factoryID(value:String) : void;
	}
}

