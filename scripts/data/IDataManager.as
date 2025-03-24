package data {
	import core.artifact.Artifact;
	import playerio.Client;
	
	public interface IDataManager {
		function getArtifacts() : Vector.<Artifact>;
		
		function setClient(value:Client) : void;
		
		function loadKeyFromBigDB(table:String, key:String, successCallback:Function) : void;
		
		function loadRangeFromBigDB(table:String, index:String, indexPath:Array = null, callback:Function = null, maxCount:int = 1000) : void;
		
		function loadKeysFromBigDB(table:String, keys:Array, callback:Function = null) : void;
		
		function cacheCommonData() : void;
		
		function loadTable(table:String) : Object;
		
		function loadKey(table:String, key:String) : Object;
		
		function loadKeys(table:String, keys:Array) : Array;
		
		function loadRange(table:String, property:String, compareValue:String) : Object;
		
		function loadFirstByProperty(table:String, property:String, compareValue:String) : Object;
	}
}

