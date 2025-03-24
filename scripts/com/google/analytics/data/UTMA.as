package com.google.analytics.data {
	import com.google.analytics.utils.Timespan;
	
	public class UTMA extends UTMCookie {
		private var _domainHash:Number;
		
		private var _sessionId:Number;
		
		private var _firstTime:Number;
		
		private var _lastTime:Number;
		
		private var _currentTime:Number;
		
		private var _sessionCount:Number;
		
		public function UTMA(domainHash:Number = NaN, sessionId:Number = NaN, firstTime:Number = NaN, lastTime:Number = NaN, currentTime:Number = NaN, sessionCount:Number = NaN) {
			super("utma","__utma",["domainHash","sessionId","firstTime","lastTime","currentTime","sessionCount"],Timespan.twoyears * 1000);
			this.domainHash = domainHash;
			this.sessionId = sessionId;
			this.firstTime = firstTime;
			this.lastTime = lastTime;
			this.currentTime = currentTime;
			this.sessionCount = sessionCount;
		}
		
		public function get domainHash() : Number {
			return this._domainHash;
		}
		
		public function set domainHash(value:Number) : void {
			this._domainHash = value;
			update();
		}
		
		public function get sessionId() : Number {
			return this._sessionId;
		}
		
		public function set sessionId(value:Number) : void {
			this._sessionId = value;
			update();
		}
		
		public function get firstTime() : Number {
			return this._firstTime;
		}
		
		public function set firstTime(value:Number) : void {
			this._firstTime = value;
			update();
		}
		
		public function get lastTime() : Number {
			return this._lastTime;
		}
		
		public function set lastTime(value:Number) : void {
			this._lastTime = value;
			update();
		}
		
		public function get currentTime() : Number {
			return this._currentTime;
		}
		
		public function set currentTime(value:Number) : void {
			this._currentTime = value;
			update();
		}
		
		public function get sessionCount() : Number {
			return this._sessionCount;
		}
		
		public function set sessionCount(value:Number) : void {
			this._sessionCount = value;
			update();
		}
	}
}

