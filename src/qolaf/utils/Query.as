package qolaf.utils {
	
	/**
	 * @author rydev
	 */
	public class Query {
		public static function firstEquals(enumerable:Object, val:*):* {
			if (!(enumerable is Vector.<*>) && !(enumerable is Array))
				throw new Error("Enumerable type must be a Vector or a Array.");
			
			for each (var element:* in enumerable) {
				if (element == val)
					return element;
			}
			return null;
		}
		
		public static function first(enumerable:Object, callback:Function):* {
			if (!(enumerable is Vector.<*>) && !(enumerable is Array))
				throw new Error("Enumerable type must be a Vector or a Array.");
			
			for each (var element:* in enumerable) {
				if (callback(element))
					return element;
			}
			return null;
		}
	}
}