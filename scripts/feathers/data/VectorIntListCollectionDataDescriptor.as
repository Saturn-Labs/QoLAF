package feathers.data {
	import flash.errors.IllegalOperationError;
	
	public class VectorIntListCollectionDataDescriptor implements IListCollectionDataDescriptor {
		public function VectorIntListCollectionDataDescriptor() {
			super();
		}
		
		public function getLength(data:Object) : int {
			this.checkForCorrectDataType(data);
			return (data as Vector.<int>).length;
		}
		
		public function getItemAt(data:Object, index:int) : Object {
			this.checkForCorrectDataType(data);
			return (data as Vector.<int>)[index];
		}
		
		public function setItemAt(data:Object, item:Object, index:int) : void {
			this.checkForCorrectDataType(data);
			(data as Vector.<int>)[index] = item as int;
		}
		
		public function addItemAt(data:Object, item:Object, index:int) : void {
			this.checkForCorrectDataType(data);
			(data as Vector.<int>).insertAt(index,item as int);
		}
		
		public function removeItemAt(data:Object, index:int) : Object {
			this.checkForCorrectDataType(data);
			return (data as Vector.<int>).removeAt(index);
		}
		
		public function removeAll(data:Object) : void {
			this.checkForCorrectDataType(data);
			(data as Vector.<int>).length = 0;
		}
		
		public function getItemIndex(data:Object, item:Object) : int {
			this.checkForCorrectDataType(data);
			return (data as Vector.<int>).indexOf(item as int);
		}
		
		protected function checkForCorrectDataType(data:Object) : void {
			if(!(data is Vector.<int>)) {
				throw new IllegalOperationError("Expected Vector.<int>. Received " + Object(data).constructor + " instead.");
			}
		}
	}
}

