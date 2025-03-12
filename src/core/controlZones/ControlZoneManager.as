package core.controlZones
{
	import core.scene.Game;
	import flash.utils.Dictionary;
	import playerio.DatabaseObject;
	import playerio.Message;
	
	public class ControlZoneManager
	{
		public static var claimData:Message;
		
		private var g:Game;
		
		public var controlZones:Vector.<ControlZone>;
		
		public function ControlZoneManager(param1:Game)
		{
			controlZones = new Vector.<ControlZone>();
			super();
			this.g = param1;
		}
		
		private function onZoneClaimed(param1:Message):void
		{
			claimData = param1;
		}
		
		public function init():void
		{
			if (!g.isSystemTypeHostile())
			{
				return;
			}
			if (g.me.clanId == "")
			{
				return;
			}
			load();
		}
		
		public function load(param1:Function = null):void
		{
			var callback:Function = param1;
			if (controlZones.length > 0)
			{
				if (Boolean(callback))
				{
					callback();
					return;
				}
				return;
			}
			g.dataManager.loadRangeFromBigDB("ControlZones", "ByPlayer", null, function(param1:Array):void
			{
				onGetControlZones(param1);
				if (Boolean(callback))
				{
					callback();
				}
			});
		}
		
		public function addMessageHandlers():void
		{
			g.addMessageHandler("updateControlZones", onUpdateControlZones);
			g.addMessageHandler("zoneClaimed", onZoneClaimed);
			g.addServiceMessageHandler("updateClaimedZone", onUpdateClaimedZone);
		}
		
		private function onGetControlZones(param1:Array):void
		{
			var _loc5_:int = 0;
			var _loc4_:DatabaseObject = null;
			var _loc2_:ControlZone = null;
			controlZones.length = 0;
			var _loc3_:int = int(param1.length);
			_loc5_ = 0;
			while (_loc5_ < _loc3_)
			{
				_loc4_ = param1[_loc5_];
				_loc2_ = new ControlZone();
				_loc2_.key = _loc4_.key;
				_loc2_.claimTime = _loc4_.claimTime;
				_loc2_.releaseTime = _loc4_.releaseTime;
				_loc2_.playerKey = _loc4_.player;
				_loc2_.clanKey = _loc4_.clan;
				_loc2_.clanName = _loc4_.clanName;
				_loc2_.clanLogo = _loc4_.clanLogo;
				_loc2_.clanColor = _loc4_.clanColor;
				_loc2_.solarSystemKey = _loc4_.solarSystem;
				_loc2_.troonsPerMinute = _loc4_.troonsPerMinute;
				controlZones.push(_loc2_);
				_loc5_++;
			}
		}
		
		public function onUpdateControlZones(param1:Message):void
		{
			g.sendToServiceRoom("updateControlZones");
		}
		
		public function onUpdateClaimedZone(param1:Message):void
		{
			var _loc3_:String = param1.getString(0);
			var _loc4_:ControlZone = getZoneByKey(_loc3_);
			if (_loc4_ != null)
			{
				controlZones.splice(controlZones.indexOf(_loc4_), 1);
			}
			var _loc5_:int = 1;
			var _loc2_:ControlZone = new ControlZone();
			_loc2_.key = _loc3_;
			_loc2_.claimTime = param1.getNumber(_loc5_++);
			_loc2_.releaseTime = param1.getNumber(_loc5_++);
			_loc2_.playerKey = param1.getString(_loc5_++);
			_loc2_.clanKey = param1.getString(_loc5_++);
			_loc2_.clanName = param1.getString(_loc5_++);
			_loc2_.clanLogo = param1.getString(_loc5_++);
			_loc2_.clanColor = param1.getUInt(_loc5_++);
			_loc2_.solarSystemKey = param1.getString(_loc5_++);
			_loc2_.troonsPerMinute = param1.getInt(_loc5_++);
			controlZones.push(_loc2_);
			g.hud.clanButton.updateTroons();
		}
		
		public function getZoneByKey(param1:String):ControlZone
		{
			var _loc3_:int = 0;
			var _loc2_:ControlZone = null;
			_loc3_ = 0;
			while (_loc3_ < controlZones.length)
			{
				_loc2_ = controlZones[_loc3_];
				if (_loc2_.key == param1)
				{
					return _loc2_;
				}
				_loc3_++;
			}
			return null;
		}
		
		public function getTotalTroonsPerMinute(param1:String):int
		{
			var _loc4_:int = 0;
			var _loc2_:ControlZone = null;
			var _loc3_:int = 0;
			_loc4_ = 0;
			while (_loc4_ < controlZones.length)
			{
				_loc2_ = controlZones[_loc4_];
				if (param1 == _loc2_.clanKey)
				{
					_loc3_ += _loc2_.troonsPerMinute;
				}
				_loc4_++;
			}
			return _loc3_;
		}
		
		public function getTopTroonsPerMinuteClans():Vector.<Object>
		{
			var controlZone:ControlZone;
			var sortedArray:Vector.<Object>;
			var prop:String;
			var topTroonsPerMinuteDict:Dictionary = new Dictionary();
			for each (controlZone in controlZones)
			{
				if (topTroonsPerMinuteDict[controlZone.clanKey] == null)
				{
					topTroonsPerMinuteDict[controlZone.clanKey] = {};
					topTroonsPerMinuteDict[controlZone.clanKey].key = controlZone.clanKey;
					topTroonsPerMinuteDict[controlZone.clanKey].name = controlZone.clanName;
					topTroonsPerMinuteDict[controlZone.clanKey].logo = controlZone.clanLogo;
					topTroonsPerMinuteDict[controlZone.clanKey].color = controlZone.clanColor;
					topTroonsPerMinuteDict[controlZone.clanKey].troons = 0;
				}
				topTroonsPerMinuteDict[controlZone.clanKey].troons += controlZone.troonsPerMinute;
			}
			sortedArray = new Vector.<Object>();
			for (prop in topTroonsPerMinuteDict)
			{
				sortedArray.push(topTroonsPerMinuteDict[prop]);
			}
			sortedArray.sort(function(param1:Object, param2:Object):int
			{
				return param2.troons - param1.troons;
			});
			return sortedArray;
		}
	}
}
