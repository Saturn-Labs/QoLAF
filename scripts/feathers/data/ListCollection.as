package feathers.data {
	import starling.events.EventDispatcher;
	
	public class ListCollection extends EventDispatcher {
		protected var _data:Object;
		
		protected var _dataDescriptor:IListCollectionDataDescriptor;
		
		public function ListCollection(data:Object = null) {
			super();
			if(!data) {
				data = [];
			}
			this.data = data;
		}
		
		public function get data() : Object {
			return _data;
		}
		
		public function set data(value:Object) : void {
			if(this._data == value) {
				return;
			}
			this._data = value;
			if(this._data is Array && !(this._dataDescriptor is ArrayListCollectionDataDescriptor)) {
				this._dataDescriptor = new ArrayListCollectionDataDescriptor();
			} else if(this._data is Vector.<Number> && !(this._dataDescriptor is VectorNumberListCollectionDataDescriptor)) {
				this._dataDescriptor = new VectorNumberListCollectionDataDescriptor();
			} else if(this._data is Vector.<int> && !(this._dataDescriptor is VectorIntListCollectionDataDescriptor)) {
				this._dataDescriptor = new VectorIntListCollectionDataDescriptor();
			} else if(this._data is Vector.<uint> && !(this._dataDescriptor is VectorUintListCollectionDataDescriptor)) {
				this._dataDescriptor = new VectorUintListCollectionDataDescriptor();
			} else if(this._data is Vector.<*> && !(this._dataDescriptor is VectorListCollectionDataDescriptor)) {
				this._dataDescriptor = new VectorListCollectionDataDescriptor();
			} else if(this._data is XMLList && !(this._dataDescriptor is XMLListListCollectionDataDescriptor)) {
				this._dataDescriptor = new XMLListListCollectionDataDescriptor();
			}
			if(this._data === null) {
				this._dataDescriptor = null;
			}
			this.dispatchEventWith("reset");
			this.dispatchEventWith("change");
		}
		
		public function get dataDescriptor() : IListCollectionDataDescriptor {
			return this._dataDescriptor;
		}
		
		public function set dataDescriptor(value:IListCollectionDataDescriptor) : void {
			if(this._dataDescriptor == value) {
				return;
			}
			this._dataDescriptor = value;
			this.dispatchEventWith("reset");
			this.dispatchEventWith("change");
		}
		
		public function get length() : int {
			if(!this._dataDescriptor) {
				return 0;
			}
			return this._dataDescriptor.getLength(this._data);
		}
		
		public function updateItemAt(index:int) : void {
			this.dispatchEventWith("updateItem",false,index);
		}
		
		public function updateAll() : void {
			this.dispatchEventWith("updateAll");
		}
		
		public function getItemAt(index:int) : Object {
			return this._dataDescriptor.getItemAt(this._data,index);
		}
		
		public function getItemIndex(item:Object) : int {
			return this._dataDescriptor.getItemIndex(this._data,item);
		}
		
		public function addItemAt(item:Object, index:int) : void {
			this._dataDescriptor.addItemAt(this._data,item,index);
			this.dispatchEventWith("change");
			this.dispatchEventWith("addItem",false,index);
		}
		
		public function removeItemAt(index:int) : Object {
			var _local2:Object = this._dataDescriptor.removeItemAt(this._data,index);
			this.dispatchEventWith("change");
			this.dispatchEventWith("removeItem",false,index);
			return _local2;
		}
		
		public function removeItem(item:Object) : void {
			var _local2:int = this.getItemIndex(item);
			if(_local2 >= 0) {
				this.removeItemAt(_local2);
			}
		}
		
		public function removeAll() : void {
			if(this.length == 0) {
				return;
			}
			this._dataDescriptor.removeAll(this._data);
			this.dispatchEventWith("change");
			this.dispatchEventWith("reset",false);
		}
		
		public function setItemAt(item:Object, index:int) : void {
			this._dataDescriptor.setItemAt(this._data,item,index);
			this.dispatchEventWith("change");
			this.dispatchEventWith("replaceItem",false,index);
		}
		
		public function addItem(item:Object) : void {
			this.addItemAt(item,this.length);
		}
		
		public function push(item:Object) : void {
			this.addItemAt(item,this.length);
		}
		
		public function addAll(collection:ListCollection) : void {
			var _local4:int = 0;
			var _local2:Object = null;
			var _local3:int = collection.length;
			_local4 = 0;
			while(_local4 < _local3) {
				_local2 = collection.getItemAt(_local4);
				this.addItem(_local2);
				_local4++;
			}
		}
		
		public function addAllAt(collection:ListCollection, index:int) : void {
			var _local5:int = 0;
			var _local3:Object = null;
			var _local4:int = collection.length;
			var _local6:* = index;
			_local5 = 0;
			while(_local5 < _local4) {
				_local3 = collection.getItemAt(_local5);
				this.addItemAt(_local3,_local6);
				_local6++;
				_local5++;
			}
		}
		
		public function pop() : Object {
			return this.removeItemAt(this.length - 1);
		}
		
		public function unshift(item:Object) : void {
			this.addItemAt(item,0);
		}
		
		public function shift() : Object {
			return this.removeItemAt(0);
		}
		
		public function contains(item:Object) : Boolean {
			return this.getItemIndex(item) >= 0;
		}
		
		public function dispose(disposeItem:Function) : void {
			var _local3:int = 0;
			var _local2:Object = null;
			var _local4:int = this.length;
			_local3 = 0;
			while(_local3 < _local4) {
				_local2 = this.getItemAt(_local3);
				disposeItem(_local2);
				_local3++;
			}
		}
	}
}

