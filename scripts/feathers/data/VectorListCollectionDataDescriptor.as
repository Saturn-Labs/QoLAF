package feathers.data {
	import flash.errors.IllegalOperationError;
	
	public class VectorListCollectionDataDescriptor implements IListCollectionDataDescriptor {
		public function VectorListCollectionDataDescriptor() {
			super();
		}
		
		public function getLength(data:Object) : int {
			this.checkForCorrectDataType(data);
			return (data as Vector.<*>).length;
		}
		
		public function getItemAt(data:Object, index:int) : Object {
			this.checkForCorrectDataType(data);
			return (data as Vector.<*>)[index];
		}
		
		public function setItemAt(data:Object, item:Object, index:int) : void {
			this.checkForCorrectDataType(data);
			(data as Vector.<*>)[index] = item;
		}
		
		public function addItemAt(data:Object, item:Object, index:int) : void {
			this.checkForCorrectDataType(data);
			(data as Vector.<*>).insertAt(index,item);
		}
		
		public function removeItemAt(data:Object, index:int) : Object {
			this.checkForCorrectDataType(data);
			return (data as Vector.<*>).removeAt(index);
		}
		
		public function removeAll(data:Object) : void {
			this.checkForCorrectDataType(data);
			(data as Vector.<*>).length = 0;
		}
		
		public function getItemIndex(data:Object, item:Object) : int {
			this.checkForCorrectDataType(data);
			return (data as Vector.<*>).indexOf(item);
		}
		
		protected function checkForCorrectDataType(data:Object) : void {
			if(!(data is Vector.<*>)) {
				throw new IllegalOperationError("Expected Vector. Received " + Object(data).constructor + " instead.");
			}
		}
	}
}

