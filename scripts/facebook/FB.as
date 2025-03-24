package facebook {
	import flash.events.*;
	import flash.external.*;
	import flash.net.*;
	import flash.system.*;
	
	public class FB {
		private static var access_token:String = null;
		
		private static var app_id:String = null;
		
		private static var debug:Boolean = false;
		
		private static var uiFlashId:String = null;
		
		private static var uiCallbackId:Number = 0;
		
		private static var allowedMethods:Object = {
			"GET":1,
			"POST":1,
			"DELETE":1,
			"PUT":1
		};
		
		private static var readOnlyCalls:Object = {
			"fql_query":1,
			"fql_multiquery":1,
			"friends_get":1,
			"notifications_get":1,
			"stream_get":1,
			"users_getinfo":1
		};
		
		private static var data:FBData = new FBData();
		
		private static var _formatRE:RegExp = /(\{[^\}^\{]+\})/g;
		
		private static var _trimRE:RegExp = /^\s*|\s*$/g;
		
		private static var _quoteRE:RegExp = /["\\\x00-\x1f\x7f-\x9f]/g;
		
		public function FB() {
			super();
		}
		
		public static function get Data() : FBData {
			return data;
		}
		
		public static function init(params:*) : void {
			debug = !!params.debug;
			app_id = params.app_id;
			if((params.access_token + "").length < 3) {
				error("You must supply the init method with an not-null access_token string.");
			} else {
				access_token = params.access_token;
				log("Initializing with access_token: " + access_token);
			}
		}
		
		public static function api(... rest) : void {
			requireAccessToken("api");
			if(typeof rest[0] == "string") {
				graphCall.apply(null,rest);
			} else {
				restCall.apply(null,rest);
			}
		}
		
		public static function get uiAvailable() : Boolean {
			return initUI() == null;
		}
		
		public static function ui(params:*, cb:Function) : void {
			var callbackId:String;
			var err:String = initUI();
			if(err != null) {
				error(err);
			}
			if(!params.method) {
				error("\"method\" is a required parameter for FB.ui().");
			}
			callbackId = "as_ui_callback_" + uiCallbackId++;
			ExternalInterface.addCallback(callbackId,function(param1:*):void {
				log("Got response from Javascript FB.ui: " + toString(param1));
				cb(param1);
			});
			ExternalInterface.call("__doFBUICall",uiFlashId,params,callbackId);
		}
		
		private static function initUI() : String {
			var allowsExternalInterface:Boolean;
			var hasJavascript:Boolean;
			var source:String;
			if(uiFlashId == null) {
				Security.allowDomain("*");
				allowsExternalInterface = false;
				try {
					allowsExternalInterface = ExternalInterface.call("eval","true");
				}
				catch(e:*) {
				}
				if(!allowsExternalInterface) {
					return "The flash element must not have allowNetworking = \'none\' in the containing page in order to call the FB.ui() method.";
				}
				hasJavascript = ExternalInterface.call("eval","typeof(FB)!=\'undefined\' && typeof(FB.ui)!=\'undefined\'");
				if(!hasJavascript) {
					return "The FB.ui() method can only be used when the containing page includes the Facebook Javascript SDK. Read more here: http://developers.facebook.com/docs/reference/javascript/FB.init";
				}
				uiFlashId = "flash_" + new Date().getTime() + Math.round(Math.random() * 9999999);
				ExternalInterface.addCallback("getFlashId",function():String {
					return uiFlashId;
				});
				source = "";
				source += "__doFBUICall = function(uiFlashId,params,callbackId){";
				source += " var find = function(tag){var list=document.getElementsByTagName(tag);for(var i=0;i!=list.length;i++){if(list[i].getFlashId&&list[i].getFlashId()==\"" + uiFlashId + "\"){return list[i]}}};";
				source += " var flashObj = find(\"embed\") || find(\"object\");";
				source += " if(flashObj != null){";
				source += "  FB.ui(params, function(response){";
				source += "   flashObj[callbackId](response);";
				source += "  })";
				source += " }else{alert(\"could not find flash element on the page w/ uiFlashId: " + uiFlashId + "\")}";
				source += "};";
				ExternalInterface.call("eval",source);
			}
			return null;
		}
		
		private static function graphCall(... rest) : void {
			var _local6:String = null;
			var _local7:String = null;
			var _local4:* = null;
			var _local5:* = null;
			var _local8:Function = null;
			var _local3:String = rest.shift();
			var _local2:* = rest.shift();
			while(_local2) {
				_local6 = typeof _local2;
				if(_local6 === "string" && _local4 == null) {
					_local7 = _local2.toUpperCase();
					if(allowedMethods[_local7]) {
						_local4 = _local7;
					} else {
						error("Invalid method passed to FB.api(" + _local3 + "): " + _local2);
					}
				} else if(_local6 === "function" && _local8 == null) {
					_local8 = _local2;
				} else if(_local6 === "object" && _local5 == null) {
					_local5 = _local2;
				} else {
					error("Invalid argument passed to FB.api(" + _local3 + "): " + _local2);
				}
				_local2 = rest.shift();
			}
			_local4 ||= "GET";
			_local5 ||= {};
			log("Graph call: path=" + _local3 + ", method=" + _local4 + ", params=" + toString(_local5));
			oauthRequest("https://graph.facebook.com" + _local3,_local4,_local5,_local8);
		}
		
		private static function restCall(params:*, cb:Function) : void {
			var _local3:String = (params.method + "").toLowerCase().replace(".","_");
			params.format = "json-strings";
			params.api_key = app_id;
			log("REST call: method=" + _local3 + ", params=" + toString(params));
			oauthRequest("https://" + (!!readOnlyCalls[_local3] ? "api-read" : "api") + ".facebook.com/restserver.php","get",params,cb);
		}
		
		private static function oauthRequest(url:String, method:String, params:*, cb:Function) : void {
			var x:*;
			var loader:URLLoader;
			var request:URLRequest = new URLRequest(url);
			request.method = method;
			request.data = new URLVariables();
			request.data.access_token = access_token;
			for(x in params) {
				request.data[x] = params[x];
			}
			request.data.callback = "c";
			loader = new URLLoader();
			loader.addEventListener("complete",function(param1:Event):void {
				var _local3:String = loader.data;
				if(_local3.length > 2 && _local3.substring(0,12) == "/**/ /**/ c(") {
					_local3 = loader.data.substring(loader.data.indexOf("(") + 1,loader.data.lastIndexOf(")"));
				} else if(_local3.length > 2 && _local3.substring(0,7) == "/**/ c(") {
					_local3 = loader.data.substring(loader.data.indexOf("(") + 1,loader.data.lastIndexOf(")"));
				}
				var _local2:* = JSON2.deserialize(_local3);
				if(url.substring(0,11) == "https://api") {
					log("REST call result, method=" + params.method + " => " + toString(_local2));
				} else {
					log("Graph call result, path=" + url + " => " + toString(_local2));
				}
				cb(_local2);
			});
			loader.addEventListener("ioError",function(param1:IOErrorEvent):void {
				error("Error in response from Facebook api servers, most likely cause is expired or invalid access_token. Error message: " + param1.text);
			});
			loader.load(request);
		}
		
		private static function requireAccessToken(callerName:String) : void {
			if(access_token == null) {
				error("You must call FB.init({access_token:\"...\") before attempting to call FB." + callerName + "()");
			}
		}
		
		private static function error(msg:String) : void {
			if(debug) {
			}
			throw new Error(msg);
		}
		
		private static function log(msg:String) : void {
			if(debug) {
			}
		}
		
		public static function toString(obj:*) : String {
			var _local4:String = null;
			var _local6:String = null;
			var _local3:Boolean = false;
			var _local2:Boolean = false;
			if(obj == null) {
				return "[null]";
			}
			switch(typeof obj) {
				case "object":
					_local4 = "{";
					_local6 = "[";
					_local3 = true;
					_local2 = false;
					for(var _local5 in obj) {
						_local4 += (_local4 == "{" ? "" : ", ") + _local5 + "=" + toString(obj[_local5]);
						_local6 += (_local6 == "[" ? "" : ", ") + toString(obj[_local5]);
						if(typeof _local5 != "number") {
							_local3 = false;
						}
						_local2 = true;
					}
					return _local3 && _local2 ? _local6 + "]" : _local4 + "}";
				case "string":
					return "\"" + obj.replace("\n","\\n").replace("\r","\\r") + "\"";
				default:
					return obj + "";
			}
		}
		
		internal static function stringTrim(s:String) : String {
			return s.replace(_trimRE,"");
		}
		
		internal static function stringFormat(format:String, ... rest) : String {
			var args:Array = rest;
			return format.replace(_formatRE,function(param1:String, param2:String, param3:int, param4:String):String {
				var _local5:int = parseInt(param2.substr(1),10);
				var _local6:* = args[_local5];
				if(_local6 === null || typeof _local6 == "undefined") {
					return "";
				}
				return _local6.toString();
			});
		}
		
		internal static function stringQuote(value:String) : String {
			var subst:Object = {
				"\b":"\\b",
				"\t":"\\t",
				"\n":"\\n",
				"\f":"\\f",
				"\r":"\\r",
				"\"":"\\\"",
				"\\":"\\\\"
			};
			return !!_quoteRE.test(value) ? "\"" + value.replace(_quoteRE,function(param1:String):String {
				var _local2:String = subst[param1];
				if(_local2) {
					return _local2;
				}
				_local2 = param1.charCodeAt().toString();
				return "\\u00" + Math.floor(Number(_local2) / 16).toString(16) + (Number(_local2) % 16).toString(16);
			}) + "\"" : "\"" + value + "\"";
		}
		
		internal static function arrayIndexOf(arr:Array, item:*) : int {
			var _local4:int = 0;
			var _local3:uint = arr.length;
			if(_local3) {
				_local4 = 0;
				while(_local4 < _local3) {
					if(arr[_local4] === item) {
						return _local4;
					}
					_local4++;
				}
			}
			return -1;
		}
		
		internal static function arrayMerge(target:Array, source:Array) : Array {
			var _local3:int = 0;
			_local3 = 0;
			while(_local3 < source.length) {
				if(arrayIndexOf(target,source[_local3]) < 0) {
					target.push(source[_local3]);
				}
				_local3++;
			}
			return target;
		}
		
		internal static function arrayMap(arr:Array, transform:Function) : Array {
			var _local4:int = 0;
			var _local3:Array = [];
			_local4 = 0;
			while(_local4 < arr.length) {
				_local3.push(transform(arr[_local4]));
				_local4++;
			}
			return _local3;
		}
		
		internal static function arrayFilter(arr:Array, fn:Function) : Array {
			var _local4:int = 0;
			var _local3:Array = [];
			_local4 = 0;
			while(_local4 < arr.length) {
				if(fn(arr[_local4])) {
					_local3.push(arr[_local4]);
				}
				_local4++;
			}
			return _local3;
		}
		
		internal static function objCopy(target:Object, source:Object, overwrite:Boolean, transform:Function) : Object {
			for(var _local5 in source) {
				if(overwrite || typeof target[_local5] == "undefined") {
					target[_local5] = typeof transform == "function" ? transform(source[_local5]) : source[_local5];
				}
			}
			return target;
		}
		
		internal static function forEach(item:*, fn:Function) : void {
			var _local4:* = 0;
			if(!item) {
				return;
			}
			if(item is Array) {
				_local4 = 0;
				while(_local4 != item.length) {
					fn(item[_local4],_local4,item);
					_local4++;
				}
			} else if(item is Object) {
				for(var _local3 in item) {
					fn(item[_local3],_local3,item);
				}
			}
		}
	}
}

