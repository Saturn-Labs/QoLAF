package feathers.data {
	import flash.errors.IllegalOperationError;
	
	public class VectorNumberListCollectionDataDescriptor implements IListCollectionDataDescriptor {
		public function VectorNumberListCollectionDataDescriptor() {
			super();
		}
		
		public function getLength(data:Object) : int {
			this.checkForCorrectDataType(data);
			return (data as Vector.<Number>).length;
		}
		
		public function getItemAt(data:Object, index:int) : Object {
			this.checkForCorrectDataType(data);
			return (data as Vector.<Number>)[index];
		}
		
		public function setItemAt(data:Object, item:Object, index:int) : void {
			this.checkForCorrectDataType(data);
			(data as Vector.<Number>)[index] = item as Number;
		}
		
		public function addItemAt(data:Object, item:Object, index:int) : void {
			this.checkForCorrectDataType(data);
			(data as Vector.<Number>).insertAt(index,item as Number);
		}
		
		public function removeItemAt(data:Object, index:int) : Object {
			this.checkForCorrectDataType(data);
			return (data as Vector.<Number>).removeAt(index);
		}
		
		public function removeAll(data:Object) : void {
			this.checkForCorrectDataType(data);
			(data as Vector.<Number>).length = 0;
		}
		
		public function getItemIndex(data:Object, item:Object) : int {
			this.checkForCorrectDataType(data);
			return (data as Vector.<Number>).indexOf(item as Number);
		}
		
		protected function checkForCorrectDataType(data:Object) : void {
			if(!(data is Vector.<Number>)) {
				throw new IllegalOperationError("Expected Vector.<Number>. Received " + Object(data).constructor + " instead.");
			}
		}
	}
}

