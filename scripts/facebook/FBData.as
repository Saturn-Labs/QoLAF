package facebook {
	import flash.events.*;
	import flash.external.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;
	
	public class FBData {
		private var timer:int = -1;
		
		private var queue:Array = [];
		
		public function FBData() {
			super();
		}
		
		public function query(template:String, ... rest) : FBQuery {
			var _local3:FBQuery = new FBQuery().parse(template,rest);
			queue.push(_local3);
			_waitToProcess();
			return _local3;
		}
		
		public function waitOn(dependencies:Array, callback:Function) : FBWaitable {
			var result:FBWaitable = new FBWaitable();
			var count:int = int(dependencies.length);
			FB.forEach(dependencies,function(param1:*, param2:*, param3:*):void {
				var item:* = param1;
				var index:* = param2;
				var original:* = param3;
				item.monitor("value",function():Boolean {
					var _local2:* = undefined;
					var _local1:Boolean = false;
					if(FB.Data._getValue(item) != null) {
						count--;
						_local1 = true;
					}
					if(count == 0) {
						_local2 = callback(FB.arrayMap(dependencies,FB.Data._getValue));
						result.value = _local2 != null ? _local2 : true;
					}
					return _local1;
				});
			});
			return result;
		}
		
		private function _getValue(item:*) : * {
			return item is FBWaitable ? item.value : item;
		}
		
		private function _waitToProcess() : void {
			if(timer < 0) {
				timer = setTimeout(_process,10);
			}
		}
		
		private function _process() : void {
			var item:FBQuery;
			var params:Object;
			timer = -1;
			var mqueries:Object = {};
			var q:Array = queue;
			queue = [];
			var i:int = 0;
			while(i < q.length) {
				item = q[i];
				if(item.where.type == "index" && !item.hasDependency) {
					_mergeIndexQuery(item,mqueries);
				} else {
					mqueries[item.name] = item;
				}
				i++;
			}
			params = {
				"method":"fql.multiquery",
				"queries":{}
			};
			FB.objCopy(params.queries,mqueries,true,function(param1:FBQuery):String {
				return param1.toFql();
			});
			params.queries = JSON2.serialize(params.queries);
			FB.api(params,function(param1:*):void {
				var _local2:int = 0;
				var _local4:* = undefined;
				if(param1.error_msg) {
					for(var _local3 in mqueries) {
						mqueries[_local3].error(new Error(param1.error_msg));
					}
				} else {
					_local2 = 0;
					while(_local2 < param1.length) {
						_local4 = param1[_local2];
						mqueries[_local4.name].value = _local4.fql_result_set;
						_local2++;
					}
				}
			});
		}
		
		private function _mergeIndexQuery(item:FBQuery, mqueries:Object) : void {
			var key:String = item.where.key;
			var value:* = item.where.value;
			var name:String = "index_" + item.table + "_" + key;
			var master:FBQuery = mqueries[name];
			if(!master) {
				master = mqueries[name] = new FBQuery();
				master.fields = [key];
				master.table = item.table;
				master.where = {
					"type":"in",
					"key":key,
					"value":[]
				};
			}
			FB.arrayMerge(master.fields,item.fields);
			FB.arrayMerge(master.where.value,[value]);
			master.wait(function(param1:Array):void {
				var r:Array = param1;
				item.value = FB.arrayFilter(r,function(param1:Object):Boolean {
					return param1[key] == value;
				});
			},function(param1:*):void {
				item.fire("error",param1);
			});
		}
	}
}

