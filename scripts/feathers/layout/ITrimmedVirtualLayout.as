package feathers.layout {
	public interface ITrimmedVirtualLayout extends IVirtualLayout {
		function get beforeVirtualizedItemCount() : int;
		
		function set beforeVirtualizedItemCount(value:int) : void;
		
		function get afterVirtualizedItemCount() : int;
		
		function set afterVirtualizedItemCount(value:int) : void;
	}
}

