package com.google.analytics.campaign {
	import com.google.analytics.core.Buffer;
	import com.google.analytics.core.OrganicReferrer;
	import com.google.analytics.debug.DebugConfiguration;
	import com.google.analytics.debug.VisualDebugMode;
	import com.google.analytics.utils.Variables;
	import com.google.analytics.v4.Configuration;
	import core.uri;
	
	public class CampaignManager {
		public static const trackingDelimiter:String = "|";
		
		private var _config:Configuration;
		
		private var _debug:DebugConfiguration;
		
		private var _buffer:Buffer;
		
		private var _domainHash:Number;
		
		private var _referrer:String;
		
		private var _timeStamp:Number;
		
		public function CampaignManager(config:Configuration, debug:DebugConfiguration, buffer:Buffer, domainHash:Number, referrer:String, timeStamp:Number) {
			super();
			this._config = config;
			this._debug = debug;
			this._buffer = buffer;
			this._domainHash = domainHash;
			this._referrer = referrer;
			this._timeStamp = timeStamp;
		}
		
		public static function isInvalidReferrer(referrer:String) : Boolean {
			if(referrer == "" || referrer == "-" || referrer == "0") {
				return true;
			}
			var _local2:uri = new uri(referrer);
			if(_local2.scheme == "file" || _local2.scheme == "") {
				return true;
			}
			return false;
		}
		
		public static function isFromGoogleCSE(referrer:String, config:Configuration) : Boolean {
			var _local3:uri = new uri(referrer);
			if(_local3.host.indexOf(config.google) > -1) {
				if(_local3.path == "/" + config.googleCsePath && _local3.query.indexOf(config.googleSearchParam + "=") > -1) {
					return true;
				}
			}
			return false;
		}
		
		public function getCampaignInformation(search:String, noSessionInformation:Boolean) : CampaignInfo {
			var _local4:CampaignTracker = null;
			var _local8:CampaignTracker = null;
			var _local9:int = 0;
			var _local3:CampaignInfo = new CampaignInfo();
			var _local5:* = false;
			var _local6:Boolean = false;
			var _local7:int = 0;
			if(this._config.allowLinker && this._buffer.isGenuine()) {
				if(!this._buffer.hasUTMZ()) {
					return _local3;
				}
			}
			_local4 = this.getTrackerFromSearchString(search);
			if(this.isValid(_local4)) {
				_local6 = this.hasNoOverride(search);
				if((_local6) && !this._buffer.hasUTMZ()) {
					return _local3;
				}
			}
			if(!this.isValid(_local4)) {
				_local4 = this.getOrganicCampaign();
				if(!this._buffer.hasUTMZ() && this.isIgnoredKeyword(_local4)) {
					return _local3;
				}
			}
			if(!this.isValid(_local4) && noSessionInformation) {
				_local4 = this.getReferrerCampaign();
				if(!this._buffer.hasUTMZ() && this.isIgnoredReferral(_local4)) {
					return _local3;
				}
			}
			if(!this.isValid(_local4)) {
				if(!this._buffer.hasUTMZ() && noSessionInformation) {
					_local4 = this.getDirectCampaign();
				}
			}
			if(!this.isValid(_local4)) {
				return _local3;
			}
			if(this._buffer.hasUTMZ() && !this._buffer.utmz.isEmpty()) {
				_local8 = new CampaignTracker();
				_local8.fromTrackerString(this._buffer.utmz.campaignTracking);
				_local5 = _local8.toTrackerString() == _local4.toTrackerString();
				_local7 = this._buffer.utmz.responseCount;
			}
			if(!_local5 || noSessionInformation) {
				_local9 = this._buffer.utma.sessionCount;
				_local7++;
				if(_local9 == 0) {
					_local9 = 1;
				}
				this._buffer.utmz.domainHash = this._domainHash;
				this._buffer.utmz.campaignCreation = this._timeStamp;
				this._buffer.utmz.campaignSessions = _local9;
				this._buffer.utmz.responseCount = _local7;
				this._buffer.utmz.campaignTracking = _local4.toTrackerString();
				this._debug.info(this._buffer.utmz.toString(),VisualDebugMode.geek);
				_local3 = new CampaignInfo(false,true);
			} else {
				_local3 = new CampaignInfo(false,false);
			}
			return _local3;
		}
		
		public function getOrganicCampaign() : CampaignTracker {
			var _local1:CampaignTracker = null;
			var _local3:String = null;
			var _local4:Array = null;
			var _local5:OrganicReferrer = null;
			var _local6:String = null;
			if(isInvalidReferrer(this._referrer) || isFromGoogleCSE(this._referrer,this._config)) {
				return _local1;
			}
			var _local2:uri = new uri(this._referrer);
			if(_local2.host != "" && _local2.host.indexOf(".") > -1) {
				_local4 = _local2.host.split(".");
				switch(_local4.length) {
					case 2:
						_local3 = _local4[0];
						break;
					case 3:
						_local3 = _local4[1];
				}
			}
			if(this._config.organic.match(_local3)) {
				_local5 = this._config.organic.getReferrerByName(_local3);
				_local6 = this._config.organic.getKeywordValue(_local5,_local2.query);
				_local1 = new CampaignTracker();
				_local1.source = _local5.engine;
				_local1.name = "(organic)";
				_local1.medium = "organic";
				_local1.term = _local6;
			}
			return _local1;
		}
		
		public function getReferrerCampaign() : CampaignTracker {
			var _local1:CampaignTracker = null;
			if(isInvalidReferrer(this._referrer) || isFromGoogleCSE(this._referrer,this._config)) {
				return _local1;
			}
			var _local2:uri = new uri(this._referrer);
			var _local3:String = _local2.host;
			var _local4:String = _local2.path;
			if(_local4 == "") {
				_local4 = "/";
			}
			if(_local3.indexOf("www.") == 0) {
				_local3 = _local3.substr(4);
			}
			_local1 = new CampaignTracker();
			_local1.source = _local3;
			_local1.name = "(referral)";
			_local1.medium = "referral";
			_local1.content = _local4;
			return _local1;
		}
		
		public function getDirectCampaign() : CampaignTracker {
			var _local1:CampaignTracker = new CampaignTracker();
			_local1.source = "(direct)";
			_local1.name = "(direct)";
			_local1.medium = "(none)";
			return _local1;
		}
		
		public function hasNoOverride(search:String) : Boolean {
			var _local2:CampaignKey = this._config.campaignKey;
			if(search == "") {
				return false;
			}
			var _local3:Variables = new Variables(search);
			var _local4:String = "";
			if(_local3.hasOwnProperty(_local2.UCNO)) {
				_local4 = _local3[_local2.UCNO];
				switch(_local4) {
					case "1":
						return true;
					case "":
					case "0":
				}
				return false;
			}
			return false;
		}
		
		public function isIgnoredKeyword(tracker:CampaignTracker) : Boolean {
			if(Boolean(tracker) && tracker.medium == "organic") {
				return this._config.organic.isIgnoredKeyword(tracker.term);
			}
			return false;
		}
		
		public function isIgnoredReferral(tracker:CampaignTracker) : Boolean {
			if(Boolean(tracker) && tracker.medium == "referral") {
				return this._config.organic.isIgnoredReferral(tracker.source);
			}
			return false;
		}
		
		public function isValid(tracker:CampaignTracker) : Boolean {
			if(Boolean(tracker) && tracker.isValid()) {
				return true;
			}
			return false;
		}
		
		public function getTrackerFromSearchString(search:String) : CampaignTracker {
			var _local2:CampaignTracker = this.getOrganicCampaign();
			var _local3:CampaignTracker = new CampaignTracker();
			var _local4:CampaignKey = this._config.campaignKey;
			if(search == "") {
				return _local3;
			}
			var _local5:Variables = new Variables(search);
			if(_local5.hasOwnProperty(_local4.UCID)) {
				_local3.id = _local5[_local4.UCID];
			}
			if(_local5.hasOwnProperty(_local4.UCSR)) {
				_local3.source = _local5[_local4.UCSR];
			}
			if(_local5.hasOwnProperty(_local4.UGCLID)) {
				_local3.clickId = _local5[_local4.UGCLID];
			}
			if(_local5.hasOwnProperty(_local4.UCCN)) {
				_local3.name = _local5[_local4.UCCN];
			} else {
				_local3.name = "(not set)";
			}
			if(_local5.hasOwnProperty(_local4.UCMD)) {
				_local3.medium = _local5[_local4.UCMD];
			} else {
				_local3.medium = "(not set)";
			}
			if(_local5.hasOwnProperty(_local4.UCTR)) {
				_local3.term = _local5[_local4.UCTR];
			} else if(Boolean(_local2) && _local2.term != "") {
				_local3.term = _local2.term;
			}
			if(_local5.hasOwnProperty(_local4.UCCT)) {
				_local3.content = _local5[_local4.UCCT];
			}
			return _local3;
		}
	}
}

