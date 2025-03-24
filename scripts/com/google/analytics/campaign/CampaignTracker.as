package com.google.analytics.campaign {
	import com.google.analytics.utils.Variables;
	
	public class CampaignTracker {
		public var id:String;
		
		public var source:String;
		
		public var clickId:String;
		
		public var name:String;
		
		public var medium:String;
		
		public var term:String;
		
		public var content:String;
		
		public function CampaignTracker(id:String = "", source:String = "", clickId:String = "", name:String = "", medium:String = "", term:String = "", content:String = "") {
			super();
			this.id = id;
			this.source = source;
			this.clickId = clickId;
			this.name = name;
			this.medium = medium;
			this.term = term;
			this.content = content;
		}
		
		private function _addIfNotEmpty(arr:Array, field:String, value:String) : void {
			if(value != "") {
				value = value.split("+").join("%20");
				value = value.split(" ").join("%20");
				arr.push(field + value);
			}
		}
		
		public function isValid() : Boolean {
			if(this.id != "" || this.source != "" || this.clickId != "") {
				return true;
			}
			return false;
		}
		
		public function fromTrackerString(tracker:String) : void {
			var _local2:String = tracker.split(CampaignManager.trackingDelimiter).join("&");
			var _local3:Variables = new Variables(_local2);
			if(_local3.hasOwnProperty("utmcid")) {
				this.id = _local3["utmcid"];
			}
			if(_local3.hasOwnProperty("utmcsr")) {
				this.source = _local3["utmcsr"];
			}
			if(_local3.hasOwnProperty("utmccn")) {
				this.name = _local3["utmccn"];
			}
			if(_local3.hasOwnProperty("utmcmd")) {
				this.medium = _local3["utmcmd"];
			}
			if(_local3.hasOwnProperty("utmctr")) {
				this.term = _local3["utmctr"];
			}
			if(_local3.hasOwnProperty("utmcct")) {
				this.content = _local3["utmcct"];
			}
			if(_local3.hasOwnProperty("utmgclid")) {
				this.clickId = _local3["utmgclid"];
			}
		}
		
		public function toTrackerString() : String {
			var _local1:Array = [];
			this._addIfNotEmpty(_local1,"utmcid=",this.id);
			this._addIfNotEmpty(_local1,"utmcsr=",this.source);
			this._addIfNotEmpty(_local1,"utmgclid=",this.clickId);
			this._addIfNotEmpty(_local1,"utmccn=",this.name);
			this._addIfNotEmpty(_local1,"utmcmd=",this.medium);
			this._addIfNotEmpty(_local1,"utmctr=",this.term);
			this._addIfNotEmpty(_local1,"utmcct=",this.content);
			return _local1.join(CampaignManager.trackingDelimiter);
		}
	}
}

