package com.google.analytics {
	import com.google.analytics.core.Buffer;
	import com.google.analytics.core.Ecommerce;
	import com.google.analytics.core.EventTracker;
	import com.google.analytics.core.GIFRequest;
	import com.google.analytics.core.ServerOperationMode;
	import com.google.analytics.core.TrackerCache;
	import com.google.analytics.core.TrackerMode;
	import com.google.analytics.core.ga_internal;
	import com.google.analytics.debug.DebugConfiguration;
	import com.google.analytics.debug.Layout;
	import com.google.analytics.events.AnalyticsEvent;
	import com.google.analytics.external.AdSenseGlobals;
	import com.google.analytics.external.HTMLDOM;
	import com.google.analytics.external.JavascriptProxy;
	import com.google.analytics.utils.Environment;
	import com.google.analytics.v4.Bridge;
	import com.google.analytics.v4.Configuration;
	import com.google.analytics.v4.GoogleAnalyticsAPI;
	import com.google.analytics.v4.Tracker;
	import core.version;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	use namespace ga_internal;
	
	public class GATracker implements AnalyticsTracker {
		public static var autobuild:Boolean = true;
		
		public static var version:core.version = API.version;
		
		private var _ready:Boolean = false;
		
		private var _display:DisplayObject;
		
		private var _eventDispatcher:EventDispatcher;
		
		private var _tracker:GoogleAnalyticsAPI;
		
		private var _config:Configuration;
		
		private var _debug:DebugConfiguration;
		
		private var _env:Environment;
		
		private var _buffer:Buffer;
		
		private var _gifRequest:GIFRequest;
		
		private var _jsproxy:JavascriptProxy;
		
		private var _dom:HTMLDOM;
		
		private var _adSense:AdSenseGlobals;
		
		private var _ecom:Ecommerce;
		
		private var _account:String;
		
		private var _mode:String;
		
		private var _visualDebug:Boolean;
		
		public function GATracker(display:DisplayObject, account:String, mode:String = "AS3", visualDebug:Boolean = false, config:Configuration = null, debug:DebugConfiguration = null) {
			super();
			this._display = display;
			this._eventDispatcher = new EventDispatcher(this);
			this._tracker = new TrackerCache();
			this.account = account;
			this.mode = mode;
			this.visualDebug = visualDebug;
			if(!debug) {
				this.debug = new DebugConfiguration();
			}
			if(!config) {
				this.config = new Configuration(debug);
			} else {
				this.config = config;
			}
			if(autobuild) {
				this._factory();
			}
		}
		
		private function _factory() : void {
			var _local1:GoogleAnalyticsAPI = null;
			this._jsproxy = new JavascriptProxy(this.debug);
			if(this.visualDebug) {
				this.debug.layout = new Layout(this.debug,this._display);
				this.debug.active = this.visualDebug;
			}
			var _local2:TrackerCache = this._tracker as TrackerCache;
			switch(this.mode) {
				case TrackerMode.BRIDGE:
					_local1 = this._bridgeFactory();
					break;
				case TrackerMode.AS3:
				default:
					_local1 = this._trackerFactory();
			}
			if(!_local2.isEmpty()) {
				_local2.tracker = _local1;
				_local2.flush();
			}
			this._tracker = _local1;
			this._ready = true;
			this.dispatchEvent(new AnalyticsEvent(AnalyticsEvent.READY,this));
		}
		
		private function _trackerFactory() : GoogleAnalyticsAPI {
			this.debug.info("GATracker (AS3) v" + version + "\naccount: " + this.account);
			this._adSense = new AdSenseGlobals(this.debug);
			this._dom = new HTMLDOM(this.debug);
			this._dom.cacheProperties();
			this._env = new Environment("","","",this.debug,this._dom,this._display);
			this._buffer = new Buffer(this.config,this.debug,false);
			this._gifRequest = new GIFRequest(this.config,this.debug,this._buffer,this._env);
			this._ecom = new Ecommerce(this._debug);
			this._env.ga_internal::url = this._display.stage.loaderInfo.url;
			return new Tracker(this.account,this.config,this.debug,this._env,this._buffer,this._gifRequest,this._adSense,this._ecom);
		}
		
		private function _bridgeFactory() : GoogleAnalyticsAPI {
			this.debug.info("GATracker (Bridge) v" + version + "\naccount: " + this.account);
			return new Bridge(this.account,this._debug,this._jsproxy);
		}
		
		public function get account() : String {
			return this._account;
		}
		
		public function set account(value:String) : void {
			this._account = value;
		}
		
		public function get config() : Configuration {
			return this._config;
		}
		
		public function set config(value:Configuration) : void {
			this._config = value;
		}
		
		public function get debug() : DebugConfiguration {
			return this._debug;
		}
		
		public function set debug(value:DebugConfiguration) : void {
			this._debug = value;
		}
		
		public function isReady() : Boolean {
			return this._ready;
		}
		
		public function get mode() : String {
			return this._mode;
		}
		
		public function set mode(value:String) : void {
			this._mode = value;
		}
		
		public function get visualDebug() : Boolean {
			return this._visualDebug;
		}
		
		public function set visualDebug(value:Boolean) : void {
			this._visualDebug = value;
		}
		
		public function build() : void {
			if(!this.isReady()) {
				this._factory();
			}
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false) : void {
			this._eventDispatcher.addEventListener(type,listener,useCapture,priority,useWeakReference);
		}
		
		public function dispatchEvent(event:Event) : Boolean {
			return this._eventDispatcher.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String) : Boolean {
			return this._eventDispatcher.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false) : void {
			this._eventDispatcher.removeEventListener(type,listener,useCapture);
		}
		
		public function willTrigger(type:String) : Boolean {
			return this._eventDispatcher.willTrigger(type);
		}
		
		public function getAccount() : String {
			return this._tracker.getAccount();
		}
		
		public function getVersion() : String {
			return this._tracker.getVersion();
		}
		
		public function resetSession() : void {
			this._tracker.resetSession();
		}
		
		public function setSampleRate(newRate:Number) : void {
			this._tracker.setSampleRate(newRate);
		}
		
		public function setSessionTimeout(newTimeout:int) : void {
			this._tracker.setSessionTimeout(newTimeout);
		}
		
		public function setVar(newVal:String) : void {
			this._tracker.setVar(newVal);
		}
		
		public function trackPageview(pageURL:String = "") : void {
			this._tracker.trackPageview(pageURL);
		}
		
		public function setAllowAnchor(enable:Boolean) : void {
			this._tracker.setAllowAnchor(enable);
		}
		
		public function setCampContentKey(newCampContentKey:String) : void {
			this._tracker.setCampContentKey(newCampContentKey);
		}
		
		public function setCampMediumKey(newCampMedKey:String) : void {
			this._tracker.setCampMediumKey(newCampMedKey);
		}
		
		public function setCampNameKey(newCampNameKey:String) : void {
			this._tracker.setCampNameKey(newCampNameKey);
		}
		
		public function setCampNOKey(newCampNOKey:String) : void {
			this._tracker.setCampNOKey(newCampNOKey);
		}
		
		public function setCampSourceKey(newCampSrcKey:String) : void {
			this._tracker.setCampSourceKey(newCampSrcKey);
		}
		
		public function setCampTermKey(newCampTermKey:String) : void {
			this._tracker.setCampTermKey(newCampTermKey);
		}
		
		public function setCampaignTrack(enable:Boolean) : void {
			this._tracker.setCampaignTrack(enable);
		}
		
		public function setCookieTimeout(newDefaultTimeout:int) : void {
			this._tracker.setCookieTimeout(newDefaultTimeout);
		}
		
		public function cookiePathCopy(newPath:String) : void {
			this._tracker.cookiePathCopy(newPath);
		}
		
		public function getLinkerUrl(url:String = "", useHash:Boolean = false) : String {
			return this._tracker.getLinkerUrl(url,useHash);
		}
		
		public function link(targetUrl:String, useHash:Boolean = false) : void {
			this._tracker.link(targetUrl,useHash);
		}
		
		public function linkByPost(formObject:Object, useHash:Boolean = false) : void {
			this._tracker.linkByPost(formObject,useHash);
		}
		
		public function setAllowHash(enable:Boolean) : void {
			this._tracker.setAllowHash(enable);
		}
		
		public function setAllowLinker(enable:Boolean) : void {
			this._tracker.setAllowLinker(enable);
		}
		
		public function setCookiePath(newCookiePath:String) : void {
			this._tracker.setCookiePath(newCookiePath);
		}
		
		public function setDomainName(newDomainName:String) : void {
			this._tracker.setDomainName(newDomainName);
		}
		
		public function addItem(item:String, sku:String, name:String, category:String, price:Number, quantity:int) : void {
			this._tracker.addItem(item,sku,name,category,price,quantity);
		}
		
		public function addTrans(orderId:String, affiliation:String, total:Number, tax:Number, shipping:Number, city:String, state:String, country:String) : void {
			this._tracker.addTrans(orderId,affiliation,total,tax,shipping,city,state,country);
		}
		
		public function trackTrans() : void {
			this._tracker.trackTrans();
		}
		
		public function createEventTracker(objName:String) : EventTracker {
			return this._tracker.createEventTracker(objName);
		}
		
		public function trackEvent(category:String, action:String, label:String = null, value:Number = NaN) : Boolean {
			return this._tracker.trackEvent(category,action,label,value);
		}
		
		public function addIgnoredOrganic(newIgnoredOrganicKeyword:String) : void {
			this._tracker.addIgnoredOrganic(newIgnoredOrganicKeyword);
		}
		
		public function addIgnoredRef(newIgnoredReferrer:String) : void {
			this._tracker.addIgnoredRef(newIgnoredReferrer);
		}
		
		public function addOrganic(newOrganicEngine:String, newOrganicKeyword:String) : void {
			this._tracker.addOrganic(newOrganicEngine,newOrganicKeyword);
		}
		
		public function clearIgnoredOrganic() : void {
			this._tracker.clearIgnoredOrganic();
		}
		
		public function clearIgnoredRef() : void {
			this._tracker.clearIgnoredRef();
		}
		
		public function clearOrganic() : void {
			this._tracker.clearOrganic();
		}
		
		public function getClientInfo() : Boolean {
			return this._tracker.getClientInfo();
		}
		
		public function getDetectFlash() : Boolean {
			return this._tracker.getDetectFlash();
		}
		
		public function getDetectTitle() : Boolean {
			return this._tracker.getDetectTitle();
		}
		
		public function setClientInfo(enable:Boolean) : void {
			this._tracker.setClientInfo(enable);
		}
		
		public function setDetectFlash(enable:Boolean) : void {
			this._tracker.setDetectFlash(enable);
		}
		
		public function setDetectTitle(enable:Boolean) : void {
			this._tracker.setDetectTitle(enable);
		}
		
		public function getLocalGifPath() : String {
			return this._tracker.getLocalGifPath();
		}
		
		public function getServiceMode() : ServerOperationMode {
			return this._tracker.getServiceMode();
		}
		
		public function setLocalGifPath(newLocalGifPath:String) : void {
			this._tracker.setLocalGifPath(newLocalGifPath);
		}
		
		public function setLocalRemoteServerMode() : void {
			this._tracker.setLocalRemoteServerMode();
		}
		
		public function setLocalServerMode() : void {
			this._tracker.setLocalServerMode();
		}
		
		public function setRemoteServerMode() : void {
			this._tracker.setRemoteServerMode();
		}
	}
}

import com.google.analytics.core.ServerOperationMode;

ServerOperationMode;

