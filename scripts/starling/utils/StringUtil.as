package starling.utils {
	import starling.errors.AbstractClassError;
	
	public class StringUtil {
		public function StringUtil() {
			super();
			throw new AbstractClassError();
		}
		
		public static function format(format:String, ... rest) : String {
			var _local3:int = 0;
			_local3 = 0;
			while(_local3 < rest.length) {
				format = format.replace(new RegExp("\\{" + _local3 + "\\}","g"),rest[_local3]);
				_local3++;
			}
			return format;
		}
		
		public static function clean(string:String) : String {
			return ("_" + string).substr(1);
		}
		
		public static function trimStart(string:String) : String {
			var _local2:int = 0;
			var _local3:int = string.length;
			_local2 = 0;
			while(_local2 < _local3) {
				if(string.charCodeAt(_local2) > 32) {
					break;
				}
				_local2++;
			}
			return string.substring(_local2,_local3);
		}
		
		public static function trimEnd(string:String) : String {
			var _local2:int = 0;
			_local2 = string.length - 1;
			while(_local2 >= 0) {
				if(string.charCodeAt(_local2) > 32) {
					break;
				}
				_local2--;
			}
			return string.substring(0,_local2 + 1);
		}
		
		public static function trim(string:String) : String {
			var _local4:int = 0;
			var _local3:int = 0;
			var _local2:int = string.length;
			_local3 = 0;
			while(_local3 < _local2) {
				if(string.charCodeAt(_local3) > 32) {
					break;
				}
				_local3++;
			}
			_local4 = string.length - 1;
			while(_local4 >= _local3) {
				if(string.charCodeAt(_local4) > 32) {
					break;
				}
				_local4--;
			}
			return string.substring(_local3,_local4 + 1);
		}
	}
}

