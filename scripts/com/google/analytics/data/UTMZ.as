package com.google.analytics.data {
	import com.google.analytics.utils.Timespan;
	
	public class UTMZ extends UTMCookie {
		public static var defaultTimespan:Number = Timespan.sixmonths;
		
		private var _domainHash:Number;
		
		private var _campaignCreation:Number;
		
		private var _campaignSessions:Number;
		
		private var _responseCount:Number;
		
		private var _campaignTracking:String;
		
		public function UTMZ(domainHash:Number = NaN, campaignCreation:Number = NaN, campaignSessions:Number = NaN, responseCount:Number = NaN, campaignTracking:String = "") {
			super("utmz","__utmz",["domainHash","campaignCreation","campaignSessions","responseCount","campaignTracking"],defaultTimespan * 1000);
			this.domainHash = domainHash;
			this.campaignCreation = campaignCreation;
			this.campaignSessions = campaignSessions;
			this.responseCount = responseCount;
			this.campaignTracking = campaignTracking;
		}
		
		public function get domainHash() : Number {
			return this._domainHash;
		}
		
		public function set domainHash(value:Number) : void {
			this._domainHash = value;
			update();
		}
		
		public function get campaignCreation() : Number {
			return this._campaignCreation;
		}
		
		public function set campaignCreation(value:Number) : void {
			this._campaignCreation = value;
			update();
		}
		
		public function get campaignSessions() : Number {
			return this._campaignSessions;
		}
		
		public function set campaignSessions(value:Number) : void {
			this._campaignSessions = value;
			update();
		}
		
		public function get responseCount() : Number {
			return this._responseCount;
		}
		
		public function set responseCount(value:Number) : void {
			this._responseCount = value;
			update();
		}
		
		public function get campaignTracking() : String {
			return this._campaignTracking;
		}
		
		public function set campaignTracking(value:String) : void {
			this._campaignTracking = value;
			update();
		}
	}
}

