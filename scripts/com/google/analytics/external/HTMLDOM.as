package com.google.analytics.external {
	import com.adobe.net.URI;
	import com.google.analytics.debug.DebugConfiguration;
	
	public class HTMLDOM extends JavascriptProxy {
		public static var cache_properties_js:XML = <script>
            <![CDATA[
                    function()
                    {
                        var obj = {};
                            obj.host         = document.location.host;
                            obj.language     = navigator.language ? navigator.language : navigator.browserLanguage;
                            obj.characterSet = document.characterSet ? document.characterSet : document.charset;
                            obj.colorDepth   = window.screen.colorDepth;
                            obj.location     = document.location.toString();
                            obj.pathname     = document.location.pathname;
                            obj.protocol     = document.location.protocol;
                            obj.search       = document.location.search;
                            obj.referrer     = document.referrer;
                            obj.title        = document.title;
							obj.inIframe     = window.location != window.parent.location;

                        return obj;
                    }
                ]]>
         </script>;
		
		public static var in_iframe_js:XML = <script>
            <![CDATA[
                    function()
                    {
                        return window.location != window.parent.location;
                    }
                ]]>
         </script>;
		
		private var _host:String;
		
		private var _language:String;
		
		private var _characterSet:String;
		
		private var _colorDepth:String;
		
		private var _location:String;
		
		private var _pathname:String;
		
		private var _protocol:String;
		
		private var _search:String;
		
		private var _referrer:String;
		
		private var _title:String;
		
		private var _inIframe:Boolean;
		
		private var _parentUri:URI;
		
		private var _parentHost:String;
		
		private var _parentLocation:String;
		
		private var _parentPathname:String;
		
		private var _parentProtocol:String;
		
		private var _parentSearch:String;
		
		public function HTMLDOM(debug:DebugConfiguration) {
			super(debug);
		}
		
		public function cacheProperties() : void {
			if(!isAvailable()) {
				return;
			}
			var _local1:Object = call(cache_properties_js);
			if(_local1) {
				this._host = _local1.host;
				this._language = _local1.language;
				this._characterSet = _local1.characterSet;
				this._colorDepth = _local1.colorDepth;
				this._location = _local1.location;
				this._pathname = _local1.pathname;
				this._protocol = _local1.protocol;
				this._search = _local1.search;
				this._referrer = _local1.referrer;
				this._title = _local1.title;
				this._inIframe = _local1.inIframe;
				if(this._inIframe) {
					this._parentUri = new URI(this._referrer);
					this._parentHost = this._parentUri.authority;
					this._parentLocation = this._referrer;
					this._parentPathname = this._parentUri.path;
					this._parentProtocol = this._parentUri.scheme;
					this._parentSearch = this._parentUri.queryRaw;
				}
			}
		}
		
		public function get host() : String {
			if(this._host) {
				return this._host;
			}
			if(!isAvailable()) {
				return null;
			}
			this._host = getProperty("document.location.host");
			return this._host;
		}
		
		public function get language() : String {
			if(this._language) {
				return this._language;
			}
			if(!isAvailable()) {
				return null;
			}
			var _local1:String = getProperty("navigator.language");
			if(_local1 == null) {
				_local1 = getProperty("navigator.browserLanguage");
			}
			this._language = _local1;
			return this._language;
		}
		
		public function get characterSet() : String {
			if(this._characterSet) {
				return this._characterSet;
			}
			if(!isAvailable()) {
				return null;
			}
			var _local1:String = getProperty("document.characterSet");
			if(_local1 == null) {
				_local1 = getProperty("document.charset");
			}
			this._characterSet = _local1;
			return this._characterSet;
		}
		
		public function get colorDepth() : String {
			if(this._colorDepth) {
				return this._colorDepth;
			}
			if(!isAvailable()) {
				return null;
			}
			this._colorDepth = getProperty("window.screen.colorDepth");
			return this._colorDepth;
		}
		
		public function get location() : String {
			if(this._location) {
				return this._location;
			}
			if(!isAvailable()) {
				return null;
			}
			this._location = getPropertyString("document.location");
			return this._location;
		}
		
		public function get pathname() : String {
			if(this._pathname) {
				return this._pathname;
			}
			if(!isAvailable()) {
				return null;
			}
			this._pathname = getProperty("document.location.pathname");
			return this._pathname;
		}
		
		public function get protocol() : String {
			if(this._protocol) {
				return this._protocol;
			}
			if(!isAvailable()) {
				return null;
			}
			this._protocol = getProperty("document.location.protocol");
			return this._protocol;
		}
		
		public function get search() : String {
			if(this._search) {
				return this._search;
			}
			if(!isAvailable()) {
				return null;
			}
			this._search = getProperty("document.location.search");
			return this._search;
		}
		
		public function get referrer() : String {
			if(this._referrer) {
				return this._referrer;
			}
			if(!isAvailable()) {
				return null;
			}
			this._referrer = getProperty("document.referrer");
			return this._referrer;
		}
		
		public function get title() : String {
			if(this._title) {
				return this._title;
			}
			if(!isAvailable()) {
				return null;
			}
			this._title = getProperty("document.title");
			return this._title;
		}
		
		public function get inIframe() : Boolean {
			if(this._inIframe) {
				return this._inIframe;
			}
			if(!isAvailable()) {
				return false;
			}
			this._inIframe = call(in_iframe_js);
			return this._inIframe;
		}
		
		public function get parentUri() : URI {
			if(this._parentUri) {
				return this._parentUri;
			}
			if(!isAvailable()) {
				return null;
			}
			if(this._inIframe) {
				this._parentUri = new URI(this._referrer);
			}
			return this._parentUri;
		}
		
		public function get parentHost() : String {
			if(this._parentHost) {
				return this._parentHost;
			}
			if(!isAvailable()) {
				return null;
			}
			if(this._inIframe) {
				this._parentHost = this._parentUri.authority;
			}
			return this._parentHost;
		}
		
		public function get parentLocation() : String {
			if(this._parentLocation) {
				return this._parentLocation;
			}
			if(!isAvailable()) {
				return null;
			}
			if(this._inIframe) {
				this._parentLocation = this._referrer;
			}
			return this._parentLocation;
		}
		
		public function get parentPathname() : String {
			if(this._parentPathname) {
				return this._parentPathname;
			}
			if(!isAvailable()) {
				return null;
			}
			if(this._inIframe) {
				this._parentPathname = this._parentUri.path;
			}
			return this._parentPathname;
		}
		
		public function get parentProtocol() : String {
			if(this._parentProtocol) {
				return this._parentProtocol;
			}
			if(!isAvailable()) {
				return null;
			}
			if(this._inIframe) {
				this._parentProtocol = this._parentUri.scheme;
			}
			return this._parentProtocol;
		}
		
		public function get parentSearch() : String {
			if(this._parentSearch) {
				return this._parentSearch;
			}
			if(!isAvailable()) {
				return null;
			}
			if(this._inIframe) {
				this._parentSearch = this._parentUri.queryRaw;
			}
			return this._parentSearch;
		}
	}
}

