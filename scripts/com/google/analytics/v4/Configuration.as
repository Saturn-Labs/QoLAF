package com.google.analytics.v4 {
	import com.google.analytics.campaign.CampaignKey;
	import com.google.analytics.core.Domain;
	import com.google.analytics.core.DomainNameMode;
	import com.google.analytics.core.Organic;
	import com.google.analytics.core.ServerOperationMode;
	import com.google.analytics.debug.DebugConfiguration;
	import com.google.analytics.utils.Timespan;
	
	public class Configuration {
		private var _debug:DebugConfiguration;
		
		private var _version:String = "4.3as";
		
		private var _sampleRate:Number = 1;
		
		private var _trackingLimitPerSession:int = 500;
		
		private var _domain:Domain;
		
		private var _organic:Organic = new Organic();
		
		public var googleCsePath:String = "cse";
		
		public var googleSearchParam:String = "q";
		
		public var google:String = "google";
		
		private var _cookieName:String = "analytics";
		
		public var allowDomainHash:Boolean = true;
		
		public var allowAnchor:Boolean = false;
		
		public var allowLinker:Boolean = false;
		
		public var hasSiteOverlay:Boolean = false;
		
		public var tokenRate:Number = 0.2;
		
		public var conversionTimeout:Number = Timespan.sixmonths;
		
		public var sessionTimeout:Number = Timespan.thirtyminutes;
		
		public var maxOutboundLinkExamined:Number = 1000;
		
		public var tokenCliff:int = 10;
		
		public var bucketCapacity:Number = 10;
		
		public var detectClientInfo:Boolean = true;
		
		public var detectFlash:Boolean = true;
		
		public var detectTitle:Boolean = true;
		
		public var campaignKey:CampaignKey = new CampaignKey();
		
		public var campaignTracking:Boolean = true;
		
		public var isTrackOutboundSubdomains:Boolean = false;
		
		public var serverMode:ServerOperationMode = ServerOperationMode.remote;
		
		public var localGIFpath:String = "/__utm.gif";
		
		public var remoteGIFpath:String = "http://www.google-analytics.com/__utm.gif";
		
		public var secureRemoteGIFpath:String = "https://ssl.google-analytics.com/__utm.gif";
		
		public var cookiePath:String = "/";
		
		public var transactionFieldDelim:String = "|";
		
		public var domainName:String = "";
		
		public var allowLocalTracking:Boolean = true;
		
		public function Configuration(debug:DebugConfiguration = null) {
			super();
			this._debug = debug;
			this._domain = new Domain(DomainNameMode.auto,"",this._debug);
			this.serverMode = ServerOperationMode.remote;
			this._initOrganicSources();
		}
		
		private function _initOrganicSources() : void {
			this.addOrganicSource(this.google,this.googleSearchParam);
			this.addOrganicSource("yahoo","p");
			this.addOrganicSource("msn","q");
			this.addOrganicSource("aol","query");
			this.addOrganicSource("aol","encquery");
			this.addOrganicSource("lycos","query");
			this.addOrganicSource("ask","q");
			this.addOrganicSource("altavista","q");
			this.addOrganicSource("netscape","query");
			this.addOrganicSource("cnn","query");
			this.addOrganicSource("looksmart","qt");
			this.addOrganicSource("about","terms");
			this.addOrganicSource("mamma","query");
			this.addOrganicSource("alltheweb","q");
			this.addOrganicSource("gigablast","q");
			this.addOrganicSource("voila","rdata");
			this.addOrganicSource("virgilio","qs");
			this.addOrganicSource("live","q");
			this.addOrganicSource("baidu","wd");
			this.addOrganicSource("alice","qs");
			this.addOrganicSource("yandex","text");
			this.addOrganicSource("najdi","q");
			this.addOrganicSource("aol","q");
			this.addOrganicSource("club-internet","q");
			this.addOrganicSource("mama","query");
			this.addOrganicSource("seznam","q");
			this.addOrganicSource("search","q");
			this.addOrganicSource("wp","szukaj");
			this.addOrganicSource("onet","qt");
			this.addOrganicSource("netsprint","q");
			this.addOrganicSource("google.interia","q");
			this.addOrganicSource("szukacz","q");
			this.addOrganicSource("yam","k");
			this.addOrganicSource("pchome","q");
			this.addOrganicSource("kvasir","searchExpr");
			this.addOrganicSource("sesam","q");
			this.addOrganicSource("ozu","q");
			this.addOrganicSource("terra","query");
			this.addOrganicSource("nostrum","query");
			this.addOrganicSource("mynet","q");
			this.addOrganicSource("ekolay","q");
			this.addOrganicSource("search.ilse","search_for");
		}
		
		public function get cookieName() : String {
			return this._cookieName;
		}
		
		public function get version() : String {
			return this._version;
		}
		
		public function get domain() : Domain {
			return this._domain;
		}
		
		public function get organic() : Organic {
			return this._organic;
		}
		
		public function get sampleRate() : Number {
			return this._sampleRate;
		}
		
		public function set sampleRate(value:Number) : void {
			if(value <= 0) {
				value = 0.1;
			}
			if(value > 1) {
				value = 1;
			}
			value = Number(value.toFixed(2));
			this._sampleRate = value;
		}
		
		public function get trackingLimitPerSession() : int {
			return this._trackingLimitPerSession;
		}
		
		public function addOrganicSource(engine:String, keyword:String) : void {
			try {
				this._organic.addSource(engine,keyword);
			}
			catch(e:Error) {
				if(Boolean(_debug) && _debug.active) {
					_debug.warning(e.message);
				}
			}
		}
	}
}

