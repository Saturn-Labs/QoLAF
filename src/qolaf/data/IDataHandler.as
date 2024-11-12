package qolaf.data {
	
	/**
	 * @author rydev
	 */
	public interface IDataHandler {
		function getSettingOr(key:String, fallback:Object):Object;
		function setSetting(key:String, value:Object):void;
	}
}