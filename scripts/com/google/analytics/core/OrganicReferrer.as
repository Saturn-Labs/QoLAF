package com.google.analytics.core {
	public class OrganicReferrer {
		private var _engine:String;
		
		private var _keyword:String;
		
		public function OrganicReferrer(engine:String, keyword:String) {
			super();
			this.engine = engine;
			this.keyword = keyword;
		}
		
		public function get engine() : String {
			return this._engine;
		}
		
		public function set engine(value:String) : void {
			this._engine = value.toLowerCase();
		}
		
		public function get keyword() : String {
			return this._keyword;
		}
		
		public function set keyword(value:String) : void {
			this._keyword = value.toLowerCase();
		}
		
		public function toString() : String {
			return this.engine + "?" + this.keyword;
		}
	}
}

