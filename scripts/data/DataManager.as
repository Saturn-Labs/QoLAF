package data {
	import com.adobe.serialization.json.JSONDecoder;
	import core.artifact.Artifact;
	import debug.Console;
	import flash.utils.ByteArray;
	import playerio.*;
	import starling.display.Sprite;
	
	public class DataManager extends Sprite implements IDataManager {
		private var CacheFile:Class = cache_json$f0170aad834e758c8de1f3455e70ad5c919569007;
		
		private var _client:Client;
		
		private var json:Object;
		
		public var _artifacts:Vector.<Artifact> = new Vector.<Artifact>();
		
		public function DataManager(client:Client) {
			super();
			this._client = client;
		}
		
		public function getArtifacts() : Vector.<Artifact> {
			return _artifacts;
		}
		
		public function setClient(value:Client) : void {
			_client = value;
		}
		
		public function loadKeyFromBigDB(table:String, key:String, callback:Function) : void {
			if(table == null || key == null || table.length == 0 || key.length == 0) {
				Console.write("BigDB: key or table is empty or null, key:" + key + " table:" + table);
				return;
			}
			loadFromBigDB(table,key,callback);
		}
		
		private function loadFromBigDB(table:String, key:String, callback:Function) : void {
			_client.bigDB.load(table,key,function(param1:DatabaseObject):void {
				try {
					callback(param1);
				}
				catch(e:Error) {
					_client.errorLog.writeError(e.toString(),"loadFromBigDB failed, table: " + table + ", key: " + key,e.getStackTrace(),{});
				}
			},function(param1:PlayerIOError):void {
				Console.write("FAILED DATA - TABLE: " + table + " KEY: " + key + " ERROR: " + param1.name);
			});
		}
		
		public function loadRangeFromBigDB(table:String, index:String, indexPath:Array = null, callback:Function = null, maxCount:int = 1000) : void {
			_client.bigDB.loadRange(table,index,indexPath,null,null,maxCount,function(param1:Array):void {
				callback(param1);
			},function(param1:PlayerIOError):void {
				Console.write("FAILED DATA - TABLE: " + table + " INDEX: " + index + " INDEX_PATH: " + indexPath + " ERROR: " + param1);
			});
		}
		
		public function loadKeysFromBigDB(table:String, keys:Array, callback:Function = null) : void {
			var key:String;
			var n:int = int(keys.length);
			var i:int = n - 1;
			while(i > -1) {
				key = keys[i];
				if(IsNullOrEmpty(key)) {
					keys.splice(keys.indexOf(key),1);
				}
				i--;
			}
			_client.bigDB.loadKeys(table,keys,function(param1:Array):void {
				callback(param1);
			},function(param1:PlayerIOError):void {
				Console.write("FAILED DATA - TABLE: " + table + " KEYS: " + keys + " ERROR: " + param1);
			});
		}
		
		private function IsNullOrEmpty(key:String) : Boolean {
			if(key == null || key == "" || key == " ") {
				return true;
			}
			return false;
		}
		
		public function loadKey(table:String, key:String) : Object {
			if(IsNullOrEmpty(table)) {
				Console.write("error table is null in loadKey");
				return null;
			}
			if(IsNullOrEmpty(key)) {
				Console.write("error key: " + key + " is null in loadKey for table " + table);
				return null;
			}
			if(!json.hasOwnProperty(table) || !json[table].hasOwnProperty(key)) {
				Console.write("error key missing i json cache, table: " + table + ", key: " + key);
				return null;
			}
			return json[table][key];
		}
		
		public function loadKeys(table:String, keys:Array) : Array {
			var _local4:Object = null;
			var _local3:Array = [];
			for each(var _local5 in keys) {
				_local4 = loadKey(table,_local5);
				_local4.key = _local5;
				_local3.push(_local4);
			}
			return _local3;
		}
		
		public function loadTable(table:String) : Object {
			if(!json.hasOwnProperty(table)) {
				Console.write("error table is missing in cache, table: " + table);
				return null;
			}
			return json[table];
		}
		
		public function loadRange(table:String, property:String, compareValue:String) : Object {
			var _local5:Object = null;
			if(!json.hasOwnProperty(table)) {
				Console.write("error table missing i json cache, table: " + table);
				return null;
			}
			var _local4:Object = {};
			for(var _local6 in json[table]) {
				_local5 = json[table][_local6];
				if(_local5.hasOwnProperty(property)) {
					if(_local5[property] == compareValue) {
						_local4[_local6] = _local5;
					}
				}
			}
			return _local4;
		}
		
		public function loadFirstByProperty(table:String, property:String, compareValue:String) : Object {
			var _local4:Object = null;
			if(!json.hasOwnProperty(table)) {
				Console.write("error table missing i json cache, table: " + table);
				return null;
			}
			for(var _local5 in json[table]) {
				_local4 = json[table][_local5];
				if(_local4.hasOwnProperty(property)) {
					if(_local4[property] == compareValue) {
						return _local4;
					}
				}
			}
			return null;
		}
		
		public function cacheCommonData() : void {
			var _local2:ByteArray = new CacheFile() as ByteArray;
			var _local1:JSONDecoder = new JSONDecoder(_local2.readUTFBytes(_local2.length),true);
			json = _local1.getValue();
		}
	}
}

