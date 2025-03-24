package feathers.data {
	import flash.errors.IllegalOperationError;
	
	public class XMLListListCollectionDataDescriptor implements IListCollectionDataDescriptor {
		public function XMLListListCollectionDataDescriptor() {
			super();
		}
		
		public function getLength(data:Object) : int {
			this.checkForCorrectDataType(data);
			return (data as XMLList).length();
		}
		
		public function getItemAt(data:Object, index:int) : Object {
			this.checkForCorrectDataType(data);
			return data[index];
		}
		
		public function setItemAt(data:Object, item:Object, index:int) : void {
			this.checkForCorrectDataType(data);
			data[index] = XML(item);
		}
		
		public function addItemAt(data:Object, item:Object, index:int) : void {
			var _local4:* = 0;
			this.checkForCorrectDataType(data);
			var _local5:XMLList = (data as XMLList).copy();
			data[index] = item;
			var _local6:int = int(_local5.length());
			_local4 = index;
			while(_local4 < _local6) {
				data[_local4 + 1] = _local5[_local4];
				_local4++;
			}
		}
		
		public function removeItemAt(data:Object, index:int) : Object {
			this.checkForCorrectDataType(data);
			var _local3:XML = data[index];
			delete data[index];
			return _local3;
		}
		
		public function removeAll(data:Object) : void {
			var _local2:int = 0;
			this.checkForCorrectDataType(data);
			var _local3:XMLList = data as XMLList;
			var _local4:int = int(_local3.length());
			_local2 = 0;
			while(_local2 < _local4) {
				delete data[0];
				_local2++;
			}
		}
		
		public function getItemIndex(data:Object, item:Object) : int {
			var _local3:int = 0;
			var _local5:XML = null;
			this.checkForCorrectDataType(data);
			var _local4:XMLList = data as XMLList;
			var _local6:int = int(_local4.length());
			_local3 = 0;
			while(_local3 < _local6) {
				_local5 = _local4[_local3];
				if(_local5 == item) {
					return _local3;
				}
				_local3++;
			}
			return -1;
		}
		
		protected function checkForCorrectDataType(data:Object) : void {
			if(!(data is XMLList)) {
				throw new IllegalOperationError("Expected XMLList. Received " + Object(data).constructor + " instead.");
			}
		}
	}
}

