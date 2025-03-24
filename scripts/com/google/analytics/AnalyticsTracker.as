package com.google.analytics {
	import com.google.analytics.debug.DebugConfiguration;
	import com.google.analytics.v4.Configuration;
	import com.google.analytics.v4.GoogleAnalyticsAPI;
	import flash.events.IEventDispatcher;
	
	public interface AnalyticsTracker extends GoogleAnalyticsAPI, IEventDispatcher {
		function get account() : String;
		
		function set account(value:String) : void;
		
		function get config() : Configuration;
		
		function set config(value:Configuration) : void;
		
		function get debug() : DebugConfiguration;
		
		function set debug(value:DebugConfiguration) : void;
		
		function get mode() : String;
		
		function set mode(value:String) : void;
		
		function get visualDebug() : Boolean;
		
		function set visualDebug(value:Boolean) : void;
		
		function isReady() : Boolean;
	}
}

