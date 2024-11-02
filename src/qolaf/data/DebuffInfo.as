package qolaf.data {
	import embeds.qolaf.DebuffsJson;
	import flash.utils.ByteArray;
	import qolaf.utils.Query;
	
	/**
	 * @author rydev
	 */
	public class DebuffInfo {
		private static var DEBUFFS_JSON:ByteArray = new DebuffsJson();
		private static var _debuffsArray:Array = JSON.parse(DEBUFFS_JSON.readUTFBytes(DEBUFFS_JSON.length)) as Array;
		
		public static function getDebuff(id:int):Object {
			if (id == -1)
				return null;
			return Query.first(_debuffsArray, function(obj:Object):Boolean {
				return obj.id == id;
			});
		}
	}
}