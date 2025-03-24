package feathers.layout {
	import feathers.core.IFeathersDisplayObject;
	
	public interface ILayoutDisplayObject extends IFeathersDisplayObject {
		function get layoutData() : ILayoutData;
		
		function set layoutData(value:ILayoutData) : void;
		
		function get includeInLayout() : Boolean;
		
		function set includeInLayout(value:Boolean) : void;
	}
}

