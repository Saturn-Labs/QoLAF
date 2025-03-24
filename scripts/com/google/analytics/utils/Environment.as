package com.google.analytics.utils {
	import com.google.analytics.core.ga_internal;
	import com.google.analytics.debug.DebugConfiguration;
	import com.google.analytics.external.HTMLDOM;
	import core.strings.userAgent;
	import core.uri;
	import core.version;
	import flash.display.DisplayObject;
	import flash.system.Capabilities;
	import flash.system.Security;
	import flash.system.System;
	
	use namespace ga_internal;
	
	public class Environment {
		private var _debug:DebugConfiguration;
		
		private var _dom:HTMLDOM;
		
		private var _protocol:String;
		
		private var _appName:String;
		
		private var _appVersion:version;
		
		private var _userAgent:String;
		
		private var _url:String;
		
		private var _display:DisplayObject;
		
		public function Environment(url:String = "", app:String = "", version:String = "", debug:DebugConfiguration = null, dom:HTMLDOM = null, display:DisplayObject = null) {
			var _local7:version = null;
			super();
			if(app == "") {
				if(this.isAIR()) {
					app = "AIR";
				} else {
					app = "Flash";
				}
			}
			if(version == "") {
				_local7 = this.flashVersion;
			} else {
				_local7 = getVersionFromString(version);
			}
			this._url = url;
			this._appName = app;
			this._appVersion = _local7;
			this._debug = debug;
			this._dom = dom;
			this._display = display;
		}
		
		private function _findProtocol() : void {
			var _local1:uri = null;
			this._protocol = "";
			if(this._url != "") {
				_local1 = new uri(this._url);
				this._protocol = _local1.scheme;
			}
		}
		
		public function get appName() : String {
			return this._appName;
		}
		
		public function set appName(value:String) : void {
			this._appName = value;
			this._defineUserAgent();
		}
		
		public function get appVersion() : version {
			return this._appVersion;
		}
		
		public function set appVersion(value:version) : void {
			this._appVersion = value;
			this._defineUserAgent();
		}
		
		ga_internal function set url(value:String) : void {
			this._url = value;
		}
		
		public function get locationSWFPath() : String {
			return this._url;
		}
		
		public function get referrer() : String {
			var _local1:String = this._dom.referrer;
			if(_local1) {
				return _local1;
			}
			if(this.protocol == "file") {
				return "localhost";
			}
			return "";
		}
		
		public function get documentTitle() : String {
			var _local1:String = this._dom.title;
			if(_local1) {
				return _local1;
			}
			return "";
		}
		
		public function get documentDomainName() : String {
			var _host:String = null;
			if(this.protocol == "http" || this.protocol == "https") {
				if(this._dom.inIframe) {
					_host = !!this._dom.parentHost ? this._dom.parentHost.toLowerCase() : "unknown_host";
				} else {
					_host = !!this._dom.host ? this._dom.host.toLowerCase() : "unknown_host";
				}
				if(_host == "unknown_host" && this._display != null && this._display.loaderInfo != null) {
					try {
						_host = new uri(this._display.loaderInfo.parameters["qs_windowLocation"]).host;
					}
					catch(err:Error) {
						_host = "";
					}
				}
				if(_host) {
					return _host;
				}
			}
			return "";
		}
		
		public function get domainName() : String {
			var _local1:uri = null;
			if(this.protocol == "http" || this.protocol == "https") {
				_local1 = new uri(this._url.toLowerCase());
				return _local1.host;
			}
			if(this.protocol == "file") {
				return "localhost";
			}
			return "";
		}
		
		public function isAIR() : Boolean {
			return Security.sandboxType == "application";
		}
		
		public function isInHTML() : Boolean {
			return Capabilities.playerType == "PlugIn";
		}
		
		public function get locationPath() : String {
			var _local1:String = this._dom.inIframe ? this._dom.parentPathname : this._dom.pathname;
			if(_local1) {
				return _local1;
			}
			return "";
		}
		
		public function get locationSearch() : String {
			var _local1:String = this._dom.inIframe ? this._dom.parentSearch : this._dom.search;
			if(_local1) {
				return _local1;
			}
			return "";
		}
		
		public function get flashVersion() : version {
			return getVersionFromString(Capabilities.version.split(" ")[1],",");
		}
		
		public function get language() : String {
			var _local1:String = this._dom.language;
			var _local2:String = Capabilities.language;
			if(_local1) {
				if(_local1.length > _local2.length && _local1.substr(0,_local2.length) == _local2) {
					_local2 = _local1;
				}
			}
			return _local2;
		}
		
		public function get languageEncoding() : String {
			var _local1:String = null;
			if(System.useCodePage) {
				_local1 = this._dom.characterSet;
				if(_local1) {
					return _local1;
				}
				return "-";
			}
			return "UTF-8";
		}
		
		public function get operatingSystem() : String {
			return Capabilities.os;
		}
		
		public function get playerType() : String {
			return Capabilities.playerType;
		}
		
		public function get platform() : String {
			var _local1:String = Capabilities.manufacturer;
			return _local1.split("Adobe ")[1];
		}
		
		public function get protocol() : String {
			if(!this._protocol) {
				this._findProtocol();
			}
			return this._protocol;
		}
		
		public function get screenHeight() : Number {
			return Capabilities.screenResolutionY;
		}
		
		public function get screenWidth() : Number {
			return Capabilities.screenResolutionX;
		}
		
		public function get screenColorDepth() : String {
			var _local1:String = null;
			switch(Capabilities.screenColor) {
				case "bw":
					_local1 = "1";
					break;
				case "gray":
					_local1 = "2";
					break;
				case "color":
				default:
					_local1 = "24";
			}
			var _local2:String = this._dom.colorDepth;
			if(_local2) {
				_local1 = _local2;
			}
			return _local1;
		}
		
		private function _defineUserAgent() : void {
			this._userAgent = userAgent(this.appName + "/" + this.appVersion.toString(4));
		}
		
		public function get userAgent() : String {
			if(!this._userAgent) {
				this._defineUserAgent();
			}
			return this._userAgent;
		}
		
		public function set userAgent(custom:String) : void {
			this._userAgent = custom;
		}
	}
}

