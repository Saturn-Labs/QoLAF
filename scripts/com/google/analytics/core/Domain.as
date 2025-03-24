package com.google.analytics.core {
	import com.google.analytics.debug.DebugConfiguration;
	import com.google.analytics.debug.VisualDebugMode;
	
	public class Domain {
		private var _mode:DomainNameMode;
		
		private var _name:String;
		
		private var _debug:DebugConfiguration;
		
		public function Domain(mode:DomainNameMode = null, name:String = "", debug:DebugConfiguration = null) {
			super();
			this._debug = debug;
			if(mode == null) {
				mode = DomainNameMode.auto;
			}
			this._mode = mode;
			if(mode == DomainNameMode.custom) {
				this.name = name;
			} else {
				this._name = name;
			}
		}
		
		public function get mode() : DomainNameMode {
			return this._mode;
		}
		
		public function set mode(value:DomainNameMode) : void {
			this._mode = value;
			if(this._mode == DomainNameMode.none) {
				this._name = "";
			}
		}
		
		public function get name() : String {
			return this._name;
		}
		
		public function set name(value:String) : void {
			if(value.charAt(0) != "." && Boolean(this._debug)) {
				this._debug.warning("missing leading period \".\", cookie will only be accessible on " + value,VisualDebugMode.geek);
			}
			this._name = value;
		}
	}
}

