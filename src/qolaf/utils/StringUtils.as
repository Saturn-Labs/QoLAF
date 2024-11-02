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
	}
}