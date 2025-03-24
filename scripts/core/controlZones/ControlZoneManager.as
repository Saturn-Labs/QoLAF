package core.controlZones {
	import core.scene.Game;
	import flash.utils.Dictionary;
	import playerio.DatabaseObject;
	import playerio.Message;
	
	public class ControlZoneManager {
		public static var claimData:Message;
		
		private var g:Game;
		
		public var controlZones:Vector.<ControlZone> = new Vector.<ControlZone>();
		
		public function ControlZoneManager(g:Game) {
			super();
			this.g = g;
		}
		
		private function onZoneClaimed(m:Message) : void {
			claimData = m;
		}
		
		public function init() : void {
			if(!g.isSystemTypeHostile()) {
				return;
			}
			if(g.me.clanId == "") {
				return;
			}
			load();
		}
		
		public function load(callback:Function = null) : void {
			if(controlZones.length > 0) {
				if(Boolean(callback)) {
					callback();
					return;
				}
				return;
			}
			g.dataManager.loadRangeFromBigDB("ControlZones","ByPlayer",null,function(param1:Array):void {
				onGetControlZones(param1);
				if(Boolean(callback)) {
					callback();
				}
			});
		}
		
		public function addMessageHandlers() : void {
			g.addMessageHandler("updateControlZones",onUpdateControlZones);
			g.addMessageHandler("zoneClaimed",onZoneClaimed);
			g.addServiceMessageHandler("updateClaimedZone",onUpdateClaimedZone);
		}
		
		private function onGetControlZones(zonesArray:Array) : void {
			var _local3:int = 0;
			var _local2:DatabaseObject = null;
			var _local5:ControlZone = null;
			controlZones.length = 0;
			var _local4:int = int(zonesArray.length);
			_local3 = 0;
			while(_local3 < _local4) {
				_local2 = zonesArray[_local3];
				_local5 = new ControlZone();
				_local5.key = _local2.key;
				_local5.claimTime = _local2.claimTime;
				_local5.releaseTime = _local2.releaseTime;
				_local5.playerKey = _local2.player;
				_local5.clanKey = _local2.clan;
				_local5.clanName = _local2.clanName;
				_local5.clanLogo = _local2.clanLogo;
				_local5.clanColor = _local2.clanColor;
				_local5.solarSystemKey = _local2.solarSystem;
				_local5.troonsPerMinute = _local2.troonsPerMinute;
				controlZones.push(_local5);
				_local3++;
			}
		}
		
		public function onUpdateControlZones(m:Message) : void {
			g.sendToServiceRoom("updateControlZones");
		}
		
		public function onUpdateClaimedZone(m:Message) : void {
			var _local2:String = m.getString(0);
			var _local3:ControlZone = getZoneByKey(_local2);
			if(_local3 != null) {
				controlZones.splice(controlZones.indexOf(_local3),1);
			}
			var _local4:int = 1;
			var _local5:ControlZone = new ControlZone();
			_local5.key = _local2;
			_local5.claimTime = m.getNumber(_local4++);
			_local5.releaseTime = m.getNumber(_local4++);
			_local5.playerKey = m.getString(_local4++);
			_local5.clanKey = m.getString(_local4++);
			_local5.clanName = m.getString(_local4++);
			_local5.clanLogo = m.getString(_local4++);
			_local5.clanColor = m.getUInt(_local4++);
			_local5.solarSystemKey = m.getString(_local4++);
			_local5.troonsPerMinute = m.getInt(_local4++);
			controlZones.push(_local5);
			g.hud.clanButton.updateTroons();
		}
		
		public function getZoneByKey(key:String) : ControlZone {
			var _local2:int = 0;
			var _local3:ControlZone = null;
			_local2 = 0;
			while(_local2 < controlZones.length) {
				_local3 = controlZones[_local2];
				if(_local3.key == key) {
					return _local3;
				}
				_local2++;
			}
			return null;
		}
		
		public function getTotalTroonsPerMinute(clanKey:String) : int {
			var _local2:int = 0;
			var _local4:ControlZone = null;
			var _local3:int = 0;
			_local2 = 0;
			while(_local2 < controlZones.length) {
				_local4 = controlZones[_local2];
				if(clanKey == _local4.clanKey) {
					_local3 += _local4.troonsPerMinute;
				}
				_local2++;
			}
			return _local3;
		}
		
		public function getTopTroonsPerMinuteClans() : Vector.<Object> {
			var controlZone:ControlZone;
			var sortedArray:Vector.<Object>;
			var prop:String;
			var topTroonsPerMinuteDict:Dictionary = new Dictionary();
			for each(controlZone in controlZones) {
				if(topTroonsPerMinuteDict[controlZone.clanKey] == null) {
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
			for(prop in topTroonsPerMinuteDict) {
				sortedArray.push(topTroonsPerMinuteDict[prop]);
			}
			sortedArray.sort(function(param1:Object, param2:Object):int {
				return param2.troons - param1.troons;
			});
			return sortedArray;
		}
	}
}

