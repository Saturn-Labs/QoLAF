package qolaf.data {
	import embeds.qolaf.ModifiersJson;
	import flash.utils.ByteArray;
	import qolaf.utils.Query;
	
	/**
	 * @author rydev
	 */
	public class ModifierInfo {
		private static var MODIFIERS_JSON:ByteArray = new ModifiersJson();
		private static var _modifiersArray:Array = JSON.parse(MODIFIERS_JSON.readUTFBytes(MODIFIERS_JSON.length)) as Array;
		
		public static function getModifier(id:int):Object {
			if (id == -1)
				return null;
			return Query.first(_modifiersArray, function(obj:Object):Boolean {
				return obj.id == id;
			});
		}
	}
}