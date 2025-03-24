package com.google.analytics.utils {
	public function getSubDomainFromHost(host:String) : String {
		var _local2:String = getDomainFromHost(host);
		if(_local2 != "" && _local2 != host) {
			return host.split("." + _local2).join("");
		}
		return "";
	}
}

