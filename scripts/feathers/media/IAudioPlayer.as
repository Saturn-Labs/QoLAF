package feathers.media {
	import flash.media.SoundTransform;
	
	public interface IAudioPlayer extends ITimedMediaPlayer {
		function get soundTransform() : SoundTransform;
		
		function set soundTransform(value:SoundTransform) : void;
	}
}

