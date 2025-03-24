package com.adobe.net {
	public class URI {
		public static const URImustEscape:String = " %";
		
		public static const URIbaselineEscape:String = " %:?#/@";
		
		public static const URIpathEscape:String = " %?#";
		
		public static const URIqueryEscape:String = " %#";
		
		public static const URIqueryPartEscape:String = " %#&=";
		
		public static const URInonHierEscape:String = " %?#/";
		
		public static const UNKNOWN_SCHEME:String = "unknown";
		
		public static const NOT_RELATED:int = 0;
		
		public static const CHILD:int = 1;
		
		public static const EQUAL:int = 2;
		
		public static const PARENT:int = 3;
		
		protected static var _resolver:IURIResolver = null;
		
		protected static const URIbaselineExcludedBitmap:URIEncodingBitmap = new URIEncodingBitmap(" %:?#/@");
		
		protected static const URIschemeExcludedBitmap:URIEncodingBitmap = URIbaselineExcludedBitmap;
		
		protected static const URIuserpassExcludedBitmap:URIEncodingBitmap = URIbaselineExcludedBitmap;
		
		protected static const URIauthorityExcludedBitmap:URIEncodingBitmap = URIbaselineExcludedBitmap;
		
		protected static const URIportExludedBitmap:URIEncodingBitmap = URIbaselineExcludedBitmap;
		
		protected static const URIpathExcludedBitmap:URIEncodingBitmap = new URIEncodingBitmap(" %?#");
		
		protected static const URIqueryExcludedBitmap:URIEncodingBitmap = new URIEncodingBitmap(" %#");
		
		protected static const URIqueryPartExcludedBitmap:URIEncodingBitmap = new URIEncodingBitmap(" %#&=");
		
		protected static const URIfragmentExcludedBitmap:URIEncodingBitmap = URIqueryExcludedBitmap;
		
		protected static const URInonHierexcludedBitmap:URIEncodingBitmap = new URIEncodingBitmap(" %?#/");
		
		protected var _valid:Boolean = false;
		
		protected var _relative:Boolean = false;
		
		protected var _scheme:String = "";
		
		protected var _authority:String = "";
		
		protected var _username:String = "";
		
		protected var _password:String = "";
		
		protected var _port:String = "";
		
		protected var _path:String = "";
		
		protected var _query:String = "";
		
		protected var _fragment:String = "";
		
		protected var _nonHierarchical:String = "";
		
		public function URI(uri:String = null) {
			super();
			if(uri == null) {
				initialize();
			} else {
				constructURI(uri);
			}
		}
		
		public static function escapeChars(unescaped:String) : String {
			return fastEscapeChars(unescaped,URI.URIbaselineExcludedBitmap);
		}
		
		public static function unescapeChars(escaped:String) : String {
			var _local2:* = null;
			return decodeURIComponent(escaped);
		}
		
		public static function fastEscapeChars(unescaped:String, bitmap:URIEncodingBitmap) : String {
			var _local4:String = null;
			var _local6:int = 0;
			var _local5:int = 0;
			var _local3:String = "";
			_local6 = 0;
			while(_local6 < unescaped.length) {
				_local4 = unescaped.charAt(_local6);
				_local5 = bitmap.ShouldEscape(_local4);
				if(_local5) {
					_local4 = _local5.toString(16);
					if(_local4.length == 1) {
						_local4 = "0" + _local4;
					}
					_local4 = "%" + _local4;
					_local4 = _local4.toUpperCase();
				}
				_local3 += _local4;
				_local6++;
			}
			return _local3;
		}
		
		public static function queryPartEscape(unescaped:String) : String {
			var _local2:* = unescaped;
			return URI.fastEscapeChars(unescaped,URI.URIqueryPartExcludedBitmap);
		}
		
		public static function queryPartUnescape(escaped:String) : String {
			var _local2:* = escaped;
			return unescapeChars(_local2);
		}
		
		protected static function compareStr(str1:String, str2:String, sensitive:Boolean = true) : Boolean {
			if(sensitive == false) {
				str1 = str1.toLowerCase();
				str2 = str2.toLowerCase();
			}
			return str1 == str2;
		}
		
		protected static function resolve(uri:URI) : URI {
			var _local2:URI = new URI();
			_local2.copyURI(uri);
			if(_resolver != null) {
				return _resolver.resolve(_local2);
			}
			return _local2;
		}
		
		public static function set resolver(resolver:IURIResolver) : void {
			_resolver = resolver;
		}
		
		public static function get resolver() : IURIResolver {
			return _resolver;
		}
		
		protected function constructURI(uri:String) : Boolean {
			if(!parseURI(uri)) {
				_valid = false;
			}
			return isValid();
		}
		
		protected function initialize() : void {
			_valid = false;
			_relative = false;
			_scheme = "unknown";
			_authority = "";
			_username = "";
			_password = "";
			_port = "";
			_path = "";
			_query = "";
			_fragment = "";
			_nonHierarchical = "";
		}
		
		protected function set hierState(state:Boolean) : void {
			if(state) {
				_nonHierarchical = "";
				if(_scheme == "" || _scheme == "unknown") {
					_relative = true;
				} else {
					_relative = false;
				}
				if(_authority.length == 0 && _path.length == 0) {
					_valid = false;
				} else {
					_valid = true;
				}
			} else {
				_authority = "";
				_username = "";
				_password = "";
				_port = "";
				_path = "";
				_relative = false;
				if(_scheme == "" || _scheme == "unknown") {
					_valid = false;
				} else {
					_valid = true;
				}
			}
		}
		
		protected function get hierState() : Boolean {
			return _nonHierarchical.length == 0;
		}
		
		protected function validateURI() : Boolean {
			if(isAbsolute()) {
				if(_scheme.length <= 1 || _scheme == "unknown") {
					return false;
				}
				if(verifyAlpha(_scheme) == false) {
					return false;
				}
			}
			if(hierState) {
				if(_path.search("\\") != -1) {
					return false;
				}
				if(isRelative() == false && _scheme == "unknown") {
					return false;
				}
			} else if(_nonHierarchical.search("\\") != -1) {
				return false;
			}
			return true;
		}
		
		protected function parseURI(uri:String) : Boolean {
			var _local6:int = 0;
			var _local7:int = 0;
			var _local4:* = uri;
			initialize();
			_local7 = int(_local4.indexOf("#"));
			if(_local7 != -1) {
				if(_local4.length > _local7 + 1) {
					_fragment = _local4.substr(_local7 + 1,_local4.length - (_local7 + 1));
				}
				_local4 = _local4.substr(0,_local7);
			}
			_local7 = int(_local4.indexOf("?"));
			if(_local7 != -1) {
				if(_local4.length > _local7 + 1) {
					_query = _local4.substr(_local7 + 1,_local4.length - (_local7 + 1));
				}
				_local4 = _local4.substr(0,_local7);
			}
			_local7 = int(_local4.search(":"));
			_local6 = int(_local4.search("/"));
			var _local3:* = _local7 != -1;
			var _local5:* = _local6 != -1;
			var _local2:Boolean = !_local5 || _local7 < _local6;
			if(_local3 && _local2) {
				_scheme = _local4.substr(0,_local7);
				_scheme = _scheme.toLowerCase();
				_local4 = _local4.substr(_local7 + 1);
				if(_local4.substr(0,2) != "//") {
					_nonHierarchical = _local4;
					if((_valid = validateURI()) == false) {
						initialize();
					}
					return isValid();
				}
				_nonHierarchical = "";
				_local4 = _local4.substr(2,_local4.length - 2);
			} else {
				_scheme = "";
				_relative = true;
				_nonHierarchical = "";
			}
			if(isRelative()) {
				_authority = "";
				_port = "";
				_path = _local4;
			} else {
				if(_local4.substr(0,2) == "//") {
					while(_local4.charAt(0) == "/") {
						_local4 = _local4.substr(1,_local4.length - 1);
					}
				}
				_local7 = int(_local4.search("/"));
				if(_local7 == -1) {
					_authority = _local4;
					_path = "";
				} else {
					_authority = _local4.substr(0,_local7);
					_path = _local4.substr(_local7,_local4.length - _local7);
				}
				_local7 = int(_authority.search("@"));
				if(_local7 != -1) {
					_username = _authority.substr(0,_local7);
					_authority = _authority.substr(_local7 + 1);
					_local7 = int(_username.search(":"));
					if(_local7 != -1) {
						_password = _username.substring(_local7 + 1,_username.length);
						_username = _username.substr(0,_local7);
					} else {
						_password = "";
					}
				} else {
					_username = "";
					_password = "";
				}
				_local7 = int(_authority.search(":"));
				if(_local7 != -1) {
					_port = _authority.substring(_local7 + 1,_authority.length);
					_authority = _authority.substr(0,_local7);
				} else {
					_port = "";
				}
				_authority = _authority.toLowerCase();
			}
			if((_valid = validateURI()) == false) {
				initialize();
			}
			return isValid();
		}
		
		public function copyURI(uri:URI) : void {
			this._scheme = uri._scheme;
			this._authority = uri._authority;
			this._username = uri._username;
			this._password = uri._password;
			this._port = uri._port;
			this._path = uri._path;
			this._query = uri._query;
			this._fragment = uri._fragment;
			this._nonHierarchical = uri._nonHierarchical;
			this._valid = uri._valid;
			this._relative = uri._relative;
		}
		
		protected function verifyAlpha(str:String) : Boolean {
			var _local3:int = 0;
			var _local2:RegExp = /[^a-z]/;
			str = str.toLowerCase();
			_local3 = int(str.search(_local2));
			if(_local3 == -1) {
				return true;
			}
			return false;
		}
		
		public function isValid() : Boolean {
			return this._valid;
		}
		
		public function isAbsolute() : Boolean {
			return !this._relative;
		}
		
		public function isRelative() : Boolean {
			return this._relative;
		}
		
		public function isDirectory() : Boolean {
			if(_path.length == 0) {
				return false;
			}
			return _path.charAt(path.length - 1) == "/";
		}
		
		public function isHierarchical() : Boolean {
			return hierState;
		}
		
		public function get scheme() : String {
			return URI.unescapeChars(_scheme);
		}
		
		public function set scheme(schemeStr:String) : void {
			var _local2:String = schemeStr.toLowerCase();
			_scheme = URI.fastEscapeChars(_local2,URI.URIschemeExcludedBitmap);
		}
		
		public function get authority() : String {
			return URI.unescapeChars(_authority);
		}
		
		public function set authority(authorityStr:String) : void {
			authorityStr = authorityStr.toLowerCase();
			_authority = URI.fastEscapeChars(authorityStr,URI.URIauthorityExcludedBitmap);
			this.hierState = true;
		}
		
		public function get username() : String {
			return URI.unescapeChars(_username);
		}
		
		public function set username(usernameStr:String) : void {
			_username = URI.fastEscapeChars(usernameStr,URI.URIuserpassExcludedBitmap);
			this.hierState = true;
		}
		
		public function get password() : String {
			return URI.unescapeChars(_password);
		}
		
		public function set password(passwordStr:String) : void {
			_password = URI.fastEscapeChars(passwordStr,URI.URIuserpassExcludedBitmap);
			this.hierState = true;
		}
		
		public function get port() : String {
			return URI.unescapeChars(_port);
		}
		
		public function set port(portStr:String) : void {
			_port = URI.escapeChars(portStr);
			this.hierState = true;
		}
		
		public function get path() : String {
			return URI.unescapeChars(_path);
		}
		
		public function set path(pathStr:String) : void {
			this._path = URI.fastEscapeChars(pathStr,URI.URIpathExcludedBitmap);
			if(this._scheme == "unknown") {
				this._scheme = "";
			}
			hierState = true;
		}
		
		public function get query() : String {
			return URI.unescapeChars(_query);
		}
		
		public function set query(queryStr:String) : void {
			_query = URI.fastEscapeChars(queryStr,URI.URIqueryExcludedBitmap);
		}
		
		public function get queryRaw() : String {
			return _query;
		}
		
		public function set queryRaw(queryStr:String) : void {
			_query = queryStr;
		}
		
		public function get fragment() : String {
			return URI.unescapeChars(_fragment);
		}
		
		public function set fragment(fragmentStr:String) : void {
			_fragment = URI.fastEscapeChars(fragmentStr,URIfragmentExcludedBitmap);
		}
		
		public function get nonHierarchical() : String {
			return URI.unescapeChars(_nonHierarchical);
		}
		
		public function set nonHierarchical(nonHier:String) : void {
			_nonHierarchical = URI.fastEscapeChars(nonHier,URInonHierexcludedBitmap);
			this.hierState = false;
		}
		
		public function setParts(schemeStr:String, authorityStr:String, portStr:String, pathStr:String, queryStr:String, fragmentStr:String) : void {
			this.scheme = schemeStr;
			this.authority = authorityStr;
			this.port = portStr;
			this.path = pathStr;
			this.query = queryStr;
			this.fragment = fragmentStr;
			hierState = true;
		}
		
		public function isOfType(scheme:String) : Boolean {
			scheme = scheme.toLowerCase();
			return this._scheme == scheme;
		}
		
		public function getQueryValue(name:String) : String {
			var _local3:Object = null;
			var _local2:String = null;
			var _local4:* = null;
			_local3 = getQueryByMap();
			for(_local2 in _local3) {
				if(_local2 == name) {
					return _local3[_local2];
				}
			}
			return new String("");
		}
		
		public function setQueryValue(name:String, value:String) : void {
			var _local3:Object = null;
			_local3 = getQueryByMap();
			_local3[name] = value;
			setQueryByMap(_local3);
		}
		
		public function getQueryByMap() : Object {
			var _local8:String = null;
			var _local6:* = null;
			var _local7:Array = null;
			var _local1:Array = null;
			var _local4:String = null;
			var _local2:String = null;
			var _local3:int = 0;
			var _local5:Object = {};
			_local8 = this._query;
			_local7 = _local8.split("&");
			for each(_local6 in _local7) {
				if(_local6.length != 0) {
					_local1 = _local6.split("=");
					if(_local1.length > 0) {
						_local2 = _local1[0];
						if(_local1.length > 1) {
							_local4 = _local1[1];
						} else {
							_local4 = "";
						}
						_local2 = queryPartUnescape(_local2);
						_local4 = queryPartUnescape(_local4);
						_local5[_local2] = _local4;
					}
				}
			}
			return _local5;
		}
		
		public function setQueryByMap(map:Object) : void {
			var _local2:String = null;
			var _local6:String = null;
			var _local5:* = null;
			var _local3:* = null;
			var _local4:* = null;
			var _local7:String = "";
			for(_local2 in map) {
				_local5 = _local2;
				_local6 = map[_local2];
				if(_local6 == null) {
					_local6 = "";
				}
				_local5 = queryPartEscape(_local5);
				_local6 = queryPartEscape(_local6);
				_local3 = _local5;
				if(_local6.length > 0) {
					_local3 += "=";
					_local3 += _local6;
				}
				if(_local7.length != 0) {
					_local7 += "&";
				}
				_local7 += _local3;
			}
			_query = _local7;
		}
		
		public function toString() : String {
			if(this == null) {
				return "";
			}
			return toStringInternal(false);
		}
		
		public function toDisplayString() : String {
			return toStringInternal(true);
		}
		
		protected function toStringInternal(forDisplay:Boolean) : String {
			var _local3:String = "";
			var _local2:String = "";
			if(isHierarchical() == false) {
				_local3 += forDisplay ? this.scheme : _scheme;
				_local3 += ":";
				_local3 += forDisplay ? this.nonHierarchical : _nonHierarchical;
			} else {
				if(isRelative() == false) {
					if(_scheme.length != 0) {
						_local2 = forDisplay ? this.scheme : _scheme;
						_local3 += _local2 + ":";
					}
					if(_authority.length != 0 || isOfType("file")) {
						_local3 += "//";
						if(_username.length != 0) {
							_local2 = forDisplay ? this.username : _username;
							_local3 += _local2;
							if(_password.length != 0) {
								_local2 = forDisplay ? this.password : _password;
								_local3 += ":" + _local2;
							}
							_local3 += "@";
						}
						_local2 = forDisplay ? this.authority : _authority;
						_local3 += _local2;
						if(port.length != 0) {
							_local3 += ":" + port;
						}
					}
				}
				_local2 = forDisplay ? this.path : _path;
				_local3 += _local2;
			}
			if(_query.length != 0) {
				_local2 = forDisplay ? this.query : _query;
				_local3 += "?" + _local2;
			}
			if(fragment.length != 0) {
				_local2 = forDisplay ? this.fragment : _fragment;
				_local3 += "#" + _local2;
			}
			return _local3;
		}
		
		public function forceEscape() : void {
			this.scheme = this.scheme;
			this.setQueryByMap(this.getQueryByMap());
			this.fragment = this.fragment;
			if(isHierarchical()) {
				this.authority = this.authority;
				this.path = this.path;
				this.port = this.port;
				this.username = this.username;
				this.password = this.password;
			} else {
				this.nonHierarchical = this.nonHierarchical;
			}
		}
		
		public function isOfFileType(extension:String) : Boolean {
			var _local2:String = null;
			var _local3:int = 0;
			_local3 = int(extension.lastIndexOf("."));
			if(_local3 != -1) {
				extension = extension.substr(_local3 + 1);
			}
			_local2 = getExtension(true);
			if(_local2 == "") {
				return false;
			}
			if(compareStr(_local2,extension,false) == 0) {
				return true;
			}
			return false;
		}
		
		public function getExtension(minusDot:Boolean = false) : String {
			var _local2:String = null;
			var _local4:int = 0;
			var _local3:String = getFilename();
			if(_local3 == "") {
				return "";
			}
			_local4 = int(_local3.lastIndexOf("."));
			if(_local4 == -1 || _local4 == 0) {
				return "";
			}
			_local2 = _local3.substr(_local4);
			if(minusDot && _local2.charAt(0) == ".") {
				_local2 = _local2.substr(1);
			}
			return _local2;
		}
		
		public function getFilename(minusExtension:Boolean = false) : String {
			var _local2:* = null;
			var _local3:int = 0;
			if(isDirectory()) {
				return "";
			}
			var _local4:String = this.path;
			_local3 = int(_local4.lastIndexOf("/"));
			if(_local3 != -1) {
				_local2 = _local4.substr(_local3 + 1);
			} else {
				_local2 = _local4;
			}
			if(minusExtension) {
				_local3 = int(_local2.lastIndexOf("."));
				if(_local3 != -1) {
					_local2 = _local2.substr(0,_local3);
				}
			}
			return _local2;
		}
		
		public function getDefaultPort() : String {
			if(_scheme == "http") {
				return "80";
			}
			if(_scheme == "ftp") {
				return "21";
			}
			if(_scheme == "file") {
				return "";
			}
			if(_scheme == "sftp") {
				return "22";
			}
			return "";
		}
		
		public function getRelation(uri:URI, caseSensitive:Boolean = true) : int {
			var _local12:Array = null;
			var _local13:Array = null;
			var _local3:String = null;
			var _local5:String = null;
			var _local7:int = 0;
			var _local4:URI = URI.resolve(this);
			var _local8:URI = URI.resolve(uri);
			if(_local4.isRelative() || _local8.isRelative()) {
				return 0;
			}
			if(_local4.isHierarchical() == false || _local8.isHierarchical() == false) {
				if(_local4.isHierarchical() == false && _local8.isHierarchical() == true || _local4.isHierarchical() == true && _local8.isHierarchical() == false) {
					return 0;
				}
				if(_local4.scheme != _local8.scheme) {
					return 0;
				}
				if(_local4.nonHierarchical != _local8.nonHierarchical) {
					return 0;
				}
				return 2;
			}
			if(_local4.scheme != _local8.scheme) {
				return 0;
			}
			if(_local4.authority != _local8.authority) {
				return 0;
			}
			var _local6:String = _local4.port;
			var _local11:String = _local8.port;
			if(_local6 == "") {
				_local6 = _local4.getDefaultPort();
			}
			if(_local11 == "") {
				_local11 = _local8.getDefaultPort();
			}
			if(_local6 != _local11) {
				return 0;
			}
			if(compareStr(_local4.path,_local8.path,caseSensitive)) {
				return 2;
			}
			var _local10:String = _local4.path;
			var _local9:String = _local8.path;
			if((_local10 == "/" || _local9 == "/") && (_local10 == "" || _local9 == "")) {
				return 2;
			}
			_local13 = _local10.split("/");
			_local12 = _local9.split("/");
			if(_local13.length > _local12.length) {
				_local3 = _local12[_local12.length - 1];
				if(_local3.length > 0) {
					return 0;
				}
				_local12.pop();
				_local7 = 0;
				while(_local7 < _local12.length) {
					_local5 = _local13[_local7];
					_local3 = _local12[_local7];
					if(compareStr(_local5,_local3,caseSensitive) == false) {
						return 0;
					}
					_local7++;
				}
				return 1;
			}
			if(_local13.length < _local12.length) {
				_local5 = _local13[_local13.length - 1];
				if(_local5.length > 0) {
					return 0;
				}
				_local13.pop();
				_local7 = 0;
				while(_local7 < _local13.length) {
					_local5 = _local13[_local7];
					_local3 = _local12[_local7];
					if(compareStr(_local5,_local3,caseSensitive) == false) {
						return 0;
					}
					_local7++;
				}
				return 3;
			}
			return 0;
		}
		
		public function getCommonParent(uri:URI, caseSensitive:Boolean = true) : URI {
			var _local6:String = null;
			var _local5:String = null;
			var _local4:URI = URI.resolve(this);
			var _local3:URI = URI.resolve(uri);
			if(!_local4.isAbsolute() || !_local3.isAbsolute() || _local4.isHierarchical() == false || _local3.isHierarchical() == false) {
				return null;
			}
			var _local7:int = _local4.getRelation(_local3);
			if(_local7 == 0) {
				return null;
			}
			_local4.chdir(".");
			_local3.chdir(".");
			while(true) {
				_local7 = _local4.getRelation(_local3,caseSensitive);
				if(_local7 == 2 || _local7 == 3) {
					break;
				}
				_local5 = _local4.toString();
				_local4.chdir("..");
				_local6 = _local4.toString();
				if(_local5 == _local6) {
					break;
				}
			}
			return _local4;
		}
		
		public function chdir(reference:String, escape:Boolean = false) : Boolean {
			var _local8:URI = null;
			var _local4:String = null;
			var _local11:String = null;
			var _local12:String = null;
			var _local14:Array = null;
			var _local17:Array = null;
			var _local13:String = null;
			var _local7:int = 0;
			var _local10:* = reference;
			if(escape) {
				_local10 = URI.escapeChars(reference);
			}
			if(_local10 == "") {
				return true;
			}
			if(_local10.substr(0,2) == "//") {
				_local4 = this.scheme + ":" + _local10;
				return constructURI(_local4);
			}
			if(_local10.charAt(0) == "?") {
				_local10 = "./" + _local10;
			}
			_local8 = new URI(_local10);
			if(_local8.isAbsolute() || _local8.isHierarchical() == false) {
				copyURI(_local8);
				return true;
			}
			var _local5:Boolean = false;
			var _local15:Boolean = false;
			var _local6:Boolean = false;
			var _local3:Boolean = false;
			var _local16:Boolean = false;
			_local12 = this.path;
			_local11 = _local8.path;
			if(_local12.length > 0) {
				_local17 = _local12.split("/");
			} else {
				_local17 = [];
			}
			if(_local11.length > 0) {
				_local14 = _local11.split("/");
			} else {
				_local14 = [];
			}
			if(_local17.length > 0 && _local17[0] == "") {
				_local6 = true;
				_local17.shift();
			}
			if(_local17.length > 0 && _local17[_local17.length - 1] == "") {
				_local5 = true;
				_local17.pop();
			}
			if(_local14.length > 0 && _local14[0] == "") {
				_local3 = true;
				_local14.shift();
			}
			if(_local14.length > 0 && _local14[_local14.length - 1] == "") {
				_local15 = true;
				_local14.pop();
			}
			if(_local3) {
				this.path = _local8.path;
				this.queryRaw = _local8.queryRaw;
				this.fragment = _local8.fragment;
				return true;
			}
			if(_local14.length == 0 && _local8.query == "") {
				this.fragment = _local8.fragment;
				return true;
			}
			if(_local5 == false && _local17.length > 0) {
				_local17.pop();
			}
			this.queryRaw = _local8.queryRaw;
			this.fragment = _local8.fragment;
			_local17 = _local17.concat(_local14);
			_local7 = 0;
			while(_local7 < _local17.length) {
				_local13 = _local17[_local7];
				_local16 = false;
				if(_local13 == ".") {
					_local17.splice(_local7,1);
					_local7 -= 1;
					_local16 = true;
				} else if(_local13 == "..") {
					if(_local7 >= 1) {
						if(_local17[_local7 - 1] != "..") {
							_local17.splice(_local7 - 1,2);
							_local7 -= 2;
						}
					} else if(!isRelative()) {
						_local17.splice(_local7,1);
						_local7 -= 1;
					}
					_local16 = true;
				}
				_local7++;
			}
			var _local9:String = "";
			_local15 ||= _local16;
			_local9 = joinPath(_local17,_local6,_local15);
			this.path = _local9;
			return true;
		}
		
		protected function joinPath(parts:Array, isAbs:Boolean, isDir:Boolean) : String {
			var _local4:int = 0;
			var _local5:String = "";
			_local4 = 0;
			while(_local4 < parts.length) {
				if(_local5.length > 0) {
					_local5 += "/";
				}
				_local5 += parts[_local4];
				_local4++;
			}
			if(isDir && _local5.length > 0) {
				_local5 += "/";
			}
			if(isAbs) {
				_local5 = "/" + _local5;
			}
			return _local5;
		}
		
		public function makeAbsoluteURI(base_uri:URI) : Boolean {
			if(isAbsolute() || base_uri.isRelative()) {
				return false;
			}
			var _local2:URI = new URI();
			_local2.copyURI(base_uri);
			if(_local2.chdir(toString()) == false) {
				return false;
			}
			copyURI(_local2);
			return true;
		}
		
		public function makeRelativeURI(base_uri:URI, caseSensitive:Boolean = true) : Boolean {
			var _local10:Array = null;
			var _local13:Array = null;
			var _local3:String = null;
			var _local7:String = null;
			var _local4:String = null;
			var _local5:int = 0;
			var _local12:URI = new URI();
			_local12.copyURI(base_uri);
			var _local9:Array = [];
			var _local14:String = this.path;
			var _local15:String = this.queryRaw;
			var _local11:String = this.fragment;
			var _local6:Boolean = false;
			var _local16:Boolean = false;
			if(isRelative()) {
				return true;
			}
			if(_local12.isRelative()) {
				return false;
			}
			if(isOfType(base_uri.scheme) == false || this.authority != base_uri.authority) {
				return false;
			}
			_local16 = isDirectory();
			_local12.chdir(".");
			_local13 = _local14.split("/");
			_local10 = _local12.path.split("/");
			if(_local13.length > 0 && _local13[0] == "") {
				_local13.shift();
			}
			if(_local13.length > 0 && _local13[_local13.length - 1] == "") {
				_local16 = true;
				_local13.pop();
			}
			if(_local10.length > 0 && _local10[0] == "") {
				_local10.shift();
			}
			if(_local10.length > 0 && _local10[_local10.length - 1] == "") {
				_local10.pop();
			}
			while(_local10.length > 0) {
				if(_local13.length == 0) {
					break;
				}
				_local4 = _local13[0];
				_local3 = _local10[0];
				if(!compareStr(_local4,_local3,caseSensitive)) {
					break;
				}
				_local13.shift();
				_local10.shift();
			}
			var _local8:String = "..";
			_local5 = 0;
			while(_local5 < _local10.length) {
				_local9.push(_local8);
				_local5++;
			}
			_local9 = _local9.concat(_local13);
			_local7 = joinPath(_local9,false,_local16);
			if(_local7.length == 0) {
				_local7 = "./";
			}
			setParts("","","",_local7,_local15,_local11);
			return true;
		}
		
		public function unknownToURI(unknown:String, defaultScheme:String = "http") : Boolean {
			var _local4:String = null;
			var _local3:String = null;
			if(unknown.length == 0) {
				this.initialize();
				return false;
			}
			unknown = unknown.replace(/\\/g,"/");
			if(unknown.length >= 2) {
				_local4 = unknown.substr(0,2);
				if(_local4 == "//") {
					unknown = defaultScheme + ":" + unknown;
				}
			}
			if(unknown.length >= 3) {
				_local4 = unknown.substr(0,3);
				if(_local4 == "://") {
					unknown = defaultScheme + unknown;
				}
			}
			var _local5:URI = new URI(unknown);
			if(_local5.isHierarchical() == false) {
				if(_local5.scheme == "unknown") {
					this.initialize();
					return false;
				}
				copyURI(_local5);
				forceEscape();
				return true;
			}
			if(_local5.scheme != "unknown" && _local5.scheme.length > 0) {
				if(_local5.authority.length > 0 || _local5.scheme == "file") {
					copyURI(_local5);
					forceEscape();
					return true;
				}
				if(_local5.authority.length == 0 && _local5.path.length == 0) {
					setParts(_local5.scheme,"","","","","");
					return false;
				}
			} else {
				_local3 = _local5.path;
				if(_local3 == ".." || _local3 == "." || _local3.length >= 3 && _local3.substr(0,3) == "../" || _local3.length >= 2 && _local3.substr(0,2) == "./") {
					copyURI(_local5);
					forceEscape();
					return true;
				}
			}
			_local5 = new URI(defaultScheme + "://" + unknown);
			if(_local5.scheme.length > 0 && _local5.authority.length > 0) {
				copyURI(_local5);
				forceEscape();
				return true;
			}
			this.initialize();
			return false;
		}
	}
}

