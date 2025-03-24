package core {
	public class uri {
		private var _source:String = "";
		
		private var _scheme:String = "";
		
		private var _host:String = "";
		
		private var _username:String = "";
		
		private var _password:String = "";
		
		private var _port:int = -1;
		
		private var _path:String = "";
		
		private var _query:String = "";
		
		private var _fragment:String = "";
		
		private var _r:RegExp = /\\/g;
		
		public function uri(raw:String) {
			super();
			this._source = raw;
			this._parse(raw);
		}
		
		private function _parseUnixAbsoluteFilePath(str:String) : void {
			this.scheme = "file";
			this._port = -1;
			this._fragment = "";
			this._query = "";
			this._host = "";
			this._path = "";
			if(str.substr(0,2) == "//") {
				while(str.charAt(0) == "/") {
					str = str.substr(1);
				}
				this._path = "/" + str;
			}
			if(!this._path) {
				this._path = str;
			}
		}
		
		private function _parseWindowsAbsoluteFilePath(str:String) : void {
			if(str.length > 2 && str.charAt(2) != "\\" && str.charAt(2) != "/") {
				return;
			}
			this.scheme = "file";
			this._port = -1;
			this._fragment = "";
			this._query = "";
			this._host = "";
			this._path = "/" + str.replace(this._r,"/");
		}
		
		private function _parseWindowsUNC(str:String) : void {
			this.scheme = "file";
			this._port = -1;
			this._fragment = "";
			this._query = "";
			while(str.charAt(0) == "\\") {
				str = str.substr(1);
			}
			var _local2:int = int(str.indexOf("\\"));
			if(_local2 > 0) {
				this._path = str.substring(_local2);
				this._host = str.substring(0,_local2);
			} else {
				this._host = str;
				this._path = "";
			}
			this._path = this._path.replace(this._r,"/");
		}
		
		private function _parse(str:String) : void {
			var _local5:String = null;
			var _local6:String = null;
			var _local7:String = null;
			var _local8:String = null;
			var _local9:int = 0;
			var _local10:String = null;
			var _local11:Boolean = false;
			var _local2:int = int(str.indexOf(":"));
			if(_local2 < 0) {
				if(str.charAt(0) == "/") {
					this._parseUnixAbsoluteFilePath(str);
				} else if(str.substr(0,2) == "\\\\") {
					this._parseWindowsUNC(str);
				}
				return;
			}
			if(_local2 == 1) {
				this._parseWindowsAbsoluteFilePath(str);
				return;
			}
			var _local3:RegExp = new RegExp("^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)([?]([^#]*))?(#(.*))?",null);
			var _local4:Object = _local3.exec(str);
			if(Boolean(_local4[1]) && Boolean(_local4[2])) {
				this.scheme = _local4[2];
			}
			if(_local4[3]) {
				_local5 = _local4[4];
				_local6 = "";
				if(_local5.indexOf("@") > -1) {
					_local7 = _local5.split("@")[0];
					_local6 = _local5.split("@")[1];
					if(_local7.indexOf(":") != -1) {
						this._username = _local7.split(":")[0];
						this._password = _local7.split(":")[1];
					} else {
						this._username = _local7;
					}
				} else {
					_local6 = _local5;
				}
				if(_local6.indexOf(":") > -1) {
					_local8 = _local6.split(":")[1];
					_local11 = true;
					_local9 = 0;
					while(_local9 < _local8.length) {
						_local10 = _local8.charAt(_local9);
						if(!("0" <= _local10 && _local10 <= "9")) {
							_local11 = false;
						}
						_local9++;
					}
					if(_local11) {
						_local6 = _local6.split(":")[0];
						if(Boolean(_local8) && _local8.length > 0) {
							this.port = parseInt(_local8);
						}
					}
				}
				this.host = _local6;
			}
			if(_local4[5]) {
				this.path = _local4[5];
			}
			if(_local4[6]) {
				this._query = _local4[7];
			}
			if(_local4[8]) {
				this._fragment = _local4[9];
			}
		}
		
		public function get authority() : String {
			var _local1:String = "";
			if(this.userinfo) {
				_local1 += this.userinfo + "@";
			}
			_local1 += this.host;
			if(this.host != "" && this.port > -1) {
				_local1 += ":" + this.port;
			}
			return _local1;
		}
		
		public function get fragment() : String {
			return this._fragment;
		}
		
		public function set fragment(value:String) : void {
			this._fragment = value;
		}
		
		public function get host() : String {
			return this._host;
		}
		
		public function set host(value:String) : void {
			this._host = value;
		}
		
		public function get path() : String {
			return this._path;
		}
		
		public function set path(value:String) : void {
			this._path = value;
		}
		
		public function get port() : int {
			return this._port;
		}
		
		public function set port(value:int) : void {
			this._port = value;
		}
		
		public function get scheme() : String {
			return this._scheme;
		}
		
		public function set scheme(value:String) : void {
			this._scheme = value;
		}
		
		public function get source() : String {
			return this._source;
		}
		
		public function get userinfo() : String {
			if(!this._username) {
				return "";
			}
			var _local1:String = "";
			_local1 += this._username;
			return _local1 + (":" + this._password);
		}
		
		public function get query() : String {
			return this._query;
		}
		
		public function set query(value:String) : void {
			this._query = value;
		}
		
		public function toString() : String {
			var _local1:String = "";
			if(this.scheme) {
				_local1 += this.scheme + ":";
			}
			if(this.authority) {
				_local1 += "//" + this.authority;
			}
			if(this.authority == "" && this.scheme == "file") {
				_local1 += "//";
			}
			_local1 += this.path;
			if(this.query) {
				_local1 += "?" + this.query;
			}
			if(this.fragment) {
				_local1 += "#" + this.fragment;
			}
			return _local1;
		}
		
		public function valueOf() : String {
			return this.toString();
		}
	}
}

