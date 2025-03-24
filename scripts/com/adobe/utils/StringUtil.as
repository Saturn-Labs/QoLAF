package com.adobe.utils {
	public class StringUtil {
		public function StringUtil() {
			super();
		}
		
		public static function stringsAreEqual(s1:String, s2:String, caseSensitive:Boolean) : Boolean {
			if(caseSensitive) {
				return s1 == s2;
			}
			return s1.toUpperCase() == s2.toUpperCase();
		}
		
		public static function trim(input:String) : String {
			return StringUtil.ltrim(StringUtil.rtrim(input));
		}
		
		public static function ltrim(input:String) : String {
			var _local3:Number = NaN;
			var _local2:Number = input.length;
			_local3 = 0;
			while(_local3 < _local2) {
				if(input.charCodeAt(_local3) > 32) {
					return input.substring(_local3);
				}
				_local3++;
			}
			return "";
		}
		
		public static function rtrim(input:String) : String {
			var _local3:* = NaN;
			var _local2:Number = input.length;
			_local3 = _local2;
			while(_local3 > 0) {
				if(input.charCodeAt(_local3 - 1) > 32) {
					return input.substring(0,_local3);
				}
				_local3--;
			}
			return "";
		}
		
		public static function beginsWith(input:String, prefix:String) : Boolean {
			return prefix == input.substring(0,prefix.length);
		}
		
		public static function endsWith(input:String, suffix:String) : Boolean {
			return suffix == input.substring(input.length - suffix.length);
		}
		
		public static function remove(input:String, remove:String) : String {
			return StringUtil.replace(input,remove,"");
		}
		
		public static function replace(input:String, replace:String, replaceWith:String) : String {
			return input.split(replace).join(replaceWith);
		}
		
		public static function stringHasValue(s:String) : Boolean {
			return s != null && s.length > 0;
		}
	}
}

