package generics {
	import com.adobe.serialization.json.JSONDecoder;
	import flash.utils.ByteArray;
	import mx.resources.Locale;
	
	public class Localize {
		private static var langObj:Object;
		
		public static var language:String = "en";
		
		public static var activateLanguageSelection:Boolean = false;
		
		private static var LanguageFile:Class = §lang_json$a96c32d35987e511add5ff79f4dafcea-680055981§;
		
		private static var r:RegExp = new RegExp(/(\W+)/g);
		
		public function Localize() {
			super();
		}
		
		public static function setLocale(locale:String = "en_US") : void {
			var _local2:Locale = new Locale(locale || "en_US");
		}
		
		public static function t(key:String) : String {
			if(!activateLanguageSelection) {
				return key;
			}
			var _local3:String = key.replace(r,"").toLowerCase();
			if(langObj[language] == null) {
				return key;
			}
			var _local2:String = langObj[language][_local3];
			if(_local2 == null) {
				return key;
			}
			if(_local2 == "") {
				return key;
			}
			return langObj[language][_local3].replace(/\\n/g,"\n");
		}
		
		public static function cacheLanguageData() : void {
			var _local2:ByteArray = new LanguageFile() as ByteArray;
			var _local1:JSONDecoder = new JSONDecoder(_local2.readUTFBytes(_local2.length),true);
			langObj = _local1.getValue();
		}
		
		public static function newData(val:String) : void {
			langObj = JSON.parse(val);
		}
	}
}

