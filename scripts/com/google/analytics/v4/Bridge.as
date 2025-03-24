package com.google.analytics.v4 {
	import com.google.analytics.core.EventTracker;
	import com.google.analytics.core.ServerOperationMode;
	import com.google.analytics.debug.DebugConfiguration;
	import com.google.analytics.external.JavascriptProxy;
	
	public class Bridge implements GoogleAnalyticsAPI {
		private static var _checkAndLoadGAJS_js:XML = <script>
            <![CDATA[
                function()
                {
					window._gaq = window._gaq || [];
                }
            ]]>
        </script>;
		
		private var _account:String;
		
		private var _debug:DebugConfiguration;
		
		private var _proxy:JavascriptProxy;
		
		private var _jsContainer:String = "_gaq";
		
		public function Bridge(account:String, debug:DebugConfiguration, jsproxy:JavascriptProxy) {
			super();
			this._account = account;
			this._debug = debug;
			this._proxy = jsproxy;
			this._checkAndLoadGAJS();
		}
		
		private function _call(functionName:String, ... rest) : * {
			rest.unshift(functionName);
			var _local3:Array = ["window." + this._jsContainer + ".push",rest];
			return this._proxy.call.apply(this._proxy,_local3);
		}
		
		private function _checkAndLoadGAJS() : Boolean {
			return this._proxy.call(_checkAndLoadGAJS_js);
		}
		
		public function getAccount() : String {
			this._debug.info("getAccount()");
			return this._call("_getAccount");
		}
		
		public function getVersion() : String {
			this._debug.info("getVersion()");
			return this._call("_getVersion");
		}
		
		public function resetSession() : void {
			this._debug.warning("resetSession() not implemented");
		}
		
		public function setAccount(account:String) : void {
			this._debug.info("setAccount( " + account + " )");
			this._call("_setAccount",account);
		}
		
		public function setSampleRate(newRate:Number) : void {
			this._debug.info("setSampleRate( " + newRate + " )");
			this._call("_setSampleRate",newRate);
		}
		
		public function setSessionTimeout(newTimeout:int) : void {
			this._debug.info("setSessionTimeout( " + newTimeout + " )");
			this._call("_setSessionTimeout",newTimeout);
		}
		
		public function setVar(newVal:String) : void {
			this._debug.info("setVar( " + newVal + " )");
			this._call("_setVar",newVal);
		}
		
		public function trackPageview(pageURL:String = "") : void {
			this._debug.info("trackPageview( " + pageURL + " )");
			this._call("_trackPageview",pageURL);
		}
		
		public function setAllowAnchor(enable:Boolean) : void {
			this._debug.info("setAllowAnchor( " + enable + " )");
			this._call("_setAllowAnchor",enable);
		}
		
		public function setCampContentKey(newCampContentKey:String) : void {
			this._debug.info("setCampContentKey( " + newCampContentKey + " )");
			this._call("_setCampContentKey",newCampContentKey);
		}
		
		public function setCampMediumKey(newCampMedKey:String) : void {
			this._debug.info("setCampMediumKey( " + newCampMedKey + " )");
			this._call("_setCampMediumKey",newCampMedKey);
		}
		
		public function setCampNameKey(newCampNameKey:String) : void {
			this._debug.info("setCampNameKey( " + newCampNameKey + " )");
			this._call("_setCampNameKey",newCampNameKey);
		}
		
		public function setCampNOKey(newCampNOKey:String) : void {
			this._debug.info("setCampNOKey( " + newCampNOKey + " )");
			this._call("_setCampNOKey",newCampNOKey);
		}
		
		public function setCampSourceKey(newCampSrcKey:String) : void {
			this._debug.info("setCampSourceKey( " + newCampSrcKey + " )");
			this._call("_setCampSourceKey",newCampSrcKey);
		}
		
		public function setCampTermKey(newCampTermKey:String) : void {
			this._debug.info("setCampTermKey( " + newCampTermKey + " )");
			this._call("_setCampTermKey",newCampTermKey);
		}
		
		public function setCampaignTrack(enable:Boolean) : void {
			this._debug.info("setCampaignTrack( " + enable + " )");
			this._call("_setCampaignTrack",enable);
		}
		
		public function setCookieTimeout(newDefaultTimeout:int) : void {
			this._debug.info("setCookieTimeout( " + newDefaultTimeout + " )");
			this._call("_setCookieTimeout",newDefaultTimeout);
		}
		
		public function cookiePathCopy(newPath:String) : void {
			this._debug.info("cookiePathCopy( " + newPath + " )");
			this._call("_cookiePathCopy",newPath);
		}
		
		public function getLinkerUrl(url:String = "", useHash:Boolean = false) : String {
			this._debug.info("getLinkerUrl(" + url + ", " + useHash + ")");
			return this._call("_getLinkerUrl",url,useHash);
		}
		
		public function link(targetUrl:String, useHash:Boolean = false) : void {
			this._debug.info("link( " + targetUrl + ", " + useHash + " )");
			this._call("_link",targetUrl,useHash);
		}
		
		public function linkByPost(formObject:Object, useHash:Boolean = false) : void {
			this._debug.warning("linkByPost( " + formObject + ", " + useHash + " ) not implemented");
		}
		
		public function setAllowHash(enable:Boolean) : void {
			this._debug.info("setAllowHash( " + enable + " )");
			this._call("_setAllowHash",enable);
		}
		
		public function setAllowLinker(enable:Boolean) : void {
			this._debug.info("setAllowLinker( " + enable + " )");
			this._call("_setAllowLinker",enable);
		}
		
		public function setCookiePath(newCookiePath:String) : void {
			this._debug.info("setCookiePath( " + newCookiePath + " )");
			this._call("_setCookiePath",newCookiePath);
		}
		
		public function setDomainName(newDomainName:String) : void {
			this._debug.info("setDomainName( " + newDomainName + " )");
			this._call("_setDomainName",newDomainName);
		}
		
		public function addItem(item:String, sku:String, name:String, category:String, price:Number, quantity:int) : void {
			this._debug.info("addItem( " + [item,sku,name,category,price,quantity].join(", ") + " )");
			this._call("_addItem",item,sku,name,category,price,quantity);
		}
		
		public function addTrans(orderId:String, affiliation:String, total:Number, tax:Number, shipping:Number, city:String, state:String, country:String) : void {
			this._debug.info("addTrans( " + [orderId,affiliation,total,tax,shipping,city,state,country].join(", ") + " )");
			this._call("_addTrans",orderId,affiliation,total,tax,shipping,city,state,country);
		}
		
		public function trackTrans() : void {
			this._debug.info("trackTrans()");
			this._call("_trackTrans");
		}
		
		public function createEventTracker(objName:String) : EventTracker {
			this._debug.info("createEventTracker( " + objName + " )");
			return new EventTracker(objName,this);
		}
		
		public function trackEvent(category:String, action:String, label:String = null, value:Number = NaN) : Boolean {
			var _local5:int = 2;
			if(Boolean(label) && label != "") {
				_local5 = 3;
			}
			if(_local5 == 3 && !isNaN(value)) {
				_local5 = 4;
			}
			switch(_local5) {
				case 4:
					this._debug.info("trackEvent( " + [category,action,label,value].join(", ") + " )");
					return this._call("_trackEvent",category,action,label,value);
				case 3:
					this._debug.info("trackEvent( " + [category,action,label].join(", ") + " )");
					return this._call("_trackEvent",category,action,label);
				case 2:
			}
			this._debug.info("trackEvent( " + [category,action].join(", ") + " )");
			return this._call("_trackEvent",category,action);
		}
		
		public function addIgnoredOrganic(newIgnoredOrganicKeyword:String) : void {
			this._debug.info("addIgnoredOrganic( " + newIgnoredOrganicKeyword + " )");
			this._call("_addIgnoredOrganic",newIgnoredOrganicKeyword);
		}
		
		public function addIgnoredRef(newIgnoredReferrer:String) : void {
			this._debug.info("addIgnoredRef( " + newIgnoredReferrer + " )");
			this._call("_addIgnoredRef",newIgnoredReferrer);
		}
		
		public function addOrganic(newOrganicEngine:String, newOrganicKeyword:String) : void {
			this._debug.info("addOrganic( " + [newOrganicEngine,newOrganicKeyword].join(", ") + " )");
			this._call("_addOrganic",newOrganicEngine);
		}
		
		public function clearIgnoredOrganic() : void {
			this._debug.info("clearIgnoredOrganic()");
			this._call("_clearIgnoreOrganic");
		}
		
		public function clearIgnoredRef() : void {
			this._debug.info("clearIgnoredRef()");
			this._call("_clearIgnoreRef");
		}
		
		public function clearOrganic() : void {
			this._debug.info("clearOrganic()");
			this._call("_clearOrganic");
		}
		
		public function getClientInfo() : Boolean {
			this._debug.info("getClientInfo()");
			return this._call("_getClientInfo");
		}
		
		public function getDetectFlash() : Boolean {
			this._debug.info("getDetectFlash()");
			return this._call("_getDetectFlash");
		}
		
		public function getDetectTitle() : Boolean {
			this._debug.info("getDetectTitle()");
			return this._call("_getDetectTitle");
		}
		
		public function setClientInfo(enable:Boolean) : void {
			this._debug.info("setClientInfo( " + enable + " )");
			this._call("_setClientInfo",enable);
		}
		
		public function setDetectFlash(enable:Boolean) : void {
			this._debug.info("setDetectFlash( " + enable + " )");
			this._call("_setDetectFlash",enable);
		}
		
		public function setDetectTitle(enable:Boolean) : void {
			this._debug.info("setDetectTitle( " + enable + " )");
			this._call("_setDetectTitle",enable);
		}
		
		public function getLocalGifPath() : String {
			this._debug.info("getLocalGifPath()");
			return this._call("_getLocalGifPath");
		}
		
		public function getServiceMode() : ServerOperationMode {
			this._debug.info("getServiceMode()");
			return this._call("_getServiceMode");
		}
		
		public function setLocalGifPath(newLocalGifPath:String) : void {
			this._debug.info("setLocalGifPath( " + newLocalGifPath + " )");
			this._call("_setLocalGifPath",newLocalGifPath);
		}
		
		public function setLocalRemoteServerMode() : void {
			this._debug.info("setLocalRemoteServerMode()");
			this._call("_setLocalRemoteServerMode");
		}
		
		public function setLocalServerMode() : void {
			this._debug.info("setLocalServerMode()");
			this._call("_setLocalServerMode");
		}
		
		public function setRemoteServerMode() : void {
			this._debug.info("setRemoteServerMode()");
			this._call("_setRemoteServerMode");
		}
	}
}

