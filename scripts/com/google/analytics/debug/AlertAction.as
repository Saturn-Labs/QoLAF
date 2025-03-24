package com.google.analytics.debug {
	public class AlertAction {
		private var _callback:*;
		
		public var activator:String;
		
		public var container:Alert;
		
		public var name:String;
		
		public function AlertAction(name:String, activator:String, callback:*) {
			super();
			this.name = name;
			this.activator = activator;
			this._callback = callback;
		}
		
		public function execute() : void {
			if(this._callback) {
				if(this._callback is Function) {
					(this._callback as Function)();
				} else if(this._callback is String) {
					this.container[this._callback]();
				}
			}
		}
	}
}

