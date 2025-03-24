package core.strings {
	public function userAgent(apptoken:String = "", noself:Boolean = false, minimal:Boolean = false, compatible:Boolean = false):String {
		var _local13:Class = null;
		var _local14:String = null;
		var _local15:String = null;
		var _local5:* = Security.sandboxType == "application";
		if((_local5) && compatible) {
			_local13 = ApplicationDomain.currentDomain.getDefinition("flash.net.URLRequestDefaults") as Class;
			if((Boolean(_local13)) && "userAgent" in _local13) {
				return _local13["userAgent"];
			}
		}
		var _local6:String = compatible ? "Mozilla/5.0" : "Tamarin/" + System.vmVersion;
		var _local7:String = _local5 ? "AdobeAIR" : "AdobeFlashPlayer";
		var _local8:String = Capabilities.version.split(" ")[1].split(",").join(".");
		var _local9:Array = [];
		var _local10:String = Capabilities.manufacturer.split("Adobe ")[1];
		var _local11:String = Capabilities.playerType;
		_local9.push(_local10,_local11);
		if(!minimal) {
			_local14 = Capabilities.os;
			_local15 = _local5 ? Capabilities["languages"] : Capabilities.language;
			_local9.push(_local14,_local15);
		}
		if(Capabilities.isDebugger) {
			_local9.push("DEBUG");
		}
		var _local12:String = "";
		_local12 = _local12 + _local6;
		_local12 = _local12 + (" (" + _local9.join("; ") + ")");
		if(!noself || apptoken == "") {
			_local12 += " " + _local7 + "/" + _local8;
		}
		if(apptoken != "") {
			_local12 += " " + apptoken;
		}
		return _local12;
	}}

import flash.system.ApplicationDomain;
import flash.system.Capabilities;
import flash.system.Security;
import flash.system.System;

