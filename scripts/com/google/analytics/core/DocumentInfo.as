package com.google.analytics.core {
	import com.google.analytics.external.AdSenseGlobals;
	import com.google.analytics.utils.Environment;
	import com.google.analytics.utils.Variables;
	import com.google.analytics.v4.Configuration;
	
	public class DocumentInfo {
		private var _config:Configuration;
		
		private var _info:Environment;
		
		private var _adSense:AdSenseGlobals;
		
		private var _pageURL:String;
		
		private var _utmr:String;
		
		public function DocumentInfo(config:Configuration, info:Environment, formatedReferrer:String, pageURL:String = null, adSense:AdSenseGlobals = null) {
			super();
			this._config = config;
			this._info = info;
			this._utmr = formatedReferrer;
			this._pageURL = pageURL;
			this._adSense = adSense;
		}
		
		private function _generateHitId() : Number {
			var _local1:Number = NaN;
			if(Boolean(this._adSense.hid) && this._adSense.hid != "") {
				_local1 = Number(this._adSense.hid);
			} else {
				_local1 = Math.round(Math.random() * 0x7fffffff);
				this._adSense.hid = String(_local1);
			}
			return _local1;
		}
		
		private function _renderPageURL(pageURL:String = "") : String {
			var _local2:String = this._info.locationPath;
			var _local3:String = this._info.locationSearch;
			if(!pageURL || pageURL == "") {
				pageURL = _local2 + unescape(_local3);
				if(pageURL == "") {
					pageURL = "/";
				}
			}
			return pageURL;
		}
		
		public function get utmdt() : String {
			return this._info.documentTitle;
		}
		
		public function get utmhid() : String {
			return String(this._generateHitId());
		}
		
		public function get utmr() : String {
			if(!this._utmr) {
				return "-";
			}
			return this._utmr;
		}
		
		public function get utmp() : String {
			return this._renderPageURL(this._pageURL);
		}
		
		public function toVariables() : Variables {
			var _local1:Variables = new Variables();
			_local1.URIencode = true;
			if(this._config.detectTitle && this.utmdt != "") {
				_local1.utmdt = this.utmdt;
			}
			_local1.utmhid = this.utmhid;
			_local1.utmr = this.utmr;
			_local1.utmp = this.utmp;
			return _local1;
		}
		
		public function toURLString() : String {
			var _local1:Variables = this.toVariables();
			return _local1.toString();
		}
	}
}

