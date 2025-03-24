package playerio.utils {
	import flash.utils.ByteArray;
	import playerio.DatabaseObject;
	import playerio.PayVaultHistoryEntry;
	import playerio.RoomInfo;
	import playerio.VaultItem;
	import playerio.generated.PlayerIOError;
	import playerio.generated.messages.*;
	import playerio.helpers.FieldToBeRemoved;
	
	public class Converter {
		public function Converter() {
			super();
		}
		
		public static function toVaultItemArray(input:Array) : Array {
			var _local6:int = 0;
			var _local8:PayVaultItem = null;
			var _local3:Date = null;
			var _local4:VaultItem = null;
			var _local5:int = 0;
			var _local7:ObjectProperty = null;
			var _local2:Array = [];
			_local6 = 0;
			while(_local6 < input.length) {
				_local8 = input[_local6] as PayVaultItem;
				_local3 = new Date();
				_local3.setTime(_local8.purchaseDate);
				_local4 = new VaultItem(_local8.id,_local8.itemKey,_local3);
				_local5 = 0;
				while(_local5 < _local8.properties.length) {
					_local7 = _local8.properties[_local5];
					_local4[_local7.name] = deserializeValueObject(_local7.value);
					_local5++;
				}
				_local2.push(_local4);
				_local6++;
			}
			return _local2;
		}
		
		public static function toPayVaultHistoryEntryArray(input:Array) : Array {
			var _local4:int = 0;
			var _local5:playerio.generated.messages.PayVaultHistoryEntry = null;
			var _local3:Date = null;
			var _local2:Array = [];
			_local4 = 0;
			while(_local4 < input.length) {
				_local5 = input[_local4] as playerio.generated.messages.PayVaultHistoryEntry;
				_local3 = new Date();
				_local3.setTime(_local5.timestamp);
				_local2.push(new playerio.PayVaultHistoryEntry(_local5.amount,_local5.type,_local3,_local5.itemKeys,_local5.reason,_local5.providerTransactionId,_local5.providerPrice));
				_local4++;
			}
			return _local2;
		}
		
		public static function toBuyItemInfoArray(input:Array) : Array {
			var _local2:int = 0;
			var _local3:Object = null;
			var _local4:PayVaultBuyItemInfo = null;
			var _local5:Array = [];
			_local2 = 0;
			while(_local2 < input.length) {
				_local3 = input[_local2];
				if(!(_local3.itemKey is String)) {
					throw new PlayerIOError("itemKey not defined on parsed item",2);
				}
				_local4 = new PayVaultBuyItemInfo();
				_local4.itemKey = _local3.itemKey;
				_local4.payload = getObjectProperties(_local3,false,"itemKey");
				_local5.push(_local4);
				_local2++;
			}
			return _local5;
		}
		
		public static function toKeyValueArray(input:Object) : Array {
			var _local3:KeyValuePair = null;
			var _local2:Array = [];
			for(var _local4 in input) {
				_local3 = new KeyValuePair();
				_local3.key = _local4;
				if(input[_local4] == undefined) {
					_local3.value = undefined;
				} else {
					_local3.value = input[_local4].toString();
				}
				_local2.push(_local3);
			}
			return _local2;
		}
		
		public static function toKeyValueObject(input:Array) : Object {
			var _local3:int = 0;
			var _local4:KeyValuePair = null;
			var _local2:Object = {};
			_local3 = 0;
			while(_local3 < input.length) {
				_local4 = input[_local3] as KeyValuePair;
				_local2[_local4.key] = _local4.value;
				_local3++;
			}
			return _local2;
		}
		
		public static function toRoomInfoArray(input:Array) : Array {
			var _local3:int = 0;
			var _local4:playerio.generated.messages.RoomInfo = null;
			var _local5:playerio.RoomInfo = null;
			var _local2:Array = [];
			_local3 = 0;
			while(_local3 < input.length) {
				_local4 = input[_local3] as playerio.generated.messages.RoomInfo;
				_local5 = new playerio.RoomInfo(_local4.id,_local4.roomType,_local4.onlineUsers,Converter.toKeyValueObject(_local4.roomData));
				_local2.push(_local5);
				_local3++;
			}
			return _local2;
		}
		
		public static function toDatabaseObject(table:String, obj:BigDBObject, isPlayerObject:Boolean, save:Function) : DatabaseObject {
			if(obj == null) {
				return null;
			}
			var _local5:DatabaseObject = new DatabaseObject(table,obj.key,obj.version,obj.creator,isPlayerObject,save);
			for each(var _local6 in obj.properties) {
				_local5[_local6.name] = deserializeValueObject(_local6.value);
			}
			if(save != null) {
				_local5.commit();
			}
			return _local5;
		}
		
		public static function toSparseBigDBObject(key:String, version:String, creator:int, data:Object) : BigDBObject {
			var _local6:ObjectProperty = null;
			var _local5:BigDBObject = new BigDBObject();
			_local5.key = key;
			_local5.version = version;
			_local5.creator = creator;
			data ||= {};
			for(var _local7 in data) {
				if(data[_local7] !== undefined) {
					_local6 = new ObjectProperty();
					_local6.name = _local7;
					_local6.value = getValueObject(data[_local7],true);
					_local5.properties.push(_local6);
				}
			}
			return _local5;
		}
		
		public static function toBigDBObject(key:String, version:String, creator:int, data:Object) : BigDBObject {
			var _local6:ObjectProperty = null;
			var _local5:BigDBObject = new BigDBObject();
			_local5.key = key;
			_local5.version = version;
			_local5.creator = creator;
			data ||= {};
			for(var _local7 in data) {
				_local6 = new ObjectProperty();
				_local6.name = _local7;
				_local6.value = getValueObject(data[_local7]);
				_local5.properties.push(_local6);
			}
			return _local5;
		}
		
		public static function toNewBigDBObject(table:String, key:String, data:Object) : NewBigDBObject {
			var _local5:ObjectProperty = null;
			var _local4:NewBigDBObject = new NewBigDBObject();
			_local4.table = table;
			_local4.key = key;
			data ||= {};
			for(var _local6 in data) {
				_local5 = new ObjectProperty();
				_local5.name = _local6;
				_local5.value = getValueObject(data[_local6],true);
				_local4.properties.push(_local5);
			}
			return _local4;
		}
		
		public static function toValueObjectArray(arr:Array) : Array {
			var _local3:int = 0;
			var _local2:Array = [];
			_local3 = 0;
			while(_local3 < arr.length) {
				_local2.push(getValueObject(arr[_local3]));
				_local3++;
			}
			return _local2;
		}
		
		private static function getValueObject(o:*, sparse:Boolean = false) : ValueObject {
			var _local4:ByteArray = null;
			var _local3:ByteArray = null;
			var _local5:ValueObject = new ValueObject();
			if(o is FieldToBeRemoved) {
				return null;
			}
			if(o === undefined) {
				return null;
			}
			if(o === null) {
				_local5.valueType = 0;
				_local5.string = null;
			} else if(o is Date) {
				_local5.valueType = 8;
				_local5.dateTime = (o as Date).getTime();
			} else if(o is Array) {
				_local5.valueType = 9;
				_local5.arrayProperties = getArrayProperties(o,sparse);
			} else if(o is String) {
				_local5.valueType = 0;
				_local5.string = o;
			} else if(o is Boolean) {
				_local5.valueType = 4;
				_local5.bool = o;
			} else if(o is ByteArray) {
				_local5.valueType = 7;
				_local5.byteArray = o;
			} else if(o is Number) {
				_local4 = new ByteArray();
				_local4.writeInt(o);
				_local4.position = 0;
				_local3 = new ByteArray();
				_local3.writeUnsignedInt(o);
				_local3.position = 0;
				if(_local4.readInt() == o) {
					_local5.valueType = 1;
					_local5.int32 = o;
				} else if(_local3.readUnsignedInt() == o) {
					_local5.valueType = 2;
					_local5.uInt = o;
				} else if(Math.floor(o) == o && o <= 9223372036854774800 && o >= -9223372036854774800) {
					_local5.valueType = 3;
					_local5.long = o;
				} else {
					_local4 = new ByteArray();
					_local4.writeFloat(o);
					_local4.position = 0;
					if(_local4.readFloat() == o) {
						_local5.valueType = 5;
						_local5.float = o;
					} else {
						_local5.valueType = 6;
						_local5.double = o;
					}
				}
			} else if(o.constructor == Object) {
				_local5.valueType = 10;
				_local5.objectProperties = getObjectProperties(o,sparse);
			}
			return _local5;
		}
		
		private static function getArrayProperties(arr:Array, sparse:Boolean = false) : Array {
			var _local5:int = 0;
			var _local4:ArrayProperty = null;
			var _local3:Array = [];
			_local5 = 0;
			while(_local5 < arr.length) {
				if(!(arr[_local5] === undefined && sparse)) {
					_local4 = new ArrayProperty();
					_local4.index = _local5;
					_local4.value = getValueObject(arr[_local5],sparse);
					_local3.push(_local4);
				}
				_local5++;
			}
			return _local3;
		}
		
		public static function getObjectProperties(obj:Object, sparse:Boolean = false, ignore:String = null) : Array {
			var _local5:ObjectProperty = null;
			var _local4:Array = [];
			for(var _local6 in obj) {
				if(!(obj[_local6] === undefined && sparse || _local6 == ignore)) {
					_local5 = new ObjectProperty();
					_local5.name = _local6;
					_local5.value = getValueObject(obj[_local6],sparse);
					_local4.push(_local5);
				}
			}
			return _local4;
		}
		
		private static function deserializeValueObject(v:ValueObject) : * {
			var _local2:Date = null;
			switch(v.valueType) {
				case 0:
					return v.string;
				case 1:
					return v.int32 || 0;
				case 2:
					return v.uInt || 0;
				case 3:
					return v.long || 0;
				case 4:
					return v.bool;
				case 5:
					return v.float || 0;
				case 6:
					return v.double || 0;
				case 7:
					return v.byteArray;
				case 8:
					_local2 = new Date();
					_local2.setTime(v.dateTime);
					return _local2;
				case 9:
					return getArray(v.arrayProperties);
				case 10:
					return getObject(v.objectProperties);
				default:
					throw new Error("Unknown valuetype in returned BigDBObject",0);
			}
		}
		
		private static function getArray(arr:Array) : Array {
			var _local4:int = 0;
			var _local3:ArrayProperty = null;
			var _local2:Array = [];
			_local4 = 0;
			while(_local4 < arr.length) {
				_local3 = arr[_local4] as ArrayProperty;
				if(_local3.value != null) {
					_local2[_local3.index] = deserializeValueObject(_local3.value);
				}
				_local4++;
			}
			return _local2;
		}
		
		private static function getObject(arr:Array) : Object {
			var _local4:int = 0;
			var _local3:ObjectProperty = null;
			var _local2:Object = {};
			_local4 = 0;
			while(_local4 < arr.length) {
				_local3 = arr[_local4] as ObjectProperty;
				if(_local3.value != null) {
					_local2[_local3.name] = deserializeValueObject(_local3.value);
				}
				_local4++;
			}
			return _local2;
		}
	}
}

