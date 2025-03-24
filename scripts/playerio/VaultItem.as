package playerio {
	public dynamic class VaultItem {
		private var _id:String;
		
		private var _itemKey:String;
		
		private var _purchaseDate:Date;
		
		private var prefix:String = "    ";
		
		public function VaultItem(id:String, itemKey:String, purchaseDate:Date) {
			super();
			this._id = id;
			this._itemKey = itemKey;
			this._purchaseDate = purchaseDate;
		}
		
		public function get id() : String {
			return _id;
		}
		
		public function get itemKey() : String {
			return _itemKey;
		}
		
		public function get purchaseDate() : Date {
			return _purchaseDate;
		}
		
		public function toString() : String {
			var _local1:String = "[playerio.VaultItem]";
			return _local1 + ("[itemKey=\"" + _itemKey + "\", id=\"" + _id + "\", purchaseDate=" + _purchaseDate + "] = " + serialize(prefix,this));
		}
		
		private function serialize(pf:String, value:*) : String {
			var _local4:int = 0;
			var _local3:String = "";
			var _local6:String = "";
			var _local5:Array = [];
			if(value is String) {
				return "\"" + value + "\"";
			}
			if(value is Array) {
				_local3 = "[\n";
				for(_local6 in value) {
					if(value[_local6] !== undefined) {
						_local5.push({
							"id":_local6,
							"value":serialize(pf + prefix,value[_local6])
						});
					}
				}
				_local5.sortOn("id",16);
				_local4 = 0;
				while(_local4 < _local5.length) {
					_local3 += pf + _local5[_local4].id + ":" + _local5[_local4].value + "\n";
					_local4++;
				}
				return _local3 + (pf.substring(4) + "]");
			}
			if(value is Object) {
				if(value.constructor == Object || value.constructor == VaultItem) {
					_local3 = "{\n";
					for(_local6 in value) {
						if(value[_local6] !== undefined) {
							_local5.push({
								"id":_local6,
								"value":serialize(pf + prefix,value[_local6])
							});
						}
					}
					_local5.sortOn("id");
					_local4 = 0;
					while(_local4 < _local5.length) {
						_local3 += pf + _local5[_local4].id + ":" + _local5[_local4].value + "\n";
						_local4++;
					}
					return _local3 + (pf.substring(4) + "}");
				}
			}
			if(value == null) {
				return value;
			}
			return value.toString();
		}
	}
}

