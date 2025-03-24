package feathers.data {
	public interface IHierarchicalCollectionDataDescriptor {
		function isBranch(node:Object) : Boolean;
		
		function getLength(data:Object, ... rest) : int;
		
		function getItemAt(data:Object, index:int, ... rest) : Object;
		
		function setItemAt(data:Object, item:Object, index:int, ... rest) : void;
		
		function addItemAt(data:Object, item:Object, index:int, ... rest) : void;
		
		function removeItemAt(data:Object, index:int, ... rest) : Object;
		
		function removeAll(data:Object) : void;
		
		function getItemLocation(data:Object, item:Object, result:Vector.<int> = null, ... rest) : Vector.<int>;
	}
}

