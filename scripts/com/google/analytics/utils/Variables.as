package com.google.analytics.utils {
	import flash.net.URLVariables;
	
	public dynamic class Variables {
		public var URIencode:Boolean;
		
		public var pre:Array = [];
		
		public var post:Array = [];
		
		public var sort:Boolean = true;
		
		public function Variables(source:String = null, pre:Array = null, post:Array = null) {
			super();
			if(source) {
				this.decode(source);
			}
			if(pre) {
				this.pre = pre;
			}
			if(post) {
				this.post = post;
			}
		}
		
		private function _join(vars:Variables) : void {
			var _local2:String = null;
			if(!vars) {
				return;
			}
			for(_local2 in vars) {
				this[_local2] = vars[_local2];
			}
		}
		
		public function decode(source:String) : void {
			var _local2:Array = null;
			var _local3:String = null;
			var _local4:String = null;
			var _local5:String = null;
			var _local6:Array = null;
			if(source == "") {
				return;
			}
			if(source.charAt(0) == "?") {
				source = source.substr(1,source.length);
			}
			if(source.indexOf("&") > -1) {
				_local2 = source.split("&");
			} else {
				_local2 = [source];
			}
			var _local7:int = 0;
			while(_local7 < _local2.length) {
				_local3 = _local2[_local7];
				if(_local3.indexOf("=") > -1) {
					_local6 = _local3.split("=");
					_local4 = _local6[0];
					_local5 = decodeURI(_local6[1]);
					this[_local4] = _local5;
				}
				_local7++;
			}
		}
		
		public function join(... rest) : void {
			var _local2:int = int(rest.length);
			var _local3:int = 0;
			while(_local3 < _local2) {
				if(rest[_local3] is Variables) {
					this._join(rest[_local3]);
				}
				_local3++;
			}
		}
		
		public function toString() : String {
			var _local2:String = null;
			var _local3:String = null;
			var _local4:String = null;
			var _local5:int = 0;
			var _local6:int = 0;
			var _local7:String = null;
			var _local8:String = null;
			var _local1:Array = [];
			for(_local3 in this) {
				_local2 = this[_local3];
				if(this.URIencode) {
					_local2 = encodeURIComponent(_local2);
				}
				_local1.push(_local3 + "=" + _local2);
			}
			if(this.sort) {
				_local1.sort();
			}
			if(this.pre.length > 0) {
				this.pre.reverse();
				_local5 = 0;
				while(_local5 < this.pre.length) {
					_local7 = this.pre[_local5];
					_local6 = 0;
					while(_local6 < _local1.length) {
						_local4 = _local1[_local6];
						if(_local4.indexOf(_local7) == 0) {
							_local1.unshift(_local1.splice(_local6,1)[0]);
						}
						_local6++;
					}
					_local5++;
				}
				this.pre.reverse();
			}
			if(this.post.length > 0) {
				_local5 = 0;
				while(_local5 < this.post.length) {
					_local8 = this.post[_local5];
					_local6 = 0;
					while(_local6 < _local1.length) {
						_local4 = _local1[_local6];
						if(_local4.indexOf(_local8) == 0) {
							_local1.push(_local1.splice(_local6,1)[0]);
						}
						_local6++;
					}
					_local5++;
				}
			}
			return _local1.join("&");
		}
		
		public function toURLVariables() : URLVariables {
			var _local2:String = null;
			var _local1:URLVariables = new URLVariables();
			for(_local2 in this) {
				_local1[_local2] = this[_local2];
			}
			return _local1;
		}
	}
}

