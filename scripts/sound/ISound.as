package sound {
	import playerio.Client;
	
	public interface ISound {
		function load(items:Array) : void;
		
		function get percLoaded() : int;
		
		function set client(value:Client) : void;
		
		function play(key:String, loadCompleteCallback:Function = null, playCompleteCallback:Function = null) : void;
		
		function playMusic(key:String, loop:Boolean = false, resume:Boolean = false, loadCompleteCallback:Function = null, playCompleteCallback:Function = null, fade:Boolean = false) : void;
		
		function preCacheSound(key:String, callback:Function = null, type:String = "effect") : void;
		
		function stop(key:String, callback:Function = null) : void;
		
		function stopMusic() : void;
		
		function stopAllMusicExcept(key:String, fade:Boolean = true) : void;
		
		function stopAll() : void;
		
		function get volume() : Number;
		
		function set volume(value:Number) : void;
		
		function get musicVolume() : Number;
		
		function set musicVolume(value:Number) : void;
		
		function get effectVolume() : Number;
		
		function set effectVolume(value:Number) : void;
	}
}

