package feathers.media {
	import starling.errors.AbstractClassError;
	
	public class BaseTimedMediaPlayer extends BaseMediaPlayer implements ITimedMediaPlayer {
		protected var _isPlaying:Boolean = false;
		
		protected var _currentTime:Number = 0;
		
		protected var _totalTime:Number = 0;
		
		public function BaseTimedMediaPlayer() {
			super();
			if(Object(this).constructor === BaseTimedMediaPlayer) {
				throw new AbstractClassError();
			}
		}
		
		public function get isPlaying() : Boolean {
			return this._isPlaying;
		}
		
		public function get currentTime() : Number {
			return this._currentTime;
		}
		
		public function get totalTime() : Number {
			return this._totalTime;
		}
		
		public function togglePlayPause() : void {
			if(this._isPlaying) {
				this.pause();
			} else {
				this.play();
			}
		}
		
		public function play() : void {
			if(this._isPlaying) {
				return;
			}
			this.playMedia();
			this._isPlaying = true;
			this.dispatchEventWith("playbackStageChange");
		}
		
		public function pause() : void {
			if(!this._isPlaying) {
				return;
			}
			this.pauseMedia();
			this._isPlaying = false;
			this.dispatchEventWith("playbackStageChange");
		}
		
		public function stop() : void {
			this.pause();
			this.seek(0);
		}
		
		public function seek(seconds:Number) : void {
			this.seekMedia(seconds);
			this.dispatchEventWith("currentTimeChange");
		}
		
		protected function playMedia() : void {
		}
		
		protected function pauseMedia() : void {
		}
		
		protected function seekMedia(seconds:Number) : void {
		}
	}
}

