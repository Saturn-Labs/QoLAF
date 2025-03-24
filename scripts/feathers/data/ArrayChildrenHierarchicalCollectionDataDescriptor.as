package feathers.data {
	public class ArrayChildrenHierarchicalCollectionDataDescriptor implements IHierarchicalCollectionDataDescriptor {
		public var childrenField:String = "children";
		
		public function ArrayChildrenHierarchicalCollectionDataDescriptor() {
			super();
		}
		
		public function getLength(data:Object, ... rest) : int {
			var _local4:int = 0;
			var _local5:int = 0;
			var _local6:Array = data as Array;
			var _local3:int = int(rest.length);
			_local4 = 0;
			while(_local4 < _local3) {
				_local5 = rest[_local4] as int;
				_local6 = _local6[_local5][childrenField] as Array;
				_local4++;
			}
			return _local6.length;
		}
		
		public function getItemAt(data:Object, index:int, ... rest) : Object {
			var _local5:int = 0;
			rest.insertAt(0,index);
			var _local7:Array = data as Array;
			var _local4:int = rest.length - 1;
			_local5 = 0;
			while(_local5 < _local4) {
				index = rest[_local5] as int;
				_local7 = _local7[index][childrenField] as Array;
				_local5++;
			}
			var _local6:int = rest[_local4] as int;
			return _local7[_local6];
		}
		
		public function setItemAt(data:Object, item:Object, index:int, ... rest) : void {
			var _local6:int = 0;
			rest.insertAt(0,index);
			var _local8:Array = data as Array;
			var _local5:int = rest.length - 1;
			_local6 = 0;
			while(_local6 < _local5) {
				index = rest[_local6] as int;
				_local8 = _local8[index][childrenField] as Array;
				_local6++;
			}
			var _local7:int = int(rest[_local5]);
			_local8[_local7] = item;
		}
		
		public function addItemAt(data:Object, item:Object, index:int, ... rest) : void {
			var _local6:int = 0;
			rest.insertAt(0,index);
			var _local8:Array = data as Array;
			var _local5:int = rest.length - 1;
			_local6 = 0;
			while(_local6 < _local5) {
				index = rest[_local6] as int;
				_local8 = _local8[index][childrenField] as Array;
				_local6++;
			}
			var _local7:int = int(rest[_local5]);
			_local8.insertAt(_local7,item);
		}
		
		public function removeItemAt(data:Object, index:int, ... rest) : Object {
			var _local5:int = 0;
			rest.insertAt(0,index);
			var _local7:Array = data as Array;
			var _local4:int = rest.length - 1;
			_local5 = 0;
			while(_local5 < _local4) {
				index = rest[_local5] as int;
				_local7 = _local7[index][childrenField] as Array;
				_local5++;
			}
			var _local6:int = int(rest[_local4]);
			return _local7.removeAt(_local6);
		}
		
		public function removeAll(data:Object) : void {
			var _local2:Array = data as Array;
			_local2.length = 0;
		}
		
		public function getItemLocation(data:Object, item:Object, result:Vector.<int> = null, ... rest) : Vector.<int> {
			var _local7:int = 0;
			var _local8:int = 0;
			if(!result) {
				result = new Vector.<int>(0);
			} else {
				result.length = 0;
			}
			var _local9:Array = data as Array;
			var _local6:int = int(rest.length);
			_local7 = 0;
			while(_local7 < _local6) {
				_local8 = rest[_local7] as int;
				result[_local7] = _local8;
				_local9 = _local9[_local8][childrenField] as Array;
				_local7++;
			}
			var _local5:Boolean = this.findItemInBranch(_local9,item,result);
			if(!_local5) {
				result.length = 0;
			}
			return result;
		}
		
		public function isBranch(node:Object) : Boolean {
			return node.hasOwnProperty(this.childrenField) && node[this.childrenField] is Array;
		}
		
		protected function findItemInBranch(branch:Array, item:Object, result:Vector.<int>) : Boolean {
			var _local7:int = 0;
			var _local5:Object = null;
			var _local4:Boolean = false;
			var _local6:int = int(branch.indexOf(item));
			if(_local6 >= 0) {
				result.push(_local6);
				return true;
			}
			var _local8:int = int(branch.length);
			_local7 = 0;
			while(_local7 < _local8) {
				_local5 = branch[_local7];
				if(this.isBranch(_local5)) {
					result.push(_local7);
					_local4 = this.findItemInBranch(_local5[childrenField] as Array,item,result);
					if(_local4) {
						return true;
					}
					result.pop();
				}
				_local7++;
			}
			return false;
		}
	}
}

