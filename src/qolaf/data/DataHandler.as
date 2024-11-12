package qolaf.data {
	import core.scene.Game;
	/**
	 * ...
	 * @author 
	 */
	public class DataHandler implements IDataHandler {
		public var sharedSettings:SharedSettings;
		
		public function DataHandler(settings:SharedSettings) {
			this.sharedSettings = settings;
		}
		
		public function get playerId():String {
			return Game.instance.playerManager.me.id;
		}
		
		public function getSettingOr(key:String, fallback:Object):Object {
			if (playerId in this.sharedSettings.sharedObject.data && key in this.sharedSettings.sharedObject.data[playerId])
				return this.sharedSettings.sharedObject.data[playerId][key];
			return fallback;
		}
		
		public function setSetting(key:String, value:Object):void {
			if (!(playerId in this.sharedSettings.sharedObject.data))
				this.sharedSettings.sharedObject.data[playerId] = {};
			this.sharedSettings.sharedObject.data[playerId][key] = value;
		}
	}
}