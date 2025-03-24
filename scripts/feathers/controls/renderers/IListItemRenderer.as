package feathers.controls.renderers {
	import feathers.controls.List;
	import feathers.core.IToggle;
	
	public interface IListItemRenderer extends IToggle {
		function get data() : Object;
		
		function set data(value:Object) : void;
		
		function get index() : int;
		
		function set index(value:int) : void;
		
		function get owner() : List;
		
		function set owner(value:List) : void;
		
		function get factoryID() : String;
		
		function set factoryID(value:String) : void;
	}
}

