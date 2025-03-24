package feathers.media {
	public interface IProgressiveMediaPlayer extends IMediaPlayer {
		function get bytesLoaded() : uint;
		
		function get bytesTotal() : uint;
	}
}

