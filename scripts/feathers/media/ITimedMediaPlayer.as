package feathers.media {
	public interface ITimedMediaPlayer extends IMediaPlayer {
		function get currentTime() : Number;
		
		function get totalTime() : Number;
		
		function get isPlaying() : Boolean;
		
		function togglePlayPause() : void;
		
		function play() : void;
		
		function pause() : void;
		
		function stop() : void;
		
		function seek(seconds:Number) : void;
	}
}

