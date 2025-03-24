package mx.resources {
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	
	public class Locale {
		private static var currentLocale:Locale;
		
		mx_internal static const VERSION:String = "4.6.0.23201";
		
		private var localeString:String;
		
		private var _language:String;
		
		private var _country:String;
		
		private var _variant:String;
		
		public function Locale(localeString:String) {
			super();
			this.localeString = localeString;
			var _local2:Array = localeString.split("_");
			if(_local2.length > 0) {
				this._language = _local2[0];
			}
			if(_local2.length > 1) {
				this._country = _local2[1];
			}
			if(_local2.length > 2) {
				this._variant = _local2.slice(2).join("_");
			}
		}
		
		public function get language() : String {
			return this._language;
		}
		
		public function get country() : String {
			return this._country;
		}
		
		public function get variant() : String {
			return this._variant;
		}
		
		public function toString() : String {
			return this.localeString;
		}
	}
}

