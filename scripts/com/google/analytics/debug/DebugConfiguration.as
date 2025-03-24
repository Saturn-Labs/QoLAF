package com.google.analytics.debug {
	import com.google.analytics.core.GIFRequest;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	
	public class DebugConfiguration {
		private var _active:Boolean = false;
		
		private var _verbose:Boolean = false;
		
		private var _visualInitialized:Boolean = false;
		
		private var _mode:VisualDebugMode = VisualDebugMode.basic;
		
		public var layout:ILayout;
		
		public var traceOutput:Boolean = false;
		
		public var javascript:Boolean = false;
		
		public var GIFRequests:Boolean = false;
		
		public var showInfos:Boolean = true;
		
		public var infoTimeout:Number = 1000;
		
		public var showWarnings:Boolean = true;
		
		public var warningTimeout:Number = 1500;
		
		public var minimizedOnStart:Boolean = false;
		
		public var showHideKey:Number = 32;
		
		public var destroyKey:Number = 8;
		
		public function DebugConfiguration() {
			super();
		}
		
		private function _initializeVisual() : void {
			if(this.layout) {
				this.layout.init();
				this._visualInitialized = true;
			}
		}
		
		private function _destroyVisual() : void {
			if(Boolean(this.layout) && this._visualInitialized) {
				this.layout.destroy();
			}
		}
		
		public function get mode() : * {
			return this._mode;
		}
		
		public function set mode(value:*) : void {
			if(value is String) {
				switch(value) {
					case "geek":
						value = VisualDebugMode.geek;
						break;
					case "advanced":
						value = VisualDebugMode.advanced;
						break;
					case "basic":
					default:
						value = VisualDebugMode.basic;
				}
			}
			this._mode = value;
		}
		
		protected function trace(message:String) : void {
			var _local7:Array = null;
			var _local8:int = 0;
			var _local2:Array = [];
			var _local3:String = "";
			var _local4:String = "";
			if(this.mode == VisualDebugMode.geek) {
				_local3 = getTimer() + " - ";
				_local4 = new Array(_local3.length).join(" ") + " ";
			}
			if(message.indexOf("\n") > -1) {
				_local7 = message.split("\n");
				_local8 = 0;
				while(_local8 < _local7.length) {
					if(_local7[_local8] != "") {
						if(_local8 == 0) {
							_local2.push(_local3 + _local7[_local8]);
						} else {
							_local2.push(_local4 + _local7[_local8]);
						}
					}
					_local8++;
				}
			} else {
				_local2.push(_local3 + message);
			}
			var _local5:int = int(_local2.length);
			var _local6:int = 0;
			while(_local6 < _local5) {
				trace(_local2[_local6]);
				_local6++;
			}
		}
		
		public function get active() : Boolean {
			return this._active;
		}
		
		public function set active(value:Boolean) : void {
			this._active = value;
			if(this._active) {
				this._initializeVisual();
			} else {
				this._destroyVisual();
			}
		}
		
		public function get verbose() : Boolean {
			return this._verbose;
		}
		
		public function set verbose(value:Boolean) : void {
			this._verbose = value;
		}
		
		private function _filter(mode:VisualDebugMode = null) : Boolean {
			return Boolean(mode) && int(mode) >= int(this.mode);
		}
		
		public function info(message:String, mode:VisualDebugMode = null) : void {
			if(this._filter(mode)) {
				return;
			}
			if(Boolean(this.layout) && this.showInfos) {
				this.layout.createInfo(message);
			}
			if(this.traceOutput) {
				this.trace(message);
			}
		}
		
		public function warning(message:String, mode:VisualDebugMode = null) : void {
			if(this._filter(mode)) {
				return;
			}
			if(Boolean(this.layout) && this.showWarnings) {
				this.layout.createWarning(message);
			}
			if(this.traceOutput) {
				this.trace("## " + message + " ##");
			}
		}
		
		public function alert(message:String) : void {
			if(this.layout) {
				this.layout.createAlert(message);
			}
			if(this.traceOutput) {
				this.trace("!! " + message + " !!");
			}
		}
		
		public function failure(message:String) : void {
			if(this.layout) {
				this.layout.createFailureAlert(message);
			}
			if(this.traceOutput) {
				this.trace("[-] " + message + " !!");
			}
		}
		
		public function success(message:String) : void {
			if(this.layout) {
				this.layout.createSuccessAlert(message);
			}
			if(this.traceOutput) {
				this.trace("[+] " + message + " !!");
			}
		}
		
		public function alertGifRequest(message:String, request:URLRequest, ref:GIFRequest) : void {
			if(this.layout) {
				this.layout.createGIFRequestAlert(message,request,ref);
			}
			if(this.traceOutput) {
				this.trace(">> " + message + " <<");
			}
		}
	}
}

