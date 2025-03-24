package com.google.analytics.core {
	import com.google.analytics.v4.GoogleAnalyticsAPI;
	import flash.errors.IllegalOperationError;
	
	public class TrackerCache implements GoogleAnalyticsAPI {
		public static var CACHE_THROW_ERROR:Boolean;
		
		private var _ar:Array;
		
		public var tracker:GoogleAnalyticsAPI;
		
		public function TrackerCache(tracker:GoogleAnalyticsAPI = null) {
			super();
			this.tracker = tracker;
			this._ar = [];
		}
		
		public function clear() : void {
			this._ar = [];
		}
		
		public function element() : * {
			return this._ar[0];
		}
		
		public function enqueue(name:String, ... rest) : Boolean {
			if(name == null) {
				return false;
			}
			this._ar.push({
				"name":name,
				"args":rest
			});
			return true;
		}
		
		public function flush() : void {
			var _local1:Object = null;
			var _local2:String = null;
			var _local3:Array = null;
			var _local4:int = 0;
			var _local5:int = 0;
			if(this.tracker == null) {
				return;
			}
			if(this.size() > 0) {
				_local4 = int(this._ar.length);
				while(_local5 < _local4) {
					_local1 = this._ar.shift();
					_local2 = _local1.name as String;
					_local3 = _local1.args as Array;
					if(_local2 != null && _local2 in this.tracker) {
						(this.tracker[_local2] as Function).apply(this.tracker,_local3);
					}
					_local5++;
				}
			}
		}
		
		public function isEmpty() : Boolean {
			return this._ar.length == 0;
		}
		
		public function size() : uint {
			return this._ar.length;
		}
		
		public function addIgnoredOrganic(newIgnoredOrganicKeyword:String) : void {
			this.enqueue("addIgnoredOrganic",newIgnoredOrganicKeyword);
		}
		
		public function addIgnoredRef(newIgnoredReferrer:String) : void {
			this.enqueue("addIgnoredRef",newIgnoredReferrer);
		}
		
		public function addItem(item:String, sku:String, name:String, category:String, price:Number, quantity:int) : void {
			this.enqueue("addItem",item,sku,name,category,price,quantity);
		}
		
		public function addOrganic(newOrganicEngine:String, newOrganicKeyword:String) : void {
			this.enqueue("addOrganic",newOrganicEngine,newOrganicKeyword);
		}
		
		public function addTrans(orderId:String, affiliation:String, total:Number, tax:Number, shipping:Number, city:String, state:String, country:String) : void {
			if(CACHE_THROW_ERROR) {
				throw new IllegalOperationError("The tracker is not ready and you can use the \'addTrans\' method for the moment.");
			}
		}
		
		public function clearIgnoredOrganic() : void {
			this.enqueue("clearIgnoredOrganic");
		}
		
		public function clearIgnoredRef() : void {
			this.enqueue("clearIgnoredRef");
		}
		
		public function clearOrganic() : void {
			this.enqueue("clearOrganic");
		}
		
		public function createEventTracker(objName:String) : EventTracker {
			if(CACHE_THROW_ERROR) {
				throw new IllegalOperationError("The tracker is not ready and you can use the \'createEventTracker\' method for the moment.");
			}
			return null;
		}
		
		public function cookiePathCopy(newPath:String) : void {
			this.enqueue("cookiePathCopy",newPath);
		}
		
		public function getAccount() : String {
			if(CACHE_THROW_ERROR) {
				throw new IllegalOperationError("The tracker is not ready and you can use the \'getAccount\' method for the moment.");
			}
			return "";
		}
		
		public function getClientInfo() : Boolean {
			if(CACHE_THROW_ERROR) {
				throw new IllegalOperationError("The tracker is not ready and you can use the \'getClientInfo\' method for the moment.");
			}
			return false;
		}
		
		public function getDetectFlash() : Boolean {
			if(CACHE_THROW_ERROR) {
				throw new IllegalOperationError("The tracker is not ready and you can use the \'getDetectFlash\' method for the moment.");
			}
			return false;
		}
		
		public function getDetectTitle() : Boolean {
			if(CACHE_THROW_ERROR) {
				throw new IllegalOperationError("The tracker is not ready and you can use the \'getDetectTitle\' method for the moment.");
			}
			return false;
		}
		
		public function getLocalGifPath() : String {
			if(CACHE_THROW_ERROR) {
				throw new IllegalOperationError("The tracker is not ready and you can use the \'getLocalGifPath\' method for the moment.");
			}
			return "";
		}
		
		public function getServiceMode() : ServerOperationMode {
			if(CACHE_THROW_ERROR) {
				throw new IllegalOperationError("The tracker is not ready and you can use the \'getServiceMode\' method for the moment.");
			}
			return null;
		}
		
		public function getVersion() : String {
			if(CACHE_THROW_ERROR) {
				throw new IllegalOperationError("The tracker is not ready and you can use the \'getVersion\' method for the moment.");
			}
			return "";
		}
		
		public function resetSession() : void {
			this.enqueue("resetSession");
		}
		
		public function getLinkerUrl(url:String = "", useHash:Boolean = false) : String {
			if(CACHE_THROW_ERROR) {
				throw new IllegalOperationError("The tracker is not ready and you can use the \'getLinkerUrl\' method for the moment.");
			}
			return "";
		}
		
		public function link(targetUrl:String, useHash:Boolean = false) : void {
			this.enqueue("link",targetUrl,useHash);
		}
		
		public function linkByPost(formObject:Object, useHash:Boolean = false) : void {
			this.enqueue("linkByPost",formObject,useHash);
		}
		
		public function setAllowAnchor(enable:Boolean) : void {
			this.enqueue("setAllowAnchor",enable);
		}
		
		public function setAllowHash(enable:Boolean) : void {
			this.enqueue("setAllowHash",enable);
		}
		
		public function setAllowLinker(enable:Boolean) : void {
			this.enqueue("setAllowLinker",enable);
		}
		
		public function setCampContentKey(newCampContentKey:String) : void {
			this.enqueue("setCampContentKey",newCampContentKey);
		}
		
		public function setCampMediumKey(newCampMedKey:String) : void {
			this.enqueue("setCampMediumKey",newCampMedKey);
		}
		
		public function setCampNameKey(newCampNameKey:String) : void {
			this.enqueue("setCampNameKey",newCampNameKey);
		}
		
		public function setCampNOKey(newCampNOKey:String) : void {
			this.enqueue("setCampNOKey",newCampNOKey);
		}
		
		public function setCampSourceKey(newCampSrcKey:String) : void {
			this.enqueue("setCampSourceKey",newCampSrcKey);
		}
		
		public function setCampTermKey(newCampTermKey:String) : void {
			this.enqueue("setCampTermKey",newCampTermKey);
		}
		
		public function setCampaignTrack(enable:Boolean) : void {
			this.enqueue("setCampaignTrack",enable);
		}
		
		public function setClientInfo(enable:Boolean) : void {
			this.enqueue("setClientInfo",enable);
		}
		
		public function setCookieTimeout(newDefaultTimeout:int) : void {
			this.enqueue("setCookieTimeout",newDefaultTimeout);
		}
		
		public function setCookiePath(newCookiePath:String) : void {
			this.enqueue("setCookiePath",newCookiePath);
		}
		
		public function setDetectFlash(enable:Boolean) : void {
			this.enqueue("setDetectFlash",enable);
		}
		
		public function setDetectTitle(enable:Boolean) : void {
			this.enqueue("setDetectTitle",enable);
		}
		
		public function setDomainName(newDomainName:String) : void {
			this.enqueue("setDomainName",newDomainName);
		}
		
		public function setLocalGifPath(newLocalGifPath:String) : void {
			this.enqueue("setLocalGifPath",newLocalGifPath);
		}
		
		public function setLocalRemoteServerMode() : void {
			this.enqueue("setLocalRemoteServerMode");
		}
		
		public function setLocalServerMode() : void {
			this.enqueue("setLocalServerMode");
		}
		
		public function setRemoteServerMode() : void {
			this.enqueue("setRemoteServerMode");
		}
		
		public function setSampleRate(newRate:Number) : void {
			this.enqueue("setSampleRate",newRate);
		}
		
		public function setSessionTimeout(newTimeout:int) : void {
			this.enqueue("setSessionTimeout",newTimeout);
		}
		
		public function setVar(newVal:String) : void {
			this.enqueue("setVar",newVal);
		}
		
		public function trackEvent(category:String, action:String, label:String = null, value:Number = NaN) : Boolean {
			this.enqueue("trackEvent",category,action,label,value);
			return true;
		}
		
		public function trackPageview(pageURL:String = "") : void {
			this.enqueue("trackPageview",pageURL);
		}
		
		public function trackTrans() : void {
			this.enqueue("trackTrans");
		}
	}
}

