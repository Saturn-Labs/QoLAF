package qolaf.data
{
	import core.scene.SceneBase;
	import core.scene.Game;
	import flash.geom.Point;
	import flash.net.SharedObject;
	import qolaf.utils.GeneralUtils;

	/**
	 * @author rydev
	 */
	public class ClientSettings
	{
		public static const AUTO_TARGET:String = "auto_target";
		public static const TARGET_INFO_POSITION:String = "target_info_position";
		public static const ZOOM_FACTOR:String = "zoom_factor";
		
		private var _sceneBase:SceneBase;
		private var _sharedObject:SharedObject;
		private var _settingsObject:Object = {};
		
		public function ClientSettings(sceneBase:SceneBase)
		{
			this._sceneBase = sceneBase;
			_sharedObject = SharedObject.getLocal("QoLAFSettings");
			load();
		}

		public function load():void
		{
			deserialize();
		}

		public function save():void
		{
			serialize();
		}

		private function serialize():Boolean
		{
			try
			{
				_sharedObject.data.settings = _settingsObject;
				_sharedObject.flush();
			}
			catch (e:Error)
			{
				trace("Failed to serialize local QoLAF settings: " + e.message);
				return false;
			}

			return true;
		}

		private function deserialize():Boolean
		{
			try
			{
				if ("settings" in _sharedObject.data)
					_settingsObject = _sharedObject.data.settings;
				else
					_settingsObject = buildDefaults();
			}
			catch (e:Error)
			{
				trace("Failed to deserialize local QoLAF settings: " + e.message);
				return false;
			}

			return true;
		}
		
		public function get autoTarget():Boolean
		{
			var playerId:String = Game.instance.playerManager.me.id;
			if (playerId in _settingsObject && AUTO_TARGET in _settingsObject[playerId])
				return _settingsObject[playerId][AUTO_TARGET] as Boolean;
			return false;
		}

		public function get zoomFactor(): Number {
			var playerId:String = Game.instance.playerManager.me.id;
			if (playerId in _settingsObject && ZOOM_FACTOR in _settingsObject[playerId])
				return _settingsObject[playerId][ZOOM_FACTOR] as Number;
			return 1.0;
		}
		
		public function set zoomFactor(value:Number): void 
		{
			var playerId:String = Game.instance.playerManager.me.id;
			if (!(playerId in _settingsObject))
				_settingsObject[playerId] = buildDefaults();
			_settingsObject[playerId][ZOOM_FACTOR] = GeneralUtils.clamp(value, 0.35, 10.0);
		}

		public function set autoTarget(value:Boolean):void
		{
			var playerId:String = Game.instance.playerManager.me.id;
			if (!(playerId in _settingsObject))
				_settingsObject[playerId] = buildDefaults();
			_settingsObject[playerId][AUTO_TARGET] = value;
		}

		public function get targetInfoPosition():Point
		{
			var playerId:String = Game.instance.playerManager.me.id;
			if (playerId in _settingsObject && TARGET_INFO_POSITION in _settingsObject[playerId])
			{
				return new Point(_settingsObject[playerId][TARGET_INFO_POSITION].x, _settingsObject[playerId][TARGET_INFO_POSITION].y);
			}
			return new Point(0.5, 0.08);
		}

		public function set targetInfoPosition(value:Point):void
		{
			var playerId:String = Game.instance.playerManager.me.id;
			if (!(playerId in _settingsObject))
				_settingsObject[playerId] = buildDefaults();
			if (!(TARGET_INFO_POSITION in _settingsObject[playerId]))
				_settingsObject[playerId][TARGET_INFO_POSITION] = {};
			_settingsObject[playerId][TARGET_INFO_POSITION].x = value.x;
			_settingsObject[playerId][TARGET_INFO_POSITION].y = value.y;
		}

		public function buildDefaults():Object
		{
			var object:Object = {};
			object[AUTO_TARGET] = autoTarget;
			object[TARGET_INFO_POSITION] = targetInfoPosition;
			object[ZOOM_FACTOR] = zoomFactor;
			return object;
		}
	}
}