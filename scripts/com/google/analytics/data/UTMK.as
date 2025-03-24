package com.google.analytics.data {
	public class UTMK extends UTMCookie {
		private var _hash:Number;
		
		public function UTMK(hash:Number = NaN) {
			super("utmk","__utmk",["hash"]);
			this.hash = hash;
		}
		
		public function get hash() : Number {
			return this._hash;
		}
		
		public function set hash(value:Number) : void {
			this._hash = value;
			update();
		}
	}
}

