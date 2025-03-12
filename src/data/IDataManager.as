package data
{
	import core.artifact.Artifact;
	import playerio.Client;
	
	public interface IDataManager
	{
		function getArtifacts():Vector.<Artifact>;
		
		function setClient(param1:Client):void;
		
		function loadKeyFromBigDB(param1:String, param2:String, param3:Function):void;
		
		function loadRangeFromBigDB(param1:String, param2:String, param3:Array = null, param4:Function = null, param5:int = 1000):void;
		
		function loadKeysFromBigDB(param1:String, param2:Array, param3:Function = null):void;
		
		function cacheCommonData():void;
		
		function loadTable(param1:String):Object;
		
		function loadKey(param1:String, param2:String):Object;
		
		function loadKeys(param1:String, param2:Array):Array;
		
		function loadRange(param1:String, param2:String, param3:String):Object;
		
		function loadFirstByProperty(param1:String, param2:String, param3:String):Object;
	}
}
