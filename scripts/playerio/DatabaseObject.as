package playerio {
	import playerio.helpers.FieldToBeRemoved;
	import playerio.utils.Converter;
	
	public dynamic class DatabaseObject {
		private var _table:String = "";
		
		private var _version:String = "";
		
		private var _creator:uint = 0;
		
		private var _key:String = "";
		
		private var _saveHandler:Function;
		
		private var _cache:DatabaseObject;
		
		private var _createIfMissing:Boolean = false;
		
		private var saveQueue:Array = [];
		
		private var inSave:Boolean = false;
		
		private var prefix:String = "    ";
		
		public function DatabaseObject(table:String, key:String, version:String, creator:uint, createIfMissing:Boolean, saveHandler:Function) {
			super();
			this._table = table;
			this._version = version;
			this._creator = creator;
			this._key = key;
			this._saveHandler = saveHandler;
			this._createIfMissing = createIfMissing;
		}
		
		public function save(useOptimisticLock:Boolean = false, fullOverwrite:Boolean = false, callback:Function = null, errorHandler:Function = null) : void {
			var _local7:SaveQueueItem = null;
			var _local6:SaveQueueItem = null;
			if(fullOverwrite) {
				throw new Error("FullOverwrite is not yet supported by BigDB - Stay tuned at www.player.io for updates!",0);
			}
			var _local5:DatabaseObject = Converter.toDatabaseObject(table,Converter.toSparseBigDBObject(key,_version,_creator,this),_createIfMissing,null);
			if(inSave) {
				_local7 = saveQueue.length > 0 ? saveQueue[saveQueue.length - 1] : null;
				if(_local7 != null && _local7.useOptimisticLock == useOptimisticLock && _local7.fullOverwrite == fullOverwrite) {
					_local7.data = _local5;
					_local7.callbacks.push(callback);
					_local7.errorHandlers.push(errorHandler);
				} else {
					_local6 = new SaveQueueItem();
					_local6.data = _local5;
					_local6.callbacks.push(callback);
					_local6.errorHandlers.push(errorHandler);
					_local6.fullOverwrite = fullOverwrite;
					_local6.useOptimisticLock = useOptimisticLock;
					saveQueue.push(_local6);
				}
				return;
			}
			doSave(_local5,useOptimisticLock,fullOverwrite,callback,errorHandler);
		}
		
		public function commit() : void {
			_cache = Converter.toDatabaseObject(table,Converter.toSparseBigDBObject(key,_version,_creator,this),_createIfMissing,null);
		}
		
		private function doSave(cached:DatabaseObject, useOptimisticLock:Boolean = false, fullOverwrite:Boolean = false, callback:Function = null, errorHandler:Function = null) : void {
			var changed:Boolean;
			var x:String;
			inSave = true;
			var ret:Object = {};
			compareObject(_cache,cached,ret);
			changed = false;
			var _local8:int = 0;
			var _local7:Object = ret;
			for(x in _local7) {
				changed = true;
			}
			if(!changed) {
				if(callback != null) {
					callback();
				}
				emptyQueue();
				return;
			}
			this._saveHandler(_table,_key,_version,ret,useOptimisticLock,_createIfMissing,function(param1:String):void {
				if(param1 == null) {
					if(errorHandler == null) {
						throw PlayerIOError.StaleVersion;
					}
					errorHandler(PlayerIOError.StaleVersion);
				} else {
					_version = param1;
					_cache = cached;
					if(callback != null) {
						callback();
					}
				}
				emptyQueue();
			},function(param1:PlayerIOError):void {
				emptyQueue();
				if(errorHandler == null) {
					throw param1;
				}
				errorHandler(param1);
			});
		}
		
		private function emptyQueue() : void {
			var qi:SaveQueueItem;
			inSave = false;
			if(saveQueue.length != 0) {
				qi = saveQueue.shift();
				doSave(qi.data,qi.useOptimisticLock,qi.fullOverwrite,function():void {
					var _local1:int = 0;
					_local1 = 0;
					while(_local1 < qi.callbacks.length) {
						if(qi.callbacks[_local1] != null) {
							qi.callbacks[_local1]();
						}
						_local1++;
					}
				},function(param1:PlayerIOError):void {
					var _local2:int = 0;
					_local2 = 0;
					while(_local2 < qi.errorHandlers.length) {
						if(qi.errorHandlers[_local2] == null) {
							throw param1;
						}
						qi.errorHandlers[_local2](param1);
						_local2++;
					}
				});
			}
		}
		
		public function get table() : String {
			return _table;
		}
		
		public function get key() : String {
			return _key;
		}
		
		private function compareObject(before:Object, after:Object, target:Object = null) : Object {
			var x:String;
			var na:Array;
			var no:Object;
			var changed:Boolean;
			var nx:String;
			var setProp:* = function(param1:String, param2:*):void {
				ret[param1] = param2;
			};
			var ret:Object = target || {};
			var prop:Object = mergePropertyList(before,after);
			for(x in prop) {
				if(before[x] !== after[x]) {
					if(after[x] === undefined) {
						setProp(x,new FieldToBeRemoved());
					} else if(before[x] is Array && after[x] is Array) {
						na = objectToArray(compareObject(before[x],after[x]));
						if(na.length > 0) {
							setProp(x,na);
						}
					} else if(before[x] is Object && before[x].constructor == Object && after[x] is Object && after[x].constructor == Object) {
						no = compareObject(before[x],after[x]);
						changed = false;
						var _local6:int = 0;
						var _local5:Object = no;
						for(nx in _local5) {
							changed = true;
						}
						if(changed) {
							setProp(x,no);
						}
					} else {
						setProp(x,after[x]);
					}
				}
			}
			return ret;
		}
		
		private function mergePropertyList(a:Object, b:Object) : Object {
			var _local4:int = 0;
			var _local5:int = 0;
			var _local3:Object = {};
			if(a is Array) {
				_local4 = 0;
				while(_local4 < a.length) {
					_local3[_local4] = true;
					_local4++;
				}
			} else {
				for(var _local7 in a) {
					_local3[_local7] = true;
				}
			}
			if(b is Array) {
				_local5 = 0;
				while(_local5 < b.length) {
					_local3[_local5] = true;
					_local5++;
				}
			} else {
				for(var _local6 in b) {
					_local3[_local6] = true;
				}
			}
			return _local3;
		}
		
		private function objectToArray(o:Object) : Array {
			var _local2:Array = [];
			for(var _local3 in o) {
				_local2[parseInt(_local3)] = o[_local3];
			}
			return _local2;
		}
		
		public function toString() : String {
			var _local1:String = "[playerio.DatabaseObject]\n";
			return _local1 + (_table + "[\"" + key + "\"] = " + serialize(prefix,this) + " (Version:" + _version + ")");
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
				_local4 = 0;
				while(_local4 < value.length) {
					if(value[_local4] !== undefined) {
						_local5.push({
							"id":_local4,
							"value":serialize(pf + prefix,value[_local4])
						});
					}
					_local4++;
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
				if(value.constructor == Object || value.constructor == DatabaseObject) {
					_local3 = "{\n";
					for(_local6 in value) {
						_local5.push({
							"id":_local6,
							"value":serialize(pf + prefix,value[_local6])
						});
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
			if(value === null) {
				return "null";
			}
			if(value === undefined) {
				return "undefined";
			}
			return value.toString();
		}
	}
}

class SaveQueueItem {
	public var data:DatabaseObject;
	
	public var callbacks:Array = [];
	
	public var errorHandlers:Array = [];
	
	public var useOptimisticLock:Boolean;
	
	public var fullOverwrite:Boolean;
	
	public function SaveQueueItem() {
		super();
	}
}
