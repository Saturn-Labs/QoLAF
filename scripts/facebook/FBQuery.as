package facebook {
	import flash.events.*;
	import flash.external.*;
	import flash.net.*;
	import flash.system.*;
	
	public class FBQuery extends FBWaitable {
		private static var counter:int = 0;
		
		public var name:String = "";
		
		public var hasDependency:Boolean = false;
		
		public var fields:Array = [];
		
		public var table:String = null;
		
		public var where:Object = null;
		
		public function FBQuery() {
			super();
			name = "v_" + counter++;
		}
		
		internal function parse(template:String, args:Array) : FBQuery {
			var _local5:* = 0;
			var _local3:String = FB.stringFormat(template,args);
			var _local4:Object = /^select (.*?) from (\w+)\s+where (.*)$/i.exec(_local3);
			this.fields = _toFields(_local4[1]);
			this.table = _local4[2];
			this.where = _parseWhere(_local4[3]);
			_local5 = 0;
			while(_local5 < args.length) {
				if(args[_local5] is FBQuery) {
					args[_local5].hasDependency = true;
				}
				_local5++;
			}
			return this;
		}
		
		public function toFql() : String {
			var _local1:String = "select " + this.fields.join(",") + " from " + this.table + " where ";
			switch(this.where.type) {
				case "unknown":
					_local1 += this.where.value;
					break;
				case "index":
					_local1 += this.where.key + "=" + this._encode(this.where.value);
					break;
				case "in":
					if(this.where.value.length == 1) {
						_local1 += this.where.key + "=" + this._encode(this.where.value[0]);
					} else {
						_local1 += this.where.key + " in (" + FB.arrayMap(this.where.value,this._encode).join(",") + ")";
					}
			}
			return _local1;
		}
		
		private function _encode(value:Object) : String {
			return typeof value == "string" ? FB.stringQuote(value + "") : value + "";
		}
		
		public function toString() : String {
			return "#" + this.name;
		}
		
		private function _toFields(s:String) : Array {
			return FB.arrayMap(s.split(","),FB.stringTrim);
		}
		
		private function _parseWhere(s:String) : Object {
			var _local3:Object = /^\s*(\w+)\s*=\s*(.*)\s*$/i.exec(s);
			var _local2:Object = null;
			var _local5:* = null;
			var _local4:String = "unknown";
			if(_local3) {
				_local5 = _local3[2];
				if(/^(["'])(?:\\?.)*?\1$/.test(_local5)) {
					_local5 = JSON2.deserialize(_local5);
					_local4 = "index";
				} else if(/^\d+\.?\d*$/.test(_local5)) {
					_local4 = "index";
				}
			}
			if(_local4 == "index") {
				_local2 = {
					"type":"index",
					"key":_local3[1],
					"value":_local5
				};
			} else {
				_local2 = {
					"type":"unknown",
					"value":s
				};
			}
			return _local2;
		}
	}
}

