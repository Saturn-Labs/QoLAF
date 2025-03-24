package com.google.analytics.core {
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	
	public class RequestObject {
		public var start:int;
		
		public var end:int;
		
		public var request:URLRequest;
		
		public function RequestObject(request:URLRequest) {
			super();
			this.start = getTimer();
			this.request = request;
		}
		
		public function get duration() : int {
			if(!this.hasCompleted()) {
				return 0;
			}
			return this.end - this.start;
		}
		
		public function complete() : void {
			this.end = getTimer();
		}
		
		public function hasCompleted() : Boolean {
			return this.end > 0;
		}
		
		public function toString() : String {
			var _local1:Array = [];
			_local1.push("duration: " + this.duration + "ms");
			_local1.push("url: " + this.request.url);
			return "{ " + _local1.join(", ") + " }";
		}
	}
}

