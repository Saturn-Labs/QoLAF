package com.google.analytics.utils {
	public function getDomainFromHost(host:String) : String {
		var _local2:Array = null;
		if(host != "" && host.indexOf(".") > -1) {
			_local2 = host.split(".");
			switch(_local2.length) {
				case 2:
					return host;
				case 3:
					if(_local2[1] == "co") {
						return host;
					}
					_local2.shift();
					return _local2.join(".");
					break;
				case 4:
					_local2.shift();
					return _local2.join(".");
			}
		}
		return "";
	}
}

