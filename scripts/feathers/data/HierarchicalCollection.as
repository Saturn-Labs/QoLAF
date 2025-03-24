package feathers.data {
	import starling.events.EventDispatcher;
	
	public class HierarchicalCollection extends EventDispatcher {
		protected var _data:Object;
		
		protected var _dataDescriptor:IHierarchicalCollectionDataDescriptor = new ArrayChildrenHierarchicalCollectionDataDescriptor();
		
		public function HierarchicalCollection(data:Object = null) {
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
			this.dispatchEventWith("reset");
			this.dispatchEventWith("change");
		}
		
		public function get dataDescriptor() : IHierarchicalCollectionDataDescriptor {
			return this._dataDescriptor;
		}
		
		public function set dataDescriptor(value:IHierarchicalCollectionDataDescriptor) : void {
			if(this._dataDescriptor == value) {
				return;
			}
			this._dataDescriptor = value;
			this.dispatchEventWith("reset");
			this.dispatchEventWith("change");
		}
		
		public function isBranch(node:Object) : Boolean {
			return this._dataDescriptor.isBranch(node);
		}
		
		public function getLength(... rest) : int {
			rest.insertAt(0,this._data);
			return this._dataDescriptor.getLength.apply(null,rest);
		}
		
		public function updateItemAt(index:int, ... rest) : void {
			rest.insertAt(0,index);
			this.dispatchEventWith("updateItem",false,rest);
		}
		
		public function updateAll() : void {
			this.dispatchEventWith("updateAll");
		}
		
		public function getItemAt(index:int, ... rest) : Object {
			rest.insertAt(0,index);
			rest.insertAt(0,this._data);
			return this._dataDescriptor.getItemAt.apply(null,rest);
		}
		
		public function getItemLocation(item:Object, result:Vector.<int> = null) : Vector.<int> {
			return this._dataDescriptor.getItemLocation(this._data,item,result);
		}
		
		public function addItemAt(item:Object, index:int, ... rest) : void {
			rest.insertAt(0,index);
			rest.insertAt(0,item);
			rest.insertAt(0,this._data);
			this._dataDescriptor.addItemAt.apply(null,rest);
			this.dispatchEventWith("change");
			rest.shift();
			rest.shift();
			this.dispatchEventWith("addItem",false,rest);
		}
		
		public function removeItemAt(index:int, ... rest) : Object {
			rest.insertAt(0,index);
			rest.insertAt(0,this._data);
			var _local3:Object = this._dataDescriptor.removeItemAt.apply(null,rest);
			this.dispatchEventWith("change");
			rest.shift();
			this.dispatchEventWith("removeItem",false,rest);
			return _local3;
		}
		
		public function removeItem(item:Object) : void {
			var _local2:Array = null;
			var _local3:int = 0;
			var _local4:int = 0;
			var _local5:Vector.<int> = this.getItemLocation(item);
			if(_local5) {
				_local2 = [];
				_local3 = int(_local5.length);
				_local4 = 0;
				while(_local4 < _local3) {
					_local2.push(_local5[_local4]);
					_local4++;
				}
				this.removeItemAt.apply(this,_local2);
			}
		}
		
		public function removeAll() : void {
			if(this.getLength() == 0) {
				return;
			}
			this._dataDescriptor.removeAll(this._data);
			this.dispatchEventWith("change");
			this.dispatchEventWith("reset",false);
		}
		
		public function setItemAt(item:Object, index:int, ... rest) : void {
			rest.insertAt(0,index);
			rest.insertAt(0,item);
			rest.insertAt(0,this._data);
			this._dataDescriptor.setItemAt.apply(null,rest);
			rest.shift();
			rest.shift();
			this.dispatchEventWith("replaceItem",false,rest);
			this.dispatchEventWith("change");
		}
		
		public function dispose(disposeGroup:Function, disposeItem:Function) : void {
			var _local5:int = 0;
			var _local6:Object = null;
			var _local4:int = this.getLength();
			var _local3:Array = [];
			_local5 = 0;
			while(_local5 < _local4) {
				_local6 = this.getItemAt(_local5);
				_local3[0] = _local5;
				this.disposeGroupInternal(_local6,_local3,disposeGroup,disposeItem);
				_local3.length = 0;
				_local5++;
			}
		}
		
		protected function disposeGroupInternal(group:Object, path:Array, disposeGroup:Function, disposeItem:Function) : void {
			var _local6:int = 0;
			var _local5:Object = null;
			if(disposeGroup != null) {
				disposeGroup(group);
			}
			var _local7:int = int(this.getLength.apply(this,path));
			_local6 = 0;
			while(_local6 < _local7) {
				path[path.length] = _local6;
				_local5 = this.getItemAt.apply(this,path);
				if(this.isBranch(_local5)) {
					this.disposeGroupInternal(_local5,path,disposeGroup,disposeItem);
				} else if(disposeItem != null) {
					disposeItem(_local5);
				}
				path.length--;
				_local6++;
			}
		}
	}
}

