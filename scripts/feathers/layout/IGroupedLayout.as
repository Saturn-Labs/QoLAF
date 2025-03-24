package feathers.layout {
	public interface IGroupedLayout extends ILayout {
		function get headerIndices() : Vector.<int>;
		
		function set headerIndices(value:Vector.<int>) : void;
	}
}

