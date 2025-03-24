package com.google.analytics.utils {
	import core.version;
	
	public function getVersionFromString(v:String, separator:String = ".") : version {
		var _local4:Array = null;
		var _local3:version = new version();
		if(v == "" || v == null) {
			return _local3;
		}
		if(v.indexOf(separator) > -1) {
			_local4 = v.split(separator);
			_local3.major = parseInt(_local4[0]);
			_local3.minor = parseInt(_local4[1]);
			_local3.build = parseInt(_local4[2]);
			_local3.revision = parseInt(_local4[3]);
		} else {
			_local3.major = parseInt(v);
		}
		return _local3;
	}
}

