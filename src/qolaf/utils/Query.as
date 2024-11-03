package qolaf.utils {
	
	/**
	 * @author rydev
	 */
	public class Query {
		public static function firstEquals(enumerable:Object, val:*):* {
			if (!isEnumerable(enumerable))
				throw new Error("Enumerable type must be a Vector or a Array.");
			
			for each (var element:* in enumerable) {
				if (element == val)
					return element;
			}
			return null;
		}
		
		public static function first(enumerable:Object, callback:Function):* {
			if (!isEnumerable(enumerable))
				throw new Error("Enumerable type must be a Vector or a Array.");
			
			for each (var element:* in enumerable) {
				if (callback(element))
					return element;
			}
			return null;
		}
		
		public static function removeEquals(enumerable:Object, val:*):Boolean {
			if (!isEnumerable(enumerable))
				throw new Error("Enumerable type must be a Vector or a Array.");
			var idx:int = enumerable.indexOf(val);
			if (idx == -1)
				return false;
			enumerable.removeAt(idx);
			return true;
		}
		
		public static function isEnumerable(obj:Object):Boolean {
			return obj is Vector.<*> || obj is Array;
		}
	}
}