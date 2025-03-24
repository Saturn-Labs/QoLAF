package com.google.analytics {
	import core.version;
	
	public class API {
		public static var version:core.version = new core.version();
		
		version.major = 1;
		version.minor = 1;
		version.build = 0;
		version.revision = "$Rev: 452 $ ".split(" ")[1];
		
		public function API() {
			super();
		}
	}
}

