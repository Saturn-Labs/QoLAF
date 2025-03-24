package feathers.data {
	import flash.errors.IllegalOperationError;
	
	public class VectorUintListCollectionDataDescriptor implements IListCollectionDataDescriptor {
		public function VectorUintListCollectionDataDescriptor() {
			super();
		}
		
		public function getLength(data:Object) : int {
			this.checkForCorrectDataType(data);
			return (data as Vector.<uint>).length;
		}
		
		public function getItemAt(data:Object, index:int) : Object {
			this.checkForCorrectDataType(data);
			return (data as Vector.<uint>)[index];
		}
		
		public function setItemAt(data:Object, item:Object, index:int) : void {
			this.checkForCorrectDataType(data);
			(data as Vector.<uint>)[index] = item as uint;
		}
		
		public function addItemAt(data:Object, item:Object, index:int) : void {
			this.checkForCorrectDataType(data);
			(data as Vector.<uint>).insertAt(index,item as uint);
		}
		
		public function removeItemAt(data:Object, index:int) : Object {
			this.checkForCorrectDataType(data);
			return (data as Vector.<uint>).removeAt(index);
		}
		
		public function removeAll(data:Object) : void {
			this.checkForCorrectDataType(data);
			(data as Vector.<uint>).length = 0;
		}
		
		public function getItemIndex(data:Object, item:Object) : int {
			this.checkForCorrectDataType(data);
			return (data as Vector.<uint>).indexOf(item as uint);
		}
		
		protected function checkForCorrectDataType(data:Object) : void {
			if(!(data is Vector.<uint>)) {
				throw new IllegalOperationError("Expected Vector.<uint>. Received " + Object(data).constructor + " instead.");
			}
		}
	}
}

