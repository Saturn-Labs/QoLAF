package com.google.analytics.debug {
	import com.google.analytics.core.GIFRequest;
	import flash.display.DisplayObject;
	import flash.net.URLRequest;
	
	public interface ILayout {
		function init() : void;
		
		function destroy() : void;
		
		function addToStage(visual:DisplayObject) : void;
		
		function addToPanel(name:String, visual:DisplayObject) : void;
		
		function bringToFront(visual:DisplayObject) : void;
		
		function isAvailable() : Boolean;
		
		function createVisualDebug() : void;
		
		function createPanel(name:String, width:uint, height:uint) : void;
		
		function createInfo(message:String) : void;
		
		function createWarning(message:String) : void;
		
		function createAlert(message:String) : void;
		
		function createFailureAlert(message:String) : void;
		
		function createSuccessAlert(message:String) : void;
		
		function createGIFRequestAlert(message:String, request:URLRequest, ref:GIFRequest) : void;
	}
}

