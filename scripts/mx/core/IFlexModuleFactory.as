package mx.core {
	import flash.display.LoaderInfo;
	import flash.utils.Dictionary;
	
	public interface IFlexModuleFactory {
		function get allowDomainsInNewRSLs() : Boolean;
		
		function set allowDomainsInNewRSLs(value:Boolean) : void;
		
		function get allowInsecureDomainsInNewRSLs() : Boolean;
		
		function set allowInsecureDomainsInNewRSLs(value:Boolean) : void;
		
		function get preloadedRSLs() : Dictionary;
		
		function addPreloadedRSL(loaderInfo:LoaderInfo, rsl:Vector.<RSLData>) : void;
		
		function allowDomain(... rest) : void;
		
		function allowInsecureDomain(... rest) : void;
		
		function callInContext(fn:Function, thisArg:Object, argArray:Array, returns:Boolean = true) : *;
		
		function create(... rest) : Object;
		
		function getImplementation(interfaceName:String) : Object;
		
		function info() : Object;
		
		function registerImplementation(interfaceName:String, impl:Object) : void;
	}
}

