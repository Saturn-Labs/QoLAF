package feathers.core {
	import flash.errors.IllegalOperationError;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	public class ToggleGroup extends EventDispatcher {
		protected var _items:Vector.<IToggle> = new Vector.<IToggle>();
		
		protected var _ignoreChanges:Boolean = false;
		
		protected var _isSelectionRequired:Boolean = true;
		
		protected var _selectedIndex:int = -1;
		
		public function ToggleGroup() {
			super();
		}
		
		public function get isSelectionRequired() : Boolean {
			return this._isSelectionRequired;
		}
		
		public function set isSelectionRequired(value:Boolean) : void {
			if(this._isSelectionRequired == value) {
				return;
			}
			this._isSelectionRequired = value;
			if(this._isSelectionRequired && this._selectedIndex < 0 && this._items.length > 0) {
				this.selectedIndex = 0;
			}
		}
		
		public function get selectedItem() : IToggle {
			if(this._selectedIndex < 0) {
				return null;
			}
			return this._items[this._selectedIndex];
		}
		
		public function set selectedItem(value:IToggle) : void {
			this.selectedIndex = this._items.indexOf(value);
		}
		
		public function get selectedIndex() : int {
			return this._selectedIndex;
		}
		
		public function set selectedIndex(value:int) : void {
			var _local4:int = 0;
			var _local2:IToggle = null;
			var _local5:int = int(this._items.length);
			if(value < -1 || value >= _local5) {
				throw new RangeError("Index " + value + " is out of range " + _local5 + " for ToggleGroup.");
			}
			var _local3:* = this._selectedIndex != value;
			this._selectedIndex = value;
			this._ignoreChanges = true;
			_local4 = 0;
			while(_local4 < _local5) {
				_local2 = this._items[_local4];
				_local2.isSelected = _local4 == value;
				_local4++;
			}
			this._ignoreChanges = false;
			if(_local3) {
				this.dispatchEventWith("change");
			}
		}
		
		public function addItem(item:IToggle) : void {
			if(!item) {
				throw new ArgumentError("IToggle passed to ToggleGroup addItem() must not be null.");
			}
			var _local2:int = int(this._items.indexOf(item));
			if(_local2 >= 0) {
				throw new IllegalOperationError("Cannot add an item to a ToggleGroup more than once.");
			}
			this._items.push(item);
			if(this._selectedIndex < 0 && this._isSelectionRequired) {
				this.selectedItem = item;
			} else {
				item.isSelected = false;
			}
			item.addEventListener("change",item_changeHandler);
			if(item is IGroupedToggle) {
				IGroupedToggle(item).toggleGroup = this;
			}
		}
		
		public function removeItem(item:IToggle) : void {
			var _local3:int = 0;
			var _local2:int = int(this._items.indexOf(item));
			if(_local2 < 0) {
				return;
			}
			this._items.removeAt(_local2);
			item.removeEventListener("change",item_changeHandler);
			if(item is IGroupedToggle) {
				IGroupedToggle(item).toggleGroup = null;
			}
			if(this._selectedIndex > _local2) {
				this.selectedIndex -= 1;
			} else if(this._selectedIndex == _local2) {
				if(this._isSelectionRequired) {
					_local3 = this._items.length - 1;
					if(this._selectedIndex > _local3) {
						this.selectedIndex = _local3;
					} else {
						this.dispatchEventWith("change");
					}
				} else {
					this.selectedIndex = -1;
				}
			}
		}
		
		public function removeAllItems() : void {
			var _local2:int = 0;
			var _local1:IToggle = null;
			var _local3:int = int(this._items.length);
			_local2 = 0;
			while(_local2 < _local3) {
				_local1 = this._items.shift();
				_local1.removeEventListener("change",item_changeHandler);
				if(_local1 is IGroupedToggle) {
					IGroupedToggle(_local1).toggleGroup = null;
				}
				_local2++;
			}
			this.selectedIndex = -1;
		}
		
		public function hasItem(item:IToggle) : Boolean {
			var _local2:int = int(this._items.indexOf(item));
			return _local2 >= 0;
		}
		
		public function getItemIndex(item:IToggle) : int {
			return this._items.indexOf(item);
		}
		
		public function setItemIndex(item:IToggle, index:int) : void {
			var _local3:int = int(this._items.indexOf(item));
			if(_local3 < 0) {
				throw new ArgumentError("Attempting to set index of an item that has not been added to this ToggleGroup.");
			}
			if(_local3 === index) {
				return;
			}
			this._items.removeAt(_local3);
			this._items.insertAt(index,item);
			if(this._selectedIndex >= 0) {
				if(this._selectedIndex == _local3) {
					this.selectedIndex = index;
				} else if(_local3 < this._selectedIndex && index > this._selectedIndex) {
					this.selectedIndex--;
				} else if(_local3 > this._selectedIndex && index < this._selectedIndex) {
					this.selectedIndex++;
				}
			}
		}
		
		protected function item_changeHandler(event:Event) : void {
			if(this._ignoreChanges) {
				return;
			}
			var _local2:IToggle = IToggle(event.currentTarget);
			var _local3:int = int(this._items.indexOf(_local2));
			if(_local2.isSelected || this._isSelectionRequired && this._selectedIndex == _local3) {
				this.selectedIndex = _local3;
			} else if(!_local2.isSelected) {
				this.selectedIndex = -1;
			}
		}
	}
}

