package com.google.analytics.v4 {
	import com.google.analytics.core.EventTracker;
	import com.google.analytics.core.ServerOperationMode;
	
	public interface GoogleAnalyticsAPI {
		function getAccount() : String;
		
		function getVersion() : String;
		
		function resetSession() : void;
		
		function setSampleRate(newRate:Number) : void;
		
		function setSessionTimeout(newTimeout:int) : void;
		
		function setVar(newVal:String) : void;
		
		function trackPageview(pageURL:String = "") : void;
		
		function setAllowAnchor(enable:Boolean) : void;
		
		function setCampContentKey(newCampContentKey:String) : void;
		
		function setCampMediumKey(newCampMedKey:String) : void;
		
		function setCampNameKey(newCampNameKey:String) : void;
		
		function setCampNOKey(newCampNOKey:String) : void;
		
		function setCampSourceKey(newCampSrcKey:String) : void;
		
		function setCampTermKey(newCampTermKey:String) : void;
		
		function setCampaignTrack(enable:Boolean) : void;
		
		function setCookieTimeout(newDefaultTimeout:int) : void;
		
		function cookiePathCopy(newPath:String) : void;
		
		function getLinkerUrl(url:String = "", useHash:Boolean = false) : String;
		
		function link(targetUrl:String, useHash:Boolean = false) : void;
		
		function linkByPost(formObject:Object, useHash:Boolean = false) : void;
		
		function setAllowHash(enable:Boolean) : void;
		
		function setAllowLinker(enable:Boolean) : void;
		
		function setCookiePath(newCookiePath:String) : void;
		
		function setDomainName(newDomainName:String) : void;
		
		function addItem(item:String, sku:String, name:String, category:String, price:Number, quantity:int) : void;
		
		function addTrans(orderId:String, affiliation:String, total:Number, tax:Number, shipping:Number, city:String, state:String, country:String) : void;
		
		function trackTrans() : void;
		
		function createEventTracker(objName:String) : EventTracker;
		
		function trackEvent(category:String, action:String, label:String = null, value:Number = NaN) : Boolean;
		
		function addIgnoredOrganic(newIgnoredOrganicKeyword:String) : void;
		
		function addIgnoredRef(newIgnoredReferrer:String) : void;
		
		function addOrganic(newOrganicEngine:String, newOrganicKeyword:String) : void;
		
		function clearIgnoredOrganic() : void;
		
		function clearIgnoredRef() : void;
		
		function clearOrganic() : void;
		
		function getClientInfo() : Boolean;
		
		function getDetectFlash() : Boolean;
		
		function getDetectTitle() : Boolean;
		
		function setClientInfo(enable:Boolean) : void;
		
		function setDetectFlash(enable:Boolean) : void;
		
		function setDetectTitle(enable:Boolean) : void;
		
		function getLocalGifPath() : String;
		
		function getServiceMode() : ServerOperationMode;
		
		function setLocalGifPath(newLocalGifPath:String) : void;
		
		function setLocalRemoteServerMode() : void;
		
		function setLocalServerMode() : void;
		
		function setRemoteServerMode() : void;
	}
}

