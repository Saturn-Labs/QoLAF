package com.google.analytics.v4 {
	import com.google.analytics.campaign.CampaignInfo;
	import com.google.analytics.campaign.CampaignManager;
	import com.google.analytics.core.BrowserInfo;
	import com.google.analytics.core.Buffer;
	import com.google.analytics.core.DocumentInfo;
	import com.google.analytics.core.DomainNameMode;
	import com.google.analytics.core.Ecommerce;
	import com.google.analytics.core.EventInfo;
	import com.google.analytics.core.EventTracker;
	import com.google.analytics.core.GIFRequest;
	import com.google.analytics.core.ServerOperationMode;
	import com.google.analytics.core.generate32bitRandom;
	import com.google.analytics.core.generateHash;
	import com.google.analytics.core.validateAccount;
	import com.google.analytics.data.X10;
	import com.google.analytics.debug.DebugConfiguration;
	import com.google.analytics.debug.VisualDebugMode;
	import com.google.analytics.ecommerce.Transaction;
	import com.google.analytics.external.AdSenseGlobals;
	import com.google.analytics.utils.Environment;
	import com.google.analytics.utils.Variables;
	import com.google.analytics.utils.getDomainFromHost;
	import com.google.analytics.utils.getSubDomainFromHost;
	import core.uri;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	public class Tracker implements GoogleAnalyticsAPI {
		private var _account:String;
		
		private var _domainHash:Number;
		
		private var _formatedReferrer:String;
		
		private var _timeStamp:Number;
		
		private var _hasInitData:Boolean = false;
		
		private var _isNewVisitor:Boolean = false;
		
		private var _noSessionInformation:Boolean = false;
		
		private var _config:Configuration;
		
		private var _debug:DebugConfiguration;
		
		private var _info:Environment;
		
		private var _buffer:Buffer;
		
		private var _gifRequest:GIFRequest;
		
		private var _adSense:AdSenseGlobals;
		
		private var _browserInfo:BrowserInfo;
		
		private var _campaignInfo:CampaignInfo;
		
		private const EVENT_TRACKER_PROJECT_ID:int = 5;
		
		private const EVENT_TRACKER_OBJECT_NAME_KEY_NUM:int = 1;
		
		private const EVENT_TRACKER_TYPE_KEY_NUM:int = 2;
		
		private const EVENT_TRACKER_LABEL_KEY_NUM:int = 3;
		
		private const EVENT_TRACKER_VALUE_VALUE_NUM:int = 1;
		
		private var _campaign:CampaignManager;
		
		private var _eventTracker:X10;
		
		private var _x10Module:X10;
		
		private var _ecom:Ecommerce;
		
		public function Tracker(account:String, config:Configuration, debug:DebugConfiguration, info:Environment, buffer:Buffer, gifRequest:GIFRequest, adSense:AdSenseGlobals, ecom:Ecommerce) {
			var _local9:String = null;
			super();
			this._account = account;
			this._config = config;
			this._debug = debug;
			this._info = info;
			this._buffer = buffer;
			this._gifRequest = gifRequest;
			this._adSense = adSense;
			this._ecom = ecom;
			if(!validateAccount(account)) {
				_local9 = "Account \"" + account + "\" is not valid.";
				this._debug.warning(_local9);
				throw new Error(_local9);
			}
		}
		
		private function _initData() : void {
			var _local1:String = null;
			var _local2:String = null;
			if(!this._hasInitData) {
				this._updateDomainName();
				this._domainHash = this._getDomainHash();
				this._timeStamp = Math.round(new Date().getTime() / 1000);
				if(this._debug.verbose) {
					_local1 = "";
					_local1 += "_initData 0";
					_local1 += "\ndomain name: " + this._config.domainName;
					_local1 += "\ndomain hash: " + this._domainHash;
					_local1 += "\ntimestamp:   " + this._timeStamp + " (" + new Date(this._timeStamp * 1000) + ")";
					this._debug.info(_local1,VisualDebugMode.geek);
				}
			}
			if(this._doTracking()) {
				this._handleCookie();
			}
			if(!this._hasInitData) {
				if(this._doTracking()) {
					this._formatedReferrer = this._formatReferrer();
					this._browserInfo = new BrowserInfo(this._config,this._info);
					this._debug.info("browserInfo: " + this._browserInfo.toURLString(),VisualDebugMode.advanced);
					if(this._config.campaignTracking) {
						this._campaign = new CampaignManager(this._config,this._debug,this._buffer,this._domainHash,this._formatedReferrer,this._timeStamp);
						this._campaignInfo = this._campaign.getCampaignInformation(this._info.locationSearch,this._noSessionInformation);
						this._debug.info("campaignInfo: " + this._campaignInfo.toURLString(),VisualDebugMode.advanced);
						this._debug.info("Search: " + this._info.locationSearch);
						this._debug.info("CampaignTrackig: " + this._buffer.utmz.campaignTracking);
					}
				}
				this._x10Module = new X10();
				this._eventTracker = new X10();
				this._hasInitData = true;
			}
			if(this._config.hasSiteOverlay) {
				this._debug.warning("Site Overlay is not supported");
			}
			if(this._debug.verbose) {
				_local2 = "";
				_local2 += "_initData (misc)";
				_local2 += "\nflash version: " + this._info.flashVersion.toString(4);
				_local2 += "\nprotocol: " + this._info.protocol;
				_local2 += "\ndefault domain name (auto): \"" + this._info.domainName + "\"";
				_local2 += "\nlanguage: " + this._info.language;
				_local2 += "\ndomain hash: " + this._getDomainHash();
				_local2 += "\nuser-agent: " + this._info.userAgent;
				this._debug.info(_local2,VisualDebugMode.geek);
			}
		}
		
		private function _handleCookie() : void {
			var _local1:String = null;
			var _local2:String = null;
			var _local3:Array = null;
			var _local4:String = null;
			if(this._config.allowLinker) {
			}
			this._buffer.createSO();
			if(this._buffer.hasUTMA() && !this._buffer.utma.isEmpty()) {
				if(!this._buffer.hasUTMB() || !this._buffer.hasUTMC()) {
					this._buffer.updateUTMA(this._timeStamp);
					this._noSessionInformation = true;
				}
				if(this._debug.verbose) {
					this._debug.info("from cookie " + this._buffer.utma.toString(),VisualDebugMode.geek);
				}
			} else {
				this._debug.info("create a new utma",VisualDebugMode.advanced);
				this._buffer.utma.domainHash = this._domainHash;
				this._buffer.utma.sessionId = this._getUniqueSessionId();
				this._buffer.utma.firstTime = this._timeStamp;
				this._buffer.utma.lastTime = this._timeStamp;
				this._buffer.utma.currentTime = this._timeStamp;
				this._buffer.utma.sessionCount = 1;
				if(this._debug.verbose) {
					this._debug.info(this._buffer.utma.toString(),VisualDebugMode.geek);
				}
				this._noSessionInformation = true;
				this._isNewVisitor = true;
			}
			if(Boolean(this._adSense.gaGlobal) && this._adSense.dh == String(this._domainHash)) {
				if(this._adSense.sid) {
					this._buffer.utma.currentTime = Number(this._adSense.sid);
					if(this._debug.verbose) {
						_local1 = "";
						_local1 += "AdSense sid found\n";
						_local1 += "Override currentTime(" + this._buffer.utma.currentTime + ") from AdSense sid(" + Number(this._adSense.sid) + ")";
						this._debug.info(_local1,VisualDebugMode.geek);
					}
				}
				if(this._isNewVisitor) {
					if(this._adSense.sid) {
						this._buffer.utma.lastTime = Number(this._adSense.sid);
						if(this._debug.verbose) {
							_local2 = "";
							_local2 += "AdSense sid found (new visitor)\n";
							_local2 += "Override lastTime(" + this._buffer.utma.lastTime + ") from AdSense sid(" + Number(this._adSense.sid) + ")";
							this._debug.info(_local2,VisualDebugMode.geek);
						}
					}
					if(this._adSense.vid) {
						_local3 = this._adSense.vid.split(".");
						this._buffer.utma.sessionId = Number(_local3[0]);
						this._buffer.utma.firstTime = Number(_local3[1]);
						if(this._debug.verbose) {
							_local4 = "";
							_local4 = _local4 + "AdSense vid found (new visitor)\n";
							_local4 = _local4 + ("Override sessionId(" + this._buffer.utma.sessionId + ") from AdSense vid(" + Number(_local3[0]) + ")\n");
							_local4 = _local4 + ("Override firstTime(" + this._buffer.utma.firstTime + ") from AdSense vid(" + Number(_local3[1]) + ")");
							this._debug.info(_local4,VisualDebugMode.geek);
						}
					}
					if(this._debug.verbose) {
						this._debug.info("AdSense modified : " + this._buffer.utma.toString(),VisualDebugMode.geek);
					}
				}
			}
			this._buffer.utmb.domainHash = this._domainHash;
			if(isNaN(this._buffer.utmb.trackCount)) {
				this._buffer.utmb.trackCount = 0;
			}
			if(isNaN(this._buffer.utmb.token)) {
				this._buffer.utmb.token = this._config.tokenCliff;
			}
			if(isNaN(this._buffer.utmb.lastTime)) {
				this._buffer.utmb.lastTime = this._buffer.utma.currentTime;
			}
			this._buffer.utmc.domainHash = this._domainHash;
			if(this._debug.verbose) {
				this._debug.info(this._buffer.utmb.toString(),VisualDebugMode.advanced);
				this._debug.info(this._buffer.utmc.toString(),VisualDebugMode.advanced);
			}
		}
		
		private function _isNotGoogleSearch() : Boolean {
			var _local1:String = this._config.domainName;
			var _local2:* = _local1.indexOf("www.google.") < 0;
			var _local3:* = _local1.indexOf(".google.") < 0;
			var _local4:* = _local1.indexOf("google.") < 0;
			var _local5:* = _local1.indexOf("google.org") > -1;
			return _local2 || _local3 || _local4 || this._config.cookiePath != "/" || _local5;
		}
		
		private function _doTracking() : Boolean {
			if(this._info.protocol != "file" && this._info.protocol != "" && this._isNotGoogleSearch()) {
				return true;
			}
			if(this._config.allowLocalTracking) {
				return true;
			}
			return false;
		}
		
		private function _updateDomainName() : void {
			var _local1:String = null;
			if(this._config.domain.mode == DomainNameMode.auto) {
				_local1 = this._info.domainName;
				if(_local1.substring(0,4) == "www.") {
					_local1 = _local1.substring(4);
				}
				this._config.domain.name = _local1;
			}
			this._config.domainName = this._config.domain.name.toLowerCase();
			this._debug.info("domain name: " + this._config.domainName,VisualDebugMode.advanced);
		}
		
		private function _formatReferrer() : String {
			var _local2:String = null;
			var _local3:uri = null;
			var _local4:uri = null;
			var _local5:String = null;
			var _local6:String = null;
			var _local7:String = null;
			var _local8:String = null;
			var _local1:String = this._info.referrer;
			if(_local1 == "" || _local1 == "localhost") {
				_local1 = "-";
			} else {
				_local2 = this._info.domainName;
				_local3 = new uri(_local1);
				_local4 = new uri("http://" + _local2);
				if(_local3.host == _local2) {
					return "-";
				}
				_local5 = getDomainFromHost(_local3.host);
				_local6 = getSubDomainFromHost(_local3.host);
				_local7 = getDomainFromHost(_local4.host);
				_local8 = getSubDomainFromHost(_local4.host);
				if(_local7 == _local5) {
					if(_local8 != _local6) {
						_local1 = "0";
					}
				}
				if(_local1.charAt(0) == "[" && _local1.charAt(_local1.length - 1) == "]") {
					_local1 = "-";
				}
			}
			this._debug.info("formated referrer: " + _local1,VisualDebugMode.advanced);
			return _local1;
		}
		
		private function _generateUserDataHash() : Number {
			var _local1:String = "";
			_local1 += this._info.appName;
			_local1 += this._info.appVersion;
			_local1 += this._info.language;
			_local1 += this._info.platform;
			_local1 += this._info.userAgent;
			_local1 += this._info.screenWidth + "x" + this._info.screenHeight + this._info.screenColorDepth;
			_local1 += this._info.referrer;
			return generateHash(_local1);
		}
		
		private function _getUniqueSessionId() : Number {
			var _local1:Number = (generate32bitRandom() ^ this._generateUserDataHash()) * 0x7fffffff;
			this._debug.info("Session ID: " + _local1,VisualDebugMode.geek);
			return _local1;
		}
		
		private function _getDomainHash() : Number {
			if(!this._config.domainName || this._config.domainName == "" || this._config.domain.mode == DomainNameMode.none) {
				this._config.domainName = "";
				return 1;
			}
			this._updateDomainName();
			if(this._config.allowDomainHash) {
				return generateHash(this._config.domainName);
			}
			return 1;
		}
		
		private function _visitCode() : Number {
			if(this._debug.verbose) {
				this._debug.info("visitCode: " + this._buffer.utma.sessionId,VisualDebugMode.geek);
			}
			return this._buffer.utma.sessionId;
		}
		
		private function _takeSample() : Boolean {
			if(this._debug.verbose) {
				this._debug.info("takeSample: (" + this._visitCode() % 10000 + ") < (" + this._config.sampleRate * 10000 + ")",VisualDebugMode.geek);
			}
			return this._visitCode() % 10000 < this._config.sampleRate * 10000;
		}
		
		public function getAccount() : String {
			this._debug.info("getAccount()");
			return this._account;
		}
		
		public function getVersion() : String {
			this._debug.info("getVersion()");
			return this._config.version;
		}
		
		public function resetSession() : void {
			this._debug.info("resetSession()");
			this._buffer.resetCurrentSession();
		}
		
		public function setSampleRate(newRate:Number) : void {
			if(newRate < 0) {
				this._debug.warning("sample rate can not be negative, ignoring value.");
			} else {
				this._config.sampleRate = newRate;
			}
			this._debug.info("setSampleRate( " + this._config.sampleRate + " )");
		}
		
		public function setSessionTimeout(newTimeout:int) : void {
			this._config.sessionTimeout = newTimeout;
			this._debug.info("setSessionTimeout( " + this._config.sessionTimeout + " )");
		}
		
		public function setVar(newVal:String) : void {
			var _local2:Variables = null;
			if(newVal != "" && this._isNotGoogleSearch()) {
				this._initData();
				this._buffer.utmv.domainHash = this._domainHash;
				this._buffer.utmv.value = encodeURI(newVal);
				if(this._debug.verbose) {
					this._debug.info(this._buffer.utmv.toString(),VisualDebugMode.geek);
				}
				this._debug.info("setVar( " + newVal + " )");
				if(this._takeSample()) {
					_local2 = new Variables();
					_local2.utmt = "var";
					this._gifRequest.send(this._account,_local2);
				}
			} else {
				this._debug.warning("setVar \"" + newVal + "\" is ignored");
			}
		}
		
		public function trackPageview(pageURL:String = "") : void {
			this._debug.info("trackPageview( " + pageURL + " )");
			if(this._doTracking()) {
				this._initData();
				this._trackMetrics(pageURL);
				this._noSessionInformation = false;
			} else {
				this._debug.warning("trackPageview( " + pageURL + " ) failed");
			}
		}
		
		private function _renderMetricsSearchVariables(pageURL:String = "") : Variables {
			var _local4:Variables = null;
			var _local2:Variables = new Variables();
			_local2.URIencode = true;
			var _local3:DocumentInfo = new DocumentInfo(this._config,this._info,this._formatedReferrer,pageURL,this._adSense);
			this._debug.info("docInfo: " + _local3.toURLString(),VisualDebugMode.geek);
			if(this._config.campaignTracking) {
				_local4 = this._campaignInfo.toVariables();
			}
			var _local5:Variables = this._browserInfo.toVariables();
			_local2.join(_local3.toVariables(),_local5,_local4);
			return _local2;
		}
		
		private function _trackMetrics(pageURL:String = "") : void {
			var _local2:Variables = null;
			var _local3:Variables = null;
			var _local4:Variables = null;
			var _local5:EventInfo = null;
			if(this._takeSample()) {
				_local2 = new Variables();
				_local2.URIencode = true;
				if(Boolean(this._x10Module) && this._x10Module.hasData()) {
					_local5 = new EventInfo(false,this._x10Module);
					_local3 = _local5.toVariables();
				}
				_local4 = this._renderMetricsSearchVariables(pageURL);
				_local2.join(_local3,_local4);
				this._gifRequest.send(this._account,_local2);
			}
		}
		
		public function setAllowAnchor(enable:Boolean) : void {
			this._config.allowAnchor = enable;
			this._debug.info("setAllowAnchor( " + this._config.allowAnchor + " )");
		}
		
		public function setCampContentKey(newCampContentKey:String) : void {
			this._config.campaignKey.UCCT = newCampContentKey;
			var _local2:String = "setCampContentKey( " + this._config.campaignKey.UCCT + " )";
			if(this._debug.mode == VisualDebugMode.geek) {
				this._debug.info(_local2 + " [UCCT]");
			} else {
				this._debug.info(_local2);
			}
		}
		
		public function setCampMediumKey(newCampMedKey:String) : void {
			this._config.campaignKey.UCMD = newCampMedKey;
			var _local2:String = "setCampMediumKey( " + this._config.campaignKey.UCMD + " )";
			if(this._debug.mode == VisualDebugMode.geek) {
				this._debug.info(_local2 + " [UCMD]");
			} else {
				this._debug.info(_local2);
			}
		}
		
		public function setCampNameKey(newCampNameKey:String) : void {
			this._config.campaignKey.UCCN = newCampNameKey;
			var _local2:String = "setCampNameKey( " + this._config.campaignKey.UCCN + " )";
			if(this._debug.mode == VisualDebugMode.geek) {
				this._debug.info(_local2 + " [UCCN]");
			} else {
				this._debug.info(_local2);
			}
		}
		
		public function setCampNOKey(newCampNOKey:String) : void {
			this._config.campaignKey.UCNO = newCampNOKey;
			var _local2:String = "setCampNOKey( " + this._config.campaignKey.UCNO + " )";
			if(this._debug.mode == VisualDebugMode.geek) {
				this._debug.info(_local2 + " [UCNO]");
			} else {
				this._debug.info(_local2);
			}
		}
		
		public function setCampSourceKey(newCampSrcKey:String) : void {
			this._config.campaignKey.UCSR = newCampSrcKey;
			var _local2:String = "setCampSourceKey( " + this._config.campaignKey.UCSR + " )";
			if(this._debug.mode == VisualDebugMode.geek) {
				this._debug.info(_local2 + " [UCSR]");
			} else {
				this._debug.info(_local2);
			}
		}
		
		public function setCampTermKey(newCampTermKey:String) : void {
			this._config.campaignKey.UCTR = newCampTermKey;
			var _local2:String = "setCampTermKey( " + this._config.campaignKey.UCTR + " )";
			if(this._debug.mode == VisualDebugMode.geek) {
				this._debug.info(_local2 + " [UCTR]");
			} else {
				this._debug.info(_local2);
			}
		}
		
		public function setCampaignTrack(enable:Boolean) : void {
			this._config.campaignTracking = enable;
			this._debug.info("setCampaignTrack( " + this._config.campaignTracking + " )");
		}
		
		public function setCookieTimeout(newDefaultTimeout:int) : void {
			this._config.conversionTimeout = newDefaultTimeout;
			this._debug.info("setCookieTimeout( " + this._config.conversionTimeout + " )");
		}
		
		public function cookiePathCopy(newPath:String) : void {
			this._debug.warning("cookiePathCopy( " + newPath + " ) not implemented");
		}
		
		public function getLinkerUrl(targetUrl:String = "", useHash:Boolean = false) : String {
			this._initData();
			this._debug.info("getLinkerUrl( " + targetUrl + ", " + useHash.toString() + " )");
			return this._buffer.getLinkerUrl(targetUrl,useHash);
		}
		
		public function link(targetUrl:String, useHash:Boolean = false) : void {
			var out:String;
			var request:URLRequest;
			this._initData();
			out = this._buffer.getLinkerUrl(targetUrl,useHash);
			request = new URLRequest(out);
			this._debug.info("link( " + [targetUrl,useHash].join(",") + " )");
			try {
				navigateToURL(request,"_top");
			}
			catch(e:Error) {
				_debug.warning("An error occured in link() msg: " + e.message);
			}
		}
		
		public function linkByPost(formObject:Object, useHash:Boolean = false) : void {
			this._debug.warning("linkByPost not implemented in AS3 mode");
		}
		
		public function setAllowHash(enable:Boolean) : void {
			this._config.allowDomainHash = enable;
			this._debug.info("setAllowHash( " + this._config.allowDomainHash + " )");
		}
		
		public function setAllowLinker(enable:Boolean) : void {
			this._config.allowLinker = enable;
			this._debug.info("setAllowLinker( " + this._config.allowLinker + " )");
		}
		
		public function setCookiePath(newCookiePath:String) : void {
			this._config.cookiePath = newCookiePath;
			this._debug.info("setCookiePath( " + this._config.cookiePath + " )");
		}
		
		public function setDomainName(newDomainName:String) : void {
			if(newDomainName == "auto") {
				this._config.domain.mode = DomainNameMode.auto;
			} else if(newDomainName == "none") {
				this._config.domain.mode = DomainNameMode.none;
			} else {
				this._config.domain.mode = DomainNameMode.custom;
				this._config.domain.name = newDomainName;
			}
			this._updateDomainName();
			this._debug.info("setDomainName( " + this._config.domainName + " )");
		}
		
		public function addItem(id:String, sku:String, name:String, category:String, price:Number, quantity:int) : void {
			var _local7:Transaction = null;
			_local7 = this._ecom.getTransaction(id);
			if(_local7 == null) {
				_local7 = this._ecom.addTransaction(id,"","","","","","","");
			}
			_local7.addItem(sku,name,category,price.toString(),quantity.toString());
			if(this._debug.active) {
				this._debug.info("addItem( " + [id,sku,name,category,price,quantity].join(", ") + " )");
			}
		}
		
		public function addTrans(orderId:String, affiliation:String, total:Number, tax:Number, shipping:Number, city:String, state:String, country:String) : void {
			this._ecom.addTransaction(orderId,affiliation,total.toString(),tax.toString(),shipping.toString(),city,state,country);
			if(this._debug.active) {
				this._debug.info("addTrans( " + [orderId,affiliation,total,tax,shipping,city,state,country].join(", ") + " );");
			}
		}
		
		public function trackTrans() : void {
			var _local1:Number = NaN;
			var _local2:Number = NaN;
			var _local4:Transaction = null;
			this._initData();
			var _local3:Array = new Array();
			if(this._takeSample()) {
				_local1 = 0;
				while(_local1 < this._ecom.getTransLength()) {
					_local4 = this._ecom.getTransFromArray(_local1);
					_local3.push(_local4.toGifParams());
					_local2 = 0;
					while(_local2 < _local4.getItemsLength()) {
						_local3.push(_local4.getItemFromArray(_local2).toGifParams());
						_local2++;
					}
					_local1++;
				}
				_local1 = 0;
				while(_local1 < _local3.length) {
					this._gifRequest.send(this._account,_local3[_local1]);
					_local1++;
				}
			}
		}
		
		private function _sendXEvent(opt_xObj:X10 = null) : void {
			var _local2:Variables = null;
			var _local3:EventInfo = null;
			var _local4:Variables = null;
			var _local5:Variables = null;
			if(this._takeSample()) {
				_local2 = new Variables();
				_local2.URIencode = true;
				_local3 = new EventInfo(true,this._x10Module,opt_xObj);
				_local4 = _local3.toVariables();
				_local5 = this._renderMetricsSearchVariables();
				_local2.join(_local4,_local5);
				this._gifRequest.send(this._account,_local2,false,true);
			}
		}
		
		public function createEventTracker(objName:String) : EventTracker {
			this._debug.info("createEventTracker( " + objName + " )");
			return new EventTracker(objName,this);
		}
		
		public function trackEvent(category:String, action:String, label:String = null, value:Number = NaN) : Boolean {
			this._initData();
			var _local5:Boolean = true;
			var _local6:int = 2;
			if(category != "" && action != "") {
				this._eventTracker.clearKey(this.EVENT_TRACKER_PROJECT_ID);
				this._eventTracker.clearValue(this.EVENT_TRACKER_PROJECT_ID);
				_local5 = this._eventTracker.setKey(this.EVENT_TRACKER_PROJECT_ID,this.EVENT_TRACKER_OBJECT_NAME_KEY_NUM,category);
				_local5 = this._eventTracker.setKey(this.EVENT_TRACKER_PROJECT_ID,this.EVENT_TRACKER_TYPE_KEY_NUM,action);
				if(label) {
					_local5 = this._eventTracker.setKey(this.EVENT_TRACKER_PROJECT_ID,this.EVENT_TRACKER_LABEL_KEY_NUM,label);
					_local6 = 3;
				}
				if(!isNaN(value)) {
					_local5 = this._eventTracker.setValue(this.EVENT_TRACKER_PROJECT_ID,this.EVENT_TRACKER_VALUE_VALUE_NUM,value);
					_local6 = 4;
				}
				if(_local5) {
					this._debug.info("valid event tracking call\ncategory: " + category + "\naction: " + action,VisualDebugMode.geek);
					this._sendXEvent(this._eventTracker);
				}
			} else {
				this._debug.warning("event tracking call is not valid, failed!\ncategory: " + category + "\naction: " + action,VisualDebugMode.geek);
				_local5 = false;
			}
			switch(_local6) {
				case 4:
					this._debug.info("trackEvent( " + [category,action,label,value].join(", ") + " )");
					break;
				case 3:
					this._debug.info("trackEvent( " + [category,action,label].join(", ") + " )");
					break;
				case 2:
				default:
					this._debug.info("trackEvent( " + [category,action].join(", ") + " )");
			}
			return _local5;
		}
		
		public function addIgnoredOrganic(newIgnoredOrganicKeyword:String) : void {
			this._debug.info("addIgnoredOrganic( " + newIgnoredOrganicKeyword + " )");
			this._config.organic.addIgnoredKeyword(newIgnoredOrganicKeyword);
		}
		
		public function addIgnoredRef(newIgnoredReferrer:String) : void {
			this._debug.info("addIgnoredRef( " + newIgnoredReferrer + " )");
			this._config.organic.addIgnoredReferral(newIgnoredReferrer);
		}
		
		public function addOrganic(newOrganicEngine:String, newOrganicKeyword:String) : void {
			this._debug.info("addOrganic( " + [newOrganicEngine,newOrganicKeyword].join(", ") + " )");
			this._config.organic.addSource(newOrganicEngine,newOrganicKeyword);
		}
		
		public function clearIgnoredOrganic() : void {
			this._debug.info("clearIgnoredOrganic()");
			this._config.organic.clearIgnoredKeywords();
		}
		
		public function clearIgnoredRef() : void {
			this._debug.info("clearIgnoredRef()");
			this._config.organic.clearIgnoredReferrals();
		}
		
		public function clearOrganic() : void {
			this._debug.info("clearOrganic()");
			this._config.organic.clearEngines();
		}
		
		public function getClientInfo() : Boolean {
			this._debug.info("getClientInfo()");
			return this._config.detectClientInfo;
		}
		
		public function getDetectFlash() : Boolean {
			this._debug.info("getDetectFlash()");
			return this._config.detectFlash;
		}
		
		public function getDetectTitle() : Boolean {
			this._debug.info("getDetectTitle()");
			return this._config.detectTitle;
		}
		
		public function setClientInfo(enable:Boolean) : void {
			this._config.detectClientInfo = enable;
			this._debug.info("setClientInfo( " + this._config.detectClientInfo + " )");
		}
		
		public function setDetectFlash(enable:Boolean) : void {
			this._config.detectFlash = enable;
			this._debug.info("setDetectFlash( " + this._config.detectFlash + " )");
		}
		
		public function setDetectTitle(enable:Boolean) : void {
			this._config.detectTitle = enable;
			this._debug.info("setDetectTitle( " + this._config.detectTitle + " )");
		}
		
		public function getLocalGifPath() : String {
			this._debug.info("getLocalGifPath()");
			return this._config.localGIFpath;
		}
		
		public function getServiceMode() : ServerOperationMode {
			this._debug.info("getServiceMode()");
			return this._config.serverMode;
		}
		
		public function setLocalGifPath(newLocalGifPath:String) : void {
			this._config.localGIFpath = newLocalGifPath;
			this._debug.info("setLocalGifPath( " + this._config.localGIFpath + " )");
		}
		
		public function setLocalRemoteServerMode() : void {
			this._config.serverMode = ServerOperationMode.both;
			this._debug.info("setLocalRemoteServerMode()");
		}
		
		public function setLocalServerMode() : void {
			this._config.serverMode = ServerOperationMode.local;
			this._debug.info("setLocalServerMode()");
		}
		
		public function setRemoteServerMode() : void {
			this._config.serverMode = ServerOperationMode.remote;
			this._debug.info("setRemoteServerMode()");
		}
	}
}

