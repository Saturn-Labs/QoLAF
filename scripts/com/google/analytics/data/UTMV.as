package com.google.analytics.data {
	import com.google.analytics.utils.Timespan;
	
	public class UTMV extends UTMCookie {
		private var _domainHash:Number;
		
		private var _value:String;
		
		public function UTMV(domainHash:Number = NaN, value:String = "") {
			super("utmv","__utmv",["domainHash","value"],Timespan.twoyears * 1000);
			this.domainHash = domainHash;
			this.value = value;
		}
		
		public function get domainHash() : Number {
			return this._domainHash;
		}
		
		public function set domainHash(value:Number) : void {
			this._domainHash = value;
			update();
		}
		
		public function get value() : String {
			return this._value;
		}
		
		public function set value(value:String) : void {
			this._value = value;
			update();
		}
	}
}

