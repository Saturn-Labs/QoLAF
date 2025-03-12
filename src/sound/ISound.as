package sound
{
	import playerio.Client;
	
	public interface ISound
	{
		function load(param1:Array):void;
		
		function get percLoaded():int;
		
		function set client(param1:Client):void;
		
		function play(param1:String, param2:Function = null, param3:Function = null):void;
		
		function playMusic(param1:String, param2:Boolean = false, param3:Boolean = false, param4:Function = null, param5:Function = null, param6:Boolean = false):void;
		
		function preCacheSound(param1:String, param2:Function = null, param3:String = "effect"):void;
		
		function stop(param1:String, param2:Function = null):void;
		
		function stopMusic():void;
		
		function stopAllMusicExcept(param1:String, param2:Boolean = true):void;
		
		function stopAll():void;
		
		function get volume():Number;
		
		function set volume(param1:Number):void;
		
		function get musicVolume():Number;
		
		function set musicVolume(param1:Number):void;
		
		function get effectVolume():Number;
		
		function set effectVolume(param1:Number):void;
	}
}
