package qolaf.utils {
	
	/**
	 * @author rydev
	 */
	public class StringUtils {
		public static function substitute(fmt:String, args:Object):String {
			var output:String = fmt;
			for (var key:String in args) {
				output = output.replace(key, args[key]);
			}
			return output;
		}
		
		public static function formatTime(ms:Number):String {
			const hours:int = ms / 3600000;
			const minutes:int = (ms % 3600000) / 60000;
			const seconds:int = (ms % 60000) / 1000;

			var result:String = "";
			if (hours > 0) {
				result += hours + "h ";
			}
			if (minutes > 0) {
				result += minutes + "m ";
			}
			if (seconds > 0 || result == "") {
				result += seconds + "s";
			}
			return result;
		}
	}
}