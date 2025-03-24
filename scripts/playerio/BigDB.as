package playerio {
	import playerio.generated.BigDB;
	import playerio.generated.messages.BigDBChangeset;
	import playerio.generated.messages.BigDBObject;
	import playerio.generated.messages.BigDBObjectId;
	import playerio.generated.messages.NewBigDBObject;
	import playerio.utils.Converter;
	import playerio.utils.HTTPChannel;
	
	public class BigDB extends playerio.generated.BigDB {
		public function BigDB(channel:HTTPChannel, client:Client) {
			super(channel,client);
		}
		
		public function load(table:String, key:String, callback:Function = null, errorHandler:Function = null) : void {
			var db:BigDBObjectId = new BigDBObjectId();
			db.table = table;
			db.keys = [key];
			_loadObjects([db],function(param1:Array):void {
				if(callback != null) {
					callback(Converter.toDatabaseObject(table,param1[0],false,save));
				}
			},errorHandler);
		}
		
		public function loadOrCreate(table:String, key:String, callback:Function = null, errorHandler:Function = null) : void {
			var obj:NewBigDBObject = Converter.toNewBigDBObject(table,key,{});
			_createObjects([obj],true,function(param1:Array):void {
				if(callback != null) {
					callback(Converter.toDatabaseObject(table,param1[0],false,save));
				}
			},errorHandler);
		}
		
		public function loadKeys(table:String, keys:Array, callback:Function = null, errorHandler:Function = null) : void {
			var db:BigDBObjectId = new BigDBObjectId();
			db.table = table;
			db.keys = keys;
			_loadObjects([db],function(param1:Array):void {
				if(callback != null) {
					callback(toDatabaseObjectArray(table,param1));
				}
			},errorHandler);
		}
		
		public function loadKeysOrCreate(table:String, keys:Array, callback:Function = null, errorHandler:Function = null) : void {
			var objs:Array = [];
			var a:int = 0;
			while(a < keys.length) {
				objs.push(Converter.toNewBigDBObject(table,keys[a],{}));
				a++;
			}
			_createObjects(objs,true,function(param1:Array):void {
				if(callback != null) {
					callback(toDatabaseObjectArray(table,param1));
				}
			},errorHandler);
		}
		
		public function createObject(table:String, key:String, data:Object, callback:Function = null, errorHandler:Function = null) : void {
			var obj:NewBigDBObject = Converter.toNewBigDBObject(table,key,data);
			_createObjects([obj],false,function(param1:Array):void {
				param1[0].properties = obj.properties;
				if(callback != null) {
					callback(Converter.toDatabaseObject(table,param1[0],false,save));
				}
			},errorHandler);
		}
		
		public function loadMyPlayerObject(callback:Function = null, errorHandler:Function = null) : void {
			_loadMyPlayerObject(function(param1:BigDBObject):void {
				if(callback != null) {
					callback(Converter.toDatabaseObject("PlayerObjects",param1,true,save));
				}
			},errorHandler);
		}
		
		public function loadSingle(table:String, index:String, indexValue:Array, callback:Function = null, errorHandler:Function = null) : void {
			_loadMatchingObjects(table,index,Converter.toValueObjectArray(indexValue),1,function(param1:Array):void {
				if(callback != null) {
					callback(Converter.toDatabaseObject(table,param1[0],false,save));
				}
			},errorHandler);
		}
		
		public function loadRange(table:String, index:String, path:Array, start:Object, stop:Object, limit:int, callback:Function = null, errorHandler:Function = null) : void {
			var startIndexValue:Array = start != null ? [start] : [];
			var stopIndexValue:Array = stop != null ? [stop] : [];
			if(path != null) {
				startIndexValue = path.concat(startIndexValue);
				stopIndexValue = path.concat(stopIndexValue);
			}
			_loadIndexRange(table,index,Converter.toValueObjectArray(startIndexValue),Converter.toValueObjectArray(stopIndexValue),limit,function(param1:Array):void {
				if(callback != null) {
					callback(toDatabaseObjectArray(table,param1));
				}
			},errorHandler);
		}
		
		public function deleteRange(table:String, index:String, path:Array, start:Object, stop:Object, callback:Function = null, errorHandler:Function = null) : void {
			var _local9:Array = start != null ? [start] : [];
			var _local8:Array = stop != null ? [stop] : [];
			if(path != null) {
				_local9 = path.concat(_local9);
				_local8 = path.concat(_local8);
			}
			_deleteIndexRange(table,index,Converter.toValueObjectArray(_local9),Converter.toValueObjectArray(_local8),callback,errorHandler);
		}
		
		public function deleteKeys(table:String, keys:Array, callback:Function = null, errorHandler:Function = null) : void {
			var _local5:BigDBObjectId = new BigDBObjectId();
			_local5.table = table;
			_local5.keys = keys;
			_deleteObjects([_local5],callback,errorHandler);
		}
		
		private function save(table:String, key:String, version:String, changeset:Object, useOptimisticLocks:Boolean, createIfMissing:Boolean = false, callback:Function = null, errorHandler:Function = null) : void {
			var obj:NewBigDBObject;
			var cs:BigDBChangeset = new BigDBChangeset();
			cs.table = table;
			cs.key = key;
			if(useOptimisticLocks) {
				cs.onlyIfVersion = version;
			}
			obj = Converter.toNewBigDBObject(table,key,changeset);
			cs.changes = obj.properties;
			_saveObjectChanges(2,[cs],createIfMissing,function(param1:Array):void {
				callback(param1[0]);
			},errorHandler);
		}
		
		private function toDatabaseObjectArray(table:String, arr:Array) : Array {
			var _local4:int = 0;
			var _local3:Array = [];
			_local4 = 0;
			while(_local4 < arr.length) {
				_local3.push(Converter.toDatabaseObject(table,arr[_local4],false,save));
				_local4++;
			}
			return _local3;
		}
	}
}

