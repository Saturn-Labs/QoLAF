package com.google.analytics.core {
	import com.google.analytics.v4.GoogleAnalyticsAPI;
	
	public class EventTracker {
		private var _parent:GoogleAnalyticsAPI;
		
		public var name:String;
		
		public function EventTracker(name:String, parent:GoogleAnalyticsAPI) {
			super();
			this.name = name;
			this._parent = parent;
		}
		
		public function trackEvent(action:String, label:String = null, value:Number = NaN) : Boolean {
			return this._parent.trackEvent(this.name,action,label,value);
		}
	}
}

