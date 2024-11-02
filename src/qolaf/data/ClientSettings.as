package qolaf.data 
{
	import core.scene.SceneBase;
	import core.scene.Game;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.net.SharedObject;
	
	/**
	 * @author rydev
	 */
	public class ClientSettings 
	{
		public static const SETTINGS_FILE:String = "\\qolaf\\local_settings.json";
		public static const AUTO_TARGET:String = "auto_target";
		
		private var _settingsFile:File;
		private var _sceneBase:SceneBase;
		private var _sharedObject:SharedObject;
		private var _settingsObject:Object = {};
		
		public function ClientSettings(sceneBase:SceneBase) 
		{
			this._sceneBase = sceneBase;
			_settingsFile = new File(File.applicationStorageDirectory.nativePath + SETTINGS_FILE);
			_sharedObject = SharedObject.getLocal("QoLAFSettings");
			load();
		}
		
		public function load(): void {
			deserialize();
		}
		
		public function save(): void {
			serialize();
		}
		
		private function serialize(): Boolean {
			try {
				_sharedObject.data.settings = _settingsObject;
				_sharedObject.flush();
			}
			catch (e:Error) {
				trace("Failed to serialize local QoLAF settings: " + e.message);
				return false;
			}
			
			return true;
		}
		
		private function deserialize(): Boolean {
			try {
				if ("settings" in _sharedObject.data)
					_settingsObject = _sharedObject.data.settings;
				else
					_settingsObject = buildDefaults();
			}
			catch (e:Error) {
				trace("Failed to deserialize local QoLAF settings: " + e.message);
				return false;
			}
			
			return true;
		}
		
		public function get autoTarget(): Boolean {
			var playerId:String = Game.instance.playerManager.me.id;
			if (playerId in _settingsObject && AUTO_TARGET in _settingsObject[playerId])
				return _settingsObject[playerId][AUTO_TARGET] as Boolean;
			return false;
		}
		
		public function set autoTarget(value:Boolean): void 
		{
			var playerId:String = Game.instance.playerManager.me.id;
			if (!(playerId in _settingsObject))
				_settingsObject[playerId] = buildDefaults();
			_settingsObject[playerId][AUTO_TARGET] = value;
		}
		
		public function buildDefaults(): Object {
			var object:Object = {};
			object[AUTO_TARGET] = autoTarget;
			return object;
		}
	}
}