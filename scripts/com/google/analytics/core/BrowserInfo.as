package com.google.analytics.core {
	import com.google.analytics.utils.Environment;
	import com.google.analytics.utils.Variables;
	import com.google.analytics.v4.Configuration;
	import core.version;
	
	public class BrowserInfo {
		private var _config:Configuration;
		
		private var _info:Environment;
		
		public function BrowserInfo(config:Configuration, info:Environment) {
			super();
			this._config = config;
			this._info = info;
		}
		
		public function get utmcs() : String {
			return this._info.languageEncoding;
		}
		
		public function get utmsr() : String {
			return this._info.screenWidth + "x" + this._info.screenHeight;
		}
		
		public function get utmsc() : String {
			return this._info.screenColorDepth + "-bit";
		}
		
		public function get utmul() : String {
			return this._info.language.toLowerCase();
		}
		
		public function get utmje() : String {
			return "0";
		}
		
		public function get utmfl() : String {
			var _local1:version = null;
			if(this._config.detectFlash) {
				_local1 = this._info.flashVersion;
				return _local1.major + "." + _local1.minor + " r" + _local1.build;
			}
			return "-";
		}
		
		public function toVariables() : Variables {
			var _local1:Variables = new Variables();
			_local1.URIencode = true;
			_local1.utmcs = this.utmcs;
			_local1.utmsr = this.utmsr;
			_local1.utmsc = this.utmsc;
			_local1.utmul = this.utmul;
			_local1.utmje = this.utmje;
			_local1.utmfl = this.utmfl;
			return _local1;
		}
		
		public function toURLString() : String {
			var _local1:Variables = this.toVariables();
			return _local1.toString();
		}
	}
}

